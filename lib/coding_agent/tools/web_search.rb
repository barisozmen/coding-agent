# frozen_string_literal: true

require "ruby_llm/tool"
require_relative "../concerns/toolable"

module CodingAgent
  module Tools
    # Web search using SerpApi (Google Search Results)
    # Enables the agent to search the web for current information
    class WebSearch < RubyLLM::Tool
      include Concerns::Toolable

      # Constants for search configuration
      MAX_RESULTS = 10
      MIN_RESULTS = 1
      DEFAULT_RESULTS = 5
      DISPLAY_WIDTH = 60

      description "Search the web using Google to find current information, documentation, " \
                  "error solutions, or any information not in the training data. " \
                  "Returns relevant search results with titles, snippets, and links. " \
                  "Perfect for finding latest documentation, debugging errors, " \
                  "researching best practices, or getting current information."

      param :query,
            desc: "The search query to search for on Google",
            required: true,
            type: :string

      param :num_results,
            desc: "Number of results to return (default: #{DEFAULT_RESULTS}, max: #{MAX_RESULTS})",
            required: false,
            type: :integer

      def execute(query: nil, num_results: DEFAULT_RESULTS)
        return validation_error("Search query is required") if query.blank?
        unless api_key_configured?
          return validation_error("SERPAPI_API_KEY is not set", instructions: api_key_instructions)
        end
        unless search_gem_available?
          return validation_error("google_search_results gem is not installed. Run: bundle install")
        end

        num_results = num_results.clamp(MIN_RESULTS, MAX_RESULTS)
        output.info("Searching Google for: '#{query}'")

        perform_search(query, num_results)
      rescue StandardError => e
        search_error(e)
      end

      private

      # Validation and error handling methods
      def validation_error(message, instructions: nil)
        output.error(message)
        { error: message, instructions: instructions }.compact
      end

      def search_error(exception)
        output.error("Search failed: #{exception.message}")
        { error: exception.message }
      end

      def api_key_configured?
        ENV["SERPAPI_API_KEY"].present?
      end

      def search_gem_available?
        require "google_search_results"
        true
      rescue LoadError
        false
      end

      def api_key_instructions
        "Get your API key from https://serpapi.com/ and add it to your .env file"
      end

      def perform_search(query, num_results)
        search = GoogleSearch.new(
          q: query,
          api_key: ENV.fetch("SERPAPI_API_KEY"),
          num: num_results
        )

        results = search.get_hash
        return { error: results[:error] } if results[:error]

        formatted_results = format_results(results)
        display_search_results(query, formatted_results)
        formatted_results
      end

      # Display methods
      def display_search_results(query, results)
        output.success("Found #{results[:total_results]} results for '#{query}'")
        output.info("") # Empty line for spacing

        # display_answer_box(results[:answer_box]) if results[:answer_box]
        # display_knowledge_graph(results[:knowledge_graph]) if results[:knowledge_graph]
        display_organic_results(results[:results])
      end

      def display_answer_box(answer_box)
        output.info("━" * DISPLAY_WIDTH)
        output.info("Quick Answer:")
        output.info("  #{answer_box[:answer]}") if answer_box[:answer]
        output.info("  #{answer_box[:snippet]}") if answer_box[:snippet]
        output.info("━" * DISPLAY_WIDTH)
        output.info("") # Empty line for spacing
      end

      def display_knowledge_graph(kg)
        output.info("━" * DISPLAY_WIDTH)
        output.info("Knowledge Graph:")
        output.info("  #{kg[:title]}") if kg[:title]
        output.info("  Type: #{kg[:type]}") if kg[:type]
        output.info("  #{kg[:description]}") if kg[:description]
        output.info("  Source: #{kg[:source]}") if kg[:source]
        output.info("━" * DISPLAY_WIDTH)
        output.info("") # Empty line for spacing
      end

      def display_organic_results(results)
        output.info("Search Results:")
        output.info("─" * DISPLAY_WIDTH)

        results.each_with_index do |result, index|
          display_single_result(result, index)
          output.info("")
          # output.info("─" * DISPLAY_WIDTH) unless index == results.size - 1
        end
      end

      def display_single_result(result, index)
        output.info("#{index + 1}. #{result[:title]}")
        output.info("   🔗 #{result[:link]}") if result[:link]
        # output.info("   #{result[:snippet]}") if result[:snippet]
        # output.info("   → #{result[:displayed_link]}") if result[:displayed_link]
      end

      def format_results(raw_results)
        organic_results = raw_results[:organic_results] || []

        results = organic_results.first(MAX_RESULTS).map do |result|
          {
            title: result[:title],
            link: result[:link],
            snippet: result[:snippet],
            displayed_link: result[:displayed_link],
          }.compact
        end

        # Include knowledge graph if available (often appears for factual queries)
        knowledge_graph = raw_results[:knowledge_graph]
        formatted_kg = nil

        if knowledge_graph
          formatted_kg = {
            title: knowledge_graph[:title],
            type: knowledge_graph[:type],
            description: knowledge_graph[:description],
            source: knowledge_graph.dig(:source, :name),
          }.compact
        end

        # Include answer box if available (often appears for direct questions)
        answer_box = raw_results[:answer_box]
        formatted_ab = nil

        if answer_box
          formatted_ab = {
            answer: answer_box[:answer],
            title: answer_box[:title],
            snippet: answer_box[:snippet],
          }.compact
        end

        {
          query: raw_results[:search_metadata][:query],
          results: results,
          knowledge_graph: formatted_kg,
          answer_box: formatted_ab,
          total_results: results.size,
        }.compact
      end
    end
  end
end

# frozen_string_literal: true

module Omca
  module Db
    # Runs query and writes results to CSV
    class QueryWriter
      class << self
        def call(...) = new(...).call
      end

      def initialize(query:, path:)
        @query = query
        @path = path
      end

      def call
        ct = results.num_tuples
        return ct if ct == 0

        CSV.open(
          path,
          "w",
          headers: headers,
          write_headers: true
        ) do |csv|
          puts "  Writing #{ct} rows"
          results.each { |row| csv << row.values_at(*headers) }
        end

        ct
      end

      private

      attr_reader :query, :path

      def results = @results ||= Omca::Db::Connection.call.exec(query)

      def headers = @headers ||= results&.first&.keys
    end
  end
end

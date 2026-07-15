# frozen_string_literal: true

module Omca
  module Rels
    class AuthhierSource
      def initialize(rectype:, path:)
        @rectype = rectype
        @path = path
      end

      def run
        Omca::Db::QueryWriter.call(
          query: Omca::Db::Queries.auth_hier_rel_data(rectype),
          path: path
        )
        puts "Wrote results to #{path}"
      end

      private

      attr_reader :rectype, :path
    end
  end
end

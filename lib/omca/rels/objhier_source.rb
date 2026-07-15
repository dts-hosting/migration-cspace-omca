# frozen_string_literal: true

module Omca
  module Rels
    class ObjhierSource
      def initialize(path:)
        @path = path
      end

      def run
        Omca::Db::QueryWriter.call(
          query: Omca::Db::Queries.obj_hier_rel_data,
          path: path
        )
        puts "Wrote results to #{path}"
      end

      private

      attr_reader :path
    end
  end
end

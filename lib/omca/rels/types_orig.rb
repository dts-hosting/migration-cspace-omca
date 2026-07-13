# frozen_string_literal: true

module Omca
  module Rels
    class TypesOrig
      def self.desc = "Undeduplicated rel type info from DB"

      def self.run = new.run

      def run
        Omca::Db::QueryWriter.call(
          query: Omca::Db::Queries.rel_types,
          path: Omca::Rels.types_orig_path
        )
        puts "Wrote results to #{Omca::Rels.types_orig_path}"
      end
    end
  end
end

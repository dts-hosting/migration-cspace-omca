# frozen_string_literal: true

module Omca
  module Rels
    class TypesOrig
      def self.desc = "Undeduplicated rel type info from DB"

      def self.run = new.run

      def source = :omca_source_db

      def destination = :rel_info__types_orig

      def dest_path = Omca.registry.resolve(destination).path
      def run
        Omca::Db::QueryWriter.call(
          query: Omca::Db::Queries.rel_types,
          path: dest_path
        )
        puts "Wrote #{outrows} rows to #{dest_path}"
      end
    end
  end
end

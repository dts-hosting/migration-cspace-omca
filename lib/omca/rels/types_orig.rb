# frozen_string_literal: true

module Omca
  module Rels
    class TypesOrig
      include Omca::DynamicCsvJobable

      def self.desc = "Undeduplicated rel type info from DB"

      def source = :omca_source_db

      def destination = :rel_info__types_orig

      def job_code
        Omca::Db::QueryWriter.call(
          query: Omca::Db::Queries.rel_types,
          path: destination_path
        )
      end
    end
  end
end

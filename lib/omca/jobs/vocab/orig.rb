# frozen_string_literal: true

module Omca
  module Jobs
    module Vocab
      class Orig
        include Omca::DynamicCsvJobable

        def source = :omca_source_db

        def destination = :vocab__orig

        def job_code
          query = Omca::Db::Queries.vocab_items
          Omca::Db::QueryWriter.call(query: query, path: destination_path)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Omca
  module Jobs
    module StructuredDates
      class UniqDisplaydates
        include Omca::DynamicCsvJobable

        def self.desc = "Extract unique :datedisplaydate values from "\
          "preprocessed structured_date tables"

        def source = %i[
          preprocess_structured_dates__top
          preprocess_structured_dates__nested
        ]

        def source_path = Omca.registry
          .resolve(source.first)
          .path

        def othersource_path = Omca.registry
          .resolve(source.last)
          .path

        def destination = :structured_dates__uniq_displaydates

        def job_code
          `#{cmd}`
        end

        private

        def cmd
          "xan cat rows -U #{source_path} #{othersource_path} | "\
            "xan select datedisplaydate | "\
            "xan dedup -s datedisplaydate > #{destination_path}"
        end
      end
    end
  end
end

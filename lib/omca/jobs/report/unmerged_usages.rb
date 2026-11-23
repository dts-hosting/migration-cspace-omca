# frozen_string_literal: true

module Omca
  module Jobs
    module Report
      class UnmergedUsages
        include Omca::DynamicCsvJobable

        def self.desc = "Verifies count of usages is same as for "\
          "authorities__usages_final_source; writes out rows not matching "\
          "expected new refname pattern"

        def source = %i[
          authorities__usages_authmerged
          authorities__usages_final_source
        ]

        def destination = :report__unmerged_usages

        def source_path = Omca.registry
          .resolve(source.first)
          .path

        def compare_path = Omca.registry
          .resolve(source.last)
          .path

        def job_code
          `#{cmd}`
        end

        private

        def cmd
          "xan join --anti id #{compare_path} id #{source_path} "\
            " > #{destination_path}"
        end
      end
    end
  end
end

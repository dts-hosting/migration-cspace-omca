# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module UniqUsages
        module_function

        def desc = "Write one row per used refname, with count of "\
          "usages. Note that different refnames for the same term record may "\
          "have been used, so this output may still have multiple rows per term"

        def job(source:, destination:)
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: source,
              destination: destination
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::UniqAuthUsages
          end
        end
      end
    end
  end
end

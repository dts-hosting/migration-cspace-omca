# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module UniqUsagesExplode
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :unlinked_auth__uniq_usages,
              destination: :unlinked_auth__uniq_usages_explode
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Explode::RowsFromGroupedMultivalFields,
              fields: %i[termid form],
              placeholder: "%NULLVALUE%"
            transform Clean::StripFields,
              fields: :all
          end
        end
      end
    end
  end
end

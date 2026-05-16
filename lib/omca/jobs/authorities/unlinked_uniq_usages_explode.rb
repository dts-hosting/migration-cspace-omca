# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module UnlinkedUniqUsagesExplode
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__unlinked_uniq_usages,
              destination: :authorities__unlinked_uniq_usages_explode
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

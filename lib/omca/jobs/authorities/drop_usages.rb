# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module DropUsages
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :non_refname_auth__usages_final,
              destination: :authorities__drop_usages
            },
            transformer: xforms
          )
        end

        # @todo xan-ify this
        def xforms
          Kiba.job_segment do
            removals = Omca::Mappings::Fields.usage_removals
            transform FilterRows::WithLambda,
              action: :reject,
              lambda: ->(row) { removals.include?([row[:table], row[:field]]) }
          end
        end
      end
    end
  end
end

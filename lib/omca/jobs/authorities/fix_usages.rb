# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module FixUsages
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :non_refname_auth__usages_final,
              destination: :authorities__fix_usages
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            removals = Omca::Mappings::Fields.usage_removals
            transform do |row|
              next if removals.include?([row[:table], row[:field]])

              row
            end
          end
        end
      end
    end
  end
end

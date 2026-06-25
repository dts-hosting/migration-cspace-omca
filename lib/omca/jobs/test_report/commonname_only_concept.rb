# frozen_string_literal: true

module Omca
  module Jobs
    module TestReport
      module CommonnameOnlyConcept
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__fix_malformed_usages,
              destination: :test_report__commonname_only_concept
            },
            transformer: [Omca::Authorities.add_term_index, xforms]
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: :authority,
              value: "conceptauthorities"
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: :vocab,
              value: "concept"
            transform Delete::Fields,
              fields: %i[tabletype id authority vocab termid form refname]
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[table field],
              target: :usage,
              delete_sources: true,
              delim: "."
            transform Deduplicate::Table,
              field: :index,
              compile_uniq_fieldvals: true
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: :usage,
              value: "commonnamegroup.commonname"
          end
        end
      end
    end
  end
end

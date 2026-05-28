# frozen_string_literal: true

module Omca
  module Jobs
    module MapReport
      module ConditioncheckCondition
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :preprocess_addtl_fields__conditionchecks_omca,
              destination: :map_report__conditioncheck_condition
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::FieldsExcept,
              fields: %i[condition needstreatment okforexhibitloanaccession]
            transform FilterRows::AnyFieldsPopulated,
              action: :keep,
              fields: %i[condition needstreatment okforexhibitloanaccession]

            cond = /^(?:excellent|good|fair|poor)$/i
            transform do |row|
              val = row[:condition]
              row[:condition_jmapping] = if val.blank?
                nil
              elsif val.match?(cond)
                val
              end
              row
            end

            transform Copy::Field,
              from: :condition,
              to: :condition_kmapping

            transform Copy::Field,
              from: :okforexhibitloanaccession,
              to: :okforexhibitloanaccession_jmapping

            transform Replace::FieldValueWithStaticMapping,
              source: :okforexhibitloanaccession_jmapping,
              mapping: {
                "t" => "needs no work",
                "f" => nil
              }

            transform Copy::Field,
              from: :okforexhibitloanaccession,
              to: :okforexhibitloanaccession_kmapping

            transform Replace::FieldValueWithStaticMapping,
              source: :okforexhibitloanaccession_kmapping,
              mapping: {
                "t" => "exhibitable / loanable",
                "f" => "not exhibitable / loanable"
              }

            transform Copy::Field,
              from: :needstreatment,
              to: :needstreatment_jmapping

            transform Replace::FieldValueWithStaticMapping,
              source: :needstreatment_jmapping,
              mapping: {
                "yes" => "exhibitable / needs work",
                "no" => nil
              }

            transform Copy::Field,
              from: :needstreatment,
              to: :needstreatment_kmapping

            transform Replace::FieldValueWithStaticMapping,
              source: :needstreatment_kmapping,
              mapping: {
                "yes" => "needs work",
                "no" => "needs no work"
              }

            transform do |row|
              row[:condition_migrating_j] = %i[
                condition_jmapping needstreatment_jmapping
                okforexhibitloanaccession_jmapping
              ].map { |field| row[field] }
                .reject(&:blank?)
                .uniq
                .sort
                .join("; ")

              row
            end

            transform do |row|
              row[:condition_migrating_k] = %i[
                condition_kmapping needstreatment_kmapping
                okforexhibitloanaccession_kmapping
              ].map { |field| row[field] }
                .reject(&:blank?)
                .uniq
                .sort
                .join("; ")

              row
            end
            transform Rename::Fields, fieldmap: {
              okforexhibitloanaccession: :okforexhibitloanaccession_orig,
              condition: :condition_orig,
              needstreatment: :needstreatment_orig
            }

            transform CombineValues::FullRecord
            transform Deduplicate::Table,
              field: :index,
              delete_field: true,
              include_occs: true
          end
        end
      end
    end
  end
end

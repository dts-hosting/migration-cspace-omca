# frozen_string_literal: true

module Omca
  module BigAuthFcar
    module_function

    extend Dry::Configurable

    def base_job = :big_auth__prep

    def fingerprint_fields = %i[index form new_form]

    extend Kiba::Extend::Mixins::IterativeCleanup

    def orig_values_identifier = :matchfingerprint

    def worksheet_add_fields = %i[new_form]

    def worksheet_field_order = %i[form new_form authority vocab occurrences]

    def job_tags = %i[big_auth]

    def cleanup_base_name = "big_auth"

    def final_lookup_on_field = :rectype

    def final_post_xforms
      Kiba.job_segment do
        transform FilterRows::FieldPopulated,
          action: :keep,
          field: :new_form
        transform Fingerprint::Decode,
          fingerprint: :matchfingerprint,
          source_fields: %i[index form]
        transform Delete::Fields,
          fields: %i[form fp_form authority vocab occurrences termid index]
        transform Rename::Fields, fieldmap: {
          fp_index: :index
        }
        transform do |row|
          vals = row[:index].split(" ")
          row[:authority] = vals.shift
          row[:vocab] = vals.shift
          row[:termid] = vals.shift
          row[:rectype] = Omca::Mappers.rectype_by_authority_type(
            row[:authority]
          )
          row
        end
        transform Omca::Xforms::BigAuthFlagTermCombos
      end
    end
  end
end

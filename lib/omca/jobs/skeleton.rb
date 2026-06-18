# frozen_string_literal: true

module Omca
  module Jobs
    module Skeleton
      module_function

      def job(source:, dest:, table:, rectype:, id_field:)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: get_source(source, table),
            destination: dest
          },
          transformer: xforms(rectype, id_field)
        )
      end

      def get_source(source, table)
        Omca::Dependencies.ensure_fix(table)

        source
      end

      def xforms(rectype, id_field)
        Kiba.job_segment do
          keepfields = Omca::Mappings::Fields.skeleton_fields(
            rectype, "main"
          ).map { |row| row["target_field"].to_sym } - [id_field] +
            [:recordcsid, Omca.ingestid_field, Omca::Authorities.used_tag_field]

          if Omca::Mappers.authority?(rectype)
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: Omca::Authorities.used_tag_field,
              value: "y"
            transform Delete::Fields,
              fields: Omca::Authorities.used_tag_field
          end
          transform Delete::FieldsExcept,
            fields: keepfields

          transform Rename::Field,
            from: Omca.ingestid_field,
            to: id_field

          Omca::Mappings::Fields.skeleton_fields(
            rectype, "repeatable_field"
          ).each do |row|
            transform Omca::Xforms::MergeRepeatableField,
              config: row
          end

          Omca::Mappings::Fields.skeleton_fields(
            rectype, "addtl_fields"
          ).each do |row|
            transform Omca::Xforms::MergeAddtlField,
              config: row
          end
        end
      end
    end
  end
end

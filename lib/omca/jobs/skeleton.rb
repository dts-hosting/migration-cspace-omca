# frozen_string_literal: true

module Omca
  module Jobs
    module Skeleton
      module_function

      def job(source:, dest:, table:, rectype:, id_field:, source_phase:,
        auth_subtype: nil)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest,
            lookup: get_lookups(rectype, source_phase)
          },
          transformer: xforms(rectype, id_field, auth_subtype, source_phase)
        )
      end

      def lookup_table_field(rectype)
        target_types = %w[exit]
        return "source_db_table" unless target_types.include?(rectype)

        "target_db_table"
      end

      def get_lookups(rectype, source_phase)
        base = []
        Omca::Mappings::Fields.skeleton_fields(rectype, "repeatable_field")
          .each do |cfg|
            base << Omca.jobkey_for(
              source_phase, cfg[lookup_table_field(rectype)]
            )
          end
        Omca::Mappings::Fields.skeleton_fields(rectype, "addtl_fields")
          .each do |cfg|
            base << Omca.jobkey_for(
              source_phase, cfg["source_db_table"]
            )
          end
        base.select { |jobkey| Kiba::Extend::Job.output?(jobkey) }
          .map { |jobkey| {jobkey: jobkey, lookup_on: :recordcsid} }
      end

      def xforms(rectype, id_field, auth_subtype, source_phase)
        bind = binding

        Kiba.job_segment do
          mod = bind.receiver

          keepfields = Omca::Mappings::Fields.skeleton_fields(
            rectype, "main"
          ).map { |row| row["target_field"].to_sym } - [id_field] +
            [:recordcsid, Omca.ingestid_field, Omca::Authorities.used_tag_field]

          if Omca::Mappers.authority?(rectype)
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: :authority,
              value: auth_subtype
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: Omca::Authorities.used_tag_field,
              value: "y"
            transform Delete::Fields,
              fields: [Omca::Authorities.used_tag_field, :authority]
            transform Delete::EmptyFields
          end

          transform Delete::FieldsExcept,
            fields: keepfields

          transform Rename::Field,
            from: Omca.ingestid_field,
            to: id_field

          Omca::Mappings::Fields.skeleton_fields(
            rectype, "repeatable_field"
          ).each do |cfg|
            lkup_meth = Omca.jobkey_for(
              source_phase, cfg[mod.lookup_table_field(rectype)]
            )
            transform Omca::Xforms::MergeRepeatableField,
              config: cfg,
              lookup: send(lkup_meth)
          end

          Omca::Mappings::Fields.skeleton_fields(
            rectype, "addtl_fields"
          ).each do |row|
            transform Omca::Xforms::MergeAddtlField,
              config: row
          end

          if rectype == "movement"
            transform Rename::Fields, fieldmap: {
              movementcontact: :movementcontactrefname,
              currentlocation: :currentlocationrefname,
              inventorycontact: :inventorycontactrefname
            }
          end
        end
      end
    end
  end
end

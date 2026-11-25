# frozen_string_literal: true

module Omca
  module Jobs
    module Ingest
      module_function

      def job(source:, dest:, rectype:, id_field:, auth_subtype: nil)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest
          },
          transformer: xforms(rectype, id_field, auth_subtype)
        )
      end

      def xforms(rectype, id_field, auth_subtype)
        Kiba.job_segment do
          renamemap = Omca::Mappings::Fields.authority_controlled_target_rows
            .select { |r| r["target_record_type"] == rectype }
            .to_h do |r|
              [r["target_field"], "#{r["target_field"]}refname"].map(&:to_sym)
            end

          unless renamemap.empty?
            transform Rename::Fields, fieldmap: renamemap
          end

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
              fields: [Omca::Authorities.used_tag_field, :authority, :refname,
                :shortidentifier, :origpref]
            transform do |row|
              pref = row[Omca.ingestid_field]
              tdn = row[id_field].split(Omca.delim)[1..]
              row[id_field] = [pref, tdn].flatten.join(Omca.delim)
              row.delete(Omca.ingestid_field)

              row
            end
          end

          unless Omca::Mappers.authority?(rectype)
            transform Delete::Fields, fields: id_field

            transform Rename::Field,
              from: Omca.ingestid_field,
              to: id_field
          end

          transform Delete::Fields, fields: %i[recordcsid rectype id]

          transform Delete::DelimiterOnlyFieldValues,
            treat_as_null: [Omca.nullvalue]
          transform Delete::DelimiterOnlyFieldValues,
            delim: Omca.sgdelim,
            treat_as_null: [Omca.nullvalue]
          transform Delete::EmptyFields, usenull: true
        end
      end
    end
  end
end

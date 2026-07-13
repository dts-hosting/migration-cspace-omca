# frozen_string_literal: true

module Omca
  module Jobs
    module RefnamesCsidsLookup
      module_function

      def job(source:, dest:, lookup:, rectype:, id_field:, auth_config: nil)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest,
            lookup: lookup
          },
          transformer: xforms(rectype, id_field, auth_config)
        )
      end

      def xforms(rectype, id_field, auth_config)
        Kiba.job_segment do
          keepfields = [:recordcsid, Omca.ingestid_field]
          fieldmap = {
            newrefname: :refname,
            newcsid: :csid
          }

          if Omca::Mappers.authority?(rectype)
            keepflds = keepfields +
              [:authority, Omca::Authorities.used_tag_field, :refname]
            transform Delete::FieldsExcept,
              fields: keepflds

            transform Merge::MultiRowLookup,
              lookup: send(:"refnames_csids_new__#{rectype}"),
              keycolumn: Omca.ingestid_field,
              fieldmap: fieldmap,
              conditions: ->(r, rows) do
                subtype = r[:authority]
                rows.select { |row| row[:subtype] == subtype }
              end

            transform Rename::Field,
              from: :refname,
              to: :oldrefname
          else
            transform Delete::FieldsExcept,
              fields: keepfields
            transform Merge::MultiRowLookup,
              lookup: send(:"refnames_csids_new__#{rectype}"),
              keycolumn: Omca.ingestid_field,
              fieldmap: fieldmap
          end

          transform Rename::Field,
            from: :recordcsid,
            to: :oldcsid
        end
      end
    end
  end
end

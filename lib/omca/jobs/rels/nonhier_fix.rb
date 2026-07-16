# frozen_string_literal: true

module Omca
  module Jobs
    module Rels
      module NonhierFix
        module_function

        def job(source:, dest:, subject:, object:)
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: source,
              destination: dest,
              lookup: get_lookups(subject, object)
            },
            transformer: [
              deduplication(subject, object),
              merges(subject, object)
            ]
          )
        end

        def get_lookups(subject, object)
          base = [get_lookup(subject)]
          return base.compact if subject == object

          base << get_lookup(object)
          base.compact
        end

        def get_lookup(rectype)
          src_job = :"refname_csid_lookup__#{rectype}"
          return unless Kiba::Extend::Job.registered?(src_job)
          return unless Kiba::Extend::Job.output?(src_job)

          {jobkey: src_job, lookup_on: :oldcsid}
        end

        def deduplication(subject, object)
          Kiba.job_segment do
            lookuptypes = [subject, object].uniq
            if lookuptypes.any? do |type|
              !respond_to?(:"refname_csid_lookup__#{type}")
            end
              transform { |row| next }
            elsif lookuptypes.length > 1
              # passthrough for now
            else
              transform do |row|
                row[:idx] = [
                  row[:subjectcsid], row[:objectcsid]
                ].sort
                  .join(" ")

                row
              end

              transform Deduplicate::Table,
                field: :idx,
                delete_field: true
            end
          end
        end

        def merges(subject, object)
          Kiba.job_segment do
            lookuptypes = [subject, object].uniq
            if lookuptypes.all? do |type|
              respond_to?(:"refname_csid_lookup__#{type}")
            end
              subid = Omca::Mappers.id_field_lookup[subject]
              objid = Omca::Mappers.id_field_lookup[object]

              transform Merge::MultiRowLookup,
                lookup: send(:"refname_csid_lookup__#{subject}"),
                keycolumn: :subjectcsid,
                fieldmap: {item1_id: subid}

              transform Merge::MultiRowLookup,
                lookup: send(:"refname_csid_lookup__#{object}"),
                keycolumn: :objectcsid,
                fieldmap: {item2_id: objid}

              transform Merge::ConstantValue,
                target: :item1_type,
                value: Omca::Mappings::Doctype.doctype_for(subject)

              transform Merge::ConstantValue,
                target: :item2_type,
                value: Omca::Mappings::Doctype.doctype_for(object)
            end
          end
        end
      end
    end
  end
end

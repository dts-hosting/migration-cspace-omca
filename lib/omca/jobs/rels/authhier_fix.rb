# frozen_string_literal: true

module Omca
  module Jobs
    module Rels
      module AuthhierFix
        module_function

        def job(source:, dest:, rectype:)
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: source,
              destination: dest,
              lookup: get_lookup(rectype)
            },
            transformer: xforms(rectype)
          )
        end

        def get_lookup(rectype)
          src_job = :"refname_csid_lookup__#{rectype}"
          return unless Kiba::Extend::Job.registered?(src_job)
          return unless Kiba::Extend::Job.output?(src_job)

          {jobkey: src_job, lookup_on: :oldcsid}
        end

        def xforms(rectype)
          Kiba.job_segment do
            transform do |row|
              row[:idx] = [
                row[:narrower], row[:broader]
              ].sort
                .join(" ")

              row
            end

            transform Deduplicate::Table,
              field: :idx,
              delete_field: true

            transform Merge::MultiRowLookup,
              lookup: send(:"refname_csid_lookup__#{rectype}"),
              keycolumn: :narrower,
              fieldmap: {
                narrower_term: :termdisplayname_preferred,
                term_subtype: :authority
              },
              conditions: ->(_r, rows) do
                rows.reject { |r| r[Omca::Authorities.used_tag_field] == "n" }
              end

            transform Merge::MultiRowLookup,
              lookup: send(:"refname_csid_lookup__#{rectype}"),
              keycolumn: :broader,
              fieldmap: {broader_term: :termdisplayname_preferred},
              conditions: ->(x, rows) do
                rows.reject { |r| r[Omca::Authorities.used_tag_field] == "n" }
                  .select { |r| r[:authority] == x[:term_subtype] }
              end

            transform Merge::ConstantValue,
              target: :term_type,
              value: Omca::Mappings::Doctype.term_type_for(rectype)
          end
        end
      end
    end
  end
end

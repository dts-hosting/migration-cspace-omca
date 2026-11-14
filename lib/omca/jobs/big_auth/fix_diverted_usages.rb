# frozen_string_literal: true

module Omca
  module Jobs
    module BigAuth
      module FixDivertedUsages
        module_function

        def desc = "Adjust usage details affected by BigAuth FCAR"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :big_auth__divert_usages,
              destination: :big_auth__fix_diverted_usages,
              lookup: [
                {
                  jobkey: :big_auth__collapsing,
                  lookup_on: :index
                },
                {
                  jobkey: :big_auth__non_collapsing,
                  lookup_on: :index
                }
              ]
            },
            transformer: [Omca::Authorities.add_term_index, xforms]
          )
        end

        def xforms
          Kiba.job_segment do
            [big_auth__collapsing, big_auth__non_collapsing].each do |lkup|
              transform Merge::MultiRowLookup,
                lookup: lkup,
                keycolumn: :index,
                fieldmap: {updatingto: :refname},
                delim: Omca.delim

              transform do |row|
                corr = row.delete(:updatingto)
                next row if corr.blank?

                row[:refname] = corr
                Omca::Refname.add_parsed_detail(row, corr, sym: true)
                row[:index] = [
                  row[:authority], row[:vocab], row[:termid]
                ].join(" ")

                row
              end
            end

            transform Delete::Fields, fields: :index
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Omca
  module Jobs
    module Report
      module MissingBlobcsid
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :remap_main__media_common,
              destination: :report__missing_blobcsid,
              lookup: {
                jobkey: :refname_csid_lookup__media,
                lookup_on: :oldcsid
              }
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform do |row|
              blobcsids = ["e8cd48b2-def5-4297-9e00", "1008e046-ccb2-434b-b845"]
              blobcsid = row[:blobcsid]

              next unless blobcsids.include?(blobcsid)
              row
            end

            transform Rename::Field,
              from: :recordcsid,
              to: :oldcsid
            transform Merge::MultiRowLookup,
              lookup: refname_csid_lookup__media,
              keycolumn: :oldcsid,
              fieldmap: {
                newcsid: :newcsid,
                identificationnumber: :identificationnumber
              }
          end
        end
      end
    end
  end
end

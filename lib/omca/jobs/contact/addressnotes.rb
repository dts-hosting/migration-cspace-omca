# frozen_string_literal: true

module Omca
  module Jobs
    module Contact
      module Addressnotes
        module_function

        def desc = "Extract note fields from addressgroupomca table, "\
          "applying appropriate note prefix depending on whether any actual "\
          "address info is present in the row"

        def job
          str = "#{Omca::Remap.previous}_repeatable_field_group__"\
            "addressgroupomca"
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: str.to_sym,
              destination: :contact__addressnotes,
              lookup: {
                jobkey: :"#{Omca::Remap.previous}_subrecord__contacts_common",
                lookup_on: :recordcsid,
                name: :contacts
              }
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::Remap::BuildAddressNotes
            transform Merge::MultiRowLookup,
              lookup: contacts,
              keycolumn: :recordcsid,
              fieldmap: {termcsid: :termcsid}
          end
        end
      end
    end
  end
end

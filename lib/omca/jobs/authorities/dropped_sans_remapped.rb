# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      class DroppedSansRemapped
        include Omca::DynamicCsvJobable

        def self.desc = "Rows from authorities__drop_usages that are NOT "\
          "for field: collectionobjects_common.assocPlace"

        def source = :authorities__drop_usages

        def destination = :authorities__dropped_sans_remapped

        def job_code
          logic = %('(table ne "assocplacegroup") && ) +
            %((field ne "assocplace")')
          cmd = %(xan filter #{logic} #{source_path} ) +
            %( > #{destination_path})

          `#{cmd}`
        end
      end
    end
  end
end

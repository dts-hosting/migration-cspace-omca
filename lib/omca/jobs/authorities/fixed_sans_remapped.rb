# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      class FixedSansRemapped
        include Omca::DynamicCsvJobable

        def self.desc = "Rows from authorities__fix_usages that are NOT "\
          "for field: collectionobjects_common.assocPlace"

        def source = :authorities__fix_usages

        def destination = :authorities__fixed_sans_remapped

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

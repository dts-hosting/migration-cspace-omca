# frozen_string_literal: true

module Omca
  module Jobs
    module Assocplace
      class Usages
        include Omca::DynamicCsvJobable

        def self.desc = "Rows from authorities__fix_usages "\
          "for field: collectionobjects_common.assocPlace"

        def source = :authorities__fix_usages

        def destination = :assocplace__usages

        def job_code
          logic = %('(table eq "assocplacegroup") && ) +
            %((field eq "assocplace")')
          cmd = %(xan filter #{logic} #{source_path} ) +
            %( > #{destination_path})

          `#{cmd}`
        end
      end
    end
  end
end

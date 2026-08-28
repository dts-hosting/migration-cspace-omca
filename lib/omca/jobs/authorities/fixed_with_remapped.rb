# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      class FixedWithRemapped
        include Omca::DynamicCsvJobable

        def self.desc = "Join sans-remapped usages with remapped usages"

        def source = %i[
          authorities__fixed_sans_remapped
          assocplace__remapped
        ]

        def source_paths = source.map { |s| Omca.registry.resolve(s).path }
          .join(" ")

        def destination = :authorities__fixed_with_remapped

        def job_code
          cmd = %(xan cat rows #{source_paths} ) +
            %( -o #{destination_path})

          `#{cmd}`
        end
      end
    end
  end
end

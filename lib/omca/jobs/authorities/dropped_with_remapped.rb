# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      class DroppedWithRemapped
        include Omca::DynamicCsvJobable

        def self.desc = "Join sans-remapped usages with remapped usages"

        def source = %i[
          authorities__dropped_sans_remapped
          assocplace__remapped
        ]

        def source_paths = source.map { |s| Omca.registry.resolve(s).path }
          .join(" ")

        def destination = :authorities__dropped_with_remapped

        def job_code
          cmd = %(xan cat rows #{source_paths} ) +
            %( -o #{destination_path})

          `#{cmd}`
        end
      end
    end
  end
end

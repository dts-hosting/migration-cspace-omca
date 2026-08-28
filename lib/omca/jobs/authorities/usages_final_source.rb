# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      class UsagesFinalSource
        include Omca::DynamicCsvJobable

        def source = [
          Omca.auth_usages,
          :works__orig_usages
        ]

        def destination = :authorities__usages_final_source

        def job_code
          paths = source.map { |s| Omca.registry.resolve(s).path }
            .join(" ")

          `xan cat rows -o #{destination_path} #{paths}`
        end
      end
    end
  end
end

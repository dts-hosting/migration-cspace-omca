# frozen_string_literal: true

module Omca
  module Jobs
    module NonRefnameAuth
      class UsagesFinal
        include Omca::DynamicCsvJobable

        def source = %i[
          authorities__fix_malformed_usages
          non_refname_auth__usage_merge
        ]

        def destination = :non_refname_auth__usages_final

        def job_code
          paths = source.map { |s| Omca.registry.resolve(s).path }
            .join(" ")

          `xan cat rows -o #{destination_path} #{paths}`
        end
      end
    end
  end
end

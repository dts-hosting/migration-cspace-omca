# frozen_string_literal: true

module Omca
  module Jobs
    module BigAuth
      class Usages
        include Omca::DynamicCsvJobable

        def self.desc = "Combine fixed diverted and undiverted BigAuth usages"

        def source = [
          :big_auth__undiverted_usages,
          :big_auth__fix_diverted_usages
        ]

        def destination = :big_auth__usages

        def job_code
          paths = source.map { |s| Omca.registry.resolve(s).path }
            .join(" ")

          `xan cat rows -o #{destination_path} #{paths}`
        end
      end
    end
  end
end

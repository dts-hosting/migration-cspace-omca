# frozen_string_literal: true

module Omca
  module Jobs
    module BigAuth
      class DivertUsages
        include Omca::DynamicCsvJobable

        def self.desc = "Diverts usages that need to be fixed up with "\
          "big_auth corrections"

        def source = %i[
          unlinked_auth__usages
          big_auth__collapsing
          big_auth__non_collapsing
        ]

        def source_path = Omca.registry
          .resolve(source.first)
          .path

        def destination = :big_auth__divert_usages

        def termids_to_divert
          source[1..].map { |key| extract_termids(key) }
            .flatten
            .join("|")
        end

        def cmd = "xan filter 'contains(termid, "\
          "/^(?:#{termids_to_divert})$/)' #{source_path}"

        def job_code
          xan_result = `#{cmd}`.chomp
          File.open(destination_path, "w") { |f| f << xan_result }
        end

        private

        def extract_termids(key)
          path = Omca.registry.resolve(key).path
          table = CSV.parse(File.read(path), **Kiba::Extend.csvopts)
          table[:termid]
        end
      end
    end
  end
end

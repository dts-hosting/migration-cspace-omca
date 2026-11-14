# frozen_string_literal: true

module Omca
  module Jobs
    module BigAuth
      class UndivertedUsages
        include Omca::DynamicCsvJobable

        def self.desc = ":unlinked_auth__usages rows not diverted for "\
          "big_auth usage adjustment"

        def source = %i[
          unlinked_auth__usages
          big_auth__collapsing
          big_auth__non_collapsing
        ]

        def source_path = Omca.registry
          .resolve(source.first)
          .path

        def destination = :big_auth__undiverted_usages

        def termids_to_divert = Omca::Jobs::BigAuth::DivertUsages.new
          .termids_to_divert

        def cmd = "xan filter 'not(contains(termid, "\
          "/^(?:#{termids_to_divert})$/))' #{source_path}"

        def job_code
          xan_result = `#{cmd}`.chomp
          File.open(destination_path, "w") { |f| f << xan_result }
        end
      end
    end
  end
end

# frozen_string_literal: true

module Omca
  module Jobs
    module Report
      class MergedauthCheck
        include Omca::DynamicCsvJobable

        def self.desc = "Verifies count of usages is same as for "\
          "authorities__usages_final_source; writes out rows not matching "\
          "expected new refname pattern"

        def source = %i[
          authorities__usages_authmerged
          authorities__usages_final_source
        ]

        def destination = :report__mergedauth_check

        def source_path = Omca.registry
          .resolve(source.first)
          .path

        def compare_path = Omca.registry
          .resolve(source.last)
          .path

        def job_code
          rct = result_ct
          cct = compare_ct
          if rct == cct
            puts "Usage count matches :authorities__usages_final_source"
          else
            puts "#{rct} authmerge usages"
            puts "#{cct} source usages"
            puts "#{cct.to_i - rct.to_i} diff"
          end

          cmd = "xan filter 'not(match(val, /^urn:cspace:omca.staging./))' "\
            "#{source_path} > #{destination_path}"
          `#{cmd}`
        end

        private

        def result_ct = `xan count #{source_path}`.chomp

        def compare_ct = `xan count #{compare_path}`.chomp
      end
    end
  end
end

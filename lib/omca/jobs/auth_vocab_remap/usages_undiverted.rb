# frozen_string_literal: true

module Omca
  module Jobs
    module AuthVocabRemap
      class UsagesUndiverted
        include Omca::DynamicCsvJobable

        def self.desc = "Removes usages that need to be remapped to new "\
          "usages, and that will be merged back in by "\
          ":authorities__usages_final_source"

        def phase = Omca::Remap.previous

        def source = :big_auth__collapsing_usage_merge

        def source_path = Omca.registry
          .resolve(source)
          .path

        def destination = :auth_vocab_remap__usages_undiverted

        def job_code
          cmd = %(xan filter '!(table eq "objectexit_common") && ) +
            %(!(field eq "depositor")' #{source_path})

          xan_result = `#{cmd}`.chomp
          File.open(destination_path, "w") { |f| f << xan_result }
        end
      end
    end
  end
end

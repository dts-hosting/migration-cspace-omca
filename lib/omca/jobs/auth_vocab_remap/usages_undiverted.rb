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

        def source = :big_auth__usages

        def source_path = Omca.registry
          .resolve(source)
          .path

        def destination = :auth_vocab_remap__usages_undiverted

        def job_code
          xan_result = `#{cmd}`.chomp
          File.open(destination_path, "w") { |f| f << xan_result }
        end

        private

        def cmd
          diverting = Omca::AuthVocabRemap.fields_to_divert
          [
            init_cmd(diverting[0]),
            diverting[1..].map { |h| xan_filter(h) }
          ].flatten.join(" | ")
        end

        def init_cmd(hash) = "#{xan_filter(hash)} #{source_path}"

        def xan_filter(hash)
          %(xan filter '!(table eq "#{hash[:table]}") && ) +
            %(!(field eq "#{hash[:field]}")')
        end
      end
    end
  end
end

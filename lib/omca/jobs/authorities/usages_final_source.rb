# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      class UsagesFinalSource
        include Omca::DynamicCsvJobable

        def source = [
          :auth_vocab_remap__usages_undiverted,
          :works__orig_usages,
          :orgs__orig_usages_acqfundsource
        ] +
          Omca::AuthVocabRemap.remapped_diverted

        def destination = :authorities__usages_final_source

        def job_code = `#{cmd}`

        private

        def cmd
          "xan cat rows -o #{destination_path} #{paths}"
        end

        def paths
          source.map { |s| Omca.registry.resolve(s).path }
            .join(" ")
        end
      end
    end
  end
end

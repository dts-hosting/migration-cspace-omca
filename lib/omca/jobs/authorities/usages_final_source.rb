# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      class UsagesFinalSource
        include Omca::DynamicCsvJobable

        # rubocop:disable Layout/LineLength
        def source = [
          :auth_vocab_remap__usages_undiverted,
          :works__orig_usages,
          :orgs__orig_usages_acqfundsource,
          :auth_vocab_remap__remap_objectexit_common_depositor_usages,
          :auth_vocab_remap__remap_accessrestrictiongroup_accessrestrictionrequestor_usages,
          :auth_vocab_remap__remap_collectionobjects_omca_copyrightholder_usages,
          :auth_vocab_remap__remap_determinationhistorygroup_dhname_usages,
          :auth_vocab_remap__remap_determinationhistorygroup_identby_usages,
          :auth_vocab_remap__remap_determinationhistorygroup_institution_usages,
          :auth_vocab_remap__remap_materialgroup_material_usages
        ]
        # rubocop:enable Layout/LineLength

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

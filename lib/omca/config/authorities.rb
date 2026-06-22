# frozen_string_literal: true

module Omca
  module Authorities
    module_function

    extend Dry::Configurable

    setting :used_tag_field,
      reader: true,
      default: :term_is_used

    setting :usages_path,
      reader: true,
      default: File.join(Omca.datadir, "authority_ref", "usages.csv")

    setting :usages_headers,
      reader: true,
      default: %w[tabletype table id field authority vocab termid form refname]

    setting :fix_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "fix", "usages_fixed.csv")

    setting :uniq_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "authority_ref", "uniq_usages.csv")

    setting :uniq_usages_headers,
      reader: true,
      default: %w[refname usagect authority vocab termid form]

    setting :fix_uniq_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "fix", "fixed_uniq_usages.csv")

    setting :non_refname_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "authority_ref",
        "usages_non_refname.csv")

    setting :non_refname_usages_headers,
      reader: true,
      default: %w[tabletype table id recordcsid field value]

    setting :uniq_non_refname_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "authority_ref",
        "uniq_usages_non_refname.csv")

    setting :uniq_non_refname_usages_headers,
      reader: true,
      default: non_refname_usages_headers + ["usagect"] - %w[id recordcsid]

    setting :non_refname_lookup_path,
      reader: true,
      default: File.join(Omca.datadir, "authority_ref",
        "non_refname_lookup.csv")

    setting :non_refname_lookup_headers,
      reader: true,
      default: uniq_non_refname_usages_headers + %w[
        matchtype refname
      ]

    setting :non_refname_lookup_config,
      reader: true,
      default: {
        ["collectionobjects_common_contentplaces", "item"] =>
          [["place", "local"]],
        ["collectionobjects_omca",
          "copyrightholder"] => [
            ["person", "local"], ["organization", "local"]
          ],
        ["assocculturalcontextgroup", "assocculturalcontext"] =>
          [["concept", "associated"]],
        ["objectproductionorganizationgroup",
          "objectproductionorganization"] => [["organization", "local"]],
        ["objectproductionpersongroup", "objectproductionperson"] =>
          [["person", "local"]]
      }
  end
end

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
      default: File.join(Omca.datadir, "reference", "usages.csv")

    setting :usages_headers,
      reader: true,
      default: %w[tabletype table id field authority vocab termid form refname]

    setting :uniq_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "reference", "uniq_usages.csv")

    setting :uniq_usages_headers,
      reader: true,
      default: %w[refname usagect authority vocab termid form]

    setting :non_refname_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "reference", "usages_non_refname.csv")

    setting :non_refname_usages_headers,
      reader: true,
      default: %w[tabletype table id recordcsid field value]

    setting :uniq_non_refname_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "reference",
        "uniq_usages_non_refname.csv")

    setting :uniq_non_refname_usages_headers,
      reader: true,
      default: non_refname_usages_headers + ["usagect"] - %w[id recordcsid]

    setting :non_refname_lookup_path,
      reader: true,
      default: File.join(Omca.wrkdir, "non_refname_lookup.csv")

    setting :non_refname_lookup_headers,
      reader: true,
      default: uniq_non_refname_usages_headers + %w[
        matchtype refname
      ]

    setting :add_non_refname_index,
      reader: true,
      default: nil,
      constructor: ->(default) do
        Kiba.job_segment do
          transform CombineValues::FromFieldsWithDelimiter,
            sources: %i[table field value],
            target: :nonrefnameindex,
            delete_sources: false,
            delim: "###"
        end
      end

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

    setting :fix_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "fix", "usages_fixed.csv")

    setting :fix_uniq_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "fix", "fixed_uniq_usages.csv")

    setting :add_term_index,
      reader: true,
      default: nil,
      constructor: ->(default) do
        Kiba.job_segment do
          transform CombineValues::FromFieldsWithDelimiter,
            sources: %i[authority vocab termid],
            target: :index,
            delete_sources: false,
            delim: " "
        end
      end
  end
end

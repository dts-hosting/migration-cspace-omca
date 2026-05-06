# frozen_string_literal: true

module Omca
  module Authorities
    module_function

    extend Dry::Configurable

    setting :usages_path,
      reader: true,
      default: File.join(Omca.datadir, "authority_ref", "usages.csv")

    setting :fix_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "fix", "usages_fixed.csv")

    setting :usages_headers,
      reader: true,
      default: %w[tabletype table id field authority vocab termid form refname]

    setting :uniq_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "authority_ref", "uniq_usages.csv")

    setting :fix_uniq_usages_path,
      reader: true,
      default: File.join(Omca.datadir, "fix", "fixed_uniq_usages.csv")

    setting :uniq_usages_headers,
      reader: true,
      default: %w[refname usagect authority vocab termid form]
  end
end

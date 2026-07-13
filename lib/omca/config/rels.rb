# frozen_string_literal: true

module Omca
  module Rels
    module_function

    extend Dry::Configurable

    setting :types_orig_path,
      reader: true,
      default: File.join(Omca.datadir, "rels", "info", "types_orig.csv")
  end
end

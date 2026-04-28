# frozen_string_literal: true

module Omca
  # Populates file registry provided by Kiba::Extend
  module RegistryData
    module_function

    def register
      register_dir_files(
        dir: File.join(Omca.datadir, "orig"), ns: "orig"
      )

      register_files

      # This needs to be added if you are using the IterativeCleanup mixin
      #  in your project. It causes all the automagically defined cleanup jobs
      #  to be registered.
      Kiba::Extend::Utils::IterativeCleanupJobRegistrar.call

      Omca.registry.finalize
    end

    # Because these are supplied, not derived by the project, they do not need
    #   `creator` attributes defined.
    def register_dir_files(dir:, ns:)
      Omca.registry.namespace(ns) do
        Dir.children(dir).select do |file|
          File.extname(file) == ".csv"
        end.each do |csvfile|
          key = csvfile.delete_suffix(".csv").to_sym

          register key, {
            path: File.join(dir, csvfile),
            supplied: true,
            tags: [key, ns.to_sym]
          }
        end
      end
    end
    private_class_method :register_dir_files

    def register_files
      # placeholder
    end
    private_class_method :register_files
  end
end

# frozen_string_literal: true

module Omca
  # Populates file registry provided by Kiba::Extend
  module RegistryData
    module_function

    def register
      %w[main_rectype repeating addtl_fields field_groups
        field_subgroups].each do |val|
        register_dir_files(
          dir: File.join(Omca.datadir, val), ns: val
        )
      end

      register_obj_and_procedure_preprocess_jobs

      register_files

      # This needs to be added if you are using the IterativeCleanup mixin
      #  in your project. It causes all the automagically defined cleanup jobs
      #  to be registered.
      Kiba::Extend::Utils::IterativeCleanupJobRegistrar.call

      Omca.registry.finalize
    end

    def register_dir_files(dir:, ns:)
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

      Omca.registry.namespace(ns) do
        Dir.children(dir).select do |file|
          File.extname(file) == ".csv"
        end.each do |csvfile|
          key = csvfile.delete_suffix(".csv").to_sym

          register key, {
            path: File.join(dir, csvfile),
            supplied: true,
            tags: [key, ns.to_sym, :orig]
          }
        end
      end
    end
    private_class_method :register_dir_files

    def register_files
      # placeholder
    end
    private_class_method :register_files

    def register_obj_and_procedure_preprocess_jobs
      ns = "preprocess_obj_proc"

      entries = Omca::Mappers.obj_and_procedures.keys
        .map do |rectype|
          table = Omca::Mappings.main_tables_by_rectype[rectype]

          args = {
            source: :"main_rectype__#{table}",
            dest: :"#{ns}__#{rectype}",
            rectype: rectype
          }

          entry = {
            path: File.join(Omca.datadir, "preprocess", "#{rectype}.csv"),
            creator: {
              callee: Omca::Jobs::PreprocessObjProc,
              args: args
            },
            tags: [:preprocess, table.to_sym, rectype.to_sym],
            dest_special_opts: {
              initial_headers: [Omca.ingestid_field]
            }
          }

          [rectype.to_sym, entry]
        end

      Omca.registry.namespace(ns) do
        entries.each { |entry| register entry[0], entry[1] }
      end
    end
    private_class_method :register_obj_and_procedure_preprocess_jobs
  end
end

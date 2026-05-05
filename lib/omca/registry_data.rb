# frozen_string_literal: true

module Omca
  # Populates file registry provided by Kiba::Extend
  module RegistryData
    module_function

    def register
      Dir.children(File.join(Omca.datadir, "orig")).each do |val|
        register_dir_files(
          dir: File.join(Omca.datadir, "orig", val), ns: val
        )
      end

      register_preprocess_main_jobs

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
      Omca.registry.namespace("authorities") do
        ns = "authorities"

        %i[usages uniq_usages].each do |key|
          register key, {
            path: Omca::Authorities.send(:"#{key}_path"),
            supplied: true,
            tags: [key, ns.to_sym],
            desc: "Produce by running `thor at #{key}`"
          }
          }
        end
      end
    end
    private_class_method :register_files

    def register_preprocess_main_jobs
      ns = "preprocess_main"

      entries = (Omca::Mappers.obj_and_procedures.keys +
                 Omca::Mappers.authorities.keys).sort
        .map do |rectype|
          table = Omca::Mappings::Db.main_tables_by_rectype[rectype]

          args = {
            source: :"main_rectype__#{table}",
            dest: :"#{ns}__#{table}",
            rectype: rectype
          }

          entry = {
            path: File.join(Omca.datadir, "preprocess", "#{table}.csv"),
            creator: {
              callee: Omca::Jobs::MainPreprocess,
              args: args
            },
            tags: [:preprocess, ns.to_sym, table.to_sym, rectype.to_sym],
            dest_special_opts: {
              initial_headers: [Omca.ingestid_field]
            }
          }

          [table.to_sym, entry]
        end

      Omca.registry.namespace(ns) do
        entries.each { |entry| register entry[0], entry[1] }
      end
    end
    private_class_method :register_preprocess_main_jobs
  end
end

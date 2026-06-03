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

      %w[authority_ref].each do |dirname|
        register_dir_files(
          dir: File.join(Omca.datadir, dirname), ns: dirname
        )
      end

      register_preprocess_main_jobs

      %w[addtl_fields repeatable_field repeatable_field_group
        repeatable_in_group subgroup].each do |dir|
        register_preprocess_non_main_jobs(dir)
      end

      register_fix_jobs
      register_fcarmerge_jobs
      register_skeleton_jobs
      register_unused_authority_reports

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

        register :fix_usages, {
          path: File.join(Omca.datadir, "fix", "authority_ref", "usages.csv"),
          creator: Omca::Jobs::Authorities::FixUsages,
          tags: [ns.to_sym, :fix]
        }

        register :fix_uniq_usages, {
          path: File.join(Omca.datadir, "fix", "authority_ref",
            "uniq_usages.csv"),
          creator: Omca::Jobs::Authorities::FixUniqUsages,
          tags: [ns.to_sym, :fix]
        }

        register :collapse_to_pref, {
          path: File.join(Omca.datadir, "fix", "authority_ref",
            "collapse_to_pref.csv"),
          creator: Omca::Jobs::Authorities::CollapseToPref,
          tags: [ns.to_sym, :fix]
        }

        register :unlinked_uniq_usages, {
          path: File.join(Omca.datadir, "reports",
            "unlinked_uniq_authority_usages.csv"),
          creator: Omca::Jobs::Authorities::UnlinkedUniqUsages,
          tags: [ns.to_sym, :reports, :unlinked]
        }

        register :unlinked_uniq_usages_explode, {
          path: File.join(Omca.datadir, "working",
            "unlinked_uniq_authority_usages_explode.csv"),
          creator: Omca::Jobs::Authorities::UnlinkedUniqUsagesExplode,
          tags: [ns.to_sym, :unlinked]
        }

        register :unlinked_usages_base, {
          path: File.join(Omca.datadir, "working",
            "unlinked_authority_usages_base.csv"),
          creator: Omca::Jobs::Authorities::UnlinkedUsagesBase,
          tags: [ns.to_sym, :unlinked]
        }

        register :unlinked_usages, {
          path: File.join(Omca.datadir, "reports",
            "unlinked_authority_usages.csv"),
          creator: Omca::Jobs::Authorities::UnlinkedUsages,
          tags: [ns.to_sym, :reports, :unlinked],
          dest_special_opts: {
            initial_headers: %i[rectype table tabletype recordcsid field]
          }
        }

        register :no_form_citations, {
          path: File.join(
            Omca.datadir, "reports", "authorities_no_form_citations.csv"
          ),
          creator: Omca::Jobs::Authorities::NoFormCitations,
          tags: [ns.to_sym, :reports, :citation]
        }
      end

      Omca.registry.namespace("big_auth") do
        register :prep, {
          path: File.join(Omca.wrkdir, "big_auth_prep.csv"),
          creator: Omca::Jobs::BigAuth::Prep,
          tags: %i[big_auth]
        }
      end

      Omca.registry.namespace("map_report") do
        register :arguscount, {
          path: File.join(
            Omca.datadir, "reports", "mapping_reports",
            "arguscount.csv"
          ),
          creator: Omca::Jobs::MapReport::Arguscount,
          tags: [:map_report, :reports]
        }
        register :conditioncheck_condition, {
          path: File.join(
            Omca.datadir, "reports", "mapping_reports",
            "conditioncheck_condition_values.csv"
          ),
          creator: Omca::Jobs::MapReport::ConditioncheckCondition,
          tags: [:map_report, :reports, :conditioncheck],
          dest_special_opts: {
            initial_headers: %i[condition_migrating_j condition_migrating_k
              condition_orig
              needstreatment_orig
              needstreatment_jmapping
              needstreatment_kmapping
              okforexhibitloanaccession_orig
              okforexhibitloanaccession_jmapping
              okforexhibitloanaccession_kmapping]
          }
        }
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
            source: :"main__#{table}",
            dest: :"#{ns}__#{table}",
            rectype: rectype
          }

          entry = {
            path: File.join(Omca.datadir, "preprocess", "main", "#{table}.csv"),
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

    def register_preprocess_non_main_jobs(dir)
      ns = "preprocess_#{dir}"

      origpath = File.join(Omca.datadir, "orig", dir)
      entries = Dir.children(origpath).reject { |f| f.end_with?("#") }
        .map do |tablefilename|
          table = tablefilename.delete_suffix(".csv")
          rectype = Omca::Mappings::Db.rectype_for_table(table)

          args = {
            source: :"#{dir}__#{table}",
            dest: :"#{ns}__#{table}",
            rectype: rectype,
            tabletype: dir
          }

          entry = {
            path: File.join(Omca.datadir, "preprocess", dir, "#{table}.csv"),
            creator: {
              callee: Omca::Jobs::NonMainPreprocess,
              args: args
            },
            tags: [:preprocess, ns.to_sym, table.to_sym, rectype.to_sym]
          }

          [table.to_sym, entry]
        end

      Omca.registry.namespace(ns) do
        entries.each { |entry| register entry[0], entry[1] }
      end
    end
    private_class_method :register_preprocess_non_main_jobs

    def register_fix_jobs
      Dir.children(File.join(Omca.datadir, "preprocess")).each do |dir|
        register_fix_dir_jobs(dir)
      end
    end
    private_class_method :register_fix_jobs

    def register_fix_dir_jobs(dir)
      ns = "fix_#{dir}"

      path = File.join(Omca.datadir, "preprocess", dir)
      entries = Dir.children(path).reject { |f| f.end_with?("#") }
        .map do |tablefilename|
          table = tablefilename.delete_suffix(".csv")
          rectype = Omca::Mappings::Db.rectype_for_table(table)

          args = {
            source: :"preprocess_#{dir}__#{table}",
            dest: :"#{ns}__#{table}",
            table: table,
            rectype: rectype,
            tabletype: dir
          }

          entry = {
            path: File.join(Omca.datadir, "fix", dir, "#{table}.csv"),
            creator: {
              callee: Omca::Jobs::FixTableData,
              args: args
            },
            tags: [:fix, ns.to_sym, table.to_sym, rectype.to_sym]
          }

          [table.to_sym, entry]
      end

      Omca.registry.namespace(ns) do
        entries.each { |entry| register entry[0], entry[1] }
      end
    end
    private_class_method :register_fix_dir_jobs

    def register_fcarmerge_jobs
      Dir.children(File.join(Omca.datadir, "fix"))
        .reject { |dir| dir == "authority_ref" }
        .each do |dir|
          register_fcarmerge_dir_jobs(dir)
      end
    end
    private_class_method :register_fcarmerge_jobs

    def register_fcarmerge_dir_jobs(dir)
      ns = "fcarmerge_#{dir}"

      path = File.join(Omca.datadir, "fix", dir)
      entries = Dir.children(path).reject { |f| f.end_with?("#") }
        .map do |tablefilename|
          table = tablefilename.delete_suffix(".csv")
          rectype = Omca::Mappings::Db.rectype_for_table(table)

          args = {
            source: :"fix_#{dir}__#{table}",
            dest: :"#{ns}__#{table}",
            table: table,
            rectype: rectype,
            tabletype: dir
          }

          entry = {
            path: File.join(Omca.datadir, "fcarmerge", dir, "#{table}.csv"),
            creator: {
              callee: Omca::Jobs::FcarMerge,
              args: args
            },
            tags: [:fcarmerge, ns.to_sym, table.to_sym, rectype.to_sym]
          }

          [table.to_sym, entry]
        end

      Omca.registry.namespace(ns) do
        entries.each { |entry| register entry[0], entry[1] }
      end
    end
    private_class_method :register_fcarmerge_dir_jobs

    def register_skeleton_jobs
      ns = "skeleton"

      entries = Omca::Mappings::Fields.skeleton_rectypes
        .map do |rectype|
          table = Omca::Mappings::Db.main_tables_by_rectype[rectype]
          id_field = Omca::Mappers.id_field_for_table(table)

          args = {
            source: :"fix_main__#{table}",
            dest: :"#{ns}__#{rectype}",
            table: table,
            rectype: rectype,
            id_field: id_field
          }

          entry = {
            path: File.join(Omca.datadir, "skeleton", "#{rectype}.csv"),
            creator: {
              callee: Omca::Jobs::Skeleton,
              args: args
            },
            tags: [ns.to_sym, rectype.to_sym],
            dest_special_opts: {
              initial_headers: [id_field]
            }
          }

          [rectype.to_sym, entry]
        end

      Omca.registry.namespace(ns) do
        entries.each { |entry| register entry[0], entry[1] }
      end
    end
    private_class_method :register_skeleton_jobs

    def register_unused_authority_reports
      ns = "authority_unused"

      entries = Omca::Mappers.authorities
        .keys
        .sort
        .map do |rectype|
          table = Omca::Mappings::Db.main_tables_by_rectype[rectype]

          args = {
            source: :"preprocess_main__#{table}",
            dest: :"#{ns}__#{table}"
          }

          entry = {
            path: File.join(Omca.datadir, "reports", "unused_authority",
              "#{table}.csv"),
            creator: {
              callee: Omca::Jobs::UnusedAuthority,
              args: args
            },
            tags: [:authorities, ns.to_sym, table.to_sym, rectype.to_sym],
            dest_special_opts: {
              initial_headers: %i[preferred_form]
            }
          }

          [table.to_sym, entry]
        end

      Omca.registry.namespace(ns) do
        entries.each { |entry| register entry[0], entry[1] }
      end
    end
    private_class_method :register_unused_authority_reports
  end
end

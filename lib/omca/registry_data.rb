# frozen_string_literal: true

module Omca
  # Populates file registry provided by Kiba::Extend
  module RegistryData
    module_function

    def phase_config
      {
        "orig" => :skip,
        "preprocess" => Omca::Jobs::Preprocess,
        "fix" => Omca::Jobs::FixTableData,
        "fcarmerge" => Omca::Jobs::FcarMerge
      }
    end

    def previous_phase(phase)
      phase_idx = phase_config.keys.find_index(phase)
      return nil if phase_idx == 0

      prev_idx = phase_idx - 1
      phase_config.keys[prev_idx]
    end

    def register
      Dir.children(File.join(Omca.datadir, "orig")).each do |val|
        register_dir_files(
          dir: File.join(Omca.datadir, "orig", val), ns: val
        )
      end

      phase_config.each { |phase, callee| register_phase_jobs(phase, callee) }

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

        register :usages, {
          path: Omca::Authorities.usages_path,
          creator: Omca::Authorities::Usages.method(:new),
          tags: [ns.to_sym],
          desc: -> { Omca::Authorities::Usages.desc }
        }
        register :uniq_usages, {
          path: Omca::Authorities.uniq_usages_path,
          creator: {
            callee: Omca::Jobs::Authorities::UniqUsages,
            args: {
              source: :authorities__usages,
              destination: :authorities__uniq_usages
            }
          },
          tags: [ns.to_sym],
          desc: -> { Omca::Jobs::Authorities::UniqUsages.desc }
        }
        register :add_pref_term_data, {
          path: File.join(Omca.wrkdir, "uniq_usages_add_pref_term_data.csv"),
          creator: Omca::Jobs::Authorities::AddPrefTermData,
          tags: [ns.to_sym],
          desc: "Add :#{Omca.ingestid_field}, :recordcsid, and :refname "\
            "into source data from authority term tables."
        }

        register :fix_usages, {
          path: File.join(Omca.datadir, "authority_ref", "usages_fixed.csv"),
          creator: Omca::Jobs::Authorities::FixUsages,
          tags: [ns.to_sym],
          desc: "- Fix malformed concept refnames\n"\
            "- Drop citation terms whose refnames have no label/form\n"\
            "- Drop field usages tagged in mappings for usage removal"
        }

        register :fix_uniq_usages, {
          path: File.join(Omca.datadir, "authority_ref",
            "uniq_usages_fixed.csv"),
          creator: {
            callee: Omca::Jobs::Authorities::UniqUsages,
            args: {
              source: :authorities__fix_usages,
              destination: :authorities__fix_uniq_usages
            }
          },
          tags: [ns.to_sym],
          desc: "Re-derive unique usages from fixed usages"
        }

        register :no_form_citations, {
          path: File.join(
            Omca.datadir, "reports", "authorities_no_form_citations.csv"
          ),
          creator: Omca::Jobs::Authorities::NoFormCitations,
          tags: [ns.to_sym, :reports, :citation],
          desc: "Citation terms where the refname does not contain a label "\
            "(e.g. used form)"
        }
      end

      Omca.registry.namespace("non_refname_auth") do
        ns = "non_refname_auth"

        register :usages, {
          path: Omca::Authorities.non_refname_usages_path,
          creator: Omca::Authorities::NonRefnameUsages.method(:new),
          tags: [ns.to_sym],
          desc: -> { Omca::Authorities::NonRefnameUsages.desc }
        }
        register :uniq_usages, {
          path: Omca::Authorities.uniq_non_refname_usages_path,
          creator: Omca::Jobs::NonRefnameAuth::UniqUsages,
          tags: [ns.to_sym],
          desc: -> { Omca::Jobs::NonRefnameAuth::UniqUsages.desc }
        }
        register :refname_lookup, {
          path: File.join(Omca.wrkdir, "non_refname_auth_refname_lookup.csv"),
          creator: Omca::Jobs::NonRefnameAuth::RefnameLookup,
          tags: [ns.to_sym],
          desc: -> { Omca::Jobs::NonRefnameAuth::RefnameLookup.desc }
        }
        register :refname_looked_up, {
          path: File.join(Omca.wrkdir,
            "non_refname_auth_refname_looked_up.csv"),
          creator: Omca::Jobs::NonRefnameAuth::RefnameLookedUp,
          tags: [ns.to_sym],
          desc: "Rows from source where lookup was successful"
        }
        register :not_matched, {
          path: File.join(Omca.wrkdir,
            "non_refname_auth_refname_not_matched.csv"),
          creator: Omca::Jobs::NonRefnameAuth::NotMatched,
          tags: [ns.to_sym],
          desc: "Rows from source where lookup was not successful"
        }
        register :not_matched_provided, {
          path: File.join(Omca.wrkdir,
            "non_refname_auth_refname_not_matched_provided.csv"),
          creator: Omca::Jobs::NonRefnameAuth::NotMatchedProvided,
          tags: [ns.to_sym],
          desc: "Rows from source where lookup was not successful, where "\
            "refname provided by FCAR process"
        }
        register :not_matched_client_cleanup, {
          path: File.join(Omca.wrkdir,
            "non_refname_auth_refname_nomatch_client_cleanup.csv"),
          creator: Omca::Jobs::NonRefnameAuth::NotMatchedClientCleanup,
          tags: [ns.to_sym],
          desc: "Rows from source where lookup was not successful, where no"\
            "refname provided by FCAR process and client needs to clean up"
        }
        register :client_cleanup, {
          path: File.join(Omca.datadir, "reports",
            "non_refname_auth_client_cleanup.csv"),
          creator: Omca::Jobs::NonRefnameAuth::ClientCleanup,
          tags: [ns.to_sym],
          desc: "Individual usages corresponding to not matched client "\
            "cleanup usages"
        }
        register :usage_merge, {
          path: File.join(Omca.wrkdir,
            "non_refname_auth_usage_merge.csv"),
          creator: Omca::Jobs::NonRefnameAuth::UsageMerge,
          tags: [ns.to_sym],
          desc: "Individual usages with provided refnames merged in, "\
            "formatted for use as an additional source to create "\
            "non_refname_auth__usages_final"
        }
        register :usages_final, {
          path: File.join(Omca.datadir, "authority_ref",
            "usages_non_refname_merged.csv"),
          creator: Omca::Jobs::NonRefnameAuth::UsagesFinal,
          tags: [ns.to_sym],
          desc: "Adds result of non_refname_auth__usage_merge to "\
            "authorities__usages"
        }
        register :usages_uniq_final, {
          path: File.join(Omca.datadir, "authority_ref",
            "uniq_usages_non_refname_merged.csv"),
          creator: {
            callee: Omca::Jobs::Authorities::UniqUsages,
            args: {
              source: :non_refname_auth__usages_final,
              destination: :non_refname_auth__usages_uniq_final
            }
          },
          tags: [ns.to_sym],
          desc: "Derive unique values with occurrence counts from "\
            "non_refname_auth__usages_final"
        }
      end

      Omca.registry.namespace("unlinked_auth") do
        ns = "unlinked_auth"

        register :uniq_usages, {
          path: File.join(Omca.wrkdir, "unlinked_auth_uniq_usages.csv"),
          creator: Omca::Jobs::UnlinkedAuth::UniqUsages,
          tags: [ns.to_sym],
          desc: "Deletes :authorities__collapse_to_pref rows with a refname "\
            "merged in from authority term table. Adds :index for later merge "\
            "back into usages"
        }
        register :uniq_usages_explode, {
          path: File.join(Omca.wrkdir, "unlinked_auth_uniq_usages_explode.csv"),
          creator: Omca::Jobs::UnlinkedAuth::UniqUsagesExplode,
          tags: [ns.to_sym],
          desc: "Generate one row per termid/form combination (deals with "\
            "values that have multiple term ids/forms concatenated)"
        }
        register :refname_lookup, {
          path: File.join(Omca.wrkdir, "unlinked_auth_refname_lookup.csv"),
          creator: Omca::Jobs::UnlinkedAuth::RefnameLookup,
          tags: [ns.to_sym],
          desc: -> { Omca::Jobs::NonRefnameAuth::RefnameLookup.desc }
        }
        register :refname_looked_up, {
          path: File.join(Omca.wrkdir, "unlinked_auth_refname_looked_up.csv"),
          creator: Omca::Jobs::UnlinkedAuth::RefnameLookedUp,
          tags: [ns.to_sym],
          desc: "Filter :unlinked_auth__refname_lookup to only rows with "\
            "matching refname found"
        }
        register :refname_no_match, {
          path: File.join(Omca.wrkdir, "unlinked_auth_refname_no_match.csv"),
          creator: Omca::Jobs::UnlinkedAuth::RefnameNoMatch,
          tags: [ns.to_sym],
          desc: "Filter :unlinked_auth__refname_lookup to only rows without "\
            "matching refname found"
        }
        register :refname_fcar_provided, {
          path: File.join(Omca.wrkdir,
            "unlinked_auth_refname_fcar_provided.csv"),
          creator: Omca::Jobs::UnlinkedAuth::RefnameFcarProvided,
          tags: [ns.to_sym],
          desc: "Filter :unlinked_auth__final to only rows with "\
            "refname provided"
        }
        register :refname_fcar_fail, {
          path: File.join(Omca.wrkdir,
            "unlinked_auth_refname_fcar_fail.csv"),
          creator: Omca::Jobs::UnlinkedAuth::RefnameFcarFail,
          tags: [ns.to_sym],
          desc: "Filter :unlinked_auth__final to only rows with no"\
            "refname provided"
        }
        register :for_merge, {
          path: File.join(Omca.wrkdir,
            "unlinked_auth_for_merge.csv"),
          creator: Omca::Jobs::UnlinkedAuth::ForMerge,
          tags: [ns.to_sym],
          desc: "Uniq and looked up and FCAR-provided refnames to update in "\
            "usages"
        }
        register :usages, {
          path: File.join(Omca.datadir, "authority_ref",
            "usages_unlinked_auth.csv"),
          creator: Omca::Jobs::UnlinkedAuth::UsageMerge,
          tags: [ns.to_sym],
          desc: "Updates usages_fixed with unlinked auth fixes"
        }
        register :uniq_usages_final, {
          path: File.join(Omca.datadir, "authority_ref",
            "uniq_usages_unlinked_auth.csv"),
          creator: {
            callee: Omca::Jobs::Authorities::UniqUsages,
            args: {
              source: :unlinked_auth__usages,
              destination: :unlinked_auth__uniq_usages_final
            }
          },
          tags: [ns.to_sym],
          desc: "Re-derive unique usages from unlinked auth usages"
        }
        register :client_cleanup, {
          path: File.join(Omca.datadir, "reports",
            "unlinked_auth_client_cleanup.csv"),
          creator: Omca::Jobs::UnlinkedAuth::ClientCleanup,
          tags: [ns.to_sym],
          desc: "Unlinked auth usages that the client needs to clean up "\
            "pre- or post-migration",
          dest_special_opts: {
            initial_headers: %i[recordcsid]
          }
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

    def register_phase_jobs(phase, callee)
      return if callee == :skip

      Dir.children(File.join(Omca.datadir, "orig")).each do |dir|
        register_phase_dir_jobs(phase, callee, dir)
      end
    end
    private_class_method :register_phase_jobs

    def register_phase_dir_jobs(phase, callee, dir)
      ns = "#{phase}_#{dir}"

      orig_dir_path = File.join(Omca.datadir, "orig", dir)
      entries = Dir.children(orig_dir_path).reject { |f| f.end_with?("#") }
        .map do |tablefilename|
          table = tablefilename.delete_suffix(".csv")
          rectype = Omca::Mappings::Db.rectype_for_table(table)
          prev_phase = previous_phase(phase)
          srckey = if prev_phase == "orig"
            :"#{dir}__#{table}"
          else
            :"#{prev_phase}_#{dir}__#{table}"
          end

          args = {
            source: srckey,
            dest: :"#{ns}__#{table}",
            table: table,
            rectype: rectype,
            tabletype: dir
          }

          tags = [phase.to_sym, ns.to_sym, table.to_sym]
          tags << rectype.to_sym if rectype

          entry = {
            path: File.join(Omca.datadir, phase, dir, "#{table}.csv"),
            creator: {
              callee: callee,
              args: args
            },
            tags: tags
          }

          [table.to_sym, entry]
        end
      Omca.registry.namespace(ns) do
        entries.each { |entry| register entry[0], entry[1] }
      end
    end
    private_class_method :register_phase_dir_jobs

    def register_skeleton_jobs
      ns = "skeleton"

      entries = Omca::Mappings::Fields.skeleton_rectypes
        .map do |rectype|
          table = Omca::Mappings::Db.main_tables_by_rectype[rectype]
          id_field = Omca::Mappers.id_field_for_table(table)

          args = {
            source: :"fcarmerge_main__#{table}",
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

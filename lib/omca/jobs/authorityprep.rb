# frozen_string_literal: true

module Omca
  module Jobs
    module Authorityprep
      module_function

      # @param source [Array<Symbol>]
      # @param dest [Symbol]
      # @param table [String]
      # @param tabletype [String]
      # @param rectype [String]
      def job(source:, dest:, table:, tabletype:, rectype:)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest,
            lookup: get_lookups(table, rectype)
          },
          transformer: xforms(table, tabletype, rectype)
        )
      end

      def get_lookups(table, rectype)
        base = []

        if table == "concepts_common"
          base << {
            jobkey: :auth_vocab_remap__ethculture_uniq_usages,
            lookup_on: :termid
          }
        end

        if rectype == "concept" && table != "concepts_common"
          base << {
            jobkey: :authorityprep_main__concepts_common,
            lookup_on: :authority
          }
        end

        base << :big_auth__non_collapsing if Omca::BigAuthFcar.cleanup_done?
        base.select do |key|
          checkkey = key.is_a?(Symbol) ? key : key[:jobkey]
          Kiba::Extend::Job.output?(checkkey)
        end
      end

      def xforms(table, tabletype, rectype)
        Kiba.job_segment do
          next unless Omca::Mappers.authority?(rectype)

          if Omca::BigAuthFcar.cleanup_done? &&
              respond_to?(:big_auth__non_collapsing) &&
              big_auth__non_collapsing.key?(rectype)

            if table == Omca::Mappers.term_table_for(rectype)
              transform Omca::Xforms::BigAuthMergeTerm,
                table: table,
                tabletype: tabletype,
                rectype: rectype,
                mergerows: big_auth__non_collapsing[rectype]
            end

            if tabletype == "main"
              transform Omca::Xforms::BigAuthMergeMain,
                table: table,
                tabletype: tabletype,
                rectype: rectype,
                mergerows: big_auth__non_collapsing[rectype]
            end
          end

          if table == "concepts_common"
            transform Omca::Xforms::RemapEthcultureMain,
              lookup: auth_vocab_remap__ethculture_uniq_usages
          end
          if rectype == "concept" && table != "concepts_common"
            transform Omca::Xforms::RemapEthcultureTerm,
              lookup: authorityprep_main__concepts_common
          end

          if tabletype == "main"
            transform Omca::Xforms::TagUnusedAuthorityTerms,
              rectype: rectype
            transform Omca::Xforms::DisambiguateIngestId,
              authority: true
          else
            transform Omca::Xforms::InheritUnusedAuthorityTags,
              rectype: rectype
          end
        end
      end
    end
  end
end

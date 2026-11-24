# frozen_string_literal: true

module Omca
  module Jobs
    module Build
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
            lookup: get_lookups(table)
          },
          transformer: xforms(tabletype, table)
        )
      end

      def get_lookups(table)
        cfg = Omca::Mappings::Db.build_children_config_for(table)
        return [] if cfg.empty?

        cfg.map do |tbl, type|
          lkupcfg = Omca::Mappings::Db.build_children_config_for(tbl)
          phase = lkupcfg.empty? ? "authmerge" : "build"

          {
            jobkey: :"#{phase}_#{type}__#{tbl}",
            lookup_on: lookup_field(table, tbl),
            name: tbl
          }
        end
      end

      def lookup_field(table, lkuptable)
        type = Omca::Mappings::Db.table_type(table)
        if Omca::Mappings::Db.table_type(lkuptable) == "subrecord"
          :termcsid
        elsif type == "main" || type == "subrecord"
          :recordcsid
        else
          :groupid
        end
      end

      def xforms(tabletype, table)
        bind = binding
        Kiba.job_segment do
          bind.receiver

          cfg = Omca::Mappings::Db.build_children_config_for(table)

          if cfg.empty?
            transform Omca::Xforms::DropAllRows
          else
            cfg.each do |tbl, type|
              lookup = send(:"#{tbl}")

              case type
              when "addtl_fields"
                transform Omca::Xforms::AddAddtlFields, lookup: lookup
              when "extension_field_group"
                transform Omca::Xforms::AddFieldGroup, lookup: lookup
              when "extension_subgroup"
                transform Omca::Xforms::AddSubgroup, lookup: lookup
              when "repeatable_field"
                Omca::Mappings::Db.rectype_for_table(table)
                field = Omca::Mappings::Fields.for_table(tbl, side: :target)
                  .first
                next unless field

                target = field["target_field"].to_sym

                transform Omca::Xforms::MergeRepeatableField,
                  lookup: lookup,
                  target: target
              when "repeatable_field_group"
                transform Omca::Xforms::AddFieldGroup, lookup: lookup
              when "subgroup"
                transform Omca::Xforms::AddSubgroup, lookup: lookup
              when "subrecord"
                transform Omca::Xforms::AddSubrecord, lookup: lookup
              end
            end
          end
        end
      end
    end
  end
end

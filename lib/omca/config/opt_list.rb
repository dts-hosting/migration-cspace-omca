# frozen_string_literal: true

module Omca
  module OptList
    module_function

    extend Dry::Configurable

    # tabletype (source) > table > field Hash of fields that are mapping
    #   to option list-controlled target fields. Used to extract values
    #   for customizing the option lists in hosted UI config
    def source_fields_to_opt_list
      result = {}
      Omca::Mappings::Fields.opt_list_controlled_target_rows.each do |row|
        tt = row["db_table_type"]
        table = row["source_db_table"]
        field = row["db_field"]
        optlist = row["target_field_source"].delete_prefix("option list: ")

        table_info = [tt, table]
        result[table_info] = [] unless result.key?(table_info)

        result[table_info] << [optlist, field]
      end
      result
    end

    # @return [Array<String>] List of source table/fields being mapped into
    #   target fields controlled by option lists, so the values need to
    #   be downcased
    setting :downcase_field_list,
      reader: true,
      default: [
        "acquisitions_common.acquisitionmethod",
        "addressgroupomca.addresstypeomca",
        "collectionobjects_common.recordstatus",
        "concepttermgroup.historicalstatus",
        "concepttermgroup.termtype",
        "conditionchecks_common.conditioncheckreason",
        "conditionchecks_omca_omcaconditioncheckmethods.item",
        "hazardgroup.hazard",
        "intakes_common.entryreason",
        "loctermgroup.termstatus",
        "loctermgroup.termtype",
        "media_common_typelist.item",
        "movements_common.currentlocationfitness",
        "movements_common.reasonformove",
        "orgtermgroup.termtype",
        "persontermgroup.termtype",
        "places_common.placetype",
        "placetermgroup.historicalstatus",
        "placetermgroup.termtype",
        "restrictedmedia_common_typelist.item",
        "taxon_common.taxonrank",
        "taxontermgroup.termtype",
        "titlegroup.titletype",
        "valuationcontrols_common.valuetype"
      ]

    # @return [Hash] Fields that need to be downcased, grouped by table
    #   for easy use in FixTableData transforms
    setting :downcase_field_config,
      reader: true,
      default: {},
      constructor: ->(_default) do
        downcase_field_list.map do |val|
          parts = val.split(".")
          [parts[0], parts[1].to_sym]
        end.group_by { |e| e[0] }
          .transform_values do |v|
            v.flatten.select { |val| val.is_a?(Symbol) }
          end
      end
  end
end

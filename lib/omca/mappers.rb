# frozen_string_literal: true

module Omca
  module Mappers
    module_function

    def mappers
      return @mappers if instance_variable_defined?(:@mappers)

      dir = Omca.mappers_dir
      @mappers = Dir.children(dir)
        .map do |filename|
          path = File.join(dir, filename)
          parsed = JSON.load_file(path, symbolize_names: true)
          rectype = parsed.dig(:config, :recordtype)
          next unless Omca::Mappings::Db.rectypes.include?(rectype)

          [rectype, parsed]
        end.compact.to_h
    end

    def authorities
      return @authorities if instance_variable_defined?(:@authorities)

      @authorities =
        mappers.select { |_k, v| v.dig(:config, :service_type) == "authority" }
    end

    def authority?(str) = authorities.key?(str)

    def relations
      return @relations if instance_variable_defined?(:@relations)

      @relations =
        mappers.select { |_k, v| v.dig(:config, :service_type) == "relation" }
    end

    def relation?(str) = relations.key?(str)

    def obj_or_procedure?(str) = !authority?(str) && !relation?(str)

    def obj_and_procedures
      return @obj_and_procedures if instance_variable_defined?(
        :@obj_and_procedures
      )

      @obj_and_procedures =
        mappers.select { |k, _v| obj_or_procedure?(k) }
    end

    # @param str [String] main table name, like "collectionobjects_common"
    # @return field [Symbol] human readable id field for record type
    def id_field_for_table(str)
      rectype = Omca::Mappings::Db.rectypes_by_main_table[str]
      id_field_lookup[rectype]
    end

    def id_field_lookup
      return @id_field_lookup if instance_variable_defined?(:@id_field_lookup)

      @id_field_lookup = mappers.map do |k, v|
        next if relation?(k)
        next [k, Omca.ingestid_field] if authority?(k)

        [k, v.dig(:config, :identifier_field).downcase.to_sym]
      end.compact.to_h
    end

    # @param rectype [String]
    # @return [String] name of table in which to look up preferred term
    def term_table_for(rectype)
      return unless authority?(rectype)

      mappers[rectype].dig(:config, :search_field)
        .split("/")
        .first
        .downcase
        .delete_suffix("list")
    end

    # @param rectype [String]
    # @return [String] name of table in which to look up inauthority csid
    def auth_table_for(rectype)
      return unless authority?(rectype)

      "#{mappers[rectype].dig(:config, :service_path)}_common"
    end

    # @param rectype [String]
    # @param vocab [String] the authority subtype string (e.g. "local" for
    #   person)
    # @return [String] the db shortidentifier for the authority subtype
    def auth_vocab_shortid(rectype, vocab)
      mapper = mappers[rectype]
      return unless mapper

      subtype = mapper.dig(:config, :authority_subtypes)
        .find { |st| st[:name].downcase == vocab.downcase }
      return unless subtype

      subtype[:subtype]
    end
  end
end

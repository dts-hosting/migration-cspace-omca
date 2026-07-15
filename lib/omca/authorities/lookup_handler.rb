# frozen_string_literal: true

module Omca
  module Authorities
    class LookupHandler
      attr_reader :type, :subtype, :subtypeid

      def initialize(type:, subtype: nil)
        @type = type
        @subtype = subtype
        @subtypeid = set_subtypeid
        @terms = []
        @records = []
      end

      # @param val [String]
      # @param type [:all, :pref, :nonpref]
      # @param caseinsensitive [Boolean]
      def by_termdisplayname(val, type: :all, caseinsensitive: true)
        populate_terms if terms.empty?
        populate_pref_terms if !instance_variable_defined?(:@pref_terms) &&
          type == :pref
        if !instance_variable_defined?(:@nonpref_terms) && type == :nonpref
          populate_nonpref_terms
        end

        sources = []
        sources << pref_terms if type == :pref
        sources << nonpref_terms if type == :nonpref
        # sources << used_terms unless include_unused
        sources = [terms] if sources.empty?

        query = caseinsensitive ? val.downcase : val
        corpus = sources.inject(:intersection)
        match = if caseinsensitive
          corpus.select { |ct| ct[:termdisplayname].downcase == query }
        else
          corpus.select { |ct| ct[:termdisplayname] == query }
        end
        return [] unless match

        merge_refnames(match)
      end

      private

      attr_reader :terms, :records, :pref_terms, :nonpref_terms, :used_terms

      def merge_refnames(matches)
        return [] if matches.empty?

        populate_records if records.empty?
        matches.map { |match| merge_refname(match) }
      end

      def merge_refname(match)
        rec = records.find { |rec| rec[:recordcsid] == match[:recordcsid] }
        match[:refname] = rec[:refname]
        match.to_h
      end

      def set_subtypeid
        return unless subtype

        res = Omca::Mappers.auth_vocab_shortid(type, subtype)
        res || subtype
      end

      def populate_terms
        termtable = Omca::Mappers.term_table_for(type)
        path = File.join(Omca.datadir, "nuke_bom", "repeatable_field_group",
          "#{termtable}.csv")

        data = CSV.parse(
          File.read(path), headers: true, header_converters: :symbol
        )
        @terms = if subtypeid
          data.select { |r| r[:authority] == subtypeid }
        else
          data
        end
      end

      def populate_pref_terms
        @pref_terms = terms.select { |t| t[:pos] == "0" }
      end

      def populate_nonpref_terms
        @nonpref_terms = terms.reject { |t| t[:pos] == "0" }
      end

      def populate_records
        table = Omca::Mappings::Db.main_tables_by_rectype[type]
        jobkey = :"main__#{table}"
        path = Omca.registry.resolve(jobkey).path
        data = CSV.parse(
          File.read(path), headers: true, header_converters: :symbol
        )
        unless subtypeid
          @records = data
          return data
        end

        @records = data.select { |r| r[:authority] == subtypeid }
      end
    end
  end
end

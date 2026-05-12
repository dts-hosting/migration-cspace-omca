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

        all = if caseinsensitive
          terms.select do |t|
            t["termdisplayname"].downcase == val.downcase
          end
        else
          terms.select { |t| t["termdisplayname"] == val }
        end
        return merge_refnames(all) if type == :all

        if type == :pref
          merge_refnames(all.select { |t| t["pos"] == "0" })
        elsif type == :nonpref
          merge_refnames(all.reject { |t| t["pos"] == "0" })
        end
      end

      private

      attr_reader :terms, :records

      def merge_refnames(matches)
        populate_records if records.empty?

        matches.map { |match| merge_refname(match) }
      end

      def merge_refname(match)
        rec = records.find { |rec| rec["csid"] == match["parentcsid"] }
        match["refname"] = rec["refname"]
        match.to_h
      end

      def set_subtypeid
        return unless subtype

        Omca::Mappers.auth_vocab_shortid(type, subtype)
      end

      def populate_terms
        termtable = Omca::Mappers.term_table_for(type)
        # dir = Omca::Mappings::Db.table_type(termtable, :dir)
        path = File.join(Omca.datadir, "orig", "field_groups",
          "#{termtable}.csv")
        data = CSV.parse(File.read(path), headers: true)
        @terms = data unless subtypeid

        @terms = data.select { |r| r["authority"] == subtypeid }
      end

      def populate_records
        table = Omca::Mappings::Db.main_tables_by_rectype[type]
        path = File.join(Omca.datadir, "orig", "main_rectype",
          "#{table}.csv")
        data = CSV.parse(File.read(path), headers: true)
        @records = data unless subtypeid

        @records = data.select { |r| r["authority"] == subtypeid }
      end
    end
  end
end

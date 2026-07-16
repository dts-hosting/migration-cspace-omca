# frozen_string_literal: true

module Omca
  module Rels
    class FixRegistrar
      def self.call = new.call

      def initialize
        @sourcepath = Omca::Rels.types_modified_path
      end

      def call
        data.map { |row| entry_data(row) }
          .reject { |ed| ed[:entry].nil? }
      end

      private

      attr_reader :sourcepath

      def data
        @data ||=
          CSV.parse(File.read(sourcepath), **Kiba::Extend.csvopts)
            .reject { |row| row[:source0].blank? }
      end

      def entry_data(row)
        {
          ns: namespace(row),
          key: key(row),
          entry: entry(row)
        }
      end

      def namespace(row) = "rels_fix_#{row[:reltype]}"

      def key(row)
        :"#{row[:target0]}_#{row[:target1]}"
      end

      def entry(row)
        base = {
          path: File.join(Omca.datadir, "rels", "fix",
            "#{row[:reltype]}_#{key(row)}.csv"),
          tags: [:rels, :rels_fix, :"rels_#{row[:reltype]}",
            row[:source0].to_sym, row[:source1].to_sym,
            row[:target0].to_sym, row[:target1].to_sym].uniq
        }

        case row[:reltype]
        when "nonhier" then nonhier_entry(row, base)
        when "hier" then hier_entry(row, base)
        end
      end

      def nonhier_entry(row, base)
        source = "rels_source_#{row[:reltype]}__"\
          "#{row[:source0]}_#{row[:source1]}"
        base.merge({
          creator: {
            callee: Omca::Jobs::Rels::NonhierFix,
            args: {
              source: source.to_sym,
              dest: :"#{namespace(row)}__#{key(row)}",
              subject: row[:target0],
              object: row[:target1]
            }
          },
          desc: "Deduplicate and apply any fixes to nonhierarchical relations "\
            "between #{row[:target0]} and #{row[:target1]}"
        })
      end

      def hier_entry(row, base)
        return obj_hier_entry(row, base) if row[:source0] == "collectionobject"

        source = "rels_source_#{row[:reltype]}__"\
          "#{row[:source0]}_#{row[:source1]}"
        base.merge({
          creator: {
            callee: Omca::Jobs::Rels::AuthhierFix,
            args: {
              source: source.to_sym,
              dest: :"#{namespace(row)}__#{key(row)}",
              rectype: row[:target0]
            }
          },
          desc: "Fix authority hierarchy relations for #{row[:source0]}"
        })
      end

      def obj_hier_entry(row, base)
        base.merge({
          creator: Omca::Jobs::Rels::ObjhierFix,
          desc: "Fix object hierarchy relations"
        })
      end
    end
  end
end

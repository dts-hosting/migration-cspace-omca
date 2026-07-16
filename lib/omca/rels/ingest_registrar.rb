# frozen_string_literal: true

module Omca
  module Rels
    class IngestRegistrar
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

      def namespace(row) = "rels_ingest_#{row[:reltype]}"

      def key(row)
        :"#{row[:target0]}_#{row[:target1]}"
      end

      def entry(row)
        base = {
          path: File.join(Omca.datadir, "rels", "ingest",
            "#{row[:reltype]}_#{key(row)}.csv"),
          tags: [:rels, :rels_ingest, :"rels_#{row[:reltype]}",
            row[:source0].to_sym, row[:source1].to_sym,
            row[:target0].to_sym, row[:target1].to_sym].uniq
        }

        case row[:reltype]
        when "nonhier" then nonhier_entry(row, base)
        when "hier" then hier_entry(row, base)
        end
      end

      def nonhier_entry(row, base)
        source = :"rels_fix_#{row[:reltype]}__#{row[:target0]}_#{row[:target1]}"

        base.merge({
          creator: {
            callee: Omca::Jobs::Rels::NonhierIngest,
            args: {
              source: source,
              dest: :"#{namespace(row)}__#{key(row)}"
            }
          },
          desc: "Prepare nonhierarchical relations between #{row[:target0]} "\
            "and #{row[:target1]} for ingest by deleting non-ingestable "\
            "fields and any rows lacking one or more ids"
        })
      end

      def hier_entry(row, base)
        return obj_hier_entry(row, base) if row[:target0] == "collectionobject"

        source = :"rels_fix_#{row[:reltype]}__#{row[:target0]}_#{row[:target1]}"
        base.merge({
          creator: {
            callee: Omca::Jobs::Rels::AuthhierIngest,
            args: {
              source: source,
              dest: :"#{namespace(row)}__#{key(row)}"
            }
          },
          desc: "Prepare authority hierarchy relations for #{row[:source0]}"
        })
      end

      def obj_hier_entry(row, base)
        base.merge({
          creator: Omca::Jobs::Rels::ObjhierIngest,
          desc: "Prep object hierarchy relations for ingest"
        })
      end
    end
  end
end

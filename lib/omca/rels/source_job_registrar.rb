# frozen_string_literal: true

module Omca
  module Rels
    class SourceJobRegistrar
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

      def namespace(row) = "rels_source_#{row[:reltype]}"

      def key(row)
        srcs = [row[:source0], row[:source1]].reject(&:blank?)
        :"#{srcs.join("_")}"
      end

      def entry(row)
        base = {
          path: File.join(Omca.datadir, "rels", "source",
            "#{row[:reltype]}_#{key(row)}.csv"),
          tags: [:rels, :rels_source, :"rels_#{row[:reltype]}",
            row[:source0].to_sym, row[:source1].to_sym].uniq
        }

        case row[:reltype]
        when "nonhier" then nonhier_entry(row, base)
        when "hier" then hier_entry(row, base)
        end
      end

      def nonhier_entry(row, base)
        with_desc = base.merge({
          desc: "Source data for nonhierarchical relations between "\
            "#{row[:target0]} and #{row[:target1]}"
        })

        unless row[:source1].blank?
          return base.merge({
            creator: {
              callee: Omca::Rels::NonhierSource.method(:new),
              args: {subject: row[:source0], object: row[:source1],
                     path: base[:path]}
            }
          })
        end

        custom_nonhier_entry(row, with_desc)
      end

      def custom_nonhier_entry(row, base)
        creator = case row[:source0]
        when "collectionobject_consultation"
          Omca::Jobs::Rels::CollectionobjectConsultationSource
        end
        base.merge({creator: creator})
      end

      def hier_entry(row, base)
        return obj_hier_entry(row, base) if row[:source0] == "collectionobject"

        base.merge({
          creator: {
            callee: Omca::Rels::AuthhierSource.method(:new),
            args: {rectype: row[:source0], path: base[:path]}
          },
          desc: "Source authority hierarchy relations for #{row[:source0]}"
        })
      end

      def obj_hier_entry(row, base)
        base.merge({
          creator: {
            callee: Omca::Rels::ObjhierSource.method(:new),
            args: {path: base[:path]}
          },
          desc: "Source object hierarchy relations"
        })
      end
    end
  end
end

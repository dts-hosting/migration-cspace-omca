# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class BuildConsultationNotes
        def initialize(lookup:)
          @refs = lookup.values.flatten
          @rows = []
        end

        def process(row)
          row[:recordcsid] = "#{row[:recordcsid]}_#{row[:pos]}"
          row[:item] = row[:viewercontributionnote]

          %i[pos rectype viewername viewerrole viewercontributiondate
            viewercontributionnote viewercontribution].each do |f|
            row.delete(f)
          end

          row[:pos] = "0"
          rows << row

          nil
        end

        def close
          groups = rows.group_by { |r| r[:id] }
          refs.each { |ref| yield prepped_ref(ref, groups) }
          rows.reject { |r| r[:item].blank? }
            .each { |r| yield r }
        end

        private

        attr_reader :refs, :rows

        def prepped_ref(ref, groups)
          return if ref[:item].blank?

          group = groups[ref[:groupid]]&.first
          return unless group

          ref[:recordcsid] = group[:recordcsid]
          ref[:id] = group[:id]
          ref[:pos] = (ref[:pos].to_i + 100).to_s
          ref[:item] = "Reference: #{ref[:item]}"
          %i[recordid groupid grouptable].each { |f| ref.delete(f) }

          ref
        end
      end
    end
  end
end

# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class MergeVenueInfo
        NOTE_PREFIX = "Exhibition details:"

        def initialize(lookup:)
          @lookup = lookup
        end

        def process(row)
          csid = row[:recordcsid]
          return row unless lookup.key?(csid)

          notes = lookup[csid].map { |nr| to_note(nr) }
            .join("\n")

          existing = row[:loanoutnote]
          row[:loanoutnote] = [existing, notes].join(Omca.notedelim)

          row
        end

        private

        attr_reader :lookup

        def to_note(nr)
          [NOTE_PREFIX, note_text(nr)].join(" ")
        end

        def note_text(nr)
          [title_venue(nr), daterange(nr)].compact
            .join(", ")
        end

        def title_venue(nr)
          vals = [
            nr[:exhibitiontitle],
            nr[:loanoutvenue]
          ]
          return if vals.all?(&:blank?)

          vals.reject(&:blank?).join(", ")
        end

        def daterange(nr)
          vals = [
            nr[:loanoutvenueopeningdate],
            nr[:loanoutvenueclosingdate]
          ]
          return if vals.all?(&:blank?)

          vals.join(" - ")
        end
      end
    end
  end
end

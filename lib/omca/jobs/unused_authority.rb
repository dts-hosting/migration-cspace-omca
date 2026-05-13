# frozen_string_literal: true

module Omca
  module Jobs
    module UnusedAuthority
      module_function

      # @param source [Array<Symbol>]
      # @param dest [Symbol]
      def job(source:, dest:)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest
          },
          transformer: xforms
        )
      end

      def xforms
        Kiba.job_segment do
          transform FilterRows::FieldEqualTo,
            action: :keep,
            field: Omca::Authorities.used_tag_field,
            value: "n"
          transform Delete::Fields,
            fields: Omca::Authorities.used_tag_field
          transform Clean::RegexpFindReplaceFieldVals,
            fields: Omca.ingestid_field,
            find: / \(UNUSED TERM\).*/,
            replace: ""
          transform Rename::Field,
            from: Omca.ingestid_field,
            to: :preferred_form
        end
      end
    end
  end
end

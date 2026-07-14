# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module NewRefnameLookup
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: sources,
              destination: :authorities__new_refname_lookup
            },
            transformer: xforms
          )
        end

        def sources
          Omca::Mappings::Fields.skeleton_rectypes
            .select { |rectype| Omca::Mappers.authority?(rectype) }
            .map { |rectype| :"refname_csid_lookup__#{rectype}" }
            .select { |job| Kiba::Extend::Job.output?(job) }
        end

        def xforms
          Kiba.job_segment do
            transform Delete::FieldsExcept,
              fields: %i[oldrefname newrefname]
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :newrefname
          end
        end
      end
    end
  end
end

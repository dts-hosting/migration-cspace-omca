# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module Fix
        module_function

        # @param source [Symbol]
        # @param dest [Symbol]
        def job(source:, dest:)
          ensure_source(source)

          Kiba::Extend::Jobs::Job.new(
            files: {
              source: source,
              destination: dest
            },
            transformer: xforms
          )
        end

        def ensure_source(source)
          path = Omca.registry.resolve(source).path
          return if File.exist?(path)

          keyparts = source.to_s.split("__")
          mod = Omca.const_get(camelize(keyparts.first))
          klass = mod.const_get(camelize(keyparts.last))
          klass.call
        end

        def camelize(str) = str.split("_").map(&:capitalize).join

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::MalformedConceptRefnames

            transform FilterRows::WithLambda,
              action: :reject,
              lambda: ->(row) do
                row[:vocab] == "citation" &&
                  row[:form].blank?
              end
          end
        end
      end
    end
  end
end

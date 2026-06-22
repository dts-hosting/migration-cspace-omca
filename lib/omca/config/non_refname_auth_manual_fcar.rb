# frozen_string_literal: true

module Omca
  module NonRefnameAuthManualFcar
    module_function

    extend Dry::Configurable

    def base_job = :non_refname_auth__not_matched

    def fingerprint_fields = %i[nonrefnameindex table field refname]

    extend Kiba::Extend::Mixins::IterativeCleanup

    def orig_values_identifier = :nonrefnameindex

    def job_tags = %i[non_refname_auth]

    def cleanup_base_name = "non_refname_auth"

    def final_lookup_on_field = :nonrefnameindex

    def final_post_xforms = Omca::Authorities.add_non_refname_index
  end
end

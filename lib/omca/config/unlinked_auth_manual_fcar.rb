# frozen_string_literal: true

module Omca
  module UnlinkedAuthManualFcar
    module_function

    extend Dry::Configurable

    def base_job = :unlinked_auth__refname_no_match

    def fingerprint_fields = %i[index form preftermrecordcsid refname]

    extend Kiba::Extend::Mixins::IterativeCleanup

    def orig_values_identifier = :prepfingerprint

    def job_tags = %i[unlinked_auth fcar]

    def cleanup_base_name = "unlinked_auth"

    def final_lookup_on_field = :index
  end
end

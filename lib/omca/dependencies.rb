# frozen_string_literal: true

module Omca
  module Dependencies
    module_function

    def jobkey_for(stage, table)
      tabletype = Omca::Mappings::Db.table_type(table, mode: :dir)
      :"#{stage}_#{tabletype}__#{table}"
    end

    def ensure_fix(table)
      Omca::Mappings::Db.table_type(table, mode: :dir)
      jobkey = jobkey_for(:fix, table)
      return if Kiba::Extend::Job.registered?(jobkey)

      ensure_preprocess(table)
      run_and_register(jobkey)
    end

    def ensure_preprocess(table)
      Omca::Mappings::Db.table_type(table, mode: :dir)
      jobkey = jobkey_for(:preprocess, table)
      return if Kiba::Extend::Job.output?(jobkey)

      run_and_register(jobkey)
    end

    def run_and_register(jobkey)
      Kiba::Extend::Command::Run.job(jobkey)
      Omca.reset_registry
      nil
    end
  end
end

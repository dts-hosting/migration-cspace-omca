# frozen_string_literal: true

module Omca
  module Dependencies
    module_function

    def jobkey_for(stage, table)
      tabletype = Omca::Mappings::Db.table_type(table, mode: :dir)
      :"#{stage}_#{tabletype}__#{table}"
    end

    def ensure_preprocess(table)
      Omca::Mappings::Db.table_type(table, mode: :dir)
      jobkey = jobkey_for(:preprocess, table)
      return if Kiba::Extend::Job.output?(jobkey)

      Kiba::Extend::Command::Run.job(jobkey)
      nil
    end

    def ensure_fix(table)
      Omca::Mappings::Db.table_type(table, mode: :dir)
      jobkey = jobkey_for(:fix, table)
      return if Kiba::Extend::Job.registered?(jobkey) &&
        Kiba::Extend::Job.output?(jobkey)

      ensure_preprocess(table) unless Kiba::Extend::Job.registered?(jobkey)
      Omca.reset_registry
      Kiba::Extend::Command::Run.job(jobkey)
      nil
    end

    def ensure_fcarmerge(table)
      Omca::Mappings::Db.table_type(table, mode: :dir)
      jobkey = jobkey_for(:fcarmerge, table)
      return if Kiba::Extend::Job.registered?(jobkey) &&
        Kiba::Extend::Job.output?(jobkey)

      ensure_fix(table) unless Kiba::Extend::Job.registered?(jobkey)
      Omca.reset_registry
      Kiba::Extend::Command::Run.job(jobkey)
      nil
    end
  end
end

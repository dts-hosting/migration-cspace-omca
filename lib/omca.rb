# frozen_string_literal: true

require "kiba/extend"

# Namespace for the overall project
module Omca
  module_function

  # @return Zeitwerk::Loader
  # Zeitwerk obviates the need to manually require project files repeatedly
  #   within the project
  def loader
    @loader ||= setup_loader
  end

  # Creates Zeitwerk::Loader, making it reloadable
  private def setup_loader
    @loader = Zeitwerk::Loader.for_gem
    @loader.enable_reloading
    @loader.setup
    @loader.eager_load
    @loader
  end

  # Will reload project code. Useful when working in console
  def reload!
    @loader.reload
  end

  extend Dry::Configurable

  setting :datadir,
    reader: true,
    default: File.expand_path(
      File.join("~", "data", "omca", "mig")
    )

  # If I want to be lazy I can define this to avoid typing out full directory
  #   paths. It also makes a nice example for using a constructor:
  setting :derived_dirs,
    default: %w[working],
    reader: true,
    constructor: proc { |value| value.map { |dir| File.join(datadir, dir) } }
  setting :backup_dir,
    default: "backup",
    reader: true,
    constructor: proc { |value| File.join(datadir, value) }
  Kiba::Extend.config.pre_job_task_run = true
  Kiba::Extend.config.pre_job_task_directories = derived_dirs
  Kiba::Extend.config.pre_job_task_backup_dir = backup_dir
  Kiba::Extend.config.pre_job_task_action = :nuke
  Kiba::Extend.config.pre_job_task_mode = :job

  # ### Re-namespacing Kiba:Extend settings
  setting :registry, default: Kiba::Extend.registry, reader: true
  setting :delim, default: Kiba::Extend.delim, reader: true
end

Omca.loader

# The following line is necessary if you wish to use
# `Kiba::Extend::Mixins::IterativeCleanup` in your project.
Kiba::Extend.config.config_namespaces = [Omca]

Omca::RegistryData.register

# Omca::PlacesCleanup.config.provided_worksheets = [
#   "places_cleanup_worksheet_1.csv"
# ]
# Omca::PlacesCleanup.config.returned_files = [
#   "places_cleanup_worksheet_done_1.csv"
# ]

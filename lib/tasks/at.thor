# frozen_string_literal: true

# Tasks related to authority terms
class At < Thor
  desc "usages", Omca::Authorities::Usages.desc
  def usages
    Omca::Authorities::Usages.run
  end
end

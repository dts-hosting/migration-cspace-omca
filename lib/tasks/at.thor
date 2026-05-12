# frozen_string_literal: true

# Tasks related to authority terms
class At < Thor
  desc "usages", Omca::Authorities::Usages.desc
  def usages
    Omca::Authorities::Usages.call
  end

  desc "uniq_usages", Omca::Authorities::UniqUsages.desc
  def uniq_usages
    Omca::Authorities::UniqUsages.call
  end

  desc "non_refnames", Omca::Authorities::NonRefnameUsages.desc
  def non_refnames
    Omca::Authorities::NonRefnameUsages.call
  end
end

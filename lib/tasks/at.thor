# frozen_string_literal: true

# Tasks related to authority terms
class At < Thor
  desc "usages", Omca::Authorities::Usages.desc
  def usages
  end

  desc "uniq_usages", Omca::Authorities::UniqUsages.desc
  def uniq_usages
    Omca::Authorities::UniqUsages.call
    Omca::Authorities::Usages.run
  end

  desc "non_refnames", Omca::Authorities::NonRefnameUsages.desc
  def non_refnames
    Omca::Authorities::NonRefnameUsages.call
  end

  desc "uniq_non_refnames", Omca::Authorities::UniqNonRefnameUsages.desc
  def uniq_non_refnames
    Omca::Authorities::UniqNonRefnameUsages.call
  end

  desc "non_refname_lookup", Omca::Authorities::NonRefnameLookup.desc
  def non_refname_lookup
    Omca::Authorities::NonRefnameLookup.call
  end
end

# frozen_string_literal: true

# Tasks related to authority terms
class At < Thor
  desc "usages", Omca::Authorities::Usages.desc
  def usages
    Omca::Authorities::Usages.run
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

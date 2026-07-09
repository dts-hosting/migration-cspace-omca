# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Jobs::FixTableData do
  describe ":fix_main__organizations_common" do
    let(:jobkey) { :fix_main__organizations_common }
    before { clear_output(jobkey) }
    let(:data) { csv_job_output(jobkey) }

    it "deurns uncontrol field" do
      chk = data[:foundingplace].reject(&:blank?)
        .select { |val| val.start_with?("urn:") }
      expect(chk).to be_empty
    end
  end
end

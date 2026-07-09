# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Jobs::Preprocess do
  describe ":preprocess_main__intakes_common" do
    let(:data) { csv_job_output(:preprocess_main__intakes_common) }

    it "deletes empty fields" do
      expect(data.headers).not_to include(:locationdate)
    end
  end

  describe ":preprocess_main__collectionobjects_common" do
    let(:data) { csv_job_output(:preprocess_main__collectionobjects_common) }

    it "disambiguates duplicate ids" do
      rows = data.select { |row| row[:objectnumber] == "H72.71.30" }
      expect(rows.length).to eq(2)
      expect(rows.first[Omca.ingestid_field]).to eq("H72.71.30 (duplicate 1)")
      expect(rows.last[Omca.ingestid_field]).to eq("H72.71.30 (duplicate 2)")
    end
  end

  describe ":preprocess_main__organizations_common" do
    let(:data) { csv_job_output(:preprocess_main__organizations_common) }

    it "populates ingestid with preferred form" do
      row = data.find do |row|
        row[:recordcsid] == "994997e2-74a0-4ee1-9bab-ac35e8af66c9"
      end
      expect(row[Omca.ingestid_field]).to eq("Lenox China")
    end
  end

  describe ":preprocess_repeatable_field_group__orgtermgroup" do
    let(:jobkey) { :preprocess_repeatable_field_group__orgtermgroup }
    before { clear_output(jobkey) }
    let(:data) { csv_job_output(jobkey) }

    it "populates ingestid with preferred form" do
      row = data.find do |row|
        row[:recordcsid] == "994997e2-74a0-4ee1-9bab-ac35e8af66c9"
      end
      expect(row[:shortidentifier]).to eq("orgpa40766")
    end
  end
end

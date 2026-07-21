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

  describe ":fix_repeatable_field__"\
    "collectionobjects_common_responsibledepartments" do
      let(:jobkey) do
        :fix_repeatable_field__collectionobjects_common_responsibledepartments
      end
      before { clear_output(jobkey) }
      let(:data) { csv_job_output(jobkey) }

      it "deletes non-Art, History, Science values" do
        row1 = data.find do |row|
          row[:recordcsid] == "5d2f2adf-a8fd-4cfb-9fd7"
        end
        expect(row1).to be_nil
        row2 = data.find do |row|
          row[:recordcsid] == "97daa5b0-f244-4b8d-9e91-815dfb347691"
        end
        expect(row2).to be_nil
        row3 = data.find do |row|
          row[:recordcsid] == "635cd44c-c7d0-4987-b218-d165f93b5a69"
        end
        expect(row3[:item]).to eq("History")
      end

      it "deletes ` Department`" do
        row3 = data.find do |row|
          row[:recordcsid] == "8f79a521-f55f-4614-8312-0fbe53aabfe0"
        end
        expect(row3[:item]).to eq("Art")
      end
    end
end

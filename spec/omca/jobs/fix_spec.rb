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

  describe ":fix_addtl_fields__collectionobjects_omca" do
    let(:jobkey) do
      :fix_addtl_fields__collectionobjects_omca
    end
    before(:context) do
      jobkey = :fix_addtl_fields__collectionobjects_omca
      clear_output(jobkey)
      csv_job_output(jobkey)
    end
    let(:path) { Omca.registry.resolve(jobkey).path }

    it "deletes `f` values in art, history, science fields" do
      val1 = xan_seach_csid_return_field(
        "83db0761-12b0-49b0-900b-a2af91a4e336", "art", path
      )
      expect(val1).to eq('""')

      val2 = xan_seach_csid_return_field(
        "ce547ecb-231e-408f-9648-1994a7defd16", "history", path
      )
      expect(val2).to eq('""')

      val3 = xan_seach_csid_return_field(
        "2522146f-56f0-43e0-9470-9c2d166758d6", "science", path
      )
      expect(val3).to eq('""')
    end

    it "replaces `t` values in art, history, science fields" do
      val1 = xan_seach_csid_return_field(
        "aa1642d5-3de7-4188-aa51-91b5e865284a", "art", path
      )
      expect(val1).to eq("Art")

      val2 = xan_seach_csid_return_field(
        "7d7c0b51-69da-4058-a885-4e68ad0882bc", "history", path
      )
      expect(val2).to eq("History")

      val3 = xan_seach_csid_return_field(
        "11877f8c-3f95-4ba6-9da2-4d047af9fb3f", "science", path
      )
      expect(val3).to eq("Science")
    end
  end

  describe ":fix_main__places_common" do
    let(:jobkey) { :fix_main__places_common }
    before(:context) do
      jobkey = :fix_main__places_common
      clear_output(jobkey)
      csv_job_output(jobkey)
    end
    let(:path) { Omca.registry.resolve(jobkey).path }

    it "downcases placetype values" do
      val1 = xan_seach_csid_return_field(
        "b50aaacf-dfc9-47ab-bb7e-95e5f96d0399", "placetype", path
      )
      expect(val1).to eq("water body")
    end
  end

  describe ":fix_main__conditionchecks_common" do
    let(:jobkey) { :fix_main__conditionchecks_common }
    before(:context) do
      jobkey = :fix_main__conditionchecks_common
      clear_output(jobkey)
      csv_job_output(jobkey)
    end
    let(:path) { Omca.registry.resolve(jobkey).path }

    it "fixes `refName` in :conditioncheckreason" do
      val1 = xan_seach_csid_return_field(
        "9627099e-d862-40e7-b9f5-176cebd56a23", "conditioncheckreason", path
      )
      expect(val1).to eq("appraisal")
    end
  end

  describe ":fix_repeatable_field__"\
    "conditionchecks_omca_omcaconditioncheckmethods" do
    let(:jobkey) do
      :fix_repeatable_field__conditionchecks_omca_omcaconditioncheckmethods
    end
    before(:context) do
      jobkey =
        :fix_repeatable_field__conditionchecks_omca_omcaconditioncheckmethods
      clear_output(jobkey)
      csv_job_output(jobkey)
    end
    let(:path) { Omca.registry.resolve(jobkey).path }

    it "recapitalizes LED" do
      val1 = xan_seach_csid_return_field(
        "a659dc12-4782-4c27-8f97", "item", path
      ).split("\n")[1]
      expect(val1).to eq("handheld LED illumination")
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Jobs::Authorityprep do
  describe ":authorityprep_main__places_common" do
    let(:data) { csv_job_output(:authorityprep_main__places_common) }

    it "fixes noncollapsing BigAuth ingestid" do
      row = data.find do |row|
        row[:shortidentifier] == "pl97080"
      end
      expect(row[Omca.ingestid_field]).to eq("Oakland, California")
    end

    it "tags unused terms" do
      val = data[Omca::Authorities.used_tag_field].uniq.sort
      expect(val).to eq(%w[n y])
    end
  end

  describe ":authorityprep_main__taxon_common" do
    let(:data) { csv_job_output(:authorityprep_main__taxon_common) }

    it "does not tag any terms as unused" do
      val = data[Omca::Authorities.used_tag_field].uniq
      expect(val).to eq(["y"])
    end
  end

  describe ":authorityprep_repeatable_field_group__placetermgroup" do
    let(:jobkey) { :authorityprep_repeatable_field_group__placetermgroup }

    before do
      clear_output(:authorityprep_main__places_common)
      clear_output(jobkey)
    end

    let(:data) do
      csv_job_output(jobkey)
    end

    it "swaps forms when pref exists as variant" do
      rows = data.select do |row|
        row[:shortidentifier] == "pl96779"
      end

      merged = rows.find do |row|
        row[:termdisplayname] == "San Francisco, California"
      end
      expect(merged[:pos]).to eq("0")
      expect(merged[:termstatus]).to eq("accepted")
      expect(merged[:termprefforlang]).to eq("t")
      expect(merged[:termtype]).to eq("Descriptor")

      demoted = rows.find do |row|
        row[:termdisplayname] == "San Francisco"
      end
      expect(demoted[:pos]).to eq("2")
      expect(demoted[:termtype]).to eq("Alternate descriptor")
      expect(demoted[:termprefforlang]).to eq("f")
    end

    it "inherits unused tag from main term record" do
      rows = data.select do |row|
        row[:recordcsid] == "7e4e7696-23af-47fa-a0ef-bea863033815"
      end
      val = rows.map { |row| row[Omca::Authorities.used_tag_field] }
      expect(val.uniq).to eq(["n"])
    end
  end

  describe ":authorityprep_repeatable_field_group__persontermgroup" do
    let(:data) do
      csv_job_output(
        :authorityprep_repeatable_field_group__persontermgroup
      )
    end

    it "adds preferred forms when not present as variant" do
      rows = data.select do |row|
        row[:shortidentifier] == "staff1646"
      end

      merged = rows.find do |row|
        row[:termdisplayname] == "Joy A. Tahan"
      end
      expect(merged[:pos]).to eq("0")
      expect(merged[:termstatus]).to eq("accepted")
      expect(merged[:termprefforlang]).to eq("t")
      expect(merged[:termtype]).to eq("Descriptor")

      demoted = rows.find do |row|
        row[:termdisplayname] == "Tahan, Joy A."
      end
      expect(demoted[:pos]).to eq("1")
      expect(demoted[:termtype]).to eq("Alternate descriptor")
      expect(demoted[:termprefforlang]).to eq("f")
    end
  end
end

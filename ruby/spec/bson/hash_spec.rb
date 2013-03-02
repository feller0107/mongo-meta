# encoding: utf-8
require "spec_helper"

describe BSON::Hash do

  describe "::BSON_TYPE" do

    it "returns 0x03" do
      expect(Hash::BSON_TYPE).to eq(3.chr)
    end
  end

  describe "#bson_type" do

    let(:hash) do
      { "field" => "value" }
    end

    it "returns the BSON_TYPE" do
      expect(hash.bson_type).to eq(Hash::BSON_TYPE)
    end
  end

  describe "#to_bson" do

    let(:document) do
      { "key" => "value" }
    end

    let(:encoded) do
      document.to_bson
    end

    it "serializes the document" do
      expect(encoded).to eq(
        "#{20.to_bson}#{String::BSON_TYPE}key#{BSON::NULL_BYTE}" +
        "#{6.to_bson}value#{BSON::NULL_BYTE}#{BSON::NULL_BYTE}"
      )
    end
  end

  context "when the class is loaded" do

    let(:registered) do
      BSON::Registry.get(Hash::BSON_TYPE)
    end

    it "registers the type" do
      expect(registered).to eq(Hash)
    end
  end
end

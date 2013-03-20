# encoding: utf-8
require "spec_helper"

# Note that hash specific specs are based off the rubyspec library, and
# converted manually to RSpec syntax.
#
# @see https://github.com/rubyspec/rubyspec/tree/master/core/hash
describe BSON::Document do

  pending "#=="
  pending "#[]"
  pending "#[]"
  pending "#[]="

  describe "#allocate" do

    let(:doc) do
      described_class.allocate
    end

    it "returns an instance of a Document" do
      expect(doc).to be_a(described_class)
    end

    it "returns a fully-formed instance of a Document" do
      expect(doc.size).to eq(0)
    end
  end

  describe "#assoc" do

    let(:doc) do
      { :apple => :green, :orange => :orange, :grape => :green, :banana => :yellow }
    end

    it "returns an Array if the argument is == to a key of the Hash" do
      expect(doc.assoc(:apple)).to be_a(Array)
    end

    it "returns a 2-element Array if the argument is == to a key of the Hash" do
      expect(doc.assoc(:grape).size).to eq(2)
    end

    it "sets the first element of the Array to the located key" do
      expect(doc.assoc(:banana).first).to eq(:banana)
    end

    it "sets the last element of the Array to the value of the located key" do
      expect(doc.assoc(:banana).last).to eq(:yellow)
    end

    it "uses #== to compare the argument to the keys" do
      doc[1.0] = :value
      expect(doc.assoc(1)).to eq([ 1.0, :value ])
    end

    it "returns nil if the argument is not a key of the Hash" do
      expect(doc.assoc(:green)).to be_nil
    end

    context "when the document compares by identity" do

      before do
        doc.compare_by_identity
        doc["pear"] = :red
        doc["pear"] = :green
      end

      it "duplicates keys" do
        expect(doc.keys.grep(/pear/).size).to eq(2)
      end

      it "only returns the first matching key-value pair" do
        expect(doc.assoc("pear")).to eq([ "pear", :red ])
      end
    end

    context "when there is a default value" do

      context "when specified in the constructor" do

        let(:doc) do
          described_class.new(42).merge!(:foo => :bar)
        end

        context "when the argument is not a key" do

          it "returns nil" do
            expect(doc.assoc(42)).to be_nil
          end
        end
      end

      context "when specified by a block" do

        let(:doc) do
          described_class.new{|h, k| h[k] = 42}.merge!(:foo => :bar)
        end

        context "when the argument is not a key" do

          it "returns nil" do
            expect(doc.assoc(42)).to be_nil
          end
        end
      end
    end
  end

  describe "#clear" do

    let(:doc) do
      described_class[1 => 2, 3 => 4]
    end

    it "removes all key, value pairs" do
      expect(doc.clear).to be_empty
    end

    it "returns the same instance" do
      expect(doc.clear).to eql(doc)
    end

    context "when the document has a default" do

      context "when the default is a value" do

        let(:doc) do
          described_class.new(5)
        end

        before do
          doc.clear
        end

        it "keeps the default value" do
          expect(doc.default).to eq(5)
        end

        it "returns the default for empty keys" do
          expect(doc["z"]).to eq(5)
        end
      end

      context "when the default is a proc" do

        let(:doc) do
          described_class.new { 5 }
        end

        before do
          doc.clear
        end

        it "keeps the default proc" do
          expect(doc.default_proc).to_not be_nil
        end

        it "returns the default for empty keys" do
          expect(doc["z"]).to eq(5)
        end
      end
    end

    context "when the document is frozen" do

      before do
        doc.freeze
      end

      it "raises an error" do
        expect {
          doc.clear
        }.to raise_error(RuntimeError)
      end
    end
  end

  describe "#compare_by_identity" do

    let(:doc) do
      described_class.new
    end

    let!(:identity) do
      doc.compare_by_identity
    end

    it "causes future comparisons on the receiver to be made by identity" do
      doc["a"] = :a
      expect(doc["a"]).to be_nil
    end

    it "causes #compare_by_identity? to return true" do
      expect(doc).to be_compare_by_identity
    end

    it "returns self" do
      expect(identity).to eql(doc)
    end

    it "uses the semantics of BasicObject#equal? to determine key identity" do
      doc[-0.0] = :a
      doc[-0.0] = :b
      doc[[ 1 ]] = :c
      doc[[ 1 ]] = :d
      doc[:bar] = :e
      doc[:bar] = :f
      doc["bar"] = :g
      doc["bar"] = :h
      expect(doc.values).to eq([ :a, :b, :c, :d, :f, :g, :h ])
    end

    it "uses #equal? semantics, but doesn't actually call #equal? to determine identity" do
      obj = mock("equal")
      obj.should_not_receive(:equal?)
      doc[:foo] = :glark
      doc[obj] = :a
      expect(doc[obj]).to eq(:a)
    end

    it "regards #dup'd objects as having different identities" do
      str = "foo"
      doc[str.dup] = :str
      expect(doc[str]).to be_nil
    end

    it "regards #clone'd objects as having different identities" do
      str = 'foo'
      doc[str.clone] = :str
      expect(doc[str]).to be_nil
    end

    it "regards references to the same object as having the same identity" do
      o = Object.new
      doc[o] = :o
      doc[:a] = :a
      expect(doc[o]).to eq(:o)
    end

    it "perists over #dups" do
      doc["foo"] = :bar
      doc["foo"] = :glark
      expect(doc.dup).to eq(doc)
      expect(doc.dup.size).to eq(doc.size)
    end

    it "persists over #clones" do
      doc["foo"] = :bar
      doc["foo"] = :glark
      expect(doc.clone).to eq(doc)
      expect(doc.clone.size).to eq(doc.size)
    end

    context "when the document is frozen" do

      before do
        doc.freeze
      end

      it "raises a RuntimeError on frozen hashes" do
        expect {
          doc.compare_by_identity
        }.to raise_error(RuntimeError)
      end
    end
  end

  describe "#compare_by_identity?" do

    let(:doc) do
      described_class.new
    end

    context "when the document is comparing by identity" do

      before do
        doc.compare_by_identity
      end

      it "returns true" do
        expect(doc).to be_compare_by_identity
      end
    end

    context "when the document is not comparing by identity" do

      it "returns false" do
        expect(doc).to_not be_compare_by_identity
      end
    end
  end

  describe "#default" do

    context "when provided a value" do

      let(:doc) do
        described_class.new(5)
      end

      context "when provided no args" do

        it "returns the default" do
          expect(doc.default).to eq(5)
        end
      end

      context "when provided args" do

        it "returns the default" do
          expect(doc.default(4)).to eq(5)
        end
      end
    end

    context "when provided a proc" do

      let(:doc) do
        described_class.new { |*args| args }
      end

      it "uses the default proc to compute a default value" do
        expect(doc.default(5)).to eq([ doc, 5 ])
      end

      context "when no value is provided" do

        it "calls default proc with nil arg" do
          expect(doc.default).to be_nil
        end
      end
    end
  end

  pending "#default="
  pending "#default_proc"
  pending "#default_proc="
  pending "#delete"
  pending "#delete_if"
  pending "#each"
  pending "#each_key"
  pending "#each_pair"
  pending "#each_value"
  pending "#empty?"
  pending "#eql?"
  pending "#fetch"
  pending "#flatten"
  pending "#has_key?"
  pending "#has_value?"
  pending "#hash"
  pending "#include?"
  pending "#initialize_copy"
  pending "#inspect"
  pending "#invert"
  pending "#keep_if"
  pending "#key"
  pending "#key?"
  pending "#keys"
  pending "#length"
  pending "#member?"
  pending "#merge"
  pending "#merge!"
  pending "#new"
  pending "#pretty_print"
  pending "#pretty_print_cycle"
  pending "#rassoc"
  pending "#rehash"
  pending "#reject"
  pending "#reject!"
  pending "#replace"
  pending "#select"
  pending "#select!"
  pending "#shift"
  pending "#size"
  pending "#store"
  pending "#to_a"
  pending "#to_hash"
  pending "#to_s"
  pending "#try_convert"
  pending "#update"
  pending "#value?"
  pending "#values"
  pending "#values_at"

  describe "#to_bson/#from_bson" do

    let(:type) { 3.chr }

    it_behaves_like "a bson element"

    context "when the hash is a single level" do

      let(:obj) do
        described_class["key" => "value"]
      end

      let(:bson) do
        "#{20.to_bson}#{String::BSON_TYPE}key#{BSON::NULL_BYTE}" +
        "#{6.to_bson}value#{BSON::NULL_BYTE}#{BSON::NULL_BYTE}"
      end

      it_behaves_like "a serializable bson element"
      it_behaves_like "a deserializable bson element"
    end

    context "when the hash is embedded" do

      let(:obj) do
        described_class["field" => { "key" => "value" }]
      end

      let(:bson) do
        "#{32.to_bson}#{Hash::BSON_TYPE}field#{BSON::NULL_BYTE}" +
        "#{20.to_bson}#{String::BSON_TYPE}key#{BSON::NULL_BYTE}" +
        "#{6.to_bson}value#{BSON::NULL_BYTE}#{BSON::NULL_BYTE}#{BSON::NULL_BYTE}"
      end

      it_behaves_like "a serializable bson element"
      it_behaves_like "a deserializable bson element"
    end
  end
end

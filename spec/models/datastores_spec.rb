require_relative '../spec_helper.rb'
describe Datastores do
  before(:each) do
    @data = [{
      label: "Label",
      href: "/datastore"
    }]
  end
  subject do
    described_class.new(@data)
  end
  context "#each" do
    it "has a working each" do
      @data.push({label: "Label2", href: "/loc_2"})
      output = []
      subject.each{|x| output.push(x)}
      expect(output.count).to eq(2)
    end
  end
  context "#list" do
    it "has a list of datastores" do
      expect(subject.list.count).to eq(1)
    end
  end
  context "single datastore" do
    let(:datastore) { subject.list.first }
    context "#label" do
      it "has a label" do
        expect(datastore.label).to eq("Label")
      end
    end
    context "#href" do
      it "has an href" do
        expect(datastore.href).to eq("#{ENV.fetch('SEARCH_URL')}/datastore")
      end
    end
    context "#current?" do
      it "is false when not listed" do
        expect(datastore.current?).to eq(false)
      end
      it "is true when it is listed" do
        @data.first[:current] = true
        expect(datastore.current?).to eq(true)
      end
    end
  end
end


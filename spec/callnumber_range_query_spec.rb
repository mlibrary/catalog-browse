require 'spec_helper'
describe CallnumberRangeQuery do
  before(:each) do
    @inputs = {
      callnumber: 'callnumber',
      key: nil,
      page: 0,
      cn_core: double('SolrClientWrapper.cn_core'),
      cn_core: double('SolrClientWrapper.catalog_core'),
      query: '*.*',
      filters: [],
      rows: 30
    }
  end
  subject do
    described_class.new(**@inputs)
  end
  context "#sort" do
    it "sorts by 'id asc'" do
      expect(subject.sort).to eq('id asc')
    end

  end
end

describe BrowseListPresenter do
  before(:each) do
    @browse_list = instance_double(BrowseList)
  end
  subject do
    described_class.new(browse_list: @browse_list)
  end
  ["path", "name", "help_text", "doc_title"].each do |method|
    it "raises an error if the child class hasn't implemented ##{method}" do
      expect { subject.public_send(method) }.to raise_error(NotImplementedError)
    end
  end
end

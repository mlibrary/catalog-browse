describe BrowseListPresenter do
  before(:each) do
    @browse_list = instance_double(BrowseList)
  end
  subject do
    described_class.new(browse_list: @browse_list)
  end
  it "raises an error if the child class hasn't implemented #path" do
    expect { subject.path }.to raise_error(NotImplementedError)
  end
  it "raises an error if the child class hasn't implemented #name" do
    expect { subject.name }.to raise_error(NotImplementedError)
  end
  it "raises an error if the child class hasn't implemented #help_text" do
    expect { subject.help_text }.to raise_error(NotImplementedError)
  end
end

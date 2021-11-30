require_relative '../spec_helper.rb'
describe BrowseItem do
  before(:each) do
    @catalog_doc = JSON.parse(fixture('zhizn_bib.json'))
    @index_doc = JSON.parse(fixture('zhizn_browse.json'))
    @exact_match = false
  end
  subject do
    described_class.new(@catalog_doc, @index_doc, @exact_match)
  end
  it "has false match_notice?" do
    expect(subject.match_notice?).to eq(false)
  end
  it "shows appropriate url" do
    expect(subject.url).to eq("https://search.lib.umich.edu/catalog/record/990039902820106381")
  end
  it "shows appropriate title" do
    expect(subject.title).to eq("Zhiznʹ gospodina de Molʹera / M. Bulgakov ; [podgot. teksta i poslesl. V.I. Loseva]. Bulgakov, Mikhail, 1891-1940.")
  end
  it "shows appropriate vernacular title" do
    expect(subject.vernacular_title).to eq("Жизнь господина де Мольера / М. Булгаков ; [подгот. текста и послесл. В.И. Лосева]. Булгаков, Михаил, 1891-1940.")
  end
  it "shows callnumber" do
    expect(subject.callnumber).to eq("PQ 1852 .B85 1992")
  end
  it "shows subtitles" do
    expect(subject.subtitles).to eq(["Bulgakov, Mikhail, 1891-1940.","\"Delovoĭ t͡sentr\","])
  end
end

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
  context "#title" do
    it "shows appropriate title without edition when there isn't one" do
      expect(subject.title).to eq("Zhiznʹ gospodina de Molʹera / M. Bulgakov ; [podgot. teksta i poslesl. V.I. Loseva].")
    end
    it "shows title with edition when there is one" do
      @catalog_doc["edition"] = ["my edition"]
      expect(subject.title).to eq("Zhiznʹ gospodina de Molʹera / M. Bulgakov ; [podgot. teksta i poslesl. V.I. Loseva]. my edition")
    end
  end
  context "#vernacular_title"  do
    it "shows vernacular title without edition when there isn't one" do
      expect(subject.vernacular_title).to eq("Жизнь господина де Мольера / М. Булгаков ; [подгот. текста и послесл. В.И. Лосева].")
    end
    it "shows vernacular title with edition when there is one" do
      @catalog_doc["edition"] = ["my edition"]
      expect(subject.vernacular_title).to eq("Жизнь господина де Мольера / М. Булгаков ; [подгот. текста и послесл. В.И. Лосева]. my edition")
    end
  end
  it "shows appropriate author" do
    expect(subject.author).to eq("Bulgakov, Mikhail, 1891-1940.")
  end
  it "shows appropriate vernacular author" do
    expect(subject.vernacular_author).to eq("Булгаков, Михаил, 1891-1940.")
  end
  it "shows appropriate publisher" do
    expect(subject.publisher).to eq("\"Delovoĭ t͡sentr\",")
  end
  it "shows appropriate vernacular publisher" do
    expect(subject.vernacular_publisher).to eq("\"Деловой центр\",")
  end
  it "shows callnumber" do
    expect(subject.callnumber).to eq("PQ 1852 .B85 1992")
  end
  it "shows subtitles" do
    expect(subject.subtitles).to eq(["Bulgakov, Mikhail, 1891-1940.","\"Delovoĭ t͡sentr\","])
  end
end

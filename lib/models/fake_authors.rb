require "yaml"
require "byebug"
class FakeAuthorList
  def initialize
    #load up items from a yaml file.
    
    @items = YAML.load_file("/app/lib/models/fake_authors.yml").map do |row| 
      FakeAuthor.for(row) 
    end
  end
  def show_table?
    true
  end
  def previous_url
    "#"
  end
  def next_url
    "#"
  end
  def items
    @items
  end
  def match_text
  end
  def error?
    false
  end
  def has_next_list?
    true
  end
  def has_previous_list?
    true
  end
  def next_reference_id
    ""
  end
  def previous_reference_id
    ""
  end
  def original_reference
    "Tate, James, 1943-2015"
  end
  def title
    if self.show_table?
      "Browse &ldquo;#{self.original_reference}&rdquo; in authors"
    else
      "Browse by Author"
    end
  end
  def help_text
    '<span class="strong">Browse by author help:</span> Search an author (last name, first name) and view an alphabetical list of all authors headings (personal names and corporate names) and variations of those names indexed in the Library catalog.'
  end
end
class FakeAuthor
  def self.for(data)
    if data["cross_references"].nil? || data["cross_references"].empty?
     FakeAuthor.new(data)
   else
     FakeAuthorWithCrossReferences.new(data)
    end
  end
  def initialize(data)
    @data = data
  end
  def match_notice?
  end
  def exact_match?
  end
  def author
    @data["author"]
  end
  def num_matches
    @data["num_matches"]
  end
  def url
    "#{ENV.fetch("SEARCH_URL")}/catalog?query=author:(#{self.author})"
  end
  def heading_link?
    !!@data["heading_link"]
  end
  def heading_link
    @data["heading_link"]
  end
  def has_cross_references?
    false
  end
end
class FakeAuthorWithCrossReferences < FakeAuthor
  def url
    ""
  end
  def num_matches
    0 
  end
  def has_cross_references?
    true
  end
  def cross_references
    @data["cross_references"].map{|x| FakeAuthorCrossReference.new(x) }
  end
end
class FakeAuthorCrossReference < FakeAuthor
  def url
    ""
  end
  def kind
    @data["kind"]
  end
end

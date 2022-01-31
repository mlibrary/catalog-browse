require 'yaml'
require 'byebug'
class FakeAuthorList
  def initialize
    #load up items from a yaml file.
    
    @items = YAML.load_file('/app/lib/models/fake_authors.yml').map do |row| 
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
    ''
  end
  def previous_reference_id
    ''
  end
end
class FakeAuthor
  def self.for(data)
   if data["see_also"].nil?
     FakeAuthor.new(data)
   else
     FakeAuthorWithSeeAlso.new(data)
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
    #link to catalog search results
  end
  def heading_link?
    !!@data["heading_link"]
  end
  def heading_link
    @data["heading_link"]
  end
  def has_see_also?
    false
  end
end
class FakeAuthorWithSeeAlso < FakeAuthor
  def url
    ""
  end
  def num_matches
    ""
  end
  def has_see_also?
    true
  end
  def see_also_url
    "#"
  end
  def see_also_author
    @data["see_also"]["author"]
  end
  def see_also_num_matches
    @data["see_also"]["num_matches"]
  end
  def see_also_heading_link?
    !!@data["see_also"]["heading_link"]
  end
  def see_also_heading_link
    @data["see_also"]["heading_link"]
  end
end

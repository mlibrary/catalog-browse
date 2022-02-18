require "yaml"
require "byebug"
class FakeSubjectList
  def initialize
    #load up items from a yaml file.
    
    @items = YAML.load_file("/app/lib/models/fake_subjects.yml").map do |row| 
      FakeSubject.for(row) 
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
      "Browse &ldquo;#{self.original_reference}&rdquo; in subjects"
    else
      "Browse by Subject"
    end
  end
  def help_text
    '<span class="strong">Browse by subject help:</span> Search subject and view an alphabetical list of all subjects (Library of Congress Subject Headings (LCSH) (left-anchored) indexed in the Library catalog.'
  end
end
class FakeSubject
  def self.for(data)
    if data["cross_references"].nil? || data["cross_references"].empty?
     FakeSubject.new(data)
   else
     FakeSubjectWithCrossReferences.new(data)
    end
  end
  def initialize(data)
    @data = data
  end
  def match_notice?
  end
  def exact_match?
  end
  def subject
    @data["subject"]
  end
  def num_matches
    @data["num_matches"]
  end
  def record_text
    "#{self.num_matches} #{self.num_matches == 1 ? "record" : "records"}"
  end
  def url
    "#{ENV.fetch("SEARCH_URL")}/catalog?query=subject:(#{self.subject})"
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
class FakeSubjectWithCrossReferences < FakeSubject
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
    @data["cross_references"].map{|x| FakeSubjectCrossReference.new(x) }
  end
end
class FakeSubjectCrossReference < FakeSubject
  def url
    ""
  end
  def kind
    @data["kind"]
  end
end

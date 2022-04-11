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
    "Physics"
  end
  def title
    if self.show_table?
      "Browse &ldquo;#{self.original_reference}&rdquo; in subjects"
    else
      "Browse by Subject"
    end
  end
  def help_text
    '<span class="strong">Browse by subject help:</span> Search within an alphabetical list of all <a href="https://id.loc.gov/authorities/subjects.html">Library of Congress Subject Headings</a> (LCSH) indexed in the Library catalog.'
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
    "#{ENV.fetch("SEARCH_URL")}/heading-information?query=#{self.subject}"
  end
  def has_cross_references?
    false
  end
end
class FakeSubjectWithCrossReferences < FakeSubject
  def has_cross_references?
    true
  end
  def cross_references
    @data["cross_references"].map{|x| FakeSubjectCrossReference.new(x)}
  end
end
class FakeSubjectCrossReference < FakeSubject
  def kind
    @data["kind"]
  end
  def terms
    @data["terms"].map{|x| FakeSubjectTerm.new(x)}
  end
  def has_terms?
    self.kind == "term" && !self.terms.nil?
  end
  def last_term?(index)
    self.terms.length - 1 == index
  end
end
class FakeSubjectTerm < FakeSubject
  #
end

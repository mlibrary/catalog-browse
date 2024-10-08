class SubjectItem
  attr_reader :browse_doc
  def self.for(browse_doc:, exact_match:)
    if ["broader", "narrower", "see_also", "see_instead"]
        .any? { |xref_kind| browse_doc.key?(xref_kind) }
      SubjectItemWithCrossReferences.new(browse_doc: browse_doc, exact_match: exact_match)
    else
      SubjectItem.new(browse_doc: browse_doc, exact_match: exact_match)
    end
  end

  def initialize(browse_doc:, exact_match:)
    @browse_doc = browse_doc
    @exact_match = exact_match
  end

  def match_notice?
    false
  end

  def exact_match?
    !!@exact_match
  end

  def term
    @browse_doc["term"]&.strip
  end

  def subject
    term
  end

  def url
    params = {library: "U-M Ann Arbor Libraries", query: "lc_subject_starts_with:(\"#{subject}\")", "filter.search_only": false}
    "https://search.lib.umich.edu/catalog?#{URI.encode_www_form(params)}"
  end

  def results_count
    @browse_doc["count"]
  end

  def record_text
    "#{results_count} record#{"s" if results_count != 1}"
  end

  # mrio: commenting out because it isn't currently used in the UI
  # def alternate_forms
  # @browse_doc["alternate_forms"]
  # end

  def has_cross_references?
    false
  end

  def heading_link?
    !!heading_link
  end

  def heading_link
    @browse_doc["loc_id"]
  end
end

class SubjectItemWithCrossReferences < SubjectItem
  def has_cross_references?
    true
  end

  def cross_references
    xrefs = {}
    [:broader, :narrower, :see_also, :see_instead].each do |xref|
      # get the terms class from the xref name (example: BroaderTerms)
      terms_klass = Module.const_get "#{xref.to_s.split("_").collect(&:capitalize).join}Terms"
      xrefs[xref] = terms_klass.new(@browse_doc[xref.to_s])
    end
    OpenStruct.new(**xrefs)
  end
end

class SubjectItemCrossReferences
  def initialize(terms)
    @terms = terms&.map { |subject| SubjectItemCrossReference.new(subject) }
  end

  def leading
    @terms&.first(10) || []
  end

  def remaining
    @terms&.drop(leading.count) || []
  end

  def has_remaining?
    remaining.any?
  end

  def any?
    leading.any?
  end

  def text
    ""
  end

  private

  def summary_text(closed, type)
    "#{(closed == true) ? "Show all #{@terms.length}" : "Hide #{remaining.count}"}#{" #{type}" if !type.nil?} term#{"s" if closed || !closed && remaining.count != 1}"
  end
end

class BroaderTerms < SubjectItemCrossReferences
  def text
    "Broader term#{"s" if @terms.count != 1}"
  end

  def summary_text_closed
    summary_text(true, "broader")
  end

  def summary_text_open
    summary_text(false, "broader")
  end
end

class NarrowerTerms < SubjectItemCrossReferences
  def text
    "Narrower term#{"s" if @terms.count != 1}"
  end

  def summary_text_closed
    summary_text(true, "narrower")
  end

  def summary_text_open
    summary_text(false, "narrower")
  end
end

class SeeAlsoTerms < SubjectItemCrossReferences
  def text
    "See also"
  end

  def summary_text_closed
    summary_text(true, nil)
  end

  def summary_text_open
    summary_text(false, nil)
  end
end

class SeeInsteadTerms < SubjectItemCrossReferences
  def text
    "See instead"
  end

  def summary_text_closed
    summary_text(true, "see instead")
  end

  def summary_text_open
    summary_text(false, "see instead")
  end
end

class SubjectItemCrossReference
  attr_reader :subject, :count
  def initialize(subject)
    @subject, @count = subject.split("||").map { |x| x.strip }
  end

  def subject_display
    @subject
  end

  def record_text
    "#{count} record#{"s" if count != "1"}"
  end

  def url
    "#{S.base_url}/subject?query=#{URI.encode_www_form_component(@subject)}"
  end

  def heading_link?
    false
  end
end

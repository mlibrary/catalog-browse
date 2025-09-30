class BrowseListPresenter
  extend Forwardable

  def_delegators :@browse_list, :show_table?, :error?, :has_next_list?, :has_previous_list?, :next_reference_id, :previous_reference_id, :original_reference, :num_rows_to_display, :num_matches, :exact_matches, :banner_reference, :error_message, :index_docs

  def initialize(browse_list:)
    @browse_list = browse_list
  end

  def title
    if show_table?
      if name == "call number"
        "Browse &ldquo;#{original_reference}&rdquo; in #{name}s"
      else
        "Browse &ldquo;#{original_reference}&rdquo; in an alphabetical list of #{name}s"
      end
    else
      "Browse by #{name}"
    end
  end

  def previous_url
    nav_url(@browse_list.previous_url_params)
  end

  def next_url
    nav_url(@browse_list.next_url_params)
  end

  def match_text
    case num_matches
    when 0
      "<span class=\"strong\">#{original_reference}</span> would appear here. There's no exact match for that #{name} in our catalog."
    when 1
      "We found a matching #{name} in our catalog for: <span class=\"strong\">#{original_reference}</span>."
    else
      "We found #{num_matches} matching items in our catalog for the #{name}: <span class=\"strong\">#{original_reference}</span>"
    end
  end

  def path
    raise NotImplementedError, "#{self.class} should have implemented..."
  end

  def name
    raise NotImplementedError, "#{self.class} should have implemented..."
  end

  def help_text
    raise NotImplementedError, "#{self.class} should have implemented..."
  end

  def doc_title
    raise NotImplementedError, "#{self.class} should have implemented..."
  end

  private

  def nav_url(params)
    "#{S.base_url}/#{path}?#{URI.encode_www_form(params)}"
  end
end

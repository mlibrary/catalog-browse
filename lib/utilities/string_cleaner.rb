module StringCleaner
  def self.prefixes
    # are there more of these?
    [
      "academic_discipline",
      "author",
      "call_number_starts_with",
      "contains",
      "contributor",
      "date",
      "isbn",
      "isn",
      "issn",
      "journal_title",
      "keyword",
      "pmid",
      "publication_date",
      "publisher",
      "realuth",
      "series",
      "subject",
      "title",
      "title_starts_with"
    ]
  end

  def self.strip_symbols(str)
    # str.gsub(/[\p{P}\p{Sm}\p{Sc}\p{So}^`]/, "")
    str.gsub(/["'(){}\[\]]/, "")
  end

  # TODO: add bits to remove field prefix (e.g., 'author:') as defined in 00-catalog.yml
  # this is where the author browse specific cleaning goes
  def self.cleanup_author_browse_string(str)
    prefixes.each do |x|
      if str.match?(/^#{x}:["(]/)
        str.sub!(/^#{x}:/, "")
        break
      end
    end
    strip_symbols(str)
  end
end

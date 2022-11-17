module StringCleaner
  def self.prefixes
    # are there more of these?
    [
      "author",
      "subject",
      "academic_discipline"
    ]
  end

  def self.strip_symbols(str)
    str.gsub(/[\p{P}\p{Sm}\p{Sc}\p{So}^`]/, "")
  end

  # TODO: add bits to remove field prefix (e.g., 'author:') as defined in 00-catalog.yml
  # this is where the author browse specific cleaning goes
  def self.cleanup_author_browse_string(str)
    prefixes.each do |x|
      if str.match?(/^#{x}:"/)
        str.sub!(/^#{x}:"/, "")
        break
      end
    end
    strip_symbols(str)
  end
end

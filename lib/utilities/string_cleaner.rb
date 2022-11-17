module StringCleaner
  def self.strip_symbols(str)
    str.gsub(/[\p{P}\p{Sm}\p{Sc}\p{So}^`]/, "")
  end

  # TODO: add bits to remove field prefix (e.g., 'author:') as defined in 00-catalog.yml
  # this is where the author browse specific cleaning goes
  def self.cleanup_author_browse_string(str)
    strip_symbols(str)
  end
end

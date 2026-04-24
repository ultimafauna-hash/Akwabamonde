-- Extension setup
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Search function using pg_trgm and unaccent
CREATE OR REPLACE FUNCTION search_articles(search_query TEXT)
RETURNS SETOF articles AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM articles
  WHERE 
    -- Search in unaccented title and content
    unaccent(title) ILIKE unaccent('%' || search_query || '%')
    OR unaccent(content) ILIKE unaccent('%' || search_query || '%')
    -- Trigam similarity search for typo tolerance
    OR title % search_query
    OR content % search_query
  ORDER BY 
    -- Order by similarity first, then by date
    similarity(unaccent(title), unaccent(search_query)) DESC,
    date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

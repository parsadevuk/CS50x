SELECT AVG(rating) FROM ratings
JOIN movies on movies.id=ratings.movie_id
WHERE movies.year=2012;
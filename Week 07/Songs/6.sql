SELECT name FROM songs WHERE artist_id = (SELECT id from artists WHERE name = 'Post Malone');
-- CREATE INDEX "artist_id_index" ON "songs" ("artist_id");
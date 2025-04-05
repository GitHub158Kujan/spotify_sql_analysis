-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


select * from spotify;

--EDA
SELECT COUNT(*) FROM spotify;

-- ARTISTS COUNT
SELECT COUNT(DISTINCT artist) FROM spotify;

--ALBUM COUNT
SELECT COUNT(DISTINCT album) FROM spotify;

--ALBUM TYPE
SELECT DISTINCT album_type FROM spotify;

--MAXIMUM DURATION
SELECT MAX(duration_min) FROM spotify;

--MINIMUM DURATION
SELECT MIN(duration_min) FROM spotify;
SELECT * FROM spotify WHERE duration_min=0;
DELETE FROM spotify 
WHERE duration_min=0;

--CHANNELS
SELECT DISTINCT(channel) FROM spotify;

--MOST PLAYED ON
SELECT DISTINCT(most_played_on) FROM spotify;


--Data analysis

--Tracks that have more than 1 billion streams.
SELECT track,stream FROM spotify WHERE stream>1000000000

--Albums along with their respective artists.
SELECT DISTINCT album,artist FROM spotify;

--Total number of comments for tracks where licensed = TRUE.
SELECT SUM(comments) FROM spotify WHERE licensed = 'TRUE'

--Tracks that belong to the album type single.
SELECT track,album_type FROM spotify WHERE album_type='single';

--Count the total number of tracks by each artist.
SELECT artist,count(track) FROM spotify GROUP BY artist;

--Average danceability of tracks in each album.
SELECT album,AVG(danceability) FROM spotify
GROUP BY album;

--Top 5 tracks with the highest energy values.
SELECT track,MAX(energy)
FROM spotify
GROUP BY track
ORDER BY energy DESC LIMIT 5;

--All tracks along with their views and likes where official_video = TRUE.
SELECT track, views,likes 
FROM spotify
WHERE official_video=TRUE;

--For each album, total views of all associated tracks.
SELECT album, SUM(views) as total_views
FROM spotify
GROUP BY album,track;

--Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
(SELECT track ,
COALESCE(SUM(CASE WHEN most_played_on='Youtube' THEN stream END),0) as streamed_on_youtube,
COALESCE(SUM(CASE WHEN most_played_on='Spotify' THEN stream END),0) as streamed_on_spotify
FROM spotify 
GROUP BY track) as t1
WHERE streamed_on_spotify>streamed_on_youtube
AND 
streamed_on_youtube!=0;

--Top 3 most-viewed tracks for each artist using window functions.
SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY Artist ORDER BY Views DESC) AS view_rank
    FROM spotify_dataset
) ranked
WHERE view_rank <= 3;

--Tracks where the liveness score is above the average.
SELECT *
FROM spotify_dataset
WHERE Liveness > (
    SELECT AVG(Liveness)
    FROM spotify_dataset
);

--Difference between the highest and lowest energy values for tracks in each album.
WITH energy_diff AS (
    SELECT Album,
           MAX(Energy) AS max_energy,
           MIN(Energy) AS min_energy,
           MAX(Energy) - MIN(Energy) AS energy_range
    FROM spotify_dataset
    GROUP BY Album
)
SELECT * FROM energy_diff;

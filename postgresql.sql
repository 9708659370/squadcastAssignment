'1. Data Import'
'create a ratings table and insert all data from ratings.csv file'
create table movie_ratings(
	rater_id int,movie_id int,rating int,time varchar(100)
);
select * from movie_ratings;

copy movie_ratings from 'H:\movies_csv\ratings.csv'
DELIMITER ',' csv header;


'create a movies_name table and insert all data from movies.csv file'
create table movies_name (
	id int,title varchar(500),year int,country varchar(500), 
	genre varchar(500), director varchar(500),minutes int,
	poster varchar(500)
);
select * from public."movies_name";

copy movies_name(id,title,year,country,genre,director,minutes,poster) 
from 'H:\movies_csv\movie.csv'
DELIMITER ',' csv header;


'2. Insights and Analysis'

'a. Top 5 Movie Titles'
select title from movies_name order by minutes desc limit 5;

select title from movies_name order by year desc limit 5;

select m.title from
movie_ratings as r inner join movies_name as m
on r.movie_id=m.id where (select avg(rating) from movie_ratings)>=5 limit 5;

select m.title from
movie_ratings as r inner join movies_name as m
on r.movie_id=m.id order by r.rating desc;

'b. Number of Unique Raters'
select count(rater_id) from movie_ratings group by rater_id;

'c. Top 5 Rater IDs'
select rater_id from movie_ratings group by rater_id 
order by count(rater_id) desc limit 5;

SELECT rater_id FROM movie_ratings GROUP BY rater_id
HAVING COUNT(*) >= 5 ORDER BY avg(rating) DESC LIMIT 5;

'd. Top Rated Movie'
select m.title 
from movies_name m inner join movie_ratings r
on m.id=r.movie_id where rating=(select max(rating) from movie_ratings) and 
m.director='Michael Bay'and m.genre='comedy' and m.year=2003 and r.rating>=5
limit 1;

'e. Favorite Movie Genre of Rater ID 1040'
SELECT m.genre AS favorite_genre
FROM (
    SELECT rater_id, movie_id
    FROM movie_ratings
    WHERE rater_id = 1040
    GROUP BY rater_id, movie_id
    ORDER BY count(*) DESC
    LIMIT 1
) AS most_rated
JOIN movies_name m ON most_rated.movie_id = m.id;


'f. Highest Average Rating for a Movie Genre by Rater ID 1040'
WITH GenreRatings AS (
    SELECT m.genre, AVG(r.rating) AS average_rating, COUNT(r.movie_id) AS rating_count
    FROM movie_ratings r  JOIN movies_name m ON r.movie_id = m.id
    WHERE r.rater_id = 1040
    GROUP BY m.genre
    HAVING COUNT(r.movie_id) >= 5
)
SELECT genre,average_rating FROM GenreRatings
ORDER BY average_rating DESC LIMIT 1;


'g. Year with Second-Highest Number of Action Movies'
WITH ActionMovies AS (
    SELECT m.year, COUNT(*) AS num_action_movies FROM movies_name m JOIN
    movie_ratings r ON m.id = r.movie_id
    WHERE
        m.genre = 'Action'
        AND m.country = 'USA'
        AND r.rating >= 6.5
        AND m.minutes < 120
    GROUP BY m.year
)
SELECT year FROM ActionMovies ORDER BY num_action_movies DESC
OFFSET 1 LIMIT 1;


'h. Count of Movies with High Ratings:'
SELECT COUNT(*) AS high_rated_movies_count
FROM (
    SELECT movie_id FROM movie_ratings WHERE rating >= 7
    GROUP BY movie_id
    HAVING COUNT(*) >= 5
) AS high_rated_movies;


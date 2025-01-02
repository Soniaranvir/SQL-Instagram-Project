-- Updating the caption of post_id 3
UPDATE Posts
SET caption = 'Best pizza ever'
WHERE post_id = 3;

--WHERE Condition 
-- Selecting all the posts where user_id is 1
SELECT *
FROM Posts
WHERE user_id = 1;

--ORDER BY 
-- Selecting all the posts and ordering them by created_at in descending order
SELECT *
FROM Posts
ORDER BY created_at DESC;

--GROUP BY and HAVING 
-- Counting the number of likes for each post and showing only the posts with more than 2 likes
SELECT Posts.post_id, COUNT(Likes.like_id) AS num_likes
FROM Posts
LEFT JOIN Likes ON Posts.post_id = Likes.post_id
GROUP BY Posts.post_id
HAVING COUNT(Likes.like_id) > 2;

--Aggregation Functions 
-- Finding the total number of likes for all posts
SELECT SUM(num_likes) AS total_likes
FROM (
    SELECT COUNT(Likes.like_id) AS num_likes
    FROM Posts
    LEFT JOIN Likes ON Posts.post_id = Likes.post_id
    GROUP BY Posts.post_id
) AS likes_by_post;

--Subquery 
-- Finding all the users who have commented on post_id 1
SELECT name
FROM Users
WHERE user_id IN (
    SELECT user_id
    FROM Comments
    WHERE post_id = 1
);

--Window Function 
-- Ranking the posts based on the number of likes
SELECT post_id, num_likes, RANK() OVER (ORDER BY num_likes DESC) AS rank
FROM (
    SELECT Posts.post_id, COUNT(Likes.like_id) AS num_likes
    FROM Posts
    LEFT JOIN Likes ON Posts.post_id = Likes.post_id
    GROUP BY Posts.post_id
) AS likes_by_post;

--CTE 
-- Finding all the posts and their comments using a Common Table Expression (CTE)
WITH post_comments AS (
    SELECT Posts.post_id, Posts.caption, Comments.comment_text
    FROM Posts
    LEFT JOIN Comments ON Posts.post_id = Comments.post_id
)
SELECT *
FROM post_comments;

--Case Statement 
-- Categorizing the posts based on the number of likes
SELECT
    post_id,
    CASE
        WHEN num_likes = 0 THEN 'No likes'
        WHEN num_likes < 5 THEN 'Few likes'
        WHEN num_likes < 10 THEN 'Some likes'
        ELSE 'Lots of likes'
    END AS like_category
FROM (
    SELECT Posts.post_id, COUNT(Likes.like_id) AS num_likes
    FROM Posts
    LEFT JOIN Likes ON Posts.post_id = Likes.post_id
    GROUP BY Posts.post_id
) AS likes_by_post;

--Date Casting and Working with Dates 
-- Finding all the posts created in the last month
SELECT *
FROM Posts
WHERE created_at >= CAST(DATE_TRUNC('month', CURRENT_TIMESTAMP - INTERVAL '1 month') AS DATE);
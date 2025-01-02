-- Practice Questions
--JOINS - Which users have liked post_id 2?
SELECT Users.name
FROM Users
JOIN Likes ON Users.user_id = Likes.user_id
WHERE Likes.post_id = 2;

--Which posts have no comments?
SELECT Posts.caption
FROM Posts
LEFT JOIN Comments ON Posts.post_id = Comments.post_id
WHERE Comments.comment_id IS NULL;

--Which posts were created by users who have no followers?
SELECT Posts.caption
FROM Posts
JOIN Users ON Posts.user_id = Users.user_id
LEFT JOIN Followers ON Users.user_id = Followers.user_id
WHERE Followers.follower_id IS NULL;

--Aggregation
--How many likes does each post have?
SELECT Posts.caption, COUNT(Likes.like_id) AS num_likes
FROM Posts
LEFT JOIN Likes ON Posts.post_id = Likes.post_id
GROUP BY Posts.post_id;

--What is the average number of likes per post?
SELECT AVG(num_likes) AS avg_likes
FROM (
    SELECT COUNT(Likes.like_id) AS num_likes
    FROM Posts
    LEFT JOIN Likes ON Posts.post_id = Likes.post_id
    GROUP BY Posts.post_id
) AS likes_by_post;

--Which user has the most followers?
SELECT Users.name, COUNT(Followers.follower_id) AS num_followers
FROM Users
LEFT JOIN Followers ON Users.user_id = Followers.user_id
GROUP BY Users.user_id
ORDER BY num_followers DESC
LIMIT 1;

--Window Function
--Rank the users by the number of posts they have created.
SELECT name, num_posts, RANK() OVER (ORDER BY num_posts DESC) AS rank
FROM (
    SELECT Users.name, COUNT(Posts.post_id) AS num_posts
    FROM Users
    LEFT JOIN Posts ON Users.user_id = Posts.user_id
    GROUP BY Users.user_id
) AS posts_by_user;

--Rank the posts based on the number of likes.
SELECT post_id, num_likes, RANK() OVER (ORDER BY num_likes DESC) AS rank
FROM (
    SELECT Posts.post_id, COUNT(Likes.like_id) AS num_likes
    FROM Posts
    LEFT JOIN Likes ON Posts.post_id = Likes.post_id
    GROUP BY Posts.post_id
) AS likes_by_post;

--Find the cumulative number of likes for each post.
SELECT post_id, num_likes, SUM(num_likes) OVER (ORDER BY created_at) AS cumulative_likes
FROM (
    SELECT Posts.post_id, COUNT(Likes.like_id) AS num_likes, Posts.created_at
    FROM Posts
    LEFT JOIN Likes ON Posts.post_id = Likes.post_id
    GROUP BY Posts.post_id
) AS likes_by_post;

--CTE
--Find all the comments and their users using a Common Table Expression (CTE).
WITH comment_users AS (
    SELECT Comments.comment_text, Users.name
    FROM Comments
    JOIN Users ON Comments.user_id = Users.user_id
)
SELECT *
FROM comment_users;

--Find all the followers and their follower users using a CTE.
WITH follower_users AS (
    SELECT Users.name AS follower, follower_users.name AS user_followed
    FROM Users
    JOIN Followers ON Users.user_id = Followers.follower_user_id
    JOIN Users AS follower_users ON Followers.user_id = follower_users.user_id
)
SELECT *
FROM follower_users;

--Find all the posts and their comments using a CTE.
WITH post_comments AS (
    SELECT Posts.caption, Comments.comment_text
    FROM Posts
    LEFT JOIN Comments ON Posts.post_id = Comments.post_id
)
SELECT *
FROM post_comments;

--Case Statement
--Categorize the posts based on the number of likes.
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

--Categorize the users based on the number of comments they have made.
SELECT
    Users.name,
    CASE
        WHEN num_comments = 0 THEN 'No comments'
        WHEN num_comments < 5 THEN 'Few comments'
        WHEN num_comments < 10 THEN 'Some comments'
        ELSE 'Lots of comments'
    END AS comment_category
FROM Users
LEFT JOIN (
    SELECT user_id, COUNT(comment_id) AS num_comments
    FROM Comments
    GROUP BY user_id
) AS comments_by_user ON Users.user_id = comments_by_user.user_id;

--Categorize the posts based on their age.
SELECT
    post_id,
    CASE
        WHEN age_in_days < 7 THEN 'New post'
        WHEN age_in_days < 30 THEN 'Recent post'
        ELSE 'Old post'
    END AS age_category
FROM (
    SELECT post_id, CURRENT_DATE - created_at::DATE AS age_in_days
    FROM Posts
) AS post_ages;
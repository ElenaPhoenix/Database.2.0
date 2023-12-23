/* Задача 1
Подсчитать количество групп (сообществ), в которые вступил каждый пользователь.
 */
SELECT 
	CONCAT(firstname, ' ', lastname) AS owner, # CONCAT - функция склеивания в одно поле
	COUNT(*)
FROM users
JOIN users_communities ON users.id = users_communities.user_id
GROUP BY users.id 
ORDER BY COUNT(*) DESC; # Сортировка по убыванию количества

/*Задача 2
Подсчитать количество пользователей в каждом сообществе.
*/
SELECT 
	COUNT(*),
	communities.name
FROM users_communities
JOIN communities ON users_communities.user_id = communities.id
GROUP BY communities.id 

/* Задача 3
Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, который больше всех общался с выбранным пользователем (написал ему сообщений).
*/
SELECT 
from_user_id,
CONCAT (users.firstname, ' ', users.lastname) AS name,
count(*) AS 'messages count'
FROM messages
JOIN users ON users.id = messages.from_user_id # присоединили таблицу users, чтобы получить users.firstname, users.lastname
WHERE to_user_id = 1 # задали целевого пользователя, №1
GROUP BY from_user_id
ORDER BY count(*) DESC
LIMIT 1;
#Обращаемся к таблице messages, фильтруем по получателю, группируем по отправителю. Для каждого отправителя считаем COUNT, отсортировали по убыванию количества

#Без JOIN через вложенные запросы
SELECT 
from_user_id,
CONCAT ((SELECT firstname FROM users WHERE id = messages.from_user_id), ' ', 
(SELECT lastname FROM users WHERE id = messages.from_user_id)) AS name,
count(*) AS 'messages count'
FROM messages
WHERE to_user_id = 1 # задали целевого пользователя, №1
GROUP BY from_user_id
ORDER BY count(*) DESC
LIMIT 1;

/* Задача 4
Подсчитать общее количество лайков, которые получили пользователи младше 18 лет..
*/
-- Решение с вложенными запросами
SELECT count(*) -- количество лайков  
FROM likes 
WHERE media_id IN -- все медиа записи таких пользователей
	(SELECT id
	FROM media
	WHERE user_id in -- все пользователи младше 18 лет 
		(SELECT user_id -- , birthday 
		FROM profiles
		WHERE YEAR(CURDATE()) - YEAR(birthday) <18
		)
	);

-- Решение с JOIN
SELECT count(*) -- количество лайков  
FROM likes
JOIN media ON likes.media_id = media.id     
JOIN profiles ON profiles.user_id = media.user_id  
WHERE YEAR(CURDATE()) - YEAR(birthday) <18;  

/* Задача 5
Определить кто больше поставил лайков (всего): мужчины или женщины.
*/
-- решение с вложенными запросами
SELECT gender, count(*)
FROM (
	SELECT 
		user_id AS user,
		(SELECT gender 
		FROM vk.profiles
		WHERE user_id = user) AS gender
	FROM likes) AS dummy
GROUP BY gender;

-- решение с объединением таблиц
SELECT  gender, COUNT(*)
FROM likes
JOIN profiles ON likes.user_id = profiles.user_id 
GROUP BY gender;

-- Альтернативное решение.
SELECT gender FROM (
	SELECT gender, COUNT((SELECT COUNT(*) FROM likes AS L WHERE L.user_id = P.user_id)) AS gender_likes_count FROM profiles AS P
	WHERE gender = 'm'
	GROUP BY gender
	UNION ALL
	SELECT gender, COUNT((SELECT COUNT(*) FROM likes AS L WHERE L.user_id = P.user_id)) FROM profiles AS P
	WHERE gender = 'f'
	GROUP BY gender
) AS T
GROUP BY gender
ORDER BY MAX(gender_likes_count) DESC
LIMIT 1;


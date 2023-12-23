/* Задача 1
Создайте представление с произвольным SELECT-запросом из прошлых уроков [CREATE VIEW]
 */
-- Подсчитать количество групп (сообществ), в которые вступил каждый пользователь.
CREATE or replace VIEW count_com AS 
SELECT 
	CONCAT(firstname, ' ', lastname) AS owner, # CONCAT - функция склеивания в одно поле
	COUNT(*)
FROM users
JOIN users_communities ON users.id = users_communities.user_id
GROUP BY users.id 
ORDER BY COUNT(*) DESC; # Сортировка по убыванию количества

/*Задача 2
Выведите данные, используя написанное представление [SELECT]
*/
select *
from count_com;

/* Задача 3
Удалите представление [DROP VIEW]
*/
DROP VIEW count_com;

/* Задача 4
Сколько новостей (записей в таблице media) у каждого пользователя? 
Вывести поля: news_count (количество новостей), user_id (номер пользователя), user_email (email пользователя). 
Попробовать решить с помощью CTE или с помощью обычного JOIN.
*/
WITH cte1 AS ( -- даем имя запросу
	select 
		count(*) as news_count,
		user_id
	from media
	group by user_id
)
SELECT news_count, user_id, email as user_email
FROM cte1 
JOIN users as u on u.id = cte1.user_id 



select count(*) as news_count,
	user_id,
	email as user_email
from media
join users on users.id = media.user_id -- теперь можем вывести email
group by user_id
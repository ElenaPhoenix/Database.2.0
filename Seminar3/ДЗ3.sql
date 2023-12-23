/* Задача 1
Написать скрипт, возвращающий список имен (только firstname) пользователей без повторений в алфавитном порядке. [ORDER BY]
*/
SELECT DISTINCT firstname
FROM users
ORDER by firstname;

/*Еще один вариант
SELECT firstname
FROM users
GROUP BY firstname
ORDER by firstname;
 */

/*Задача 2
Выведите количество мужчин старше 35 лет [COUNT].
*/
SELECT COUNT(*)
FROM profiles
WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) > 35 
	and gender = 'm'
;


/* Задача 3
Сколько заявок в друзья в каждом статусе? (таблица friend_requests) [GROUP BY]
*/
SELECT 
	COUNT(*),
	status
FROM friend_requests 
GROUP BY status

/* Задача 4
Выведите номер пользователя, который отправил больше всех заявок в друзья (таблица friend_requests) [LIMIT].
*/
SELECT 
	COUNT(*) AS cnt
FROM friend_requests 
GROUP BY initiator_user_id 
ORDER BY cnt DESC
LIMIT 1;

/* Задача 5
Выведите названия и номера групп, имена которых состоят из 5 символов [LIKE].
*/
SELECT name
FROM communities 
WHERE name LIKE '_____' -- 5 символов подчеркивания заменяют 5 букв

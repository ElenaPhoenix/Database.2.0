SELECT 
	firstname,
	lastname ,
	(SELECT hometown FROM profiles WHERE user_id = users.id) AS 'city', # в скобках вложенные (самостоятельные) запросы
	(SELECT filename FROM media WHERE id = (
		SELECT photo_id FROM profiles WHERE user_id = users.id
	)) AS 'main_photo'
FROM users 
WHERE id = 1

-- то же с помощью JOIN, с использованием внешних ключей, предпочтительнее
SELECT 
	firstname,
	lastname ,
	profiles.hometown AS 'city', 
	media.filename AS 'main_photo'
FROM users
JOIN profiles ON users.id = profiles.user_id 
JOIN media ON media.id = profiles.photo_id 
WHERE users.id = 1 # уточняем, из какой таблицы нужно использовать id: users

-- Выбираем фотографии пользователя
SELECT filename 
FROM media 
WHERE user_id = 1
    AND media_type_id = 1; # 1 - id фоток в таблице media_type_id
    
    #если не знаем id пользователя, а знаем email

SELECT filename 
FROM media 
WHERE user_id = (SELECT id FROM users WHERE email = 'arlo50@example.org')
    AND media_type_id = 1; # 1 - id фоток в таблице media_types

-- Количество новостей каждого типа
SELECT 
	COUNT(*), media_type_id
FROM media
GROUP BY media_type_id;

	#... с выводом названия каждого media_types
SELECT 
	COUNT(*), media_type_id, 
	(SELECT name FROM media_types WHERE id = media_type_id) AS type # AS указывает на псевдоним
FROM media
GROUP BY media_type_id;


-- CROSS JOIN
SELECT *
FROM users, messages ;

SELECT COUNT(*)
FROM users, messages ;

SELECT *
FROM users, messages 
WHERE users.id = messages.from_user_id ;


-- CROSS JOIN - работает медленно, лучше использовать INNER JOIN
SELECT *
FROM users AS u
JOIN messages AS m
WHERE u.id = m.from_user_id ;


-- INNER JOIN
SELECT *
FROM users AS u
INNER JOIN messages AS m ON u.id = m.from_user_id ; # INNER можно не писать, подразумевается, если пишем ON 


-- LEFT [OUTER] JOIN
SELECT *
FROM users
LEFT JOIN messages ON users.id = messages.from_user_id
ORDER BY messages.id


-- LEFT JOIN, выборка пользователей, которые не писали сообщений
SELECT users.*
FROM users
LEFT OUTER JOIN messages ON users.id = messages.from_user_id
WHERE messages.id IS NULL
ORDER BY messages.id


-- LEFT JOIN
SELECT users.*, messages.*
FROM users LEFT JOIN messages ON users.id = messages.from_user_id
ORDER BY messages.id


-- RIGHT JOIN - поменять местами таблицы, переназвать JOIN, и выборки LEFT и RIGHT дадут одинаковый результат
SELECT users.*, messages.* #порядок таблиц не меняем
FROM messages RIGHT JOIN users ON users.id = messages.from_user_id
ORDER BY messages.id


-- FULL JOIN
#Создаем баг, сообщения без отправителя
INSERT INTO vk.messages
(from_user_id, to_user_id, body, created_at)
VALUES(NULL, 2, 'some text...', CURRENT_TIMESTAMP);

SELECT users.*, messages.*
FROM users 
LEFT JOIN messages ON users.id = messages.from_user_id
	UNION
SELECT users.*, messages.*
FROM users 
RIGHT JOIN messages ON users.id = messages.from_user_id

-- INNER JOIN			100 
-- LEFT OUTER JOIN		116
-- RIGHT OUTER JOIN 	101 , 1 - добавленное сообщение-баг
-- FULL [OUTER] JOIN	117 = 100 + 16 + 1

-- Р’С‹Р±РѕСЂРєР° РґР°РЅРЅС‹С… РїРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЋ (СЃРѕ РІР»РѕР¶РµРЅРЅС‹РјРё Р·Р°РїСЂРѕСЃР°РјРё)
SELECT 
	firstname, 
	lastname, 
	(SELECT birthday FROM profiles WHERE user_id = users.id) AS birthday,
	(SELECT hometown FROM profiles WHERE user_id = users.id) AS city,
	(SELECT filename FROM media WHERE id = 
	    (SELECT photo_id FROM profiles WHERE user_id = users.id)
	) AS main_photo
FROM users 
WHERE id = 1;

-- Р’С‹Р±РѕСЂРєР° РґР°РЅРЅС‹С… РїРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЋ (JOIN)
SELECT 
	firstname, 
	lastname, 
	birthday,
	p.hometown AS city,
	m.filename AS main_photo
FROM users AS u
JOIN profiles AS p ON p.user_id = u.id
JOIN media as m ON m.id = p.photo_id 
WHERE u.id = 1;


-- РЎРѕРѕР±С‰РµРЅРёСЏ Рє РїРѕР»СЊР·РѕРІР°С‚РµР»СЋ
SELECT 
	u.email AS 'receiver email',
	u2.email AS 'sender email',
	m.*
FROM messages AS m
join users AS u ON u.id = m.to_user_id
join users AS u2 ON u2.id = m.from_user_id 
WHERE to_user_id = 1


-- РљРѕР»РёС‡РµСЃС‚РІРѕ РґСЂСѓР·РµР№ Сѓ РєР°Р¶РґРѕРіРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ
SELECT 
	count(*) AS cnt,
	u.id
FROM users AS u
JOIN friend_requests AS fr ON (
	u.id = fr.target_user_id OR u.id = fr.initiator_user_id 
)
WHERE fr.status = 'approved'
GROUP BY u.id
ORDER BY cnt DESC


-- Р’С‹Р±РѕСЂРєР° РЅРѕРІРѕСЃС‚РµР№ РґСЂСѓР·РµР№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ (users.id = 1)
SELECT *
FROM media AS m
join friend_requests AS fr ON (
	m.user_id = fr.initiator_user_id AND fr.target_user_id = 1
		OR 
	m.user_id = fr.target_user_id AND fr.initiator_user_id = 1
)
WHERE fr.status = 'approved'
ORDER BY created_at DESC
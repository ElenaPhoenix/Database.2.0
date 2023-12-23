/* Задача 1
Создать БД vk, исполнив скрипт _vk_db_creation.sql 
*/

/* Задача 2
Написать скрипт, добавляющий в созданную БД vk 2-3 новые таблицы (с перечнем полей, указанием индексов и внешних ключей) (CREATE TABLE)
*/
DROP TABLE IF EXISTS news;
CREATE TABLE news(
from_user_id BIGINT UNSIGNED NOT NULL,
to_user_id BIGINT UNSIGNED NOT NULL,
title_of_news VARCHAR(100),
body TEXT,
created_at DATETIME DEFAULT NOW()
);

DROP TABLE IF EXISTS games;
CREATE TABLE games(
id SERIAL,
user_id BIGINT UNSIGNED NOT NULL,
filename VARCHAR(255),
-- file BLOB,    	
size INT
);

DROP TABLE IF EXISTS photo_albums;
CREATE TABLE photo_albums(
id SERIAL,
user_id BIGINT UNSIGNED NOT NULL,
NAME VARCHAR(255),
FOREIGN KEY (user_id) references users (id)
);

DROP TABLE IF EXISTS photos;
CREATE TABLE photos(
id SERIAL,
album_id bigint unsigned,
media_id bigint unsigned NOT NULL,
FOREIGN KEY (album_id) REFERENCES photo_albums (id),
FOREIGN KEY (media_id) REFERENCES media (id)
);

DROP TABLE IF EXISTS cities;
CREATE TABLE cities(
id SERIAL,
name varchar (255) NOT NULL,
index (name)
);

#Добавим поле с идентификатором города
ALTER TABLE profiles
ADD COLUMN city_id BIGINT unsigned;

#Сделаем это поле внешним ключом
ALTER TABLE profiles ADD CONSTRAINT fk_profiles_city_id
FOREIGN KEY (city_id) REFERENCES cities (id);

/* Задача 3
Заполнить 2 таблицы БД vk данными (по 10 записей в каждой таблице) (INSERT)
*/
INSERT INTO `users` (`firstname`, `lastname`, `email`, `phone`) 
VALUES 
('Павел', 'Акутин', 'akutin_p89@yandex.ru', '9192291407'),
('Нина', 'Бурмак', 'nina.burmak@mail.ru', '9178263120'),
('Евгений', 'Власов', 'zhenyaaaa1309@gmail.ru', '9136605713'),
('Екатерина', 'Дацковская', 'd.cat1987@mail.ru', '9033285223'),
('Антон', 'Епифанов', 'tosha.dota@mail.ru', '9163485678'),
('Юлия', 'Заляднова', 'julie.mes@yandex.ru', '9132455465'),
('Сергей', 'Кривенко', 'krivenko.gym@gmail.ru', '9122457887'),
('Алена', 'Мусатова', 'musik2000@yandex.ru', '9061255845'),
('Дмитрий', 'Салаутин', 'satana.dimos@gmail.ru', '9133285447'),
('Екатерина', 'Теряева', 't.caterine@yandex.ru', '9083284554'),
('Юрий', 'Слободяник', 'u.fm@yandex.ru', '9271678990'),
('Евгений', 'Скориков', 'yevgen@ygmail.com', '9154675420');


INSERT INTO `profiles` (`user_id`, `gender`, `birthday`, `hometown`) 
VALUES 
('1', 'м', '1989-09-07', 'Пугачев'),
('2', 'ж', '1988-01-29', 'Саратов'),
('3', 'м', '1977-09-13', 'Энгельс'),
('4', 'ж', '1987-11-18', 'Хвалынск'),
('5', 'м', '1961-12-01', 'Барнаул'),
('6', 'ж', '2000-05-06', 'Выборг'),
('7', 'м', '1973-02-20', 'Омск'),
('8', 'ж', '1996-06-17', 'Киров'),
('9', 'м', '2007-08-15', 'Сахалин'),
('10', 'ж', '2003-11-26', 'Оханск'),
('11', 'м', '2015-03-12', 'Волгоград'),
('12', 'м', '2003-11-26', 'Бряск');

/* Задача 4.
Написать скрипт, отмечающий несовершеннолетних пользователей как неактивных (поле is_active = true). 
При необходимости предварительно добавить такое поле в таблицу profiles со значением по умолчанию = false (или 0) (ALTER TABLE + UPDATE) */
ALTER TABLE vk.profiles
ADD COLUMN is_active BIT DEFAULT 1;

UPDATE profiles
SET is_active = 0
WHERE (birthday+INTERVAL 18 YEAR) > NOW();

#Проверка неактивных
SELECT *
FROM profiles
WHERE is_active = 0
ORDER BY birthday;

/* Задача 5. 
Написать скрипт, удаляющий сообщения «из будущего» (дата позже сегодняшней) (DELETE) */
ALTER TABLE messages
ADD COLUMN is_deleted BIT DEFAULT 0;

#Отметим пару сообщений неправильной датой
update messages
set created_at = now() + interval 1 year
limit 2;

 #Отметим, как удаленные, сообщения "из будущего"
UPDATE messages
SET is_deleted = 1
WHERE created_at > now();

/*
-- физически удалим сообщения "из будущего"
delete from messages
where created_at > NOW()
*/

-- проверим
select *
from messages
order by created_at desc;

-- Функции
-- Рассчитываем коэффициент популярности пользователя, по процедурному пути (шаг за шагом). Чаще используются для вычеслений
CREATE FUNCTION vk.func_friendship_direction(check_user_id BIGINT unsigned)
returns float reads sql data
begin
	declare requests_to_user INT; -- объявляем переменные
	declare requests_from_user INT;

	set requests_to_user = ( -- присваиваем переменным значения
	select count(*)
	from friend_requests
	where target_user_id = check_user_id
	);
	
	/* set requests_from_user = ( -- присваиваем переменным значения
	select count(*)
	from friend_requests
	where initiator_user_id = check_user_id
	);
	*/
-- или в стиле SQL
	select count(*)
	into requests_from_user
	from friend_requests
	where initiator_user_id = check_user_id;

	return requests_to_user / requests_from_user; -- функция должна возвращать результат
end

select round(func_friendship_direction(1),2) as 'user_popularity'; -- внутри другого выражения можно вызывать только функцию


/*
Напишем функцию, которая будет считать коэффициент направленности дружбы.
Формула: Кол-во приглашений в друзья к пользователю / (разделим на)  Кол-во заявок в друзья от пользователя.

Из результата (которым будет некоторое вещественное число) можно будет делать некоторые выводы:
1.	Чем больше значение, тем популярность пользователя выше.
2.	Если значение меньше единицы - пользователь инициатор связей (и наоборот).

•	Решим задачу в процедурном стиле 
•	Наша функция будет только читать данные => READS SQL DATA

Направленность дружбы
Кол-во приглашений в друзья к пользователю
/
Кол-во приглашений в друзья от пользователя

Чем больше - популярность выше
Если значение меньше единицы - пользователь инициатор связей.
*/

USE vk;

DROP FUNCTION IF EXISTS func_friendship_direction;

DELIMITER // -- выставим разделитель
CREATE FUNCTION func_friendship_direction(check_user_id BIGINT UNSIGNED)
RETURNS FLOAT READS SQL DATA
  BEGIN
-- объявим переменные
    DECLARE requests_to_user INT;
    DECLARE requests_from_user INT;
    DECLARE `_result` FLOAT;
    
-- получим запросы к пользователю
    SET requests_to_user = (
    	  SELECT COUNT(*) 
    	  FROM friend_requests
    	  WHERE target_user_id = check_user_id);

/*	set requests_from_user = (
		select count(*)
		from vk.friend_requests 
		where initiator_user_id = check_user_id
	);*/
    
-- получим запросы от пользователя
    SELECT COUNT(*)
    INTO requests_from_user 
    FROM friend_requests
    WHERE initiator_user_id = check_user_id;
	
	if requests_from_user > 0 then 
		set `_result` = requests_to_user / requests_from_user;
	else 
		set `_result` = 99999;
	end if;

-- разделим первое на второе и вернем результат
    RETURN `_result`;
  END// -- не забываем наш новый разделитель
DELIMITER ; -- вернем прежний разделитель


-- Вызов функции / результаты
SELECT func_friendship_direction(1);
 

-- Округлим результат с помощью функции TRUNCATE
SELECT ROUND(vk.friendship_direction(11), 2) as user_popularity;
-- Посчитаем результат для другого пользоваетля (id = 11)
SELECT ROUND(friendship_direction(11), 2);
 

-- Транзакции - механизм в реляционных субд, который гарантирует нам, что набор команд будет исполнен полностью или не исполнен совсем
-- Транзакция по добавлению нового пользователя      
START TRANSACTION;
	INSERT INTO users (firstname, lastname, email, phone)
  	VALUES ('New', 'User', 'new@mail.com', 454545456);

	# SELECT @last_user_id := (SELECT MAX(id) FROM users); -- опасный способ
  	set @last_user_id = LAST_INSERT_ID(); -- LAST_INSERT_ID() функция всегда вернет номер записей после последней команды insert в текущей сессии
	
  	INSERT INTO profiles (user_id, gender, birthday, hometown)
  	VALUES (@last_user_id, 'M', '1999-10-10', 'Moscow');  
COMMIT;
# ROLLBACK; -- если не хотим фиксировать и нужно откатить
 

-- проверить
SELECT * FROM users ORDER BY id DESC;	
SELECT * FROM profiles ORDER BY user_id DESC;	


-- обработка ошибки в транзакции. Для этого оборачиваем транзакцию в процедуру
DROP PROCEDURE IF EXISTS `sp_add_user`;

DELIMITER $$

CREATE PROCEDURE `sp_add_user`(firstname varchar(100), lastname varchar(100), 
	email varchar(100), phone varchar(12), hometown varchar(50), photo_id INT, 
	OUT tran_result varchar(200))
BEGIN
    DECLARE `_rollback` BOOL DEFAULT 0;
   	DECLARE code varchar(100);
   	DECLARE error_string varchar(100);
   	DECLARE last_user_id int;

   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
   begin
    	SET `_rollback` = 1;
	GET stacked DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
    	set tran_result := concat('Error occured. Code: ', code, '. Text: ', error_string);
    end;
		        
    START TRANSACTION;
		INSERT INTO users (firstname, lastname, email, phone)
		  VALUES (firstname, lastname, email, phone);
	
		INSERT INTO profiles (user_id, hometown, photo_id)
		  VALUES (last_insert_id(), hometown, photo_id); 
	
	    IF `_rollback` THEN
	       ROLLBACK;
	    ELSE
		set tran_result := 'ok';
	       COMMIT;
	    END IF;
END$$

DELIMITER ;
-- вызываем процедуру
call sp_add_user('New', 'User', 'new87@mail.com', 454545456, 'Moscow', 1, @tran_result);

-- смотрим результат
select @tran_result;

-- удалить пользователя можно, удалив все его данные. Сначала удаляем записи в зависимых таблицах, потом в главных
start transaction;
	set @user_id = 101;
	
	delete from messages where from_user_id or to_user_id = @user_id;

	delete from media 
	where user_id = @user_id;

	delete from profiles 
	where user_id = @user_id;

	delete from users 
	where id = @user_id;
commit;


-- Триггеры - возможность подписаться на какое-то событие в жизни таблицы. События insert, update, delete. подписаться до или после наступления события. Можно выставить последовательность тригеров
 
-- триггер для проверки возраста пользователя перед обновлением
drop TRIGGER if exists check_user_age_before_update;

DELIMITER //

CREATE TRIGGER check_user_age_before_update 
BEFORE UPDATE ON profiles
FOR EACH ROW
begin
    IF NEW.birthday >= CURRENT_DATE() then -- переменная new содержит новые пришедшие данные, переменная old содержит старые хранящиеся данные
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Обновление отменено. Дата рождения должна быть в прошлом.';
    END IF;
END//

DELIMITER ;

-- триггер для корректировки возраста пользователя при вставке новых строк

DROP TRIGGER IF EXISTS check_user_age_before_insert;

DELIMITER //

CREATE TRIGGER check_user_age_before_insert 
BEFORE INSERT ON profiles
FOR EACH ROW
begin
    IF NEW.birthday > CURRENT_DATE() THEN
        SET NEW.birthday = CURRENT_DATE(); -- вставляем сегодняшнюю дату
    END IF;
END//

DELIMITER ;

-- проверяем
select *
from profiles p 
where user_id = 1;

update profiles 
set birthday = '2000.10.10'
where user_id = 1;

----------------
delete from vk.profiles 
where user_id = 100;

insert into vk.profiles 
(user_id, gender, birthday, photo_id, hometown)
values(100, 'f', '2030.10.10', 1, 'Moscow');

select *
from profiles p 
where user_id = 100;

-- Минусы триггеров: триггеры нельзя отладить, они не очевидны (про них часто забывают), вносят элементы бизнес-логики. Может сложиться последовательность ситуаций, когда триггер не сработает


-- Циклы 
-- REPEAT-UNTIL
-- Цикл с постуслоием

DROP PROCEDURE IF EXISTS repeat_loop_example;

DELIMITER //

CREATE PROCEDURE repeat_loop_example(start_point INT)
BEGIN
  DECLARE x INT;
  DECLARE str VARCHAR(255);
  SET x = start_point;
  SET str = '';

  repeat -- цикл с постусловием
    SET str = CONCAT(str,x,',');
    SET x = x - 1;
    UNTIL x <= 0
  END REPEAT;

  SELECT str;
END//

DELIMITER ; 

-- вызов процедуры с циклом
CALL repeat_loop_example(10); 

 

-- WHILE-DO
-- Цикл с предусловием

DROP PROCEDURE IF EXISTS while_loop_example;

DELIMITER //

CREATE PROCEDURE while_loop_example(start_point INT)
BEGIN
  DECLARE x INT;
  DECLARE str VARCHAR(255);
  SET x = start_point;
  SET str = '';

  WHILE x > 0 DO -- цикл с предусловием, сначала проверяем условие потом заходим в тело цикла. возможна ситуация, когда цикл мы ни разу не исполним
    SET str = CONCAT(str,x,',');
    SET x = x - 1;
  END WHILE;
 
  SELECT str;
END//

DELIMITER ;


-- вызов процедуры с циклом
CALL while_loop_example(10);


/* Задача 1
Написать функцию, которая удаляет всю информацию об указанном пользователе из БД vk. Пользователь задается по id. 
Удалить нужно все сообщения, лайки, медиа записи, профиль и запись из таблицы users. 
Функция должна возвращать номер пользователя.
 */
drop function if exists func_del_user;
DELIMITER //

create function func_del_user (del_user_id INT)
returns INT reads sql data

BEGIN

    delete from likes
	where likes.user_id = del_user_id;
    
    delete from users_communities
	where
	users_communities.user_id = del_user_id;
    
    delete from messages
	where messages.to_user_id = del_user_id
	or messages.from_user_id = del_user_id;
    
    delete from friend_requests
	where friend_requests.initiator_user_id = del_user_id
	or friend_requests.target_user_id = del_user_id;
    
    delete likes
	from media
	join likes on likes.media_id = media.id
	where media.user_id = del_user_id;
    
    update profiles
	join media on profiles.photo_id = media.id
    set profiles.photo_id = null
	where media.user_id = del_user_id;

    delete from media
	where media.user_id = del_user_id;
    
    delete from profiles
	where profiles.user_id = del_user_id;
    
    delete from users
	where users.id = del_user_id;
    
    return del_user_id;

END; //
DELIMITER ;

select func_del_user(7) as del_user_id;



/*Задача 2
Предыдущую задачу решить с помощью процедуры и обернуть используемые команды в транзакцию внутри процедуры.
*/
DROP PROCEDURE IF exists vk.proc_del_user;
DELIMITER //
CREATE PROCEDURE vk.proc_del_user(in del_user_id INT)
begin
	DECLARE EXIT HANDLER FOR sqlexception -- для перехвата любых исключений SQL, возникающих в транзакции. Если исключение перехвачено, транзакция откатывается с помощью инструкции ROLLBACK
	begin
		rollback;
	end;
	
	start transaction;

	delete from likes 
	where likes.user_id = del_user_id; -- удалить все лайки пользователя
	
	delete from messages 
	where messages.from_user_id = del_user_id or messages.to_user_id = del_user_id; -- удалить все сообщения пользователя

	DELETE FROM friend_requests
	WHERE friend_requests.initiator_user_id = del_user_id OR friend_requests.target_user_id = del_user_id;
	
	delete
	likes
from
	media
join likes on
	likes.media_id = media.id
where
	media.user_id = del_user_id;
    
		UPDATE profiles
		  JOIN media ON profiles.photo_id = media.id
		   SET profiles.photo_id = NULL
		 WHERE media.user_id = del_user_id; 

		DELETE FROM media
		 WHERE media.user_id = del_user_id;
    
		DELETE FROM profiles
		 WHERE profiles.user_id = del_user_id;
    
		DELETE FROM users
		 WHERE users.id = del_user_id;
         
	COMMIT;

END; //

DELIMITER ;

CALL proc_del_user(5);

/* Задача 3
 Написать триггер, который проверяет новое появляющееся сообщество. Длина названия сообщества (поле name) должна быть не менее 5 символов. 
 Если требование не выполнено, то выбрасывать исключение с пояснением.
*/
DROP TRIGGER IF EXISTS tr_com_name;

DELIMITER //

CREATE TRIGGER tr_com_name BEFORE INSERT ON Communities 
FOR EACH ROW BEGIN
   IF (LENGTH(new.name) < 5) THEN
       SIGNAL SQLSTATE '45000'
	   SET MESSAGE_TEXT = 'Длина названия сообщества должна быть не менее 5 символов';
       INSERT INTO tr_com_name_exception_table VALUES();
   END IF; 
END; // 

DELIMITER ;

/* Тест триггера */

INSERT INTO Communities
VALUES (55, 'wow');

INSERT INTO Communities
VALUES (56, 'wooow');

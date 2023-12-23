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

END; 
DELIMITER ;
CALL proc_del_user(3);


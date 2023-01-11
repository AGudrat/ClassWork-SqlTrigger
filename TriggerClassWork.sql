CREATE DATABASE SQLTrigger
use SQLTrigger
CREATE TABLE Users(
	Id int Identity(1,1) PRIMARY KEY NOT NULL,
	UserName nvarchar(200) NOT NULL,
	Password nvarchar(200) NOT NULL,
	Mail nvarchar(200) NOT NULL
)

CREATE TABLE Posts(
	Id int Identity(1,1) PRIMARY KEY NOT NULL,
	Content nvarchar(200) NOT NULL,
	UserId int FOREIGN KEY REFERENCES Users(Id),
	LikeCount int  DEFAULT(0),
	IsDeleted BIT DEFAULT(1),
	CreatedDate DATETIME DEFAULT(GETDATE()),
	UpdatedDate DATETIME NULL	
)



CREATE TABLE Comments(
	Id int Identity(1,1) PRIMARY KEY NOT NULL,
	UserId int FOREIGN KEY REFERENCES Users(Id),
	PostId int FOREIGN KEY REFERENCES Posts(Id),
	LikeCount int DEFAULT(0),
	IsDeleted BIT DEFAULT(1),
	CreatedDate DATETIME DEFAULT(GETDATE()),
	UpdatedDate DATETIME NULL	
)
INSERT Users values('TestUserName','mystrongpassword', 'isim@soyisim.com')
INSERT Users values('TestUserName2','mystrongpassword', 'isim2@soyisim.com')
INSERT Posts (Content,UserId,LikeCount) values('TestPost', 1,10)
INSERT Posts (Content,UserId,LikeCount) values('TestPost1', 2,12)
INSERT Comments(UserId,PostId,LikeCount) values(2, 2,5)
SELECT * from Posts
SELECT * from Users


--Postlara gələn comment sayların göstərin
SELECT P.Id,COUNT(C.PostId) as Count FROM Posts as P join Comments as C  on C.PostId = P.Id GROUP BY P.Id

--Rəyi və ya paylaşımı silən zaman silinməsi əvəzinə IsDeleted dəyəri true olsun
--CREATE TRIGGER DeleteComment
--on Comments
--INSTEAD OF DELETE
--as
--	begin
--		DECLARE @commentId int
--		select @commentId = deleted.Id from deleted
--		UPDATE Comments SET IsDeleted = 0 WHERE Comments.Id = @commentId
--		print 'Comment Uğurla silindi.'
--	end

	
--create or alter TRIGGER DeletePost
--on Posts
--INSTEAD OF DELETE
--as
--	begin
--		DECLARE @postId int
--		select @postId = deleted.Id from deleted
--		UPDATE Posts SET IsDeleted = 0 WHERE Posts.Id = @postId
--		UPDATE Comments SET IsDeleted = 0  where Comments.PostId = @postId
--		print 'Post Uğurla silindi.'
--	end

--Rəy və ya paylaşım insert edərkən CreatedDate yarandığı zaman görünəcək, update edərkən UpdatedDate yeniləndiyi zamanın vaxtı görünəcək

Create or Alter TRIGGER OperationsComments
ON Comments
INSTEAD OF UPDATE, INSERT , DELETE
AS
BEGIN
	DECLARE @commentId int
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        IF EXISTS (SELECT * FROM deleted)
        BEGIN
			SET @commentId = (SELECT Id from inserted)
			UPDATE Comments SET UpdatedDate = GETDATE() WHERE Comments.Id = @commentId
            PRINT ('Guncellendi')
        END
        ELSE
        BEGIN
			SELECT @commentId = Id from inserted
			UPDATE Comments SET CreatedDate = GETDATE() WHERE Comments.Id = @commentId
            PRINT ('Ekleme işlemi yapılmıştır')
        END
    END
	ELSE
	BEGIN
		begin
		select @commentId = deleted.Id from deleted
		UPDATE Comments SET IsDeleted = 0 WHERE Comments.Id = @commentId
		print 'Comment Uğurla silindi.'
	end
	END
END



Create or Alter TRIGGER OperationspRoducts
ON Posts
INSTEAD OF UPDATE, INSERT , DELETE
AS
BEGIN
	DECLARE @postId int
    IF EXISTS (SELECT * FROM inserted)
		BEGIN
			IF EXISTS (SELECT * FROM deleted)
				BEGIN
					SELECT @postId = Id from inserted
					UPDATE Posts SET Posts.UpdatedDate = GETDATE() WHERE Posts.Id = @postId
					PRINT ('Guncellendi')
				END
			ELSE
				BEGIN
					SELECT @postId = Id from inserted
					UPDATE Posts SET CreatedDate = GETDATE() WHERE Posts.Id = @postId
					PRINT ('Ekleme işlemi yapılmıştır')
				END
		END
	ELSE
		BEGIN
			select @postId = deleted.Id from deleted
			UPDATE Posts SET IsDeleted = 0 WHERE Posts.Id = @postId
			UPDATE Comments SET IsDeleted = 0  where Comments.PostId = @postId
			print 'Post Uğurla silindi.'
		END
END


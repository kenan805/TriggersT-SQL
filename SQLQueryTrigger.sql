--Triggers. DB Library
 
--Implement triggers in such a way that the following requirements are met.
--Triggerləri elə yerinə yetirin ki növbəti istəklər yerinə yetsin.

--(!) Please note that the first 3 items pertain to the issuance of books to students and teachers.
--(!) Zəhmət olmasa nəzərə alın ki ilk 3 tapışırıq , həm tələbələrə həm müəllimlərə aiddir

--1. It was impossible to issue a book, which is no longer in the library (in quantity).
--1. Kitabxanada olmayan kitabları , kitabxanadan götürmək olmaz.
CREATE TRIGGER NotTakeBooksStd
ON S_Cards
AFTER INSERT
AS
BEGIN 
	DECLARE @quantity int 
	SELECT @quantity = Quantity 
	FROM inserted INNER JOIN Books 
	ON inserted.Id_Book = Books.Id
	IF @quantity = 0
	BEGIN
		PRINT 'This book is not in the library.'
		ROLLBACK TRAN
	END
END

CREATE TRIGGER NotTakeBooksTch
ON T_Cards
AFTER INSERT
AS
BEGIN 
	DECLARE @quantity int 
	SELECT @quantity = Quantity 
	FROM inserted INNER JOIN Books 
	ON inserted.Id_Book = Books.Id
	IF @quantity = 0
	BEGIN
		PRINT 'This book is not in the library.'
		ROLLBACK TRAN
	END
END

INSERT INTO S_Cards VALUES(105, 9, 14, GETDATE(), NULL, 2)
INSERT INTO T_Cards VALUES(9, 2, 14, GETDATE(), NULL, 1)

--2. When you return a certain book, its quantity should increase.
--2. Müəyyən kitabı qaytardıqda, onun Quantity-si (sayı) artmalıdır.
CREATE TRIGGER QuantityIncreaseStd
ON S_Cards
AFTER UPDATE
AS
BEGIN
	DECLARE @dateIn datetime
	DECLARE @idBook datetime
	SELECT @dateIn = DateIn, @idBook = Id_Book FROM inserted
	IF(@dateIn IS NOT NULL)
	BEGIN
		UPDATE Books
		SET Books.Quantity += 1
		WHERE Id = @idBook
	END
END

CREATE TRIGGER QuantityIncreaseTch
ON T_Cards
AFTER UPDATE
AS
BEGIN
	DECLARE @dateIn datetime
	DECLARE @idBook datetime
	SELECT @dateIn = DateIn, @idBook = Id_Book FROM inserted
	IF(@dateIn IS NOT NULL)
	BEGIN
		UPDATE Books
		SET Books.Quantity += 1
		WHERE Id = @idBook
	END
END

UPDATE S_Cards
SET DateIn = GETDATE()
WHERE Id = 2

UPDATE T_Cards
SET DateIn = CONVERT(date, GETDATE())
WHERE Id = 3

--3. When issuing a book, its quantity should decrease.
--3. Kitab kitabxanadan verildikdə onun sayı azalmalıdır.
CREATE TRIGGER TakeBooksStd
ON S_Cards
AFTER INSERT
AS
BEGIN 
	DECLARE @idBook int 
	SELECT @idBook = Id_Book FROM inserted 

	UPDATE Books
	SET Quantity -= 1
	WHERE Books.Id = @idBook
	
END

CREATE TRIGGER TakeBooksTch
ON T_Cards
AFTER INSERT
AS
BEGIN 
	DECLARE @idBook int 
	SELECT @idBook = Id_Book FROM inserted 

	UPDATE Books
	SET Quantity -= 1
	WHERE Books.Id = @idBook
	
END

INSERT INTO S_Cards VALUES(106, 3, 1, CONVERT(date, GETDATE()), NULL, 1)
INSERT INTO T_Cards VALUES(10, 3, 12, CONVERT(date, GETDATE()), NULL, 2)

--4. You can not give more than three books to one student in his arms.
--4. Bir tələbə artıq 3 kitab götütürübsə ona yeni kitab vermək olmaz.
ALTER TRIGGER MaxTakeBooksStd
ON S_Cards
AFTER INSERT
AS
BEGIN
	DECLARE @bookCount int
	DECLARE @idStd int
	SELECT @idStd = Id_Student FROM inserted
	
	SELECT @bookCount = COUNT(*) FROM S_Cards
	WHERE Id_Student = @idStd
	

	IF(@bookCount > 3)
	BEGIN
		PRINT 'A student can take a maximum of 3 books!'
		ROLLBACK TRAN
	END
END

INSERT INTO S_Cards VALUES(20, 2, 9, CONVERT(date, GETDATE()), NULL, 2)

--5. You can not issue a new book to a student, if he now read at least one book for more than 2 months.
--5. Əgər tələbə bir kitabı 2aydan çoxdur oxuyursa, bu halda tələbəyə yeni kitab vermək olmaz.
CREATE TRIGGER NotTakeBooksMorethanTwoMonths
ON S_Cards
AFTER INSERT
AS
BEGIN
	DECLARE @idStd int
	SELECT @idStd = Id_Student FROM inserted

	IF EXISTS(SELECT * FROM S_Cards INNER JOIN Books 
	          ON Books.Id = S_Cards.Id
			  WHERE Id_Student = @idStd AND DateIn IS NULL AND DATEDIFF(MONTH,DateOut,CONVERT(date,GETDATE())) > 2)
	BEGIN
		PRINT 'The book has been with you for more than 2 months. Thats why you cant be given a book right now!'
		ROLLBACK TRAN
	END

END

INSERT INTO S_Cards VALUES(30, 16, 9, CONVERT(date, GETDATE()), NULL, 2)

--6. When you delete a book, data about it must be copied to the LibDeleted table.
--6. Kitabı bazadan sildikdə, onun haqqında data LibDeleted cədvəlinə köçürülməlidir.
CREATE TRIGGER DeleteBooks
ON Books
AFTER DELETE
AS
BEGIN
	DECLARE @LibDeleted TABLE(Id int, [Name] nvarchar(30), Pages int, YearPress int, Id_Themes int, Id_Category int, Id_Author int, Id_Press int, Comment nvarchar(30), Quantity int)
	
	INSERT @LibDeleted
	SELECT Id, [Name], Pages, YearPress, Id_Themes, Id_Category, Id_Author, Id_Press, Comment, Quantity FROM deleted
END

DELETE Books
WHERE [Name] = 'WCF, Part 1'






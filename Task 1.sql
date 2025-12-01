-- Task 1
CREATE DATABASE Project;
USE Project;

-- Database Creation
-- a, Books table
CREATE TABLE Books(BOOK_ID int Primary Key,
TITLE Varchar(255),
AUTHOR Varchar(255),
Genre Varchar(255),
YEAR_PUBLISHED YEAR,
AVAILABLE_COPIES int);


-- b, Members table
CREATE TABLE Members(MEMBER_ID int Primary Key,
NAME Varchar(255),
EMAIL Varchar(255),
PHONE_NO Varchar(255),
ADDRESS Varchar(255),
MEMBERSHIP_DATE date);

-- c, BorrowingRecords table
CREATE TABLE BorrowingRecords(BORROW_ID int Primary Key,
MEMBER_ID int,
Foreign key (MEMBER_ID) REFERENCES Members(MEMBER_ID),
BOOK_ID int,
Foreign key (BOOK_ID) REFERENCES Books(BOOK_ID),
BORROW_DATE date,
RETURN_DATE date);

-- Data Creation
INSERT INTO Books (BOOK_ID, TITLE, AUTHOR, Genre, YEAR_PUBLISHED, AVAILABLE_COPIES) VALUES
(1, 'To Kill a Mockingbird', 'Harper Lee', 'Fiction', 1960, 5),
(2, '1984', 'George Orwell', 'Dystopian', 1949, 3),
(3, 'The Great Gatsby', 'F. Scott Fitzgerald', 'Classic', 1925, 4),
(4, 'Pride and Prejudice', 'Jane Austen', 'Romance', 1913, 2),
(5, 'The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 1937, 6),
(6, 'The Catcher in the Rye', 'J.D. Salinger', 'Fiction', 1951, 3),
(7, 'Moby-Dick', 'Herman Melville', 'Adventure', 1951, 1);


INSERT INTO Members (MEMBER_ID, NAME, EMAIL, PHONE_NO, ADDRESS, MEMBERSHIP_DATE) VALUES
(1, 'Aarav Sharma', 'aarav.sharma@example.com', '9876543210', 'Delhi, India', '2022-01-15'),
(2, 'Priya Nair', 'priya.nair@example.com', '9123456780', 'Kochi, Kerala', '2022-03-22'),
(3, 'Rohit Verma', 'rohit.verma@example.com', '9988776655', 'Kanpur, Uttar Pradesh', '2022-05-10'),
(4, 'Sneha Iyer', 'sneha.iyer@example.com', '9090908080', 'Chennai, Tamil Nadu', '2022-07-08'),
(5, 'Arjun Singh', 'arjun.singh@example.com', '9811122233', 'Jaipur, Rajasthan', '2022-09-19'),
(6, 'Kavya Reddy', 'kavya.reddy@example.com', '9000090000', 'Hyderabad, Telangana', '2022-11-25'),
(7, 'Vikram Patel', 'vikram.patel@example.com', '9877001122', 'Ahmedabad, Gujarat', '2023-02-03');

INSERT INTO BorrowingRecords (BORROW_ID, MEMBER_ID, BOOK_ID, BORROW_DATE, RETURN_DATE) VALUES
(1, 1, 3, '2023-01-10', '2023-01-20'),   -- Aarav borrowed The Great Gatsby
(2, 2, 5, '2023-02-15', '2023-02-28'),   -- Priya borrowed The Hobbit
(3, 3, 1, '2023-03-05', '2023-03-18'),   -- Rohit borrowed To Kill a Mockingbird
(4, 4, 2, '2023-04-12', '2023-04-25'),   -- Sneha borrowed 1984
(5, 5, 7, '2023-05-20', NULL),           -- Arjun borrowed Moby-Dick (not yet returned)
(6, 6, 4, '2023-06-01', '2023-06-14'),   -- Kavya borrowed Pride and Prejudice
(7, 7, 6, '2023-07-18', NULL); 

-- Information Retrieval:
-- a, Retrieve a list of books borrowed by specific member
SELECT B.BOOK_ID, B.TITLE FROM Books B JOIN BorrowingRecords BR on B.BOOK_ID=BR.BOOK_ID;

-- b, Find members who have overdue books
SELECT BR.BORROW_ID, BR.MEMBER_ID, M.NAME, B.TITLE, BR.BORROW_DATE, BR.RETURN_DATE FROM
BorrowingRecords BR JOIN Members M ON BR.MEMBER_ID = M.MEMBER_ID
JOIN Books B ON BR.BOOK_ID = B.BOOK_ID
WHERE BR.RETURN_DATE IS NULL
AND BR.BORROW_DATE < DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- c, Retrieve books by genre along with the count of all available copies
SELECT  Genre, SUM(AVAILABLE_COPIES) as total_count 
FROM Books GROUP BY Genre;

-- d, Find the most borrowed books overall
SELECT 
b.BOOK_ID,
b.TITLE,
b.AUTHOR,
COUNT(br.BOOK_ID) AS borrow_count
FROM BorrowingRecords br
JOIN Books b ON br.BOOK_ID = b.BOOK_ID
GROUP BY b.BOOK_ID, b.TITLE, b.AUTHOR
HAVING COUNT(br.BOOK_ID) =(SELECT MAX(borrow_times)
FROM (SELECT COUNT(BR.BOOK_ID) AS borrow_times
FROM BorrowingRecords BR
GROUP BY BR.BOOK_ID) AS counts);

-- e, Retrieve members who have borrowed books from at least three different genres
SELECT 
br.MEMBER_ID,
m.NAME,
COUNT(DISTINCT b.Genre) AS total_genres_borrowed
FROM BorrowingRecords br
JOIN Books b ON br.BOOK_ID = b.BOOK_ID
JOIN Members m ON br.MEMBER_ID = m.MEMBER_ID
GROUP BY br.MEMBER_ID, m.NAME
HAVING COUNT(DISTINCT b.Genre) >= 3;

-- Reporting and Analytics:
-- a, Calcualte the total number of books borrowed per month
SELECT DATE_FORMAT(BORROW_DATE, '%Y-%m') AS Month, Count(*) FROM BorrowingRecords GROUP BY Month;

-- b, Find the top three most active members based on number of books borrowed
SELECT br.MEMBER_ID, m.NAME, COUNT(br.BORROW_ID) as total FROM
BorrowingRecords br JOIN Members m
ON br.MEMBER_ID = m.MEMBER_ID
GROUP BY br.MEMBER_ID, m.NAME
ORDER BY total desc limit 3;

-- c, Retrieve authors whose books have been borrowed at least 10 times
SELECT 
    b.AUTHOR,
    COUNT(br.BORROW_ID) AS Total
FROM Books b
JOIN BorrowingRecords br
    ON b.BOOK_ID = br.BOOK_ID
GROUP BY b.AUTHOR
HAVING COUNT(br.BORROW_ID) >= 10;

-- d, Identify members who have never borrowed a book
SELECT br.MEMBER_ID, m.NAME FROM BorrowingRecords br JOIN
Members m ON br.MEMBER_ID = m.MEMBER_ID
WHERE br.MEMBER_ID IS NULL;

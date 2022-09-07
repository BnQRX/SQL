/*�������� ������� book*/
CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT, 
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id) ON DELETE SET NULL
);

/*���������� ������*/
INSERT INTO book (title, author_id,genre_id,price,amount)
VALUES ('������������� � �����',3,2,650.00,15),('������ �������',3,2,570.20,6),('������',4,2,518.99,2);
SELECT * FROM book;

/*���������� � ������ ������ �������� �������� ���� ������� ������ � ������� 2020 ����. 
���� ���������� �������� ������� ��������� �������. ������� ������, ������� ������� �����,
������ � ���� ���������� ��������. ��������� ������� ������� ����. ���������� �������, ������������ 
������� � ���������� ������� �� ��������� �������, � ����� �� �������� ��� ���������� ��������.*/
SELECT name_city, name_author, (DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 365) DAY)) AS '����'
FROM city, author
ORDER BY name_city, ���� DESC;

/*��������� ���������� �����������  ���� ������� ������ �� ������� author.  ������� ��� �������,  ���������� ���� ������� ������ 10,
� ��������������� �� ����������� ���������� ����. ��������� ������� ������� ����������*/
SELECT name_author, SUM(amount) AS '����������'
FROM author
     LEFT JOIN book ON author.author_id=book.author_id
GROUP BY name_author
HAVING SUM(book.amount)<10 OR SUM(book.amount) IS NULL
ORDER BY ����������;

/*������� ���������� � ������ (�������� �����, ������� � �������� ������, �������� �����, ���� � ���������� ����������� ����), 
���������� � ����� ���������� ������, � ��������������� � ���������� ������� �� �������� ���� ����. ����� ���������� ������� ����, 
����� ���������� ����������� ���� �������� �� ������ �����������.*/
SELECT title, name_author, name_genre, price, amount
FROM book
    JOIN author ON author.author_id=book.author_id
    JOIN genre ON genre.genre_id=book.genre_id
WHERE genre.genre_id IN
     (SELECT coun_genre.genre_id
          FROM
              (SELECT genre_id, sum(amount) AS sum_amount
                FROM book
                GROUP BY genre_id) AS coun_genre
          JOIN
              (SELECT genre_id, sum(amount) AS sum_amount
                FROM book
                GROUP BY genre_id
                ORDER BY sum_amount DESC
                LIMIT 1) AS top1
          ON coun_genre.sum_amount=top1.sum_amount)
ORDER BY book.title;

/*��� ����, ������� ��� ���� �� ������ (� ������� book), �� �� ������ ����, ��� � �������� (supply), 
���������� � ������� book ��������� ���������� �� ��������, ��������� � ��������,  � ����������� ����. � � �������  
supply �������� ���������� ���� ����.*/
UPDATE book
    JOIN author USING (author_id)
    JOIN supply ON book.title = supply.title AND author.name_author=supply.author
SET book.amount=book.amount+supply.amount, book.price = 
((book.price*book.amount+supply.price*supply.amount)/(book.amount+supply.amount)), supply.amount = 0
WHERE book.price <> supply.price;

/*������� ��� �����, � ������� ��������� ������ 4-� ����. � ������� book ��� ���� ������ ���������� �������� Null.*/
DELETE FROM genre
WHERE genre_id IN 
                (SELECT genre_id
                 FROM book
                 GROUP BY genre_id
                 HAVING count(DISTINCT book_id)<4);
SELECT*FROM genre;

/*������� ��� ������ �������� ����� (id ������, ����� �����, �� ����� ���� � � ����� ���������� �� �������) 
� ��������������� �� ������ ������ � ��������� ���� ����.*/
SELECT buy.buy_id, book.title, book.price, buy_book.amount
FROM buy
    JOIN client ON buy.client_id=client.client_id
    JOIN buy_book ON buy.buy_id = buy_book.buy_id
    JOIN book ON buy_book.book_id=book.book_id
WHERE name_client = '������� �����'
ORDER BY buy.buy_id, book.title;

/*���������, ������� ��� ���� �������� ������ �����, ��� ����� ������� �� ������ (����� ���������, � ����� ���������� 
������� ���������� ������ �����).  ������� ������� � �������� ������, �������� �����, ��������� ������� ������� ����������.
��������� ������������� �������  �� �������� �������, � ����� �� ��������� ����.*/
SELECT author.name_author, book.title,
COUNT(buy_book_id) AS '����������'
FROM book
      INNER JOIN author ON book.author_id = author.author_id
      LEFT JOIN buy_book ON book.book_id = buy_book.book_id
GROUP BY book.title,author.name_author
ORDER BY author.name_author, book.title;

/*������� ���� (��� �����), � ������� ���� �������� ������ ����� ����������� ����, ������� ��� ���������� . ��������� ������� ������� ����������.*/
SELECT genre.name_genre,
(
	SELECT max(pek.sum1) as 'maxzn'
	FROM (
		SELECT book.genre_id, Sum(buy_book.amount) as sum1
		FROM book
			JOIN buy_book on book.book_id=buy_book.book_id
		Group by book.genre_id) sum1
) as '����������'
FROM genre
     Join book ON genre.genre_id=book.genre_id
     Join buy_book ON book.book_id=buy_book.book_id
GROUP BY genre.genre_id
HAVING Sum(buy_book.amount)=(
							SELECT max(max_sum.sum2)
							FROM (
								SELECT book.genre_id, Sum(buy_book.amount) as sum2
								FROM book
									Join buy_book on book.book_id=buy_book.book_id
									GROUP BY book.genre_id) max_sum
							);
/*������� ����������� ������� �� ������� ���� �� ������� � ���������� ����. ��� ����� ������� ���, �����, ����� ������� � ��������������� 
������� �� ����������� �������, ����� �� ����������� ��� ����. �������� ��������: ���, �����, �����.*/
SELECT year(buy_step.date_step_end) AS '���', monthname(buy_step.date_step_end) AS '�����', sum(book.price*buy_book.amount) AS'�����'
FROM buy_step
    JOIN buy_book USING (buy_id)
    JOIN book USING (book_id)
    JOIN step USING (step_id)
GROUP BY �����, ���, buy_step.step_id
HAVING ����� IS NOT NULL AND buy_step.step_id=1
UNION
SELECT year(date_payment) AS '���', monthname(date_payment) AS '�����', sum(price*amount) AS'�����'
FROM buy_archive
GROUP BY �����, ���
HAVING ����� IS NOT NULL
ORDER BY �����, ���;

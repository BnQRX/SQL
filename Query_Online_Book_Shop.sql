/*Создание таблицы book*/
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

/*Добавление данных*/
INSERT INTO book (title, author_id,genre_id,price,amount)
VALUES ('Стихотворения и поэмы',3,2,650.00,15),('Черный человек',3,2,570.20,6),('Лирика',4,2,518.99,2);
SELECT * FROM book;

/*Необходимо в каждом городе провести выставку книг каждого автора в течение 2020 года. 
Дату проведения выставки выбрать случайным образом. Создать запрос, который выведет город,
автора и дату проведения выставки. Последний столбец назвать Дата. Информацию вывести, отсортировав 
сначала в алфавитном порядке по названиям городов, а потом по убыванию дат проведения выставок.*/
SELECT name_city, name_author, (DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 365) DAY)) AS 'Дата'
FROM city, author
ORDER BY name_city, Дата DESC;

/*Посчитать количество экземпляров  книг каждого автора из таблицы author.  Вывести тех авторов,  количество книг которых меньше 10,
в отсортированном по возрастанию количества виде. Последний столбец назвать Количество*/
SELECT name_author, SUM(amount) AS 'Количество'
FROM author
     LEFT JOIN book ON author.author_id=book.author_id
GROUP BY name_author
HAVING SUM(book.amount)<10 OR SUM(book.amount) IS NULL
ORDER BY Количество;

/*Вывести информацию о книгах (название книги, фамилию и инициалы автора, название жанра, цену и количество экземпляров книг), 
написанных в самых популярных жанрах, в отсортированном в алфавитном порядке по названию книг виде. Самым популярным считать жанр, 
общее количество экземпляров книг которого на складе максимально.*/
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

/*Для книг, которые уже есть на складе (в таблице book), но по другой цене, чем в поставке (supply), 
необходимо в таблице book увеличить количество на значение, указанное в поставке,  и пересчитать цену. А в таблице  
supply обнулить количество этих книг.*/
UPDATE book
    JOIN author USING (author_id)
    JOIN supply ON book.title = supply.title AND author.name_author=supply.author
SET book.amount=book.amount+supply.amount, book.price = 
((book.price*book.amount+supply.price*supply.amount)/(book.amount+supply.amount)), supply.amount = 0
WHERE book.price <> supply.price;

/*Удалить все жанры, к которым относится меньше 4-х книг. В таблице book для этих жанров установить значение Null.*/
DELETE FROM genre
WHERE genre_id IN 
                (SELECT genre_id
                 FROM book
                 GROUP BY genre_id
                 HAVING count(DISTINCT book_id)<4);
SELECT*FROM genre;

/*Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и в каком количестве он заказал) 
в отсортированном по номеру заказа и названиям книг виде.*/
SELECT buy.buy_id, book.title, book.price, buy_book.amount
FROM buy
    JOIN client ON buy.client_id=client.client_id
    JOIN buy_book ON buy.buy_id = buy_book.buy_id
    JOIN book ON buy_book.book_id=book.book_id
WHERE name_client = 'Баранов Павел'
ORDER BY buy.buy_id, book.title;

/*Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора (нужно посчитать, в каком количестве 
заказов фигурирует каждая книга).  Вывести фамилию и инициалы автора, название книги, последний столбец назвать Количество.
Результат отсортировать сначала  по фамилиям авторов, а потом по названиям книг.*/
SELECT author.name_author, book.title,
COUNT(buy_book_id) AS 'Количество'
FROM book
      INNER JOIN author ON book.author_id = author.author_id
      LEFT JOIN buy_book ON book.book_id = buy_book.book_id
GROUP BY book.title,author.name_author
ORDER BY author.name_author, book.title;

/*Вывести жанр (или жанры), в котором было заказано больше всего экземпляров книг, указать это количество . Последний столбец назвать Количество.*/
SELECT genre.name_genre,
(
	SELECT max(pek.sum1) as 'maxzn'
	FROM (
		SELECT book.genre_id, Sum(buy_book.amount) as sum1
		FROM book
			JOIN buy_book on book.book_id=buy_book.book_id
		Group by book.genre_id) sum1
) as 'Количество'
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
/*равнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. Для этого вывести год, месяц, сумму выручки в отсортированном 
сначала по возрастанию месяцев, затем по возрастанию лет виде. Название столбцов: Год, Месяц, Сумма.*/
SELECT year(buy_step.date_step_end) AS 'Год', monthname(buy_step.date_step_end) AS 'Месяц', sum(book.price*buy_book.amount) AS'Сумма'
FROM buy_step
    JOIN buy_book USING (buy_id)
    JOIN book USING (book_id)
    JOIN step USING (step_id)
GROUP BY Месяц, Год, buy_step.step_id
HAVING Месяц IS NOT NULL AND buy_step.step_id=1
UNION
SELECT year(date_payment) AS 'Год', monthname(date_payment) AS 'Месяц', sum(price*amount) AS'Сумма'
FROM buy_archive
GROUP BY Месяц, Год
HAVING Месяц IS NOT NULL
ORDER BY Месяц, Год;

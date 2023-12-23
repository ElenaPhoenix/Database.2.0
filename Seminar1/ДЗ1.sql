/* Задача 1
Создайте таблицу с мобильными телефонами, используя графический интерфейс. Необходимые поля таблицы: product_name (название товара), 
manufacturer (производитель), product_count (количество), price (цена). Заполните БД произвольными данными.

Задача 2
Напишите SELECT-запрос, который выводит название товара, производителя и цену для товаров, количество которых превышает 2
*/
SELECT product_name, manufacturer, price
FROM mobphones.phones
WHERE product_count > 2;

/* Задача 3
Выведите SELECT-запросом весь ассортимент товаров марки “Samsung”
*/
SELECT *
FROM mobphones.phones
WHERE manufacturer = 'Samsung';

/* Задача 4
С помощью SELECT-запроса с оператором LIKE / REGEXP найти:
Товары, в которых есть упоминание "Iphone"
Товары, в названии которых есть ЦИФРЫ
Товары, в названии которых есть ЦИФРА "8"
*/
SELECT *
FROM mobphones.phones
WHERE product_name LIKE '%iphone%';

SELECT * 
FROM mobphones.phones
WHERE product_name REGEXP '[0-9]';

SELECT * 
FROM mobphones.phones
WHERE product_name LIKE '%8%';

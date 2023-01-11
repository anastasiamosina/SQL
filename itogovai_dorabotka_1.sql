--№1
--Сколько суммарно каждый тип самолета провел в воздухе, если брать завершенные перелеты.

select  a.model ,sum("time")
from(
	select flight_id ,f.aircraft_code, actual_departure, actual_arrival, actual_arrival -actual_departure::timestamp  as "time"
	from flights f
	where f.actual_departure is not null) f
join aircrafts a  on a.aircraft_code = f.aircraft_code
where f.actual_departure is not null
group by a.model


--№2
--Сколько было получено посадочных талонов по каждой брони
select  b.book_ref, count(bp.seat_no)
from  bookings b 
join tickets t on t.book_ref = b.book_ref 
left join boarding_passes bp on bp.ticket_no = t.ticket_no 
where  bp.seat_no is not null 
group by b.book_ref 


--№3
--Вывести общую сумму продаж по каждому классу билетов
select fare_conditions , sum(amount) 
from  ticket_flights tf 
group by fare_conditions 

--№4
--Найти маршрут с наибольшим финансовым оборотом
with c1 as (
	select  f.flight_id,f.flight_no, f.departure_airport ,a.city
	from flights f
	join  airports a on f.departure_airport = a.airport_code)  ,
c2 as(
	select 	f.flight_id,f.flight_no, f.arrival_airport , a.city 
	from flights f
	join  airports a on f.arrival_airport  = a.airport_code)
select distinct f1.flight_no, f1."city1", f1."city2", sum(f1.sum) over (partition by f1.flight_no)
from(
	select distinct  f.flight_id,f.flight_no,  c_1.city as "city1", c_2.city as "city2", f.actual_departure,
	sum(tf.amount)over (partition by f.flight_id)	 
	from flights f
	join ticket_flights tf on f.flight_id =tf.flight_id
	join c1 c_1 on  c_1.flight_id =f.flight_id 
	join c2 c_2 on c_2.flight_id =f.flight_id )f1
where f1.actual_departure is not null
order by sum desc
limit 1





--№5
--Найти наилучший и наихудший месяцы по бронированию билетов (количество и сумма)
with c1 as (
	select distinct  b."month",b."year", sum(b.total_amount ) over (partition by b."month", b."year"), 
		count(book_ref) over (partition by b."month",b."year")
	from(
	select total_amount ,book_date,book_ref,
	extract( 'month' from book_date ) AS "month",
	extract( 'year' from book_date ) AS "year"
	from bookings b  )b)
select   c1."month",c1."year", sum, count
from c1
WHERE sum IN (
	( SELECT min( sum ) FROM c1 ),
	( SELECT max( sum ) FROM c1))
   











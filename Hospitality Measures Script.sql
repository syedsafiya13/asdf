Create database Hospitality_DB;
Use Hospitality_DB;
Select * From dim_date;
Select * From dim_hotels1;
Select * From dim_rooms;
Select * From fact_aggregated_bookings;
Select * From fact_bookings;

-- Q1 Revenue
SELECT SUM(revenue_realized) AS total_revenue
FROM fact_bookings;

-- Q2 Total Bookings
SELECT COUNT(DISTINCT booking_id) AS total_bookings
FROM fact_bookings;

-- Q3 Total Capacity
SELECT SUM(capacity) AS total_rooms_capacity
FROM fact_aggregated_bookings;

-- Q4 Total Successful Bookings
SELECT COUNT(booking_id) AS total_successful_bookings
FROM fact_bookings
WHERE booking_status = 'checked out';

-- Q5 Occupancy%
 SELECT 
    h.property_id,
    h.property_name,
    f.check_in_date,
    SUM(f.successful_bookings) AS total_booked_rooms,
    sum(f.capacity) AS total_capacity,
    ROUND(SUM(f.successful_bookings) / SUM(f.capacity) * 100, 2) AS occupancy_percent
FROM fact_aggregated_bookings f
JOIN dim_hotels1 h 
    ON f.property_id = h.property_id
GROUP BY h.property_id, h.property_name, f.check_in_date
ORDER BY f.check_in_date, h.property_id;

-- Q6 Avg Ratings
SELECT AVG(ratings_given) AS avg_rating
FROM fact_bookings;

-- Q7 Total Cancelled Bookings
SELECT COUNT(DISTINCT booking_id) AS total_cancelled_bookings
FROM fact_bookings
WHERE booking_status = 'cancelled';

-- Q8 Cancellation%
SELECT
  SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
  COUNT(DISTINCT booking_id) AS total_bookings,
ROUND(100 * SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT booking_id),0), 2) AS cancellation_pct
FROM fact_bookings;

-- Q9 Total Check Out
SELECT COUNT(DISTINCT booking_id) AS total_checked_out
FROM fact_bookings
WHERE booking_status = 'checked out';

-- Q10 Total No Show
SELECT COUNT(DISTINCT booking_id) AS Total_No_Show
FROM fact_bookings
WHERE booking_status = 'No Show';

-- Q11 No Show%
SELECT
  SUM(CASE WHEN booking_status = 'No Show' THEN 1 ELSE 0 END) AS no_show_count,
  COUNT(DISTINCT booking_id) AS total_bookings,
  ROUND(100 * SUM(CASE WHEN booking_status = 'No Show' THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT booking_id),0),2) AS No_Show_pct
FROM fact_bookings;

-- Q12 Booking % by Platform
SELECT
  booking_platform,
  COUNT(DISTINCT booking_id) AS bookings,
  ROUND(100 * COUNT(DISTINCT booking_id) / NULLIF((SELECT COUNT(DISTINCT booking_id) 
  FROM fact_bookings),0),2) AS pct_of_bookings
FROM fact_bookings
GROUP BY booking_platform
ORDER BY bookings DESC;

-- Q13 Booking % by Room Class
SELECT
  r.room_class,
  COUNT(DISTINCT f.booking_id) AS bookings,
  ROUND(100 * COUNT(DISTINCT f.booking_id) / NULLIF((SELECT COUNT(DISTINCT booking_id) 
  FROM fact_bookings),0),2) AS pct_of_bookings
FROM fact_bookings f
LEFT JOIN dim_rooms r ON f.room_category = r.room_id
GROUP BY r.room_class
ORDER BY bookings DESC;

-- Q14 ADR (Average Daily Rate)
SELECT
  ROUND(SUM(revenue_realized) / COUNT(DISTINCT booking_id)) AS ADR
FROM fact_bookings;

-- Q15 Realisation %
SELECT
  (ROUND(100 * SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT booking_id),0), 2)) / (ROUND(100 * SUM(CASE WHEN booking_status = 'No Show' THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT booking_id),0),2)) AS realisation_pct
FROM fact_bookings;

-- Q16 RevPAR (Revenue per Available Room)
SELECT
	ROUND(SUM(b.revenue_realized) / SUM(f.capacity)) AS RevPAR
FROM fact_bookings b
LEFT JOIN fact_aggregated_bookings f ON b.property_id = f.property_id;

-- Q17 DBRN
SELECT 
	ROUND(COUNT(DISTINCT f.booking_id)/COUNT(DISTINCT d.date)) AS DBRN
FROM fact_bookings f
LEFT JOIN dim_date d ON d.date = f.check_in_date;

-- Q18 DSRN
SELECT 
	ROUND(SUM(f.capacity)/ COUNT(DISTINCT d.date)) AS DSRn
FROM fact_aggregated_bookings f
LEFT JOIN dim_date d ON d.date = f.check_in_date;

-- Q19 DURN
SELECT 
	ROUND(SUM(CASE WHEN f.booking_status = 'Checked Out' THEN 1 ELSE 0 END)/ COUNT(DISTINCT d.date)) AS DURN
FROM fact_bookings f
LEFT JOIN dim_date d ON d.date = f.check_in_date;
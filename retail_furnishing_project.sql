

------- tổng quan về sản phẩm
--- ở mỗi năm,mỗi  nhóm sub-category có bao nhiêu items

select *
from
	(
	select
		year([Order Date]) as year,
		[Sub-Category],
		count(distinct([Product ID])) as number_of_items
	from sales_data
	group by year([Order Date]) , [Sub-Category]
	) as source_table
	pivot
	(
		max(number_of_items) for [Sub-Category] in ([Bookcases],[Chairs],[Furnishings],[Tables])
	) as number_of_items_by_sub


--- tỷ lệ tăng trưởng về số lượng items ở mỗi nhóm sản phẩm qua từng năm

with cte1 as (
select 
	year,
	Bookcases,
	Chairs,
	Furnishings,
	Tables
from
	(
	select
		year([Order Date]) as year,
		[Sub-Category],
		cast(count(distinct([Product ID])) as float) as number_of_items
	from sales_data
	group by year([Order Date]) , [Sub-Category]
	) as source_table
	pivot
	(
		max(number_of_items) for [Sub-Category] in ([Bookcases],[Chairs],[Furnishings],[Tables])
	) as number_of_items_by_sub
) 

select 
	b.year,
	round((b.Bookcases - a.Bookcases)/a.Bookcases,2) as Bookcases_growth_rate, --- tính tỷ lệ tăng trưởng về số lượng items trong mỗi sub-category qua từng năm
	round((b.Furnishings - a.Furnishings)/a.Furnishings,2) as Furnishings_growth_rate,
	round((b.Tables - a.Tables)/a.Tables,2) as Tables_growth_rate
from cte1  a join cte1 b
	on b.year - a.year = 1;
	---> Nhìn chung tính đến 2017, số lượng sản phẩm được doanh nghiệp mở rộng qua các năm.
	---> Doanh nghiệp có triển khai và bán thêm nhiều sản phẩm mới, và giảm bớt những sản phẩm có thể không đáp ứng nhu cầu khách hàng.

---------- XÁC ĐỊNH CÁC SẢN PHẨM KHÔNG HIỆU QUẢ Ở MỖI NHÓM SUB-CATEGORY
create procedure ineffective_items
	@sub_category nvarchar(255)
as
	begin
		with cte1  as (
			select
				sub1.year,
				sub1.product_name,
				sum(sub1.diff_days) as total_diff_days, --- tổng các khoảng cách (ngày) giữa các lần sản phẩm được mua
				count(sub1.product_name) as number_of_purchases --- số lần sản phẩm được mua trong năm
			from (
				select 
					year([Order Date]) as year,
					[Product Name] as product_name,
					coalesce(datediff(day, 
								cast([Order Date] as date),
										(lead(cast([Order Date] as date),1,null) over (partition by year([Order Date]) , [Product Name] order by [Order Date]))),0) as diff_days ---tính khoảng cách (ngày) giữa các lần sản phẩm được mua
				from sales_data
				where [Sub-Category] = @sub_category ---- thay đổi sub-category khác
			) as sub1
			group by sub1.year , sub1.product_name
		),
		cte2 as (
			select
				cte0.year,
				cte0.product_name,
				cte1.total_diff_days,
				cte1.number_of_purchases,
				(cte1.total_diff_days / cte1.number_of_purchases) as average_time_between_purchases, --- thời gian trung bình (ngày) giữa các lần sản phẩm được mua 
				cte0.total_sales,
				cte0.total_volume
			from cte1 join (
				select
					year([Order Date]) as year,
					[Product Name] as product_name,
					round(sum(Sales),0) as total_sales,
					sum(Quantity) as total_volume
				from sales_data 
				where [Sub-Category] = @sub_category
				group by year([Order Date]) , [Product Name]
			) as cte0 
				on cte1.year = cte0.year and cte1.product_name = cte0.product_name),
		cte3 as (
		select
			year,
			product_name,
			total_diff_days,
			number_of_purchases,
			average_time_between_purchases,
			total_volume,
			total_sales,
			dense_rank() over (partition by year order by total_sales desc) as sales_rank --- xếp hạng doanh số của các sản phẩm trong năm 
		from cte2),
		cte4 as (
			select
				*
			from cte3
			where product_name in (
					select 
						product_name
					from cte3
					where (number_of_purchases = 1 and total_sales < 100) or 
							(number_of_purchases = 2 and average_time_between_purchases > 180 and total_sales < 200) or --- thiết lập điều kiện cho từng yếu tố
							(number_of_purchases = 3 and average_time_between_purchases > 120 and total_sales < 400) or
							(number_of_purchases = 4 and average_time_between_purchases > 90 and total_sales < 800) or
							(number_of_purchases >= 5 and average_time_between_purchases > 70 and total_sales < 1600)
		)
		
	)

		select
			year,
			product_name,
			number_of_purchases,
			average_time_between_purchases,
			total_volume,
			total_sales,
			coalesce(lag(sales_growth_rate,1,null) over (partition by product_name order by year),0) as sales_growth_rate, --- thay thế giá trị null bằng giá trị 0 vì đã dịch chuyển sales_growth_rate lên trên 1 hàng
			sales_rank
		from (
			select
				year,
				product_name,
				number_of_purchases,
				average_time_between_purchases,
				total_volume,
				total_sales,
				round((lead(total_sales,1,total_sales) over (partition by product_name order by year) - total_sales) / total_sales,2) as sales_growth_rate, ---tính sales_growth_rate
				sales_rank
			from cte4
		) as items_sales
end

exec ineffective_items @sub_category = 'chairs'




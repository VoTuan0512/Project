------Type:  Analytical Dashboard
---- Target users: product team and mid-management
---- Stage: 2017
---- Indicators:
--1. Sales by Sub-Category
--2. Number of orders by Sub-Category and Ship Mode
--3. Sales volume growth rate
--4. Average selling price by Sub-Category
--5. Top 5 products sales by Sub-Category
--6. Sales to discount
-- sales ratio from discount by Sub-Category each month
-- discount ratio to sales by Sub-Category each month
--7. Evaluate ineffective products based on factors such as sales, sales rank ,number of purchases, and average time between purchases, total volume

--1. Sales by Sub-Category
select 
    month,
    sub_category,
    sales
from (
        select 
        month([Order Date]) as month,
        round(sum(case when [sub-category] = 'bookcases' then sales else 0 end),0) as 'Bookcase', -- tính doanh số theo từng sub-category
        round(sum(case when [sub-category] = 'chairs' then sales else 0 end),0) as 'Chairs',
        round(sum(case when [sub-category] = 'furnishings' then sales else 0 end),0) as 'Furnishings',
        round(sum(case when [sub-category] = 'tables' then sales else 0 end),0) as 'Tables'
    from sales_data
    where year([order date]) = 2017
    group by month([order date])
) as source
unpivot 
 (
    sales for sub_category in ([Bookcase],[Chairs],[Furnishings],[Tables]) -- chuyển kết quả thành bảng dài
 ) as unpivot_table


--2. Number of orders by Sub-Category and Ship Mode
with cte as (
    select
        [sub-category],
        count(distinct(case when [ship mode] = 'same day' then [order id] else null end)) as 'same day', -- đếm số lượng đơn theo phương thức giao hàng
        count(distinct(case when [ship mode] = 'first class' then [order id] else null end)) as 'first class',
        count(distinct(case when [ship mode] = 'second class' then [order id] else null end)) as 'second class',
        count(distinct(case when [ship mode] = 'standard class' then [order id] else null end)) as 'standard class'
    from sales_data
    where year([order date]) = 2017
    group by [sub-category]
)

select
    [sub-category],
    [ship_mode],
    [number_of_orders]
from (
    select
        [sub-category],
        [same day],
        [first class],
        [second class],
        [standard class]
    from cte
) as source 
unpivot
 (
    number_of_orders for ship_mode in ([same day],[first class],[second class],[standard class]) -- chuyển thành kết quả thành bảng dài
 ) as unpivot_table

--3. Sales volume growth rate

with cte0 as (
    select 
        month([order date]) as month,
        sum(quantity) as quantity
    from sales_data
    where year([order date]) = 2017
    group by month([order date])
), cte_ as (
    select
        month,
        round(((lead(quantity,1,0) over (order by month) - quantity) / quantity)*100,2) as sales_volume_growth_rate
    from cte0
)

select 
    month,
    lag(sales_volume_growth_rate,1,0) over (order by month) as sales_volume_growth_rate -- lấy kết quả dịch xuống 1 hàng
from cte_



--4. Average selling price by Sub-Category
with cte1 as (
    select 
        [sub-category],
        round(sum(sales),0) as sales,
        sum(quantity) as total_quantity
    from sales_data
    where year([order date]) = 2017
    group by [sub-category]
)

select 
    [sub-category],
    round((sales / total_quantity),2) as avg_selling_price  
from cte1

--5. top 5 products sales by Sub-Category
with cte2 as (
    select
        [sub-category],
        [product name],
        round(sum(sales),2) as sales
    from sales_data
    where year([order date]) = 2017
    group by [sub-category] , [product name]
), cte3 as (
    select 
        [sub-category],
        [product name],
        sales,
        dense_rank() over (partition by [sub-category] order by sales desc) as sales_rank
    from cte2
)

select 
    [sub-category],
    [product name],
    sales
from cte3
where sales_rank between 1 and 5


--6. Sales to discount ratio by Sub-Category each month
-- sales ratio from discount by Sub-Category each month

with cte4 as (
    select
        month([order date]) as month,
        round(sum((case when [sub-category] = 'bookcases' then sales else 0 end)),2) as bookcases_sales,
        round(sum((case when [sub-category] = 'chairs' then sales else 0 end)),2) as chairs_sales,
        round(sum((case when [sub-category] = 'furnishings' then sales else 0 end)),2) as furnishings_sales,
        round(sum((case when [sub-category] = 'tables' then sales else 0 end)),2) as tables_sales
    from sales_data
    where year([order date]) = 2017
    group by month([order date])
),cte5 as (
    select
        month([order date]) as month,
        round(sum((case when [sub-category] = 'bookcases' then sales else 0 end)),2) as bookcases_sales_from_discount,
        round(sum((case when [sub-category] = 'chairs' then sales else 0 end)),2) as chairs_sales_from_discount,
        round(sum((case when [sub-category] = 'furnishings' then sales else 0 end)),2) as furnishings_sales_from_discount,
        round(sum((case when [sub-category] = 'tables' then sales else 0 end)),2) as tables_sales_from_discount
    from sales_data
    where year([order date]) = 2017 and discount != 0
    group by month([order date])
)
select
    cte4.month,
    round((cte5.bookcases_sales_from_discount / cte4.bookcases_sales )*100,2) as bookcases_sales_ratio_from_discount,
    round((cte5.chairs_sales_from_discount / cte4.chairs_sales)*100,2) as chairs_sales_ratio_from_discount,
    round((cte5.furnishings_sales_from_discount / cte4.furnishings_sales)*100,2) as furnishings_sales_ratio_from_discount,
    round((cte5.tables_sales_from_discount / cte4.tables_sales)*100,2) as tables_sales_ratio_from_discount
from cte4 join cte5 
    on cte4.month = cte5.month

-- discount ratio to sales by Sub-Category each month
with cte6 as (
    select 
        month([order date]) as month,
        round(sum(case when [sub-category] = 'bookcases' then sales else 0 end),2) as bookcases_sales,
        round(sum(case when [sub-category] = 'chairs' then sales else 0 end),2) as chairs_sales,
        round(sum(case when [sub-category] = 'furnishings' then sales else 0 end),2) as furnishings_sales,
        round(sum(case when [sub-category] = 'tables' then sales else 0 end),2) as tables_sales
    from sales_data
    where year([order date]) = 2017
    group by month([order date])
), cte7 as (
    select 
        month([order date]) as month,
        round(sum(case when [sub-category] = 'bookcases' then sales else 0 end),2) as bookcases_sales_from_discount,
        round(sum(case when [sub-category] = 'chairs' then sales else 0 end),2) as chairs_sales_from_discount,
        round(sum(case when [sub-category] = 'furnishings' then sales else 0 end),2) as furnishings_sales_from_discount,
        round(sum(case when [sub-category] = 'tables' then sales else 0 end),2) as tables_sales_from_discount
    from sales_data
    where year([order date]) = 2017 and discount != 0
    group by month([order date])
)

select 
    cte6.month,
    round(((cte6.bookcases_sales - cte7.bookcases_sales_from_discount) / cte6.bookcases_sales)*100,2) as bookcases_discount_ratio_to_sales,
    round(((cte6.chairs_sales - cte7.chairs_sales_from_discount) / cte6.chairs_sales)*100,2) as chairs_discount_ratio_to_sales,
    round(((cte6.furnishings_sales - cte7.furnishings_sales_from_discount) / cte6.furnishings_sales)*100,2) as furnishings_discount_ratio_to_sales,
    round(((cte6.tables_sales - cte7.tables_sales_from_discount) / cte6.tables_sales)*100,2) as tables_discount_ratio_to_sales
from cte6 join cte7 
    on cte6.month = cte7.month


--7. Evaluate ineffective products based on factors such as sales, sales rank ,number of purchases, and average time between purchases, total volume
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
				year,
				product_name,
				total_diff_days,
				number_of_purchases,
				average_time_between_purchases,
				total_volume,
				total_sales,
				sales_rank
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

# Super Store Sales Analysis (period 2014-2017)

- The project related to retail furniture. This is a small retail business based in the United States, specializes in selling Furniture, Office Supplies, and Technology products.

- They're launching 4 sub-categories include Bookcases, Chairs, Furnishings and Tables. Each sub-category have multiple items.

- The three customer segments are Consumers, Home Office and Corporate. These segments are in four regions: Central, East, South, and West.

There are two parts in my project. 
- Part 1: The overview status of business, as well as the expenditure capability per order of customers from 2014 to 2017, was executed using Python. Check it out [here](https://github.com/VoTuan0512/Project/blob/master/retail_furniture_project.ipynb)
- Part 2: The operational dashboard of sub-category in 2017, was executed using SQL and Tableau. Target users: operations professional. Check it out [here](https://github.com/VoTuan0512/Project/blob/master/analytical_indicators_of_retail_furniture_project.sql)

Some business questions served to build the dashboard:
- How was the sales/profit performance in 2017 ?
- What is the average selling price of sub-categories in 2017 ?
- How much is the sales contribution in regions ?
- What is the most commonly used ship-mode for each sub-category ?
- What is the ratio of sales from discounts compared to total sales?
- What is the sales volume for each sub-category ?
- What discount rates are commonly applied across sub-categories?
- Top 5 products has highest sales for each sub-category ?
  
## Part 1: Summary of Insights

### Overview Status of the business:
- The operational situation of the business from 2014 to 2017 showed positive results in terms of revenue.
The West region was the largest revenue generator, with the company's main product groups over the past four years being Chairs (the highest revenue group) and Furnishings (the group with the highest sales volume).
- The primary customer segment for the business is Consumers, accounting for an average proportion of 40-50% in each region.
- The most commonly used delivery method is Standard delivery, which has been gradually declining each year.

### Expenditure capability of customer
- The spending per order by customers has been decreasing year by year, and the proportion of high-value orders has continuously declined.
The Consumer segment in the East region has experienced the most significant decrease in spending per order for the sub-category Chairs and Furnishings compared to other regions in 2017.

## Part 2: Zoom indicators analysis of sub-category in 2017. Interactive Tableau dashboard can be found [here](https://public.tableau.com/views/RetailFurnitureProject/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

![image](https://github.com/user-attachments/assets/6d469e6c-6451-4205-a43f-6460b34609dc)

![image](https://github.com/user-attachments/assets/23206125-6f72-4839-bc2a-ba210c62d7dd)

### Summary review indicators in dashboard:
- Sub-categories show positive results in terms of revenue. However, tables show significantly negative results in terms of profit over the last 4 months.
- Consider the price of items in Furnishing (though it show positive result in term of sales volume) when it has the lowest average selling price compared to others.
- Chairs still have the highest sales contribution in each region.
- 3 out of 4 sub-categories have the majority of sales from discounts. This could indicate an effective discount campaign, but it can bring some disadvantages to the business, such as decreased profit and issues related to brand quality.
- Tables have a relatively high discount ratio because they have low sales volume in Q1, Q2, and Q3 of this year. Another reason could be that they will launch some new products in 2018, that why a high discount ratio to accelerate the process of selling inventory.

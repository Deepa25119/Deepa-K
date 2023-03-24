 ##--1.
 select * from online_customer;
 select 
 case
	when customer_gender='M' then concat ('Mr.', upper(customer_fname),  ' ',upper(customer_lname))
    when customer_gender='F' then concat ('Ms.', upper(customer_fname),  ' ',upper(customer_lname))
    else 'not found'
    end as fullname,customer_email,customer_creation_date,
 case
	when year(customer_creation_date)  < 2005 then 'A'
    when year(customer_creation_date) >= 2005 and year(customer_creation_date)< 2011 then 'B'
    when year(customer_creation_date) >= 2011 then 'C'
    else 'Nil'
    end as category
	from online_customer;
    
    ##--2.
	select product_id,product_desc,product_quantity_avail,product_price,
    product_quantity_avail*product_price as inventory_value,
	case
		when product_price>20000 then product_price*0.8
        when product_price>10000 then product_price*0.85
        when product_price<=10000 then product_price*0.9
        end as New_price from product
        order by inventory_value desc;
        
   ##--3.
   select pc.product_class_code,pc.product_class_desc,
   COUNT(p.Product_quantity_avail) as 'Product_Type_Count',
   SUM(p.product_quantity_avail * p.product_price) as inventory_value from product_class pc
   join Product p ON pc.Product_class_code = p.Product_class_code
   group by pc.Product_class_code, pc.Product_class_desc
   Having SUM(p.product_quantity_avail * p.product_price) > 100000
   order by inventory_value desc;
   
   ##--4.
   select c.customer_id,concat(customer_fname,'',customer_lname) as fullname ,c.customer_email,c.customer_phone,a.country from online_customer c
   join address a on c.customer_id
   join order_header o on c.customer_id
   where not exists(select * from order_header where customer_id = c.customer_id and order_status = 'cancelled');
   
   ##--5.
   select s.shipper_name,a.city,COUNT(DISTINCT o.customer_id) as 'Number of Customers', COUNT(o.order_id) as 'Number of Consignments'
   from shipper s
   join order_header o ON s.shipper_id = o.shipper_id
   join online_customer c on o.customer_id=c.customer_id
   join address a on c.customer_id
   where s.shipper_name ='DHL'
   group by s.shipper_name,a.city;
   
   ##--6.
select * from order_items;
select * from product;
select * from product_class;
select 
p.product_id,
p.product_desc, 
p.product_quantity_avail,
pc.product_class_desc,
 case 
		when (pc.product_class_desc = "Electronics" or pc.product_class_desc = "Computer") and sum(oi.product_quantity) = 0 then "No Sales in past, give discount to reduce inventory"
        when (pc.product_class_desc = "Electronics" or pc.product_class_desc = "Computer") and product_quantity_avail < (0.10*sum(oi.product_quantity)) then "Low inventory, need to add inventory"
		when (pc.product_class_desc = "Electronics" or pc.product_class_desc = "Computer") and product_quantity_avail < (0.50*sum(oi.product_quantity)) then "Medium inventory"
        when (pc.product_class_desc = "Electronics" or pc.product_class_desc = "Computer") and product_quantity_avail > (0.50*sum(oi.product_quantity)) then "Sufficient inventory"
        when (pc.product_class_desc = "Mobiles" or pc.product_class_desc = "Watches") and sum(oi.product_quantity) = 0 then "No Sales in past, give discount to reduce inventory"
        when (pc.product_class_desc = "Mobiles" or pc.product_class_desc = "Watches") and product_quantity_avail < (0.20*sum(oi.product_quantity)) then "Low inventory, need to add inventory"
		when (pc.product_class_desc = "Mobiles" or pc.product_class_desc = "Watches") and product_quantity_avail < (0.60*sum(oi.product_quantity)) then "Medium inventory"
		when (pc.product_class_desc = "Mobiles" or pc.product_class_desc = "Watches") and product_quantity_avail > (0.60*sum(oi.product_quantity)) then "Sufficient inventory"
        when pc.product_class_desc not in ("Electronics","Computer","Mobiles","Watches") and sum(oi.product_quantity) = 0 then "No Sales in past, give discount to reduce inventory"
        when pc.product_class_desc not in ("Electronics","Computer","Mobiles","Watches") and product_quantity_avail < (0.30*sum(oi.product_quantity)) then "Low inventory, need to add inventory"
        when pc.product_class_desc not in ("Electronics","Computer","Mobiles","Watches") and product_quantity_avail < (0.70*sum(oi.product_quantity)) then "Medium inventory"
	else "Sufficient inventory"
end as InventoryStatus,
sum(oi.product_quantity) as QuantitySold 
from product p, order_items oi , product_class pc
where p.product_id = oi.product_id and pc.product_class_code = p.product_class_code
group by p.product_id,p.product_desc, p.product_quantity_avail,pc.product_class_desc;

##--7.
select * from order_items;
select * from product;
select * from carton;
select oi.order_id,
sum(p.len*p.width*p.height) as Volume
from order_items oi
join product p on oi.product_id = p.product_id
where p.len < 600 and p.width <300 and p.height <100 
group by oi.order_id
order by Volume desc
limit 1;

##--8.
select * from order_items;
select * from product;
select * from order_header;
select * from online_customer;
select oc.customer_id,
concat(oc.customer_fname," ",oc.customer_lname) as "fullname",
sum(oi.product_quantity) as "total_quantity",
sum(p.product_quantity_avail*p.product_price) as "Totalvalue"
from online_customer oc
join order_header oh on oh.customer_id = oc.customer_id
join order_items oi on oi.order_id = oh.order_id
join product p on p.product_id = oi.product_id
where oh.payment_mode = "Cash" and oc.customer_lname like "G%"
group by oc.customer_id,concat(oc.customer_fname," ",oc.customer_lname);

##--9.
select oi.product_id, p.product_desc, SUM(oi.product_quantity) as 'Total Quantity' from order_items oi
join PRODUCT p on oi.product_id = p.product_id
join ORDER_HEADER oh ON oi.order_id = oh.order_id
join ONLINE_CUSTOMER c ON oh.customer_id = c.customer_id
join ADDRESS a ON c.customer_id
where oi.product_id <> 201 AND a.city NOT IN ('Bangalore', 'New Delhi')
AND oh.order_id IN (
  select oh.order_id from ORDER_ITEMS oi
  Join ORDER_HEADER oh ON oi.order_id = oh.order_id
  WHERE oi.product_id = 201
)
GROUP BY oi.product_id, p.product_desc
ORDER BY SUM(oi.product_quantity) DESC;

##--10.
select * from order_items;
select * from online_customer;
select * from address;
select * from order_header;
select oi.order_id,oc.customer_id,concat(oc.customer_fname," ",oc.customer_lname) as fullname,sum(oi.product_quantity) as "Total Quantity"
from order_items oi
join order_header oh on  oi.order_id= oh.order_id
join online_customer oc on oc.customer_id = oh.customer_id
join address a on oc.address_id = a.address_id
where oi.order_id%2 =0 and a.pincode not like "5%"
group by oi.order_id, oc.customer_id,concat(oc.customer_fname," ",oc.customer_lname);





   
   
   
   
   
   
	
   
   
   
    
 
 
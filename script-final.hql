-- Creation of the table catalogue and loading of the data

DROP TABLE IF EXISTS catalogue;

CREATE EXTERNAL TABLE catalogue (ProductColorId bigINT, 
                      GenderLabel STRING,
                      SupplierColorLabel STRING, 
                      SeasonLabel STRING)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ';' 
STORED AS TEXTFILE
LOCATION "/user/cloudera/catalogue/"
TBLPROPERTIES ("skip.header.line.count"="1");



-- Creation of the table customer
DROP TABLE IF EXISTS customer;

CREATE EXTERNAL TABLE customer (CustomerId bigINT,
                       DomainCode STRING,
                       BirthDate timestamp,
                       Gender STRING,
                       Size STRING)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ';' 
STORED AS TEXTFILE
LOCATION "/user/cloudera/customer/"
TBLPROPERTIES ("skip.header.line.count"="1");

-- Creation of the table order
DROP TABLE IF EXISTS order;

CREATE EXTERNAL TABLE order (OrderNumber bigint,
                    VariantId bigint, 
                    CustomerId bigint,
                    Quantity bigint,
                    UnitPrice string,
                    OrderCreationDate timestamp)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ';' 
STORED AS TEXTFILE
LOCATION "/user/cloudera/order/"
TBLPROPERTIES ("skip.header.line.count"="1");


-- Creation of the table product_ref

DROP TABLE IF EXISTS product_ref;

CREATE EXTERNAL TABLE product_ref (VariantId bigint,
                    ProductColorId bigint,
                    ProductId bigint)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ';' 
STORED AS TEXTFILE
LOCATION "/user/cloudera/product_ref"
TBLPROPERTIES ("skip.header.line.count"="1");

-- Create the data variant

DROP TABLE IF EXISTS variant;

CREATE EXTERNAL TABLE variant (VariantId bigint,
                      MinSize String,	
                      MaxSize String,
                      Size String)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ';' 
STORED AS TEXTFILE
LOCATION "/user/cloudera/variant"
TBLPROPERTIES ("skip.header.line.count"="1");




-- AGGREGATION



-- transform orderprice from string

DROP TABLE IF EXISTS the_order_4;
CREATE TABLE the_order_4 AS
SELECT ordernumber, variantid, customerid, quantity, ordercreationdate, REGEXP_REPLACE(unitprice,',','.') AS unitprice FROM order;

ALTER TABLE the_order_4 CHANGE unitprice unitprice FLOAT;


-- drop the old order table

DROP TABLE order;


-- set hive.auto.convert.join=false enables RIGHT OUTER JOIN

set hive.auto.convert.join=false;

-- catalogue    RIGHT OUTTER JOIN    product_ref on productcolorid to add to product_ref the genderlabel that we will need later

DROP TABLE IF EXISTS product_cat;
CREATE TABLE product_cat AS
     
     SELECT u.genderlabel , u.suppliercolorlabel, pv.variantid, pv.productcolorid, pv.productid, u.seasonlabel
     FROM catalogue AS u RIGHT OUTER JOIN product_ref AS pv ON (pv.productcolorid = u.productcolorid)
     
;
-- variant    RIGHT OUTTER JOIN    product_cat on variantid to add on the previous obtained table(product_cat) the size that we will need later


     
     DROP TABLE IF EXISTS product_catv;
CREATE TABLE product_catv AS
     
     SELECT pv.genderlabel , pv.suppliercolorlabel, pv.variantid, pv.productcolorid, pv.productid, pv.seasonlabel, u.minsize, u.maxsize, u.size
     FROM variant AS u RIGHT OUTER JOIN product_cat AS pv ON (pv.variantid = u.variantid)
;

DROP TABLE product_cat ;

-- create the_product table which is the table demanded
DROP TABLE IF EXISTS the_product;

CREATE TABLE the_product 
ROW FORMAT DELIMITED 

FIELDS TERMINATED BY ';' 
STORED AS TEXTFILE
LOCATION "/user/cloudera/the_product/"
AS
SELECT productid, count(DISTINCT u.customerid) AS distinct_cust , sum(u.quantity) AS total_quantity, sum(u.unitprice*u.quantity) AS total_amount
FROM product_catv pv RIGHT OUTER JOIN the_order_4 u ON (pv.variantid = u.variantid)

GROUP BY  pv.productid

;
-- creating the table that has the dominant gender for each userm including duplicates . we are computing the maxgender as the maximum of the count of occurances for each gender 


DROP TABLE IF EXISTS CUSTOMER_G;

CREATE TABLE CUSTOMER_G AS

SELECT a.customerid, b.genderlabel, maxgender 
FROM
    (
      SELECT e.customerid, max(e.totalgender) maxgender
      
      FROM
        (
            SELECT u.customerid, pv.genderlabel, count(pv.genderlabel) totalgender            
            FROM product_catv pv RIGHT OUTER JOIN the_order_4 u ON (pv.variantid = u.variantid)
            group by u.customerid, pv.genderlabel
          ) e       
      
      group by e.customerid
    ) a

JOIN
    (
       SELECT u.customerid, pv.genderlabel, count(pv.genderlabel) totalgender            
            FROM product_catv pv RIGHT OUTER JOIN the_order_4 u ON (pv.variantid = u.variantid)
            group by u.customerid, pv.genderlabel
    ) b on (a.customerid=b.customerid) where (b.totalgender=a.maxgender)

;

-- creating the table that has the dominant size including the duplicates as the maximum of all the counts per size


DROP TABLE IF EXISTS CUSTOMER_S;

CREATE TABLE CUSTOMER_S AS

SELECT a.customerid, b.size, maxsizel 
FROM
    (
      SELECT e.customerid, max(e.totalsize) maxsizel
      
      FROM
        (
            SELECT u.customerid, pv.size, count(pv.size) totalsize            
            FROM product_catv pv RIGHT OUTER JOIN the_order_4 u ON (pv.variantid = u.variantid)
            group by u.customerid, pv.size
          ) e       
      
      group by e.customerid
    ) a

JOIN
    (
       SELECT u.customerid, pv.size, count(pv.size) totalsize            
            FROM product_catv pv RIGHT OUTER JOIN the_order_4 u ON (pv.variantid = u.variantid)
            group by u.customerid, pv.size
    ) b on (a.customerid = b.customerid) where (b.totalsize = a.maxsizel )
;
-- merging table that has the dominant size with the order date


DROP TABLE IF EXISTS CUSTOMER_D;

CREATE TABLE CUSTOMER_D AS

SELECT DISTINCT a.customerid, a.size, a.maxsizel, b.ordercreationdate  
FROM customer_s a JOIN the_order_4 b
ON (a.customerid = b.customerid);






-- modifying the gender into numerals in order to eli;inate the duplicates follozing the rule that in case of a tie the Femme is preffered to the Homme that is preffered to the Enfant follozing by Sacs and Accesories
DROP TABLE IF EXISTS customer_gn;

CREATE TABLE customer_gn AS


SELECT customerid,maxgender, genderlabel, 
CASE 
                 WHEN genderlabel='Femme' THEN 5
                 WHEN genderlabel='Homme' THEN 4
                 WHEN genderlabel='Enfant' THEN 3
                 WHEN genderlabel='Sacs' THEN 2
                 WHEN genderlabel='Accessoire' THEN 1
                 ELSE 0
                 END AS gender_num
FROM customer_g;

-- compute the maximum  gender as follozing the rule of selecting the order of the variable gender_num
DROP TABLE IF EXISTS customer_maxgen;
CREATE TABLE customer_maxgen AS
SELECT customerid, max(gender_num) as selected_gender
FROM customer_gn
GROUP BY customerid
;
-- merge the maximum gender for each customer with the table customer_gn in order to have for each custo;erid only the lign corresponding to the maximal gender 
DROP TABLE IF EXISTS the_customer_mg;


CREATE TABLE the_customer_mg AS

SELECT a.customerid, a.maxgender, a.genderlabel,b.selected_gender, a.gender_num

FROM customer_maxgen b JOIN customer_gn a 
ON a.customerid = b.customerid where (b.selected_gender = a.gender_num )
;


-- compute the maximum  size
DROP TABLE IF EXISTS customer_maxsize;
CREATE TABLE customer_maxsize AS
SELECT customerid, max(size) as selected_size
FROM customer_d
GROUP BY customerid

;
-- merge the maximum gender results with the table seing 
DROP TABLE IF EXISTS the_customer_size;

CREATE TABLE the_customer_size AS

SELECT a.customerid, a.size, a.maxsizel, a.ordercreationdate, b.selected_size
FROM customer_maxsize b JOIN customer_d a 
ON a.customerid = b.customerid where (b.selected_size = a.size )

;

-- DROP intermediate table that are no longer used
DROP TABLE customer_s;
DROP TABLE customer_g;
DROP TABLE customer_maxgen;
DROP TABLE customer_gn;
DROP TABLE customer_d;
DROP TABLE customer_maxsize ;

-- create the final table

DROP TABLE IF EXISTS the_CUSTOMER;

CREATE TABLE the_CUSTOMER

ROW FORMAT DELIMITED 

FIELDS TERMINATED BY ';' 
STORED AS TEXTFILE
LOCATION "/user/cloudera/the_customer/"


AS

SELECT DISTINCT a.customerid, a.size, a.maxsizel, a.ordercreationdate, b.genderlabel, b.maxgender    
FROM the_customer_size a JOIN the_customer_mg b
ON (a.customerid = b.customerid)
;

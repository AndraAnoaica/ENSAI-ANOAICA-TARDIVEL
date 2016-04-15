**

ENSAI-ANOAICA-TARDIVEL
----------------------

**

Repository containing the scripts and data and ReadMe file for IT Tools Project

**The repository contains:** 

 - the script-final.hql that contains the commands to load data from external table, aggregate and obtain the desired final tables:
   the_customer and the_product
 - forecast.py script that retrieves the maximum and minimum temperature for all the prefectures in France on 3 11 2015
 -  tables.xls containng two tabs, the first tabs contains the operations in order to obtain an unique intermediate table containing all the details related to products. The second tab explains the process to obtain the_customer table

**The script-final.hql takes as input the following tables :**

 - catalogue (ProductColorId, GenderLabel, SupplierColorLabel, SeasonLabel)  
 - product_ref (VariantId, ProductColorId, ProductId)
 - variant (VariantId, Minsize, MaxSize, Size)
 - order (OrderNumber, VariantId, CustomerId, Quqntity, UnitPrice,   
   OrderCrationDate)
 - customer (CustomerId, DomainCode, BirthDate, Gender, Size)

**We want to obtain two final tables:**

the_customer (customerid, size, ordercreationdate, genderlabel )
In this table, for each unique customerid that made an order, we have its last order date, the dominant gender that he purchased most offen and the dominant size.

For a particular customer where we had an equality between two genders we followed a predefined rule where Femme is to be picked first, then Homme, Enfant, Sacs and Accesoires.

To implement this rule we turned our values into numbers using a Case statement and choose the one that is the greatest.

Chosing the Size was done by using the Max function directly.

the_product (productid, distinct_cust, total_quantity, total_amount)

In the product table we have for each cproduct, the number of distinct customers that brought it, the total quantity and the total amount

**Working Hypothesis:**

We consider that our tables are provided by an external server into the location specified into HDFS. The tables are processed according to the specifications, The Product_ref table and the Variant are static, while the Product description and Customer are replaced every day. The table representing the order appends to the old table the current day's purchases. 

We are creating external tables and the final results are also stored as external tables.  

**forecast.py**

forecast.py is a python script that lakes use of the forecast.io API to fetch data related to weather on a particular date. If the desired date is wished to be change, only changing the fllowing line is needed, where the first argument is the year, the second the month, the third the date and the following is the huor.
date = datetime.datetime(2015,11,3,12,0,0)
the files are read and written to hdfs
pip install pydoop  command must be run in the terminal to install pydoop that enables access to hdfs
pip install python-forecastio command must be run in the terminal to install forecastio

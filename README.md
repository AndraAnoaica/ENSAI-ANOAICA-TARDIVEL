**

ENSAI-ANOAICA-TARDIVEL
----------------------

**

Repository containing the scripts and data and ReadMe file for IT Tools Project

**The repository contains:** 

 - the script-final.hql that contains the commands to load data from external table, aggregate and obtain the desired final tables:
   the_customer and the_product
 - forecast.py script that retrieves the maximum and minimum temperature for all the prefectures in France on 3 11 2015

**The script-final.hql takes as input the following tables :**

 - catalogue (ProductColorId, GenderLabel, SupplierColorLabel, SeasonLabel)  
 - product_ref (VariantId, ProductColorId, ProductId)
 - variant (VariantId, Minsize, MaxSize, Size)
 - order (OrderNumber, VariantId, CustomerId, Quqntity, UnitPrice,   
   OrderCrationDate)
 - customer (CustomerId, DomainCode, BirthDate, Gender, Size)

**We want to obtain two final tables:**

 - the_customer (customerid, size, ordercreationdate, genderlabel, ) 
  
 - the_product (productid, distinct_cust, total_quantity, total_amount)


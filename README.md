# SQL-Builder COS #

A flexible and powerful SQL query string builder for Intersystems Caché

### Installation ###

To install latest SQL-Builder, you just need to import xml package. 
Download the archive from latest releases, and then import sql-builder-cos-vX.X.X.xml file.

### Examples ###

```cos 
	Set tRS = ##class(gen.SQLBuilder).%New("sample.person").Where("Age = ?", 30).Execute()
```

SQL Output:
```sql
	Select * From sample.person Where Age = '30'
```
### Authors ###
 
 * Leonardo "Metz" Metzger [github](https://github.com/leometzger)
 * Henry "HammZ" Hamon [github](https://github.com/henryhamon)
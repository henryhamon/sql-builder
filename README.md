# SQL-Builder COS #

A flexible and powerful SQL query string builder for Intersystems Caché.

## Benefits ##
	1. Nice and clean object oriented methods instead of having to use concatenation and substituition to generate dynamic queries
	2. Flexibility to build query adding clauses with logical conditions

## Installation ##

### ZPM ###

To install with ZPM(ObjectScript Package Manager) just run install sqlbuilder

```
	USER>zpm
	zpm: USER>install sqlbuilder
```

### Import Package ###

To install latest SQL-Builder, you just need to import xml package.
Download the archive from latest releases, and then import sql-builder-cos-vX.X.X.xml file.

## Examples ##

```cos
	Set tRS = ##class(gen.SQLBuilder).%New("sample.person").Where("Age = ?", 30).Execute()
```

SQL Output:
```sql
	Select * From sample.person Where Age = '30'
```
## Authors ##

 * Leonardo "Metz" Metzger [github](https://github.com/leometzger)
 * Henry "HammZ" Hamon [github](https://github.com/henryhamon)

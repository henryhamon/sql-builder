# SQL-Builder COS #

A flexible and powerful SQL query string builder for Intersystems Caché.

## Benefits ##
	1. Nice and clean object oriented methods instead of having to use concatenation
  	and substituition to generate dynamic queries
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

SQL Executed:
```sql
	Select * From sample.person Where Age = '30'
```

## Documentation ##

#### Execute(Output tSC As %Status = "", Args...) as %ResultSet
Execute the Query returning the ResultSet

#### GetSQL() as %String
Get the SQL Query string
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person
```

#### Prepare(tSC As %Status) as %ResultSet
Prepare the query ResultSet

```
	Set tRS = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN, Age").From("sample.person").Between("Age",10,50).Prepare()
	Write $ClassName(tRS)
	> %Library.ResultSet
```

### SELECT

#### Select(params As %String = "")
Creates a Select query
taking an optional line string of columns for the query with comma separator
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person
```

defaulting to * if none are specified when the query is built
```
	Write ##class(gen.SQLBuilder).%New().Select().From("sample.person").GetSQL()
```
**Output**
```sql
	Select * From sample.person
```

#### Column(pField, pAlias As %String = "")
Add Columns on Select query
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").Column("age").From("sample.person").Between("Age",10,50).GetSQL()
```
**Output**
```sql
	Select name,age From sample.person Where (Age BETWEEN 10 AND 50)
```

taking an optional Alias as second parameter
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name","nome").Column("age","idade").From("sample.person").Between("Age",10,50).GetSQL()
```
**Output**
```sql
	Select name As nome,age As idade From sample.person Where (Age BETWEEN 10 AND 50)
```

#### From(pTableName As %String)
FROM
Specifies the table used in the current query
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person
```

#### As(pAlias As %String)
Add an Alias for Table
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").As("pessoa").GetSQL()
```
**Output**
```sql
	Select name From sample.person As pessoa
```

#### %New(pTableName As %String)
Specifies the table used in the current query when create a SQLBuilder instance
```
	Write ##class(gen.SQLBuilder).%New("sample.person").Select("name, ssn").GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person
```

#### Limit(pNumberOfRows As %Integer = "")
Adds a TOP clause to the query
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").Limit(10).GetSQL()
```
**Output**
```sql
	Select TOP 10 name From sample.person
```

#### Order(pOrderBy As %String)
ORDER BY
```
	Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").Order("Name").GetSQL()
```
**Output**
```sql
	Select ID, Name, SSN From sample.person Order By Name
```

#### OrderBy(pOrderBy As %String)
ORDER BY
```
	Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").Order("Name").GetSQL()
```
**Output**
```sql
	Select ID, Name, SSN From sample.person Order By Name
```

#### Top(pNumberOfRows As %Integer = "")
Adds a TOP clause to the query
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").Top(10).GetSQL()
```
**Output**
```sql
	Select TOP 10 name From sample.person
```

#### TopIf(pCondition, pNumberOfRows As %Integer = "")
Adds a TOP clause to the query when a condition is true
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").TopIf(1=1,10).GetSQL()
```
**Output**
```sql
	Select TOP 10 name From sample.person
```
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").TopIf(2=1,10).GetSQL()
```
**Output**
```sql
	Select name From sample.person
```


### WHERE Clauses

#### And(args...)
Add an AND on Where
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").And("Age > ?", 10).GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo' AND Age > '10'
```

#### AndIf(pCondition, args...)
Add an AND on Where clause when a condition is true
First parameter is a boolean condition Second parameter is the instruction with one or multiples?
next arguments are the values
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").AndIf(5 > 5, "Age = ?", 5).GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo'
```
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").AndIf(10 > 1, "Age = ?", 10).GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo' AND Age = '10'
```

#### Between(pProp, pInferior, pSuperior, pType=0)
Add an BETWEEN on Where
first parameter is the column name
second and third parameters are the values
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Between("Age",10,50).GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person Where (Age BETWEEN 10 AND 50)
```

#### Or(args...)
Add an OR on Where clause
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").Or("Age = ?", 10).GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo' OR Age = '10'
```

#### OrIf(pCondition, args...)
Add an OR on Where clause when a condition is true
First parameter is a boolean condition Second parameter is the instruction with one or multiples?
next arguments are the values
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").OrIf(5 > 5, "Age = ?", 5).GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo'
```
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").OrIf(10 > 1, "Age = ?", 10).GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo' OR Age = '10'
```

#### In(pColumn, args...)
Adds an IN clause to the query
O primeiro parâmetro é o nome da coluna
Os demais parâmetros são os valores
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").In("age",10,20,30,40).GetSQL()
```
**Output**
```sql
	Select name From sample.person Where age In ('10','20','30','40')
```

#### InIf(pCondition, pColumn, args...)
Adds an IN clause to the query when a condition is true
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").InIf(5>5,"age",10,20,30,40).GetSQL()
```
**Output**
```sql
Select name From sample.person
```

```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").InIf(6>5,"age",10,20,30,40).GetSQL()
```
**Output**
```sql
	Select name From sample.person Where age In ('10','20','30','40')
```

#### NotIn(pColumn, args...)
Adds an NOT IN clause to the query
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").NotIn("age",10,20,30,40).GetSQL()
**Output**
```sql
	Select name From sample.person Where age Not In ('10','20','30','40')
```

#### NotInIf(pCondition, pColumn, args...)
Adds a NOT IN clause to the query when a condition is true

```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").NotInIf(5>5,"age",10,20,30,40).GetSQL()
```
**Output**
```sql
	Select name From sample.person
```
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").NotInIf(6>5,"age",10,20,30,40).GetSQL()
```
**Output**
```sql
	Select name From sample.person Where age Not In ('10','20','30','40')
```

#### Where(args...)
Add Where clause
First parameter is the instruction with one or multiples?
next arguments are the values
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo'
```

A complex example:
```
	Write ##class(gen.SQLBuilder).%New(
		).Select("ID, Name, SSN, Age").From("sample.person"
		).Where("Age In (?,?,?,?)",10,20,30,40).GetSQL()
```
**Output**
```sql
	Select ID, Name, SSN, Age From sample.person Where Age In ('10','20','30','40')
```

For multiples clauses will add an AND
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn"
		).From("sample.person").Where("Name %STARSTSWITH ?","Jo"
		).Where("Age > ?",10).GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo' AND Age > '10'
```

#### WhereIf(pCondition, args...)
Add a Where or an AND on Where clause when a condition is true
First parameter is a boolean condition Second parameter is the instruction with one or multiples?
next arguments are the values
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").WhereIf(5 > 5, "Age = ?", 5).GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person
```
```
	Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").WhereIf(10 > 1, "Age = ?", 10).GetSQL()
```
**Output**
```sql
	Select name, ssn From sample.person Where Age = '10'
```

#### WhereIn(pColumn, args...)
Adds an IN clause to the query
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereIn("age",10,20,30,40).GetSQL()
```
**Output**
```sql
	Select name From sample.person Where age In ('10','20','30','40')
```

#### WhereInIf(pCondition, pColumn, args...)
Adds an IN clause to the query when a condition is true

```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereInIf(5>5,"age",10,20,30,40).GetSQL()
```
**Output**
```sql
	Select name From sample.person
```
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereInIf(6>5,"age",10,20,30,40).GetSQL()
```
**Output**
```sql
	Select name From sample.person Where age In ('10','20','30','40')
```

#### WhereNotIn(pColumn, args...)
Adds an NOT IN clause to the query
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereNotIn("age",10,20,30,40).GetSQL()
```
**Output**
```sql
	Select name From sample.person Where age Not In ('10','20','30','40')
```

#### WhereNotInIf(pCondition, pColumn, args...)
Adds a NOT IN clause to the query when a condition is true

```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereNotInIf(5>5,"age",10,20,30,40).GetSQL()
```
**Output**
```sql
	Select name From sample.person
```
```
	Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereNotInIf(6>5,"age",10,20,30,40).GetSQL()
```
**Output**
```sql
	Select name From sample.person Where age Not In ('10','20','30','40')
```

### GROUP

#### GroupBy(pGroupBy As %String)
GROUP BY
```
	Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").GroupBy("Name").GetSQL()
```
**Output**
```sql
	Select ID, Name, SSN From sample.person Group By Name
```

Grouping on multiple fields is supported
```
	Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").GroupBy("Name").GroupBy("Age").GetSQL()
```
**Output**
```sql
	Select ID, Name, SSN From sample.person Group By Name,Age
```

#### Having(args...)
Add HAVING on GROUP BY clause
```
	Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").GroupBy("Name").Having("Age > ?", 50).GetSQL()
```
**Output**
```sql
	Select ID, Name, SSN From sample.person Group By Name Having Age > '50'
```

### JOIN Methods

#### Join(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "")
To add INNER JOIN between tables
The first argument being the table name with Alias, the next argument being the first join column and the second join column

```
 Write ##class(gen.SQLBuilder).%New(
	  ).From("sample.person").As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).Join("sample.Contact As C","P.ID","C.Person"
		).GetSQL()
```
**Output**
```sql
 Select P.ID, P.Name, P.SSN, C.Email, C.Phone
 From sample.person As P Inner Join sample.Contact As C On P.ID = C.Person
```

#### InnerJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "")
To add INNER JOIN between tables
The first argument being the table name with Alias, the next argument being the first join column and the second join column

```
 Write ##class(gen.SQLBuilder).%New(
	  ).From("sample.person").As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).JoinRaw("sample.Contact As C","P.ID = C.Person AND P.Name = C.Name"
		).GetSQL()
```
**Output**
```sql
	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Inner Join sample.Contact As C On P.ID = C.Person
```

#### InnerJoinRaw(pTable, pRawClause As %String = "")
To add INNER JOIN between tables
The first argument being the table name with Alias, the next argument the JOIN-ing condition

```
 Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
 	).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").JoinRaw("sample.Contact As C","P.ID = C.Person AND P.Name = C.Name").GetSQL()
```
**Output**
```sql
	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Inner Join sample.Contact As C On P.ID = C.Person
```

#### LeftJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "")
To do a LEFT JOIN between tables
The first argument being the table name with Alias, the next argument being the first join column and the second join column

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").LeftJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Left Join sample.Contact As C On P.ID = C.Person
```

#### LeftJoinRaw(pTable, pRawClause As %String)
To do a LEFT JOIN between tables
The first argument being the table name with Alias, the next argument the JOIN-ing condition

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").LeftJoinRaw("sample.Contact As C","P.ID = C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Left Join sample.Contact As C On P.ID = C.Person
```

#### LeftOuterJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "")
To do a LEFT OUTER JOIN between tables
The first argument being the table name with Alias, the next argument being the first join column and the second join column

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").LeftOuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Left Outer Join sample.Contact As C On P.ID = C.Person
```

#### LeftOuterJoinRaw(pTable, pRawClause As %String)
To do a LEFT OUTER JOIN between tables
The first argument being the table name with Alias, the next argument the JOIN-ing condition

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").LeftOuterJoinRaw("sample.Contact As C","P.ID = C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Left Join sample.Contact As C On P.ID = C.Person
```

#### CrossJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "")
To do a CROSS JOIN between tables
The first argument being the table name with Alias, the next argument being the first join column and the second join column

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
			).CrossJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Cross Join sample.Contact As C On P.ID = C.Person
```

#### CrossJoinRaw(pTable, pRawClause As %String)
To do a CROSS JOIN between tables
The first argument being the table name with Alias, the next argument the JOIN-ing condition

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
			).CrossJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Cross Join sample.Contact As C On P.ID = C.Person
```

#### FullOuterJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "")
To do a FULL OUTER JOIN between tables
The first argument being the table name with Alias, the next argument being the first join column and the second join column

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P").Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").FullOuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Full Outer Join sample.Contact As C On P.ID = C.Person
```

#### FullOuterJoinRaw(pTable, pRawClause As %String)
To do a FULL OUTER JOIN between tables
The first argument being the table name with Alias, the next argument the JOIN-ing condition

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P").Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").FullOuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Full Outer Join sample.Contact As C On P.ID = C.Person
```

#### OuterJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "")
To do an OUTER JOIN between tables
The first argument being the table name with Alias, the next argument being the first join column and the second join column

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
			).OuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Outer Join sample.Contact As C On P.ID = C.Person
```

#### OuterJoinRaw(pTable, pRawClause As %String)
To do an OUTER JOIN between tables
The first argument being the table name with Alias, the next argument the JOIN-ing condition

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
			).OuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Outer Join sample.Contact As C On P.ID = C.Person
```

#### RightJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "")
To do a RIGHT JOIN between tables
The first argument being the table name with Alias, the next argument being the first join column and the second join column

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
			).RightJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Right Join sample.Contact As C On P.ID = C.Person
```

#### RightJoinRaw(pTable, pRawClause As %String)
To do a RIGHT JOIN between tables
The first argument being the table name with Alias, the next argument the JOIN-ing condition

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
			).RightJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Right Join sample.Contact As C On P.ID = C.Person
```

#### RightOuterJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "")
To do a RIGHT OUTER JOIN between tables
The first argument being the table name with Alias, the next argument being the first join column and the second join column

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
			).RightOuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone
	From sample.person As P Right Outer Join sample.Contact As C On P.ID = C.Person
```

#### RightOuterJoinRaw(pTable, pRawClause As %String)
To do a RIGHT OUTER JOIN between tables
The first argument being the table name with Alias, the next argument the JOIN-ing condition

```
	Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
			).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
			).RightOuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
```
**Output**
```sql
 	Select P.ID, P.Name, P.SSN, C.Email, C.Phone
	From sample.person As P Right Outer Join sample.Contact As C On P.ID = C.Person
```

### UNION

#### Union(pSQL)
Creates a UNION Query
The parameter is another SQLBuilder object
```
	Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person"
		).Union( ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person")
	).GetSQL()
```
**Output**
```sql
	Select ID, Name, SSN From sample.person Union Select ID, Name, SSN From sample.person
```

#### UnionAll(pSQL)
Creates a UNION ALL Query
The parameter is another SQLBuilder object
```
	Write ##class(gen.SQLBuilder).%New(
		).Select("ID, Name, SSN").From("sample.person"
		).UnionAll( ##class(gen.SQLBuilder).%New(
		).Select("ID, Name, SSN").From("sample.person")
	).GetSQL()
```
**Output**
```sql
	Select ID, Name, SSN From sample.person
	Union All
	Select ID, Name, SSN From sample.person
```


## Authors ##

 * Leonardo "Metz" Metzger [github](https://github.com/leometzger)
 * Henry "HammZ" Hamon [github](https://github.com/henryhamon)

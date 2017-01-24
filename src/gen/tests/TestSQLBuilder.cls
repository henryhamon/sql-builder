Class gen.tests.TestSQLBuilder Extends Atomic.UnitTest.TestHelper
{

ClassMethod factory() As gen.SQLBuilder
{
	Quit ##class(gen.SQLBuilder).%New("sample.person")
}

Method TestSelect()
{
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person")
	Do ..Eql(sqlBuilder.GetSQL(),"Select name, ssn From sample.person")
}

Method TestSelectAll()
{
	Set sqlBuilder = ..factory().Select().From("sample.person")
	Do ..Is(sqlBuilder.GetSQL(),"Select * From sample.person")
}

Method TestWhere()
{
	
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person"
		).Where("Name %STARSTSWITH ?","Jo")
		
	Do ..Eql(sqlBuilder.GetSQL(),"Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo'")
}

Method TestOrderBy()
{
	
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person"
		).Order("Name")
		
	Do ..Eql(sqlBuilder.GetSQL(),"Select ID, Name, SSN From sample.person Order By Name")
}

Method TestBetween()
{
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN, Age").From("sample.person"
		).Between("Age",10,50)
		
	Do ..Eql(sqlBuilder.GetSQL(),"Select ID, Name, SSN, Age From sample.person Where (Age BETWEEN 10 AND 50)")
}

Method TestAndCondition()
{
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN, Age").From("sample.person"
		).Between("Age",10,50).And("Name %STARSTSWITH ?","Jo")
		
	Do ..Eql(sqlBuilder.GetSQL(),"Select ID, Name, SSN, Age From sample.person Where (Age BETWEEN 10 AND 50) AND Name %STARSTSWITH 'Jo'")
}

Method TestComplexWhere()
{
	
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN, Age").From("sample.person"
		).Where("Age In (?,?,?,?)",10,20,30,40)
		
	Do ..Eql(sqlBuilder.GetSQL(),"Select ID, Name, SSN, Age From sample.person Where Age In ('10','20','30','40')")
}

Method TestFixedArgument()
{
	
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN, Age").From("sample.person"
		).Where("Age = 10")
		
	Do ..Eql(sqlBuilder.GetSQL(),"Select ID, Name, SSN, Age From sample.person Where Age = 10")
}

Method TestSimpleUpdate()
{
	Set age = $Random(90)+1
	Set sqlBuilder = ##class(gen.SQLBuilder).%New("sample.person").Update(
		).Set("Name", "Nathan Drake"
		).Set("Age", age).Where("ID = ?",10)
	
	Do ..Eql(sqlBuilder.GetSQL(),"Update sample.person SET Age = '"_age_"', Name = 'Nathan Drake' Where ID = '10'")
}

Method TestSimpleInsert()
{
	Set age = $Random(90)+1
	Set sqlBuilder = ..factory().Insert(
		).Set("Name", "Nathan Drake"
		).Set("Age", age)
	
	Do ..Eql(sqlBuilder.GetSQL(),"Insert INTO sample.person  (Age, Name) VALUES ('"_age_"', 'Nathan Drake' )")
}

Method TestUpdateSetCase()
{
	Set sqlBuilder = ..factory().Update(
		).Set("FavoriteColors = (CASE "
						_"WHEN (Age = 1) THEN 'Red' "
						_"WHEN (Age = 2) THEN 'Orange' "
						_"WHEN (Age = 3) THEN 'Yellow' "
						_"WHEN (Age = 4) THEN 'Green' "
						_"WHEN (Age = 5) THEN 'Blue' "
						_"WHEN (Age = 6) THEN 'Purple' END)",,$$$YES)
	
	Do ..Eql(sqlBuilder.GetSQL(),"Update sample.person SET FavoriteColors = (CASE "
						_"WHEN (Age = 1) THEN 'Red' "
						_"WHEN (Age = 2) THEN 'Orange' "
						_"WHEN (Age = 3) THEN 'Yellow' "
						_"WHEN (Age = 4) THEN 'Green' "
						_"WHEN (Age = 5) THEN 'Blue' "
						_"WHEN (Age = 6) THEN 'Purple' END)")
}

Method testIf()
{
}

Method TestSubQueryOnWhere()
{
	Set sqlBuilder = ..factory(
		).Select("ID, Name, SSN, Age"
		).Where("Age =?",##class(gen.SQLBuilder).%New("sample.person"
			).Select("Age").Where("Name = ?","Luke Skywalker")
		)

	Do ..Is(sqlBuilder.GetSQL(),"Select ID, Name, SSN, Age From sample.person Where Age =(Select Age From sample.person Where Name = 'Luke Skywalker')")
}

Method TestSelectColumn()
{
	Set sqlBuilder = ..factory(
		).Select().Column("ID").Column("Name").Where("Age > ?",10)
		
	Do ..Is(sqlBuilder.GetSQL(), "Select ID,Name From sample.person Where Age > '10'" )
	
	
	Set sqlBuilder = ..factory(
		).Select("ID").Column("Name").Where("Age > ?",10)
		
	Do ..Is(sqlBuilder.GetSQL(), "Select ID,Name From sample.person Where Age > '10'" )
	
	
	Set sqlBuilder = ..factory(
		).Select("ID").Column("Name").Column("Age","Ages").Where("Age > ?",10)
		
	Do ..Is(sqlBuilder.GetSQL(), "Select ID,Name,Age As Ages From sample.person Where Age > '10'" )
}

Method TestSubqueryOnSelect()
{
	Set sqlBuilder = ..factory(
		).Select().Column("ID").Column("Name").Where("Age > ?",10)
	Do ..Is(sqlBuilder.GetSQL(), "Select ID,Name From sample.person Where Age > '10'" )
		
	Do sqlBuilder.Column(..factory().Select("Age").Where("Age < ?",50).As("Ages"))
	
	Do ..Is(sqlBuilder.GetSQL(), "Select ID,Name,(Select Age From sample.person Where Age < '50') As Ages From sample.person Where Age > '10'" )
}

Method TestTableAlias()
{
	
	Set sqlBuilder = ..factory().Column("ID"
		).Column( ..factory().Select("Age").Where("Age < ?",50).As("Ages")
	).Where("Age > ?",10)

	Do ..Is(sqlBuilder.GetSQL(), "Select ID,(Select Age From sample.person Where Age < '50') As Ages From sample.person Where Age > '10'" )
	
	Set sqlBuilder = ..factory().Column("ID"
		).Column(..factory().Select("Age").Where("Age < ?",50).As("Ages")
	).Where("Age > ?",10).As("First")

	Do ..Is(sqlBuilder.GetSQL(), "Select ID,(Select Age From sample.person Where Age < '50') As Ages From sample.person As First Where Age > '10'" )
}

}


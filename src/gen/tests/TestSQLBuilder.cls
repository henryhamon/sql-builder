Class gen.tests.TestSQLBuilder Extends Atomic.UnitTest.TestHelper
{

Method TestSelect()
{
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person")
	Do ..Eql(sqlBuilder.GetSQL(),"Select name, ssn From sample.person")
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

Method testIf()
{
}

}


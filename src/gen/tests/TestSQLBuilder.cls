Class gen.tests.TestSQLBuilder Extends %UnitTest.TestCase
{

ClassMethod factory() As gen.SQLBuilder
{
	Quit ##class(gen.SQLBuilder).%New("sample.person")
}

Method TestSelect()
{
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person")
	Do $$$AssertEquals(sqlBuilder.GetSQL(),"Select name, ssn From sample.person")
}

Method TestSelectAll()
{
	Set sqlBuilder = ..factory().Select().From("sample.person")
	Do $$$AssertEquals(sqlBuilder.GetSQL(),"Select * From sample.person")
}

Method TestWhere()
{

	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person"
		).Where("Name %STARSTSWITH ?","Jo")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),"Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo'")
}

Method TestOrderBy()
{

	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person"
		).Order("Name")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),"Select ID, Name, SSN From sample.person Order By Name")
}

Method TestBetween()
{
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN, Age").From("sample.person"
		).Between("Age",10,50)

	Do $$$AssertEquals(sqlBuilder.GetSQL(),"Select ID, Name, SSN, Age From sample.person Where (Age BETWEEN 10 AND 50)")
}

Method TestAndCondition()
{
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN, Age").From("sample.person"
		).Between("Age",10,50).And("Name %STARSTSWITH ?","Jo")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),"Select ID, Name, SSN, Age From sample.person Where (Age BETWEEN 10 AND 50) AND Name %STARSTSWITH 'Jo'")
}

Method TestComplexWhere()
{

	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN, Age").From("sample.person"
		).Where("Age In (?,?,?,?)",10,20,30,40)

	Do $$$AssertEquals(sqlBuilder.GetSQL(),"Select ID, Name, SSN, Age From sample.person Where Age In ('10','20','30','40')")
}

Method TestFixedArgument()
{

	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN, Age").From("sample.person"
		).Where("Age = 10")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),"Select ID, Name, SSN, Age From sample.person Where Age = 10")
}

Method TestSimpleUpdate()
{
	Set age = $Random(90)+1
	Set sqlBuilder = ##class(gen.SQLBuilder).%New("sample.person").Update(
		).Set("Name", "Nathan Drake"
		).Set("Age", age).Where("ID = ?",10)

	Do $$$AssertEquals(sqlBuilder.GetSQL(),"Update sample.person SET Age = '"_age_"', Name = 'Nathan Drake' Where ID = '10'")
}

Method TestSimpleInsert()
{
	Set age = $Random(90)+1
	Set sqlBuilder = ..factory().Insert(
		).Set("Name", "Nathan Drake"
		).Set("Age", age)

	Do $$$AssertEquals(sqlBuilder.GetSQL(),"Insert INTO sample.person  (Age, Name) VALUES ('"_age_"', 'Nathan Drake' )")
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

	Set expected = "Update sample.person SET FavoriteColors = (CASE "
						_"WHEN (Age = 1) THEN 'Red' "
						_"WHEN (Age = 2) THEN 'Orange' "
						_"WHEN (Age = 3) THEN 'Yellow' "
						_"WHEN (Age = 4) THEN 'Green' "
						_"WHEN (Age = 5) THEN 'Blue' "
						_"WHEN (Age = 6) THEN 'Purple' END)"

	Do $$$AssertEquals(sqlBuilder.GetSQL(), expected)
}

Method TestSubQueryOnWhere()
{
	Set sqlBuilder = ..factory(
		).Select("ID, Name, SSN, Age"
		).Where("Age =?",##class(gen.SQLBuilder).%New("sample.person"
			).Select("Age").Where("Name = ?","Luke Skywalker")
		)

	Do $$$AssertEquals(sqlBuilder.GetSQL(),"Select ID, Name, SSN, Age From sample.person Where Age =(Select Age From sample.person Where Name = 'Luke Skywalker')")
}

Method TestSelectColumn()
{
	Set sqlBuilder = ..factory(
		).Select().Column("ID").Column("Name").Where("Age > ?",10)

	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select ID,Name From sample.person Where Age > '10'" )


	Set sqlBuilder = ..factory(
		).Select("ID").Column("Name").Where("Age > ?",10)

	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select ID,Name From sample.person Where Age > '10'" )


	Set sqlBuilder = ..factory(
		).Select("ID").Column("Name").Column("Age","Ages").Where("Age > ?",10)

	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select ID,Name,Age As Ages From sample.person Where Age > '10'" )
}

Method TestSubqueryOnSelect()
{
	Set sqlBuilder = ..factory(
		).Select().Column("ID").Column("Name").Where("Age > ?",10)
	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select ID,Name From sample.person Where Age > '10'" )

	Do sqlBuilder.Column(..factory().Select("Age").Where("Age < ?",50).As("Ages"))

	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select ID,Name,(Select Age From sample.person Where Age < '50') As Ages From sample.person Where Age > '10'" )
}

Method TestTableAlias()
{

	Set sqlBuilder = ..factory().Column("ID"
		).Column( ..factory().Select("Age").Where("Age < ?",50).As("Ages")
	).Where("Age > ?",10)

	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select ID,(Select Age From sample.person Where Age < '50') As Ages From sample.person Where Age > '10'" )

	Set sqlBuilder = ..factory().Column("ID"
		).Column(..factory().Select("Age").Where("Age < ?",50).As("Ages")
	).Where("Age > ?",10).As("First")

	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select ID,(Select Age From sample.person Where Age < '50') As Ages From sample.person As First Where Age > '10'" )
}

Method TestUnion()
{
	Set sqlBuilder = ..factory().Where("Age = ?", 10).Union(..factory().Where("Age = ?", 15))

	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select * From sample.person Where Age = '10' Union Select * From sample.person Where Age = '15'")
}

Method TestUnionAll()
{
	Set sqlBuilder = ..factory().Where("Age = ?", 10).UnionAll(..factory().Where("Age = ?", 15))

	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select * From sample.person Where Age = '10' Union All Select * From sample.person Where Age = '15'")
}

Method TestJoin()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Inner Join sample.Contact As C On P.ID = C.Person"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).Join("sample.Contact As C","P.ID","C.Person")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).InnerJoin("sample.Contact As C","P.ID","C.Person")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestInnerJoinRaw()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Inner Join sample.Contact As C On (P.ID = C.Person AND P.Name = C.Name)"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).InnerJoinRaw("sample.Contact As C", "P.ID = C.Person AND P.Name = C.Name")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestJoinWithMultipleClauses()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Inner Join sample.Contact As C On (P.ID = C.Person AND P.Name = C.Name)"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).Join("sample.Contact As C",,, "P.ID = C.Person AND P.Name = C.Name")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).InnerJoin("sample.Contact As C",,, "P.ID = C.Person AND P.Name = C.Name")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestJoinWithMultipleClausesProtected()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).Join("sample.Contact As C",,, "Select P.ID From Table WHERE P.Name = C.Name")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).InnerJoin("sample.Contact As C",,, "Insert Into Table")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestLeftJoin()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Left Join sample.Contact As C On P.ID = C.Person"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).LeftJoin("sample.Contact As C","P.ID","C.Person")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestLeftOuterJoin()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Left Outer Join sample.Contact As C On P.ID = C.Person"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).LeftOuterJoin("sample.Contact As C","P.ID","C.Person")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestLeftJoinRaw()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Left Join sample.Contact As C On (P.ID = C.Person AND P.Name = C.Name)"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).LeftJoinRaw("sample.Contact As C", "P.ID = C.Person AND P.Name = C.Name")

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).LeftJoin("sample.Contact As C",,, "P.ID = C.Person AND P.Name = C.Name")
	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestLeftOuterJoinRaw()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Left Outer Join sample.Contact As C On (P.ID = C.Person AND P.Name = C.Name)"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).LeftOuterJoinRaw("sample.Contact As C", "P.ID = C.Person AND P.Name = C.Name")

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).LeftOuterJoin("sample.Contact As C",,, "P.ID = C.Person AND P.Name = C.Name")
	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestRightOuterJoinRaw()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Right Outer Join sample.Contact As C On (P.ID = C.Person AND P.Name = C.Name)"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).RightOuterJoinRaw("sample.Contact As C", "P.ID = C.Person AND P.Name = C.Name")

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).RightOuterJoin("sample.Contact As C",,, "P.ID = C.Person AND P.Name = C.Name")
	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestRightJoinRaw()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Right Join sample.Contact As C On (P.ID = C.Person AND P.Name = C.Name)"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).RightJoinRaw("sample.Contact As C", "P.ID = C.Person AND P.Name = C.Name")

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).RightJoin("sample.Contact As C",,, "P.ID = C.Person AND P.Name = C.Name")
	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestOuterJoin()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Outer Join sample.Contact As C On P.ID = C.Person"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).OuterJoin("sample.Contact As C","P.ID","C.Person")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestOuterJoinRaw()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Outer Join sample.Contact As C On (P.ID = C.Person AND P.Name = C.Name)"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).OuterJoinRaw("sample.Contact As C", "P.ID = C.Person AND P.Name = C.Name")

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).OuterJoin("sample.Contact As C",,, "P.ID = C.Person AND P.Name = C.Name")
	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestCrossJoin()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Cross Join sample.Contact As C On P.ID = C.Person"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).CrossJoin("sample.Contact As C","P.ID","C.Person")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestCrossJoinRaw()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Cross Join sample.Contact As C On (P.ID = C.Person AND P.Name = C.Name)"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).CrossJoinRaw("sample.Contact As C", "P.ID = C.Person AND P.Name = C.Name")

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).CrossJoin("sample.Contact As C",,, "P.ID = C.Person AND P.Name = C.Name")
	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestRightJoin()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Right Join sample.Contact As C On P.ID = C.Person"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).RightJoin("sample.Contact As C","P.ID","C.Person")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestRightOuterJoin()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Right Outer Join sample.Contact As C On P.ID = C.Person"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).RightOuterJoin("sample.Contact As C","P.ID","C.Person")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestFullOuterJoin()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Full Outer Join sample.Contact As C On P.ID = C.Person"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).FullOuterJoin("sample.Contact As C","P.ID","C.Person")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestFullOuterJoinRaw()
{
	Set join = "Select P.ID, P.Name, P.SSN, C.Email, C.Phone "_
			"From sample.person As P "_
			"Full Outer Join sample.Contact As C On (P.ID = C.Person AND P.Name = C.Name)"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).FullOuterJoinRaw("sample.Contact As C", "P.ID = C.Person AND P.Name = C.Name")

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
		).FullOuterJoin("sample.Contact As C",,, "P.ID = C.Person AND P.Name = C.Name")
	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestJoinSubQuery()
{
	Set join = "Select P.ID, P.Name, P.SSN "_
		"From sample.person As P "_
		"Inner Join (Select Person From sample.contact) As C On P.ID = C.Person"

	Set sqlBuilder = ..factory().As("P"
		).Select("P.ID, P.Name, P.SSN"
		).Join( ##class(gen.SQLBuilder).%New("sample.contact"
					).Select("Person").As("C") ,"P.ID","C.Person")

	Do $$$AssertEquals(sqlBuilder.GetSQL(),join)
}

Method TestUpdate()
{
	Set id = $Random(10)+1, name = "John Snow",
		sql = "Update sample.person SET Name = '"_name_"' "_
				"Where Id = '"_id_"'",
		sqlBuilder = ..factory().Update(
			).Set("Name", name
			).Where("Id = ?",id	)

	Do $$$AssertEquals(sqlBuilder.GetSQL(),sql)
}

Method TestUpdateSetIf()
{
	Set id = 5, name = "John Snow",
		sql1 = "Update sample.person SET Name = '"_name_"' Where Id = '5'",
		sql2 = "Update sample.person SET Age = '30', Name = '"_name_"' Where Id = '6'",
		sqlBuilder1 = ..factory().Update(
			).Set("Name", name
			).SetIf( id>5, "Age", 30
			).Where("Id = ?",id),
		id = 6,
		sqlBuilder2 = ..factory().Update(
			).Set("Name", name
			).SetIf( id>5, "Age", 30
			).Where("Id = ?",id)

	Do $$$AssertEquals(sqlBuilder1.GetSQL(),sql1)
	Do $$$AssertEquals(sqlBuilder2.GetSQL(),sql2)
}

Method TestHaving()
{
	Set sql = "Select Count(1) As Elders,Age From sample.person Group By Age Having Age > '50'",
		sqlBuilder = ..factory().Select("Count(1) As Elders"
			).Column("Age"
			).GroupBy("Age"
			).Having("Age > ?",50)

	Do $$$AssertEquals(sqlBuilder.GetSQL(),sql)
}

Method TestByParam()
{
	Set sqlBuilder = ..factory().ByParams().Select("Name").Where("Age = ?")

	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select Name From sample.person Where Age = ?")
}

Method TestSQLInjection()
{
	Set sqlBuilder = ..factory().ByParams().Select("Name").Where("Age = ?", "10' OR '1'='1'")
	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select Name From sample.person Where Age = ?")
}

Method TestClone()
{
		Set sqlBuilder = ..factory()
		D $$$AssertTrue(sqlBuilder '= sqlBuilder.Clone())
}

Method TestSanitize()
{
	Set sqlBuilder = ..factory().Select("Name").Where("Thing = ?", "BASO#")
	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select Name From sample.person Where Thing = 'BASO#'")
}

Method TestLike()
{
	Set sqlBuilder = ..factory().Select("Name").Where("Thing Like '%?%'", "BASO#")
	Do $$$AssertEquals(sqlBuilder.GetSQL(), "Select Name From sample.person Where Thing Like '%BASO#%'")
}

}

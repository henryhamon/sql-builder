Class gen.tests.TestSQLBuilder Extends Atomic.UnitTest.TestHelper
{

Method testSelect()
{
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("id, nome").From("person")
	Do ..Eql(sqlBuilder.GetSQL(),"Select id, nome From person")
}

Method testEntreDatas()
{
	
	Set sqlBuilder = ##class(gen.SQLBuilder).%New().Select("id, nome").From("")
}

Method testIf()
{
}

}


Class gen.SQLBuilder Extends %RegisteredObject
{

Parameter Version = "0.2.2";

Parameter Codename = "Brown Ramshorn Snails";

Property Select As %String [ InitialExpression = "*", Internal ];

Property Update As %String [ Internal ];

Property From As %String [ Internal ];

Property Where As %String [ Internal ];

Property GroupBy As %String [ Internal ];

Property OrderBy As %String [ Internal ];

Property Fields As %ArrayOfDataTypes [ Private ];

Property Columns As %ListOfDataTypes [ Private ];

Property TableAlias As %String [ Private ];

Property UsedAsSubQuery As %Boolean [ InitialExpression = 0, Private ];

Property Union As %String [ Private ];

Property Join As %ListOfDataTypes [ Private ];

Property Having As %String [ Private ];

Property Statement As %Integer(DISPLAYLIST = ",Select,Update,Insert,Delete", VALUELIST = ",1,2,3,4") [ InitialExpression = 1, Internal ];

Property ByParams As %Boolean [ InitialExpression = 0, Private ];

Property SQLStatement As %SQL.Statement;

Property ResultSet As %ResultSet;

Property SQLType As %String(DISPLAYLIST = ",ResultSet,Statement", VALUELIST = ",RS,ST");

Property Info As %ZEN.Auxiliary.QueryInfo;

Property RuntimeMode As %Integer [ InitialExpression = 0 ];

Property WasPreperedBefore As %Boolean [ InitialExpression = 0 ];

Property Top As %String [ Private ];

Method SubQueryAlias()
{
	Do ..IsSubQuery()
	Quit ..TableAlias
}

Method IsSubQuery()
{
	Set ..UsedAsSubQuery = $$$YES
}

Method Delete(params As %String = "") As gen.SQLBuilder
{
	Set ..Select = ""
	Set ..Update = ""
	Set ..Statement = 4
	Quit $This
}

/// Creates a <b>Select</b> query<br />
/// taking an optional line string of columns for the query with comma separator<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").GetSQL()
/// ; Select name, ssn From sample.person
/// </example>
/// <br/>
/// defaulting to * if none are specified when the query is built<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().From("sample.person").GetSQL()
/// ; Select * From sample.person
/// </example>
/// <br/>
Method Select(params As %String = "") As gen.SQLBuilder
{
	If params'="" {
		Set auxList = $ListFromString(params,",")
		Set select = ""
		For k=1:1:$ListLength(auxList) {
			Set:$List(auxList,k)'="" $List(select,*+1) = $List(auxList,k)
		}
		Set ..Select = $ListToString(select,",")
	}
	Set ..Statement = 1
	Quit $This
}

Method Update() As gen.SQLBuilder
{
	Set ..Select = ""
	Set ..Statement = 2
	Quit $This
}

Method Insert() As gen.SQLBuilder
{
	Set ..Select = ""
	Set ..Statement = 3
	Quit $This
}

Method Set(pField As %String, pValue As %String = "", pAllowNull As %Boolean = 0) As gen.SQLBuilder
{
	Do:((pValue'="")||(pAllowNull=$$$YES)||(..ByParams=$$$YES)) ..AddField(pField, pValue)
	Quit $This
}

Method SetIf(pCondition As %Boolean, args...) As gen.SQLBuilder
{
	Quit:pCondition ..Set(args...)
	Quit $This
}

/// Add <em>Columns</em> on <b>Select</b> query<br />
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").Column("age").From("sample.person").Between("Age",10,50).GetSQL()
/// ; Select name,age From sample.person Where (Age BETWEEN 10 AND 50)
/// </example>
/// <br/>
/// taking an optional <em>Alias</em> as second parameter<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name","nome").Column("age","idade").From("sample.person").Between("Age",10,50).GetSQL()
/// ; Select name As nome,age As idade From sample.person Where (Age BETWEEN 10 AND 50)
/// </example>
/// <br/>
Method Column(pField, pAlias As %String = "") As gen.SQLBuilder
{
	If ($IsObject(pField)&&($ClassName(pField)=$ClassName($This))) {
		Do pField.IsSubQuery()
		Set pField = "("_ pField.GetSQL() _ ")" _
			$Case(pField.SubQueryAlias(),"":"",:" As " _ pField.SubQueryAlias())
	}

	Set:pAlias'="" pField = pField _ " As " _ pAlias
	Do ..Columns.Insert(pField)
	Quit $This
}

/// Add an <em>Alias</em> for Table<br />
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").As("pessoa").GetSQL()
/// ; Select name From sample.person As pessoa
/// </example>
/// <br/>
Method As(pAlias As %String) As gen.SQLBuilder
{
	Set ..TableAlias = pAlias
	Quit $This
}

/// <b>FROM</b><br />
/// Specifies the table used in the current query<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").GetSQL()
/// ; Select name, ssn From sample.person
/// </example>
/// <br/>
Method From(pFrom As %String) As gen.SQLBuilder
{
	Set ..From = pFrom
	Quit $This
}

/// Add <b>Where</b> clause<br />
/// First parameter is the instruction with one or multiples<em>?</em> <br/>
/// next arguments are the values<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").GetSQL()
/// ; Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo'
/// </example>
/// <br/>
/// A complex example:<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN, Age").From("sample.person").Where("Age In (?,?,?,?)",10,20,30,40).GetSQL()
/// ; Select ID, Name, SSN, Age From sample.person Where Age In ('10','20','30','40')
/// </example>
/// <br/>
/// For multiples clauses will add an <em>AND</em><br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").Where("Age > ?",10).GetSQL()
/// ; Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo' AND Age > '10'
/// </example>
/// <br/>
Method Where(args...) As gen.SQLBuilder
{
	Set result = ..GetStringPrepare(args...)
	Quit:result="" $This
	Quit ..WhereInterno(result)
}

Method WhereInterno(pWhere As %String, pAndOr = 0) As gen.SQLBuilder [ Internal, Private ]
{
	If ..Where=""{
		Set ..Where = pWhere
	} Else {
		Set:..Where'="" ..Where = ..Where _ $Case(pAndOr,0:" AND ",1:" OR ") _ pWhere
	}
	Quit $This
}

/// Add an <em>OR</em> on <b>Where</b> clause<br />
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").Or("Age = ?", 10).GetSQL()
/// ; Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo' OR Age = '10'
/// </example>
/// <br/>
Method Or(args...) As gen.SQLBuilder
{
	Set result = ..GetStringPrepare(args...)
	Quit:result="" $This
	Quit ..WhereInterno(result,1)
}

/// Add an <em>AND</em> on <b>Where</b> <br />
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").And("Age > ?", 10).GetSQL()
/// ; Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo' AND Age > '10'
/// </example>
/// <br/>
Method And(args...) As gen.SQLBuilder
{
	Set result = ..GetStringPrepare(args...)
	Quit:result="" $This
	Quit ..WhereInterno(result)
}

/// Add an <em>BETWEEN</em> on <b>Where</b> <br />
/// first parameter is the column name <br/>
/// second and third parameters are the values
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Between("Age",10,50).GetSQL()
/// ; Select name, ssn From sample.person Where (Age BETWEEN 10 AND 50)
/// </example>
/// <br/>
Method Between(pProp, pInferior, pSuperior, pType = 0) As gen.SQLBuilder
{
	Set sql = "(" _ pProp _ " BETWEEN " _ pInferior _ " AND " _ pSuperior _ ")"
	Quit ..WhereInterno(sql)
}

/// To add <em>INNER JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument being the first join column and the second join column
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P").Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").Join("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Inner Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method Join(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "") As gen.SQLBuilder
{
	Quit ..InnerJoin(pTable, pFirst, pSecond, pRawClause)
}

/// To add <em>INNER JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument the JOIN-ing condition
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 	).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").JoinRaw("sample.Contact As C","P.ID = C.Person AND P.Name = C.Name").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Inner Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method InnerJoinRaw(pTable, pRawClause As %String = "") As gen.SQLBuilder
{
	Quit ..InnerJoin(pTable, , , pRawClause)
}

/// To add <em>INNER JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument being the first join column and the second join column
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P").Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").Join("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Inner Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method InnerJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "") As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Inner", pTable, pFirst, pSecond, pRawClause))
	Quit $This
}

/// To do a <em>LEFT JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument being the first join column and the second join column
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").LeftJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Left Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method LeftJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "") As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Left",pTable, pFirst, pSecond, pRawClause))
	Quit $This
}

/// To do a <em>LEFT JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument the JOIN-ing condition
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").LeftJoinRaw("sample.Contact As C","P.ID = C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Left Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method LeftJoinRaw(pTable, pRawClause As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Left",pTable, , ,pRawClause))
	Quit $This
}

/// To do a <em>LEFT OUTER JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument being the first join column and the second join column
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").LeftOuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Left Outer Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method LeftOuterJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "") As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Left Outer",pTable, pFirst, pSecond, pRawClause))
	Quit $This
}

/// To do a <em>LEFT OUTER JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument the JOIN-ing condition
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").LeftOuterJoinRaw("sample.Contact As C","P.ID = C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Left Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method LeftOuterJoinRaw(pTable, pRawClause As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Left Outer",pTable, , ,pRawClause))
	Quit $This
}

/// To do a <em>RIGHT JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument being the first join column and the second join column
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
/// 		).RightJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Right Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method RightJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "") As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Right",pTable, pFirst, pSecond, pRawClause))
	Quit $This
}

/// To do a <em>RIGHT JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument the JOIN-ing condition
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
/// 		).RightJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Right Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method RightJoinRaw(pTable, pRawClause As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Right",pTable, , ,pRawClause))
	Quit $This
}

/// To do a <em>RIGHT OUTER JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument being the first join column and the second join column
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
/// 		).RightOuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Right Outer Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method RightOuterJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "") As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Right Outer",pTable, pFirst, pSecond, pRawClause))
	Quit $This
}

/// To do a <em>RIGHT OUTER JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument the JOIN-ing condition
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
/// 		).RightOuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Right Outer Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method RightOuterJoinRaw(pTable, pRawClause As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Right Outer",pTable, , , pRawClause))
	Quit $This
}

/// To do an <em>OUTER JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument being the first join column and the second join column
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
/// 		).OuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Outer Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method OuterJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "") As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Outer",pTable, pFirst, pSecond, pRawClause))
	Quit $This
}

/// To do an <em>OUTER JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument the JOIN-ing condition
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
/// 		).OuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Outer Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method OuterJoinRaw(pTable, pRawClause As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Outer",pTable, , , pRawClause))
	Quit $This
}

/// To do a <em>FULL OUTER JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument being the first join column and the second join column
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P").Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").FullOuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Full Outer Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method FullOuterJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "") As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Full Outer",pTable, pFirst, pSecond, pRawClause))
	Quit $This
}

/// To do a <em>FULL OUTER JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument the JOIN-ing condition
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P").Select("P.ID, P.Name, P.SSN, C.Email, C.Phone").FullOuterJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Full Outer Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method FullOuterJoinRaw(pTable, pRawClause As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Full Outer",pTable, , , pRawClause))
	Quit $This
}

/// To do a <em>CROSS JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument being the first join column and the second join column
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
/// 		).CrossJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Cross Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method CrossJoin(pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "") As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Cross",pTable, pFirst, pSecond, pRawClause))
	Quit $This
}

/// To do a <em>CROSS JOIN</em> between tables <br />
/// The first argument being the table name with Alias,
/// the next argument the JOIN-ing condition
/// <code>
/// Write ##class(gen.SQLBuilder).%New().From("sample.person").As("P"
/// 		).Select("P.ID, P.Name, P.SSN, C.Email, C.Phone"
/// 		).CrossJoin("sample.Contact As C","P.ID","C.Person").GetSQL()
/// ; Select P.ID, P.Name, P.SSN, C.Email, C.Phone From sample.person As P Cross Join sample.Contact As C On P.ID = C.Person
/// </code>
/// <br/>
Method CrossJoinRaw(pTable, pRawClause As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Cross",pTable, , , pRawClause))
	Quit $This
}

ClassMethod JoinPrepare(pJoinSyntax As %String, pTable, pFirst As %String = "", pSecond As %String = "", pRawClause As %String = "") As %String [ Private ]
{
	If $IsObject(pTable) {
		If $ClassName(pTable)=$ClassName($This) {
			Do pTable.IsSubQuery()
			Set pTable = "("_ pTable.GetSQL() _ ")" _
				$Case(pTable.SubQueryAlias(),"":"",:" As " _ pTable.SubQueryAlias())
		}
	}

	Quit:(pRawClause = "") pJoinSyntax _ " Join "_ pTable _" On "_ pFirst _ " = " _ pSecond

	Set aux = $ZConvert(pRawClause, "l")
	Set:($Find(aux, "select ", 1)||$Find(aux, "delete ")||$Find(aux, "insert ")) pRawClause = ""
	Quit:((pFirst = "") && (pSecond = "") && (pRawClause '= "")) pJoinSyntax _ " Join "_ pTable _" On ("_ pRawClause _ ")"
	Quit ""
}

Method GetStringPrepare(args...) As %String [ Private ]
{
	Set output = ""
	Quit:..ByParams=$$$YES $Get(args(1))

	Try {
		Set output = $Get(args(1))

		If $Get(args,0) > 1 {
			Set k = 2, sanitize = "'"

			Set:$Find($ZConvert(output,"U"),"LIKE")>0 sanitize = "#"
			Set matcher = $ListFromString(output,"?"), output = ""

			For i=1:1:$ListLength(matcher) {
				Set got = "", arg = $Get(args(k))

				If $IsObject(arg){
					Set:$ClassName(arg)=$ClassName($This) got = "(" _ arg.GetSQL()_")"
				} Else {
					Set:(arg'="") got = sanitize_$Replace(arg,"'","")_sanitize
				}

				Set output = output _ $List(matcher,i) _ got
				Set k = $Increment(k)
			}

			Set:$Find(output,"''")>0 output = ""
			Set:$Find(output,"##")>0 output = ""
			Set:output'="" output = $Replace(output,"#","")
		}
	} Catch {
		Set output = ""
	}
	Quit output
}

/// <em>ORDER BY</em>  <br />
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").Order("Name").GetSQL()
/// ; Select ID, Name, SSN From sample.person Order By Name
/// </example>
/// <br/>
Method Order(pOrderBy As %String) As gen.SQLBuilder
{
	Set ..OrderBy = ""
	Quit ..OrderBy(pOrderBy)
}

/// <em>ORDER BY</em>  <br />
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").Order("Name").GetSQL()
/// ; Select ID, Name, SSN From sample.person Order By Name
/// </example>
/// <br/>
Method OrderBy(pOrderBy As %String) As gen.SQLBuilder
{
	Set:..OrderBy'="" ..OrderBy = ..OrderBy _ "," _ pOrderBy
	Set:..OrderBy="" ..OrderBy = pOrderBy
	Quit $This
}

/// <em>GROUP BY</em>  <br />
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").GroupBy("Name").GetSQL()
/// ; Select ID, Name, SSN From sample.person Group By Name
/// </example>
/// <br/>
/// Grouping on multiple fields is supported <br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").GroupBy("Name").GroupBy("Age").GetSQL()
/// ; Select ID, Name, SSN From sample.person Group By Name,Age
/// </example>
Method GroupBy(pGroupBy As %String) As gen.SQLBuilder
{
	Set:..GroupBy'="" ..GroupBy = ..GroupBy _ "," _ pGroupBy
	Set:..GroupBy="" ..GroupBy = pGroupBy
	Quit $This
}

/// Add an <em>AND</em> on <b>Where</b> clause when a condition is true<br />
/// First parameter is a boolean condition
/// Second parameter is the instruction with one or multiples<em>?</em> <br/>
/// next arguments are the values<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").AndIf(5 > 5, "Age = ?", 5).GetSQL()
/// ; Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo'
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").AndIf(10 > 1, "Age = ?", 10).GetSQL()
/// ; Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo' AND Age = '10'
/// </example>
/// <br/>
Method AndIf(pCondition, args...) As gen.SQLBuilder
{
	Quit:pCondition ..And(args...)
	Quit $This
}

/// Add an <em>OR</em> on <b>Where</b> clause when a condition is true<br />
/// First parameter is a boolean condition
/// Second parameter is the instruction with one or multiples<em>?</em> <br/>
/// next arguments are the values<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").OrIf(5 > 5, "Age = ?", 5).GetSQL()
/// ; Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo'
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").Where("Name %STARSTSWITH ?","Jo").OrIf(10 > 1, "Age = ?", 10).GetSQL()
/// ; Select name, ssn From sample.person Where Name %STARSTSWITH 'Jo' OR Age = '10'
/// </example>
/// <br/>
Method OrIf(pCondition, args...) As gen.SQLBuilder
{
	Quit:pCondition ..Or(args...)
	Quit $This
}

/// Add a <b>Where</b> or an <em>AND</em> on <b>Where</b> clause when a condition is true<br />
/// First parameter is a boolean condition
/// Second parameter is the instruction with one or multiples<em>?</em> <br/>
/// next arguments are the values<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").WhereIf(5 > 5, "Age = ?", 5).GetSQL()
/// ; Select name, ssn From sample.person
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").WhereIf(10 > 1, "Age = ?", 10).GetSQL()
/// ; Select name, ssn From sample.person Where Age = '10'
/// </example>
/// <br/>
Method WhereIf(pCondition, args...) As gen.SQLBuilder
{
	Quit:pCondition ..Where(args...)
	Quit $This
}

/// Get the SQL Query string<br />
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("name, ssn").From("sample.person").GetSQL()
/// ; Select name, ssn From sample.person
/// </example>
/// <br/>
Method GetSQL() As %String
{
	Quit ..SerializeSql()
}

Method SerializeSql() As %String
{
	Quit:..Statement=1 ..GetSelectStatement()
	Quit:..Statement=2 ..GetUpdateStatement()
	Quit:..Statement=3 ..GetInsertStatement()
	Quit:..Statement=4 ..GetDeleteStatement()
}

Method GetSelectStatement() As %String [ Private ]
{
	Set select = ""
	Set:..Select'="*" $List(select, *+1) = ..Select
	For k=1:1:..Columns.Count() {
		Set $List(select, *+1)=..Columns.GetAt(k)
	}

	Set sql = "Select " _ ..Top _ $Case($ListLength(select),0: ..Select,:$ListToString(select,","))

	Set from = ..From
	Set:((..TableAlias'="")&&(..UsedAsSubQuery=$$$NO)) from = from _ " As "_..TableAlias

	Set sql = sql _ " From " _ from

	For k=1:1:..Join.Count() {
		Set sql = sql _ " " _ ..Join.GetAt(k)
	}

	Set:..Where'="" sql = sql _ " Where " _ ..Where

	Set:..GroupBy'="" sql = sql _ " Group By " _ ..GroupBy
	Set:..Having'="" sql = sql _ " Having " _ ..Having
	Set:..OrderBy'="" sql = sql _ " Order By " _ ..OrderBy
	Set:..Union'="" sql = sql _ ..Union
	Quit sql
}

Method GetDeleteStatement() As %String [ Private ]
{
	Set sql = "Delete "
	Set sql = sql _ " From " _ ..From
	Set:..Where'="" sql = sql _ " Where " _ ..Where
	Quit sql
}

Method GetUpdateStatement() As %String [ Private ]
{
	Set sql = "Update " _ ..From
	Do ..AbstractGetFieldsBlock(.setFieldsStatement)
	Set sql = sql _ setFieldsStatement
	Set:..Where'="" sql = sql _ " Where " _ ..Where
	Quit sql
}

Method GetInsertStatement() As %String [ Private ]
{
	Set sql = "Insert INTO " _ ..From _ " "
	Do ..AbstractGetFieldsBlock(.setFieldsStatement)
	Set sql = sql _ setFieldsStatement
	Quit sql
}

/// Prepare the query <b>ResultSet</b><br />
/// <example>
/// Set tRS = ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN, Age").From("sample.person").Between("Age",10,50).Prepare()
/// Write $ClassName(tRS)
/// ; %Library.ResultSet
/// </example>
/// <br/>
Method Prepare(tSC As %Status) As %ResultSet
{
	Set tSC = $$$OK
	Try {
		If ..SQLType="ST" {
			Set ..SQLStatement = ##class(%SQL.Statement).%New()
			$$$THROWONERROR(tSC, ..SQLStatement.%Prepare(..GetSQL()))
		} Else {
			Set ..ResultSet = ##class(%ResultSet).%New()
			$$$THROWONERROR(tSC, ..ResultSet.Prepare(..GetSQL()))
		}
		Set ..WasPreperedBefore = $$$YES
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit:..SQLType="ST" ..SQLStatement
	Quit ..ResultSet
}

/// Execute the <b>Query</b> returning the ResultSet<br />
Method Execute(Output tSC As %Status = "", Args...) As %ResultSet
{
	Set tSC = $$$OK, tRS = ""
	Try {

		If ..WasPreperedBefore'=1 {
			Do ..Prepare()
		}
		If ..SQLType="ST" {
			Set tRS = ..SQLStatement.%Execute(Args...)
			Throw:tRS.%SQLCODE<0 ##class(%Exception.SQL).CreateFromSQLCODE(tRS.%SQLCODE, "SQL ERROR: " _
				$System.SQL.SQLCODE(tRS.%SQLCODE))
		} Else {
			Set tRS = ..ResultSet.%Execute(Args...)
		}

	}
	Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tRS
}

Method %OnNew(table As %String = "", pIsStatement As %Boolean = 0, pRuntimeMode As %Integer = 0, pInfo As %ZEN.Auxiliary.QueryInfo = "") As %Status [ Private, ServerOnly = 1 ]
{
	Set ..From = table
	Set ..SQLType = "RS"
	Set:pIsStatement ..SQLType = "ST"
	Set ..RuntimeMode = pRuntimeMode
	Set:pInfo'="" ..Info = pInfo
	Quit $$$OK
}

/// This method is just to insert on %ArrayOfDataTypes property using Key and Value. <br>
/// 'Cos caché set array inverse (Value, Key)...
Method AddField(pField, pValue = "") As %Status
{
	Set tSC = $$$OK
	Try {
		$$$THROWONERROR(tSC, ..Fields.SetAt(pValue, pField))
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method AbstractGetFieldsBlock(Output pQueryBlock) As %Status [ Private ]
{
	Set tSC = $$$OK
	Try {
		Set into = "", field = ..Fields.Next("")

		While field'="" {
			Set updateAttr = " = ?"
			Set:((..ByParams=$$$NO)&&(..Fields.GetAt(field)="")) updateAttr = ""
			Set:..Statement=2 $List(into, *+1) = ..GetStringPrepare(field _ updateAttr, ..Fields.GetAt(field)) //Update
			Kill updateAttr

			If ..Statement=3 { // Insert
				Set $List(into, *+1) = field
				Set $List(values, *+1) = ..GetStringPrepare("?",..Fields.GetAt(field))
			}

			Set field = ..Fields.Next(field)

		}

		Set:..Statement=2 pQueryBlock = " SET " _ $ListToString(into,", ")
		Set:..Statement=3 pQueryBlock = " (" _ $ListToString(into,", ")_") VALUES ("_$ListToString(values,", ")_" )"

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

/// Adiciona um <em>UNION</em> com outra Query <br />
/// Recebe como parâmetro outro objeto SQLBuilder <br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").Union( ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person")).GetSQL()
/// ; Select ID, Name, SSN From sample.person Union Select ID, Name, SSN From sample.person
/// </example>
/// <br/>
Method Union(pSQL As gen.SQLBuilder) As gen.SQLBuilder
{
	Set ..Union = " Union " _ pSQL.GetSQL()
	Quit $This
}

/// Adiciona um <em>UNION ALL</em> com outra Query <br />
/// Recebe como parâmetro outro objeto SQLBuilder <br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").UnionAll( ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person")).GetSQL()
/// ; Select ID, Name, SSN From sample.person Union All Select ID, Name, SSN From sample.person
/// </example>
/// <br/>
Method UnionAll(pSQL As gen.SQLBuilder) As gen.SQLBuilder
{
	Set ..Union = " Union All " _ pSQL.GetSQL()
	Quit $This
}

Method HavingInternal(pHaving As %String, pAndOr = 0) As gen.SQLBuilder [ Internal, Private ]
{
	If ..Having=""{
		Set ..Having = pHaving
	} Else {
		Set:..Having'="" ..Having = ..Having _ $Case(pAndOr,0:" AND ",1:" OR ") _ pHaving
	}
	Quit $This
}

/// Adiciona um <em>HAVING</em> no <em>GROUP BY</em> da query <br />
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select("ID, Name, SSN").From("sample.person").GroupBy("Name").Having("Age > ?", 50).GetSQL()
/// ; Select ID, Name, SSN From sample.person Group By Name Having Age > '50'
/// </example>
Method Having(args...) As gen.SQLBuilder
{
	If $IsObject(args(2)) {
		If $ClassName(args(2))=$ClassName($This) {
			Do args(2).IsSubQuery()
			Set args(2) = "("_ args(2).GetSQL() _ ")" _
				$Case(args(2).SubQueryAlias(),"":"",:" As " _ args(1).SubQueryAlias())
		}
	}

	Set result = ..GetStringPrepare(args...)
	Quit:result="" $This
	Quit ..HavingInternal(result)

	Quit $This
}

Method ByParams() As gen.SQLBuilder
{
	Set ..ByParams = $$$YES
	Quit $This
}

/// Adiciona um <em>TOP</em> no <b>Select</b> <br />
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").Top(10).GetSQL()
/// ; Select TOP 10 name From sample.person
/// </example>
/// <br/>
Method Top(pNumberOfRows As %Integer = "") As gen.SQLBuilder
{
	Set:pNumberOfRows'="" ..Top = "TOP "_pNumberOfRows_" "
	Quit $This
}

/// Adiciona um <em>TOP</em> no <b>Select</b>  Caso atenda uma condição<br />
/// O primeiro parâmetro é a condição <br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").TopIf(1=1,10).GetSQL()
/// ; Select TOP 10 name From sample.person
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").TopIf(2=1,10).GetSQL()
/// ; Select name From sample.person
/// </example>
/// <br/>
Method TopIf(pCondition, pNumberOfRows As %Integer = "") As gen.SQLBuilder
{
	Quit:pCondition ..Top(pNumberOfRows)
	Quit $This
}

/// Adiciona um <em>TOP</em> no <b>Select</b> <br />
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").Limit(10).GetSQL()
/// ; Select TOP 10 name From sample.person
/// </example>
/// <br/>
Method Limit(pNumberOfRows As %Integer = "") As gen.SQLBuilder
{
	Quit ..Top(pNumberOfRows)
}

/// Adiciona uma condição <em>IN</em> na cláusula <b>Where</b> <br />
/// O primeiro parâmetro é o nome da coluna <br/>
/// Os demais parâmetros são os valores<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").In("age",10,20,30,40).GetSQL()
/// ; Select name From sample.person Where age In ('10','20','30','40')
/// </example>
/// <br/>
Method In(pColumn, args...) As gen.SQLBuilder
{
	Quit ..WhereInInterno($$$NO, pColumn, args...)
}

/// Adiciona uma condição <em>IN</em> na query Caso atenda uma condição<br /><br />
/// O primeiro parâmetro é a condição <br/>
/// O segundo parâmetro é a cláusula <br/>
/// Os demais parâmetros são os valores<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").InIf(5>5,"age",10,20,30,40).GetSQL()
/// ; Select name From sample.person
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").InIf(6>5,"age",10,20,30,40).GetSQL()
/// ; Select name From sample.person Where age In ('10','20','30','40')
/// </example>
/// <br/>
Method InIf(pCondition, pColumn, args...) As gen.SQLBuilder
{
	Quit ..WhereInIf(pCondition, pColumn, args...)
}

/// Adiciona uma condição <em>IN</em> na query Caso atenda uma condição<br /><br />
/// O primeiro parâmetro é a condição <br/>
/// O segundo parâmetro é a cláusula <br/>
/// Os demais parâmetros são os valores<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereInIf(5>5,"age",10,20,30,40).GetSQL()
/// ; Select name From sample.person
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereInIf(6>5,"age",10,20,30,40).GetSQL()
/// ; Select name From sample.person Where age In ('10','20','30','40')
/// </example>
/// <br/>
Method WhereInIf(pCondition, pColumn, args...) As gen.SQLBuilder
{
	Quit:pCondition ..WhereInInterno($$$NO, pColumn, args...)
	Quit $This
}

/// Adiciona uma condição <em>IN</em> na cláusula <b>Where</b> <br />
/// O primeiro parâmetro é o nome da coluna <br/>
/// Os demais parâmetros são os valores<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereIn("age",10,20,30,40).GetSQL()
/// ; Select name From sample.person Where age In ('10','20','30','40')
/// </example>
/// <br/>
Method WhereIn(pColumn, args...) As gen.SQLBuilder
{
	Quit ..WhereInInterno($$$NO, pColumn, args...)
}

/// Adiciona uma condição <em>NOT IN</em> na query Caso atenda uma condição<br /><br />
/// O primeiro parâmetro é a condição <br/>
/// O segundo parâmetro é a cláusula <br/>
/// Os demais parâmetros são os valores<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereNotInIf(5>5,"age",10,20,30,40).GetSQL()
/// ; Select name From sample.person
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereNotInIf(6>5,"age",10,20,30,40).GetSQL()
/// ; Select name From sample.person Where age Not In ('10','20','30','40')
/// </example>
/// <br/>
Method WhereNotInIf(pCondition, pColumn, args...) As gen.SQLBuilder
{
	Quit:pCondition ..WhereInInterno($$$YES, pColumn, args...)
	Quit $This
}

/// Adiciona uma condição <em>NOT IN</em> na cláusula <b>Where</b> <br />
/// O primeiro parâmetro é o nome da coluna <br/>
/// Os demais parâmetros são os valores<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").NotIn("age",10,20,30,40).GetSQL()
/// ; Select name From sample.person Where age Not In ('10','20','30','40')
/// </example>
/// <br/>
Method NotIn(pColumn, args...) As gen.SQLBuilder
{
	Quit ..WhereInInterno($$$YES, pColumn, args...)
}

/// Adiciona uma condição <em>NOT IN</em> na query Caso atenda uma condição<br /><br />
/// O primeiro parâmetro é a condição <br/>
/// O segundo parâmetro é a cláusula <br/>
/// Os demais parâmetros são os valores<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").NotInIf(5>5,"age",10,20,30,40).GetSQL()
/// ; Select name From sample.person
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").NotInIf(6>5,"age",10,20,30,40).GetSQL()
/// ; Select name From sample.person Where age Not In ('10','20','30','40')
/// </example>
/// <br/>
Method NotInIf(pCondition, pColumn, args...) As gen.SQLBuilder
{
	Quit ..WhereNotInIf(pCondition, pColumn, args...)
}

/// Adiciona uma condição <em>NOT IN</em> na cláusula <b>Where</b> <br />
/// O primeiro parâmetro é o nome da coluna <br/>
/// Os demais parâmetros são os valores<br/>
/// <example>
/// Write ##class(gen.SQLBuilder).%New().Select().Column("name").From("sample.person").WhereNotIn("age",10,20,30,40).GetSQL()
/// ; Select name From sample.person Where age Not In ('10','20','30','40')
/// </example>
/// <br/>
Method WhereNotIn(pColumn, args...) As gen.SQLBuilder
{
	Quit ..WhereInInterno($$$YES, pColumn, args...)
}

Method SetInfo(pInfo As %ZEN.Auxiliary.QueryInfo) As gen.SQLBuilder
{
	Set ..Info = pInfo
	Quit $This
}

Method WhereInInterno(pNot As %Boolean = 0, pColumn, args...) As gen.SQLBuilder [ Private ]
{
	Set arguments = "", sanitize = "'", not = " ",
		count = $Get(args, 0) // Get Args Size

	Set:pNot=1 not = " Not "

	If count = 1 {
		If $IsObject(args(1)) {
			If (($ClassName(args(1)) = "%Collection.ListOfDT")||($ClassName(args(1)) = "%ListOfDataTypes")||($ClassName(args(1)) = "%List")) {
				For k=1:1:args(1).Count() {
					Set $List(arguments, *+1) =  sanitize _ $Replace(args(1).GetAt(k),"'","") _ sanitize
				}
			}
		} ElseIf $ListValid(args(1)) {
			For k=1:1:$ListLength(args(1)) {
				Set $List(arguments, *+1) =  sanitize _ $Replace($List(args(1),k),"'","") _ sanitize
			}
		} Else {
			Set tmp = $ListFromString(args(1),",")
			For k=1:1:$ListLength(tmp) {
				Set $List(arguments, *+1) =  sanitize _ $Replace($List(tmp,k),"'","") _ sanitize
			}
		}

		Set arguments = $ListToString(arguments,",")

	} ElseIf count > 1 {
		For k=1:1:count {
			S $Li(arguments,*+1) = sanitize _ $Replace(args(k),"'","") _ sanitize
		}
		Set arguments = $ListToString(arguments,",")
	} Else {
		Set arguments = "?"
	}
	Set sql = pColumn_not_"In (" _ arguments _ ")"
	Quit ..WhereInterno(sql)
}

Method WhereFilter(pWhereColumn As %String = "", pTablePaneColumn As %String = "", pInfo As %ZEN.Auxiliary.QueryInfo = "", pSensitive As %Boolean = 0, Output tSC As %Status) As gen.SQLBuilder
{
	Set tSC = $$$OK
	Set WhereFltr = ""
	Set tValue = ""
	Try{
		Set:pInfo'="" ..Info = pInfo
		Set tValue = ..Info.filters(pTablePaneColumn)
		Set tCondition = ..Info.filterOps(pTablePaneColumn),
			WhereFltr = pWhereColumn_" "_tCondition
		Set WhereFltr = WhereFltr_" ?"

	} Catch tException {
		Set tSC = ##class(HPardini.Basico.Operacao.Utilitario).TrataObjErro(tException)
    }
	Quit:tValue'="" ..Where(WhereFltr,tValue)
	Quit $This
}

/// Cria um clone do objeto SQLBuilder
Method Clone() As gen.SQLBuilder
{
	Quit $This.%ConstructClone()
}

}

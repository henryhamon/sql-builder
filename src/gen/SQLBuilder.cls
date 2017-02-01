Class gen.SQLBuilder Extends %RegisteredObject
{

Parameter Version = "0.1.0";

Parameter Codename = "Black Sails";

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

Property WasPreperedBefore As %Boolean [ InitialExpression = 0, Private ];

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

Method As(pAlias As %String) As gen.SQLBuilder
{
	Set ..TableAlias = pAlias
	Quit $This
}

Method From(pFrom As %String) As gen.SQLBuilder
{
	Set ..From = pFrom
	Quit $This
}

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

Method Or(args...) As gen.SQLBuilder
{
	Set result = ..GetStringPrepare(args...)
	Quit:result="" $This
	Quit ..WhereInterno(result,1)
}

Method And(args...) As gen.SQLBuilder
{
	Set result = ..GetStringPrepare(args...)
	Quit:result="" $This
	Quit ..WhereInterno(result)
}

Method Between(pProp, pInferior, pSuperior, pType = 0) As gen.SQLBuilder
{
	Set sql = "(" _ pProp _ " BETWEEN " _ pInferior _ " AND " _ pSuperior _ ")"
	Quit ..WhereInterno(sql)
}

Method Join(pTable, pFirst As %String, pSecond As %String) As gen.SQLBuilder
{
	Quit ..InnerJoin(pTable, pFirst, pSecond)
}

Method InnerJoin(pTable, pFirst As %String, pSecond As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Inner",pTable, pFirst, pSecond))
	Quit $This
}

Method LeftJoin(pTable, pFirst As %String, pSecond As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Left",pTable, pFirst, pSecond))
	Quit $This
}

Method LeftOuterJoin(pTable, pFirst As %String, pSecond As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Left Outer",pTable, pFirst, pSecond))
	Quit $This
}

Method RightJoin(pTable, pFirst As %String, pSecond As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Right",pTable, pFirst, pSecond))
	Quit $This
}

Method RightOuterJoin(pTable, pFirst As %String, pSecond As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Right Outer",pTable, pFirst, pSecond))
	Quit $This
}

Method OuterJoin(pTable, pFirst As %String, pSecond As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Outer",pTable, pFirst, pSecond))
	Quit $This
}

Method FullOuterJoin(pTable, pFirst As %String, pSecond As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Full Outer",pTable, pFirst, pSecond))
	Quit $This
}

Method CrossJoin(pTable, pFirst As %String, pSecond As %String) As gen.SQLBuilder
{
	Do ..Join.Insert(..JoinPrepare("Cross",pTable, pFirst, pSecond))
	Quit $This
}

ClassMethod JoinPrepare(pJoinSyntax As %String, pTable, pFirst As %String, pSecond As %String) As %String [ Private ]
{
	If $IsObject(pTable) {
		If $ClassName(pTable)=$ClassName($This) {
			Do pTable.IsSubQuery()
			Set pTable = "("_ pTable.GetSQL() _ ")" _ 
				$Case(pTable.SubQueryAlias(),"":"",:" As " _ pTable.SubQueryAlias())
		}	
	}
	
	Quit pJoinSyntax _ " Join "_ pTable _" On "_ pFirst _ " = " _ pSecond
}

Method GetStringPrepare(args...) As %String [ Private ]
{
	Set output = ""
	Quit:..ByParams=$$$YES $Get(args(1))
	
	Try {
		Set output = $Get(args(1))
		
		Set k = 2, sanitize = "'"
		
		Set:$Find($ZConvert(output,"U"),"LIKE")>0 sanitize = "#"
		Set matcher = $ListFromString(output,"?"), output = ""
		
	    For i=1:1:$ListLength(matcher) {
		    Set got = "", arg = $Get(args(k))
		    
		    If $IsObject(arg){
		    	Set:$ClassName(arg)=$ClassName($This) got = "(" _ arg.GetSQL()_")"
		    } Else {
		    	Set:arg'="" got = sanitize_$Replace(arg,"'","")_sanitize
		    }
		    
		    
		    Set output = output _ $List(matcher,i) _ got
	        Set k = $Increment(k)
	    }
	    
	    Set:$Find(output,"''")>0 output = ""
	    Set:$Find(output,"##")>0 output = ""
	    Set:output'="" output = $Replace(output,"#","")
		
	} Catch {
		Set output = ""
	}
	Quit output
}

Method Order(pOrderBy As %String) As gen.SQLBuilder
{
	Set ..OrderBy = ""
	Quit ..OrderBy(pOrderBy)
}

Method OrderBy(pOrderBy As %String) As gen.SQLBuilder
{
	Set:..OrderBy'="" ..OrderBy = ..OrderBy _ "," _ pOrderBy
	Set:..OrderBy="" ..OrderBy = pOrderBy
	Quit $This
}

Method GroupBy(pGroupBy As %String) As gen.SQLBuilder
{
	Set:..GroupBy'="" ..GroupBy = ..GroupBy _ "," _ pGroupBy
	Set:..GroupBy="" ..GroupBy = pGroupBy
	Quit $This
}

Method AndIf(pCondition, args...) As gen.SQLBuilder
{
	Quit:pCondition ..And(args...)
	Quit $This
}

Method OrIf(pCondition, args...) As gen.SQLBuilder
{
	Quit:pCondition ..Or(args...)
	Quit $This
}

Method WhereIf(pCondition, args...) As gen.SQLBuilder
{
	Quit:pCondition ..Where(args...)
	Quit $This
}

Method GetSQL() As %String
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
	
	Set sql = "Select " _ $Case($ListLength(select),0: ..Select,:$ListToString(select,","))
	
	Set from = ..From
	Set:((..TableAlias'="")&&(..UsedAsSubQuery=$$$NO)) from = from _ " As "_..TableAlias
	
	Set sql = sql _ " From " _ from
	Set:..Where'="" sql = sql _ " Where " _ ..Where
	
	For k=1:1:..Join.Count() {
		Set sql = sql _ " " _ ..Join.GetAt(k)
	}
	
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
	Write sql,!
	Quit sql
}

Method Prepare() As %Status
{
	Set tSC = $$$OK
	Try {
		Set ..SQLStatement = ##class(%SQL.Statement).%New()
		$$$THROWONERROR(tSC, ..SQLStatement.%Prepare(..GetSQL()))
		Set ..WasPreperedBefore = $$$YES
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method Execute(Output tSC As %Status = "", Args...) As %ResultSet
{
	Set tSC = $$$OK, tRS = ""
	Try {
		
		If ..WasPreperedBefore=$$$NO {
			$$$THROWONERROR(tSC, ..Prepare())
		}
		
		Set tRS = ..SQLStatement.%Execute(Args...)
	}
	Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tRS
}

Method %OnNew(table As %String = "") As %Status [ Private, ServerOnly = 1 ]
{
	Set ..From = table
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
			
			S ^CacheTemp.ham($I(^CacheTemp.ham),"into") = into
			S ^CacheTemp.ham($I(^CacheTemp.ham),"values") = values
		}
		
		Set:..Statement=2 pQueryBlock = " SET " _ $ListToString(into,", ")
		Set:..Statement=3 pQueryBlock = " (" _ $ListToString(into,", ")_") VALUES ("_$ListToString(values,", ")_" )"

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method Union(pSQL As gen.SQLBuilder) As gen.SQLBuilder
{
	Set ..Union = " Union " _ pSQL.GetSQL()
	Quit $This
}

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

}


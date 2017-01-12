Class gen.SQLBuilder Extends %RegisteredObject
{

Parameter Version = "0.0.3";

Property Select As %String [ InitialExpression = "*", Internal ];

Property Update As %String [ Internal ];

Property From As %String [ Internal ];

Property Where As %String [ Internal ];

Property GroupBy As %String [ Internal ];

Property OrderBy As %String [ Internal ];

Property Fields As %ArrayOfDataTypes [ Private ];

Property Statement As %Integer(DISPLAYLIST = ",Select,Update,Insert,Delete", VALUELIST = ",1,2,3,4") [ InitialExpression = 1, Internal ];

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
		Set matcher = ##class(%Regex.Matcher).%New("^(SELECT)\s")
		Set matcher.Text = $ZConvert(params,"U")
		Set:matcher.Locate() params = $Extract(params,8,*+1)
		
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

Method Set(pField As %String, pValue As %String = "") As gen.SQLBuilder
{
	Do:pValue'="" ..AddField(pField, pValue)
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

Method Join(table As %String, prop As %String) As gen.SQLBuilder
{
}

ClassMethod GetStringPrepare(args...) As %String [ Private ]
{
	Set output = ""
	Try {
		Set output = $Get(args(1))
		Set count = $Order(args(""),-1)
		
		Set matcher = ##class(%Regex.Matcher).%New("\?")
		Set matcher.Text = output
		
		If count > 1 {
			Set k = 2, sanitize = "'"
			
			Set:$Find($ZConvert(output,"U"),"LIKE")>0 sanitize = "#"
			
			While matcher.Locate() {
				Set matcher.Text = matcher.ReplaceFirst(sanitize_$Replace($Get(args(k)),"'","")_sanitize)
		        Set k = $Increment(k)
		    }
		    
		    Set output = matcher.Text
		    Set:$Find(output,"''")>0 output = ""
		    Set:$Find(output,"##")>0 output = ""
		    Set:output'="" output = $Replace(output,"#","")
		} Else {
			Set:matcher.Match(output) output = ""
		}
	} Catch {
		Set output = ""
	}
	Quit output
}

Method Order(pOrderBy As %String) As gen.SQLBuilder
{
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
	Set sql = "Select " _ ..Select
	Set sql = sql _ " From " _ ..From
	Set:..Where'="" sql = sql _ " Where " _ ..Where
	Set:..GroupBy'="" sql = sql _ " Group By " _ ..GroupBy
	Set:..OrderBy'="" sql = sql _ " Order By " _ ..OrderBy
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
	W sql,!
	Quit sql
}

Method Execute(Output tSC As %Status = "", Args...) As %ResultSet
{
	Set tSC = $$$OK
	Try {
		Set statement = ##class(%SQL.Statement).%New()
		$$$THROWONERROR(tSC, statement.%Prepare(..GetSQL()))
		
		Set tRS = statement.%Execute(Args...)
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
Method AddField(pField, pValue) As %Status
{
	Set tSC = $$$OK
	Try {
		$$$THROWONERROR(tSC, ..Fields.SetAt(pValue, pField))
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method AbstractGetFieldsBlock(Output pQueryBlock) As %Status
{
	Set tSC = $$$OK
	Try {
		Set into = "", field = ..Fields.Next("")
		
		While field'="" {
			Set:..Statement=2 $List(into, *+1) = ..GetStringPrepare(field _ " = ?", ..Fields.GetAt(field)) //Update
			If ..Statement=3 { // Insert
				S $List(into, *+1) = field 
				S $Li(values, *+1) = ..GetStringPrepare("?",..Fields.GetAt(field))
			}

			Set field = ..Fields.Next(field)
		}
		
		Set:..Statement=2 pQueryBlock = " SET " _ $ListToString(into,", ")
		Set:..Statement=3 pQueryBlock = " (" _ $ListToString(into,", ")_") VALUES ("_$LTS(values,", ")_" )"

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

}


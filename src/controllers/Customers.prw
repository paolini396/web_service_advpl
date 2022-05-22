#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

WSRestFul Customers Description "REST para Clientes no Protheus"

	WSData search as string optional
	WSData page as string optional
	WSData per_page as string optional
	WSData all_page as string optional
	WSData store as string optional

	WSMethod GET Description "Listar Clientes"  WSSYNTAX "/Customers/{id}" Produces APPLICATION_JSON

end WSRestFul

WSMethod GET WSService Customers

	Local oResponse        := Nil as object

	Local oCustomerService :=  Nil as object
	Local oCustomerData    := Nil as Object

	Local lParsedAllPage   := .F. as logical
	Local cParsedSearch    := "" as character
	Local nParsedPage      := 1 as numeric
	Local nParsedPerPage   := 50 as numeric
	Local cParsedStore     := "" as character
	Local cParsedId        := "" as character

	Private cError         := "" as character
	Private bError         := ErrorBlock({ |oError| cError := oError:Description}) as codeblock

	Default ::search   := ""
	Default ::page     := "1"
	Default ::per_page := "50"
	Default ::all_page := "false"
	Default ::store    := ""

	begin sequence

		lParsedAllPage := if(::all_page == "true", .T. , .F.)
		cParsedSearch  := Upper(AllTrim(::search))
		nParsedPage    := Val(::page)
		nParsedPerPage := Val(::per_page)
		cParsedStore   := AllTrim(::store)
		cParsedId      := if(Len(::aURLParms) > 0, ::aURLParms[1], "")

		oResponse := JsonObject():New()
		oResponse["page"] := oCustomerData["page"]
		oResponse["per_page"] := oCustomerData["per_page"]
		oResponse["total"] := oCustomerData["total"]
		oResponse["last_page"] := oCustomerData["last_page"]
		oResponse["data"] := {}

		oCustomerService :=  TCustomerService():New()
		oModel := TCustomerModel():New()

		if !Empty(cParsedId)

			oCustomerData := oCustomerService:Show(cId, cStore)
			oResponse["data"] := oModel:SanitizeResponseToShow(oCustomerData["data"])

		else

			oCustomerData := oCustomerService:List(cSearch, nPage, nPerPage, lAllPage)
			oResponse["data"] := oModel:SanitizeResponseToList(oCustomerData["data"])

		endif

	end sequence

	if !Empty(cError)

		oResponse := JsonObject():New()

		oResponse["error"] := JsonObject():New()
		oResponse["error"]["status"] := 400
		oResponse["error"]["message"] := cError

		::SetStatus(400)

	else 

		::SetStatus(200)

	endif
	
	::SetContentType("application/json; charset=UTF-8")
	::SetResponse(oResponse:ToJson())

	ErrorBlock(bError)

Return(.T.)


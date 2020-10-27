xquery version "3.1";

module namespace raffPostals="https://portal.raff-archiv.ch/ns/raffPostals";

import module namespace app="https://portal.raff-archiv.ch/templates" at "app.xql";
import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config="https://portal.raff-archiv.ch/config" at "config.xqm";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace transform="http://exist-db.org/xquery/transform";

import module namespace functx="http://www.functx.com" at "functx.xqm";
import module namespace json="http://www.json.org";
import module namespace jsonp="http://www.jsonp.org";

import module namespace i18n="http://exist-db.org/xquery/i18n" at "i18n.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace hc = "http://expath.org/ns/http-client";

declare function raffPostals:getSender($correspActionSent as node()){
let $senders := for $sender in ($correspActionSent//tei:persName/@key | $correspActionSent//tei:orgName/@key)
                    let $senderName := raffPostals:getName($sender,'full')
                    
                    return
                        normalize-space($senderName)
  return
    string-join($senders, '/')
};

declare function raffPostals:getName($key as xs:string, $param as xs:string){
    let $person := $app:collectionPersons[@xml:id = $key]
    let $institution := $app:collectionInstitutions[@xml:id = $key]
    
    let $nameSurname := $person//tei:surname[matches(@type,"^used")][1]/text()[1]
    let $nameGenName := $person//tei:genName/text()
    let $nameForename := $person//tei:forename[matches(@type,"^used")][1]/text()[1]
    let $nameNameLink := $person//tei:nameLink[1]/text()[1]
    let $nameAddNameTitle := $person//tei:addName[matches(@type,"^title")][1]/text()[1]
    let $nameAddNameEpitet := $person//tei:addName[matches(@type,"^epithet")][1]/text()[1]
    let $pseudonym := if ($person//tei:forename[matches(@type,'^pseudonym')] or $person//tei:surname[matches(@type,'^pseudonym')])
                           then (concat($person//tei:forename[matches(@type,'^pseudonym')], ' ', $person//tei:surname[matches(@type,'^pseudonym')]))
                           else ()
    let $nameRoleName := $person//tei:roleName[1]/text()[1]
    let $nameAddNameNick := $person//tei:addName[matches(@type,"^nick")][1]/text()[1]
    let $nameUnspec := $person//tei:name[matches(@type,'^unspecified')][1]/text()[1]

    let $name :=
      if($person and $param = 'full')
      then(
            string-join(($nameAddNameTitle, $nameForename, $nameAddNameEpitet, $nameNameLink, $nameSurname, $nameGenName), ' ')
          )
      
      else if($person and $param = 'short')
      then(string-join(($nameForename, $nameNameLink, $nameSurname, $nameGenName), ' '))
      
      else if($person and $param = 'reversed')
      then(concat($nameSurname, ', ',string-join(($nameForename, $nameNameLink), ' '), if($nameGenName) then(concat('(',$nameGenName,')')) else()))
      
      else if($institution)
      then($institution//tei:orgName)
      
      else('[N.N.]')

    return
        $name
};
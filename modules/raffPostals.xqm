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
declare namespace range = "http://exist-db.org/xquery/range";

(:declare function raffPostals:getSender($correspActionSent as node()){
let $senders := for $sender in ($correspActionSent//tei:persName/@key | $correspActionSent//tei:orgName/@key)
                    let $senderName := raffPostals:getName($sender,'full')
                    
                    return
                        normalize-space($senderName)
  return
    string-join($senders, '/')
};:)

declare function raffPostals:getName($key as xs:string, $param as xs:string){

    let $person :=$app:collectionPersons[range:field-eq("person-id", $key)]
    let $institution := $app:collectionInstitutions[range:field-eq("institution-id", $key)]
    let $nameForename := string-join($person//tei:forename[matches(@type,"^used")], ' ')
    let $nameNameLink := $person//tei:nameLink[1]/text()[1]
    let $nameSurname := string-join($person//tei:surname[matches(@type,"^used")], ' ')
    let $nameGenName := $person//tei:genName/text()
    let $nameAddNameTitle := $person//tei:addName[matches(@type,"^title")][1]/text()[1]
    let $nameAddNameEpitet := $person//tei:addName[matches(@type,"^epithet")][1]/text()[1]
    let $pseudonym := string-join(($person//tei:forename[matches(@type,'^pseudonym')], $person//tei:surname[matches(@type,'^pseudonym')]), ' ')
    let $nameRoleName := $person//tei:roleName[1]/text()[1]
    let $nameAddNameNick := string-join($person//tei:addName[matches(@type,"^nick")], ' ')
    let $affiliation := $person//tei:affiliation[1]/text()
    let $nameUnspecified := $person//tei:name[matches(@type,'^unspecified')][1]/text()[1]
    let $nameUnspec := if($affiliation and $nameUnspecified)
                       then(concat($nameUnspecified, ' (',$affiliation,')'))
                       else($nameUnspecified)
    let $institutionName := $institution//tei:org/tei:orgName/text()
    
    let $name := if ($person)
                 then(
                      if($param = 'full')
                      then(
                            if($nameAddNameTitle or $nameForename or $nameAddNameEpitet or $nameNameLink or $nameSurname or $nameGenName or $nameUnspec)
                            then(string-join(($nameAddNameTitle, $nameForename, $nameAddNameEpitet, $nameNameLink, $nameSurname, $nameUnspec, if($nameGenName) then(concat(' (',$nameGenName,')')) else()), ' '))
                            else if($pseudonym)
                            then($pseudonym)
                            else if($nameRoleName)
                            then($nameRoleName)
                            else if($nameAddNameNick)
                            then($nameAddNameNick)
                            else('N.N.')
                          )
                          
                      else if($param = 'short')
                      then(
                           string-join(($nameForename, $nameNameLink, $nameSurname, if($nameGenName) then(concat(' (',$nameGenName,')')) else()), ' ')
                          )
                          
                      else if($param = 'reversed')
                      then(
                            if($nameSurname)
                            then(
                                concat(
                                       $nameSurname,
                                       if($nameGenName) then(concat(' (',$nameGenName,')')) else(),
                                       if($nameAddNameTitle or $nameForename or $nameNameLink)
                                       then(', ', string-join(($nameAddNameTitle, $nameForename, $nameNameLink), ' '))
                                       else()
                                       )
                                
                                )
                            else (
                                    if(not($nameForename) and not($nameNameLink) and not($nameUnspec))
                                    then($nameRoleName)
                                    else(
                                           string-join(($nameForename, $nameNameLink, $nameUnspec), ' '),
                                           if($nameGenName) then(concat(' (',$nameGenName,')')) else()
                                        )
                            )
                           )
                           
                      else ('[No person found]')
                     )
                 else if($institution)
                 then(if($institutionName)
                      then($institutionName)
                      else('[No institution found]'))
                 else('[Not found]')
    return
       $name
};
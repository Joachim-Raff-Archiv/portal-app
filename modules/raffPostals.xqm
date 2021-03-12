xquery version "3.1";

module namespace raffPostals="https://portal.raff-archiv.ch/ns/raffPostals";

import module namespace app="https://portal.raff-archiv.ch/templates" at "/db/apps/raffArchive/modules/app.xql";
import module namespace raffShared="https://portal.raff-archiv.ch/ns/raffShared" at "/db/apps/raffArchive/modules/raffShared.xqm";
import module namespace raffWritings="https://portal.raff-archiv.ch/ns/raffWritings" at "/db/apps/raffArchive/modules/raffWritings.xqm";
import module namespace raffWorks="https://portal.raff-archiv.ch/ns/raffWorks" at "/db/apps/raffArchive/modules/raffWorks.xqm";
import module namespace i18n="http://exist-db.org/xquery/i18n" at "i18n.xql";


import module namespace templates = "http://exist-db.org/xquery/templates";
(:import module namespace config="https://portal.raff-archiv.ch/config" at "/db/apps/raffArchive/modules/config.xqm";:)
import module namespace request="http://exist-db.org/xquery/request";
import module namespace transform="http://exist-db.org/xquery/transform";

import module namespace functx="http://www.functx.com" at "/db/apps/raffArchive/modules/functx.xqm";
import module namespace json="http://www.json.org";
import module namespace jsonp="http://www.jsonp.org";


declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace hc = "http://expath.org/ns/http-client";
declare namespace range = "http://exist-db.org/xquery/range";


declare function raffPostals:getName($key as xs:string, $param as xs:string){

    let $person :=$app:collectionPersons/id($key) (:[range:field-eq("person-id", $key)]:)
    let $institution := $app:collectionInstitutions/id($key) (:[range:field-eq("institution-id", $key)]:)
    let $nameForename := $person//tei:forename[matches(@type,"used")]
                          => string-join(' ')
    let $nameNameLink := $person//tei:nameLink[1]/text()[1]
    let $nameSurname := $person//tei:surname[matches(@type,"^used")]
                         => string-join(' ')
    let $nameSurnameBirth := $person//tei:surname[matches(@type,"^birth")]
                         => string-join(' ')
    let $nameSurnameMarried := $person//tei:surname[matches(@type,"^married")]
                         => string-join(' ')
    let $nameGenName := $person//tei:genName/text()
    let $nameAddNameTitle := $person//tei:addName[matches(@type,"title")][1]/text()[1]
    let $nameAddNameEpitet := $person//tei:addName[matches(@type,"^epithet")][1]/text()[1]
    let $pseudonym := ($person//tei:forename[matches(@type,'^pseudonym')], $person//tei:surname[matches(@type,'^pseudonym')])
                        => string-join(' ')
    let $nameRoleName := $person//tei:roleName[1]/text()[1]
    let $nameAddNameNick := $person//tei:addName[matches(@type,"^nick")]
                             => string-join(' ')
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
                                       then(concat(', ', string-join(($nameAddNameTitle, $nameForename, $nameNameLink), ' ')))
                                       else()
                                       )
                                )
                            else if($nameForename)
                            then(
                                   string-join(($nameForename, $nameNameLink, $nameUnspec), ' '),
                                   if($nameGenName) then(concat(' (',$nameGenName,')')) else()
                                )
                            else if($nameRoleName)
                            then($nameRoleName)
                            else('[N.N.]')
                                 )
                      else if($param = 'birth-rev')
                      then(
                            if($nameSurnameBirth)
                            then(
                                concat(
                                       $nameSurnameBirth,
                                       if($nameGenName) then(concat(' (',$nameGenName,')')) else(),
                                       if($nameAddNameTitle or $nameForename or $nameNameLink)
                                       then(concat(', ', string-join(($nameAddNameTitle, $nameForename, $nameNameLink), ' ')))
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
                      else if($param = 'married-rev')
                      then(
                            if($nameSurnameMarried)
                            then(
                                concat(
                                       $nameSurnameMarried,
                                       if($nameGenName) then(concat(' (',$nameGenName,')')) else(),
                                       if($nameAddNameTitle or $nameForename or $nameNameLink)
                                       then(concat(', ', string-join(($nameAddNameTitle, $nameForename, $nameNameLink), ' ')))
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

declare function raffPostals:getNameJoined($person){
 let $nameSurname := $person//tei:surname[matches(@type,"^used")][1]/text()[1]
 let $nameGenName := $person//tei:genName/text()
 let $nameSurnameFull := if($nameGenName)then(concat($nameSurname,' ',$nameGenName))else($nameSurname)
 let $nameForename := $person//tei:forename[matches(@type,"^used")][1]/text()[1]
 let $nameNameLink := $person//tei:nameLink[1]/text()[1]
 let $nameAddNameTitle := $person//tei:addName[matches(@type,"^title")][1]/text()[1]
 let $nameAddNameEpitet := $person//tei:addName[matches(@type,"^epithet")][1]/text()[1]
 let $nameForeFull := concat(if($nameAddNameTitle)then(concat($nameAddNameTitle,' '))else(),
                             if($nameForename)then(concat($nameForename,' '))else(),
                             if($nameAddNameEpitet)then(concat($nameAddNameEpitet,' '))else(),
                             if($nameNameLink)then(concat($nameNameLink,' '))else()
                             )
 let $pseudonym := if ($person//tei:forename[matches(@type,'^pseudonym')] or $person//tei:surname[matches(@type,'^pseudonym')])
                   then (concat($person//tei:forename[matches(@type,'^pseudonym')], ' ', $person//tei:surname[matches(@type,'^pseudonym')]))
                   else ()
 let $nameRoleName := $person//tei:roleName[1]/text()[1]
 let $nameAddNameNick := $person//tei:addName[matches(@type,"^nick")][1]/text()[1]
 let $nameUnspec := $person//tei:name[matches(@type,'^unspecified')][1]/text()[1]
 
 let $nameToJoin := if ($nameSurnameFull and $nameForeFull)
                    then (concat($nameSurnameFull,', ',$nameForeFull))
                    else if ($nameSurnameFull)
                    then ($nameSurnameFull)
                    else if($nameForeFull)
                    then ($nameForeFull)
                    else if($pseudonym)
                    then ($pseudonym)
                    else if($nameRoleName)
                    then ($nameRoleName)
                    else if ($nameAddNameNick)
                    then ($nameAddNameNick)
                    else if ($nameUnspec)
                    then ($nameUnspec)
                    else ('[N.N.]')
 
 return
    $nameToJoin
};

declare function raffPostals:turnName($nameToTurn){
let $nameTurned := if(contains($nameToTurn,'['))
                   then($nameToTurn)
                   else(concat(string-join(subsequence(tokenize($nameToTurn,', '),2),' '),
                   ' ', subsequence(tokenize($nameToTurn,', '),1,1)))
return
    $nameTurned
};

declare function raffPostals:getSenderTurned($correspActionSent){
let $sender := if($correspActionSent/tei:persName[3]/text())
                then(concat(raffPostals:turnName($correspActionSent/tei:persName[1]/text()[1]),'/', raffPostals:turnName($correspActionSent/tei:persName[2]/text()[1]),'/', raffPostals:turnName($correspActionSent/tei:persName[3]/text()[1]))) 
                else if($correspActionSent/tei:persName[2]/text())
                        then(concat(raffPostals:turnName($correspActionSent/tei:persName[1]/text()[1]),' und ',raffPostals:turnName($correspActionSent/tei:persName[2]/text()[1]))) 
                        else if($correspActionSent/tei:persName/text()) 
                             then(raffPostals:turnName($correspActionSent/tei:persName/text()[1])) 
                             else if($correspActionSent/tei:orgName/text()) 
                                  then($correspActionSent/tei:orgName/text()[1]) 
                                  else('[N.N.]')
  return
    $sender
};


declare function raffPostals:getSender($correspActionSent){
let $sender := if($correspActionSent/tei:persName)
               then(
                    if(($correspActionSent/tei:persName) > 2)
                    then(string-join($correspActionSent/tei:persName/text()[1],'/')) 
                    else if(count($correspActionSent/tei:persName) = 2)
                    then(string-join($correspActionSent/tei:persName/text()[1],' und ')) 
                    else($correspActionSent/tei:persName/text()[1])
                   )
               else if($correspActionSent/tei:orgName)
               then(
                    if(count($correspActionSent/tei:orgName) > 2)
                    then(string-join($correspActionSent/tei:orgName/text()[1],'/')) 
                    else if(count($correspActionSent/tei:orgName) = 2)
                    then(string-join($correspActionSent/tei:orgName/text()[1],' und ')) 
                    else($correspActionSent/tei:orgName/text()[1])
                   )
               else('[N.N.]')
  return
    $sender
};

declare function raffPostals:getReceiverTurned($correspActionReceived){

let $receiver := if($correspActionReceived/tei:persName[3]/text()) 
                                then(concat(raffPostals:turnName($correspActionReceived/tei:persName[1]/text()[1]),'/', raffPostals:turnName($correspActionReceived/tei:persName[2]/text()[1]),'/', raffPostals:turnName($correspActionReceived/tei:persName[3]/text()[1]))) 
                                else if($correspActionReceived/tei:persName[2]/text()) 
                                     then(concat(raffPostals:turnName($correspActionReceived/tei:persName[1]/text()[1]),' und ', raffPostals:turnName($correspActionReceived/tei:persName[2]/text()[1]))) 
                                     else if($correspActionReceived/tei:persName/text()) 
                                          then(raffPostals:turnName($correspActionReceived/tei:persName/text()[1])) 
                                          else if($correspActionReceived/tei:orgName/text()) 
                                               then($correspActionReceived/tei:orgName/text()[1]) 
                                               else ('[N.N.]')
 return
     $receiver
};

declare function raffPostals:getReceiver($correspActionReceived){

let $receiver := if($correspActionReceived/tei:persName[3]/text()) 
                                then(concat($correspActionReceived/tei:persName[1]/text()[1],'/', $correspActionReceived/tei:persName[2]/text()[1],'/', $correspActionReceived/tei:persName[3]/text()[1])) 
                                else if($correspActionReceived/tei:persName[2]/text()) 
                                     then(concat($correspActionReceived/tei:persName[1]/text()[1],' und ', $correspActionReceived/tei:persName[2]/text()[1])) 
                                     else if($correspActionReceived/tei:persName/text()) 
                                          then($correspActionReceived/tei:persName/text()[1]) 
                                          else if($correspActionReceived/tei:orgName/text()) 
                                               then($correspActionReceived/tei:orgName/text()[1]) 
                                               else ('[N.N.]')
 return
     $receiver
};

declare function raffPostals:getCorrespondance($id){
    let $correspondence := $app:collectionPostals[matches(.//@key[not(./ancestor::tei:note[@type='regeste'])], $id)]
    for $doc in $correspondence
        let $letter := $doc/ancestor::tei:TEI
        let $letterID := $letter/@xml:id/string()
        let $correspActionSent := $letter//tei:correspAction[@type="sent"]
        let $correspActionReceived := $letter//tei:correspAction[@type="received"]
        let $correspSentTurned := raffPostals:getSenderTurned($correspActionSent)
        let $correspReceivedTurned := raffPostals:getReceiverTurned($correspActionReceived)
        let $date := raffPostals:getDateRegistryLetters($correspActionSent)
        let $dateFormatted := raffPostals:formatDateRegistryLetters($date)
        
        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3">{$dateFormatted}</div>
                                <div class="col">{$correspSentTurned}<br/>an {$correspReceivedTurned}</div>
                                <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                            </div>
        
            order by $date(1)
        return
        $letterEntry
};

declare function raffPostals:getDateRegistryLetters($correspAction as node()*) as array(*) {
    
    let $dateEditors := $correspAction/tei:date[matches(@type,'^editor')]
    let $dateEditor := $dateEditors[1]
    let $dateEditorType := $dateEditor/@type/string()
    
    let $dateSources := $correspAction/tei:date[matches(@type,'^source')]
    let $dateSource := $dateSources[1]
    let $dateSourceType := $dateSource/@type/string()
    
    let $get := if($dateEditor)
                then(
                        if($dateEditor/@when)
                        then($dateEditor/@when/string())
                        
                        else if($dateEditor/@when-custom)
                        then($dateEditor/@when-custom/string())
                        
                        else if($dateEditor/@from)
                        then($dateEditor/@from/string())
                        
                        else if($dateEditor/@from-custom)
                        then($dateEditor/@from-custom/string())
                        
                        else if($dateEditor/@notBefore)
                        then( if(substring($dateEditor/@notBefore,6,2) = '01')
                              then(
                                   if(substring($dateEditor/@notBefore,9,2) = '01')
                                   then(substring($dateEditor/@notBefore,1,4))
                                   else($dateEditor/@notBefore)
                                  )
                              else ($dateEditor/@notBefore)
                            )
                        else if($dateEditor/@notAfter)
                        then($dateEditor/@notAfter/string())
                        
                        else('0000-00-00')
                    )
                else if($dateSource)
                then(
                        if($dateSource/@when)
                        then($dateSource/@when/string())
                        else if($dateSource/@when-custom)
                        then($dateSource/@when-custom/string())
                        else if($dateSource/@from)
                        then($dateSource/@from/string())
                        else if($dateSource/@from-custom)
                        then($dateSource/@from-custom/string())
                        else if($dateSource/@notBefore)
                        then($dateSource/@notBefore/string())
                        else if($dateSource/@notAfter)
                        then($dateSource/@notAfter/string())
                        else('0000-00-00')
                    )
                else if($dateEditor[@confidence])
                then($dateEditor[not(matches(@confidence,'0.5'))][@confidence = max(@confidence)]/@when)
                else if($dateSource[@confidence])
                then($dateSource[not(matches(@confidence,'0.5'))][@confidence = max(@confidence)]/@when)
                    else if($dateEditor[matches(@confidence,'0.5')])
                then($dateEditor[matches(@confidence,'0.5')]/@when)
                else if($dateSource[matches(@confidence,'0.5')])
                then($dateSource[matches(@confidence,'0.5')]/@when)
                else if($dateEditor)
                then(
                        if($dateEditor/@when)
                        then($dateEditor/@when/string())
                        else if($dateEditor/@when-custom)
                        then($dateEditor/@when-custom/string())
                        else if($dateEditor/@from)
                        then($dateEditor/@from/string())
                        else if($dateEditor/@from-custom)
                        then($dateEditor/@from-custom/string())
                        else if($dateEditor/@notBefore)
                        then($dateEditor/@notBefore/string())
                        else('0000-00-00')
                    )
                else if($dateSource)
                then(
                        if($dateSource/@when)
                        then($dateSource/@when/string())
                        else if($dateSource/@when-custom)
                        then($dateSource/@when-custom/string())
                        else if($dateSource/@from)
                        then($dateSource/@from/string())
                        else if($dateSource/@from-custom)
                        then($dateSource/@from-custom/string())
                        else if($dateSource/@notBefore)
                        then($dateSource/@notBefore/string())
                        else if($dateSource/@notAfter)
                        then($dateSource/@notAfter/string())
                        else('0000-00-00')
                    )
                else('0000-00-00')

    let $type := if($dateEditorType)
                 then($dateEditorType)
                 else if ($dateSourceType)
                 then ($dateSourceType)
                 else ('noType')

    return
        [$get, $type]
};

declare function raffPostals:formatDateRegistryLetters($dateArray){
    let $dateRaw := $dateArray(1)
    let $type := $dateArray(2)
    let $date :=  if(string-length($dateRaw)=10 and not(contains($dateRaw,'00')))
                  then(format-date(xs:date($dateRaw),'[D]. [M,*-3]. [Y]','de',(),()))
                  else if($dateRaw =('0000','0000-00','0000-00-00'))
                  then('[undatiert]')
                  else if(string-length($dateRaw)=7 and not(contains($dateRaw,'00')))
                  then (concat(upper-case(substring(format-date(xs:date(concat($dateRaw,'-01')),'[Mn,*-3]. [Y]','de',(),()),1,1)),substring(format-date(xs:date(concat($dateRaw,'-01')),'[Mn,*-3]. [Y]','de',(),()),2)))
                  else if(contains($dateRaw,'0000-') and contains($dateRaw,'-00'))
                  then (concat(upper-case(substring(format-date(xs:date(replace(replace($dateRaw,'0000-','9999-'),'-00','-01')),'[Mn,*-3].','de',(),()),1,1)),substring(format-date(xs:date(replace(replace($dateRaw,'0000-','9999-'),'-00','-01')),'[Mn,*-3].','de',(),()),2)))
                  else if(starts-with($dateRaw,'0000-'))
                  then(concat(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[D]. ','de',(),()),upper-case(substring(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[Mn,*-3]. ','de',(),()),1,1)),substring(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[Mn,*-3].','de',(),()),2)))
                  else($dateRaw)
    
    let $replace := replace($date,'Mai.','Mai')
    let $bracketify := if(matches($type, 'editor')) then(concat('[', $replace, ']')) else($replace)
    return
        $bracketify
};


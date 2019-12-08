xquery version "3.1";

module namespace app = "http://localhost:8080/exist/apps/raffArchive/templates";
import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config = "http://localhost:8080/exist/apps/raffArchive/config" at "config.xqm";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace functx = "http://www.functx.com";
declare namespace http = "http://expath.org/ns/http-client";
(:declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";:)

declare function functx:is-node-in-sequence-deep-equal
($node as node()?,
$seq as node()*) as xs:boolean {
    
    some $nodeInSeq in $seq
        satisfies deep-equal($nodeInSeq, $node)
};

declare function functx:distinct-deep
($nodes as node()*) as node()* {
    
    for $seq in (1 to count($nodes))
    return
        $nodes[$seq][not(functx:is-node-in-sequence-deep-equal(., $nodes[position() < $seq]))]
};

(:declare function app:search($node as node(), $model as map(*)) {
for $x in doc("/db/contents/jra/sources/documents/letters")//tei:TEI
 let $title := $x//LINE[ . ftcontains "romeo juliet " all words ]
 return $x/ancestor::tei:TEI/@xml:id
};:)

declare function app:search($node as node(), $model as map(*)) {
    let $collection := collection('/db/contents/jra/persons')//tei:TEI
    return
        <div>
            <p>Es wurden {count($collection//tei:surname[contains(., 'Raff')])} Ergebnisse gefunden.</p>
            <br/>
            <ul
                id="myResults">
                {
                    for $search at $n in $collection//tei:surname
                        where $search[contains(., 'Raff')]
                    let $result := $search/parent::node()/string()
                    let $resultID := $search/ancestor::tei:TEI/@xml:id
                        order by $result
                    return
                        <li>{$result} (<a
                                href="person/{$resultID}">{$resultID/string()}</a>)</li>
                }</ul></div>
};


declare function local:getDate($date) {

    let $get := if(count($date/tei:date[matches(@type,'^editor')])=1)
                then(
                        if($date/tei:date[matches(@type,'^editor')]/@when)
                        then($date/tei:date[matches(@type,'^editor')]/@when/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@when-custom)
                        then($date/tei:date[matches(@type,'^editor')]/@when-custom/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@from)
                        then($date/tei:date[matches(@type,'^editor')]/@from/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@from-custom)
                        then($date/tei:date[matches(@type,'^editor')]/@from-custom/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@notBefore)
                        then($date/tei:date[matches(@type,'^editor')]/@notBefore/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@notAfter)
                        then($date/tei:date[matches(@type,'^editor')]/@notAfter/string())
                        else('0000-00-00')
                    )
                else if(count($date/tei:date[matches(@type,'^source')])=1)
                then(
                        if($date/tei:date[matches(@type,'^source')]/@when)
                        then($date/tei:date[matches(@type,'^source')]/@when/string())
                        else if($date/tei:date[matches(@type,'^source')]/@when-custom)
                        then($date/tei:date[matches(@type,'^source')]/@when-custom/string())
                        else if($date/tei:date[matches(@type,'^source')]/@from)
                        then($date/tei:date[matches(@type,'^source')]/@from/string())
                        else if($date/tei:date[matches(@type,'^source')]/@from-custom)
                        then($date/tei:date[matches(@type,'^source')]/@from-custom/string())
                        else if($date/tei:date[matches(@type,'^source')]/@notBefore)
                        then($date/tei:date[matches(@type,'^source')]/@notBefore/string())
                        else if($date/tei:date[matches(@type,'^source')]/@notAfter)
                        then($date/tei:date[matches(@type,'^source')]/@notAfter/string())
                        else('0000-00-00')
                    )
                else if(count($date/tei:date[matches(@type,'^editor') and @confidence])=1)
                then(
                       $date/tei:date[matches(@type,'^editor') and not(matches(@confidence,'0.5'))][@confidence = max(@confidence)]/@when
                    )
                else if(count($date/tei:date[matches(@type,'^source') and @confidence])=1)
                then(
                       $date/tei:date[matches(@type,'^source') and not(matches(@confidence,'0.5'))][@confidence = max(@confidence)]/@when
                    )
                    else if($date/tei:date[matches(@type,'^editor') and matches(@confidence,'0.5')])
                then(
                       $date/tei:date[matches(@type,'^editor') and matches(@confidence,'0.5')][1]/@when
                    )
                else if($date/tei:date[matches(@type,'^source') and matches(@confidence,'0.5')])
                then(
                       $date/tei:date[matches(@type,'^source') and matches(@confidence,'0.5')][1]/@when
                    )
                else if($date/tei:date[matches(@type,'^editor')])
                then(
                        if($date/tei:date[matches(@type,'^editor')]/@when)
                        then($date/tei:date[matches(@type,'^editor')][1]/@when/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@when-custom)
                        then($date/tei:date[matches(@type,'^editor')][1]/@when-custom/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@from)
                        then($date/tei:date[matches(@type,'^editor')][1]/@from/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@from-custom)
                        then($date/tei:date[matches(@type,'^editor')][1]/@from-custom/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@notBefore)
                        then($date/tei:date[matches(@type,'^editor')][1]/@notBefore/string())
                        else('0000-00-00')
                    )
                else if(count($date/tei:date[matches(@type,'^source')]))
                then(
                        if($date/tei:date[matches(@type,'^source')]/@when)
                        then($date/tei:date[matches(@type,'^source')][1]/@when/string())
                        else if($date/tei:date[matches(@type,'^source')]/@when-custom)
                        then($date/tei:date[matches(@type,'^source')][1]/@when-custom/string())
                        else if($date/tei:date[matches(@type,'^source')]/@from)
                        then($date/tei:date[matches(@type,'^source')][1]/@from/string())
                        else if($date/tei:date[matches(@type,'^source')]/@from-custom)
                        then($date/tei:date[matches(@type,'^source')][1]/@from-custom/string())
                        else if($date/tei:date[matches(@type,'^source')]/@notBefore)
                        then($date/tei:date[matches(@type,'^source')][1]/@notBefore/string())
                        else if($date/tei:date[matches(@type,'^source')]/@notAfter)
                        then($date/tei:date[matches(@type,'^source')][1]/@notAfter/string())
                        else('0000-00-00')
                    )
                else('0000-00-00')
                
    return
        $get
};

declare function local:formatDate($dateRaw){
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

    let $replaceMay := replace($date,'Mai.','Mai')
    return
        $replaceMay
};

declare function local:getBirth($person){
if ($person//tei:birth[1][@when-iso])
    then
        ($person//tei:birth[1]/@when-iso)
    else
        if ($person//tei:birth[1][@notBefore] and $person//tei:birth[1][@notAfter])
        then
            (concat($person//tei:birth[1]/@notBefore, '/', $person//tei:birth[1]/@notAfter))
        else
            if ($person//tei:birth[1][@notBefore])
            then
                ($person//tei:birth[1]/@notBefore)
            else
                if ($person//tei:birth[1][@notAfter])
                then
                    ($person//tei:birth[1]/@notAfter)
                else
                    ('noBirth')
};
declare function local:getDeath($person){
if ($person//tei:death[1][@when-iso])
    then
        ($person//tei:death[1]/@when-iso)
    else
        if ($person//tei:death[1][@notBefore] and $person//tei:death[1][@notAfter])
        then
            (concat($person//tei:death[1]/@notBefore, '/', $person//tei:death[1]/@notAfter))
        else
            if ($person//tei:death[1][@notBefore])
            then
                ($person//tei:death[1]/@notBefore)
            else
                if ($person//tei:death[1][@notAfter])
                then
                    ($person//tei:death[1]/@notAfter)
                else
                    ('noDeath')
                    };

declare function local:formatLifedata($lifedata){
if(starts-with($lifedata,'-')) then(concat(substring(format-number(number($lifedata),'##.##;##.##'),2),' v. Chr.')) else($lifedata)
};

declare function local:getLifedata($person){
let $birth := if(local:getBirth($person)='noBirth')then()else(local:getBirth($person))
let $birthFormatted := local:formatLifedata($birth)
let $death := if(local:getDeath($person)='noDeath')then()else(local:getDeath($person))
let $deathFormatted := local:formatLifedata($death)
let $lifedata:= if ($birthFormatted[. != ''] and $deathFormatted[. != ''])
                then
                    (concat(' (', $birthFormatted, '–', $deathFormatted, ')'))
                else
                    if ($birthFormatted and not($deathFormatted))
                    then
                        (concat(' (*', $birthFormatted, ')'))
                    else
                        if ($deathFormatted and not($birthFormatted))
                        then
                            (concat(' (†', $deathFormatted, ')'))
                        else
                            ()
    return
        $lifedata
                };

declare function local:replaceToSortDist($input) {
distinct-values(
                replace(replace(replace(replace(replace(replace(replace(replace(replace($input,'ö','oe'),'ä','ae'),'ü','ue'),'É','E'),'é','e'),'è','e'),'ê','e'),'á','a'),'à','a')
                )
                };
                
declare function local:turnName($nameToTurn){
let $nameTurned := if(contains($nameToTurn,'['))
                   then($nameToTurn)
                   else(concat(string-join(subsequence(tokenize($nameToTurn,', '),2),' '),
                   ' ',subsequence(tokenize($nameToTurn,', '),1,1)))
return
    $nameTurned
};

declare function local:getReferences($idToReference) {
    let $collectionReference := (collection("/db/contents/jra/persons")//tei:TEI//@key[.=$idToReference], collection("/db/contents/jra/institutions")//tei:TEI//@key[.=$idToReference], collection("/db/contents/jra/texts")//tei:TEI//@key[.=$idToReference], collection("/db/contents/jra/sources")//tei:TEI//tei:note[@type='regeste']//@key[.=$idToReference], collection("/db/contents/jra")//mei:mei//@auth[.=$idToReference])
        for $doc in $collectionReference
            let $docRoot := if($doc/ancestor::tei:TEI)
                            then($doc/ancestor::tei:TEI)
                            else if($doc/ancestor::mei:mei)
                            then($doc/ancestor::mei:mei)
                            else('unknownNamespace')
            let $docID := $docRoot/@xml:id
            let $docType := if(starts-with($docRoot/@xml:id,'A'))
                            then($docRoot//tei:textClass//tei:term)
                            else if (starts-with($docRoot/@xml:id,'B'))
                            then ('Werk')
                            else if(starts-with($docRoot/@xml:id,'C'))
                            then('Person')
                            else if(starts-with($docRoot/@xml:id,'D'))
                            then('Institution')
                            else('Sonstige')
            let $correspActionSent := $docRoot//tei:correspAction[@type="sent"]
            let $correspActionReceived := $docRoot//tei:correspAction[@type="received"]
            let $correspSentTurned := local:getSenderTurned($correspActionSent)
            let $correspReceivedTurned := local:getReceiverTurned($correspActionReceived)
            let $docDate := if(starts-with($docRoot/@xml:id,'A'))
                            then(local:getDate($docRoot//tei:correspAction[@type='sent']))
                            else(<br/>)
            let $docTitle := if(starts-with($docRoot/@xml:id,'A'))
                             then($correspSentTurned,<br/>,'an ',$correspReceivedTurned)
                             else if($docRoot/name()='TEI')
                             then($docRoot//tei:titleStmt/tei:title/string())
                             else if($docRoot/name()='mei') 
                             then($docRoot//mei:titleStmt/mei:title/string())
                             else('noTitle')
            let $href := if(starts-with($docRoot/@xml:id,'A'))
                            then('../letter/')
                            else if (starts-with($docRoot/@xml:id,'B'))
                            then ('../work/')
                            else if(starts-with($docRoot/@xml:id,'C'))
                            then('../person/')
                            else if(starts-with($docRoot/@xml:id,'D'))
                            then('../institution/')
                            else()
            let $entry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                            <div class="col-3">{if(starts-with($docRoot/@xml:id,'A') and $doc[./ancestor::tei:note])
                                                then('Regeste',<br/>)
                                                else()}
                                                {$docType}
                                                {if($docDate and starts-with($docRoot/@xml:id,'A'))
                                                then(' vom ',local:formatDate($docDate))
                                                else()}
                           </div>
                           <div class="col">{$docTitle}</div>
                           <div class="col-2"><a href="{concat($href,$docID)}">{$docID/string()}</a></div>
                         </div>
            order by $docID
            return
                $entry
};

declare function local:getSenderTurned($correspActionSent){
let $sender := if($correspActionSent/tei:persName[3]/text())
                then(concat(local:turnName($correspActionSent/tei:persName[1]/text()[1]),'/', local:turnName($correspActionSent/tei:persName[2]/text()[1]),'/', local:turnName($correspActionSent/tei:persName[3]/text()[1]))) 
                else if($correspActionSent/tei:persName[2]/text())
                        then(concat(local:turnName($correspActionSent/tei:persName[1]/text()[1]),' und ',local:turnName($correspActionSent/tei:persName[2]/text()[1]))) 
                        else if($correspActionSent/tei:persName/text()) 
                             then(local:turnName($correspActionSent/tei:persName/text()[1])) 
                             else if($correspActionSent/tei:orgName/text()) 
                                  then($correspActionSent/tei:orgName/text()[1]) 
                                  else('[N.N.]')
  return
    $sender
};
declare function local:getSender($correspActionSent){
let $sender := if($correspActionSent/tei:persName[3]/text())
                then(concat($correspActionSent/tei:persName[1]/text()[1],'/', $correspActionSent/tei:persName[2]/text()[1],'/', $correspActionSent/tei:persName[3]/text()[1])) 
                else if($correspActionSent/tei:persName[2]/text())
                        then(concat($correspActionSent/tei:persName[1]/text()[1],' und ', $correspActionSent/tei:persName[2]/text()[1])) 
                        else if($correspActionSent/tei:persName/text()) 
                             then($correspActionSent/tei:persName/text()[1]) 
                             else if($correspActionSent/tei:orgName/text()) 
                                  then($correspActionSent/tei:orgName/text()[1]) 
                                  else('[N.N.]')
  return
    $sender
};

declare function local:getReceiverTurned($correspActionReceived){

let $receiver := if($correspActionReceived/tei:persName[3]/text()) 
                                then(concat(local:turnName($correspActionReceived/tei:persName[1]/text()[1]),'/', local:turnName($correspActionReceived/tei:persName[2]/text()[1]),'/', local:turnName($correspActionReceived/tei:persName[3]/text()[1]))) 
                                else if($correspActionReceived/tei:persName[2]/text()) 
                                     then(concat(local:turnName($correspActionReceived/tei:persName[1]/text()[1]),' und ', local:turnName($correspActionReceived/tei:persName[2]/text()[1]))) 
                                     else if($correspActionReceived/tei:persName/text()) 
                                          then(local:turnName($correspActionReceived/tei:persName/text()[1])) 
                                          else if($correspActionReceived/tei:orgName/text()) 
                                               then($correspActionReceived/tei:orgName/text()[1]) 
                                               else ('[N.N.]')
 return
     $receiver
};

declare function local:getReceiver($correspActionReceived){

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

declare function local:getCorrespondance($idToReference){
    let $correspondence := collection("/db/contents/jra/sources/documents/letters")//tei:TEI//@key[.=$idToReference][not(./ancestor::tei:note[@type='regeste'])]
    for $doc in $correspondence
        let $letter := $doc/ancestor::tei:TEI
        let $letterID := $letter/@xml:id/string()
        let $correspActionSent := $letter//tei:correspAction[@type="sent"]
        let $correspActionReceived := $letter//tei:correspAction[@type="received"]
        let $correspSentTurned := local:getSenderTurned($correspActionSent)
        let $correspReceivedTurned := local:getReceiverTurned($correspActionReceived)
        let $date := local:getDate($correspActionSent)
        let $year := substring($date,1,4)
        let $dateFormatted := local:formatDate($date)
        
        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3">{$dateFormatted}</div>
                                <div class="col">{$correspSentTurned}<br/>an {$correspReceivedTurned}</div>
                                <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                            </div>
        
            order by $date
        return
        $letterEntry
};

declare function local:getNameJoined($person){
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

declare function local:getWorks($cat){
    let $works := collection('/db/contents/jra/works')//mei:term[.=$cat]/ancestor::mei:mei
    for $work in $works
        let $workName := $work//mei:workList//mei:title[matches(@type,'uniform')]/normalize-space(text())
        let $opus := $work//mei:workList//mei:title[matches(@type,'desc')]/normalize-space(text())
        let $withoutArticle := replace(replace(replace(replace(replace(replace($workName,'Der ',''),'Den ',''), 'Die ',''), 'La ',''), 'Le ',''), 'L’','')
        let $workID := $work/@xml:id/string()
        return
            <div titleToSort="{$withoutArticle}"
            class="row {if(string-length($cat)>9)then('RegisterEntry2')else('RegisterEntry')}">
                <div
                    class="col">{$workName}</div>
                <div
                    class="col-2">{$opus}</div>
                <div
                    class="col-2"><a onclick="pleaseWait()"
                        href="work/{$workID}">{$workID}</a>
                </div>
            </div>
};

declare function app:registryLettersDate($node as node(), $model as map(*)) {

    let $letters := (collection('/db/contents/jra/sources/documents/letters')//tei:TEI, collection('/db/contents/jra/sources/documents/others')//tei:TEI)
    let $persons := collection('/db/contents/jra/persons')//tei:TEI
    let $institutions := collection('/db/contents/jra/institutions')//tei:TEI
    let $collection := ($persons, $institutions)
    let $lettersCrono := for $letter in $letters
                        let $letterID := $letter/@xml:id/string()
                        let $correspActionSent := $letter//tei:correspAction[matches(@type,'^sent')]
                        let $correspActionReceived := $letter//tei:correspAction[matches(@type,'^received')]
                        let $correspSent := local:getSender($correspActionSent)
                        let $correspSentTurned := local:getSenderTurned($correspActionSent)
                        let $correspReceived := local:getReceiver($correspActionReceived)
                        let $correspReceivedTurned := local:getReceiverTurned($correspActionReceived)
                        let $date := local:getDate($correspActionSent)
                        let $year := substring($date,1,4)
                        let $dateFormatted := local:formatDate($date)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3" dateToSort="{if($date='0000-00-00')then(replace($date,'0000-','9999-'))else($date)}">{$dateFormatted}</div>
                                <div class="col">{$correspSentTurned}<br/>an {$correspReceivedTurned}</div>
                                <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                            </div>
                        group by $year
                        order by $year
                        return
                            (<div name="{$year}" count="{count($letterEntry)}" xmlns="http://www.w3.org/1999/xhtml">
                                {for $each in $letterEntry
                                    order by $each/div/@dateToSort
                                    return
                                        $each}
                             </div>)
     
     let $lettersGroupedByYears :=
        for $groups in $lettersCrono
        let $year := if($groups/@name/string()='0000')then('[Jahr nicht ermittelbar]')else($groups/@name/string())
        let $count := $groups/@count/string()
        order by $year
        return
            (<div class="RegisterSortBox" year="{$year}" count="{$count}" xmlns="http://www.w3.org/1999/xhtml">
                <div class="RegisterSortEntry" id="{concat('list-item-',if($year='[Jahr nicht ermittelbar]')then('unknown')else($year))}">
                                                    {$year}
                </div>
                {
                    for $group in $groups
                        return
                            $group
                }
            </div>)
    
    return
        (<div class="container">
        <div class="row">
        <div class="col-10">
        <p>Der Katalog verzeichnet derzeit {count($letters)} Briefe und Postkarten.</p>
                    <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li class="nav-item"><a class="nav-link-jra active" href="#date">Datum</a></li>
                        <li class="nav-item"><a class="nav-link-jra" onclick="pleaseWait()" href="registryLettersSender.html">Absender</a></li>
                        <li class="nav-item"><a class="nav-link-jra" onclick="pleaseWait()" href="registryLettersReceiver.html">Empfänger</a></li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane fade show active" id="date">
                            <br/>
                            <div class="row">
        					   <div id="navigator" class="list-group col-3" style="height:500px; overflow-y: scroll;">
            					   <ul id="nav" class="nav hidden-xs hidden-sm"> <!-- position: relative; style="height: 500px; overflow-y: scroll; width: 200px;" -->
                                       {
                                        for $year at $pos in $lettersGroupedByYears[@year !='']
                                        let $letterCount := $year/@count/string()
                                        let $letterYear := $year/@year/string()
                                            order by $year
                                        return
                                            <a class="nav-link list-group-item list-group-item-action justify-content-between align-items-center d-flex" href="{concat('#list-item-', if($letterYear='[Jahr nicht ermittelbar]')then('unknown')else($letterYear))}">
                                            <span>{
                                                    if ($letterYear = '[Jahr unbekannt]') then
                                                        ('[ohne Jahr]')
                                                    else
                                                        ($letterYear)
                                                   }
                                            </span>
                                            <span class="badge badge-jra badge-pill right">{$letterCount}</span></a>
                                       }
                                       </ul>
                                  </div>
                        <div id="divResults" data-spy="scroll" data-target="#navigator" data-offset="90" class="col-md-9 col-sm-9" style="position: relative; height:500px; overflow-y: scroll;">
                            {$lettersGroupedByYears}
                        </div>
                    </div>
                  <!--<div
                    class="col-3">
                    <br/><br/>
                    <h5>Filter​n <img src="../resources/fonts/feather/info.svg" width="23px" data-toggle="popover" title="Ansicht reduzieren." data-content="Geben Sie einen Namen oder eine ID ein. Der Filter zeigt nur Datensätze an, die Ihren Suchbegriff enthalten."/></h5>
                    <input
                        type="text"
                        id="myResearchInput"
                        onkeyup="myFilterLetter()"
                        placeholder="Name oder ID"
                        title="Type in a string"/>
                </div>-->
                  </div>
                    </div>
                </div>
            </div>
        </div>
        )
};

declare function app:registryLettersSender($node as node(), $model as map(*)) {

    let $letters := (collection('/db/contents/jra/sources/documents/letters')//tei:TEI,collection('/db/contents/jra/sources/documents/others')//tei:TEI)
    let $persons := collection('/db/contents/jra/persons')//tei:TEI
    let $institutions := collection('/db/contents/jra/institutions')//tei:TEI
    let $collection := ($persons, $institutions)
    
    let $lettersSender := for $letter in ($letters//tei:correspAction[matches(@type,"^sent")]//tei:persName,$letters//tei:correspAction[matches(@type,"^sent")]//tei:orgName)
                        let $letterID := $letter/ancestor::tei:TEI/@xml:id/data(.)
                        let $correspActionSent := $letter/ancestor::tei:correspDesc/tei:correspAction[matches(@type,"^sent")]
                        let $correspActionReceived := $letter/ancestor::tei:correspDesc/tei:correspAction[matches(@type,"^received")]
                        let $correspSent :=  local:getSender($correspActionSent)
                        let $correspSentId := normalize-space(if($letter/@key)
                                              then($letter/@key)
                                              else('noID'))
                        
                        let $correspReceivedTurned := local:getReceiverTurned($correspActionReceived)
                        let $correspReceived := local:getReceiver($correspActionReceived)
                        let $senderName := normalize-space(if($correspSentId!='noID')
                                           then(for $data in $collection[range:eq(@xml:id,$correspSentId)]
                                               let $title := $data//tei:titleStmt/tei:title/string()
                                               return
                                                $title)
                                                else($correspSent))
                                                                   
                        let $date := local:getDate($correspActionSent)
                        let $year := substring($date,1,4)
                        let $dateFormatted := local:formatDate($date)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3" dateToSort="{$date}">{$dateFormatted}</div>
                                <div class="col">an {$correspReceivedTurned}</div>
                                <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                            </div>
                        group by $senderName
                        return
                            (<div sender="{distinct-values($senderName)}" senderId="{distinct-values($correspSentId)}" count="{count($letterEntry)}" xmlns="http://www.w3.org/1999/xhtml">
                                {for $each in $letterEntry
                                    order by $each/div/@dateToSort
                                    return
                                        $each}
                             </div>)
                             
    let $lettersGroupedBySenders :=
        for $groups in $lettersSender
        let $sender := $groups/@sender/string()
        let $senderId := $groups/@senderId/string()
        let $count := $groups/@count/string()
        order by $sender
        return
            (<div class="RegisterSortBox" sender="{$sender}" senderId="{$senderId}" count="{$count}" xmlns="http://www.w3.org/1999/xhtml">
                <div class="RegisterSortEntry" id="{concat('list-item-',if(not(matches($senderId, '^noID')))then($senderId)else(translate(normalize-space($sender),',.’ ','____')))}">
                                                    {if(matches($sender,'^noReceiver'))then('[N.N.]')else($sender)}
                </div>
                {
                    for $group in $groups
                        return
                            $group
                }
            </div>)
    
    return
        (<div class="container">
            <div class="row">
                <div class="col-10">
                    <p>Der Katalog verzeichnet derzeit {count($letters)} Briefe und Postkarten.</p>
                    <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li class="nav-item"><a class="nav-link-jra" onclick="pleaseWait()" href="registryLettersDate.html">Datum</a></li>
                        <li class="nav-item"><a class="nav-link-jra active" href="#sender">Absender</a></li>
                        <li class="nav-item"><a class="nav-link-jra" onclick="pleaseWait()" href="registryLettersReceiver.html">Empfänger</a></li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane fade show active" id="sender">
                            <br/>
                            <div
                                class="row">
                                <div id="navigator" class="list-group col-sm-3" style="height:500px; overflow-y: scroll;">
            					   <ul id="nav" class="nav hidden-xs hidden-sm"> <!-- position: relative; style="height: 500px; overflow-y: scroll; width: 200px;" -->
                                    {
                                        for $sender in $lettersGroupedBySenders
                                        let $letterCount := $sender/@count/string()
                                        let $letterSender := $sender/@sender/string()
                                        let $letterSenderId := if(not(matches($sender/@senderId/string(),'^noID')))then(($sender/@senderId/string()))else(translate(normalize-space($letterSender),',.’ ','____'))
                                            order by $letterSender
                                        return
                                            <a
                                                class="nav-link list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-',$letterSenderId)}"><span>{if(matches($letterSenderId,'^noSender'))then('[N.N.]')else($letterSender)}</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$letterCount}</span>
                                            </a>
                                    }
                                </ul>
                                </div>
                                <div data-spy="scroll" data-target="#navigator" data-offset="90" class="col-sm-9" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$lettersGroupedBySenders}
                                </div>
                            </div>
                            </div>
                            </div>
                            </div>
                            </div>
                            </div>
                    
        )

};

declare function app:registryLettersReceiver($node as node(), $model as map(*)) {

    let $letters := (collection('/db/contents/jra/sources/documents/letters')//tei:TEI,collection('/db/contents/jra/sources/documents/others')//tei:TEI)
    let $persons := collection('/db/contents/jra/persons')//tei:TEI
    let $institutions := collection('/db/contents/jra/institutions')//tei:TEI
    let $collection := ($persons, $institutions)
    
    let $lettersReceiver := for $letter in ($letters//tei:correspAction[matches(@type,"^received")]//tei:persName,$letters//tei:correspAction[matches(@type,"received")]//tei:orgName)
                        let $letterID := $letter/ancestor::tei:TEI/@xml:id/data(.)
                        let $correspActionSent := $letter/ancestor::tei:correspDesc/tei:correspAction[matches(@type,"sent")]
                        let $correspActionReceived := $letter/ancestor::tei:correspDesc/tei:correspAction[matches(@type,"received")]
                        
                        let $correspSentTurned := local:getSenderTurned($correspActionSent)
                        let $correspSent := local:getSender($correspActionSent)
                        let $correspReceivedId := normalize-space(if($letter/@key)
                                              then($letter/@key)
                                              else('noID'))
                        
(:                        let $correspReceivedTurned := local:getReceiverTurned($correspActionReceived):)
                        let $correspReceived := local:getReceiver($correspActionReceived)
                        
                        let $receiverName := normalize-space(if($correspReceivedId !='noID')
                                             then(for $data in $collection[range:eq(@xml:id,$correspReceivedId)]
                                               let $title := $data//tei:titleStmt/tei:title/string()
                                               return
                                                $title)
                                             else($correspReceived))
                                              
                        let $date := local:getDate($correspActionSent)
                        let $year := substring($date,1,4)
                        let $dateFormatted := local:formatDate($date)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3" dateToSort="{$date}">{$dateFormatted}</div>
                                <div class="col">von {$correspSentTurned}</div>
                                <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                            </div>
                        group by $receiverName
                        return
                            (<div receiver="{distinct-values($receiverName)}" receiverId="{distinct-values($correspReceivedId)}" count="{count($letterEntry)}" xmlns="http://www.w3.org/1999/xhtml">
                                {for $each in $letterEntry
                                    order by $each/div/@dateToSort
                                    return
                                        $each}
                             </div>)
                             
    let $lettersGroupedByReceivers :=
        for $groups in $lettersReceiver
        let $receiver := $groups/@receiver/string()
        let $receiverId := $groups/@receiverId/string()
        let $count := $groups/@count/string()
        order by $receiver
        return
            (<div class="RegisterSortBox" receiver="{$receiver}" receiverId="{$receiverId}" count="{$count}" xmlns="http://www.w3.org/1999/xhtml">
                <div class="RegisterSortEntry" id="{concat('list-item-',if(not(matches($receiverId,'^noID')))then($receiverId)else(translate(normalize-space($receiver),',.’[] ','______')))}">
                                                    {if(matches($receiver,'^noReceiver'))then('[N.N.]')else($receiver)}
                </div>
                {
                    for $group in $groups
                        return
                            $group
                }
            </div>)
    
    return
         (<div class="container">
            <div class="row">
                <div class="col-11">
                    <p>Der Katalog verzeichnet derzeit {count($letters)} Briefe und Postkarten.</p>
                    <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li class="nav-item"><a class="nav-link-jra" onclick="pleaseWait()" href="registryLettersDate.html">Datum</a></li>
                        <li class="nav-item"><a class="nav-link-jra" onclick="pleaseWait()" href="registryLettersSender.html">Absender</a></li>
                        <li class="nav-item"><a class="nav-link-jra active" href="#receiver">Empfänger</a></li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane fade show active" id="receiver">
                            <br/>
                       <div
                                class="row">
                                <div id="navigator" class="list-group col-sm-3" style="height:500px; overflow-y: scroll;">
            					   <ul id="nav" class="nav hidden-xs hidden-sm"> <!-- position: relative; style="height: 500px; overflow-y: scroll; width: 200px;" -->
                                    <!--  -->
                                    {
                                        for $receiver in $lettersGroupedByReceivers
                                        let $letterCount := $receiver/@count/string()
                                        let $letterReceiver := $receiver/@receiver/string()
                                        let $letterReceiverId := if(not(matches($receiver/@receiverId/string(),'noID')))then($receiver/@receiverId/string())else(translate(normalize-space($letterReceiver),',.’[] ','______'))
                                            order by $letterReceiver
                                        return
                                            <a
                                                class="nav-link list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-',$letterReceiverId)}"><span>{if(matches($letterReceiver,'^noReceiver'))then('[N.N.]') else ($letterReceiver)}</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$letterCount}</span>
                                            </a>
                                    }
                                </ul>
                                </div>
                                <div data-spy="scroll" data-target="#navigator" data-offset="90" class="col-sm-9" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$lettersGroupedByReceivers}
                                </div>
                            </div>
                            </div></div>
                            </div>
                            </div>
                            </div>
        )

};


declare function app:letter($node as node(), $model as map(*)) {
    
    let $id := request:get-parameter("letter-id", "Fehler")
    let $letter := collection("/db/contents/jra/sources/documents/letters")//tei:TEI[@xml:id = $id]
    let $person := collection("/db/contents/jra/persons")//tei:TEI
    let $absender := $letter//tei:correspAction[@type = "sent"]/tei:persName[1]/text()[1] (:$person[@xml:id= $letter//tei:correspAction[@type="sent"]/tei:persName[1]/@key]/tei:forename[@type='used']:)
    let $datumSent := local:formatDate(local:getDate($letter//tei:correspAction[@type = "sent"]))
    let $correspReceived := $letter//tei:correspAction[@type = "received"]
    let $adressat := if($letter//tei:correspAction[@type = "received"]/tei:persName) then ($letter//tei:correspAction[@type = "received"]/tei:persName[1]/text()[1]) else if($letter//tei:correspAction[@type = "received"]/tei:orgName[1]/text()[1]) then($letter//tei:correspAction[@type = "received"]/tei:orgName[1]/text()[1]) else('')
    let $nameTurned := if(contains($adressat,', '))then(concat($adressat/substring-after(., ','),' ',$adressat/substring-before(., ',')))else($adressat)
    let $regeste := $letter//tei:note[@type='regeste']
    let $fulltext := $letter//tei:div[@type='volltext']
    return
        (
        <div
            class="container">
            <div
                class="page-header">
                <h5>{$datumSent}</h5>
                <h2>Brief an {$nameTurned}</h2>
                <h6>ID: {$id}</h6>
                <hr/>
                <ul
                class="nav nav-pills"
                role="tablist">
                <li
                    class="nav-item"><a
                        class="nav-link-jra active"
                        data-toggle="tab"
                        href="#letterMetadata">Allgemein</a></li>
                {if ($regeste) then(<li
                    class="nav-item"><a
                        class="nav-link-jra"
                        data-toggle="tab"
                        href="#contentLetterRegeste">Regeste</a></li>)else()}
                {if ($fulltext/tei:p != '') then(<li
                    class="nav-item"><a
                        class="nav-link-jra"
                        data-toggle="tab"
                        href="#letterContentFull">Volltext</a></li>)else()}
                <li
                    class="nav-item"><a
                        class="nav-link-jra"
                        data-toggle="tab"
                        href="#viewXML">XML-Ansicht</a></li>
            </ul>
                <hr/>
            </div>
            <div
                class="container">
                <div
                    class="row">
                    <div
                        class="col">
            <div
                class="tab-content">
                <div
                    class="tab-pane fade show active"
                    id="letterMetadata">
                    <br/>
                    <div
                        class="row">
                        
                        <div
                            class="col">
                            {transform:transform($letter, doc("/db/apps/raffArchive/resources/xslt/metadataLetter.xsl"), ())}
                        </div>
                        <div
                            class="col-sm-3">
                            {if($letter//tei:revisionDesc/tei:change)
                                then(<div class="suggestedCitation">
                                <span class="heading" style="font-size: medium;">Änderungen:</span>
                                <br/>
                                {
                                for $change at $n in $letter//tei:revisionDesc/tei:change
                                    let $changeDate := concat(format-date(xs:date($change/@when), '[D]. [M,*-3]. [Y]', 'de', (), ()), ' ')
                                    let $changerName := $change/@who/string()
                                    let $changeInfo := $change/string()
                                    let $changeInfoButton := <img src="http://localhost:8080/exist/apps/raffArchive/resources/fonts/feather/info.svg" width="18px" data-toggle="popover" data-original-title="{$changerName}" data-content="{$changeInfo}"/>
                                    return
                                        (<span style="padding-left: 3px;"/>,$changeDate, $changeInfoButton, <br/>)
                                }<br/>
                              </div>)
                            else()
                        }
                        <div class="suggestedCitation">
                            <span class="heading" style="font-size: medium;">Zitiervorschlag:</span>
                            <br/>
                            {concat($absender,': Brief an ',$nameTurned,' (',$datumSent,'); ')}<a href="{concat('http://localhost:8080/exist/apps/raffArchive/html/letter/',$id)}">{concat('http://localhost:8080/exist/apps/raffArchive/html/letter/',$id)}</a>, abgerufen am {format-date(current-date(), '[D]. [M,*-3]. [Y]', 'de', (), ())}
                         </div>
                        </div>
                    </div>
                </div>
                {if ($regeste)
                 then (<div
                    class="tab-pane fade"
                    id="contentLetterRegeste">
                    <br/>
                        <div
                            class="row">
                            <div class="col">
                                {transform:transform($letter, doc("/db/apps/raffArchive/resources/xslt/contentLetterRegeste.xsl"), ())}
                            </div>
                        </div>
                </div>)else()}
                {if ($fulltext/tei:p != '')
                 then (<div
                    class="tab-pane fade"
                    id="letterContentFull">
                        <div
                            class="row">
                            <div class="letterContentFullView">
                                {transform:transform($letter//tei:body/tei:div[@type = "volltext"], doc("/db/apps/raffArchive/resources/xslt/contentLetterFull.xsl"), ())}
                            </div>
                        </div>
                </div>)else()}
                <div
                    class="tab-pane fade"
                    id="viewXML">
                    <pre
                                    class="pre-scrollable">
                                    <xmp>
                    {transform:transform($letter, doc("/db/apps/raffArchive/resources/xslt/viewXML.xsl"), ())}
                    </xmp>
                    </pre>
                </div>
            </div>
        </div>
        </div>
        </div>
        </div>
        )
};

declare function app:registryPersonsInitial($node as node(), $model as map(*)) {
    
    let $persons := collection("/db/contents/jra/persons/")//tei:TEI
    
    let $personsAlpha := for $person in $persons
                            let $persID := $person/@xml:id/string()
                            let $initial := substring($person//tei:surname[matches(@type,"^used")][1], 1, 1)
                            let $nameSurname := $person//tei:surname[matches(@type,"^used")][1]
                            let $role := $person//tei:roleName[1]/text()[1]
                            let $pseudonym := if ($person//tei:forename[matches(@type,'^pseudonym')] or $person//tei:surname[matches(@type,'^pseudonym')])
                                               then (string-join(($person//tei:forename[matches(@type,'^pseudonym')], $person//tei:surname[matches(@type,'^pseudonym')]),' '))
                                               else ()
                            let $occupation := $person//tei:occupation[1]/text()[1]
                            
                            let $lifeData := local:getLifedata($person)
                            let $nameJoined := local:getNameJoined($person)
                            let $nameToSort := local:replaceToSortDist($nameSurname)
                            let $name := <div
                                class="row RegisterEntry">
                                <div
                                    class="col">
                                    {$nameJoined}
                                    {$lifeData}
                                    {
                                        if ($pseudonym or $role or $occupation)
                                        then (<br/>,
                                                <span class="sublevel">
                                                    {concat('(',
                                                            string-join((if($pseudonym)then(concat($pseudonym,' [Pseudonym]'))else(),
                                                                         if($role)then($role)else(),
                                                                         if($occupation)then($occupation)else()),' | ')
                                                            ,')')
                                                    }
                                                </span>)
                                        else ()
                                    }
                                </div>
                                <!--<div class="col-3"></div>-->
                                <div
                                    class="col-2"><a  onclick="pleaseWait()"
                                        href="person/{$persID}">{$persID}</a></div>
                            </div>
                                group by $initial
                                order by $initial
                            return
                                (<div
                                    name="{$initial}"
                                    count="{count($name)}">
                                    {
                                        for $each in $name
                                        let $order := local:replaceToSortDist($each)
                                            order by $order
                                        return
                                            $each
                                    }
                                </div>)
    
    let $personsGroupedByInitials := for $groups in $personsAlpha
                                        group by $initial := $groups/@name/string()
                                        return
                                            (<div
                                                class="RegisterSortBox"
                                                initial="{$initial}"
                                                count="{$personsAlpha[@name=$initial]/@count}"
                                                xmlns="http://www.w3.org/1999/xhtml">
                                                <div
                                                    class="RegisterSortEntry"
                                                    id="{
                                                            concat('list-item-', if ($initial='') then
                                                                ('unknown')
                                                            else
                                                                ($initial))
                                                        }">
                                                    {
                                                        if ($initial = '') then
                                                            ('[ohne Nachname]')
                                                        else
                                                            ($initial)
                                                    }
                                                </div>
                                                {
                                                    for $group in $groups
                                                    return
                                                        $group
                                                }
                                            </div>)
    
    return
        
        <div
            class="container"
            xmlns="http://www.w3.org/1999/xhtml">
            <div
                class="row">
                <div
                    class="col-9">
                    <p>Der Katalog verzeichnet derzeit {count($persons)} Personen.</p>
                    <ul
                        class="nav nav-tabs"
                        id="myTab"
                        role="tablist">
                        <li
                            class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra active"
                                href="#alpha">Alphabetisch</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                href="registryPersonsBirth.html" onclick="pleaseWait()">Geburtsjahr</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                href="registryPersonsDeath.html" onclick="pleaseWait()">Sterbejahr</a></li>
                    </ul>
                    <div
                        class="tab-content">
                        <div
                            class="tab-pane fade show active"
                            id="alpha">
                            <br/>
                            <div
                                class="row" >
                                <div id="navigator" class="list-group col-3" style="height:500px; overflow-y: scroll;">
            					   <ul id="nav" class="nav hidden-xs hidden-sm"> <!-- position: relative; style="height: 500px; overflow-y: scroll; width: 200px;" -->
                                    {
                                        for $each in $personsGroupedByInitials
                                            let $initial := if ($each/@initial/string() = '') then
                                                ('unknown')
                                            else
                                                ($each/@initial/string())
                                            let $count := $each/@count/string()
                                            order by $initial
                                        return
                                            <a
                                                class="nav-link list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', $initial)}"><span>{
                                                        if (matches($initial,'unknown')) then
                                                            ('[ohne Initial]')
                                                        else
                                                            ($initial)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                            </a>
                                    }
                                
                                </ul>
                                </div>
                                <div data-spy="scroll" data-target="#navigator" data-offset="90" class="col-md-9 col-sm-9" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$personsGroupedByInitials}
                                </div>
                            </div>
                        </div>
                        </div>
                </div>
            </div>
        </div>
};

declare function app:registryPersonsBirth($node as node(), $model as map(*)) {
    
    let $persons := collection("/db/contents/jra/persons/")//tei:TEI
    
    let $personsBirth := for $person in $persons
                             let $persID := $person/@xml:id/string()
                             let $nameJoined := local:getNameJoined($person)
                             let $nameSurname := $person//tei:surname[matches(@type,"^used")][1]
                             let $role := $person//tei:roleName[1]/text()[1]
                             let $pseudonym := if ($person//*[matches(@type,'^pseudonym')][1]/text()[1])
                                               then (string-join(($person//tei:forename[matches(@type,'^pseudonym')], $person//tei:surname[matches(@type,'^pseudonym')]),' '))
                                               else ()
                             let $occupation := $person//tei:occupation[1]/text()[1]
                             
                             let $birth := local:getBirth($person)
                             let $birthToSort := if (contains($birth,'/')) then(substring-before($birth,'/')) else($birth)
                             let $birthFormatted := local:formatLifedata($birth)
                             let $lifeData := local:getLifedata($person)
                             
                             let $name := <div
                                 class="row RegisterEntry">
                                 <div
                                     class="col">
                                     {$nameJoined}
                                     {$lifeData}
                                     {
                                        if ($pseudonym or $role or $occupation)
                                        then (<br/>,
                                                <span class="sublevel">
                                                    {concat('(',
                                                            string-join((if($pseudonym)then(concat($pseudonym,' [Pseudonym]'))else(),
                                                                         if($role)then($role)else(),
                                                                         if($occupation)then($occupation)else()),' | ')
                                                            ,')')
                                                    }
                                                </span>)
                                        else ()
                                    }
                                 </div>
                                 <!--<div class="col-3"></div>-->
                                 <div
                                     class="col-2"><a  onclick="pleaseWait()"
                                         href="person/{$persID}">{$persID}</a></div>
                             </div>
                                 group by $birth
                                 order by distinct-values($birthToSort)
                             return
                                 (<div
                                     name="{
                                             if (not(matches($birth,'^noBirth'))) then (distinct-values($birthFormatted)) else($birth)
                                         }"
                                         birth="{$birth}"
                                     count="{count($name)}">
                                     {
                                         for $each in $name
                                         let $order := local:replaceToSortDist($each)
                                             order by $order
                                         return
                                             $each
                                     }
                                 </div>)
    
    let $personsGroupedByBirth := for $groups in $personsBirth
                                     let $birthToSort := $groups/@birth/string()
                                     (:if (contains($groups/@birth/string(),'-')) then(substring($groups/@birth,1,5)) else($groups/@birth/number()):)
                                     group by $birth := $groups/@name/normalize-space(string())
                                     order by $birthToSort
                                      return
                                          (<div
                                              class="RegisterSortBox"
                                              birth="{$birth}" birthToSort="{$birthToSort}"
                                              count="{$personsBirth[matches(@name,$birth)]/@count}"
                                              xmlns="http://www.w3.org/1999/xhtml">
                                              <div
                                                  class="RegisterSortEntry"
                                                  id="{concat('list-item-', translate($birth, '/. ', '___'))}">
                                                  {
                                                      if (matches($birth,'^noBirth')) then
                                                          ('[Geburtsjahr nicht erfasst]')
                                                      else
                                                          ($birth)
                                                  }
                                              </div>
                                              {
                                                  for $group in $groups
                                                  return
                                                      $group
                                              }
                                          </div>)
    
    return
        
        <div
            class="container"
            xmlns="http://www.w3.org/1999/xhtml">
            <div
                class="row">
                <div
                    class="col-9">
                    <p>Der Katalog verzeichnet derzeit {count($persons)} Personen.</p>
                    <ul
                        class="nav nav-tabs"
                        id="myTab"
                        role="tablist">
                        <li
                            class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                href="registryPersonsInitial.html" onclick="pleaseWait()">Alphabetisch</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra active"
                                href="#birth">Geburtsjahr</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                href="registryPersonsDeath.html" onclick="pleaseWait()">Sterbejahr</a></li>
                    </ul>
                    <div
                        class="tab-content">
                         <div
                            class="tab-pane fade show active"
                            id="birth">
                            <br/>
                            <div
                                class="row">
                                <div id="navigatorTab2" class="list-group col-3" style="height:500px; overflow-y: scroll;">
            					   <ul id="navTab2" class="nav hidden-xs hidden-sm">
                                    {
                                        for $each in $personsGroupedByBirth
                                        let $birth := $each/@birth/string()
                                        let $birthToSort := $each/@birthToSort/string()
                                        let $count := $each/@count/string()
                                        order by $birthToSort
                                        return
                                            <a
                                                class="nav-link list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', translate($birth, '/. ', '___'))}"><span>{
                                                        if (matches($birth,'noBirth')) then
                                                            ('[nicht erfasst]')
                                                        else
                                                            ($birth)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                             </a>
                                    }
                                </ul>
                                </div>
                                <div data-spy="scroll" data-target="#navigatorTab2" data-offset="90" class="col-md-9 col-sm-9" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$personsGroupedByBirth}
                                </div>
                            </div>
                        </div>
                       </div>
                </div>
            </div>
        </div>
};
 
 declare function app:registryPersonsDeath($node as node(), $model as map(*)) {
    
    let $persons := collection("/db/contents/jra/persons/")//tei:TEI
    
    let $personsDeath := for $person in $persons
                            let $persID := $person/@xml:id/string()
                            let $nameSurname := $person//tei:surname[matches(@type,"^used")][1]
                            let $role := $person//tei:roleName[1]/text()[1]
                            let $pseudonym := if ($person//*[matches(@type,'^pseudonym')][1]/text()[1])
                                               then (string-join(($person//tei:forename[matches(@type,'^pseudonym')], $person//tei:surname[matches(@type,'^pseudonym')]),' '))
                                               else ()
                            let $occupation := $person//tei:occupation[1]/text()[1]
                            
                            let $death := local:getDeath($person)
                            let $deathToSort := if (contains($death,'/')) then(substring-before($death,'/')) else($death)
                            let $deathFormatted := local:formatLifedata($death)
                            let $lifeData := local:getLifedata($person)
                            let $nameJoined := local:getNameJoined($person)
                            let $name := <div
                                class="row RegisterEntry">
                                <div
                                    class="col">
                                    {$nameJoined}
                                    {$lifeData}
                                    {
                                        if ($pseudonym or $role or $occupation)
                                        then (<br/>,
                                                <span class="sublevel">
                                                    {concat('(',
                                                            string-join((if($pseudonym)then(concat($pseudonym,' [Pseudonym]'))else(),
                                                                         if($role)then($role)else(),
                                                                         if($occupation)then($occupation)else()),' | ')
                                                            ,')')
                                                    }
                                                </span>)
                                        else ()
                                    }
                                </div>
                                <!--<div class="col-3"></div>-->
                                <div
                                    class="col-2"><a onclick="pleaseWait()"
                                        href="person/{$persID}">{$persID}</a></div>
                            </div>
                                group by $death
                                order by distinct-values($deathToSort)
                            return
                                (<div
                                    name="{
                                            if (not(matches($death,'^noDeath'))) then (distinct-values($deathFormatted)) else($death)
                                        }"
                                    death="{$death}"
                                    count="{count($name)}">
                                    {
                                        for $each in $name
                                            let $order := local:replaceToSortDist($each)
                                            order by $order
                                        return
                                            $each
                                    }
                                </div>)
    
    let $personsGroupedByDeath := for $groups in $personsDeath
                                    let $deathToSort := $groups/@death/string()
                                    (:if(contains($groups/@death,'/')) then(substring($groups/@death,1,4)) else($groups/@death/number()):)
                                    group by $death := $groups/@name/normalize-space(string())
                                    order by $deathToSort
                                    return
                                        (<div
                                            class="RegisterSortBox"
                                            death="{$death}" deathToSort="{$deathToSort}"
                                            count="{$personsDeath[matches(@name,$death)]/@count}"
                                            xmlns="http://www.w3.org/1999/xhtml">
                                            <div
                                                class="RegisterSortEntry"
                                                id="{concat('list-item-', translate($death, '/. ', '___'))}">
                                                {
                                                    if (matches($death,'^noDeath')) then
                                                        ('[Sterbejahr nicht erfasst]')
                                                    else
                                                        ($death)
                                                }
                                            </div>
                                            {
                                                for $group in $groups
                                                return
                                                    $group
                                            }
                                        </div>)
    
    return
        
        <div
            class="container"
            xmlns="http://www.w3.org/1999/xhtml">
            <div
                class="row">
                <div
                    class="col-9">
                    <p>Der Katalog verzeichnet derzeit {count($persons)} Personen.</p>
                    <ul
                        class="nav nav-tabs"
                        id="myTab"
                        role="tablist">
                        <li
                            class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                href="registryPersonsInitial.html" onclick="pleaseWait()">Alphabetisch</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                href="registryPersonsBirth.html" onclick="pleaseWait()">Geburtsjahr</a></li>
                        <li
                            class="nav-item active"><a
                                class="nav-link-jra"
                                href="#death">Sterbejahr</a></li>
                    </ul>
                    <div
                        class="tab-content">
                       <div
                            class="tab-pane fade show active"
                            id="death">
                            <br/>
                            <div
                                class="row">
                                <div id="navigatorTab3" class="list-group col-3" style="height:500px; overflow-y: scroll;">
            					   <ul id="navTab3" class="nav hidden-xs hidden-sm">
                                    {
                                        for $each in $personsGroupedByDeath
                                        let $deathToSort := $each/@deathToSort/string()
                                        let $death := $each/@death/string()
                                        let $count := $each/@count/string()
                                        order by $deathToSort
                                        return
                                            <a
                                                class="nav-link list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', translate($death, '/. ', '___'))}"><span>{
                                                        if (matches($death,'noDeath')) then
                                                            ('[nicht erfasst]')
                                                        else
                                                            ($death)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                            </a>
                                    }
                                </ul>
                                </div>
                                <div data-spy="scroll" data-target="#navigatorTab3" data-offset="90" class="col-md-9 col-sm-9" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$personsGroupedByDeath}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
};
 
declare function app:person($node as node(), $model as map(*)) {
    
    let $id := request:get-parameter("person-id", "Fehler")
    let $person := collection("/db/contents/jra/persons")//tei:TEI[@xml:id = $id]
    let $name := $person//tei:titleStmt/tei:title/normalize-space(data(.))
    let $letters := collection("/db/contents/jra/sources/documents/letters")//tei:TEI
    let $correspondence := $letters//tei:persName[@key = $id]/ancestor::tei:TEI
    let $literature := $person//tei:bibl[@type='links']
    let $vorkommen := collection("/db/contents/jra")//tei:persName[@key=$id]/ancestor::tei:TEI
    
    return
        (
        <div
            class="container">
            <div
                class="page-header">
                <h2>{$name}</h2>
                <h6>ID: {$id}</h6>
                <hr/>
                    <ul
                            class="nav nav-pills"
                            role="tablist">
                            <li
                                class="nav-item">
                                <a
                                    class="nav-link-jra active"
                                    data-toggle="tab"
                                    href="#metadata">Allgemein</a></li>
                            {if (local:getCorrespondance($id)) then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#correspondence">Korrespondenz</a></li>)else()}
                            {if (local:getReferences($id)) then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#references">Bezüge</a></li>)else()}
                            {if ($literature/text()/normalize-space()!='') then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#literature">Literatur</a></li>)else()}
                            <li
                                class="nav-item"><a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#xmlAnsicht">XML-Ansicht</a></li>
                        </ul>
                        <hr/>
            </div>
            <div
                class="container">
                <div
                    class="row">
                    <div
                        class="col">
                        
                        <div
                            class="tab-content">
                            <div
                                class="tab-pane fade show active"
                                id="metadata">
                                <br/>
                                <div
                        class="row">
                        
                        <div
                            class="col">
                                {transform:transform($person, doc("/db/apps/raffArchive/resources/xslt/metadataPerson.xsl"), ())}
                                </div>
                                <div
                            class="col-sm-3">
                            {if($person//tei:revisionDesc/tei:change)
                                then(<div class="suggestedCitation">
                                <span class="heading" style="font-size: medium;">Änderungen:</span>
                                <br/>
                                {
                                for $change at $n in $person//tei:revisionDesc/tei:change
                                    let $changeDate := concat(format-date(xs:date($change/@when), '[D]. [M,*-3]. [Y]', 'de', (), ()), ' ')
                                    let $changerName := $change/@who/string()
                                    let $changeInfo := $change/string()
                                    let $changeInfoButton := <img src="../../resources/fonts/feather/info.svg" width="18px" data-toggle="popover" data-original-title="{$changerName}" data-content="{$changeInfo}"/>
                                    return
                                        (<span style="padding-left: 3px;"/>,$changeDate, $changeInfoButton, <br/>)
                                }<br/>
                              </div>)
                            else()
                        }
                        <div class="suggestedCitation">
                            <span class="heading" style="font-size: medium;">Zitiervorschlag:</span>
                            <br/>
                            {concat($name,'; ')}<a href="{concat('http://localhost:8080/exist/apps/raffArchive/html/person/',$id)}">{concat('http://localhost:8080/exist/apps/raffArchive/html/person/',$id)}</a>, abgerufen am {format-date(current-date(), '[D]. [M,*-3]. [Y]', 'de', (), ())}
                         </div>
                        </div>
                        </div>
                            </div>
                            {
                                if (local:getCorrespondance($id)) then
                                    (<div
                                        class="tab-pane fade"
                                        id="correspondence">
                                        <br/>
                                        <div class="{if(count(local:getCorrespondance($id)) gt 5) then('pre-scrollable') else()}">{
                                            let $entrys := local:getCorrespondance($id)
                                            return
                                                $entrys
                                        }</div>
                                    </div>)
                                else
                                    ()
                            }
                            {
                                if (local:getReferences($id))
                                then (<div
                                        class="tab-pane fade"
                                        id="references">
                                        <br/>
                                        <div class="{if(count(local:getReferences($id)) gt 5) then('pre-scrollable') else()}">{
                                            let $entrys := local:getReferences($id)
                                            return
                                                $entrys
                                        }</div>
                                      </div>
                                )
                                else
                                    ()
                            }
                            {
                                if ($literature/text()/normalize-space()!='') then
                                    (<div
                                        class="tab-pane fade"
                                        id="literature">
                                        {$literature}
                                    </div>)
                                else
                                    ()
                            }
                            <div
                                class="tab-pane fade"
                                id="xmlAnsicht">
                                <pre
                                    class="pre-scrollable">
                                    <xmp>
                                        {transform:transform($person, doc("/db/apps/raffArchive/resources/xslt/viewXML.xsl"), ())}
                                    </xmp>
                                </pre>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        )
};

declare function app:registryInstitutions($node as node(), $model as map(*)) {
    
    let $institutions := collection("/db/contents/jra/institutions/")//tei:TEI
    
    let $institutionsAlpha := for $institution in $institutions
                                let $instID := $institution/@xml:id/string()
                                let $initial := upper-case(substring($institution//tei:org/tei:orgName[1], 1, 1))
                                let $nameInstitution := $institution//tei:org/tei:orgName[1]
                                let $desc := $institution//tei:org/tei:desc[1]
                                let $place := string-join($institution//tei:org/tei:place/tei:placeName, '/')
                                let $name := <div
                                    class="row RegisterEntry">
                                    <div
                                        class="col-6">
                                        {$nameInstitution}<br/><span class="sublevel">{$desc}</span>
                                    </div>
                                    <div
                                        class="col-4">{$place}</div>
                                    <div
                                        class="col-2"><a onclick="pleaseWait()"
                                            href="institution/{$instID}">{$instID}</a></div>
                                </div>
                                    group by $initial
                                    order by $initial
                                return
                                    (<div
                                        name="{$initial}"
                                        count="{count($name)}">
                                        {
                                            for $each in $name
                                                let $order := local:replaceToSortDist($each)
                                                order by $order
                                            return
                                                $each
                                        }
                                    </div>)
    
    let $institutionsGroupedByInitials := for $groups in $institutionsAlpha
                                            group by $initial := $groups/@name/string()
                                            return
                                                (<div
                                                    class="RegisterSortBox"
                                                    initial="{$initial}"
                                                    count="{$institutionsAlpha[@name = $initial]/@count}"
                                                    xmlns="http://www.w3.org/1999/xhtml">
                                                    <div
                                                        class="RegisterSortEntry"
                                                        id="{
                                                                concat('list-item-', if ($initial = '') then
                                                                    ('unknown')
                                                                else
                                                                    ($initial))
                                                            }">
                                                        {
                                                            if ($initial = '') then
                                                                ('[N.N.]')
                                                            else
                                                                ($initial)
                                                        }
                                                    </div>
                                                    {
                                                        for $group in $groups
                                                        return
                                                            $group
                                                    }
                                                </div>)
    
    let $institutionsPlace := for $place in $institutions//tei:org/tei:place/tei:placeName
                                let $instID := $place/ancestor::tei:TEI/@xml:id/string()
                                let $nameInstitution := $place/ancestor::tei:org/tei:orgName[1]
                                let $desc := $place/ancestor::tei:org/tei:desc[1]
                                let $places := if(count($place/ancestor::tei:org/tei:place/tei:placeName)>1)then(string-join($place/ancestor::tei:org/tei:place/tei:placeName, '/'))else()
                                let $name := <div
                                    class="row RegisterEntry">
                                    <div
                                        class="col-6">
                                        {$nameInstitution}<br/><span class="sublevel">{$desc}</span>
                                    </div>
                                    <div
                                        class="col-4">{$places}</div>
                                    <div
                                        class="col-2"><a onclick="pleaseWait()"
                                            href="institution/{$instID}">{$instID}</a></div>
                                </div>
                                    group by $place
                            (:        order by $place:)
                                return
                                    (<div
                                        name="{if($place ='') then('[N.N.]')else($place)}"
                                        count="{count($name)}">
                                        {
                                            for $each in $name
                                                let $order := local:replaceToSortDist($each)
                                                order by $order
                                            return
                                                $each
                                        }
                                    </div>)
    
    let $institutionsGroupedByPlaces := for $groups in $institutionsPlace
        group by $place := $groups/@name/string()
        order by $place
    return
        (<div
            class="RegisterSortBox"
            place="{$place}"
            count="{$institutionsPlace[@name = $place]/@count}"
            xmlns="http://www.w3.org/1999/xhtml">
            <div
                class="RegisterSortEntry"
                id="{
                        concat('list-item-', if ($place = '[N.N.]') then
                            ('unknown')
                        else
                            (translate($place,' ','_')))
                    }">
                {
                    if ($place = '') then
                        ('[N.N.]')
                    else
                        ($place)
                }
            </div>
            {
                for $group in $groups
                return
                    $group
            }
        </div>)
    
    return
        
        <div
            class="container"
            xmlns="http://www.w3.org/1999/xhtml">
            <div
                class="row">
                <div
                    class="col-9">
                    <p>Der Katalog verzeichnet derzeit {count($institutions)} Institutionen.</p>
                    <ul
                        class="nav nav-tabs"
                        id="myTab"
                        role="tablist">
                        <li
                            class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra active"
                                data-toggle="tab"
                                href="#alpha">Alphabetisch</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                data-toggle="tab"
                                href="#place" onclick="activateTab2()">Ort</a></li>
                        <!--<li
                            class="nav-item"><a
                                class="nav-link-jra disabled"
                                data-toggle="tab"
                                href="#established" onclick="activateTab3()">Gründungsjahr</a></li>-->
                    </ul>
                    <div
                        class="tab-content">
                        <div
                            class="tab-pane fade show active"
                            id="alpha">
                            <br/>
                            <div
                                class="row">
                                <div id="navigator" class="list-group col-3" style="height:500px; overflow-y: scroll;">
            					   <ul id="nav" class="nav hidden-xs hidden-sm">
                                    {
                                        for $each in $institutionsGroupedByInitials
                                        let $initial := if ($each/@initial/string() = '') then
                                            ('unknown')
                                        else
                                            ($each/@initial/string())
                                        let $count := $each/@count/string()
                                            order by $initial
                                        return
                                            <a
                                                class="nav-link list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', $initial)}"><span>{
                                                        if ($initial = 'unknown') then
                                                            ('[N.N.]')
                                                        else
                                                            ($initial)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                            </a>
                                    }
                                    </ul>
                                </div>
                                <div data-spy="scroll" data-target="#navigator" data-offset="90" class="col-md-9 col-sm-9" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$institutionsGroupedByInitials}
                                </div>
                            </div>
                        </div>
                        <div
                            class="tab-pane fade"
                            id="place">
                            <br/>
                            <div
                                class="row">
                                <div id="navigatorTab2" class="list-group col-3" style="height:500px; overflow-y: scroll;">
            					   <ul id="navTab2" class="nav hidden-xs hidden-sm">
                                    {
                                        for $each in $institutionsGroupedByPlaces
                                        let $place := if ($each/@place/string() = '[N.N.]') then
                                            ('unknown')
                                        else ($each/@place/string())
                                        let $count := $each/@count/string()
                                            order by $place
                                        return
                                            <a
                                                class="nav-link list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', translate($place,' ','_'))}"><span>{
                                                        if ($place = 'unknown') then
                                                            ('[N.N.]')
                                                        else
                                                            ($place)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                            </a>
                                    }
                                    </ul>
                                </div>
                                <div data-spy="scroll" data-target="#navigatorTab2" data-offset="90" class="col-md-9 col-sm-9" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$institutionsGroupedByPlaces}
                                </div>
                            </div>
                        </div>
                        <!--<div class="tab-pane fade" id="established">
                    no content
                </div>-->
                    </div>
                </div>
                <!--<div
                    class="col-3">
                    <br/><br/>
                    <h5>Filter​n <img src="../resources/fonts/feather/info.svg" width="23px" data-toggle="popover" title="Ansicht reduzieren." data-content="Geben Sie einen Namen oder eine ID ein. Der Filter zeigt nur Datensätze an, die Ihren Suchbegriff enthalten."/></h5>
                    <input
                        type="text"
                        id="myResearchInput"
                        onkeyup="myFilter()"
                        placeholder="Name oder ID"
                        title="Type in a string"/>
                </div>-->
            </div>
        </div>
};

declare function app:institution($node as node(), $model as map(*)) {
    
    let $id := request:get-parameter("institution-id", "Fehler")
    let $persons := collection("/db/contents/jra/persons")//tei:TEI
    let $institution := collection("/db/contents/jra/institutions")//tei:TEI[@xml:id = $id]
    let $name := $institution//tei:titleStmt/tei:title/normalize-space(data(.))
    let $letters := (collection('/db/contents/jra/sources/documents/letters')//tei:TEI,collection('/db/contents/jra/sources/documents/others')//tei:TEI)
    let $correspondence := $letters//tei:orgName[@key = $id]/ancestor::tei:TEI
    let $affiliates := $persons//tei:affiliation[@key = $id]/ancestor::tei:TEI
    let $literature := $institution//tei:bibl[@type='links']
    return
        (
        <div
            class="container">
            
            <div
                class="page-header">
                <h2>{$name}</h2>
                <h6>ID: {$id}</h6>
                <hr/>
                <ul
                            class="nav nav-pills"
                            role="tablist">
                            <li
                                class="nav-item">
                                <a
                                    class="nav-link-jra active"
                                    data-toggle="tab"
                                    href="#metadata">Allgemein</a></li>
                            {if (local:getCorrespondance($id)) then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#correspondence">Korrespondenz</a></li>)else()}
                            {if (local:getReferences($id)) then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#references">Bezüge</a></li>)else()}
                            {if ($literature/text()/normalize-space()!='') then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#literature">Literatur</a></li>)else()}
                            <li
                                class="nav-item"><a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#xmlAnsicht">XML-Ansicht</a></li>
                        </ul>
                <hr/>
            </div>
            <div
                class="container">
                <div
                    class="row">
                    <div
                        class="col">
                        <div
                            class="tab-content">
                            <div
                                class="tab-pane fade show active"
                                id="metadata">
                                <br/>
                                <div class="row">
                                <div class="col">
                                {transform:transform($institution, doc("/db/apps/raffArchive/resources/xslt/metadataInstitution.xsl"), ())}
                        </div>
                                <div
                            class="col-sm-3">
                            {if($institution//tei:revisionDesc/tei:change)
                                then(<div class="suggestedCitation">
                                <span class="heading" style="font-size: medium;">Änderungen:</span>
                                <br/>
                                {
                                for $change at $n in $institution//tei:revisionDesc/tei:change
                                    let $changeDate := concat(format-date(xs:date($change/@when), '[D]. [M,*-3]. [Y]', 'de', (), ()), ' ')
                                    let $changerName := $change/@who/string()
                                    let $changeInfo := $change/string()
                                    let $changeInfoButton := <img src="../../resources/fonts/feather/info.svg" width="18px" data-toggle="popover" data-original-title="{$changerName}" data-content="{$changeInfo}"/>
                                    return
                                        (<span style="padding-left: 3px;"/>,$changeDate, $changeInfoButton, <br/>)
                                }<br/>
                              </div>)
                            else()
                        }
                        <div class="suggestedCitation">
                            <span class="heading" style="font-size: medium;">Zitiervorschlag:</span>
                            <br/>
                            {concat($name,'; ')}<a href="{concat('http://localhost:8080/exist/apps/raffArchive/html/institution/',$id)}">{concat('http://localhost:8080/exist/apps/raffArchive/html/institution/',$id)}</a>, abgerufen am {format-date(current-date(), '[D]. [M,*-3]. [Y]', 'de', (), ())}
                         </div>
                        </div>
                        </div>
                        <!--
                        <br/>
                        <div>Zugehörige Personen:<br/>
                            <ul>
                                {for $affiliate in $affiliates
                                    let $affName := $affiliate//tei:titleStmt/tei:title/string()
                                    let $affId := $affiliate/@xml:id/string()
                                    return
                                        <li>{$affName} (<a href="person/{$affId}">{$affId}</a>)</li>
                                }
                            </ul>
                        </div>
                        -->
                            </div>
                            {
                                if (local:getCorrespondance($id)) then
                                    (<div
                                        class="tab-pane fade"
                                        id="correspondence">
                                        <br/>
                                        <div class="{if(count(local:getCorrespondance($id)) gt 5) then('pre-scrollable') else()}">{
                                            let $entrys := local:getCorrespondance($id)
                                            return
                                                $entrys
                                        }</div>
                                    </div>)
                                else
                                    ()
                            }
                            {
                                if (local:getReferences($id)) then
                                    (<div
                                        class="tab-pane fade"
                                        id="references">
                                        <br/>
                                        <div class="{if(count(local:getReferences($id)) gt 5) then('pre-scrollable') else()}">{
                                            let $entrys := local:getReferences($id)
                                            return
                                                $entrys
                                        }</div>
                                    </div>)
                                else
                                    ()
                            }
                            {
                                if ($literature/text()/normalize-space()!='') then
                                    (<div
                                        class="tab-pane fade"
                                        id="literature">
                                        {$literature}
                                    </div>)
                                else
                                    ()
                            }
                            <div
                                class="tab-pane fade"
                                id="xmlAnsicht">
                                <pre
                                    class="pre-scrollable">
                                    <xmp>
                                        {transform:transform($institution, doc("/db/apps/raffArchive/resources/xslt/viewXML.xsl"), ())}
                                    </xmp>
                                </pre>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        )
};


declare function app:registryWorks($node as node(), $model as map(*)) {
    
    let $works := collection('/db/contents/jra/works')//mei:mei
    let $worksOpus := $works//mei:workList//mei:title[@type = 'desc' and contains(., 'Opus')]/ancestor::mei:mei
    let $worksWoO := $works//mei:workList//mei:title[@type = 'desc' and contains(., 'WoO')]/ancestor::mei:mei
    let $perfRess := $works//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[not(@type = 'alt')]
    
    let $worksAlpha := for $work in $works
                            let $workName := $work//mei:workList//mei:title[@type = 'uniform']/normalize-space(text())
                            let $opus := $work//mei:workList//mei:title[@type = 'desc']/normalize-space(text())
                            let $withoutArticle := replace(replace(replace(replace(replace(replace($workName,'Der ',''),'Den ',''), 'Die ',''), 'La ',''), 'Le ',''), 'L’','')
                            let $initial := for $case in upper-case(substring($withoutArticle, 1, 1))
                                                return switch ($case)
                                                case 'É' return 'E'
                                                case '0' return '0–9'
                                                case '1' return '0–9'
                                                case '2' return '0–9'
                                                case '3' return '0–9'
                                                case '4' return '0–9'
                                                case '5' return '0–9'
                                                case '6' return '0–9'
                                                case '7' return '0–9'
                                                case '8' return '0–9'
                                                case '9' return '0-9'
                                                default return $case 
                            let $workID := $work/@xml:id/string()
                            let $name := <div
                                            class="row RegisterEntry" titleToSort="{$withoutArticle}">
                                            <div
                                                class="col">{$workName}</div>
                                            <div
                                                class="col-2">{$opus}</div>
                                            <div
                                                class="col-2"><a onclick="pleaseWait()"
                                                    href="work/{$workID}">{$workID}</a></div>
                                        </div>
                                            group by $initial
                                            order by $initial
                                            return
                                                (<div
                                                    name="{$initial}"
                                                    count="{count($name)}">
                                                    {
                                                        for $each in $name
                                                            let $orderWithoutArticle := $each/@titleToSort
                                                            let $order := local:replaceToSortDist($orderWithoutArticle)
                                                            order by $order
                                                            return
                                                                $each
                                                    }
                                                </div>)
    
    let $worksGroupedByInitials := for $groups in $worksAlpha
                                        let $initial := $groups/@name/string()
                                        return
                                            (<div
                                                class="RegisterSortBox"
                                                initial="{$initial}"
                                                count="{$worksAlpha[@name = $initial]/@count}"
                                                xmlns="http://www.w3.org/1999/xhtml">
                                                <div
                                                    class="RegisterSortEntry"
                                                    id="{
                                                            concat('list-item-', if ($initial = '') then
                                                                ('unknown')
                                                            else
                                                                ($initial))
                                                        }">
                                                    {
                                                        if ($initial = '') then
                                                            ('[N.N.]')
                                                        else
                                                            ($initial)
                                                    }
                                                </div>
                                                {
                                                 for $group in $groups
                                                 return
                                                     $group
                                                }
                                            </div>)
    let $worksChrono := for $work in $works
                            let $workName := $work//mei:workList//mei:title[@type = 'uniform']/normalize-space(text())
                            let $opus := $work//mei:workList//mei:title[@type = 'desc']/normalize-space(text())
                            let $withoutArticle := replace(replace(replace(replace(replace(replace($workName,'Der ',''),'Den ',''), 'Die ',''), 'La ',''), 'Le ',''), 'L’','')
                            let $date := $work//mei:creation/mei:date[@type = 'composition']
                            let $compositionDate := if (count($date) = 1)
                                                    then
                                                        (
                                                        if ($date/@startdate)
                                                        then
                                                            ($date/@startdate/string())
                                                        else
                                                            if ($date/@notbefore)
                                                            then
                                                                ($date/@notbefore/string())
                                                            else
                                                                ('0000')
                                                        )
                                                    else
                                                        if ($date)
                                                        then
                                                            (
                                                            if ($date[1]/@startdate)
                                                            then
                                                                ($date[1]/@startdate/string())
                                                            else
                                                                if ($date[1]/@notbefore)
                                                                then
                                                                    ($date[1]/@notbefore/string())
                                                                else
                                                                    ('0000')
                                                            )
                                                        else
                                                            ('0000')
                            let $year := substring($compositionDate, 1, 4)
                            let $workID := $work/@xml:id/string()
                            let $name := <div
                                class="row RegisterEntry" titleToSort="{$withoutArticle}">
                                <!--<div class="col-2">{format-date(xs:date(replace($compositionDate,'00','01')),'[M,*-3]. [D]','de',(),())}</div>-->
                                <div
                                    class="col">{$workName}</div>
                                <div
                                    class="col-2">{$opus}</div>
                                <div
                                    class="col-2"><a onclick="pleaseWait()"
                                        href="work/{$workID}">{$workID}</a></div>
                            </div>
                                group by $year
                                order by $year
                            return
                                (<div
                                    name="{$year}"
                                    count="{count($name)}">
                                    {
                                        for $each in $name
                                            let $orderWithoutArticle := $each/@titleToSort
                                            let $order := local:replaceToSortDist($orderWithoutArticle)
                                            order by $order
                                            return
                                                $each
                                    }
                                </div>)
    
    let $worksGroupedByYears := for $groups in $worksChrono
    let $year := $groups/@name/string()
    return
        (<div
            class="RegisterSortBox"
            year="{$year}"
            count="{$worksChrono[@name = $year]/@count}"
            xmlns="http://www.w3.org/1999/xhtml">
            <div
                class="RegisterSortEntry"
                id="{
                        concat('list-item-', if ($year = '0000') then
                            ('unknown')
                        else
                            ($year))
                    }">
                {
                    if ($year = '0000') then
                        ('[N.N.]')
                    else
                        ($year)
                }
            </div>
            {
                for $group in $groups
                return
                    $group
            }
        </div>)
   
    let $content := <div
        class="container">
        <br/>
        <ul
            class="nav nav-tabs"
            role="tablist">
            <li
                class="nav-item nav-linkless-jra">Sortierungen:</li>
            <li
                class="nav-item"><a
                    class="nav-link-jra active"
                    data-toggle="tab"
                    href="#sortWork">Werk</a></li>
            <li
                class="nav-item"><a
                    class="nav-link-jra"
                    data-toggle="tab"
                    href="#sortTitle" onclick="activateTab2()">Titel</a></li>
            <li
                class="nav-item"><a
                    class="nav-link-jra"
                    data-toggle="tab"
                    href="#sortDate" onclick="activateTab3()">Entstehung</a></li>
            <li
                class="nav-item"><a
                    class="nav-link-jra"
                    data-toggle="tab"
                    href="#sortGenre">Kategorien</a></li>
        </ul>
        <div
            class="tab-content">
            <div
                class="tab-pane fade show active"
                id="sortWork">
                <br/>
                <div
                    class="row">
                    <div data-spy="scroll" data-target="#navigator" data-offset="90" class="col" style="position: relative; height:500px; overflow-y: scroll;">
                        <div
                            class="RegisterSortBox">
                            <div
                                class="RegisterSortEntry"
                                id="opera">Werke mit Opuszahl</div>
                            {
                                for $work in $worksOpus
                                let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type = 'uniform' and @xml:lang = 'de']/normalize-space(text())
                                let $opus := $work//mei:workList//mei:title[@type = 'desc']/normalize-space(text())
                                let $workID := $work/@xml:id/normalize-space(data(.))
                                    order by $opus ascending
                                return
                                    <div
                                        class="row RegisterEntry">
                                        <div
                                            class="col-2">{$opus}</div>
                                        <div
                                            class="col">{$name}</div>
                                        <div
                                            class="col-2"><a
                                                href="work/{$workID}">{$workID}</a></div>
                                    </div>
                            }
                            <div
                                class="RegisterSortEntry"
                                id="woos">Werke ohne Opuszahl</div>
                            {
                                for $work in $worksWoO
                                let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type = 'uniform' and @xml:lang = 'de']/normalize-space(text())
                                let $opus := $work//mei:workList//mei:title[@type = 'desc']/normalize-space(text())
                                let $workID := $work/@xml:id/normalize-space(data(.))
                                    order by $opus ascending
                                return
                                    <div
                                        class="row RegisterEntry">
                                        <div
                                            class="col-2">{$opus}</div>
                                        <div
                                            class="col">{$name}</div>
                                        <div
                                            class="col-2"><a
                                                href="work/{$workID}">{$workID}</a></div>
                                    </div>
                            }
                        </div>
                    </div>
                    <div id="navigator" class=" col-2" style="align-content:right;">
            			<ul id="nav" class="nav hidden-xs hidden-sm"> <!-- position: relative; style="height: 500px; overflow-y: scroll; width: 200px;" -->
                            <a
                                class="nav-link list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="#opera"
                                ><span>Opera</span></a>
                            <a
                                class="nav-link list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="#woos"
                                ><span>WoOs</span></a>
                        </ul>
                    </div>
                </div>
            </div>
            <div
                class="tab-pane fade"
                id="sortTitle">
                <br/>
                <div
                    class="row">
                    <div id="navigatorTab2" class="list-group col-3" style="height:500px; overflow-y: scroll;">
            					   <ul id="navTab2" class="nav hidden-xs hidden-sm">
                        {
                            for $each in $worksGroupedByInitials
                            let $initial := $each/@initial/string()
                            let $count := $each/@count/string()
                                order by $initial
                            return
                                <a
                                    class="nav-link list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                    href="{concat('#list-item-', $initial)}"><span>{
                                            if ($initial = 'unknown') then
                                                ('[N.N.]')
                                            else
                                                ($initial)
                                        }</span>
                                    <span
                                        class="badge badge-jra badge-pill right">{$count}</span>
                                </a>
                        }
                        </ul>
                    </div>
                    <div data-spy="scroll" data-target="#navigatorTab2" data-offset="90" class="col-md-9 col-sm-9" style="position: relative; height:500px; overflow-y: scroll;">
                        {$worksGroupedByInitials}
                    </div>
                </div>
            </div>
            <div
                class="tab-pane fade"
                id="sortDate">
                <br/>
                <div
                    class="row">
                    <div id="navigatorTab3" class="list-group col-3" style="height:500px; overflow-y: scroll;">
            					   <ul id="navTab3" class="nav hidden-xs hidden-sm">
                        {
                            for $each in $worksGroupedByYears
                            let $year := $each/@year/string()
                            let $count := $each/@count/string()
                                order by $year
                            return
                                <a
                                    class="nav-link list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                    href="{concat('#list-item-', $year)}"><span>{
                                            if ($year = '0000') then
                                                ('[N.N.]')
                                            else
                                                ($year)
                                        }</span>
                                    <span
                                        class="badge badge-jra badge-pill right">{$count}</span>
                                </a>
                        }
                        </ul>
                    </div>
                    <div data-spy="scroll" data-target="#navigatorTab3" data-offset="90" class="col-md-9 col-sm-9" style="position: relative; height:500px; overflow-y: scroll;">
                        {$worksGroupedByYears}
                    </div>
                </div>
            </div>
            <div
                class="tab-pane fade"
                id="sortGenre">
                <ul
                class="nav nav-pills col-11 d-flex justify-content-between subNav"
                role="tablist">
                    <li class="nav-item nav-linkless-jra"><span> </span></li>
                    <li
                        class="nav-item"><a
                            class="nav-link-jra active"
                            data-toggle="tab"
                            href="#vocalMusic">Vokalwerke</a></li>
                    <li
                     class="nav-item"><a
                         class="nav-link-jra"
                         data-toggle="tab"
                         href="#stageMusic">Bühnenwerke</a></li>
                    <li
                     class="nav-item"><a
                         class="nav-link-jra"
                         data-toggle="tab"
                         href="#orchestralMusic">Orchesterwerke</a></li>
                         <li
                     class="nav-item"><a
                         class="nav-link-jra"
                         data-toggle="tab"
                         href="#chamberMusic">Kammermusik</a></li>
                         <li
                     class="nav-item"><a
                         class="nav-link-jra"
                         data-toggle="tab"
                         href="#pianoMusic">Klavierwerke</a></li>
                         <li
                     class="nav-item"><a
                         class="nav-link-jra"
                         data-toggle="tab"
                         href="#arrangements">Bearbeitungen</a></li>
                         <li class="nav-item nav-linkless-jra d-flex justify-content-between"></li>
                </ul>
                <div class="tab-content">
                    <div
                        class="tab-pane fade show active"
                        id="vocalMusic">
                        <br/>
                            <div
                                class="row">
                                <div id="navigatorVocalMusic" class="list-group col-11" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-01-01">Chorwerke mit Orchester geistlich</div>
                                            {let $works := 'cat-01-01'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-01-01-01">Oratorien</div>
                                            {let $works := 'cat-01-01-01'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-01-01-02">Liturgische Werke</div>
                                            {let $works := 'cat-01-01-02'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-01-01-03">Andere Chorwerke</div>
                                            {let $works := 'cat-01-01-03'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-01-02">Chorwerke mit Orchester weltlich</div>
                                            {let $works := 'cat-01-02'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                          class="RegisterSortEntry"
                                          id="cat-01-03">Chorwerke mit Klavier</div>
                                          {let $works := 'cat-01-03'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                           class="RegisterSortEntry"
                                           id="cat-01-04">Chorwerke a cappella geistlich</div>
                                           {let $works := 'cat-01-04'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                           class="RegisterSortEntry"
                                           id="cat-01-05">Chorwerke a cappella weltlich</div>
                                           {let $works := 'cat-01-05'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-01-06">Ensembles mit Klavier</div>
                                            {let $works := 'cat-01-06'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-01-07">Lieder mit Orchester</div>
                                               {let $works := 'cat-01-07'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work 
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-01-08">Lieder mit Klavier</div>
                                            {let $works := 'cat-01-08'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        
                                    </div>
                                </div>
                        </div>
                    </div>
                    <div
                        class="tab-pane fade"
                        id="stageMusic">
                        <br/>
                            <div
                                class="row">
                                <div id="navigatorStageMusic" class="list-group col-11" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-02-01">Opern</div>
                                            {let $works := 'cat-02-01'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-02-02">Schauspielmusiken</div>
                                            {let $works := 'cat-02-02'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        </div>
                                   </div>
                            </div>
                    </div>
                    <div
                        class="tab-pane fade"
                        id="orchestralMusic">
                        <br/>
                        <div
                            class="row">
                              <div id="navigatorOrchestralMusic" class="list-group col-11" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-03-01">Symphonien</div>
                                            {let $works := 'cat-03-01'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-03-02">Suiten</div>
                                            {let $works := 'cat-03-02'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                       <div
                                            class="RegisterSortEntry"
                                            id="cat-03-03">Konzertante Werke</div>
                                            {let $works := 'cat-03-03'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                      <div
                                            class="RegisterSortEntry"
                                            id="cat-03-04">Ouvertüren und Vorspiele</div>
                                            {let $works := 'cat-03-04'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                     <div
                                            class="RegisterSortEntry"
                                            id="cat-03-05">Andere Orchesterwerke</div>
                                            {let $works := 'cat-03-05'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        </div>
                                   </div>
                        </div>
                    </div>
                    <div
                        class="tab-pane fade"
                        id="chamberMusic">
                        <br/>
                        <div
                            class="row">
                            <div id="navigatorChamberMusic" class="list-group col-11" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-04-01">Kammermusik ohne Klavier</div>
                                            {let $works := 'cat-04-01'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-01-01">Sinfonietta</div>
                                            {let $works := 'cat-04-01-01'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-01-02">Oktett</div>
                                            {let $works := 'cat-04-01-02'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-01-03">Sextett</div>
                                            {let $works := 'cat-04-01-03'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-01-04">Streichquartette</div>
                                            {let $works := 'cat-04-01-04'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                       <div
                                            class="RegisterSortEntry"
                                            id="cat-04-02">Kammermusik mit Klavier</div>
                                            {let $works := 'cat-04-02'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-02-01">Klavierquintette</div>
                                            {let $works := 'cat-04-02-01'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-02-02">Klavierquartette</div>
                                            {let $works := 'cat-04-02-02'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-02-03">Klaviertrios</div>
                                            {let $works := 'cat-04-02-03'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-02-04">Bläser und Klavier</div>
                                            {let $works := 'cat-04-02-04'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-04-03">Violine und Klavier</div>
                                            {let $works := 'cat-04-03'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-03-01">Sonaten</div>
                                            {let $works := 'cat-04-03-01'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-03-02">Andere Werke für Violine und Klavier</div>
                                            {let $works := 'cat-04-03-02'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-04-04">Cello und Klavier</div>
                                            {let $works := 'cat-04-04'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        </div>
                                   </div>
                        </div>
                    </div>
                    <div
                        class="tab-pane fade"
                        id="pianoMusic">
                        <br/>
                        <div
                            class="row">
                              <div id="navigatorPianoMusic" class="list-group col-11" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-05-01">Klavier zweihändig</div>
                                            {let $works := 'cat-05-01'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-05-01-01">Sonaten</div>
                                            {let $works := 'cat-05-01-01'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-05-01-02">Suiten</div>
                                            {let $works := 'cat-05-01-02'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-05-01-03">Weitere Stücke für Klavier zu zwei Händen</div>
                                            {let $works := 'cat-05-01-03'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-05-01-04">Fantasien und Variationen über fremde Themen</div>
                                            {let $works := 'cat-05-01-04'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat} 
                                       <div
                                            class="RegisterSortEntry2"
                                            id="cat-05-01-05">Klavierauszüge</div>
                                            {let $works := 'cat-05-01-05'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-05-02">Klavier vierhändig</div>
                                            {let $works := 'cat-05-02'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-05-03">Zwei Klaviere</div>
                                            {let $works := 'cat-05-03'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-05-04">Orgel</div>
                                            {let $works := 'cat-05-04'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        </div>
                                   </div>
                        </div>
                    </div>
                    <div
                        class="tab-pane fade"
                        id="arrangements">
                        <br/>
                        <div
                            class="row">
                            <div id="navigatorArrangements" class="list-group col-11" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-06-01">Für Orchester</div>
                                            {let $works := 'cat-06-01'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-06-02">Für Kammermusik</div>
                                            {let $works := 'cat-06-02'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-06-03">Für Klavier</div>
                                            {let $works := 'cat-06-03'
                                                for $work in local:getWorks($works)
                                                let $worksByCat := $work
                                                order by local:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                   </div>
                               </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    return
        $content
};

declare function app:work($node as node(), $model as map(*)) {
    
    let $id := request:get-parameter("work-id", "Fehler")
    let $work := collection("/db/contents/jra/works")//mei:mei[@xml:id = $id]
    let $collection := collection("/db/contents/jra")//tei:TEI
    let $naming := $collection//tei:title[@key=$id]/ancestor::tei:TEI
    let $opus := $work//mei:workList//mei:title[@type = 'desc']/normalize-space(text())
    let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type = 'uniform' and @xml:lang = 'de']/normalize-space(text())
    
    return
        (
            <div
            class="container">
            <div
                class="page-header">
                <h2>{$name}</h2>
                <h5>{$opus}</h5>
                <hr/>
                <ul
                            class="nav nav-pills"
                            role="tablist">
                            <li
                                class="nav-item">
                                <a
                                    class="nav-link-jra active"
                                    data-toggle="tab"
                                    href="#metadata">Allgemein</a></li>
                            {if (local:getReferences($id)) then(
                            <li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#references">Bezüge</a></li>
                                    )else()}
                                    <li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#viewXML">XML-Ansicht</a></li>
                        </ul>
            
                <hr/>
            </div>
            <div
                class="container">
                <div
                    class="row">
                    <div
                        class="col">
                        <div
                            class="tab-content">
                            <div
                                class="tab-pane fade show active"
                                id="metadata">
                                <br/>
                                <div
                        class="row">
                        <div
                            class="col">
                {transform:transform($work, doc("/db/apps/raffArchive/resources/xslt/metadataWork.xsl"), ())}
                                </div>
                                
                        <div
                            class="col-sm-3">
                            {if($work//mei:revisionDesc/mei:change)
                                then(<div class="suggestedCitation">
                                <span class="heading" style="font-size: medium;">Änderungen:</span>
                                <br/>
                                {
                                for $change at $n in $work//mei:revisionDesc/mei:change
                                    let $changeDate := concat(format-date(xs:date($change/@isodate), '[D]. [M,*-3]. [Y]', 'de', (), ()), ' ')
                                    let $changerName := $change/@resp/string()
                                    let $changeInfo := $change/mei:changeDesc/mei:p/string()
                                    let $changeInfoButton := <img src="../../resources/fonts/feather/info.svg" width="18px" data-toggle="popover" data-original-title="{$changerName}" data-content="{$changeInfo}"/>
                                    return
                                        ($changeDate, $changeInfoButton, <br/>)
                                }<br/>
                              </div>)
                            else()
                        }
                        <div class="suggestedCitation">
                            <span class="heading" style="font-size: medium;">Zitiervorschlag:</span>
                            <br/>
                            {concat($name,', ',$opus,'; ')}<a href="{concat('http://localhost:8080/exist/apps/raffArchive/html/work/',$id)}">{concat('http://localhost:8080/exist/apps/raffArchive/html/work/',$id)}</a>, abgerufen am {format-date(current-date(), '[D]. [M,*-3]. [Y]', 'de', (), ())}
                         </div>
                        </div>
                        </div>
                            </div>
                            {
                                if (local:getReferences($id))
                                then (<div
                                        class="tab-pane fade"
                                        id="references">
                                        <br/>
                                        <div class="{if(count(local:getReferences($id)) gt 5) then('pre-scrollable') else()}">{
                                            let $entrys := local:getReferences($id)
                                            return
                                                $entrys
                                        }</div>
                                      </div>
                                )
                                else
                                    ()
                            }
                            <div
                    class="tab-pane fade"
                    id="viewXML">
                    <pre
                                    class="pre-scrollable">
                                    <xmp>
                    {transform:transform($work, doc("/db/apps/raffArchive/resources/xslt/viewXML.xsl"), ())}
                    </xmp>
                    </pre>
                </div>
        </div>
        </div>
        </div>
        </div>
        </div>
        )
};

declare function app:aboutProject($node as node(), $model as map(*)) {
    
    let $text := doc("/db/contents/jra/texts/portal/aboutProject.xml")/tei:TEI
    let $title := $text//tei:titleStmt/tei:title/string()
    let $subtitle := $text//tei:sourceDesc/tei:p[1]
    
    return
        (
        <div
            class="container">
            <div
                class="page-header">
                <h2>{$title}</h2>
                <h5 class="sublevel">{$subtitle}</h5>
                <hr/>
            </div>
            <div
                class="container">
                <div
                    class="row">
                    <div
                        class="col">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        </div>
        </div>
        </div>
        )
};

declare function app:aboutRaff($node as node(), $model as map(*)) {
    
    let $text := doc("/db/contents/jra/texts/portal/aboutRaff.xml")/tei:TEI
    let $title := $text//tei:titleStmt/tei:title/string()
    let $subtitle := $text//tei:sourceDesc/tei:p[1]
    
    return
        (
        <p class="title-b">{$title}</p>,
        <p class="subtitle-b">{$subtitle}</p>,
        <div>
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        )
};

declare function app:aboutDocumentation($node as node(), $model as map(*)) {
    
    let $text := doc("/db/contents/jra/texts/portal/aboutDocumentation.xml")/tei:TEI
    let $title := $text//tei:titleStmt/tei:title/string()
    let $subtitle := $text//tei:sourceDesc/tei:p[1]
    
    return
        (
        <div
            class="container">
            <div
                class="page-header">
                <h2>{$title}</h2>
                <h5 class="sublevel">{$subtitle}</h5>
                <hr/>
            </div>
            <div
                class="container">
                <div
                    class="row">
                    <div
                        class="col">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        </div>
        </div>
        </div>
        )
};

declare function app:aboutResources($node as node(), $model as map(*)) {
    
    let $text := doc("/db/contents/jra/texts/portal/aboutResources.xml")/tei:TEI
    let $title := $text//tei:titleStmt/tei:title/string()
    let $subtitle := $text//tei:sourceDesc/tei:p[1]
    
    return
        (
         <div
            class="container">
            <div
                class="page-header">
                <h2>{$title}</h2>
                <h5 class="sublevel">{$subtitle}</h5>
                <hr/>
            </div>
            <div
                class="container">
                <div
                    class="row">
                    <div
                        class="col">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        </div>
        </div>
        </div>
        )
};

declare function app:indexPage($node as node(), $model as map(*)) {
    
    let $text := doc('/db/contents/jra/texts/portal/index.xml')
    
    return
        (
        <div
            class="container">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        )
};

declare function app:impressum($node as node(), $model as map(*)) {
    
    let $text := doc("/db/contents/jra/texts/portal/impressum.xml")/tei:TEI
    
    return
        (
        <div class="title-b">Kontakt</div>,
        <div>
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        )
};

declare function app:privacyPolicy($node as node(), $model as map(*)) {
    
    let $text := doc("/db/contents/jra/texts/portal/privacyPolicy.xml")/tei:TEI
    
    return
        (
        <div
            class="container">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        )
};

declare function app:disclaimer($node as node(), $model as map(*)) {
    
    let $text := doc("/db/contents/jra/texts/portal/disclaimer.xml")/tei:TEI
    
    return
        (
        <div
            class="container">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        )
};

declare function app:errorReport($node as node(), $model as map(*)){

let $mailto := 'mailto:ried-musikforschung@mail.de'
let $subject := 'Error%20Report'
let $occurance := replace(request:get-url(),'http://localhost:8080/exist/apps/raffArchive','http://portal.raff-archiv.ch')
let $body := concat('Hey Guys,%0D%0A%0D%0Aplease%20check%20this%20url:%0D%0A%0D%0A',$occurance,'%0D%0A%0D%0Athanks!')
let $href := concat($mailto,'?subject=',$subject,'&amp;body=',$body)
return
    <button class="btn list-item-jra"><a href="{$href}">report</a></button>
};

declare function app:countLetters($node as node(), $model as map(*)){
let $letters := collection("/db/contents/jra/sources/documents/letters") | collection("/db/contents/jra/sources/documents/others")
let $count := count($letters//tei:TEI)
return
    (<p class="counter">{$count}</p>,
    <span class="counter-text">Postsachen</span>)
};
declare function app:countWorks($node as node(), $model as map(*)){
let $works := collection("/db/contents/jra/works")
let $count := count($works//mei:mei)
return
    (<p class="counter">{$count}</p>,
    <span class="counter-text">Werke</span>)
};
declare function app:countPersons($node as node(), $model as map(*)){
let $persons := collection("/db/contents/jra/persons")
let $count := count($persons//tei:TEI)
return
    (<p class="counter">{$count}</p>,
    <span class="counter-text">Personen</span>)
};
declare function app:countInstitutions($node as node(), $model as map(*)){
let $institutions := collection("/db/contents/jra/institutions")
let $count := count($institutions//tei:TEI)
return
    (<p class="counter">{$count}</p>,
    <span class="counter-text">Institutionen</span>)
};
xquery version "3.0";

module namespace app="http://localhost:8080/exist/apps/raffArchive/templates";
import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://localhost:8080/exist/apps/raffArchive/config" at "config.xqm";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace functx = "http://www.functx.com";
declare namespace http = "http://expath.org/ns/http-client";
(:declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";:)

declare function functx:is-node-in-sequence-deep-equal
  ( $node as node()? ,
    $seq as node()* )  as xs:boolean {

   some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
 };
 
declare function functx:distinct-deep
  ( $nodes as node()* )  as node()* {

    for $seq in (1 to count($nodes))
    return $nodes[$seq][not(functx:is-node-in-sequence-deep-equal(.,$nodes[position() < $seq]))]
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
<ul id="myResults">
{
for $search at $n in $collection//tei:surname
    where $search[contains(., 'Raff')]
    let $result := $search/parent::node()/string()
    let $resultID := $search/ancestor::tei:TEI/@xml:id
    order by $result
    return
        <li>{$result} (<a href="person/{$resultID}">{$resultID/string()}</a>)</li>
}</ul></div>
};

declare function app:registryLetters($node as node(), $model as map(*)) {

    let $letters := collection("/db/contents/jra/sources/documents/letters")//tei:TEI
    let $persons := collection('/db/contents/jra/persons')//tei:TEI
    let $lettersGroupedByYears :=
        for $letter in $letters
            let $letterID := $letter/@xml:id/data(.)
            
            let $correspActionSent := $letter//tei:correspAction[@type="sent"]
            let $correspActionReceived := $letter//tei:correspAction[@type="received"]
            let $correspSent := if($correspActionSent/tei:persName/text() or $correspActionSent/tei:orgName/text()) then($correspActionSent/tei:persName/text() | $correspActionSent/tei:orgName/text()) else('[Unbekannt]')
            let $correspReceived := if($correspActionReceived/tei:persName/text() or $correspActionReceived/tei:orgName/text()) then($correspActionReceived/tei:persName/text() | $correspActionReceived/tei:orgName/text()) else('[Unbekannt]')
            
            let $date := if($correspActionSent/tei:date[@type='editor']/@when)
                then($correspActionSent/tei:date[@type='editor' and 1]/@when/string())
                else if($correspActionSent/tei:date[@type='editor' and 1]/@from)
                then($correspActionSent/tei:date[@type='editor' and 1]/@from/string()) (: größte confidence ansonsten das Erste :)
                else if($correspActionSent/tei:date[@type='editor']/@notBefore)
                then($correspActionSent/tei:date[@type='editor' and 1]/@notBefore/string())
                else if($correspActionSent/tei:date[@type='editor']/@when-custom)
                then($correspActionSent/tei:date[@type='editor' and 1]/@when-custom/string())
                else if($correspActionSent/tei:date[@type='editor']/@from-custom)
                then($correspActionSent/tei:date[@type='editor' and 1]/@from-custom/string())
                else if($correspActionSent/tei:date[@type='source']/@when)
                then($correspActionSent/tei:date[@type='source' and 1]/@when/string())
                else if($correspActionSent/tei:date[@type='source']/@when-custom)
                then($correspActionSent/tei:date[@type='source' and 1]/@when-custom/string())
                else if($correspActionSent/tei:date[@type='source']/@from)
                then($correspActionSent/tei:date[@type='source' and 1]/@from/string())
                else if($correspActionSent/tei:date[@type='source']/@from-custom)
                then($correspActionSent/tei:date[@type='source' and 1]/@from-custom/string())
                else('0000')
            let $dateSecured := if(number(substring($date,1,4)) < number(substring(string(current-date()),1,4))-70)then($date)else()
            let $letterSmall := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml" dateToOrder='{$dateSecured}'>
            <div data-toggle="tooltip" data-placement="top" title="ID: {$letterID}" valign="top" class="col-md-3 col-sm-3 col-xs-3"><a href="letter/{$letterID}">{if(string-length($dateSecured)=10 and not(contains($date,'00')))then(format-date(xs:date($dateSecured),'[D]. [M,*-3]. [Y]','de',(),()))else($dateSecured)}</a></div>
            <div class="col">{$correspSent}<br/>an {$correspReceived}</div>
            </div>
    
        group by $year := if(not($dateSecured) or contains(substring($dateSecured,1,4),'0000'))
                              then('noYear')
                              else
                              if(not(contains(substring($dateSecured,1,4),'-')))then(substring($dateSecured,1,4))else($dateSecured)
        order by $year
        return
            (
            <div class="RegisterSortBox" year="{$year}" letterCount="{count($letterSmall)}" xmlns="http://www.w3.org/1999/xhtml">
                <div class="RegisterSortEntry" id="{concat('list-item-',$year)}">{if($year='noYear')then('ohne Jahr')else($year)}</div>
                {for $each in $letterSmall
                    let $order := $each/@dateToOrder
                    order by $order
                    return $each}
            </div>)
            
    let $lettersGroupedByRecipient :=
        for $letter in $letters
            let $letterID := $letter/@xml:id/data(.)
            
            let $correspActionSent := $letter//tei:correspAction[@type="sent"]
            let $correspActionReceived := $letter//tei:correspAction[@type="received"]
            let $correspSent := if($correspActionSent/tei:orgName/text()) then($correspActionSent/tei:orgName[1]/text()[1]) else if($correspActionSent/tei:persName/text()) then($correspActionSent/tei:persName[1]/text()[1]) else('[Unbekannt]')
            let $correspReceived := if($correspActionReceived/tei:orgName/text()) then($correspActionReceived/tei:orgName[1]/text()[1]) else if($correspActionReceived/tei:persName[1]/text()[1]) then($correspActionReceived/tei:persName[1]/text()[1]) else('[Unbekannt]')
            let $correspReceivedId := if($correspActionReceived/tei:orgName/@key) then($correspActionReceived/tei:orgName[1]/@key/data(.)) else if($correspActionReceived/tei:persName[1]/@key) then($correspActionReceived/tei:persName[1]/@key/data(.)) else('[Unbekannt]')
            let $date := if($correspActionSent/tei:date[@type='editor']/@when)
                then($correspActionSent/tei:date[@type='editor' and 1]/@when/string())
                else if($correspActionSent/tei:date[@type='editor' and 1]/@from)
                then($correspActionSent/tei:date[@type='editor' and 1]/@from/string()) (: größte confidence ansonsten das Erste :)
                else if($correspActionSent/tei:date[@type='editor']/@notBefore)
                then($correspActionSent/tei:date[@type='editor' and 1]/@notBefore/string())
                else if($correspActionSent/tei:date[@type='editor']/@when-custom)
                then($correspActionSent/tei:date[@type='editor' and 1]/@when-custom/string())
                else if($correspActionSent/tei:date[@type='editor']/@from-custom)
                then($correspActionSent/tei:date[@type='editor' and 1]/@from-custom/string())
                else if($correspActionSent/tei:date[@type='source']/@when)
                then($correspActionSent/tei:date[@type='source' and 1]/@when/string())
                else if($correspActionSent/tei:date[@type='source']/@when-custom)
                then($correspActionSent/tei:date[@type='source' and 1]/@when-custom/string())
                else if($correspActionSent/tei:date[@type='source']/@from)
                then($correspActionSent/tei:date[@type='source' and 1]/@from/string())
                else if($correspActionSent/tei:date[@type='source']/@from-custom)
                then($correspActionSent/tei:date[@type='source' and 1]/@from-custom/string())
                else('0000')
            let $dateSecured := if(number(substring($date,1,4)) < number(substring(string(current-date()),1,4))-70)then($date)else()
            let $letterSmall := <tr class="RegisterEntry" xmlns="http://www.w3.org/1999/xhtml" dateToOrder='{$dateSecured}'><td data-toggle="tooltip" data-placement="top" title="ID: {$letterID}" valign="top" width="18%"><a href="letter/{$letterID}">{if(string-length($dateSecured)=10 and not(contains($date,'00')))then(format-date(xs:date($dateSecured),'[D]. [M,*-3]. [Y]','de',(),()))else($dateSecured)}</a></td><td width="82%">{$correspSent}<br/>an {$correspReceived}</td></tr>
    
        group by $correspReceivedId
        order by distinct-values($persons[@xml:id=$correspReceivedId]//tei:titleStmt/tei:title/string())
        return
            (let $correspReceivedLabel := distinct-values($persons[@xml:id=$correspReceivedId]//tei:titleStmt/tei:title/string())
            return
            <div class="RegisterSortBox" recipient="{$correspReceivedLabel}" recipientId="{$correspReceivedId}" letterCount="{count($letterSmall)}" xmlns="http://www.w3.org/1999/xhtml">
                <h5 class="RegisterSortEntry" id="{$correspReceivedId}">{$correspReceivedLabel}</h5>
                <table width="100%">
                {for $each in $letterSmall
                    let $order := $each/@dateToOrder
                    order by $order
                    return $each}
                    </table>
            </div>)

    let $lettersGroupedBySender :=
        for $letter in $letters
            let $letterID := $letter/@xml:id/data(.)
            
            let $correspActionSent := $letter//tei:correspAction[@type="sent"]
            let $correspActionReceived := $letter//tei:correspAction[@type="received"]
            let $correspSent := if($correspActionSent/tei:orgName/text()) then($correspActionSent/tei:orgName[1]/text()[1]) else if($correspActionSent/tei:persName/text()) then($correspActionSent/tei:persName[1]/text()[1]) else('[Unbekannt]')
            let $correspSentId := if($correspActionSent/tei:orgName/@key) then($correspActionSent/tei:orgName[1]/@key/data(.)) else if($correspActionSent/tei:persName[1]/@key) then($correspActionSent/tei:persName[1]/@key/data(.)) else('[Unbekannt]')
            let $correspReceived := if($correspActionReceived/tei:orgName/text()) then($correspActionReceived/tei:orgName[1]/text()[1]) else if($correspActionReceived/tei:persName[1]/text()[1]) then($correspActionReceived/tei:persName[1]/text()[1]) else('[Unbekannt]')
            let $date := if($correspActionSent/tei:date[@type='editor']/@when)
                then($correspActionSent/tei:date[@type='editor' and 1]/@when/string())
                else if($correspActionSent/tei:date[@type='editor' and 1]/@from)
                then($correspActionSent/tei:date[@type='editor' and 1]/@from/string()) (: größte confidence ansonsten das Erste :)
                else if($correspActionSent/tei:date[@type='editor']/@notBefore)
                then($correspActionSent/tei:date[@type='editor' and 1]/@notBefore/string())
                else if($correspActionSent/tei:date[@type='editor']/@when-custom)
                then($correspActionSent/tei:date[@type='editor' and 1]/@when-custom/string())
                else if($correspActionSent/tei:date[@type='editor']/@from-custom)
                then($correspActionSent/tei:date[@type='editor' and 1]/@from-custom/string())
                else if($correspActionSent/tei:date[@type='source']/@when)
                then($correspActionSent/tei:date[@type='source' and 1]/@when/string())
                else if($correspActionSent/tei:date[@type='source']/@when-custom)
                then($correspActionSent/tei:date[@type='source' and 1]/@when-custom/string())
                else if($correspActionSent/tei:date[@type='source']/@from)
                then($correspActionSent/tei:date[@type='source' and 1]/@from/string())
                else if($correspActionSent/tei:date[@type='source']/@from-custom)
                then($correspActionSent/tei:date[@type='source' and 1]/@from-custom/string())
                else('0000')
            let $dateSecured := if(number(substring($date,1,4)) < number(substring(string(current-date()),1,4))-70)then($date)else()
            let $letterSmall := <tr class="RegisterEntry" xmlns="http://www.w3.org/1999/xhtml" dateToOrder='{$dateSecured}'><td data-toggle="tooltip" data-placement="top" title="ID: {$letterID}" valign="top" width="18%"><a href="letter/{$letterID}">{if(string-length($dateSecured)=10 and not(contains($date,'00')))then(format-date(xs:date($dateSecured),'[D]. [M,*-3]. [Y]','de',(),()))else($dateSecured)}</a></td><td width="82%">{$correspSent}<br/>an {$correspReceived}</td></tr>
    
        group by $correspSentId
        order by distinct-values($persons[@xml:id=$correspSentId]//tei:titleStmt/tei:title/string())
        return
            (let $correspSentLabel := distinct-values($persons[@xml:id = $correspSentId]//tei:titleStmt/tei:title/string())
            return
            <div class="RegisterSortBox" recipient="{$correspSentLabel}" recipientId="{$correspSentId}" letterCount="{count($letterSmall)}" xmlns="http://www.w3.org/1999/xhtml">
                <h5 class="RegisterSortEntry" id="{$correspSentId}">{$correspSentLabel}</h5>
                <table width="100%">
                {for $each in $letterSmall
                    let $order := $each/@dateToOrder
                    order by $order
                    return $each}
                    </table>
            </div>)
            
return
(<div class="container">   
    <div class="row">
        <div class="col-9">
            <p>Das Briefeverzeichnis enthält zur Zeit {count($letters)} Briefe.</p>
            <ul class="nav nav-pills" role="tablist">
                <li class="nav-item"><a class="nav-link-jra active" data-toggle="tab" href="#chrono">Nach Datum</a></li>
                <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#recipient">Nach Adressat</a></li>
                <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#sender">Nach Absender</a></li>
                <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#regRecipient">Alle Adressaten</a></li>
                <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#regSender">Alle Absender</a></li>
            </ul>
            <div class="tab-content">
                <div class="tab-pane fade show active" id="chrono">
                <br/>
                    <div class="row">
                            <nav id="nav1" class="nav nav-pills navbar-fixed-top pre-scrollable col-3"> <!--  -->
                                {for $year in $lettersGroupedByYears/@year
                                    let $letterCount := $year/parent::xhtml:div/@letterCount/data(.)
                                    let $letterYear := $year/data(.)
                                    order by $year
                                    return
                                        <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="{concat('#list-item-',$year)}"><span>{if($year='noYear')then('ohne Jahr')else($letterYear)}</span>
                                        <span class="badge badge-jra badge-pill right">{$letterCount}</span></a>
                                }
                            </nav>
                        <div data-spy="scroll" data-target="#nav1" data-offset="0" class="pre-scrollable col" id="divResults">
                           {$lettersGroupedByYears}
                        </div>
                    </div>
                </div>
                <div class="tab-pane fade show" id="recipient">
                <br/>
                    <div class="row">
                            <nav id="nav2" class="nav nav-pills navbar-fixed-top pre-scrollable col-3">
                                {for $recipient in $lettersGroupedByRecipient
                                    let $letterCount := $recipient/parent::xhtml:div/@letterCount/data(.)
                                    let $letterRecipientId := $recipient/@recipientId/data(.)
                                    let $letterRecipientLabel := $persons[@xml:id=$letterRecipientId]//tei:titleStmt/tei:title/string()
                                    order by $letterRecipientLabel
                                    return
                                        <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="{concat('#',$letterRecipientId)}"><span>{$letterRecipientLabel}</span>
                                        <span class="badge badge-jra badge-pill right">{$letterCount}</span></a>
                                }
                            </nav>
                        <div data-spy="scroll" data-target="#nav2" data-offset="0" class="col pre-scrollable" id="divResults"> 
                           {$lettersGroupedByRecipient}
                        </div>
                    </div>
                </div>
                <div class="tab-pane fade show" id="sender">
                <br/>
                    <div class="row">
                            <nav id="nav3" class="nav nav-pills navbar-fixed-top col-3 pre-scrollable">
                                {for $sender in $lettersGroupedBySender
                                    let $letterCount := $sender/parent::xhtml:div/@letterCount/data(.)
                                    let $letterSenderId := $sender/@recipientId/data(.)
                                    let $letterSenderLabel := $persons[@xml:id=$letterSenderId]//tei:titleStmt/tei:title/string()
                                    order by $letterSenderLabel
                                    return
                                        <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="{concat('#',$letterSenderId)}"><span>{$letterSenderLabel}</span>
                                        <span class="badge badge-jra badge-pill right">{$letterCount}</span></a>
                                }
                            </nav>
                        <div data-spy="scroll" data-target="#nav3" data-offset="70" class="pre-scrollable col" id="divResults">
                           {$lettersGroupedBySender}
                        </div>
                    </div>
                </div>
                <div class="tab-pane fade" id="regRecipient" >
                     
                     <div><ul>{
                   let $valuesRec := distinct-values($letters//tei:correspAction[@type="received"]/tei:persName/text()[1])
                   for $valueRec in $valuesRec
                   order by $valueRec
                   return
                   <li>{$valueRec}</li>
                     }</ul>
                     </div>
                     </div>
                <div class="tab-pane fade" id="regSender" >
                
                     <div><ul>{
                     let $valuesSent := distinct-values($letters//tei:correspAction[@type="sent"]/tei:persName/text()[1])
                     for $valueSent in $valuesSent
                     order by $valueSent
                     return
                     <li>{$valueSent}</li>
                       }</ul>
                     </div>
                </div>
           </div>
        </div>
        <div class="col-3">
            <br/><br/><h5>Suche</h5>
              <input type="text" id="myResearchInput" onkeyup="myFilterLetter()" placeholder="Name oder ID" title="Type in a string"/>
        </div>
   </div>
</div>
)
    
};

declare function app:letter($node as node(), $model as map(*)) {

let $id := request:get-parameter("letter-id", "Fehler")
let $letter := collection("/db/contents/jra/sources/documents/letters")//tei:TEI[@xml:id=$id]
let $person := collection("/db/contents/jra/persons")//tei:TEI
let $absender := $letter//tei:correspAction[@type="sent"]/tei:persName[1]/text()[1] (:$person[@xml:id= $letter//tei:correspAction[@type="sent"]/tei:persName[1]/@key]/tei:forename[@type='used']:)
let $datumSent := $letter//tei:correspAction[@type="sent"]/tei:date[@type='source' and 1]/@when
let $adressat := $letter//tei:correspAction[@type="received"]/tei:persName[1]/text()[1]

return
(
<div class="container">
    <div class="page-header">
        <a href="../registryLetters.html">&#8592; zum Briefeverzeichnis</a>
            <h2>Von: {$adressat}</h2>
            <h4>An: {$absender}</h4>
            <h4>Datum: {format-date(xs:date($datumSent),'[D]. [M,*-3]. [Y]','de',(),())}</h4>
            <h6>ID: {$id}</h6>
    </div>
     <ul class="nav nav-tabs" role="tablist">
        <li class="nav-item"><a class="nav-link-jra active" data-toggle="tab" href="#metadata">Metadaten</a></li>  
        <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#xmlAnsicht">XML-Ansicht</a></li>
    </ul>
    <div class="tab-content">
        <div class="tab-pane fade show active" id="metadaten" >
            <br/>
            <div class="row">
            <div class="col-4">
                {if($letter//tei:facsimile/tei:graphic)
                then(<a href="{$letter//tei:facsimile/tei:graphic/@url}"><img src="{$letter//tei:facsimile/tei:graphic/@url}" class="img-thumbnail" width="250" target="_blank"/></a>)
                else('no picture')}
                <br/><br/>
                {if($letter//tei:facsimile/tei:graphic)
                then('Quelle: ',$letter//tei:facsimile/tei:graphic/tei:desc[@type="source"])
                else('no SourceLink')}
                 | Unveränderte Wiedergabe
                 {if($letter//tei:facsimile/tei:graphic)
                then('Lizenz: ',<a href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.de" target="_blank">{$letter//tei:facsimile/tei:graphic/tei:desc[@type="licence"]}</a>)
                else('no picture')}
            </div>
               <div class="col"> {transform:transform($letter//tei:teiHeader,doc("/db/apps/raffArchive/resources/xslt/metadataLetter.xsl"), ())}
            </div>
            <div class="col-2">
            Änderungen:
            <br/>
                {for $change at $n in $letter//tei:revisionDesc/tei:change
                let $changeDate := format-date(xs:date($change/@when),'[D]. [M,*-3]. [Y]','de',(),())
                return
                    ($changeDate,<br/>)}
            </div>
            </div>
            <div class="row">
                {transform:transform($letter//tei:text,doc("/db/apps/raffArchive/resources/xslt/contentLetter.xsl"), ())}
            </div>
        </div>
        <div class="tab-pane fade" id="xmlAnsicht">
            {transform:transform($letter,doc("/db/apps/raffArchive/resources/xslt/xmlView.xsl"), ())}
        </div>
    </div>
  </div>
)
};

declare function app:registryPersons($node as node(), $model as map(*)) {

   let $persons := collection("/db/contents/jra/persons/")//tei:TEI
  (:  let $namedPersonsDist := functx:distinct-deep(collection("/db/contents/jra/sources")//tei:text//tei:persName[normalize-space(.)])
    let $namedPersons := collection("/db/contents/jra/sources")//tei:text//tei:persName[normalize-space(.)] :)

let $personsAlpha := for $person in $persons
                        let $persID := $person/@xml:id/string()
                        let $initial := substring($person//tei:surname[@type="used"][1],1,1)
                        let $nameSurname := $person//tei:surname[@type="used"][1]
                        let $nameForename := $person//tei:forename[@type="used"][1]
                        let $nameAddName := $person//tei:nameLink[1]
                        let $nameForeFull := if($nameAddName)then(concat($nameForename,' ',$nameAddName))else($nameForename)
                        let $nameToJoin := if(not($nameSurname=''))then($nameSurname,$nameForeFull)else($nameForeFull)
                        let $role := $person//tei:roleName[1]
                        let $nameJoined := if($role)
                                           then(concat(if($nameForeFull='')
                                           then($nameSurname)
                                           else(string-join($nameToJoin,', ')),' (',$role,')'))
                                           else if($nameForeFull='')
                                           then($nameSurname)
                                           else(string-join($nameToJoin,', '))
                        let $name := <li>{$nameJoined} [<a href="person/{$persID}">{$persID}</a>]</li>
                        group by $initial
                        order by $initial
                        return
                            (<ul name="{$initial}">
                                {for $each in $name
                                    order by $each
                                    return
                                        $each}
                             </ul>)

let $personsGroupedByInitials := for $groups in $personsAlpha
                                    group by $initial := $groups/@name/string()
                                    return
                                           (<div><h5 id="{concat('list-item-',if($groups/@name/string()='')then('unknown')else($groups/@name/string()))}">
                                                {if($groups/@name/string()='')then('[unbekannt]')else($groups/@name/string())}
                                            </h5>
                                            {
                                                    for $group in $groups
                                                        return
                                                            $group
                                             }
                                           </div>)

(: {
        for $person in $persons
        let $name := $person//tei:title
        let $id := $person/@xml:id
        order by $name
        return
        <li>{$name/normalize-space(data(.))} (ID: <a href="person/{$id}">{$id/normalize-space(data(.))}</a>)</li>:)
        
return

<div class="container" xmlns="http://www.w3.org/1999/xhtml">
        <div class="row">
        <div class="col-9">
        <p>In diesem Verzeichnis sind aktuell {count($persons)} Personen erfasst.</p>
            <ul class="nav nav-tabs" id="myTab" role="tablist">
               <li class="nav-item"><a class="nav-link-jra active" data-toggle="tab" href="#tab1">Alphabetisch</a></li>  
               <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#tab2">Alle Erwähnungen</a></li>
            </ul>
            <div class="tab-content">
            <div class="tab-pane fade show active" id="tab1">
            <br/>
                <div class="row">
                        <nav id="nav" class="nav nav-pills navbar-fixed-top col-3 pre-scrollable">
                            {for $person in $persons
                                let $initial := if($person//tei:surname[@type="used"]='')then('unknown')else(substring($person//tei:surname[@type="used"],1,1))
                                group by $initial
                                order by $initial
                                return
                                        <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="{concat('#list-item-',$initial)}"><span>{if($initial='unknown')then('[unbekannt]')else($initial)}</span>
                                            <span class="badge badge-jra badge-pill right">{count($person[substring(.//tei:surnme[@type="used"],1,1)=$initial])}</span>
                                        </a>
                            }
                            </nav>
                    <div data-spy="scroll" data-target="#nav" data-offset="70" class="pre-scrollable col" id="divResults">
                        {$personsGroupedByInitials}
                    </div>
                </div>
            </div>
            <div class="tab-pane fade" id="tab2">
                no content
            </div>
            </div>
            </div>
            <div class="col-3">
            <br/><br/>
            <h5>Suche</h5>
              <input type="text" id="myResearchInput" onkeyup="myFilterPerson()" placeholder="Name oder ID" title="Type in a string"/>
        </div>
        </div>
       </div>
};

declare function app:person($node as node(), $model as map(*)) {
 
let $id := request:get-parameter("person-id", "Fehler")
let $person := collection("/db/contents/jra/persons")//tei:TEI[@xml:id=$id]
let $name := $person//tei:title/normalize-space(data(.))
let $personNaming := collection("/db/contents/jra/sources")//tei:persName[@key=$id]
let $personNamingDistinct := functx:distinct-deep($personNaming)
return
(
<div class="row">
    <div class="page-header">
        <a href="http://localhost:8080/exist/apps/raffArchive/html/registryPersons.html">&#8592; zum Personenverzeichnis</a>
        <h1>{$name}</h1>
        <h5>ID: {$id}</h5>
    </div>
    <div class="container">
        <div class="row">
            <div class="col">
                <ul class="nav nav-pills" role="tablist">
                  <li class="nav-item"><a class="nav-link-jra active" data-toggle="tab" href="#metadaten">Metadaten</a></li>
                  {if($personNaming)then(<li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#named">Erwähnungen</a></li>)else()}
                  <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#xmlAnsicht">XML-Ansicht</a></li>
                </ul>
                <div class="tab-content">
                    <br/>
                    <div class="tab-pane fade show active" id="metadaten">
                        {transform:transform($person,doc("/db/apps/raffArchive/resources/xslt/metadataPerson.xsl"), ())}
                        <br/>
                        {transform:transform($person,doc("/db/apps/raffArchive/resources/xslt/contentPerson.xsl"), ())}
                    </div>
                    {if($personNaming)then(<div class="tab-pane fade" id="named" >
                        <ul>
                        {
                            for $each in $personNaming
                            let $persNameDist := distinct-values($each/normalize-space(data(.)))
                            let $source := $each/ancestor::tei:TEI/@xml:id/data(.)
                            order by lower-case($persNameDist)
                            return
                            <li>{$each}{$persNameDist} (in: <b>{concat($source,'.xml')}</b>)</li>
                            }
                        </ul>
                    </div>)else()}
                    <div class="tab-pane fade" id="xmlAnsicht" >
                        <pre class="pre-scrollable">
                            <xmp>
                                {transform:transform($person,doc("/db/apps/raffArchive/resources/xslt/viewXML.xsl"), ())}
                            </xmp>
                        </pre>
                    </div>
                </div>
            </div>
            <div class="col-2">
            <h5>Links</h5>
            <li><a href="{concat('/db/contents/jra/persons/',$id,'.xml')}" download="Download">Download file</a></li>
            <li>Link2</li>
            </div>
        </div>
    </div>
</div>
)
};


declare function app:registryWorks($node as node(), $model as map(*)) {
    
    let $works := collection("/db/contents/jra/works?select=*.xml;recurse=yes")/mei:mei
    let $worksOpus := $works//mei:workList//mei:title[@type='desc' and contains(.,'Opus')]/ancestor::mei:mei
    let $worksWoO := $works//mei:workList//mei:title[@type='desc' and contains(.,'WoO')]/ancestor::mei:mei
    let $besetzungen := distinct-values($works//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[not(@type='alt')]/text())
    
    let $content := <div class="container">
    <br/>
    <ul class="nav nav-pills" role="tablist">
        <li class="nav-item"><a class="nav-link-jra active" data-toggle="tab" href="#sortOpus">Opera</a></li>
        <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#sortWoO">WoOs</a></li>
        <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#sortTitle">Titel</a></li>
        <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#sortDate">Chronologie</a></li>
        <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#sortPerfRes">Besetzung</a></li>
    </ul>
    <!-- Tab panels -->
    <div class="tab-content">
    <div class="tab-pane fade show active" id="sortOpus">
        <p>
        <h5>Werke mit Opuszahl</h5>
            <ul>
        {
        for $work in $worksOpus
        let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/normalize-space(text())
        let $opus := $work//mei:workList//mei:title[@type='desc']/normalize-space(text())
        let $id := $work/@xml:id/normalize-space(data(.))
        order by $opus ascending
        return
            <li>
                {$name}, {$opus} (ID: <a href="work/{$id}">{$id}</a>)<br/>
            </li>
        }
            </ul>
            </p>
        </div>
        <div class="tab-pane fade" id="sortWoO">
        <p>
        <h5>Werke ohne Opuszahl</h5>
            <ul>
        {
        for $work in $worksWoO
        let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/normalize-space(text())
        let $opus := $work//mei:workList//mei:title[@type='desc']/normalize-space(text())
        let $id := $work/@xml:id/normalize-space(data(.))
        order by $opus ascending
        return
            <li>
                {$name}, {$opus} (ID: <a href="work/{$id}">{$id}</a>)<br/>
            </li>
        }
            </ul>
            </p>
        </div>
        <div class="tab-pane fade" id="sortTitle">
        <p>
        <h5>Alpabetisch nach Titel</h5>
            <ul>
        {
        for $work in $works
        let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/normalize-space(text())
        let $opus := $work//mei:workList//mei:title[@type='desc']/normalize-space(text())
        let $id := $work/@xml:id/normalize-space(data(.))
        order by $name ascending
        return
            <li>
                {$name}, {$opus} (ID: <a href="work/{$id}">{$id}</a>)<br/>
            </li>
        }
            </ul>
            </p>
        </div>
        <div class="tab-pane fade" id="sortDate">
        <p>
        <h5>Nach Entstehungszeit</h5>
            <ul>
        {
        for $work in $works
        let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/normalize-space(text())
        let $dateComposition := $work//mei:date[@type="composition" and 1]
        let $opus := $work//mei:workList//mei:title[@type='desc']/normalize-space(text())
        let $id := $work/@xml:id/normalize-space(data(.))
        order by $dateComposition ascending
        return
            <li>
                {$name}, {$opus} (ID: <a href="work/{$id}">{$id}</a>)<br/>
            </li>
        }
            </ul>
            </p>
        </div>
        <div class="tab-pane fade" id="sortPerfRes">
        <p>
        {
        for $besetzung in $besetzungen
        let $category := $besetzung
        order by $category ascending
        return(
        <h5>{$category}</h5>,
          <ul>
          {
        for $work in $works
        where $work//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes/text() = $category
        let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/normalize-space(text())
        let $opus := $work//mei:workList//mei:title[@type='desc']/normalize-space(text())
        let $id := $work/@xml:id/normalize-space(data(.))
        order by $opus ascending
        return
            <li>
                {$name}, {$opus} (ID: <a href="work/{$id}">{$id}</a>)<br/>
            </li>
        }
          </ul>)
          }
            </p>
        </div>
        </div>
   </div>
       return $content
       };
       
declare function app:work($node as node(), $model as map(*)) {

let $id := request:get-parameter("work-id", "Fehler")
let $work := collection("/db/contents/jra/works")/mei:mei[@xml:id=$id]
let $opus := $work//mei:workList//mei:title[@type='desc']/normalize-space(text())
let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/normalize-space(text())

return
(
    <div class="container">
        <a href="../registryWorks.html">&#8592; zum Werkeverzeichnis</a>
        <br/>
        <div class="page-header">
            <h1>{$name}, {$opus}</h1>
            <h5>ID: {$id}</h5>
        </div>
        <br/>
    <div class="col">
        {transform:transform($work,doc("/db/apps/raffArchive/resources/xslt/metadataWork.xsl"), ())}
    </div>
    </div>
)
};

declare function app:aboutProject($node as node(), $model as map(*)) {

let $text := doc("/db/contents/jra/texts/portal/aboutProject.xml")/tei:TEI

return
(
    <div class="container">
        {transform:transform($text,doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
    </div>
)
};

declare function app:aboutRaff($node as node(), $model as map(*)) {

let $text := doc("/db/contents/jra/texts/portal/aboutRaff.xml")/tei:TEI

return
(
    <div class="container">
        {transform:transform($text,doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
    </div>
)
};

declare function app:indexPage($node as node(), $model as map(*)) {

let $text := doc('/db/contents/jra/texts/portal/index.xml')

return
(
    <div class="container">
        {transform:transform($text,doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
    </div>
)
};

declare function app:impressum($node as node(), $model as map(*)) {

let $text := doc("/db/contents/jra/texts/portal/impressum.xml")/tei:TEI

return
(
    <div class="container">
        {transform:transform($text,doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
    </div>
)
};

(:declare function app:guidelines($node as node(), $model as map(*)) {

let $codingGuidelines := doc('/db/contents/jra/texts/documentation/codingGuidelines.xml')
let $editiorialGuidelines := doc('/db/contents/jra/texts/documentation/editorialGuidelines.xml')
let $sourceDescGuidelines := doc('/db/contents/jra/texts/documentation/sourceDescGuidelines.xml')

return
(
<div class="container">
        <ul class="nav nav-pills" role="tablist">
        <li class="nav-item"><a class="nav-link-jra active" data-toggle="tab" href="#coding">Kodierung</a></li>
        <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#edition">Edition</a></li>
        <li class="nav-item"><a class="nav-link-jra" data-toggle="tab" href="#sourceDesc">Quellenbeschreibung</a></li>
    </ul>
    <!-- Tab panels -->
    <div class="tab-content">
        <div class="tab-pane fade show active" id="coding" >
        {transform:transform($codingGuidelines,doc("/db/apps/raffArchive/resources/xslt/codingGuidelines.xsl"), ())}
        </div>
        <div class="tab-pane fade" id="edition" >
        {transform:transform($editiorialGuidelines,doc("/db/apps/raffArchive/resources/xslt/editorialGuidelines.xsl"), ())}
        </div>
        <div class="tab-pane fade" id="sourceDesc" >
        {transform:transform($sourceDescGuidelines,doc("/db/apps/raffArchive/resources/xslt/sourceDescGuidelines.xsl"), ())}
        </div>
   </div>
    </div>
)
};
:)

xquery version "3.0";

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

declare function local:downloadPerson($personFile) {
    
    let $dbWebdav := 'http://localhost:8080/exist/webdav/db/contents/jra/'
    let $collection := 'person/'
    let $id := request:get-parameter("person-id", "Fehler")
    let $filePath := concat($dbWebdav, $collection, $id)
    (:    let $interpreterURI := document-uri($interpreter[1]/root()):)
    return
        $filePath
};

declare function local:getDate($date) {

    let $get := if(count($date/tei:date[@type='editor'])=1)
                then(
                        if($date/tei:date[@type='editor']/@when)
                        then($date/tei:date[@type='editor']/@when/string())
                        else if($date/tei:date[@type='editor']/@when-custom)
                        then($date/tei:date[@type='editor']/@when-custom/string())
                        else if($date/tei:date[@type='editor']/@from)
                        then($date/tei:date[@type='editor']/@from/string())
                        else if($date/tei:date[@type='editor']/@from-custom)
                        then($date/tei:date[@type='editor']/@from-custom/string())
                        else if($date/tei:date[@type='editor']/@notBefore)
                        then($date/tei:date[@type='editor']/@notBefore/string())
                        else if($date/tei:date[@type='editor']/@notAfter)
                        then($date/tei:date[@type='editor']/@notAfter/string())
                        else('0000')
                    )
                else if(count($date/tei:date[@type='source'])=1)
                then(
                        if($date/tei:date[@type='source']/@when)
                        then($date/tei:date[@type='source']/@when/string())
                        else if($date/tei:date[@type='source']/@when-custom)
                        then($date/tei:date[@type='source']/@when-custom/string())
                        else if($date/tei:date[@type='source']/@from)
                        then($date/tei:date[@type='source']/@from/string())
                        else if($date/tei:date[@type='source']/@from-custom)
                        then($date/tei:date[@type='source']/@from-custom/string())
                        else if($date/tei:date[@type='source']/@notBefore)
                        then($date/tei:date[@type='source']/@notBefore/string())
                        else if($date/tei:date[@type='source']/@notAfter)
                        then($date/tei:date[@type='source']/@notAfter/string())
                        else('0000')
                    )
                else if(count($date/tei:date[@type='editor' and @confidence])=1)
                then(
                       $date/tei:date[@type='editor' and not(@confidence = '0.5')][@confidence = max(@confidence)]/@when
                    )
                else if(count($date/tei:date[@type='source' and @confidence])=1)
                then(
                       $date/tei:date[@type='source' and not(@confidence = '0.5')][@confidence = max(@confidence)]/@when
                    )
                    else if($date/tei:date[@type='editor' and @confidence = '0.5'])
                then(
                       $date/tei:date[@type='editor' and @confidence ='0.5'][1]/@when
                    )
                else if($date/tei:date[@type='source' and @confidence='0.5'])
                then(
                       $date/tei:date[@type='source' and @confidence ='0.5'][1]/@when
                    )
                else if($date/tei:date[@type='editor'])
                then(
                        if($date/tei:date[@type='editor']/@when)
                        then($date/tei:date[@type='editor'][1]/@when/string())
                        else if($date/tei:date[@type='editor']/@when-custom)
                        then($date/tei:date[@type='editor'][1]/@when-custom/string())
                        else if($date/tei:date[@type='editor']/@from)
                        then($date/tei:date[@type='editor'][1]/@from/string())
                        else if($date/tei:date[@type='editor']/@from-custom)
                        then($date/tei:date[@type='editor'][1]/@from-custom/string())
                        else if($date/tei:date[@type='editor']/@notBefore)
                        then($date/tei:date[@type='editor'][1]/@notBefore/string())
                        else('0000')
                    )
                else if(count($date/tei:date[@type='source']))
                then(
                        if($date/tei:date[@type='source']/@when)
                        then($date/tei:date[@type='source'][1]/@when/string())
                        else if($date/tei:date[@type='source']/@when-custom)
                        then($date/tei:date[@type='source'][1]/@when-custom/string())
                        else if($date/tei:date[@type='source']/@from)
                        then($date/tei:date[@type='source'][1]/@from/string())
                        else if($date/tei:date[@type='source']/@from-custom)
                        then($date/tei:date[@type='source'][1]/@from-custom/string())
                        else if($date/tei:date[@type='source']/@notBefore)
                        then($date/tei:date[@type='source'][1]/@notBefore/string())
                        else if($date/tei:date[@type='source']/@notAfter)
                        then($date/tei:date[@type='source'][1]/@notAfter/string())
                        else('0000')
                    )
                else('0000')
                
    return
        $get[number(substring(.,1,4)) < number(substring(string(current-date()),1,4))-70]
};

declare function app:registryLetters($node as node(), $model as map(*)) {
    
    let $letters := collection("/db/contents/jra/sources/documents/letters")//tei:TEI
    let $persons := collection('/db/contents/jra/persons')//tei:TEI
    let $institutions := collection('/db/contents/jra/institutions')//tei:TEI
    
    let $letters := collection("/db/contents/jra/sources/documents/letters")//tei:TEI
    let $persons := collection('/db/contents/jra/persons')//tei:TEI
    
    let $lettersCrono := for $letter in $letters
                        let $letterID := $letter/@xml:id/data(.)
                        let $correspActionSent := $letter//tei:correspAction[@type="sent"]
                        let $correspActionReceived := $letter//tei:correspAction[@type="received"]
                        let $correspSent := if($correspActionSent/tei:persName/text() or $correspActionSent/tei:orgName/text()) then($correspActionSent/tei:persName/text()[1] | $correspActionSent/tei:orgName/text()[1]) else('[Unbekannt]')
                        (:let $correspSentId := if($correspActionSent/tei:persName/@key or $correspActionSent/tei:orgName/@key) then($correspActionSent/tei:persName/@key | $correspActionSent/tei:orgName/@key) else('noID'):)
                        let $correspReceived := if($correspActionReceived/tei:persName/text() or $correspActionReceived/tei:orgName/text()) then($correspActionReceived/tei:persName/text()[1] | $correspActionReceived/tei:orgName/text()[1]) else ('[Unbekannt]')
                        (:let $correspReceivedId := if($correspActionReceived/tei:persName/@key or $correspActionReceived/tei:orgName/@key) then($correspActionReceived/tei:persName/@key | $correspActionReceived/tei:orgName/@key) else('noID'):)
                        let $date := local:getDate($correspActionSent)
                        let $year := substring($date,1,4)
                        let $dateFormatted := if(string-length($date)=10 and not(contains($date,'00')))
                                              then(format-date(xs:date($date),'[D]. [M,*-3]. [Y]','de',(),()))
                                              else if($date='0000' or $date='0000-00' or $date='0000-00-00')
                                              then('[undatiert]')
                                              else if(string-length($date)=7 and not(contains($date,'00')))
                                              then (concat(upper-case(substring(format-date(xs:date(concat($date,'-01')),'[Mn,*-3]. [Y]','de',(),()),1,1)),substring(format-date(xs:date(concat($date,'-01')),'[Mn,*-3]. [Y]','de',(),()),2)))
                                              else if(contains($date,'0000-') and contains($date,'-00'))
                                              then (concat(upper-case(substring(format-date(xs:date(replace(replace($date,'0000-','1492-'),'-00','-01')),'[Mn,*-3].','de',(),()),1,1)),substring(format-date(xs:date(replace(replace($date,'0000-','1492-'),'-00','-01')),'[Mn,*-3].','de',(),()),2)))
                                              else if(starts-with($date,'0000-'))
                                              then(concat(format-date(xs:date(replace($date,'0000-','1492-')),'[D]. ','de',(),()),upper-case(substring(format-date(xs:date(replace($date,'0000-','1492-')),'[Mn,*-3]. ','de',(),()),1,1)),substring(format-date(xs:date(replace($date,'0000-','1492-')),'[Mn,*-3].','de',(),()),2)))
                                              else($date)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3">{$dateFormatted}</div>
                                <div class="col">Von {$correspSent}<br/>an {$correspReceived}</div>
                                <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                            </div>
                        group by $year
                        order by $year
                        return
                            (<div name="{$year}" count="{count($letterEntry)}" xmlns="http://www.w3.org/1999/xhtml">
                                {for $each in $letterEntry
                                    order by $each
                                    return
                                        $each}
                             </div>)
     
     let $lettersGroupedByYears :=
        for $groups in $lettersCrono[@name !='']
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
    
    let $lettersReceiver := for $letter in $letters
                        let $letterID := $letter/@xml:id/data(.)
                        let $correspActionSent := $letter//tei:correspAction[@type="sent"]
                        let $correspActionReceived := $letter//tei:correspAction[@type="received"]
                        let $correspSent := if($correspActionSent/tei:persName/text())
                        then($correspActionSent/tei:persName/text()[1])
                        else if($correspActionSent/tei:orgName/text()) then($correspActionSent/tei:orgName/text()[1]) else ('[Unbekannt]')
                        let $correspSentId := if($correspActionSent/tei:persName/@key)
                        then($correspActionSent/tei:persName/@key/string()[1])
                        else if($correspActionSent/tei:orgName/@key) then($correspActionSent/tei:orgName/@key/string()[1]) else()
                        let $correspReceived := if($correspActionReceived/tei:persName/text())
                        then($correspActionReceived/tei:persName/text()[1])
                        else if($correspActionReceived/tei:orgName/text()) then($correspActionReceived/tei:orgName/text()[1]) else ('[Unbekannt]')
                        let $correspReceivedId := if($correspActionReceived/tei:persName/@key)
                        then($correspActionReceived/tei:persName/@key/string()[1])
                        else if($correspActionReceived/tei:orgName/@key) then($correspActionReceived/tei:orgName/@key/string()[1]) else('noID')
                        let $date := local:getDate($correspActionSent)
                        let $year := substring($date,1,4)
                        let $dateFormatted := if(string-length($date)=10 and not(contains($date,'00')))
                                              then(format-date(xs:date($date),'[D]. [M,*-3]. [Y]','de',(),()))
                                              else if($date='0000' or $date='0000-00' or $date='0000-00-00')
                                              then('[undatiert]')
                                              else if(string-length($date)=7 and not(contains($date,'00')))
                                              then (concat(upper-case(substring(format-date(xs:date(concat($date,'-01')),'[Mn,*-3]. [Y]','de',(),()),1,1)),substring(format-date(xs:date(concat($date,'-01')),'[Mn,*-3]. [Y]','de',(),()),2)))
                                              else if(contains($date,'0000-') and contains($date,'-00'))
                                              then (concat(upper-case(substring(format-date(xs:date(replace(replace($date,'0000-','1492-'),'-00','-01')),'[Mn,*-3].','de',(),()),1,1)),substring(format-date(xs:date(replace(replace($date,'0000-','1492-'),'-00','-01')),'[Mn,*-3].','de',(),()),2)))
                                              else if(starts-with($date,'0000-'))
                                              then(concat(format-date(xs:date(replace($date,'0000-','1492-')),'[D]. ','de',(),()),upper-case(substring(format-date(xs:date(replace($date,'0000-','1492-')),'[Mn,*-3]. ','de',(),()),1,1)),substring(format-date(xs:date(replace($date,'0000-','1492-')),'[Mn,*-3].','de',(),()),2)))
                                              else($date)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3">{$dateFormatted}</div>
                                <div class="col">An {$correspSent}</div>
                                <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                            </div>
                        group by $correspReceivedId
                        order by $correspReceivedId
                        return
                            (<div receiver="{if(starts-with($correspReceivedId,'C')) then($persons[@xml:id=$correspReceivedId]//tei:titleStmt/tei:title) else if(starts-with($correspReceivedId,'D')) then($institutions[@xml:id=$correspReceivedId]//tei:titleStmt/tei:title) else()}" receiverId="{$correspReceivedId}" count="{count($letterEntry)}" xmlns="http://www.w3.org/1999/xhtml">
                                {for $each in $letterEntry
                                    order by $each
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
                <div class="RegisterSortEntry" id="{concat('list-item-',$receiverId)}">
                                                    {$receiver}
                </div>
                {
                    for $group in $groups
                        return
                            $group
                }
            </div>)
    
    let $lettersSender := for $letter in $letters
                        let $letterID := $letter/@xml:id/data(.)
                        let $correspActionSent := $letter//tei:correspAction[@type="sent"]
                        let $correspActionReceived := $letter//tei:correspAction[@type="received"]
                        (:let $correspSent := if($correspActionSent/tei:persName/text() or $correspActionSent/tei:orgName/text()) then($correspActionSent/tei:persName/text()[1] | $correspActionSent/tei:orgName/text()[1]) else('[Unbekannt]'):)
                        let $correspSentId := if($correspActionSent/tei:persName/@key)
                        then($correspActionSent/tei:persName/@key/string()[1])
                        else if($correspActionSent/tei:orgName/@key) then($correspActionSent/tei:orgName/@key/string()[1]) else()
                        let $correspReceived := if($correspActionReceived/tei:persName/text())
                        then($correspActionReceived/tei:persName/text()[1])
                        else if($correspActionReceived/tei:orgName/text()) then($correspActionReceived/tei:orgName/text()[1]) else ('[Unbekannt]')
                        let $correspReceivedId := if($correspActionReceived/tei:persName/@key)
                        then($correspActionReceived/tei:persName/@key/string()[1])
                        else if($correspActionReceived/tei:orgName/@key) then($correspActionReceived/tei:orgName/@key/string()[1]) else('noID')
                        let $date := local:getDate($correspActionSent)
                        let $year := substring($date,1,4)
                        let $dateFormatted := if(string-length($date)=10 and not(contains($date,'00')))
                                              then(format-date(xs:date($date),'[D]. [M,*-3]. [Y]','de',(),()))
                                              else if($date='0000' or $date='0000-00' or $date='0000-00-00')
                                              then('[undatiert]')
                                              else if(string-length($date)=7 and not(contains($date,'00')))
                                              then (concat(upper-case(substring(format-date(xs:date(concat($date,'-01')),'[Mn,*-3]. [Y]','de',(),()),1,1)),substring(format-date(xs:date(concat($date,'-01')),'[Mn,*-3]. [Y]','de',(),()),2)))
                                              else if(contains($date,'0000-') and contains($date,'-00'))
                                              then (concat(upper-case(substring(format-date(xs:date(replace(replace($date,'0000-','1492-'),'-00','-01')),'[Mn,*-3].','de',(),()),1,1)),substring(format-date(xs:date(replace(replace($date,'0000-','1492-'),'-00','-01')),'[Mn,*-3].','de',(),()),2)))
                                              else if(starts-with($date,'0000-'))
                                              then(concat(format-date(xs:date(replace($date,'0000-','1492-')),'[D]. ','de',(),()),upper-case(substring(format-date(xs:date(replace($date,'0000-','1492-')),'[Mn,*-3]. ','de',(),()),1,1)),substring(format-date(xs:date(replace($date,'0000-','1492-')),'[Mn,*-3].','de',(),()),2)))
                                              else($date)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3">{$dateFormatted}</div>
                                <div class="col">An {$correspReceived}</div>
                                <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                            </div>
                        group by $correspSentId
                        order by $correspSentId
                        return
                            (<div sender="{if(starts-with($correspSentId,'C')) then($persons[@xml:id=$correspSentId]//tei:titleStmt/tei:title) else if(starts-with($correspSentId,'D')) then($institutions[@xml:id=$correspSentId]//tei:titleStmt/tei:title) else()}" senderId="{$correspSentId}" count="{count($letterEntry)}" xmlns="http://www.w3.org/1999/xhtml">
                                {for $each in $letterEntry
                                    order by $each
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
                <div class="RegisterSortEntry" id="{concat('list-item-',$senderId)}">
                                                    {$sender}
                </div>
                {
                    for $group in $groups
                        return
                            $group
                }
            </div>)
    
    return
        (<div
            class="container">
            <div
                class="row">
                <div
                    class="col-9">
                    <p>Der Katalog verzeichnet derzeit {count($letters)} Briefe.</p>
                    <ul
                        class="nav nav-pills"
                        role="tablist">
                        <li
                            class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra active"
                                data-toggle="tab"
                                href="#date">Datum</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                data-toggle="tab"
                                href="#receiver">Adressat</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                data-toggle="tab"
                                href="#sender">Absender</a></li>
                    </ul>
                    <div
                        class="tab-content">
                        <div
                            class="tab-pane fade show active"
                            id="date">
                            <br/>
                            <div
                                class="row">
                                <nav
                                    id="nav1"
                                    class="nav nav-pills navbar-fixed-top pre-scrollable col-3">
                                    <!--  -->
                                    {
                                        for $year in $lettersGroupedByYears[@year !='']
                                        let $letterCount := $year/@count/string()
                                        let $letterYear := $year/@year/string()
                                            order by $year
                                        return
                                            <a
                                                class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', if($letterYear='[Jahr nicht ermittelbar]')then('unknown')else($letterYear))}"><span>{
                                                        if ($letterYear = '[Jahr unbekannt]') then
                                                            ('[ohne Jahr]')
                                                        else
                                                            ($letterYear)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$letterCount}</span>
                                            </a>
                                    }
                                </nav>
                                <div
                                    data-spy="scroll"
                                    data-target="#nav1"
                                    data-offset="0"
                                    class="pre-scrollable col"
                                    id="divResults">
                                    {$lettersGroupedByYears}
                                </div>
                            </div>
                        </div>
                        <div
                            class="tab-pane fade"
                            id="receiver">
                            <br/>
                            <div
                                class="row">
                                <nav
                                    id="nav1"
                                    class="nav nav-pills navbar-fixed-top pre-scrollable col-3">
                                    <!--  -->
                                    {
                                        for $receiver in $lettersGroupedByReceivers
                                        let $letterCount := $receiver/@count/string()
                                        let $letterReceiver := $receiver/@receiver/string()
                                        let $letterReceiverId := $receiver/@receiverId/string()
                                            order by $letterReceiverId
                                        return
                                            <a
                                                class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-',$letterReceiverId)}"><span>{$letterReceiver}</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$letterCount}</span>
                                            </a>
                                    }
                                </nav>
                                <div
                                    data-spy="scroll"
                                    data-target="#nav1"
                                    data-offset="0"
                                    class="pre-scrollable col"
                                    id="divResults">
                                    {$lettersGroupedByReceivers}
                                </div>
                            </div>
                        </div>
                        <div
                            class="tab-pane fade"
                            id="sender">
                            <br/>
                            <div
                                class="row">
                                <nav
                                    id="nav1"
                                    class="nav nav-pills navbar-fixed-top pre-scrollable col-3">
                                    <!--  -->
                                    {
                                        for $sender in $lettersGroupedBySenders
                                        let $letterCount := $sender/@count/string()
                                        let $letterSender := $sender/@sender/string()
                                        let $letterSenderId := $sender/@senderId/string()
                                            order by $letterSenderId
                                        return
                                            <a
                                                class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-',$letterSenderId)}"><span>{$letterSender}</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$letterCount}</span>
                                            </a>
                                    }
                                </nav>
                                <div
                                    data-spy="scroll"
                                    data-target="#nav1"
                                    data-offset="0"
                                    class="pre-scrollable col"
                                    id="divResults">
                                    {$lettersGroupedBySenders}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div
                    class="col-3">
                    <br/><br/><h5>Suche</h5>
                    <input
                        type="text"
                        id="myResearchInput"
                        onkeyup="myFilterLetter()"
                        placeholder="Name oder ID"
                        title="Type in a string"/>
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
    let $datumSent := $letter//tei:correspAction[@type = "sent"]/tei:date[@type = 'source' and 1]/@when
    let $adressat := $letter//tei:correspAction[@type = "received"]/tei:persName[1]/text()[1]
    
    return
        (
        <div
            class="container">
            <div
                class="page-header">
                <a
                    href="../registryLetters.html">&#8592; zum Briefeverzeichnis</a>
                <br/>
                <br/>
                <h4>Brief vom {format-date(xs:date($datumSent), '[D]. [M,*-3]. [Y]', 'de', (), ())}</h4>
                <h6>ID: {$id}</h6>
                <br/>
            </div>
            <ul
                class="nav nav-tabs"
                role="tablist">
                <li
                    class="nav-item"><a
                        class="nav-link-jra active"
                        data-toggle="tab"
                        href="#letterMetadata">Metadaten</a></li>
                <li
                    class="nav-item"><a
                        class="nav-link-jra"
                        data-toggle="tab"
                        href="#letterContent">Inhalt</a></li>
                <li
                    class="nav-item"><a
                        class="nav-link-jra"
                        data-toggle="tab"
                        href="#xmlView">XML-Ansicht</a></li>
            </ul>
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
                            {transform:transform($letter//tei:teiHeader, doc("/db/apps/raffArchive/resources/xslt/metadataLetter.xsl"), ())}
                        </div>
                        <div
                            class="col-2">
                            Änderungen:
                            <br/>
                            {
                                for $change at $n in $letter//tei:revisionDesc/tei:change
                                let $changeDate := format-date(xs:date($change/@when), '[D]. [M,*-3]. [Y]', 'de', (), ())
                                return
                                    ($changeDate, <br/>)
                            }
                        </div>
                    </div>
                </div>
                <div
                    class="tab-pane fade"
                    id="letterContent">
                    <div
                        class="row">
                        <div
                            class="col-4">
                            <br/>
                            {
                                if ($letter//tei:facsimile/tei:surface[1]/tei:graphic)
                                then
                                    (<a
                                        href="{$letter//tei:facsimile/tei:surface[1]/tei:graphic/@url}"><img
                                            src="{$letter//tei:facsimile/tei:surface[1]/tei:graphic/@url}"
                                            class="img-thumbnail"
                                            width="250"
                                            target="_blank"/></a>)
                                else
                                    ('no picture')
                            }
                            <br/><br/>
                            {
                                if ($letter//tei:facsimile/tei:surface[1]/tei:graphic)
                                then
                                    ('Quelle: ', $letter//tei:msIdentifier/tei:repository, ' ', $letter//tei:msIdentifier/tei:settlement, ', ', $letter//tei:msIdentifier/tei:idno)
                                else
                                    ('no SourceLink')
                            }
                            | Unveränderte Wiedergabe
                            {
                                if ($letter//tei:facsimile/tei:surface[1]/tei:graphic)
                                then
                                    ('Lizenz: ',
                                    <a
                                        href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.de"
                                        target="_blank">{$letter//tei:facsimile/tei:surface[1]/tei:graphic/tei:desc[@type = "licence"]}</a>)
                                else
                                    ('no picture')
                            }
                        </div>
                        <div
                            class="col">
                            {transform:transform($letter//tei:text, doc("/db/apps/raffArchive/resources/xslt/contentLetter.xsl"), ())}
                        </div>
                    </div>
                </div>
                <div
                    class="tab-pane fade"
                    id="xmlView">
                    {transform:transform($letter, doc("/db/apps/raffArchive/resources/xslt/xmlView.xsl"), ())}
                </div>
            </div>
        </div>
        )
};

declare function app:registryPersons($node as node(), $model as map(*)) {
    
    let $persons := collection("/db/contents/jra/persons/")//tei:TEI
    
    let $personsAlpha := for $person in $persons
    let $persID := $person/@xml:id/string()
    let $initial := substring($person//tei:surname[@type = "used"][1], 1, 1)
    let $nameSurname := $person//tei:surname[@type = "used"][1]
    let $nameForename := $person//tei:forename[@type = "used"][1]
    let $nameAddName := $person//tei:nameLink[1]
    let $nameForeFull := if ($nameAddName) then
        (concat($nameForename, ' ', $nameAddName))
    else
        ($nameForename)
    let $nameToJoin := if (not($nameSurname = '')) then
        ($nameSurname, $nameForeFull)
    else
        ($nameForeFull)
    let $role := $person//tei:roleName[1]
    let $pseudonym := if ($person//node()[@type = 'pseudonym'])
    then
        (concat($person//tei:forename[@type = 'pseudonym'], ' ', $person//tei:surname[@type = 'pseudonym']))
    else
        ()
    let $birth := if ($person//tei:birth[1][@when-iso])
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
                    ()
    let $death := if ($person//tei:death[1][@when-iso])
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
                    ()
    let $lifeData := if ($birth[. != ''] and $death[. != ''])
    then
        (concat(' (', $birth, '–', $death, ')'))
    else
        if ($birth and not($death))
        then
            (concat(' (* ', $birth, ')'))
        else
            if ($death and not($birth))
            then
                (concat(' († ', $birth, ')'))
            else
                ()
    let $nameJoined := if ($nameForeFull = '')
    then
        ($nameSurname)
    else
        (string-join($nameToJoin, ', '))
    let $name := <div
        class="row RegisterEntry">
        <div
            class="col">
            {$nameJoined}
            {$lifeData}
            {
                if ($role) then
                    (<br/>, ' (', $role, ')')
                else
                    ()
            }
            {
                if ($pseudonym) then
                    (<br/>, concat('(Pseudonym: ', $pseudonym, ')'))
                else
                    ()
            }
        </div>
        <!--<div class="col-3"></div>-->
        <div
            class="col-2"><a
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
                    order by $each
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
            count="{$personsAlpha[@name = $initial]/@count}"
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
                        ('[unbekannt]')
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
    
    let $personsBirth := for $person in $persons
    let $persID := $person/@xml:id/string()
    let $nameSurname := $person//tei:surname[@type = "used"][1]
    let $nameForename := $person//tei:forename[@type = "used"][1]
    let $nameAddName := $person//tei:nameLink[1]
    let $nameForeFull := if ($nameAddName) then
        (concat($nameForename, ' ', $nameAddName))
    else
        ($nameForename)
    let $nameToJoin := if (not($nameSurname = '')) then
        ($nameSurname, $nameForeFull)
    else
        ($nameForeFull)
    let $role := $person//tei:roleName[1]
    let $pseudonym := if ($person//node()[@type = 'pseudonym'])
    then
        (concat($person//tei:forename[@type = 'pseudonym'], ' ', $person//tei:surname[@type = 'pseudonym']))
    else
        ()
    let $birth := if ($person//tei:birth[1][@when-iso])
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
                    ('')
    let $birthFormatted := if(starts-with($birth,'-0')) then(concat(substring(format-number(number($birth),'##.##;##.##'),2),' v. Chr.')) else($birth)
    let $death := if ($person//tei:death[1][@when-iso])
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
                    ('')
    let $deathFormatted := if(starts-with($death,'-')) then(concat(substring(format-number(number($death),'##.##;##.##'),2),' v. Chr.')) else($death)
    let $lifeData := if ($birthFormatted[. != ''] and $deathFormatted[. != ''])
    then
        (concat(' (', $birthFormatted, '–', $deathFormatted, ')'))
    else
        if ($birthFormatted and not($deathFormatted))
        then
            (concat(' (* ', $birthFormatted, ')'))
        else
            if ($deathFormatted and not($birthFormatted))
            then
                (concat(' († ', $birthFormatted, ')'))
            else
                ()
    let $nameJoined := if ($nameForeFull = '')
    then
        ($nameSurname)
    else
        (string-join($nameToJoin, ', '))
    let $name := <div
        class="row RegisterEntry">
        <div
            class="col">
            {$nameJoined}
            {$lifeData}
            {
                if ($role) then
                    (<br/>, ' (', $role, ')')
                else
                    ()
            }
            {
                if ($pseudonym) then
                    (<br/>, concat('(Pseudonym: ', $pseudonym, ')'))
                else
                    ()
            }
        </div>
        <!--<div class="col-3"></div>-->
        <div
            class="col-2"><a
                href="person/{$persID}">{$persID}</a></div>
    </div>
        group by $birth
        order by $birth
    return
        (<div
            name="{
                    if ($birth = '') then
                        ('unknownBirth')
                    else
                        (distinct-values($birthFormatted))
                }"
            count="{count($name)}">
            {
                for $each in $name
                    order by $each
                return
                    $each
            }
        </div>)
    
    let $personsGroupedByBirth := for $groups in $personsBirth
        group by $birth := $groups/@name/string()
        order by $birth
    return
        (<div
            class="RegisterSortBox"
            birth="{$birth}"
            count="{$personsBirth[@name = $birth]/@count}"
            xmlns="http://www.w3.org/1999/xhtml">
            <div
                class="RegisterSortEntry"
                id="{concat('list-item-', translate($birth, '/', '_'))}">
                {
                    if ($birth = 'unknownBirth') then
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
    
    let $personsDeath := for $person in $persons
    let $persID := $person/@xml:id/string()
    let $nameSurname := $person//tei:surname[@type = "used"][1]
    let $nameForename := $person//tei:forename[@type = "used"][1]
    let $nameAddName := $person//tei:nameLink[1]
    let $nameForeFull := if ($nameAddName) then
        (concat($nameForename, ' ', $nameAddName))
    else
        ($nameForename)
    let $nameToJoin := if (not($nameSurname = '')) then
        ($nameSurname, $nameForeFull)
    else
        ($nameForeFull)
    let $role := $person//tei:roleName[1]
    let $pseudonym := if ($person//node()[@type = 'pseudonym'])
    then
        (concat($person//tei:forename[@type = 'pseudonym'], ' ', $person//tei:surname[@type = 'pseudonym']))
    else
        ()
    let $birth := if ($person//tei:birth[1][@when-iso])
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
                    ('')
    let $birthFormatted := if(starts-with($birth,'-0')) then(concat(substring(format-number(number($birth),'##.##;##.##'),2),' v. Chr.')) else($birth)
    let $death := if ($person//tei:death[1][@when-iso])
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
                    ('')
    let $deathFormatted := if(starts-with($death,'-')) then(concat(substring(format-number(number($death),'##.##;##.##'),2),' v. Chr.')) else($death)
    let $lifeData := if ($birthFormatted[. != ''] and $deathFormatted[. != ''])
    then
        (concat(' (', $birthFormatted, '–', $deathFormatted, ')'))
    else
        if ($birthFormatted and not($deathFormatted))
        then
            (concat(' (* ', $birthFormatted, ')'))
        else
            if ($deathFormatted and not($birthFormatted))
            then
                (concat(' († ', $birthFormatted, ')'))
            else
                ()
    let $nameJoined := if ($nameForeFull = '')
    then
        ($nameSurname)
    else
        (string-join($nameToJoin, ', '))
    let $name := <div
        class="row RegisterEntry">
        <div
            class="col">
            {$nameJoined}
            {$lifeData}
            {
                if ($role) then
                    (<br/>, ' (', $role, ')')
                else
                    ()
            }
            {
                if ($pseudonym) then
                    (<br/>, concat('(Pseudonym: ', $pseudonym, ')'))
                else
                    ()
            }
        </div>
        <!--<div class="col-3"></div>-->
        <div
            class="col-2"><a
                href="person/{$persID}">{$persID}</a></div>
    </div>
        group by $death
        order by $death
    return
        (<div
            name="{
                    if ($death = '') then
                        ('unknownDeath')
                    else
                        (distinct-values($deathFormatted))
                }"
            count="{count($name)}">
            {
                for $each in $name
                    order by $each
                return
                    $each
            }
        </div>)
    
    let $personsGroupedByDeath := for $groups in $personsDeath
        group by $death := $groups/@name/string()
        order by $death
    return
        (<div
            class="RegisterSortBox"
            death="{$death}"
            count="{$personsDeath[@name = $death]/@count}"
            xmlns="http://www.w3.org/1999/xhtml">
            <div
                class="RegisterSortEntry"
                id="{concat('list-item-', translate($death, '/', '_'))}">
                {
                    if ($death = 'unknownDeath') then
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
                                class="nav-link-jra active"
                                data-toggle="tab"
                                href="#alpha">Alphabetisch</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                data-toggle="tab"
                                href="#birth">Geburtsjahr</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                data-toggle="tab"
                                href="#death">Sterbejahr</a></li>
                    </ul>
                    <div
                        class="tab-content">
                        <div
                            class="tab-pane fade show active"
                            id="alpha">
                            <br/>
                            <div
                                class="row">
                                <nav
                                    id="nav"
                                    class="nav nav-pills navbar-fixed-top col-3 pre-scrollable">
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
                                                class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', $initial)}"><span>{
                                                        if ($initial = 'unknown') then
                                                            ('[unbekannt]')
                                                        else
                                                            ($initial)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                            </a>
                                    }
                                
                                </nav>
                                <div
                                    data-spy="scroll"
                                    data-target="#nav"
                                    data-offset="70"
                                    class="pre-scrollable col"
                                    id="divResults">
                                    {$personsGroupedByInitials}
                                </div>
                            </div>
                        </div>
                        <div
                            class="tab-pane fade"
                            id="birth">
                            <br/>
                            <div
                                class="row">
                                <nav
                                    id="nav"
                                    class="nav nav-pills navbar-fixed-top col-3 pre-scrollable">
                                    {
                                        for $each in $personsGroupedByBirth
                                        let $birth := $each/@birth/string()
                                        let $count := $each/@count/string()
                                        return
                                            <a
                                                class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', translate($birth, '/', '_'))}"><span>{
                                                        if ($birth = 'unknownBirth') then
                                                            ('[unbekannt]')
                                                        else
                                                            ($birth)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                            </a>
                                    }
                                </nav>
                                <div
                                    data-spy="scroll"
                                    data-target="#nav"
                                    data-offset="70"
                                    class="pre-scrollable col"
                                    id="divResults">
                                    {$personsGroupedByBirth}
                                </div>
                            </div>
                        </div>
                        <div
                            class="tab-pane fade"
                            id="death">
                            <br/>
                            <div
                                class="row">
                                <nav
                                    id="nav"
                                    class="nav nav-pills navbar-fixed-top col-3 pre-scrollable">
                                    {
                                        for $each in $personsGroupedByDeath
                                        let $death := $each/@death/string()
                                        let $count := $each/@count/string()
                                        return
                                            <a
                                                class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', translate($death, '/', '_'))}"><span>{
                                                        if ($death = 'unknownDeath') then
                                                            ('[unbekannt]')
                                                        else
                                                            ($death)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                            </a>
                                    }
                                </nav>
                                <div
                                    data-spy="scroll"
                                    data-target="#nav"
                                    data-offset="70"
                                    class="pre-scrollable col"
                                    id="divResults">
                                    {$personsGroupedByDeath}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div
                    class="col-3">
                    <br/><br/>
                    <h5>Suche</h5>
                    <input
                        type="text"
                        id="myResearchInput"
                        onkeyup="myFilterPerson()"
                        placeholder="Name oder ID"
                        title="Type in a string"/>
                </div>
            </div>
        </div>
};

declare function app:person($node as node(), $model as map(*)) {
    
    let $id := request:get-parameter("person-id", "Fehler")
    let $person := collection("/db/contents/jra/persons")//tei:TEI[@xml:id = $id]
    let $name := $person//tei:title/normalize-space(data(.))
    let $personNaming := collection("/db/contents/jra/sources")//tei:persName[@key = $id]
    let $personNamingDistinct := functx:distinct-deep($personNaming)
    return
        (
        <div
            class="row">
            <div
                class="page-header">
                <a
                    href="http://localhost:8080/exist/apps/raffArchive/html/registryPersons.html">&#8592; zum Personenverzeichnis</a>
                <h1>{$name}</h1>
                <h5>ID: {$id}</h5>
            </div>
            <div
                class="container">
                <div
                    class="row">
                    <div
                        class="col">
                        <ul
                            class="nav nav-pills"
                            role="tablist">
                            <li
                                class="nav-item">
                                <a
                                    class="nav-link-jra active"
                                    data-toggle="tab"
                                    href="#metadata">Allgemein</a></li>
                            {
                                if ($personNaming) then
                                    (<li
                                        class="nav-item">
                                        <a
                                            class="nav-link-jra"
                                            data-toggle="tab"
                                            href="#named">Erwähnungen</a></li>)
                                else
                                    ()
                            }
                            <li
                                class="nav-item"><a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#xmlAnsicht">XML-Ansicht</a></li>
                        </ul>
                        <div
                            class="tab-content">
                            <br/>
                            <div
                                class="tab-pane fade show active"
                                id="metadata">
                                {transform:transform($person, doc("/db/apps/raffArchive/resources/xslt/metadataPerson.xsl"), ())}
                                <!--<br/>
                        {transform:transform($person,doc("/db/apps/raffArchive/resources/xslt/contentPerson.xsl"), ())}-->
                            </div>
                            {
                                if ($personNaming) then
                                    (<div
                                        class="tab-pane fade"
                                        id="named">
                                        <ul>
                                            {
                                                for $each in $personNaming
                                                let $persNameDist := distinct-values($each/normalize-space(data(.)))
                                                let $source := $each/ancestor::tei:TEI/@xml:id/data(.)
                                                    order by lower-case($persNameDist)
                                                return
                                                    <li>{$each}{$persNameDist} (in: <b>{concat($source, '.xml')}</b>)</li>
                                            }
                                        </ul>
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
                    <div
                        class="col-2">
                        <h5>Links</h5>
                        <li><a
                                href="{local:downloadPerson($person)}"
                                download="Download">Download file</a></li>
                        <li>Link2</li>
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
    let $place := string-join($institution//tei:org/tei:place/tei:placeName, '/')
    let $name := <div
        class="row RegisterEntry">
        <div
            class="col-6">
            {$nameInstitution}
            {
                if ($place) then
                    (concat('(', $place, ')'))
                else
                    ($place)
            }
        </div>
        <div
            class="col-4">{$place}</div>
        <div
            class="col-2"><a
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
                    order by upper-case($each)
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
                        ('[unbekannt]')
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
    let $places := string-join($place//tei:org/tei:place/tei:placeName, '/')
    let $name := <div
        class="row RegisterEntry">
        <div
            class="col-6">
            {$nameInstitution}
            {
                if ($places) then
                    (concat('(', $places, ')'))
                else
                    ($place)
            }
        </div>
        <div
            class="col-4">{$places}</div>
        <div
            class="col-2"><a
                href="institution/{$instID}">{$instID}</a></div>
    </div>
        group by $place
        order by $place
    return
        (<div
            name="{$place}"
            count="{count($name)}">
            {
                for $each in $name
                    order by upper-case($each)
                return
                    $each
            }
        </div>)
    
    let $institutionsGroupedByPlaces := for $groups in $institutionsPlace
        group by $place := $groups/@name/string()
    return
        (<div
            class="RegisterSortBox"
            place="{$place}"
            count="{$institutionsPlace[@name = $place]/@count}"
            xmlns="http://www.w3.org/1999/xhtml">
            <div
                class="RegisterSortEntry"
                id="{
                        concat('list-item-', if ($place = '') then
                            ('unknown')
                        else
                            ($place))
                    }">
                {
                    if ($place = '') then
                        ('[unbekannt]')
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
                                href="#place">Ort</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra disabled"
                                data-toggle="tab"
                                href="#established">Gründungsjahr</a></li>
                    </ul>
                    <div
                        class="tab-content">
                        <div
                            class="tab-pane fade show active"
                            id="alpha">
                            <br/>
                            <div
                                class="row">
                                <nav
                                    id="nav"
                                    class="nav nav-pills navbar-fixed-top col-3 pre-scrollable">
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
                                                class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', $initial)}"><span>{
                                                        if ($initial = 'unknown') then
                                                            ('[unbekannt]')
                                                        else
                                                            ($initial)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                            </a>
                                    }
                                </nav>
                                <div
                                    data-spy="scroll"
                                    data-target="#nav"
                                    data-offset="70"
                                    class="pre-scrollable col"
                                    id="divResults">
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
                                <nav
                                    id="nav"
                                    class="nav nav-pills navbar-fixed-top col-3 pre-scrollable">
                                    {
                                        for $each in $institutionsGroupedByPlaces
                                        let $place := if ($each/@place/string() = '') then
                                            ('unknown')
                                        else
                                            ($each/@place/string())
                                        let $count := $each/@count/string()
                                            order by $place
                                        return
                                            <a
                                                class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', $place)}"><span>{
                                                        if ($place = 'unknown') then
                                                            ('[unbekannt]')
                                                        else
                                                            ($place)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                            </a>
                                    }
                                </nav>
                                <div
                                    data-spy="scroll"
                                    data-target="#nav"
                                    data-offset="70"
                                    class="pre-scrollable col"
                                    id="divResults">
                                    {$institutionsGroupedByPlaces}
                                </div>
                            </div>
                        </div>
                        <!--<div class="tab-pane fade" id="established">
                    no content
                </div>-->
                    </div>
                </div>
                <div
                    class="col-3">
                    <br/><br/>
                    <h5>Suche</h5>
                    <input
                        type="text"
                        id="myResearchInput"
                        onkeyup="myFilterPerson()"
                        placeholder="Name oder ID"
                        title="Type in a string"/>
                </div>
            </div>
        </div>
};

declare function app:institution($node as node(), $model as map(*)) {
    
    let $id := request:get-parameter("institution-id", "Fehler")
    let $institution := collection("/db/contents/jra/institutions")//tei:TEI[@xml:id = $id]
    let $name := $institution//tei:title/normalize-space(data(.))
    let $institutionNaming := collection("/db/contents/jra/sources")//tei:orgName[@key = $id]
    let $institutionNamingDistinct := functx:distinct-deep($institutionNaming)
    return
        (
        <div
            class="row">
            <div
                class="page-header">
                <a
                    href="http://localhost:8080/exist/apps/raffArchive/html/registryPersons.html">&#8592; zum Institutionenverzeichnis</a>
                <br/>
                <br/>
                <h1>{$name}</h1>
                <h5>ID: {$id}</h5>
                <br/>
            </div>
            <div
                class="container">
                <div
                    class="row">
                    <div
                        class="col">
                        <ul
                            class="nav nav-pills"
                            role="tablist">
                            <li
                                class="nav-item">
                                <a
                                    class="nav-link-jra active"
                                    data-toggle="tab"
                                    href="#metadata">Allgemein</a></li>
                            {
                                if ($institutionNaming) then
                                    (<li
                                        class="nav-item">
                                        <a
                                            class="nav-link-jra"
                                            data-toggle="tab"
                                            href="#named">Erwähnungen</a></li>)
                                else
                                    ()
                            }
                            <li
                                class="nav-item"><a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#xmlAnsicht">XML-Ansicht</a></li>
                        </ul>
                        <div
                            class="tab-content">
                            <br/>
                            <div
                                class="tab-pane fade show active"
                                id="metadata">
                                {transform:transform($institution, doc("/db/apps/raffArchive/resources/xslt/metadataPerson.xsl"), ())}
                                <!--<br/>
                        {transform:transform($person,doc("/db/apps/raffArchive/resources/xslt/contentPerson.xsl"), ())}-->
                            </div>
                            {
                                if ($institutionNaming) then
                                    (<div
                                        class="tab-pane fade"
                                        id="named">
                                        <ul>
                                            {
                                                for $each in $institutionNaming
                                                let $instNameDist := distinct-values($each/normalize-space(data(.)))
                                                let $source := $each/ancestor::tei:TEI/@xml:id/data(.)
                                                    order by lower-case($instNameDist)
                                                return
                                                    <li>{$each}{$instNameDist} (in: <b>{concat($source, '.xml')}</b>)</li>
                                            }
                                        </ul>
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
                    <div
                        class="col-2">
                        <h5>Links</h5>
                        <li><a
                                href="{local:downloadPerson($institution)}"
                                download="Download">Download file</a></li>
                        <li>Link2</li>
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
    let $initial := replace(upper-case(substring(translate($workName, 'É', 'E'), 1, 1)), '3', '0-9')
    let $workID := $work/@xml:id/string()
    let $name := <div
        class="row RegisterEntry">
        <div
            class="col">{$workName}</div>
        <div
            class="col-2">{$opus}</div>
        <div
            class="col-2"><a
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
                    order by $each
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
                        ('[unbekannt]')
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
        class="row RegisterEntry">
        <!--<div class="col-2">{format-date(xs:date(replace($compositionDate,'00','01')),'[M,*-3]. [D]','de',(),())}</div>-->
        <div
            class="col">{$workName}</div>
        <div
            class="col-2">{$opus}</div>
        <div
            class="col-2"><a
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
                    order by $each
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
                        concat('list-item-', if ($year = '') then
                            ('unknown')
                        else
                            ($year))
                    }">
                {
                    if ($year = '') then
                        ('[unbekannt]')
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
    let $worksPerfRes := for $perfRes in $perfRess
    let $workName := $perfRes/ancestor::mei:mei//mei:workList//mei:title[@type = 'uniform']/normalize-space(text())
    let $opus := $perfRes/ancestor::mei:mei//mei:workList//mei:title[@type = 'desc']/normalize-space(text())
    let $workID := $perfRes/ancestor::mei:mei/@xml:id/string()
    let $name := <div
        class="row RegisterEntry">
        <!--<div class="col-2">{format-date(xs:date(replace($compositionDate,'00','01')),'[M,*-3]. [D]','de',(),())}</div>-->
        <div
            class="col">{$workName}</div>
        <div
            class="col-2">{$opus}</div>
        <div
            class="col-2"><a
                href="work/{$workID}">{$workID}</a></div>
    </div>
        group by $perfRes
        order by $perfRes
    return
        (<div
            name="{$perfRes}"
            count="{count($name)}">
            {
                for $each in $name
                    order by $each
                return
                    $each
            }
        </div>)
    
    let $worksGroupedByPerfRes := for $groups in $worksPerfRes
    let $perf := $groups/@name/string()
    let $count := $groups/@count/string()
    return
        (<div
            class="RegisterSortBox"
            perf="{$perf}"
            count="{$count}"
            xmlns="http://www.w3.org/1999/xhtml">
            <div
                class="RegisterSortEntry"
                id="{
                        concat('list-item-', if ($perf = '') then
                            ('unknown')
                        else
                            ($perf))
                    }">
                {
                    if ($perf = '') then
                        ('[unbekannt]')
                    else
                        ($perf)
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
            class="nav nav-pills"
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
                    href="#sortTitle">Titel</a></li>
            <li
                class="nav-item"><a
                    class="nav-link-jra"
                    data-toggle="tab"
                    href="#sortDate">Entstehung</a></li>
            <li
                class="nav-item"><a
                    class="nav-link-jra"
                    data-toggle="tab"
                    href="#sortPerfRes">Besetzung</a></li>
            <li
                class="nav-item"><a
                    class="nav-link-jra disabled"
                    data-toggle="tab"
                    href="#sortGenre">Gattung</a></li>
        </ul>
        <!-- Tab panels -->
        <div
            class="tab-content">
            <div
                class="tab-pane fade show active"
                id="sortWork">
                <br/>
                <div
                    class="row">
                    <div
                        data-spy="scroll"
                        data-target="#nav"
                        data-offset="70"
                        class="pre-scrollable col"
                        id="divResults">
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
                    <div
                        class="col-2">
                        <nav
                            id="nav"
                            class="nav-pills col">
                            <li
                                class="nav-item nav-linkless-jra">Kategorien</li>
                            <a
                                class="list-group-item list-group-item-action"
                                href="#opera"><span>Opera</span></a>
                            <a
                                class="list-group-item list-group-item-action"
                                href="#woos"><span>WoOs</span></a>
                        </nav>
                    </div>
                </div>
            </div>
            <div
                class="tab-pane fade"
                id="sortTitle">
                <br/>
                <div
                    class="row">
                    <nav
                        id="nav"
                        class="nav nav-pills navbar-fixed-top col-2 pre-scrollable">
                        {
                            for $each in $worksGroupedByInitials
                            let $initial := $each/@initial/string()
                            let $count := $each/@count/string()
                                order by $initial
                            return
                                <a
                                    class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                    href="{concat('#list-item-', $initial)}"><span>{
                                            if ($initial = 'unknown') then
                                                ('[unbekannt]')
                                            else
                                                ($initial)
                                        }</span>
                                    <span
                                        class="badge badge-jra badge-pill right">{$count}</span>
                                </a>
                        }
                    
                    </nav>
                    <div
                        data-spy="scroll"
                        data-target="#nav"
                        data-offset="70"
                        class="pre-scrollable col"
                        id="divResults">
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
                    <nav
                        id="nav"
                        class="nav nav-pills navbar-fixed-top col-2 pre-scrollable">
                        {
                            for $each in $worksGroupedByYears
                            let $year := $each/@year/string()
                            let $count := $each/@count/string()
                                order by $year
                            return
                                <a
                                    class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                    href="{concat('#list-item-', $year)}"><span>{
                                            if ($year = 'unknown') then
                                                ('[unbekannt]')
                                            else
                                                ($year)
                                        }</span>
                                    <span
                                        class="badge badge-jra badge-pill right">{$count}</span>
                                </a>
                        }
                    
                    </nav>
                    <div
                        data-spy="scroll"
                        data-target="#nav"
                        data-offset="70"
                        class="pre-scrollable col"
                        id="divResults">
                        {$worksGroupedByYears}
                    </div>
                </div>
            </div>
            <div
                class="tab-pane fade"
                id="sortPerfRes">
                <br/>
                <div
                    class="row">
                    <nav
                        id="nav"
                        class="nav nav-pills navbar-fixed-top col-2 pre-scrollable">
                        {
                            for $each in $worksGroupedByPerfRes
                            let $perf := $each/@perf/string()
                            let $count := $each/@count/string()
                                order by $perf
                            return
                                <a
                                    class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                    href="{concat('#list-item-', $perf)}"><span>{
                                            if ($perf = 'unknown') then
                                                ('[unbekannt]')
                                            else
                                                ($perf)
                                        }</span>
                                    <span
                                        class="badge badge-jra badge-pill right">{$count}</span>
                                </a>
                        }
                    
                    </nav>
                    <div
                        data-spy="scroll"
                        data-target="#nav"
                        data-offset="70"
                        class="pre-scrollable col"
                        id="divResults">
                        {$worksGroupedByPerfRes}
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
    let $work := collection("/db/contents/jra/works")/mei:mei[@xml:id = $id]
    let $opus := $work//mei:workList//mei:title[@type = 'desc']/normalize-space(text())
    let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type = 'uniform' and @xml:lang = 'de']/normalize-space(text())
    
    return
        (
        <div
            class="container">
            <a
                href="../registryWorks.html">&#8592; zum Werkeverzeichnis</a>
            <br/>
            <div
                class="page-header">
                <br/>
                <h2>{$name}</h2>
                <h4>{$opus}</h4>
            </div>
            <br/>
            <div
                class="col-9">
                {transform:transform($work, doc("/db/apps/raffArchive/resources/xslt/metadataWork.xsl"), ())}
            </div>
        </div>
        )
};

declare function app:aboutProject($node as node(), $model as map(*)) {
    
    let $text := doc("/db/contents/jra/texts/portal/aboutProject.xml")/tei:TEI
    
    return
        (
        <div
            class="container">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        )
};

declare function app:aboutRaff($node as node(), $model as map(*)) {
    
    let $text := doc("/db/contents/jra/texts/portal/aboutRaff.xml")/tei:TEI
    
    return
        (
        <div
            class="container">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
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
        <div
            class="container">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
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

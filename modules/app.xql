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
                        else('0000-00-00')
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
                        else('0000-00-00')
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
                        else('0000-00-00')
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
                        else('0000-00-00')
                    )
                else('0000-00-00')
                
    return
        $get[number(substring(.,1,4)) <= number(substring(string(current-date()),1,4))-70]
};

declare function local:formatDate($dateRaw){
    if(string-length($dateRaw)=10 and not(contains($dateRaw,'00')))
                                              then(format-date(xs:date($dateRaw),'[D]. [M,*-3]. [Y]','de',(),()))
                                              else if($dateRaw='0000' or $dateRaw='0000-00' or $dateRaw='0000-00-00')
                                              then('[undatiert]')
                                              else if(string-length($dateRaw)=7 and not(contains($dateRaw,'00')))
                                              then (concat(upper-case(substring(format-date(xs:date(concat($dateRaw,'-01')),'[Mn,*-3]. [Y]','de',(),()),1,1)),substring(format-date(xs:date(concat($dateRaw,'-01')),'[Mn,*-3]. [Y]','de',(),()),2)))
                                              else if(contains($dateRaw,'0000-') and contains($dateRaw,'-00'))
                                              then (concat(upper-case(substring(format-date(xs:date(replace(replace($dateRaw,'0000-','9999-'),'-00','-01')),'[Mn,*-3].','de',(),()),1,1)),substring(format-date(xs:date(replace(replace($dateRaw,'0000-','9999-'),'-00','-01')),'[Mn,*-3].','de',(),()),2)))
                                              else if(starts-with($dateRaw,'0000-'))
                                              then(concat(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[D]. ','de',(),()),upper-case(substring(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[Mn,*-3]. ','de',(),()),1,1)),substring(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[Mn,*-3].','de',(),()),2)))
                                              else($dateRaw)
};

declare function local:getReferences($idToReference) {
    let $collectionReference := collection("/db/contents/jra/persons")//tei:TEI//@key[.=$idToReference] | collection("/db/contents/jra/institutions")//tei:TEI//@key[.=$idToReference] | collection("/db/contents/jra/texts")//tei:TEI//@key[.=$idToReference] | collection("/db/contents/jra/sources")//tei:TEI//tei:note[@type='regeste']//@key[.=$idToReference] | collection("/db/contents/jra")//mei:mei//@auth[.=$idToReference]
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
                            else('[Art]')
            let $correspActionSent := $docRoot//tei:correspAction[@type="sent"]
            let $correspActionReceived := $docRoot//tei:correspAction[@type="received"]
            let $correspSent := if($correspActionSent/tei:persName/text())
                                then($correspActionSent/tei:persName/text()[1])
                                else if($correspActionSent/tei:orgName/text())
                                then($correspActionSent/tei:orgName/text()[1])
                                else('[Unbekannt]')
            let $correspReceived := if($correspActionReceived/tei:persName/text())
                                    then($correspActionReceived/tei:persName/text()[1])
                                    else if($correspActionReceived/tei:orgName/text())
                                    then($correspActionReceived/tei:orgName/text()[1])
                                    else('[Unbekannt]')
            let $docDate := if(starts-with($docRoot/@xml:id,'A'))
                            then(local:getDate($docRoot//tei:correspAction[@type='sent']))
                            else(<br/>)
            let $docTitle := if(starts-with($docRoot/@xml:id,'A'))
                             then($correspSent,<br/>,'an ',$correspReceived)
                             else if($docRoot/name()='TEI')
                             then($docRoot//tei:titleStmt/tei:title/string())
                             else if($docRoot/name()='mei') 
                             then($docRoot//mei:titleStmt/mei:title/string())
                             else('noTitle')
            let $role := if(starts-with($docRoot/@xml:id,'C'))
                            then(if($docRoot//tei:person/tei:affiliation/text() and $docRoot//tei:person/tei:occupation/text())
                                 then(concat($docRoot//tei:person/tei:affiliation,', ',$docRoot//tei:person/tei:occupation))
                                 else if($docRoot//tei:person/tei:affiliation/text())
                                 then($docRoot//tei:person/tei:affiliation/text())
                                 else if($docRoot//tei:person/tei:occupation/text())
                                 then($docRoot//tei:person/tei:occupation/text())
                                 else()
                                 )
                            else if(starts-with($docRoot/@xml:id,'D'))
                            then($docRoot//tei:org/tei:desc/string())
                            else()
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
                                            <div class="col-3">{$docType}{if($docDate and starts-with($docRoot/@xml:id,'A'))
                                                                          then(' vom ',local:formatDate($docDate))
                                                                          else()}
                                                                          <br/>
                                                                          {if(starts-with($docRoot/@xml:id,'A') and $doc[./ancestor::tei:note])
                                                                           then(' (Regeste)')
                                                                           else()
                                            }</div>
                                            <div class="col">{$docTitle}&#160;<br/>{if($role)then(<span class="sublevel">{concat('(',$role,')')}</span>)else()}</div>
                                            <div class="col-2"><a href="{concat($href,$docID)}">{$docID/string()}</a></div>
                                        </div>
            order by $docID
            return
                $entry
};

declare function local:getCorrespondance($idToReference){
    let $correspondence := collection("/db/contents/jra/sources/documents/letters")//tei:TEI//@key[.=$idToReference][not(./ancestor::tei:note[@type='regeste'])]
    for $doc in $correspondence
        let $letter := $doc/ancestor::tei:TEI
        let $letterID := $letter/@xml:id/string()
        let $correspActionSent := $letter//tei:correspAction[@type="sent"]
        let $correspActionReceived := $letter//tei:correspAction[@type="received"]
        let $correspSent := if($correspActionSent/tei:persName/text())
                            then($correspActionSent/tei:persName/text()[1])
                            else if($correspActionSent/tei:orgName/text())
                            then($correspActionSent/tei:orgName/text()[1])
                            else('[Unbekannt]')
        (:let $correspSentId := if($correspActionSent/tei:persName/@key or $correspActionSent/tei:orgName/@key)
                              then($correspActionSent/tei:persName/@key | $correspActionSent/tei:orgName/@key)
                              else('noID'):)
        let $correspReceived := if($correspActionReceived/tei:persName/text())
                                then($correspActionReceived/tei:persName/text()[1])
                                else if($correspActionReceived/tei:orgName/text())
                                then($correspActionReceived/tei:orgName/text()[1])
                                else('[Unbekannt]')
        (:let $correspReceivedId := if($correspActionReceived/tei:persName/@key or $correspActionReceived/tei:orgName/@key)
                                  then($correspActionReceived/tei:persName/@key | $correspActionReceived/tei:orgName/@key)
                                  else('noID'):)
        let $date := local:getDate($correspActionSent)
        let $year := substring($date,1,4)
        let $dateFormatted := local:formatDate($date)
        
        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3">{$dateFormatted}</div>
                                <div class="col">{$correspSent}<br/>an {$correspReceived}</div>
                                <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                            </div>
        
            order by $date
        return
        $letterEntry
};

declare function app:registryLettersDate($node as node(), $model as map(*)) {

    let $letters := collection('/db/contents/jra/sources/documents/letters')//tei:TEI
    let $persons := collection('/db/contents/jra/persons')//tei:TEI
    let $institutions := collection('/db/contents/jra/institutions')//tei:TEI
    let $collection := ($persons, $institutions)
    let $lettersCrono := for $letter in $letters
                        let $letterID := $letter/@xml:id/data(.)
                        let $correspActionSent := $letter//tei:correspAction[@type="sent"]
                        let $correspActionReceived := $letter//tei:correspAction[@type="received"]
                        let $correspSent := if($correspActionSent/tei:persName[2]/text()) then(concat($correspActionSent/tei:persName[1]/text()[1],' und ',$correspActionSent/tei:persName[2]/text()[1])) else if($correspActionSent/tei:persName/text()) then($correspActionSent/tei:persName/text()[1]) else if($correspActionSent/tei:orgName/text()) then($correspActionSent/tei:orgName/text()[1]) else('[Unbekannt]')
                        let $correspReceived := if($correspActionReceived/tei:persName[2]/text()) then(concat($correspActionReceived/tei:persName[1]/text()[1],' und ',$correspActionReceived/tei:persName[2]/text()[1])) else if($correspActionReceived/tei:persName/text()) then($correspActionReceived/tei:persName/text()[1]) else if($correspActionReceived/tei:orgName/text()) then($correspActionReceived/tei:orgName/text()[1]) else ('[Unbekannt]')
                        let $date := local:getDate($correspActionSent)
                        let $year := substring($date,1,4)
                        let $dateFormatted := local:formatDate($date)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3" dateToSort="{if($date='0000-00-00')then(replace($date,'0000-','9999-'))else($date)}">{$dateFormatted}</div>
                                <div class="col">{$correspSent}<br/>an {$correspReceived}</div>
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
    
    return
        (<div class="container">
        <p>Der Katalog verzeichnet derzeit {count($letters)} Briefe.</p>
                  <!--  <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li class="nav-item"><a class="nav-link-jra active" href="#date">Datum</a></li>
                        <li class="nav-item"><a class="nav-link-jra" href="registryLettersReceiver.html">Empfänger</a></li>
                        <li class="nav-item"><a class="nav-link-jra" href="registryLettersSender.html">Absender</a></li>
                    </ul> -->
                    <br/>
            <div class="row" style="height: 500px;">
                <div class="col-10"> <!--  pre-scrollable -->
                    
                <!--    <div class="tab-content">
                        <div class="tab-pane fade show active" id="date"> -->
                            <br/>
                            <div
                                class="row">
                                <nav
                                    id="myScrollspy"
                                    class="col-md-3 col-sm-3 hidden-xs"> <!-- nav nav-pills nav-stacked pre-scrollable  -->
                                    <ul id="nav" style="height: 400px; overflow-y: auto;" class="nav nav-pills nav-stacked" data-spy="affix" data-offset-top="60">
                                    {
                                        for $year in $lettersGroupedByYears[@year !='']
                                        let $letterCount := $year/@count/string()
                                        let $letterYear := $year/@year/string()
                                            order by $year
                                        return
                                            <a class="list-group-item list-group-item-action justify-content-between d-flex  align-items-center" href="{concat('#list-item-', if($letterYear='[Jahr nicht ermittelbar]')then('unknown')else($letterYear))}"><!-- class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" -->
                                            <span>{
                                                        if ($letterYear = '[Jahr unbekannt]') then
                                                            ('[ohne Jahr]')
                                                        else
                                                            ($letterYear)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$letterCount}</span>
                                            </a>
                                    }
                                    </ul>
                                </nav>
                                <div
                                    class="col-md-9 col-sm-9"
                                    id="divResults"> <!-- pre-scrollable -->
                                    {$lettersGroupedByYears}
                                </div>
                            </div>
                            </div>
                            </div>
                          <!--  </div>
                            </div> -->
                            </div>
               
        )

};

declare function app:registryLettersSender($node as node(), $model as map(*)) {

    let $letters := collection('/db/contents/jra/sources/documents/letters')//tei:TEI
    let $persons := collection('/db/contents/jra/persons')//tei:TEI
    let $institutions := collection('/db/contents/jra/institutions')//tei:TEI
    let $collection := ($persons, $institutions)
    
    let $lettersSender := for $letter in $letters
                        let $letterID := $letter/@xml:id/data(.)
                        let $correspActionSent := $letter//tei:correspAction[@type="sent"]
                        let $correspActionReceived := $letter//tei:correspAction[@type="received"]
                       
                        let $correspSentId := if($correspActionSent/tei:persName/@key)
                                              then($correspActionSent/tei:persName/@key/string())
                                              else if($correspActionSent/tei:orgName/@key)
                                              then($correspActionSent/tei:orgName/@key/string())
                                              else()
                        
                        let $correspReceived := if($correspActionReceived/tei:persName/text())
                                                then($correspActionReceived/tei:persName/text()[1])
                                                else if($correspActionReceived/tei:orgName/text())
                                                then($correspActionReceived/tei:orgName/text()[1])
                                                else ('[Unbekannt]')
                        
                        let $senderNameRaw :=  if($correspActionSent/tei:persName)
                                              then($correspActionSent/tei:persName[1]/text()[1])
                                              else if($correspActionSent/tei:orgName)
                                              then($correspActionSent/tei:orgName[1]/text()[1])
                                              else()
                        let $senderName := for $data in $collection[range:eq(@xml:id,$correspSentId)]
                                               let $title := $data//tei:titleStmt/tei:title/string()
                                               return
                                                $title
                                                                   
                        let $date := local:getDate($correspActionSent)
                        let $year := substring($date,1,4)
                        let $dateFormatted := local:formatDate($date)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3" dateToSort="{$date}">{$dateFormatted}</div>
                                <div class="col">An {$correspReceived}</div>
                                <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                            </div>
                        group by $correspSentId
                        return
                            (<div sender="{distinct-values($senderName)}" senderId="{$correspSentId}" count="{count($letterEntry)}" xmlns="http://www.w3.org/1999/xhtml">
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
        (<div class="container">
            <div class="row">
                <div class="col-10">
                    <p>Der Katalog verzeichnet derzeit {count($letters)} Briefe.</p>
                    <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li class="nav-item"><a class="nav-link-jra active" href="registryLettersDate.html">Datum</a></li>
                        <li class="nav-item"><a class="nav-link-jra" href="registryLettersReceiver.html">Empfänger</a></li>
                        <li class="nav-item"><a class="nav-link-jra" href="#sender">Absender</a></li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane fade show active" id="sender">
                            <br/>
                            <div
                                class="row">
                                <nav
                                    id="myScrollspy"
                                    class="nav nav-pills navbar-fixed-top pre-scrollable col-4">
                                    <!--  -->
                                    {
                                        for $sender in $lettersGroupedBySenders
                                        let $letterCount := $sender/@count/string()
                                        let $letterSender := $sender/@sender/string()
                                        let $letterSenderId := $sender/@senderId/string()
                                            order by $letterSender
                                        return
                                            <a
                                                class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-',$letterSenderId)}"><span>{if($letterSenderId='none')then('[Unbekannt]')else($letterSender)}</span>
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
                            </div>
                            </div>
                    
        )

};

declare function app:registryLettersReceiver($node as node(), $model as map(*)) {

    let $letters := collection('/db/contents/jra/sources/documents/letters')//tei:TEI
    let $persons := collection('/db/contents/jra/persons')//tei:TEI
    let $institutions := collection('/db/contents/jra/institutions')//tei:TEI
    let $collection := ($persons, $institutions)
    
    let $lettersReceiver := for $letter in $letters
                        let $letterID := $letter/@xml:id/data(.)
                        let $correspActionSent := $letter//tei:correspAction[@type="sent"]
                        let $correspActionReceived := $letter//tei:correspAction[@type="received"]
                        
                        let $correspSent := if($correspActionSent/tei:persName/text())
                                            then($correspActionSent/tei:persName/text()[1])
                                            else if($correspActionSent/tei:orgName/text())
                                            then($correspActionSent/tei:orgName/text()[1])
                                            else ('[Unbekannt]')
                        let $correspReceivedId := if($correspActionReceived/tei:persName/@key)
                                              then($correspActionReceived/tei:persName/@key)
                                              else if($correspActionReceived/tei:orgName/@key)
                                              then($correspActionReceived/tei:orgName/@key)
                                              else()
                        
                        let $correspReceived := if($correspActionReceived/tei:persName/text())
                                                then($correspActionReceived/tei:persName/text()[1])
                                                else if($correspActionReceived/tei:orgName/text())
                                                then($correspActionReceived/tei:orgName/text()[1])
                                                else ('[Unbekannt]')
                        
                        let $receiverNameRaw :=  if($correspActionReceived/tei:persName)
                                              then($correspActionReceived/tei:persName[1]/text()[1])
                                              else if($correspActionReceived/tei:orgName)
                                              then($correspActionReceived/tei:orgName[1]/text()[1])
                                              else()
                        let $receiverName := for $data in $collection[range:eq(@xml:id,$correspReceivedId)]
                                               let $title := $data//tei:titleStmt/tei:title/string()
                                               return
                                                $title
                                              
                        let $date := local:getDate($correspActionSent)
                        let $year := substring($date,1,4)
                        let $dateFormatted := local:formatDate($date)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-3" dateToSort="{$date}">{$dateFormatted}</div>
                                <div class="col">An {$correspSent}</div>
                                <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                            </div>
                        group by $correspReceivedId
                        return
                            (<div receiver="{distinct-values($receiverName)}" receiverId="{$correspReceivedId}" count="{count($letterEntry)}" xmlns="http://www.w3.org/1999/xhtml">
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
                <div class="RegisterSortEntry" id="{concat('list-item-',$receiverId)}">
                                                    {$receiver}
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
                    <p>Der Katalog verzeichnet derzeit {count($letters)} Briefe.</p>
                    <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li class="nav-item"><a class="nav-link-jra active" href="registryLettersDate.html">Datum</a></li>
                        <li class="nav-item"><a class="nav-link-jra" href="#receiver">Empfänger</a></li>
                        <li class="nav-item"><a class="nav-link-jra" href="registryLettersSender.html">Absender</a></li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane fade show active" id="receiver">
                            <br/>
                       <div
                                class="row">
                                <nav
                                    id="myScrollspy"
                                    class="nav nav-pills navbar-fixed-top pre-scrollable col-4">
                                    <!--  -->
                                    {
                                        for $receiver in $lettersGroupedByReceivers
                                        let $letterCount := $receiver/@count/string()
                                        let $letterReceiver := $receiver/@receiver/string()
                                        let $letterReceiverId := $receiver/@receiverId/string()
                                            order by $letterReceiver
                                        return
                                            <a
                                                class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-',$letterReceiverId)}"><span>{if($letterReceiverId='none')then('[Unbekannt]')else($letterReceiver)}</span>
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
            <a class="back" onclick="history.back();">&#8592; zurück</a>
            <hr/>
            <div
                class="page-header">
                <br/>
                <h4>{$datumSent}</h4>
                <h2>Brief an {$nameTurned}</h2>
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

declare function app:registryPersons($node as node(), $model as map(*)) {
    
    let $persons := collection("/db/contents/jra/persons/")//tei:TEI
    
    let $personsAlpha := for $person in $persons
    let $persID := $person/@xml:id/string()
    let $initial := substring($person//tei:surname[@type = "used"][1], 1, 1)
    let $nameSurname := $person//tei:surname[@type = "used"][1]
    let $nameForename := $person//tei:forename[@type = "used"][1]
    let $nameAddName := $person//tei:addName[@type = "nick"][1]
    let $nameForeFull := if ($nameForename) then($nameForename) else if ($nameAddName and not($nameForename)) then ($nameAddName) else ()
    let $nameToJoin := if ($nameSurname != '') then($nameSurname, $nameForeFull) else if(not($nameAddName) and not($nameForename)) then($person//tei:titleStmt/tei:title) else ($nameForeFull)
    let $role := string-join($person//tei:roleName,' | ')
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
    let $birthFormatted := if(starts-with($birth,'-')) then(concat(substring(format-number(number($birth),'##.##;##.##'),2),' v. Chr.')) else($birth)
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
    let $nameToSort := distinct-values(replace(replace(replace($nameSurname,'ö','oe'),'ä','ae'),'ü','ue'))
    let $name := <div
        class="row RegisterEntry">
        <div
            class="col">
            {$nameJoined}
            {$lifeData}
            {
                if ($role) then
                    (<br/>, <span class="sublevel">({$role})</span>)
                else
                    ()
            }
            {
                if ($pseudonym) then
                    (<br/>, <span class="sublevel">(Pseudonym: {$pseudonym})</span>)
                else
                    ()
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
                let $order := distinct-values(replace(replace(replace($each,'ö','oe'),'ä','ae'),'ü','ue'))
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
    let $birthToSort := if (contains($birth,'/')) then(substring-before($birth,'/')) else($birth)
    let $birthFormatted := if(starts-with($birth,'-')) then(concat(substring(format-number(number($birth),'##.##;##.##'),2),' v. Chr.')) else($birth)
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
                    (<br/>, <span class="sublevel">({$role})</span>)
                else
                    ()
            }
            {
                if ($pseudonym) then
                    (<br/>, <span class="sublevel">(Pseudonym: {$pseudonym})</span>)
                else
                    ()
            }
        </div>
        <!--<div class="col-3"></div>-->
        <div
            class="col-2"><a  onclick="pleaseWait()"
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
                birth="{$birth}"
            count="{count($name)}">
            {
                for $each in $name
                let $order := distinct-values(replace(replace(replace($each,'ö','oe'),'ä','ae'),'ü','ue'))
                    order by $order
                return
                    $each
            }
        </div>)
    
    let $personsGroupedByBirth := for $groups in $personsBirth
        let $birthToSort := if (contains($groups/@birth/string(),'-')) then(substring($groups/@birth,1,5)) else($groups/@birth/number())
        group by $birth := $groups/@name/normalize-space(string())
(:        order by $sort ascending:)
    return
        (<div
            class="RegisterSortBox"
            birth="{$birth}" birthToSort="{translate($birthToSort,'/','_')}"
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
                    (<br/>, <span class="sublevel">({$role})</span>)
                else
                    ()
            }
            {
                if ($pseudonym) then
                    (<br/>, <span class="sublevel">(Pseudonym: {$pseudonym})</span>)
                else
                    ()
            }
        </div>
        <!--<div class="col-3"></div>-->
        <div
            class="col-2"><a onclick="pleaseWait()"
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
            death="{$death}"
            count="{count($name)}">
            {
                for $each in $name
                    let $order := distinct-values(replace(replace(replace($each,'ö','oe'),'ä','ae'),'ü','ue'))
                    order by $order
                return
                    $each
            }
        </div>)
    
    let $personsGroupedByDeath := for $groups in $personsDeath
        let $sort := if(contains($groups/@death,'/')) then(substring($groups/@death,1,4)) else($groups/@death/number())
        group by $death := $groups/@name/string()
        order by $sort
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
                        <!--<div
                            class="tab-pane fade show active"
                            id="alpha">
                            <br/>
                            <div
                                class="row" >
                                <nav 
                                    id="myScrollspy"
                                    class="nav nav-pills col-3 pre-scrollable">
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
                        </div> -->
                        <div
                            class="tab-pane fade show active"
                            id="birth">
                            <br/>
                            <div
                                class="row">
                                <nav
                                    id="myScrollspy" style="height:500px; overflow-y: auto;"
                                    class="nav nav-pills navbar-fixed-top col-3"> <!-- pre-scrollable style="overflow-y: auto;" -->
                                    {
                                        for $each in $personsGroupedByBirth
                                        let $birth := $each/@birth/string()
                                        let $birthToSort := $each/@birthToSort/string()
                                        let $count := $each/@count/string()
                                        order by $birthToSort
                                        return
                                            <a
                                                class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                                href="{concat('#list-item-', translate($birth, '/. ', '___'))}"><span>{
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
                                <div class="col pre-scrollable"
                                    id="divResults">
                                    {$personsGroupedByBirth}
                                </div>
                            </div>
                        </div>
                       <!-- <div
                            class="tab-pane fade"
                            id="death">
                            <br/>
                            <div
                                class="row">
                                <nav
                                    id="myScrollspy"
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

declare function app:person($node as node(), $model as map(*)) {
    
    let $id := request:get-parameter("person-id", "Fehler")
    let $person := collection("/db/contents/jra/persons")//tei:TEI[@xml:id = $id]
    let $name := $person//tei:title/normalize-space(data(.))
    let $letters := collection("/db/contents/jra/sources/documents/letters")//tei:TEI
    let $correspondence := $letters//tei:persName[@key = $id]/ancestor::tei:TEI
    let $literature := $person//tei:bibl[@type='links']
    let $vorkommen := collection("/db/contents/jra")//tei:persName[@key=$id]/ancestor::tei:TEI
    
    return
        (
        <div
            class="container">
            <button class="btn btn-jra" onclick="history.back();">&#8592; zurück</button>
            <hr/>
            <div
                class="page-header">
                <br/>
                <h2>{$name}</h2>
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
                            {if ($literature/text()!='') then(<li
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
                                if ($literature/text()!='') then
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
            <!--{
                if ($place) then
                    (concat('(', $place, ')'))
                else
                    ($place)
            }-->
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
                    let $order := distinct-values(replace(replace(replace($each,'ö','oe'),'ä','ae'),'ü','ue'))
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
            <!--{
                if ($places) then
                    (concat('(', $places, ')'))
                else if ($place = '')
                then('[unbekannt]')
                else ($place)
            }-->
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
            name="{if($place ='') then('[unbekannt]')else($place)}"
            count="{count($name)}">
            {
                for $each in $name
                    let $order := distinct-values(replace(replace(replace($each,'ö','oe'),'ä','ae'),'ü','ue'))
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
                        concat('list-item-', if ($place = '[unbekannt]') then
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
                                    id="myScrollspy"
                                    class="nav nav-pills navbar-fixed-top col-3 pre-scrollable">
                                    {
                                        for $each in $institutionsGroupedByPlaces
                                        let $place := if ($each/@place/string() = '[unbekannt]') then
                                            ('unknown')
                                        else ($each/@place/string())
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
    let $name := $institution//tei:title/normalize-space(data(.))
    let $letters := collection("/db/contents/jra/sources/documents/letters")//tei:TEI
    let $correspondence := $letters//tei:orgName[@key = $id]/ancestor::tei:TEI
    let $affiliates := $persons//tei:affiliation[@key = $id]/ancestor::tei:TEI
    let $literature := $institution//tei:bibl[@type='links']
    return
        (
        <div
            class="container">
            <button class="btn btn-jra" onclick="history.back();">&#8592; zurück</button>
            <hr/>
            <div
                class="page-header">
                <br/>
                <h2>{$name}</h2>
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
                            {if ($literature/text()!='') then(<li
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
                                if ($literature/text()!='') then
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
    let $initial := for $case in upper-case(substring($workName, 1, 1))
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
                        case '9' return '0–9'
                        default return $case 
    
    let $workID := $work/@xml:id/string()
    let $name := <div
        class="row RegisterEntry">
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
                  let $order := distinct-values(replace(replace(replace($each,'ö','oe'),'ä','ae'),'ü','ue'))
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
                   let $order := distinct-values(replace(replace(replace($each,'ö','oe'),'ä','ae'),'ü','ue'))
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
    let $worksPerfResPiano := for $perfRes in $perfRess[@auth='piano' and @solo='true']
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
                                    class="col-2"><a onclick="pleaseWait()"
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
                                         let $order := distinct-values(replace(replace(replace($each,'ö','oe'),'ä','ae'),'ü','ue'))
                    order by $order
                                        return
                                            $each
                                    }
                                </div>)
    
    let $worksGroupedByPerfResPiano := for $groups in $worksPerfResPiano
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
                            id="myScrollspy"
                            class="nav-pills col">
                            <li
                                class="nav-item nav-linkless-jra">Zählung</li>
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
                        id="myScrollspy"
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
                        id="myScrollspy"
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
                                            if ($year = '0000') then
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
                id="sortGenre">
                <ul
                class="nav nav-pills"
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
                </ul>
                <div class="tab-content">
                    <div
                        class="tab-pane fade show active"
                        id="vocalMusic">
                        <br/>
                        <div
                            class="row">
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
                            id="myScrollspy"
                            class="nav-pills col">
                            <li
                                class="nav-item nav-linkless-jra">Zählung</li>
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
                    </div>
                    <div
                        class="tab-pane fade"
                        id="stageMusic">
                        <br/>
                        <div
                            class="row">
                            Hier kommt die Bühnenmusik hin.
                        </div>
                    </div>
                    <div
                        class="tab-pane fade"
                        id="orchestralMusic">
                        <br/>
                        <div
                            class="row">
                            Hier kommt die Orchestermusik hin.
                        </div>
                    </div>
                    <div
                        class="tab-pane fade"
                        id="chamberMusic">
                        <br/>
                        <div
                            class="row">
                            Hier kommt die Kammermusik hin.
                        </div>
                    </div>
                    <div
                        class="tab-pane fade"
                        id="pianoMusic">
                        <br/>
                        <div
                            class="row">
                            <nav
                                id="myScrollspy"
                                class="nav nav-pills navbar-fixed-top col-2 pre-scrollable">
                                {
                                    for $each in $worksGroupedByPerfResPiano
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
                                {$worksGroupedByPerfResPiano}
                            </div>
                        </div>
                    </div>
                    <div
                        class="tab-pane fade"
                        id="arrangements">
                        <br/>
                        <div
                            class="row">
                            Hier kommten die Bearbeitungen hin.
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
            <button class="btn btn-jra" onclick="history.back();">&#8592; zurück</button>
            <hr/>
            <div
                class="page-header">
                <br/>
                <h2>{$name}</h2>
                <h5>{$opus}</h5>
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
                            <!--{if ($naming) then(-->
                            <li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#naming">Erwähnungen</a></li>
                                    <!--)else()}-->
                                    <li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#viewXML">XML-Ansicht</a></li>
                        </ul>
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
            <!--{
                                if ($naming/text()!='') then
                                    (-->
                                    <div
                                        class="tab-pane fade"
                                        id="naming">
                                        <br/>
                                        {
                                            <div class="pre-scrollable">
                                            {
                                                for $letter in $naming
                                                let $letterID := $letter/@xml:id/string()
                                                let $correspActionSent := $letter//tei:correspAction[@type="sent"]
                                                let $correspActionReceived := $letter//tei:correspAction[@type="received"]
                                                let $correspSent := if($correspActionSent/tei:persName/text()) then($correspActionSent/tei:persName/text()[1]) else if($correspActionSent/tei:orgName/text()) then($correspActionSent/tei:orgName/text()[1]) else('[Unbekannt]')
                                                (:let $correspSentId := if($correspActionSent/tei:persName/@key or $correspActionSent/tei:orgName/@key) then($correspActionSent/tei:persName/@key | $correspActionSent/tei:orgName/@key) else('noID'):)
                                                let $correspReceived := if($correspActionReceived/tei:persName/text()) then($correspActionReceived/tei:persName/text()[1]) else if($correspActionReceived/tei:orgName/text()) then($correspActionReceived/tei:orgName/text()[1]) else ('[Unbekannt]')
                                                (:let $correspReceivedId := if($correspActionReceived/tei:persName/@key or $correspActionReceived/tei:orgName/@key) then($correspActionReceived/tei:persName/@key | $correspActionReceived/tei:orgName/@key) else('noID'):)
                                                let $date := local:getDate($correspActionSent)
                                                let $year := substring($date,1,4)
                                                let $dateFormatted := local:formatDate($date) (:if(string-length($date)=10 and not(contains($date,'00')))
                                                                        then(format-date(xs:date($date),'[D]. [M,*-3]. [Y]','de',(),()))
                                                                        else if($date='0000' or $date='0000-00' or $date='0000-00-00')
                                                                        then('[undatiert]')
                                                                        else if(string-length($date)=7 and not(contains($date,'00')))
                                                                        then (concat(upper-case(substring(format-date(xs:date(concat($date,'-01')),'[Mn,*-3]. [Y]','de',(),()),1,1)),substring(format-date(xs:date(concat($date,'-01')),'[Mn,*-3]. [Y]','de',(),()),2)))
                                                                        else if(contains($date,'0000-') and contains($date,'-00'))
                                                                        then (concat(upper-case(substring(format-date(xs:date(replace(replace($date,'0000-','1492-'),'-00','-01')),'[Mn,*-3].','de',(),()),1,1)),substring(format-date(xs:date(replace(replace($date,'0000-','1492-'),'-00','-01')),'[Mn,*-3].','de',(),()),2)))
                                                                        else if(starts-with($date,'0000-'))
                                                                        then(concat(format-date(xs:date(replace($date,'0000-','1492-')),'[D]. ','de',(),()),upper-case(substring(format-date(xs:date(replace($date,'0000-','1492-')),'[Mn,*-3]. ','de',(),()),1,1)),substring(format-date(xs:date(replace($date,'0000-','1492-')),'[Mn,*-3].','de',(),()),2)))
                                                                        else($date):)
                                                
                                                let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                                                        <div class="col-3">{$dateFormatted}</div>
                                                                        <div class="col">{$correspSent}<br/>an {$correspReceived}</div>
                                                                        <div class="col-2"><a href="letter/{$letterID}">{$letterID}</a></div>
                                                                    </div>
                                                
                                                    order by $date
                                                return
                                                $letterEntry
                                                }
                                                </div>
                                    
                                         }
                                    </div>
                                    <!--)
                                else
                                    ()
                            }-->
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
            <button class="btn btn-jra" onclick="history.back();">&#8592; zurück</button>
            <hr/>
            <div
                class="page-header">
                <br/>
                <h2>{$title}</h2>
                <h5 class="sublevel">{$subtitle}</h5>
                <br/>
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
        <div
            class="container">
            <button class="btn btn-jra" onclick="history.back();">&#8592; zurück</button>
            <hr/>
            <div
                class="page-header">
                <br/>
                <h2>{$title}</h2>
                <h5 class="sublevel">{$subtitle}</h5>
                <br/>
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

declare function app:aboutDocumentation($node as node(), $model as map(*)) {
    
    let $text := doc("/db/contents/jra/texts/portal/aboutDocumentation.xml")/tei:TEI
    let $title := $text//tei:titleStmt/tei:title/string()
    let $subtitle := $text//tei:sourceDesc/tei:p[1]
    
    return
        (
        <div
            class="container">
            <button class="btn btn-jra" onclick="history.back();">&#8592; zurück</button>
            <hr/>
            <div
                class="page-header">
                <br/>
                <h2>{$title}</h2>
                <h5 class="sublevel">{$subtitle}</h5>
                <br/>
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
            <button class="btn btn-jra" onclick="history.back();">&#8592; zurück</button>
            <hr/>
            <div
                class="page-header">
                <br/>
                <h2>{$title}</h2>
                <h5 class="sublevel">{$subtitle}</h5>
                <br/>
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
        <div
            class="container">
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

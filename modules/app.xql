xquery version "3.0";

module namespace app="http://baumann-digital.de:8080/exist/apps/raffArchive/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://baumann-digital.de:8080/exist/apps/raffArchive/config" at "config.xqm";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace functx = "http://www.functx.com";

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

declare function app:registryLetters($node as node(), $model as map(*)) {

    let $letters := collection("/db/contents/jra/sources/documents/letters?select=*.xml;recurse=yes")//tei:TEI
    let $dates := for $letter in $letters
        let $date := 
        if(exists($letter//tei:correspAction[@type="sent"]/tei:date[@type="source" and 1]/@when))
        then($letter//tei:correspAction[@type="sent"]/tei:date[@type="source" and 1]/@when)
        else if(exists($letter//tei:correspAction[@type="sent"]/tei:date[@type="source" and 1]/@when-custom))
        then($letter//tei:correspAction[@type="sent"]/tei:date[@type="source" and 1]/@when-custom)
        else()
        return $date
    let $yearsAll := for $date in $dates
                    let $yearsSubstring := substring($date,1,4)
                    return
                    $yearsSubstring
    let $year := let $yearDistinct := distinct-values($yearsAll)
                 for $yearEach in $yearDistinct
                 order by $yearEach
                 return
                    $yearEach
    
return
(
   <div class="container">
      <p>Das lettersverzeichnis enthält zur Zeit {count($letters)} letters.</p>
        <ul class="nav nav-tabs" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#letters">Chronologie</a></li>  
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#RegAdressaten">Register: Adressaten</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#RegAbsender">Register: Absender</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#todo">ToDos</a></li>
    </ul>
    <div class="tab-content">
        <div class="tab-pane fade show active" id="letters" >
        <br/>
        <div class="row">
        <div class="col-2">
        <div data-spy="scroll" id="list-letters" class="list-group pre-scrollable">
        {for $items in $year
        order by $items
        return
        <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="{concat('#list-item-',$items)}"><span>{if($items='0000')then('ohne Jahr')else($items)}</span><span class="badge badge-primary badge-pill right">{count($yearsAll[contains(.,$items)])}</span></a>
        }
        </div>
        </div>
        <div data-spy="scroll" data-target="#list-letters" data-offset="0" class="pre-scrollable col">
        <ul>
        {for $items in $year
        order by $items ascending
        return
        (<h5 id="{concat('list-item-',$items)}">{if($items='0000')then('ohne Jahr')else($items)}</h5>,
        let $lettersToProcess := $letters//tei:correspAction[@type="sent"]/tei:date[@type="source" and 1 and contains(substring(data(.),1,4),$items)]/ancestor::tei:TEI
        for $letter in $lettersToProcess
        let $absenderPers := $letter//tei:correspAction[@type="sent"]/tei:persName[1]/text()[1]
        let $absenderOrg := $letter//tei:correspAction[@type="sent"]/tei:orgName[1]/text()[1]
        let $absender := if(exists($absenderPers))then($absenderPers)else if(exists($absenderOrg))then($absenderOrg)else()
        let $adressatPers := $letter//tei:correspAction[@type="received"]/tei:persName[1]/text()[1]
        let $adressatOrg := $letter//tei:correspAction[@type="received"]/tei:orgName[1]/text()[1]
        let $adressat := if(exists($adressatPers))then($adressatPers)else if(exists($adressatOrg))then($adressatOrg)else()
        let $datumSentWhen := $letter//tei:correspAction[@type="sent"]/tei:date[@type="source" and 1]/@when
        let $datumSentWhenCustom := $letter//tei:correspAction[@type="sent"]/tei:date[@type="source" and 1]/@when-custom
        let $datumSentFrom := $letter//tei:correspAction[@type="sent"]/tei:date[@type="source" and 1]/@from
        let $datumSentFromCustom := $letter//tei:correspAction[@type="sent"]/tei:date[@type="source" and 1]/@from-custom
        let $datumSentNotBefore := $letter//tei:correspAction[@type="sent"]/tei:date[@type="source" and 1]/@notBefore
        (:let $datumReceived := $letter//tei:correspAction[@type="received"]/tei:date/@when:)
        let $id := $letter/@xml:id
        let $datumSent := if(exists($datumSentWhen))
                          then($datumSentWhen)
                          else if(exists($datumSentWhenCustom))
                          then($datumSentWhenCustom)
                          else if(exists($datumSentFrom))
                          then($datumSentFrom)
                          else if(exists($datumSentFromCustom))
                          then($datumSentFromCustom)
                          else if(exists($datumSentNotBefore))
                          then($datumSentNotBefore)
                          else()
        let $yearSelect := substring($datumSent,1,4)
            let $yearSelectIfthen := if($yearSelect='0000')then('[o.J.]')else($yearSelect)
            let $monthSelect := substring($datumSent,6,2)
            let $monthSelectIfthen := if ($monthSelect = '01') then
                        ('Jan.')
                        else
                        if ($monthSelect = '02') then
                        ('Feb.')
                        else
                        if ($monthSelect = '03') then
                        ('Mrz.')
                        else
                        if ($monthSelect = '04') then
                        ('Apr.')
                        else
                        if ($monthSelect = '05') then
                        ('Mai')
                        else
                        if ($monthSelect = '06') then
                        ('Jun.')
                        else
                        if ($monthSelect = '07') then
                        ('Jul.')
                        else
                        if ($monthSelect = '08') then
                        ('Aug.')
                        else
                        if ($monthSelect = '09') then
                        ('Sep.')
                        else
                        if ($monthSelect = '10') then
                        ('Okt.')
                        else
                        if ($monthSelect = '11') then
                        ('Nov.')
                        else
                        if ($monthSelect = '12') then
                        ('Dez.')
                        else
                        ('[o.M.]')
            let $daySelect := substring($datumSent,9,2)
            let $daySelectIfthen := if($daySelect='')then()else if(substring($daySelect,1,1)='0')then(concat(substring($daySelect,2,1),'. '))else(concat($daySelect,'. '))
            
            let $dateTurned := concat($daySelectIfthen,$monthSelectIfthen,' ',$yearSelectIfthen)
        
        
        order by $datumSent
        return
        (
        <li>{concat($dateTurned,' – ',if(exists($absender))then($absender)else('[unbekannt]'),' an ',if(exists($adressat))then($adressat)else('[unbekannt]'))} <span> </span> (ID: <a href="letter/{$id}">{$id/normalize-space(data(.))}</a>)</li>),<br/>,<span/>
        )
        }
        </ul>
        </div>
        </div>
        </div>
        <div class="tab-pane fade" id="RegAdressaten" >
        
        <p><ul>{
      let $valuesRec := distinct-values($letters//tei:correspAction[@type="received"]/tei:persName/text()[1])
      for $valueRec in $valuesRec
      order by $valueRec
      return
      <li>{$valueRec}</li>
        }</ul>
        </p>
        </div>
        <div class="tab-pane fade" id="RegAbsender" >
        
      <p><ul>{
      let $valuesSent := distinct-values($letters//tei:correspAction[@type="sent"]/tei:persName/text()[1])
      for $valueSent in $valuesSent
      order by $valueSent
      return
      <li>{$valueSent}</li>
        }</ul>
        </p>
        </div>
        <div class="tab-pane fade" id="todo" >
        <p>
        <ul>
        <li>Register Adressaten Besser durchsuchbar machen</li>
        <li>Register Absender Besser durchsuchbar machen</li>
        <li>letters nach Absender ordnen</li>
        <li>letters nach Adressaten ordnen</li>
        <li>Scrollfunktion verbessern!</li>
        </ul>
        </p>
        </div>
   </div>
      </div>
)

};

declare function app:letter($node as node(), $model as map(*)) {

let $id := request:get-parameter("letter-id", "Fehler")
let $letter := collection("/db/contents/jra/sources/documents/letters")/tei:TEI[@xml:id=$id]
let $absender := $letter//tei:correspAction[@type="sent"]/tei:persName[1]/text()[1]
let $datumSent := $letter//tei:correspAction[@type="sent"]/tei:date[@type="source" and 1]/@when
let $adressat := $letter//tei:correspAction[@type="received"]/tei:persName[1]/text()[1]

return
(
<div class="container">
    <div class="page-header">
        <a href="../registryLetters.html">&#8592; zum Briefeverzeichnis</a>
            <h2>letter an {$adressat}</h2>
            <h4>Datum: {string($datumSent)}</h4>
            <h4>Absender: {$absender}</h4>
            <h6>ID: {$id}</h6>
    </div>
     <ul class="nav nav-tabs" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#metadata">Metadaten</a></li>  
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#xmlAnsicht">XML-Ansicht</a></li>
    </ul>
    <div class="tab-content">
        <div class="tab-pane fade show active" id="metadaten" >
            <br/>
            <div class="row">
                {transform:transform($letter//tei:teiHeader,doc("/db/apps/raffArchive/resources/xslt/metadataLetter.xsl"), ())}
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

    let $persons := collection("/db/contents/jra/persons")//tei:TEI
  (:  let $namedPersonsDist := functx:distinct-deep(collection("/db/contents/jra/sources")//tei:text//tei:persName[normalize-space(.)])
    let $namedPersons := collection("/db/contents/jra/sources")//tei:text//tei:persName[normalize-space(.)] :)
    
return
(
<div class="container">
    <!--<ul class="nav nav-pills" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#tab1">personsdateien</a></li>  
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#tab2">Alle Erwähnungen</a></li>
    </ul>
    <div class="tab-content">-->
    <!--<div class="tab-pane fade show active" id="tab1">-->
    <br/>
        <p>In diesem Verzeichnis sind zur Zeit {count($persons)} Personen erfasst.</p>
      <ul>
        {
        for $person in $persons
        let $name := $person//tei:title
        let $id := $person/@xml:id
        order by $name
        return
        <li>{$name/normalize-space(data(.))} (ID: <a href="person/{$id}">{$id/normalize-space(data(.))}</a>)</li>
        }
      </ul>
    <!--</div>
    <div class="tab-pane fade" id="tab2">
        <p>Alle Vorkommen von Personen in alphabetischer Reihenfolge</p>
         <ul>
        {
        for $persName in $namedPersons
        let $persNameDist := $persName/normalize-space(data(.))
        let $Quelle := $persName/ancestor::tei:TEI/@xml:id/data(.)
        order by lower-case($persNameDist)
        return
        <li>{$persNameDist} (in: <b>{concat($Quelle,'.xml')}</b>)</li>
        }
      </ul>
        </div>
        </div>-->
    </div>
)
};

declare function app:person($node as node(), $model as map(*)) {
 
let $id := request:get-parameter("person-id", "Fehler")
let $person := collection("/db/contents/jra/persons")/tei:TEI[@xml:id=$id]
let $name := $person//tei:title/normalize-space(data(.))
let $namedPersons := collection("/db/contents/jra/sources")//tei:text//tei:persName[@key=$id]
let $namedPersonsDist := functx:distinct-deep(collection("/db/contents/jra/sources")//tei:text//tei:persName[@key=$id])

return
(
<div class="row">
    <div class="page-header">
        <a href="http://baumann-digital.de:8080/exist/apps/raffArchive/html/registryPersons.html">&#8592; zum Personenverzeichnis</a>
        <h1>{$name}</h1>
        <h5>ID: {$id}</h5>
    </div>
    <div class="container">
          <ul class="nav nav-pills" role="tablist">
            <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#metadaten">Metadaten</a></li>
            <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#xmlAnsicht">XML-Ansicht</a></li>
            <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#named">Erwähnungen</a></li>
          </ul>
          <div class="tab-content">
          <br/>
            <div class="tab-pane fade show active" id="metadaten">
                {transform:transform($person,doc("/db/apps/raffArchive/resources/xslt/metadataPerson.xsl"), ())}
                <br/>
                {transform:transform($person,doc("/db/apps/raffArchive/resources/xslt/contentPerson.xsl"), ())}
            </div>
            <div class="tab-pane fade" id="named" >
                <ul>
                {
                    for $persName in $namedPersons
                    let $persNameDist := $persName/normalize-space(data(.))
                    let $Quelle := $persName/ancestor::tei:TEI/@xml:id/data(.)
                    order by lower-case($persNameDist)
                    return
                    <li>{$persNameDist} (in: <b>{concat($Quelle,'.xml')}</b>)</li>
                    }
                </ul>
            </div>
            <div class="tab-pane fade" id="xmlAnsicht" >
                <pre class="pre-scrollable">
                    <xmp>
                        {transform:transform($person,doc("/db/apps/raffArchive/resources/xslt/viewXML.xsl"), ())}
                    </xmp>
                </pre>
            </div>
        </div>
    </div>
</div>
)
};


declare function app:registryWorks($node as node(), $model as map(*)) {
    
    let $works := collection("/db/contents/jra/works?select=*.xml;recurse=yes")/mei:mei
    
    let $content := <div class="container">
    <br/>
    <ul class="nav nav-pills" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#alpha">Von A-Z</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#chrono">Chronologisch</a></li>
    </ul>
    <!-- Tab panels -->
    <div class="tab-content">
        <div class="tab-pane fade show active" id="alpha">
        <br/>
            <ul>
        {
        for $work in $works
        let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/normalize-space(text())
        
        let $id := $work/@xml:id/normalize-space(data(.))
        order by $name ascending
        return
            <li>
                {$name} (ID: <a href="work/{$id}">{$id}</a>)<br/>
            </li>
        }
            </ul>
        </div>
        <div class="tab-pane fade show" id="chrono">
        <br/>
            <ul>
        {
        for $work in $works
        let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/normalize-space(text())
        let $dateComposition := $work//mei:date[@type="composition" and 1]
        
        let $id := $work/@xml:id/normalize-space(data(.))
        order by $dateComposition ascending
        return
            <li>
                {$name} (ID: <a href="work/{$id}">{$id}</a>)<br/>
            </li>
        }
            </ul>
            </p>
        </div>
        </div>
   </div>
       return $content
       };
       
declare function app:work($node as node(), $model as map(*)) {

let $id := request:get-parameter("work-id", "Fehler")
let $work := collection("/db/contents/jra/works")/mei:mei[@xml:id=$id]
let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/normalize-space(text())

return
(
    <div class="container">
        <a href="../registryWorks.html">&#8592; zum Werkeverzeichnis</a>
        <br/>
        <div class="page-header">
            <h1>{$name}</h1>
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

declare function app:raffAbout($node as node(), $model as map(*)) {

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

(:declare function app:guidelines($node as node(), $model as map(*)) {

let $codingGuidelines := doc('/db/contents/jra/texts/documentation/codingGuidelines.xml')
let $editiorialGuidelines := doc('/db/contents/jra/texts/documentation/editorialGuidelines.xml')
let $sourceDescGuidelines := doc('/db/contents/jra/texts/documentation/sourceDescGuidelines.xml')

return
(
<div class="container">
        <ul class="nav nav-pills" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#coding">Kodierung</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#edition">Edition</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#sourceDesc">Quellenbeschreibung</a></li>
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

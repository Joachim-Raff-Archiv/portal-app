xquery version "3.0";

module namespace app="http://localhost:8080/exist/apps/raffArchive/templates";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/raffArchive/config" at "config.xqm";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace functx = "http://www.functx.com";
declare namespace http = "http://expath.org/ns/http-client";

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
        <input type="text" id="myInput" onkeyup="myFilter()" placeholder="Search for names.." title="Type in a name"/>
<br/>
<ul id="myUL">
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
        let $letterSmall := <li xmlns="http://www.w3.org/1999/xhtml" dateToOrder='{$dateSecured}'>{if(string-length($dateSecured)=10 and not(contains($date,'00')))then(format-date(xs:date($dateSecured),'[D]. [M,*-3]. [Y]','de',(),()))else($dateSecured)} – {$correspSent} an {$correspReceived}<span/> (ID: <a href="letter/{$letterID}">{$letterID}</a>)</li>

group by $year := if(not($dateSecured) or contains(substring($dateSecured,1,4),'0000'))
                      then('noYear')
                      else
                      if(not(contains(substring($dateSecured,1,4),'-')))then(substring($dateSecured,1,4))else($dateSecured)
    order by $year
    return
        (
        <p year="{$year}" letterCount="{count($letterSmall)}" xmlns="http://www.w3.org/1999/xhtml">
            <h5 id="{concat('list-item-',$year)}">{if($year='noYear')then('ohne Jahr')else($year)}</h5>
            <ul>
            {for $each in $letterSmall
                let $order := $each/@dateToOrder
                order by $order
                return $each}
                </ul>
        </p>)
        
return
(   <div class="container">
        <p>Das Briefeverzeichnis enthält zur Zeit {count($letters)} Briefe.</p>
        <ul class="nav nav-tabs" role="tablist">
            <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#letters">Chronologie</a></li>  
            <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#RegAdressaten">Register: Adressaten</a></li>
            <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#RegAbsender">Register: Absender</a></li>
        </ul>
    <div class="tab-content">
        <div class="tab-pane fade show active" id="letters">
        <br/>
        <div class="row">
        <div class="col-2">
        <div data-spy="scroll" id="list-letters" class="list-group pre-scrollable">
        {for $year in $lettersGroupedByYears/@year
        let $letterCount := $year/parent::xhtml:p/@letterCount/data(.)
        let $letterYear := $year/data(.)
        order by $year
        return
        <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="{concat('#list-item-',$year)}"><span>{if($year='noYear')then('ohne Jahr')else($letterYear)}</span>
        <span class="badge badge-primary badge-pill right">{$letterCount}</span></a>
        }
        </div>
      </div>
     <div data-spy="scroll" data-target="#list-letters" data-offset="0" class="pre-scrollable col">
        {$lettersGroupedByYears}
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
   </div>
      </div>
)
    
};

declare function app:letter($node as node(), $model as map(*)) {

let $id := request:get-parameter("letter-id", "Fehler")
let $letter := collection("/db/contents/jra/sources/documents/letters")/tei:TEI[@xml:id=$id]
let $absender := $letter//tei:correspAction[@type="sent"]/tei:persName[1]/text()[1]
let $datumSent := $letter//tei:correspAction[@type="sent"]/tei:date[@type='source' and 1]/@when
let $adressat := $letter//tei:correspAction[@type="received"]/tei:persName[1]/text()[1]

return
(
<div class="container">
    <div class="page-header">
        <a href="../registryLetters.html">&#8592; zum Briefeverzeichnis</a>
            <h2>Brief an {$adressat}</h2>
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
        <div>
        <img src="http://daten.digitale-sammlungen.de/0010/bsb00107735/images/bsb00107735_00001.jpg" class="img-thumbnail" width="400"/></div>
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
                                           ( <h5 id="{concat('list-item-',if($groups/@name/string()='')then('unknown')else($groups/@name/string()))}">
                                                {if($groups/@name/string()='')then('[unbekannt]')else($groups/@name/string())}
                                            </h5>,
                                                    for $group in $groups
                                                        return
                                                            $group
                                           )

(: {
        for $person in $persons
        let $name := $person//tei:title
        let $id := $person/@xml:id
        order by $name
        return
        <li>{$name/normalize-space(data(.))} (ID: <a href="person/{$id}">{$id/normalize-space(data(.))}</a>)</li>:)
        
return

<div class="container" xmlns="http://www.w3.org/1999/xhtml">
    <br/>
        <p>In diesem Verzeichnis sind aktuell {count($persons)} Personen erfasst.</p>
            <ul class="nav nav-tabs" id="myTab" role="tablist">
               <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#tab1">Alphabetisch</a></li>  
               <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#tab2">Alle Erwähnungen</a></li>
            </ul>
        <div class="tab-pane fade show active" id="tab1">
        <br/>
            <div class="row">
                <div class="col-2">
                    <div data-spy="scroll" id="list-persons" class="list-group pre-scrollable">
                        {for $person in $persons
                            let $initial := if($person//tei:surname[@type="used"]='')then('unknown')else(substring($person//tei:surname[@type="used"],1,1))
                            group by $initial
                            order by $initial
                            return
                                <li class="nav-item" xmlns="http://www.w3.org/1999/xhtml">
                                    <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="{concat('#list-item-',$initial)}">
                                        <span>{if($initial='unknown')then('[unbekannt]')else($initial)}</span>
                                        <span class="badge badge-primary badge-pill right">{count($person[substring(.//tei:surname[@type="used"],1,1)=$initial])}</span>
                                    </a>
                                </li>
                        }
                    </div>
                </div>
                <div data-spy="scroll" data-target="#list-persons" data-offset="0" class="pre-scrollable col">
                    {$personsGroupedByInitials}
                </div>
            </div>
        </div>
        <div class="tab-pane fade" id="tab2">
            no content
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
                  <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#metadaten">Metadaten</a></li>
                  {if($personNaming)then(<li class="nav-item"><a class="nav-link" data-toggle="tab" href="#named">Erwähnungen</a></li>)else()}
                  <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#xmlAnsicht">XML-Ansicht</a></li>
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
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#sortOpus">Opera</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#sortWoO">WoOs</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#sortTitle">Titel</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#sortDate">Chronologie</a></li>
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#sortPerfRes">Besetzung</a></li>
    </ul>
    <!-- Tab panels -->
    <div class="tab-content">
    <div class="tab-pane fade" id="sortOpus">
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
        <div class="tab-pane fade show active" id="sortPerfRes">
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

declare function app:tests($node as node(), $model as map(*)) {

let $collection := collection('/db/contents/jra/persons')
let $gndNos := (:'1091567573':) $collection//tei:TEI//tei:idno[@type="GND"]
(:for $gndNo in $gndNos:)
let $data := <div class="container"><table><tr> <td>Pos. (Abfrage)</td><td>Identifikationsnummer</td><td>GND (eingetragen)</td>
                        <td>URL</td><td>Test</td></tr>{

                for $item at $n in $gndNos
(:                    where $n < 20:)
                    
                    let $itemString := $item/normalize-space(string())
                    let $urlGND := concat('http://d-nb.info/gnd/',$itemString)
                    let $request := http:send-request(<http:request href="{$urlGND}" method="GET"/>)
                    let $test := exists($request//@status[string()='404'])
                    
                    where $test = true()
                    let $id := $item/ancestor::tei:TEI/@xml:id/string()
                    let $result := if($test = true())then('Existiert nicht!')else()
(:                    let $data := if(not($test = true()))then(doc($urlGND))else():)
(:                    let $dataLink := if(not($test = true()))then($data//xhtml:h1[@class="nameID" and contains(text(),'Permalink:')]/substring-after(text(),': '))else():)
(:                    let $dataRedirect := if(not($test = true()))then(doc(concat('https://viaf.org',$dataLink)))else():)
(:                    let $VIAFid := if($dataRedirect='')then('Problem')else($dataRedirect//xhtml:head/xhtml:title/string()):)
                    
                    order by $result,$id
                    return
                        (<tr>
                            <td>{$n}</td>
                            <td>{$id}</td>
                            <td>{$itemString}</td>
                            <td>{$urlGND}</td>
                            <td>{$result}</td>
                        </tr>)
                         
               }</table>
              </div>
return
    $data
};
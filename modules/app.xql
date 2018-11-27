xquery version "3.0";

module namespace app="http://localhost:8080/exist/apps/baudi/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/baudi/config" at "config.xqm";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace functx = "http://www.functx.com";
(:declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";:)


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
 
declare function app:briefe($node as node(), $model as map(*)) {
   
    let $briefe := collection("/db/contents/sources/documents/letters")//tei:TEI
    let $datum := $briefe//tei:correspAction[@type="sent"]//tei:date/@when/xs:date(.)
    let $datum-first := min($datum)
    let $datum-last := max($datum)

(:
    TODO:
    - filtern nach absender, empfänger, datum  
:)
return
(
    <div class="container">
      <p>Das Briefverzeichnis enthält zur Zeit { count($briefe) } transkribierte Briefe.</p>
      <p>Die erfassten Briefe wurden in den Jahren {
        substring($datum-first,1,4)
        } bis {
        substring($datum-last,1,4)
        } geschrieben.</p>
        
        <ul class="nav nav-pills" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#briefe">Briefe</a></li>  
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#adressaten">Adressaten</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#absender">Absender</a></li>
    </ul>
    <!-- Tab panels -->
    <div class="tab-content">
        <div class="tab-pane fade show active" id="briefe" >
        <br/>
        {
        for $brief in $briefe
        let $titel := $brief//tei:fileDesc/tei:titleStmt/tei:title
        let $id := $brief/@xml:id
        let $datumSent := $brief//tei:correspAction[@type="sent"]/tei:date/@when
        order by $datumSent
        return
        <li><a href="brief/{$id}">{$titel/normalize-space(data(.))}</a> <span> </span> ({$id/normalize-space(data(.))})</li>
        }
      
        </div>
        <div class="tab-pane fade" id="adressaten" >
        
        <p><ul>{
      let $valuesRec := distinct-values($briefe//tei:correspAction[@type="received"]/tei:persName[@key])
      for $valueRec in $valuesRec
      order by $valueRec
      return
      <li>{$valueRec}</li>
        }</ul>
        </p>
        </div>
        <div class="tab-pane fade" id="absender" >
        
      <p><ul>{
      let $valuesSent := distinct-values($briefe//tei:correspAction[@type="sent"]/tei:persName/normalize-space(data(.)))
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

declare function app:brief($node as node(), $model as map(*)) {

let $id := request:get-parameter("brief-id", "Fehler")
let $brief := collection("/db/contents/sources/documents/letters")/tei:TEI[@xml:id=$id]
let $pages := $brief/tei:text/tei:body/tei:div[@type='page']/@n/normalize-space(data(.))

return
(
<div class="container">
    <div class="page-header">
        <a href="../briefverzeichnis.html">&#8592; zum Briefverzeichnis</a>
            <h1>{$brief//tei:fileDesc/tei:titleStmt/tei:title/normalize-space(data(.))}</h1>
            <h5>{$id}</h5>
    </div>
 <ul class="nav nav-pills" role="tablist">
    <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#datenblatt" role="tab" aria-controls="home" aria-selected="true">Datenblatt</a></li>
    { 
        for $tab in $pages
        let $tabCounted := $tab
        let $tabID := concat('#seite-',$tabCounted)
        
        return
    <li class="nav-item"><a class="nav-link" data-toggle="tab" href="{$tabID}" role="tab" aria-controls="{$tabCounted}" aria-selected="false">[Seite {$tabCounted}]</a></li>
    }
  </ul>
    <!-- Tab panels -->
    <div class="tab-content">
    <div class="tab-pane fade show active" id="datenblatt" role="tabpanel">
        {transform:transform($brief//tei:teiHeader,doc("/db/apps/baudi/resources/scripts/briefDatenblatt.xsl"), ())}
    </div>
    
    {if (count($pages)=1)
    then(
    <div class="tab-pane fade" id="seite-1" role="tabpanel">
    <div class="row">
        <div class="col">
            <br/>
                <div class="col">
                <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#bigPicture">
  Vollansicht
</button>
</div>
                <br/><br/>
                <img src="{
                if (exists($brief//tei:div[@type='page' and @n='1' and @facs]))
                then(concat('../../../baudi-images/documents/',$brief//tei:div[@type='page' and @n='1']/@facs))
                else(concat('../../../baudi-images/documents/',$id,'-1','.jpeg'))}" class="img-thumbnail" width="400"/>
            </div>
        <div class="col">
                <br/>
                <strong>Transkription</strong>
                <br/><br/>
                {transform:transform($brief//tei:div[@type='page' and @n='1'],doc("/db/apps/baudi/resources/scripts/brief.xsl"), ())}
        </div>
        <!-- Modal -->
    <div class="modal fade bd-example-modal-lg" id="bigPicture" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
  <div class="modal-header">
        <h5 class="modal-title" id="exampleModalCenterTitle">Seite 1 von 1</h5>
      </div>
      <div class="modal-body">
        <img src="{
                if (exists($brief//tei:div[@type='page' and @n='1' and @facs]))
                then(concat('../../../baudi-images/documents/',$brief//tei:div[@type='page' and @n='1']/@facs))
                else(concat('../../../baudi-images/documents/',$id,'-1','.jpeg'))}" class="img-thumbnail"/>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-dismiss="modal">Zurück</button>
      </div>
    </div>
  </div>
</div>
        </div>
    </div>
    )
    else(
        for $page in $pages
        let $briefOrigFacs := concat('../../../baudi-images/documents/',$brief//tei:div[@type='page' and @n=$page]/@facs)
        let $briefOrigLink := concat('../../../baudi-images/documents/',$id,'-',$page,'.jpeg')
     
        return
        
    <div class="tab-pane fade" id="{concat('seite-',$page)}" role="tabpanel">
    <div class="row">
        <div class="col">
                <br/>
                <div class="col">
                <button type="button" class="btn btn-primary" data-toggle="modal" data-target="{concat('#bigPicture',$page)}">
  Vollansicht
</button>
</div>
                <br/><br/>
                <img src="{if (exists($brief//tei:div[@type='page' and @n=$page and @facs])) then($briefOrigFacs) else($briefOrigLink)}" class="img-thumbnail" width="400"/>
       </div>
        <div class="col">
                <br/>
                <strong>Transkription</strong>
                <br/><br/>
                {transform:transform($brief//tei:div[@type='page' and @n=$page],doc("/db/apps/baudi/resources/scripts/brief.xsl"), ())}
       </div>
<!-- Modal -->
    <div class="modal fade bd-example-modal-lg" id="{concat('bigPicture',$page)}" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
  <div class="modal-header">
        <h5 class="modal-title" id="exampleModalCenterTitle">{concat('Seite ',$page,' von ',count($pages))}</h5>
      </div>
      <div class="modal-body">
        <img src="{if (exists($brief//tei:div[@type='page' and @n=$page and @facs])) then($briefOrigFacs) else($briefOrigLink)}" class="img-thumbnail"/>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-dismiss="modal">Zurück</button>
      </div>
    </div>
  </div>
</div>
    </div>
    </div>
        )
        }
  </div>
  </div>
)
};

declare function app:dokumente($node as node(), $model as map(*)) {
   
    let $dokumente := collection("/db/contents/sources/documents")//tei:TEI[@type='certificate' or @type='Bericht']
    let $datum := $dokumente//tei:correspAction[@type="sent"]//tei:date/@when/xs:date(.)
    let $datum-first := min($datum)
    let $datum-last := max($datum)
(:    order by $title :)

return
    <div class="container">
      <p>Das Dokumentenverzeichnis enthält zur Zeit { count($dokumente) } Inhalte.</p>
      <p>Die erfassten Schriften wurden in den Jahren {
        substring($datum-first,1,4)
        } bis {
        substring($datum-last,1,4)
        } verfasst.</p>
      <ul>
        {
        for $dokument in $dokumente
        let $titel := $dokument//tei:fileDesc/tei:titleStmt/tei:title
        let $id := $dokument/@xml:id
        let $datumVerfasst := $dokument//tei:correspAction[@type="sent"]/tei:date/@when
        order by $titel
        return
        <li><a href="dokument/{$id}">{$titel/normalize-space(data(.))}</a> <span> </span> ({$id/normalize-space(data(.))})</li>
        }
      </ul>
    </div>

};

declare function app:dokument($node as node(), $model as map(*)) {
let $id := request:get-parameter("dokument-id", "Fehler")
let $dokument := collection("/db/contents/sources/documents")/tei:TEI[@xml:id=$id]
let $pages := $dokument/tei:text/tei:body/tei:div[@type='page']/@n/normalize-space(data(.))

return
(
<div class="container">
    <div class="page-header">
        <a href="../dokumentenverzeichnis.html">&#8592; zum Dokumentenverzeichnis</a>
            <h1>{$dokument//tei:fileDesc/tei:titleStmt/tei:title/normalize-space(data(.))}</h1>
            <h5>{$id}</h5>
    </div>
    <ul class="nav nav-pills" role="tablist">
<!--        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#datenblatt">Datenblatt</a></li>  -->
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#inhalt">Inhalt</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#daten">Daten</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#personen">Personen</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#institutionen">Institutionen</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#orte">Orte</a></li>
    </ul>
    <!-- Tab panels -->
    <div class="tab-content">
      <!--  <div class="tab-pane fade show active" id="datenblatt" >
        {transform:transform($dokument,doc("/db/apps/baudi/resources/scripts/dokumentDatenblatt.xsl"), ())}
        </div>-->
        <div class="tab-pane fade show active" id="inhalt" >
        {transform:transform($dokument//tei:text,doc("/db/apps/baudi/resources/scripts/dokument.xsl"), ())}
        </div>
        <div class="tab-pane fade" id="daten" >
        {transform:transform($dokument,doc("/db/apps/baudi/resources/scripts/namedDate.xsl"), ())}
        </div>
        <div class="tab-pane fade" id="personen" >
        {transform:transform($dokument,doc("/db/apps/baudi/resources/scripts/namedPers.xsl"), ())}
        </div>
         <div class="tab-pane fade" id="institutionen" >
        {transform:transform($dokument,doc("/db/apps/baudi/resources/scripts/namedInst.xsl"), ())}
        </div>
        <div class="tab-pane fade" id="orte" >
        {transform:transform($dokument,doc("/db/apps/baudi/resources/scripts/namedPlace.xsl"), ())}
        </div>
   </div>
</div>
)
};

declare function app:personen($node as node(), $model as map(*)) {

    let $personen := collection("/db/contents/texts/persons")//tei:TEI
    let $namedPersonsDist := functx:distinct-deep(collection("/db/contents/sources")//tei:text//tei:persName[normalize-space(.)])
    let $namedPersons := collection("/db/contents/sources")//tei:text//tei:persName[normalize-space(.)]
    
return
(
<div class="container">
    <ul class="nav nav-pills" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#tab1">Personendateien</a></li>  
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#tab2">Alle Erwähnungen</a></li>
    </ul>
    <div class="tab-content">
    <div class="tab-pane fade show active" id="tab1">
        <p>Das Personenverzeichnis enthält weiterfündende Informationen zu {count($personen)} Personen.</p>
      <ul>
        {
        for $person in $personen
        let $name := $person//tei:title
        let $id := $person/@xml:id
        order by $name
        return
        <li><a href="person/{$id}">{$name/normalize-space(data(.))}</a> ({$id/normalize-space(data(.))})</li>
        }
      </ul>
    </div>
    <div class="tab-pane fade" id="tab2" >
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
        </div>
    </div>
)
};

declare function app:person($node as node(), $model as map(*)) {
 
let $id := request:get-parameter("person-id", "Fehler")
let $person := collection("/db/contents/texts/persons")/tei:TEI[@xml:id=$id]
let $name := $person//tei:title/normalize-space(data(.))
let $namedPersons := collection("/db/contents/sources")//tei:text//tei:persName[@key=$id]
let $namedPersonsDist := functx:distinct-deep(collection("/db/contents/sources")//tei:text//tei:persName[@key=$id])

return
(
<div class="row">
    <div class="page-header">
        <a href="http://localhost:8080/exist/apps/baudi/html/personenverzeichnis.html">&#8592; zum Personenverzeichnis</a>
        <h1>{$name}</h1>
        <h5>{$id}</h5>
    </div>
    <div class="container">
            <ul class="nav nav-pills" role="tablist">
                <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#tab1">Zur Person</a></li>  
                <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#tab2">Erwähnungen</a></li>
            </ul>
          <div class="tab-content">
            <div class="tab-pane fade show active" id="tab1">
                {transform:transform($person,doc("/db/apps/baudi/resources/scripts/person.xsl"), ())}
                <h4>Bezeichnungen</h4>
                <ul>
                {
                for $persName in $namedPersonsDist
                let $persNameDist := $persName/normalize-space(data(.))
                let $Quelle := $persName/ancestor::tei:TEI/@xml:id/data(.)
                order by lower-case($persNameDist)
                return
                (
                <li>{$persNameDist}</li>
                )
                }
                </ul>
            </div>
            <div class="tab-pane fade" id="tab2" >
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
          </div>
    </div>
</div>
)
};

declare function app:orte($node as node(), $model as map(*)) {

    let $orte := collection("/db/contents/texts/loci")//tei:TEI

return
(
    <div class="container">
        <p>Im Ortsverzeichnis sind {count($orte)} Orte.</p>
      <ul>
        {
        for $ort in $orte
        let $name := $ort//tei:fileDesc/tei:titleStmt/tei:title
        let $id := $ort/@xml:id
        order by $name
        return
        <li><a href="ort/{$id}">{$name/normalize-space(data(.))}</a> <span> </span> ({$id/normalize-space(data(.))})</li>
        }
      </ul>
    </div>
)
};

declare function app:ort($node as node(), $model as map(*)) {

let $id := request:get-parameter("ort-id", "Fehler")
let $ort := collection("/db/contents/texts/loci")/tei:TEI[@xml:id=$id]
let $name := $ort//tei:title/normalize-space(data(.))

return
(
    <div class="container">
    <a href="http://localhost:8080/exist/apps/baudi/html/ortsverzeichnis.html">&#8592; zum Ortsverzeichnis</a>
        <div class="page-header">
            <h1>{$name}</h1>
            <h5>{$id}</h5>
        </div>
        Hier wirds irgendwann noch ein paar Infos zu <br/>{$name}<br/> geben.
        {transform:transform($ort,doc("/db/apps/baudi/resources/scripts/ort.xsl"), ())}
    </div>
)
};

declare function app:institutionen($node as node(), $model as map(*)) {
    let $institutionen := collection("/db/contents/texts/institutions")//tei:TEI

return
(
    <div class ="container">
        <p>Im Institutionenverzeichnis sind {count($institutionen)} Institutionen verzeichnet.</p>
      <ul>
        {
        for $institution in $institutionen
        let $name := $institution//tei:fileDesc/tei:titleStmt/tei:title
        let $id := $institution/@xml:id
        order by $name
        return
        <li><a href="institution/{$id}">{$name/normalize-space(data(.))}</a> ({$id/normalize-space(data(.))})</li>
        }
      </ul>
    </div>
)
};

declare function app:institution($node as node(), $model as map(*)) {

let $id := request:get-parameter("institution-id", "Fehler")
let $institution := collection("/db/contents/texts/institutions")/tei:TEI[@xml:id=$id]
let $name := $institution//tei:title/normalize-space(data(.))

return
(
    <div class="container">
    <a href="http://localhost:8080/exist/apps/baudi/html/institutionenverzeichnis.html">&#8592; zum Institutionenverzeichnis</a>
        <div class="page-header">
            <h1>{$name}</h1>
            <h5>{$id}</h5>
        </div>
        {transform:transform($institution,doc("/db/apps/baudi/resources/scripts/institution.xsl"), ())}
    </div>
)
};

declare function app:sources($node as node(), $model as map(*)) {
    
    let $sources-manuscripts := collection("/db/contents/sources/music")/mei:mei//mei:manifestation[contains(@class,'#ms')]/ancestor::mei:mei
    let $sources-manuscripts-Coll := collection("/db/contents/sources/music/collections")/mei:mei//mei:term[@type='source' and .='Manuskript']/ancestor::mei:mei
    let $sources-prints := collection("/db/contents/sources/music")/mei:mei//mei:term[@type='source' and .='Druck']/ancestor::mei:mei
    let $sources-lieder := collection("/db/contents/sources/music")/mei:mei//mei:term[@type='genre' and .='Lied']/ancestor::mei:mei
    let $sources-choere := collection("/db/contents/sources/music")/mei:mei//mei:term[@type='genre' and .='Chor']/ancestor::mei:mei
    
return
(
    <div class="container">
         <ul class="nav nav-pills" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#manuskripte">Manuskripte ({count($sources-manuscripts)})</a></li>  
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#drucke">Drucke ({count($sources-prints)})</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#lieder">Lieder ({count($sources-lieder)})</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#choere">Chöre ({count($sources-choere)})</a></li>
    </ul>
    <!-- Tab panels -->
    <div class="tab-content">
        <div class="tab-pane fade show active" id="manuskripte" >
        <p>Im Manuskripteverzeichnis sind aktuell {count($sources-manuscripts)} Quellen erfasst.</p>
            <ul>
        {
        for $manuscript in $sources-manuscripts
        let $name :=
            if(exists($manuscript//mei:term[@type='source' and @subtype='special' and contains(./text(),'Sammelquelle')]))
            then($manuscript//mei:fileDesc/mei:titleStmt/mei:title[@type="uniform" and @xml:lang='de']/mei:titlePart[@type='main']/normalize-space(text()))
            else($manuscript//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/mei:titlePart[@type='main']/normalize-space(text()))
        
        let $id := $manuscript/@xml:id/normalize-space(data(.))
        order by $name ascending
        return
            <li>
                {$name} (<a href="sources/manuscript/{$id}">{$id}</a>)<br/>
            </li>
        }
            </ul>
        </div>
        <div class="tab-pane fade" id="drucke" >
         <p>Im Druckeverzeichnis sind aktuell {count($sources-prints)} Quellen erfasst.</p>
            <ul>
        {
        for $print in $sources-prints
        let $name :=
            if(exists($print//mei:term[@type='source' and @subtype='special' and contains(./text(),'Sammelquelle')]))
            then($print//mei:fileDesc/mei:titleStmt/mei:title[@type="uniform" and @xml:lang='de']/normalize-space(data(.)))
            else($print//mei:sourceDesc/mei:source[1]/mei:titleStmt/mei:title[@type="main"]/normalize-space(data(.)))
        
        let $id := $print/@xml:id/normalize-space(data(.))
        order by $name ascending
        return
            <li>
                {$name} (<a href="sources/print/{$id}">{$id}</a>)<br/>
            </li>
        }
            </ul>
        </div>
        <div class="tab-pane fade" id="lieder" >
         <p>Im Quellenverzeichnis sind aktuell {count($sources-lieder)} Quellen zu Lieder erfasst.</p>
            <ul>
        {
        for $lied in $sources-lieder
        let $name :=
            if(exists($lied//mei:term[@type='source' and @subtype='special' and contains(./text(),'Sammelquelle')]))
            then($lied//mei:fileDesc/mei:titleStmt/mei:title[@type="uniform" and @xml:lang='de']/normalize-space(data(.)))
            else($lied//mei:sourceDesc/mei:source[1]/mei:titleStmt/mei:title[@type="main"]/normalize-space(data(.)))
        
        let $id := $lied/@xml:id/normalize-space(data(.))
        order by $name ascending
        return
        (
            if($lied//mei:term[@type='source']/contains(.,'Manuskript') = true()) 
            then(
            <li>
                {$name} (<a href="sources/manuscript/{$id}">{$id}</a>)<br/>
            </li>
            )
            else if($lied//mei:term[@type='source']/contains(.,'Druck') = true())
            then(
            <li>
                {$name} (<a href="sources/print/{$id}">{$id}</a>)<br/>
            </li>
            )
            else()
            )
        }
            </ul>
        </div>
        <div class="tab-pane fade" id="choere" >
         <p>Im Quellenverzeichnis sind aktuell {count($sources-choere)} Quellen zu Chören erfasst.</p>
            <ul>
        {
        for $chor in $sources-choere
        let $name :=
            if(exists($chor//mei:term[@type='source' and @subtype='special' and contains(./text(),'Sammelquelle')]))
            then($chor//mei:fileDesc/mei:titleStmt/mei:title[@type="uniform" and @xml:lang='de']/normalize-space(data(.)))
            else($chor//mei:sourceDesc/mei:source[1]/mei:titleStmt/mei:title[@type="main"]/normalize-space(data(.)))
        
        let $id := $chor/@xml:id/normalize-space(data(.))
        order by $name ascending
        return
            <li>
                {$name} (<a href="sources/print/{$id}">{$id}</a>)<br/>
            </li>
        }
            </ul>
        </div>
   </div>
        
        
    </div>
)
};

declare function app:sources-manuscript($node as node(), $model as map(*)) {

let $id := request:get-parameter("source-id", "Fehler")
let $manuscript := collection("/db/contents/sources/music")/mei:mei[@xml:id=$id]
let $name := $manuscript//mei:manifestation/mei:titleStmt/mei:title[@type="main"]/normalize-space(data(.))
let $manuscriptOrig := concat('../../../../../baudi-images/music/',$manuscript/@xml:id)
let $manuscriptOrigBLB := "https://digital.blb-karlsruhe.de/blbihd/image/view/"
let $manuscriptDigitalisatBLB := "https://digital.blb-karlsruhe.de/blbihd/content/pageview/"

return
(
    <div class="container">
        <a href="../../quellenverzeichnis.html">&#8592; zum Quellenverzeichnis</a>
        <div class="page-header">
            <h1>{$name}</h1>
            <h5>{$id}</h5>
        </div>
        <div class="row">
       {if(exists($manuscript//mei:facsimile/mei:surface))
       then(
        <div class="col">
                {
                if(doc-available(concat($manuscriptOrig,'_001','.jpeg')))
                then(<img src="{concat($manuscriptOrig,'_001','.jpeg')}" width="400"/>)
                else if($manuscript//mei:graphic[@targettype="blb-vlid"])
                then(<a href="{concat($manuscriptDigitalisatBLB,$manuscript//mei:facsimile/mei:surface[@n="1"]/mei:graphic/@target)}" target="_blank"><img src="{concat($manuscriptOrigBLB,$manuscript//mei:facsimile/mei:surface[@n="1"]/mei:graphic/@target)}" width="400"/></a>)
                else()
                }
        </div>
        )
        else()}

    <div class="col">
    <ul class="nav nav-pills" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#main">Überblick</a></li>  
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#detail">Im Detail</a></li>
        <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#lyrics">Liedtext</a></li>
    </ul>
    <!-- Tab panels -->
    <div class="tab-content">
        <div class="tab-pane fade show active" id="main">
        <p/>
        {transform:transform($manuscript,doc("/db/apps/baudi/resources/scripts/manuscriptDataMain.xsl"), ())}
        <p/>
        {if(exists($manuscript//mei:workDesc/mei:work/mei:incip/mei:score))
        then(<b>INCIPIT available (soon)</b>)
        else(<b>No INCIPIT available</b>)}
        </div>
        <div class="tab-pane fade" id="detail">
        <p/>
        {transform:transform($manuscript,doc("/db/apps/baudi/resources/scripts/manuscriptDataDetail.xsl"), ())}
        </div>
        <div class="tab-pane fade" id="lyrics">
        <p/>
            {transform:transform($manuscript,doc("/db/apps/baudi/resources/scripts/lyrics.xsl"), ())}
        </div>
    </div>
    </div>
    </div>
    </div>
)
};

declare function app:sources-print($node as node(), $model as map(*)) {

let $id := request:get-parameter("source-id", "Fehler")
let $print := collection("/db/contents/sources/music")/mei:mei[@xml:id=$id]
let $name := $print//mei:title[@type="main"]/normalize-space(data(.))
let $printOrig := "PFAD"

return
(
    <div class="container">
        <a href="../../quellenverzeichnis.html">&#8592; zum Quellenverzeichnis</a>
        <div class="page-header">
            <h1>{$name}</h1>
        </div>
        <div class="row">
      <div class="col">
                <strong>Link zum Digitalisat der Quelle </strong>
                <img src="{concat($printOrig,'_001','.jpeg')}" width="400"/>
                </div>  
    <div class="col">
    <strong>Quellenbeschreibung</strong>
        {transform:transform($print,doc("/db/apps/baudi/resources/scripts/print.xsl"), ())}
    </div>
    </div>
    </div>
)
};

declare function app:about($node as node(), $model as map(*)) {

let $text := doc("/db/contents/texts/portal/about.xml")/tei:TEI


return
(
    <div class="container">
        {transform:transform($text,doc("/db/apps/baudi/resources/scripts/portal.xsl"), ())}
    </div>
)
};

declare function app:baumann($node as node(), $model as map(*)) {

let $text := doc("/db/contents/texts/portal/baumann.xml")/tei:TEI

return
(
    <div class="container">
        {transform:transform($text,doc("/db/apps/baudi/resources/scripts/portal.xsl"), ())}
    </div>
)
};

declare function app:statusBearb($node as node(), $model as map(*)) {

let $object := doc("/db/contents/register/bearbStatusBLB-HS.xml")

return
(
<div class="container">
<div class="page-header">
<a href="../index.html">&#8592; zurück zur Startseite</a>
            <h1>Status der Bestandsbearbeitung (HS: D-KA, D-KAsa)</h1>
        </div>
        <div class="container">
        {transform:transform($object,doc("/db/contents/resources/scripts/rismxml2html.xsl"), ())}
    </div>
    </div>
)
};

declare function app:indexPage($node as node(), $model as map(*)) {

let $text := doc('/db/contents/texts/portal/index.xml')

return
(
    <div class="container">
        {transform:transform($text,doc("/db/apps/baudi/resources/scripts/portal.xsl"), ())}
    </div>
)
};

declare function app:zeitungsarchiv($node as node(), $model as map(*)) {

let $text := doc('/db/contents/register/zeitungsarchiv.xml')

return
(
<div class="container">
        <a href="../index.html">← zurück zur Startseite</a>
        <div class="page-header">
            <h1>Zeitungarchiv</h1>
        </div>
    <div class="container">
        {transform:transform($text,doc("/db/apps/baudi/resources/scripts/zeitungsarchiv.xsl"), ())}
    </div>
    </div>
)
};

declare function app:guidelines($node as node(), $model as map(*)) {

let $codingGuidelines := doc('/db/contents/texts/documentation/codingGuidelines.xml')
let $editiorialGuidelines := doc('/db/contents/texts/documentation/editorialGuidelines.xml')
let $sourceDescGuidelines := doc('/db/contents/texts/documentation/sourceDescGuidelines.xml')

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
        {transform:transform($codingGuidelines,doc("/db/apps/baudi/resources/scripts/codingGuidelines.xsl"), ())}
        </div>
        <div class="tab-pane fade" id="edition" >
        {transform:transform($editiorialGuidelines,doc("/db/apps/baudi/resources/scripts/editorialGuidelines.xsl"), ())}
        </div>
        <div class="tab-pane fade" id="sourceDesc" >
        {transform:transform($sourceDescGuidelines,doc("/db/apps/baudi/resources/scripts/sourceDescGuidelines.xsl"), ())}
        </div>
   </div>
    </div>
)
};

declare function app:works($node as node(), $model as map(*)) {
    
    let $works := collection("/db/contents/works")/mei:mei
    
    let $content := <div class="container">
    <br/>
         <ul class="nav nav-pills" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#works">Werke ({count($works)})</a></li>  
       
    </ul>
    <!-- Tab panels -->
    <div class="tab-content">
        <div class="tab-pane fade show active" id="works" >
        <br/>
            <ul>
        {
        for $work in $works
        let $name := $works//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/mei:titlePart[@type='main']/normalize-space(text())
        
        let $id := $work/@xml:id/normalize-space(data(.))
        order by $name ascending
        return
            <li>
                {$name} (<a href="werk/{$id}">{$id}</a>)<br/>
            </li>
        }
            </ul>
        </div>
        </div>
   </div>
       
       return $content
       };
       
declare function app:work($node as node(), $model as map(*)) {

let $id := request:get-parameter("werk-id", "Fehler")
let $work := collection("/db/contents/works")/mei:mei[@xml:id=$id]
let $name := $work//mei:fileDesc/mei:titleStmt/mei:title[@type='uniform' and @xml:lang='de']/mei:titlePart[@type='main']/normalize-space(text())

return
(
    <div class="container">
        <a href="../werkeverzeichnis.html">&#8592; zum Werkeverzeichnis</a>
        <br/>
        <div class="page-header">
            <h1>{$name}</h1>
            <h5>ID: {$id}</h5>
        </div>
        <br/>
    <div class="col">
        {transform:transform($work,doc("/db/apps/baudi/resources/scripts/workData.xsl"), ())}
    </div>
    </div>
)
};

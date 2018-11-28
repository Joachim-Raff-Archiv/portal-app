xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

let $create-collection := xmldb:create-collection("/db", "output")

for $record in doc('/db/contents/texts/portal/baumann.xml')/tei:TEI/*

let $split-record := 
    <tei:TEI xmlns="http://www.tei-c.org/ns/1.0">
        {$record}
    </tei:TEI>

let $about := $record/@xml:id

let $filename := util:hash($record/@xml:id/string(), "EDITED") || ".xml"

return
    xmldb:store("/db/output", $filename, $split-record)

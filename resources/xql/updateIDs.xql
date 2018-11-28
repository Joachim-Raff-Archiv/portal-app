xquery version "1.0";
(:
    MRI, RWA, dried, 2018
    Update @n with new numbers; position() will be new @n
    >>>Skript muss in der eXistDB ausgeführt werden.<<<
:)

declare default element namespace "http://www.edirom.de/ns/1.3";

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace functx = "http://www.functx.com";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

let $docsToUpdate := collection("/db/contents/jra/works/")
let $pos := 1

for $docToUpdate at $pos in $docsToUpdate
    let $docURI := $docToUpdate/document-uri(.)
    let $historyOld := $docToUpdate//mei:physLoc/mei:history/mei:eventList/mei:event
    let $placeToInsert := $docToUpdate//mei:mei//mei:manifestation/mei:history/mei:eventList

return
    update insert $historyOld into $placeToInsert

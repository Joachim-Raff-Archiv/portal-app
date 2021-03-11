xquery version "3.1";

module namespace raffWorks="https://portal.raff-archiv.ch/ns/raffWorks";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace hc = "http://expath.org/ns/http-client";

import module namespace app="https://portal.raff-archiv.ch/templates" at "/db/apps/raffArchive/modules/app.xql";
import module namespace raffShared="https://portal.raff-archiv.ch/ns/raffShared" at "/db/apps/raffArchive/modules/raffShared.xqm";
import module namespace raffPostals="https://portal.raff-archiv.ch/ns/raffPostals" at "/db/apps/raffArchive/modules/raffPostals.xqm";
import module namespace raffWritings="https://portal.raff-archiv.ch/ns/raffWritings" at "/db/apps/raffArchive/modules/raffWritings.xqm";
import module namespace functx="http://www.functx.com" at "/db/apps/raffArchive/modules/functx.xqm";
import module namespace i18n="http://exist-db.org/xquery/i18n" at "/db/apps/raffArchive/modules/i18n.xql";


declare function raffWorks:getWorks($cat){
    let $works := $app:collectionWorks[.//mei:term = $cat]
    for $work in $works
        let $workName := $work//mei:workList//mei:title[matches(@type,'uniform')]/text() => normalize-space()
        let $opus := $work//mei:workList//mei:title[matches(@type,'desc')]/text() => normalize-space()
        let $withoutArticle := functx:replace-multi($workName, ('Der ','Den ', 'Die ', 'La ', 'Le ', 'L’'),('','','','','',''))
        
        let $workID := $work/@xml:id/string()
        
        let $workPerfRess := $work//mei:work[1]//mei:perfResList/mei:perfRes[not(@type = 'alt')]
                            let $perfDesc := string-join($workPerfRess, ' | ')
                            let $arranged := if(matches($work//mei:arranger//mei:persName/@auth, 'C00695')) then(true()) else (false())
                            let $lost := $work//mei:event[mei:head/text() = 'Textverlust']/mei:desc/text()
        
        return
            <div titleToSort="{$opus}"
            class="row {if(string-length($cat)>9)then('RegisterEntry2')else('RegisterEntry')}">
                <div class="col-sm-5 col-md-7 col-lg-8">
                    {$workName}
                    {if($perfDesc or $arranged)
                     then(<br/>,<span class="sublevel">{if($arranged)then('Bearbeitet für ')else()}{$perfDesc}</span>)
                     else()}
                </div>
                <div
                    class="col-sm-4 col-md-3 col-lg-2">{$opus}
                    <br/>
                    {if($lost)
                    then(<span class="sublevel">{concat('(', $lost, ')')}</span>)
                    else()}
                </div>
                <div
                    class="col-sm-3 col-md-2 col-lg-2"><a onclick="pleaseWait()"
                        href="work/{$workID}">{$workID}</a>
                </div>
            </div>
};

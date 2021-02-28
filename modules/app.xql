xquery version "3.1";

module namespace app = "https://portal.raff-archiv.ch/templates";

import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config = "https://portal.raff-archiv.ch/config" at "config.xqm";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

import module namespace i18n="http://exist-db.org/xquery/i18n" at "i18n.xql";
import module namespace raffShared="https://portal.raff-archiv.ch/ns/raffShared" at "raffShared.xqm";
import module namespace raffPostals="https://portal.raff-archiv.ch/ns/raffPostals" at "raffPostals.xqm";
import module namespace raffWritings="https://portal.raff-archiv.ch/ns/raffWritings" at "raffWritings.xqm";
import module namespace raffWorks="https://portal.raff-archiv.ch/ns/raffWorks" at "/db/apps/raffArchive/modules/raffWorks.xqm";
(:import module namespace raffSources="https://portal.raff-archiv.ch/ns/baudiSources" at "raffSources.xqm";:)

import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace http = "http://expath.org/ns/http-client";
(:declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";:)
declare namespace range = "http://exist-db.org/xquery/range";
declare namespace pkg = "http://expath.org/ns/pkg";

declare variable $app:dbRootUrl as xs:string := request:get-url();
declare variable $app:dbRootLocalhost as xs:string := 'http://localhost:8080/exist/apps/raffArchive';
declare variable $app:dbRootDev as xs:string := 'http://localhost:8088/exist/apps/raffArchive';
declare variable $app:dbRootPortal as xs:string := 'http://localhost:8082/exist/apps/raffArchive';
declare variable $app:dbRoot as xs:string := if(contains($app:dbRootUrl,$app:dbRootLocalhost))then('/exist/apps/raffArchive')else('');
declare variable $app:digilibPath as xs:string := 'https://digilib.baumann-digital.de';


declare variable $app:collectionPostals := collection('/db/apps/jraSources/data/documents')//tei:TEI[.//tei:correspDesc];
declare variable $app:collectionPersons := collection('/db/apps/jraPersons/data')//tei:TEI[.//tei:person];
declare variable $app:collectionInstitutions := collection('/db/apps/jraInstitutions/data')//tei:TEI[.//tei:org];
declare variable $app:collectionSources := collection('/db/apps/jraSources/data')//tei:TEI;
declare variable $app:collectionTexts := collection('/db/apps/jraTexts/data')//tei:TEI;
declare variable $app:collectionWorks := collection('/db/apps/jraWorks/data')//mei:mei;
declare variable $app:collectionWritings := collection('/db/apps/jraWritings/data')//tei:TEI;
declare variable $app:collectionsAll := ($app:collectionPostals, $app:collectionPersons, $app:collectionInstitutions, $app:collectionSources, $app:collectionTexts, $app:collectionWorks);

declare variable $app:collFullPostals := collection('/db/apps/jraSources/data/documents')//tei:TEI;
declare variable $app:collFullPersons := collection('/db/apps/jraPersons/data')//tei:TEI;
declare variable $app:collFullInstitutions := collection('/db/apps/jraInstitutions/data')//tei:TEI;
declare variable $app:collFullSources := collection('/db/apps/jraSources/data')//tei:TEI;
declare variable $app:collFullTexts := collection('/db/apps/jraTexts/data')//tei:TEI;
declare variable $app:collFullWorks := collection('/db/apps/jraWorks/data')//mei:mei;
declare variable $app:collFullWritings := collection('/db/apps/jraWritings/data')//tei:TEI;
declare variable $app:collFullAll := ($app:collFullPostals, $app:collFullPersons, $app:collFullInstitutions, $app:collFullSources, $app:collFullTexts, $app:collFullWorks, $app:collFullWritings);

declare function app:langSwitch($node as node(), $model as map(*)) {
    let $supportedLangVals := ('de', 'en')
    for $lang in $supportedLangVals
        return
            <li class="nav-item-jra-top">
                <a id="{concat('lang-switch-', $lang)}" class="nav-link-jra-top {if (raffShared:get-lang() = $lang) then ('disabled') else ()}" style="{if (raffShared:get-lang() = $lang) then ('color: white!important;') else ()}" href="?lang={$lang}" onklick="{response:set-cookie('forceLang', $lang)}">{upper-case($lang)}</a>
            </li>
};

declare function app:search($node as node(), $model as map(*)) {
    let $collection := $app:collectionPersons
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

declare function app:filterInput(){
    <div>
        <h5>Filter​n <img src="../resources/fonts/feather/info.svg" width="23px" data-toggle="popover" title="Ansicht reduzieren." data-content="Geben Sie bspw. einen Namen, eine ID oder ein Datum ein. Der Filter reduziert die Ansicht auf die Einträge, die Ihren Suchbegriff enthalten."/></h5>
        <input type="text" id="myResearchInput" onkeyup="myFilter()" placeholder="Name, ID, …" title="Type in a string"/>
   </div>
};

declare function app:registryLettersDate($node as node(), $model as map(*)) {

    let $letters := $app:collectionPostals
    
    let $lettersCrono := for $letter in $letters
                        let $letterID := $letter/@xml:id/string()
                        let $correspActionSent := $letter//tei:correspAction[matches(@type, "sent")]
                        let $correspActionReceived := $letter//tei:correspAction[matches(@type, "received")]
                        (:let $correspSentId := if($sender/@key)
                                              then($sender/@key)
                                              else():)
                        let $correspSent := if($correspActionSent/tei:persName[@key])
                                                then(for $each in $correspActionSent/tei:persName/@key
                                                      return
                                                        raffPostals:getName($each, 'short'))
                                                else if($correspActionSent/tei:orgName[@key])
                                                then(raffPostals:getName($correspActionSent/tei:orgName/@key, 'full'))
                                                else('N.N.')
                        let $correspReceived := if($correspActionReceived/tei:persName[@key])
                                                then(for $each in $correspActionReceived/tei:persName/@key
                                                      return
                                                        raffPostals:getName($each, 'short'))
                                                else if($correspActionReceived/tei:orgName[@key])
                                                then(raffPostals:getName($correspActionReceived/tei:orgName/@key, 'full'))
                                                else('N.N.')
                        let $getDateArray := raffShared:getDateRegistryLetters($correspActionSent)
                        let $date := $getDateArray(1)
                        let $year := substring($date,1,4)
                        let $dateFormatted := raffShared:formatDateRegistryLetters($getDateArray)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-sm-4 col-md-3 col-lg-4" dateToSort="{if($date='0000-00-00')then(replace($date,'0000-','9999-'))else($date)}">{$dateFormatted}</div>
                                <div class="col-sm-5 col-md-7 col-lg-6">{string-join($correspSent, ' | ')}<br/>an {string-join($correspReceived, ' | ')}</div>
                                <div class="col-sm-3 col-md-2 col-lg-2"><a href="letter/{$letterID}">{$letterID}</a></div>
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
            <div class="row  justify-content-between">
                <div class="col-sm-9 	col-md-7 	col-lg-7">
                    <p>Der Katalog verzeichnet derzeit {count($letters)} Postsachen.</p>
                </div>
                <div class=".col-sm-3 	.col-md-3 	.col-lg-3">
                    {app:filterInput()}
                </div>
            </div>
                    <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item nav-linkless-jra">Sortierungen:</li>
                        <li class="nav-item"><a class="nav-link-jra active" href="#date">Datum</a></li>
                        <li class="nav-item"><a class="nav-link-jra" onclick="pleaseWait()" href="registryLettersSender.html">Absender</a></li>
                        <li class="nav-item"><a class="nav-link-jra" onclick="pleaseWait()" href="registryLettersReceiver.html">Empfänger</a></li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane fade show active" id="date">
                            <br/>
                            <div class="container row">
        					   <div id="navigator" class="list-group col-sm-4 col-md-3 col-lg-3" style="height:500px; overflow-y: scroll;">
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
                        <div id="divResults" data-spy="scroll" data-target="#navigator" data-offset="90" class="col-sm col-md col-lg" style="position: relative; height:500px; overflow-y: scroll;">
                            {$lettersGroupedByYears}
                        </div>
                    </div>
                </div>
            </div>
        </div>
        )
};

declare function app:registryLettersSender($node as node(), $model as map(*)) {

    let $letters := $app:collectionPostals
    
    let $lettersSender := for $sender in ($letters//tei:correspAction[matches(@type, "sent")]//tei:persName[@key],
                                          $letters//tei:correspAction[matches(@type, "sent")]//tei:orgName[@key])
                        let $letterID := $sender/ancestor::tei:TEI/@xml:id/data(.)
                        let $correspActionSent := $sender/ancestor::tei:correspAction[matches(@type, "sent")]
                        let $correspActionReceived := $sender/ancestor::tei:correspDesc/tei:correspAction[matches(@type, "received")]
                        let $correspSentId := if($sender/@key)
                                              then($sender/@key)
                                              else()
                        
                        let $correspReceived := if($correspActionReceived/tei:persName[@key])
                                                then(for $each in $correspActionReceived/tei:persName/@key
                                                      return
                                                        raffPostals:getName($each, 'short'))
                                                else if($correspActionReceived/tei:orgName[@key])
                                                then(raffPostals:getName($correspActionReceived/tei:orgName/@key, 'full'))
                                                else('N.N.')
                        let $senderName := raffPostals:getName($sender/@key,'reversed')
                        let $getDateArray := raffShared:getDateRegistryLetters($correspActionSent)
                        let $date := $getDateArray(1)
                        let $year := substring($date,1,4)
                        let $dateFormatted := raffShared:formatDateRegistryLetters($getDateArray)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                                <div class="col-sm-4 col-md-3 col-lg-4" dateToSort="{$date}">{$dateFormatted}</div>
                                                <div class="col-sm-5 col-md-7 col-lg-6">an {string-join($correspReceived,' | ')}</div>
                                                <div class="col-sm-3 col-md-2 col-lg-2"><a href="letter/{$letterID}">{$letterID}</a></div>
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
                                                    {raffPostals:getName($senderId,'full')}
                </div>
                {
                    for $group in $groups
                        return
                            $group
                }
            </div>)
    
    return
        (<div class="container">
           <div class="row  justify-content-between">
                <div class="col-sm-9 	col-md-7 	col-lg-7">
                    <p>Der Katalog verzeichnet derzeit {count($letters)} Postsachen.</p>
                </div>
                <div class=".col-sm-3 	.col-md-3 	.col-lg-3">
                    {app:filterInput()}
                </div>
            </div>
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
                                <div id="navigator" class="list-group col-sm-4 col-md-3 col-lg-3" style="height:500px; overflow-y: scroll;">
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
                                <div id="divResults" data-spy="scroll" data-target="#navigator" data-offset="90" class="col-sm col-md col-lg" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$lettersGroupedBySenders}
                                </div>
                            </div>
                            </div>
                            </div>
                            </div>
        )

};

declare function app:registryLettersReceiver($node as node(), $model as map(*)) {

    let $letters := $app:collectionPostals
    
    let $lettersReceiver := for $receiver in ($letters//tei:correspAction[matches(@type,"received")]//tei:persName[@key],
                                            $letters//tei:correspAction[matches(@type,"received")]//tei:orgName[@key])
                        let $letterID := $receiver/ancestor::tei:TEI/@xml:id/data(.)
                        let $correspActionSent := $receiver/ancestor::tei:correspDesc/tei:correspAction[matches(@type,"sent")]
                        let $correspActionReceived := $receiver/ancestor::tei:correspDesc/tei:correspAction[matches(@type,"received")]
                        let $correspReceivedId := if($receiver/@key)
                                              then($receiver/@key)
                                              else()
                                              
                        let $correspSent := if($correspActionSent/tei:persName[@key])
                                                then(for $each in $correspActionSent/tei:persName/@key
                                                      return
                                                        raffPostals:getName($each, 'short'))
                                                else if($correspActionSent/tei:orgName[@key])
                                                then(raffPostals:getName($correspActionSent/tei:orgName/@key, 'full'))
                                                else('N.N.')
                        
(:                        let $correspReceived := raffPostals:getReceiver($correspActionReceived):)
                        
                        let $receiverName := raffPostals:getName($receiver/@key,'reversed')
                                              
                        let $getDateArray := raffShared:getDateRegistryLetters($correspActionSent)
                        let $date := $getDateArray(1)
                        let $year := substring($date,1,4)
                        let $dateFormatted := raffShared:formatDateRegistryLetters($getDateArray)
                        let $letterEntry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                <div class="col-sm-4 col-md-3 col-lg-4" dateToSort="{$date}">{$dateFormatted}</div>
                                <div class="col-sm-5 col-md-7 col-lg-6">von {string-join($correspSent,' | ')}</div>
                                <div class="col-sm-3 col-md-2 col-lg-2"><a href="letter/{$letterID}">{$letterID}</a></div>
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
                                                    {raffPostals:getName($receiverId,'full')}
                </div>
                {
                    for $group in $groups
                        return
                            $group
                }
            </div>)
    
    return
         (<div class="container">
            <div class="row  justify-content-between">
                <div class="col-sm-9 	col-md-7 	col-lg-7">
                    <p>Der Katalog verzeichnet derzeit {count($letters)} Postsachen.</p>
                </div>
                <div class=".col-sm-3 	.col-md-3 	.col-lg-3">
                    {app:filterInput()}
                </div>
            </div>
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
                                <div id="navigator" class="list-group col-sm-4 col-md-3 col-lg-3" style="height:500px; overflow-y: scroll;">
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
                                <div id="divResults" data-spy="scroll" data-target="#navigator" data-offset="90" class="col-sm col-md col-lg" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$lettersGroupedByReceivers}
                                </div>
                            </div>
                            </div>
                            </div>
                            </div>
        )

};


declare function app:letter($node as node(), $model as map(*)) {
    
    let $id := request:get-parameter("letter-id", "Fehler")
    let $forwarding := raffShared:forwardEntries($id)
    let $letter := $app:collectionPostals/id($id)
    let $person := $app:collectionPersons
    let $absender := $letter//tei:correspAction[@type = "sent"]/tei:persName[1]/text()[1] (:$person/id($letter//tei:correspAction[@type="sent"]/tei:persName[1]/@key)/tei:forename[@type='used']:)
    let $datumSent := raffShared:formatDate(raffShared:getDate($letter//tei:correspAction[@type = "sent"]))
    let $correspReceived := $letter//tei:correspAction[@type = "received"]
    let $adressat := if($letter//tei:correspAction[@type = "received"]/tei:persName) then ($letter//tei:correspAction[@type = "received"]/tei:persName[1]/text()[1]) else if($letter//tei:correspAction[@type = "received"]/tei:orgName[1]/text()[1]) then($letter//tei:correspAction[@type = "received"]/tei:orgName[1]/text()[1]) else('')
    let $nameTurned := if(contains($adressat,', '))then(concat($adressat/substring-after(., ','),' ',$adressat/substring-before(., ',')))else($adressat)
    let $regeste := $letter//tei:note[@type='regeste' and . !='']
    let $fulltext := $letter//tei:div[@type='volltext']
    let $facsimile := $letter//tei:facsimile[.//tei:graphic]
    return
        (
        <div
            class="container">
            <div
                class="page-header tabbable parentTabs">
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
                {if ($facsimile) then(<li
                    class="nav-item"><a
                        class="nav-link-jra"
                        data-toggle="tab"
                        href="#contentLetterFacsimile">Faksimile</a></li>)else()}
                {if(contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive') or contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
                then(<li
                    class="nav-item"><a
                        class="nav-link-jra"
                        data-toggle="tab"
                        href="#viewXML">XML-Ansicht</a></li>)
                        else()}
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
                              {if(contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive') or
                              contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
                              then(<div class="alert alert-info" role="alert">{
                                        if($letter//tei:msIdentifier/tei:altIdentifier/tei:idno[@resp = 'JRA-copy']/text() != '')
                                        then('Signatur (JRA): ', $letter//tei:msIdentifier/tei:altIdentifier/tei:idno[@resp = 'JRA-copy']/text(), ' (Kopie)')
                                        else()}
                                   </div>)
                              else()}
                              <br/>
                              {transform:transform($letter, doc("/db/apps/raffArchive/resources/xslt/metadataLetter.xsl"), ())}
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
                          {if ($facsimile)
                           then(
                           <div
                              class="tab-pane fade"
                              id="contentLetterFacsimile">
                                    <div class="tabbable">
                                    <nav aria-label="Page navigation example">
                                      <ul class="pagination justify-content-center nav nav-pills" id="facsimileTabs" role="tablist">
                                        <!--<li class="nav-item prev">
                                          <a class="nav-link-jra" href="#" aria-label="Previous">
                                            <span aria-hidden="true">«</span>
                                            <span class="sr-only">Previous</span>
                                          </a>
                                        </li>-->
                                        {for $surface at $n in $facsimile//tei:surface
                                         return
                                              <li class="nav-item {if($n=1)then('active')else()}"><a class="nav-link-jra" data-toggle="tab" href="#facsimile-{$n}">{$n}</a></li>
                                          }
                                        <!--<li class="nav-item next">
                                          <a class="nav-link-jra" href="#" aria-label="Next">
                                            <span aria-hidden="true">»</span>
                                            <span class="sr-only">Next</span>
                                          </a>
                                        </li>-->
                                      </ul>
                                    </nav>
                                  <div class="tab-content">
                                      {raffShared:get-digitalization-tei-as-html($facsimile)}
                                  </div>
                                </div>
                                </div>)
                           else()}
                          {if(contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive') or contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
                          then(<div
                              class="tab-pane fade"
                              id="viewXML">
                              <pre>
                                              <xmp>
                              {transform:transform($letter, doc("/db/apps/raffArchive/resources/xslt/viewXML.xsl"), ())}
                              </xmp>
                              </pre>
                          </div>)
                          else()}
                      </div>
                      {raffShared:suggestedCitation($id)}
            </div>
         </div>
      </div>
  </div>
        )
};

declare function app:registryPersonsInitial($node as node(), $model as map(*)) {
    
    let $persons := $app:collectionPersons
    
    let $personsAlpha := for $person in $persons
                            let $persID := $person/@xml:id/string()
                            let $nameSurnames := $person//tei:surname[matches(@type,"^used")]
                            let $nameForenames := $person//tei:forename[matches(@type,"^used")]
                            let $initial := if(count($nameSurnames) > 0)
                                            then(substring($nameSurnames[1], 1, 1))
                                            else if(count($nameForenames) > 0)
                                            then(substring($nameForenames[1], 1, 1))
                                            else()
                            let $role := $person//tei:roleName[1]/text()[1]
                            let $pseudonym := string-join(($person//tei:forename[matches(@type,'^pseudonym')],
                                                           $person//tei:surname[matches(@type,'^pseudonym')]),' ')
                            let $occupation := $person//tei:occupation[1]/text()[1]
                            
                            let $lifeData := raffShared:getLifedata($person)
                            let $nameJoined := raffPostals:getName($persID, 'reversed')
                            let $nameToSort := raffShared:replaceToSortDist(if(count($nameSurnames) > 0) 
                                                                       then(string-join($nameSurnames, ' '))
                                                                       else if(count($nameForenames) > 0)
                                                                       then(string-join($nameForenames, ' '))
                                                                       else())
                            let $name := <div
                                class="row RegisterEntry">
                                <div
                                    class="col">
                                    {$nameJoined}
                                    {$lifeData}
                                    {<br/>,
                                     <span class="sublevel">
                                        {if($pseudonym != '' or $role != '' or $occupation != '')
                                        then(
                                        concat('(',
                                                string-join((if($pseudonym)then(concat('Pseudonym: ', $pseudonym))else(),
                                                             if($role)then($role)else(),
                                                             if($occupation)then($occupation)else()),' | ')
                                                ,')')
                                                )
                                        else(<br/>)
                                        }
                                     </span>
                                    }
                                </div>
                                <div
                                    class="col-sm-3 col-md-2 col-lg-2"><a  onclick="pleaseWait()"
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
                                        let $order := raffShared:replaceToSortDist($each)
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
                    <div class="row  justify-content-between">
                        <div class="col-sm-9 	col-md-7 	col-lg-7">
                            <p>Der Katalog verzeichnet derzeit {count($persons)} Personen.</p>
                        </div>
                        <div class=".col-sm-3 	.col-md-3 	.col-lg-3">
                            {app:filterInput()}
                        </div>
                    </div>
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
                                class="container row">
                                <div id="navigator" class="list-group col-sm-4 col-md-3 col-lg-3" style="height:500px; overflow-y: scroll;">
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
                                                            ('[weitere]')
                                                        else
                                                            ($initial)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                            </a>
                                    }
                                
                                </ul>
                                </div>
                                <div id="divResults" data-spy="scroll" data-target="#navigator" data-offset="90" class="col-sm col-md col-lg" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$personsGroupedByInitials}
                                </div>
                            </div>
                        </div>
            </div>
        </div>
};

declare function app:registryPersonsBirth($node as node(), $model as map(*)) {
    
    let $persons := $app:collectionPersons
    
    let $personsBirth := for $person in $persons
                             let $persID := $person/@xml:id/string()
                             let $nameJoined := raffPostals:getName($persID, 'reversed')
                             let $nameSurname := $person//tei:surname[matches(@type,"^used")][1]
                             let $role := $person//tei:roleName[1]/text()[1]
                             let $pseudonym := if ($person//*[matches(@type,'^pseudonym')][1]/text()[1])
                                               then (string-join(($person//tei:forename[matches(@type,'^pseudonym')], $person//tei:surname[matches(@type,'^pseudonym')]),' '))
                                               else ()
                             let $occupation := $person//tei:occupation[1]/text()[1]
                             
                             let $birth := raffShared:getBirth($person)
                             let $birthToSort := if (contains($birth,'/')) then(substring-before($birth,'/')) else($birth)
                             let $birthFormatted := raffShared:formatLifedata($birth)
                             let $lifeData := raffShared:getLifedata($person)
                             
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
                                                            string-join((if($pseudonym)then(concat('Pseudonym: ', $pseudonym))else(),
                                                                         if($role)then($role)else(),
                                                                         if($occupation)then($occupation)else()),' | ')
                                                            ,')')
                                                    }
                                                </span>)
                                        else ()
                                    }
                                 </div>
                                 <div
                                     class="col-sm-3 col-md-2 col-lg-2"><a  onclick="pleaseWait()"
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
                                         let $order := raffShared:replaceToSortDist($each)
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
                     <div class="row  justify-content-between">
                        <div class="col-sm-9 	col-md-7 	col-lg-7">
                            <p>Der Katalog verzeichnet derzeit {count($persons)} Personen.</p>
                        </div>
                        <div class=".col-sm-3 	.col-md-3 	.col-lg-3">
                            {app:filterInput()}
                        </div>
                    </div>
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
                                class="container row">
                                <div id="navigatorTab2" class="list-group col-sm-4 col-md-3 col-lg-3" style="height:500px; overflow-y: scroll;">
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
                                <div  id="divResults" data-spy="scroll" data-target="#navigatorTab2" data-offset="90" class="col-sm col-md col-lg" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$personsGroupedByBirth}
                                </div>
                            </div>
                </div>
            </div>
        </div>
};
 
declare function app:registryPersonsDeath($node as node(), $model as map(*)) {
    
    let $persons := $app:collectionPersons
    
    let $personsDeath := for $person in $persons
                            let $persID := $person/@xml:id/string()
                            let $nameSurname := $person//tei:surname[matches(@type,"^used")][1]
                            let $role := $person//tei:roleName[1]/text()[1]
                            let $pseudonym := if ($person//*[matches(@type,'^pseudonym')][1]/text()[1])
                                               then (string-join(($person//tei:forename[matches(@type,'^pseudonym')], $person//tei:surname[matches(@type,'^pseudonym')]),' '))
                                               else ()
                            let $occupation := $person//tei:occupation[1]/text()[1]
                            
                            let $death := raffShared:getDeath($person)
                            let $deathToSort := if (contains($death,'/')) then(substring-before($death,'/')) else($death)
                            let $deathFormatted := raffShared:formatLifedata($death)
                            let $lifeData := raffShared:getLifedata($person)
                            let $nameJoined := raffPostals:getName($persID, 'reversed')
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
                                                            string-join((if($pseudonym)then(concat('Pseudonym: ', $pseudonym))else(),
                                                                         if($role)then($role)else(),
                                                                         if($occupation)then($occupation)else()),' | ')
                                                            ,')')
                                                    }
                                                </span>)
                                        else ()
                                    }
                                </div>
                                <div
                                    class="col-sm-3 col-md-2 col-lg-2"><a onclick="pleaseWait()"
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
                                            let $order := raffShared:replaceToSortDist($each)
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
                     <div class="row  justify-content-between">
                        <div class="col-sm-9 	col-md-7 	col-lg-7">
                            <p>Der Katalog verzeichnet derzeit {count($persons)} Personen.</p>
                        </div>
                        <div class=".col-sm-3 	.col-md-3 	.col-lg-3">
                            {app:filterInput()}
                        </div>
                    </div>
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
                                class="container row">
                                <div id="navigatorTab3" class="list-group col-sm-4 col-md-3 col-lg-3" style="height:500px; overflow-y: scroll;">
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
                                <div id="divResults" data-spy="scroll" data-target="#navigatorTab3" data-offset="90" class="col-sm col-md col-lg" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$personsGroupedByDeath}
                                </div>
                            </div>
                        </div>
            </div>
        </div>
};
 
declare function app:person($node as node(), $model as map(*)) {
    
    let $id := request:get-parameter("person-id", "Fehler")
    let $forwarding := raffShared:forwardEntries($id)
    let $person := $app:collectionPersons/id($id)
    let $name := raffPostals:getName($id, 'full')
    let $correspondence := $app:collectionPostals//tei:persName[@key = $id]/ancestor::tei:TEI
    let $literature := $person//tei:bibl[@type='links']
    let $vorkommen := ($app:collectionInstitutions//tei:persName[@key=$id]/ancestor::tei:TEI|
                      $app:collectionTexts//tei:persName[@key=$id]/ancestor::tei:TEI|
                      $app:collectionSources//tei:persName[@key=$id]/ancestor::tei:TEI|
                      $app:collectionWorks//mei:persName[@auth=$id]/ancestor::mei:mei)
    
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
                            {if (raffPostals:getCorrespondance($id)) then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#correspondence">Korrespondenz</a></li>)else()}
                            {if (raffShared:getReferences($id)) then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#references">Referenzen</a></li>)else()}
                            {if ($literature/text()/normalize-space()!='') then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#literature">Literatur</a></li>)else()}
                            {if(contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive') or contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
                then(<li
                    class="nav-item"><a
                        class="nav-link-jra"
                        data-toggle="tab"
                        href="#viewXML">XML-Ansicht</a></li>)
                        else()}
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
                                {transform:transform($person, doc("/db/apps/raffArchive/resources/xslt/metadataPerson.xsl"), ())}
                            </div>
                            {
                                if (raffPostals:getCorrespondance($id)) then
                                    (<div
                                        class="tab-pane fade"
                                        id="correspondence">
                                        <br/>
                                        <div >{
                                            let $entrys := raffPostals:getCorrespondance($id)
                                            return
                                                $entrys
                                        }</div>
                                    </div>)
                                else
                                    ()
                            }
                            {
                                if (raffShared:getReferences($id))
                                then (<div
                                        class="tab-pane fade"
                                        id="references">
                                        <br/>
                                        <div >{
                                            let $entrys := raffShared:getReferences($id)
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
                            {if(contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive') or contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
                then(<div
                    class="tab-pane fade"
                    id="viewXML">
                    <pre>
                                    <xmp>
                    {transform:transform($person/root(), doc("/db/apps/raffArchive/resources/xslt/viewXML.xsl"), ())}
                    </xmp>
                    </pre>
                </div>)
                else()}
                        </div>
                        {raffShared:suggestedCitation($id)}
                    </div>
                </div>
            </div>
        </div>
        )
};

declare function app:registryInstitutions($node as node(), $model as map(*)) {
    
    let $institutions := $app:collectionInstitutions
    
    let $institutionsAlpha := for $institution in $institutions
                                let $instID := $institution/@xml:id/string()
                                let $initial := upper-case(substring($institution//tei:org/tei:orgName[1], 1, 1))
                                let $nameInstitution := $institution//tei:org/tei:orgName[1]
                                let $desc := $institution//tei:org/tei:desc[1]
                                let $place := string-join($institution//tei:org/tei:place/tei:placeName, '/')
                                let $name := <div
                                    class="row RegisterEntry">
                                    <div
                                        class="col-sm-5 col-md-6 col-lg-6">
                                        {$nameInstitution}<br/><span class="sublevel">{$desc}</span>
                                    </div>
                                    <div
                                        class="col-sm-4 col-md-4 col-lg-4">{$place}</div>
                                    <div
                                        class="col-sm-3 col-md-2 col-lg-2"><a onclick="pleaseWait()"
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
                                                let $order := raffShared:replaceToSortDist($each)
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
                                        class="col-sm-5 col-md-6 col-lg-6">
                                        {$nameInstitution}<br/><span class="sublevel">{$desc}</span>
                                    </div>
                                    <div
                                        class="col-sm-4 col-md-4 col-lg-4">{$places}</div>
                                    <div
                                        class="col-sm-3 col-md-2 col-lg-2"><a onclick="pleaseWait()"
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
                                                let $order := raffShared:replaceToSortDist($each)
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
           <div class="row  justify-content-between">
               <div class="col-sm-9 	col-md-7 	col-lg-7">
                   <p>Der Katalog verzeichnet derzeit {count($institutions)} Institutionen.</p>
               </div>
               <div class=".col-sm-3 	.col-md-3 	.col-lg-3">
                   {app:filterInput()}
               </div>
            </div>
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
                        class="tab-content" id="divResults" >
                        <div
                            class="tab-pane fade show active"
                            id="alpha">
                            <br/>
                            <div
                                class="container row">
                                <div id="navigator" class="list-group col-sm-4 col-md-3 col-lg-3" style="height:500px; overflow-y: scroll;">
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
                                <div data-spy="scroll" data-target="#navigator" data-offset="90" class="col-sm col-md col-lg" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$institutionsGroupedByInitials}
                                </div>
                            </div>
                        </div>
                        <div
                            class="tab-pane fade"
                            id="place">
                            <br/>
                            <div
                                class="container row">
                                <div id="navigatorTab2" class="list-group col-sm-4 col-md-3 col-lg-3" style="height:500px; overflow-y: scroll;">
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
                                <div data-spy="scroll" data-target="#navigatorTab2" data-offset="90" class="col-sm col-md col-lg" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$institutionsGroupedByPlaces}
                                </div>
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
    let $forwarding := raffShared:forwardEntries($id)
    let $persons := $app:collectionPersons
    let $institution := $app:collectionInstitutions/id($id)
    let $name := $institution//tei:titleStmt/tei:title/normalize-space(data(.))
    let $letters := $app:collectionPostals
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
                            {if (raffPostals:getCorrespondance($id)) then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#correspondence">Korrespondenz</a></li>)else()}
                            {if (raffShared:getReferences($id)) then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#references">Referenzen</a></li>)else()}
                            {if ($literature/text()/normalize-space()!='') then(<li
                                class="nav-item">
                                <a
                                    class="nav-link-jra"
                                    data-toggle="tab"
                                    href="#literature">Literatur</a></li>)else()}
                            {if(contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive') or contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
                then(<li
                    class="nav-item"><a
                        class="nav-link-jra"
                        data-toggle="tab"
                        href="#viewXML">XML-Ansicht</a></li>)
                        else()}
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
                                {transform:transform($institution, doc("/db/apps/raffArchive/resources/xslt/metadataInstitution.xsl"), ())}
                               
                        
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
                                if (raffPostals:getCorrespondance($id)) then
                                    (<div
                                        class="tab-pane fade"
                                        id="correspondence">
                                        <br/>
                                        <div >{
                                            let $entrys := raffPostals:getCorrespondance($id)
                                            return
                                                $entrys
                                        }</div>
                                    </div>)
                                else
                                    ()
                            }
                            {
                                if (raffShared:getReferences($id)) then
                                    (<div
                                        class="tab-pane fade"
                                        id="references">
                                        <br/>
                                        <div >{
                                            let $entrys := raffShared:getReferences($id)
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
                            {if(contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive') or contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
                then(<div
                    class="tab-pane fade"
                    id="viewXML">
                    <pre>
                                    <xmp>
                    {transform:transform($institution/root(), doc("/db/apps/raffArchive/resources/xslt/viewXML.xsl"), ())}
                    </xmp>
                    </pre>
                </div>)
                else()}
                    </div>
                    {raffShared:suggestedCitation($id)}
                  </div>
              </div>
          </div>
        </div>
        )
};


declare function app:registryWorks($node as node(), $model as map(*)) {
    
    let $works := $app:collectionWorks 
    let $worksOpus := $works//mei:workList//mei:title[@type = 'desc' and contains(., 'Opus')]/ancestor::mei:mei
    let $worksWoO := $works//mei:workList//mei:title[@type = 'desc' and contains(., 'WoO')]/ancestor::mei:mei
    let $perfRess := $works//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[not(@type = 'alt')]
    
    let $worksAlpha := for $work in $works
                            let $workName := $work//mei:workList//mei:title[@type = 'uniform']/normalize-space(text())
                            let $opus := $work//mei:workList//mei:title[@type = 'desc']/normalize-space(text())
                            let $withoutArticle := raffShared:replaceCutArticlesForSort($workName)
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
                            
                            let $workPerfRess := $work//mei:workList/mei:work[1]//mei:perfResList/mei:perfRes[not(@type = 'alt')]
                            let $perfDesc := string-join($workPerfRess, ' | ')
                            let $arranged := if(contains($work//mei:arranger, 'Raff')) then(true()) else (false())
                            let $lost := $work//mei:event[mei:head/text() = 'Textverlust']/mei:desc/text()
                            let $name := <div
                                            class="row RegisterEntry" titleToSort="{$withoutArticle}">
                                            <div
                                                class="col-sm-5 col-md-7 col-lg-8">
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
                                                            let $order := raffShared:replaceToSortDist($orderWithoutArticle)
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
                            
                            let $workPerfRess := $work//mei:workList/mei:work[1]//mei:perfResList/mei:perfRes[not(@type = 'alt')]
                            let $perfDesc := string-join($workPerfRess, ' | ')
                            let $arranged := if(contains($work//mei:arranger, 'Raff')) then(true()) else (false())
                            let $lost := $work//mei:event[mei:head/text() = 'Textverlust']/mei:desc/text()
                            let $name := <div
                                class="row RegisterEntry" titleToSort="{$withoutArticle}">
                                <div
                                    class="col-sm-5 col-md-7 col-lg-8">
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
                                            let $order := raffShared:replaceToSortDist($orderWithoutArticle)
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
        <div class="row  justify-content-between">
            <div class="col"/>
            <div class=".col-sm-3 	.col-md-3 	.col-lg-3">
                {app:filterInput()}
            </div>
        </div>
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
                    class="container row">
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
                                
                                let $workPerfRess := $work//mei:workList/mei:work[1]//mei:perfResList/mei:perfRes[not(@type = 'alt')]
                                let $perfDesc := string-join($workPerfRess, ' | ')
                                let $arranged := if(contains($work//mei:arranger, 'Raff')) then(true()) else (false())
                                let $lost := $work//mei:event[mei:head/text() = 'Textverlust']/mei:desc/text()
                                
                                order by $opus ascending
                                return
                                    <div
                                        class="row RegisterEntry">
                                        <div
                                            class="col-sm-4 col-md-3 col-lg-2">{$opus}
                                            <br/>
                                                {if($lost)
                                                then(<span class="sublevel">{concat('(', $lost, ')')}</span>)
                                                else()}</div>
                                        <div
                                            class="col-sm-5 col-md-7 col-lg-8">{$name}
                                            {if($perfDesc or $arranged)
                                                then(<br/>,<span class="sublevel">{if($arranged)then('Bearbeitet für ')else()}{$perfDesc}</span>)
                                                else()}
                                        </div>
                                        <div
                                            class="col-sm-3 col-md-2 col-lg-2"><a
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
                                
                                let $workPerfRess := $work//mei:workList/mei:work[1]//mei:perfResList/mei:perfRes[not(@type = 'alt')]
                                let $perfDesc := string-join($workPerfRess, ' | ')
                                let $arranged := if(contains($work//mei:arranger, 'Raff')) then(true()) else (false())
                                let $lost := $work//mei:event[mei:head/text() = 'Textverlust']/mei:desc/text()
                                
                                order by $opus ascending
                                return
                                    <div
                                        class="row RegisterEntry">
                                        <div
                                            class="col-sm-4 col-md-3 col-lg-2">{$opus}
                                            <br/>
                                                {if($lost)
                                                then(<span class="sublevel">{concat('(', $lost, ')')}</span>)
                                                else()}</div>
                                        <div
                                            class="col-sm-5 col-md-7 col-lg-8">{$name}
                                            {if($perfDesc or $arranged)
                                                then(<br/>,<span class="sublevel">{if($arranged)then('Bearbeitet für ')else()}{$perfDesc}</span>)
                                                else()}
                                        </div>
                                        <div
                                            class="col-sm-3 col-md-2 col-lg-2"><a
                                                href="work/{$workID}">{$workID}</a></div>
                                    </div>
                            }
                        </div>
                    </div>
                    <div id="navigator" class="col-sm-3 col-md-2 col-lg-2" style="align-content:right;">
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
                    <div id="navigatorTab2" class="list-group col-sm-4 col-md-3 col-lg-3" style="height:500px; overflow-y: scroll;">
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
                    <div data-spy="scroll" data-target="#navigatorTab2" data-offset="90" class="col-md col-sm col-lg" style="position: relative; height:500px; overflow-y: scroll;">
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
                    <div id="navigatorTab3" class="list-group col-sm-4 col-md-3 col-lg-3" style="height:500px; overflow-y: scroll;">
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
                    <div data-spy="scroll" data-target="#navigatorTab3" data-offset="90" class="col-lg col-md col-sm" style="position: relative; height:500px; overflow-y: scroll;">
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
                         <li
                     class="nav-item"><a
                         class="nav-link-jra"
                         data-toggle="tab"
                         href="#foreignMaterial">Fremdmaterial</a></li>
                         <li class="nav-item nav-linkless-jra d-flex justify-content-between"></li>
                </ul>
                <div class="tab-content">
                    <div
                        class="tab-pane fade show active"
                        id="vocalMusic">
                        <br/>
                            <div
                                class="row">
                                <div id="navigatorVocalMusic" class="list-group col-sm col-md col-lg" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-01-01">Chorwerke mit Orchester geistlich</div>
                                            {let $works := 'cat-01-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-01-01-01">Oratorien</div>
                                            {let $works := 'cat-01-01-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-01-01-02">Liturgische Werke</div>
                                            {let $works := 'cat-01-01-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-01-01-03">Andere Chorwerke</div>
                                            {let $works := 'cat-01-01-03'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-01-02">Chorwerke mit Orchester weltlich</div>
                                            {let $works := 'cat-01-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <!--<div
                                          class="RegisterSortEntry"
                                          id="cat-01-03">Chorwerke mit Klavier</div>
                                          {let $works := 'cat-01-03'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}-->
                                        <div
                                           class="RegisterSortEntry"
                                           id="cat-01-04">Chorwerke a cappella geistlich</div>
                                           {let $works := 'cat-01-04'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                           class="RegisterSortEntry"
                                           id="cat-01-05">Chorwerke a cappella weltlich</div>
                                           {let $works := 'cat-01-05'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-01-06">Ensembles mit Klavier</div>
                                            {let $works := 'cat-01-06'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-01-07">Lieder mit Orchester</div>
                                               {let $works := 'cat-01-07'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work 
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-01-08">Lieder mit Klavier</div>
                                            {let $works := 'cat-01-08'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
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
                                <div id="navigatorStageMusic" class="list-group col-sm col-md col-lg" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-02-01">Opern</div>
                                            {let $works := 'cat-02-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-02-02">Schauspielmusiken</div>
                                            {let $works := 'cat-02-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
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
                              <div id="navigatorOrchestralMusic" class="list-group col-sm col-md col-lg" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-03-01">Symphonien</div>
                                            {let $works := 'cat-03-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-03-02">Suiten</div>
                                            {let $works := 'cat-03-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                       <div
                                            class="RegisterSortEntry"
                                            id="cat-03-03">Konzertante Werke</div>
                                            {let $works := 'cat-03-03'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                      <div
                                            class="RegisterSortEntry"
                                            id="cat-03-04">Ouvertüren und Vorspiele</div>
                                            {let $works := 'cat-03-04'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                     <div
                                            class="RegisterSortEntry"
                                            id="cat-03-05">Andere Orchesterwerke</div>
                                            {let $works := 'cat-03-05'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
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
                            <div id="navigatorChamberMusic" class="list-group col-sm col-md col-lg" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-04-01">Kammermusik ohne Klavier</div>
                                            {let $works := 'cat-04-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-01-01">Sinfonietta</div>
                                            {let $works := 'cat-04-01-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-01-02">Oktett</div>
                                            {let $works := 'cat-04-01-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-01-03">Sextett</div>
                                            {let $works := 'cat-04-01-03'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-01-04">Streichquartette</div>
                                            {let $works := 'cat-04-01-04'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                       <div
                                            class="RegisterSortEntry"
                                            id="cat-04-02">Kammermusik mit Klavier</div>
                                            {let $works := 'cat-04-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-02-01">Klavierquintette</div>
                                            {let $works := 'cat-04-02-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-02-02">Klavierquartette</div>
                                            {let $works := 'cat-04-02-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-02-03">Klaviertrios</div>
                                            {let $works := 'cat-04-02-03'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-02-04">Horn und Klavier</div>
                                            {let $works := 'cat-04-02-04'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-04-03">Violine und Klavier</div>
                                            {let $works := 'cat-04-03'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-03-01">Sonaten</div>
                                            {let $works := 'cat-04-03-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-03-02">Andere Werke für Violine und Klavier</div>
                                            {let $works := 'cat-04-03-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-03-03">Fantasien und Variationen über fremde Themen für Violine und Klavier</div>
                                            {let $works := 'cat-04-03-03'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-04-04">Cello und Klavier</div>
                                            {let $works := 'cat-04-04'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-04-01">Sonaten</div>
                                            {let $works := 'cat-04-04-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-04-02">Andere Werke für Cello und Klavier</div>
                                            {let $works := 'cat-04-04-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-04-04-03">Fantasien und Variationen über fremde Themen für Cello und Klavier</div>
                                            {let $works := 'cat-04-04-03'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
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
                              <div id="navigatorPianoMusic" class="list-group col-sm col-md col-lg" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-05-01">Klavier zweihändig</div>
                                            {let $works := 'cat-05-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-05-01-01">Sonaten</div>
                                            {let $works := 'cat-05-01-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-05-01-02">Suiten</div>
                                            {let $works := 'cat-05-01-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-05-01-03">Weitere Stücke für Klavier zu zwei Händen</div>
                                            {let $works := 'cat-05-01-03'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry2"
                                            id="cat-05-01-04">Fantasien und Variationen über fremde Themen</div>
                                            {let $works := 'cat-05-01-04'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat} 
                                       <div
                                            class="RegisterSortEntry2"
                                            id="cat-05-01-05">Klavierauszüge</div>
                                            {let $works := 'cat-05-01-05'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-05-02">Klavier vierhändig</div>
                                            {let $works := 'cat-05-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-05-03">Zwei Klaviere</div>
                                            {let $works := 'cat-05-03'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-05-04">Orgel</div>
                                            {let $works := 'cat-05-04'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
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
                            <div id="navigatorArrangements" class="list-group col-sm col-md col-lg" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-06-01">Orchestrierungen</div>
                                            {let $works := 'cat-06-01'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-06-04">Klavierauszüge eigener Werke</div>
                                            {let $works := 'cat-05-01-05'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                        <div
                                            class="RegisterSortEntry"
                                            id="cat-06-03">Transkriptionen für Klavier</div>
                                            {let $works := 'cat-06-03'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                       <div
                                            class="RegisterSortEntry"
                                            id="cat-06-02">Kammermusik</div>
                                            {let $works := 'cat-06-02'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
                                                return
                                                    $worksByCat}
                                   </div>
                               </div>
                        </div>
                    </div>
                    <div
                        class="tab-pane fade"
                        id="foreignMaterial">
                        <br/>
                        <div
                            class="row">
                            <div id="navigatorForeign" class="list-group col-sm col-md col-lg" style="height:500px; overflow-y: scroll;">
                                    <div
                                        class="RegisterSortBox">
                                        <!--<div class="RegisterSortEntry"
                                            id="cat-06-01">Orchestrierungen</div>-->
                                            {let $works := 'cat-07'
                                                for $work in raffWorks:getWorks($works)
                                                let $worksByCat := $work
                                                order by raffShared:replaceToSortDist($worksByCat/@titleToSort)
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
    let $work := $app:collectionWorks/id($id)
    let $collection := $app:collectionInstitutions|
                       $app:collectionTexts|
                       $app:collectionSources
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
                     {if (raffShared:getReferences($id)) then(
                     <li
                         class="nav-item">
                         <a
                             class="nav-link-jra"
                             data-toggle="tab"
                             href="#references">Referenzen</a></li>
                             )else()}
                    {if(contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive') or contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
         then(<li
             class="nav-item"><a
                 class="nav-link-jra"
                 data-toggle="tab"
                 href="#viewXML">XML-Ansicht</a></li>)
                 else()}
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
         {transform:transform($work, doc("/db/apps/raffArchive/resources/xslt/metadataWork.xsl"), ())}
                     </div>
                     {
                         if (raffShared:getReferences($id))
                         then (<div
                                 class="tab-pane fade"
                                 id="references">
                                 <br/>
                                 <div >{
                                     let $entrys := raffShared:getReferences($id)
                                     return
                                         $entrys
                                 }</div>
                               </div>
                         )
                         else
                             ()
                     }
                     {if(contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive') or
                         contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
                     then(<div
                         class="tab-pane fade"
                         id="viewXML">
                             <pre>
                                 <xmp>
                                     {transform:transform($work/root(), doc("/db/apps/raffArchive/resources/xslt/viewXML.xsl"), ())}
                                 </xmp>
                             </pre>
                         </div>)
                     else()}
                 </div>
                 {raffShared:suggestedCitation($id)}
             </div>
         </div>
     </div>
  </div>
        )
};

declare function app:registryWritings($node as node(), $model as map(*)) {
    (:<div class="container">
        <ul>{
        for $entry in $app:collFullWritings
            let $entryID := $entry/@xml:id/string()
            return
                <li>{raffWritings:getTitle($entryID)}&#160;<a onclick="pleaseWait()" href="writing/{$entryID}">{$entryID}</a></li>
        }</ul>
    </div>:)
    
    let $writings := $app:collFullWritings
    
    let $writingsAlpha := for $writing in $writings
                            let $writingID := $writing/@xml:id/string()
                            let $title := $writing//tei:sourceDesc//tei:title[1]/text()
                            let $initial := substring(raffShared:replaceCutArticlesForSort($title), 1, 1)
                            let $author := $writing//tei:sourceDesc//tei:author[1]
                            let $pubPlace := $writing//tei:sourceDesc//tei:imprint/tei:pubPlace[1]
                            let $date := $writing//tei:sourceDesc//tei:imprint/tei:date[1]
                            
                            let $entry := <div
                                class="row RegisterEntry">
                                <div
                                    class="col">
                                    {$title}
                                    {<br/>,
                                     <span class="sublevel">
                                        {if($pubPlace != '' or $date != '')
                                        then(string-join(($pubPlace, $date),' '))
                                        else(<br/>)
                                        }
                                     </span>
                                    }
                                </div>
                                <div
                                    class="col-sm-3 col-md-2 col-lg-2"><a  onclick="pleaseWait()"
                                        href="writing/{$writingID}">{$writingID}</a></div>
                            </div>
                                group by $initial
                                order by $initial
                            return
                                (<div
                                    name="{$initial}"
                                    count="{count($entry)}">
                                    {
                                        for $each in $entry
                                        let $order := raffShared:replaceToSortDist($each)
                                            order by $order
                                        return
                                            $each
                                    }
                                </div>)
    
    let $WritingsGroupedByInitials := for $groups in $writingsAlpha
                                        group by $initial := $groups/@name/string()
                                        return
                                            (<div
                                                class="RegisterSortBox"
                                                initial="{$initial}"
                                                count="{$writingsAlpha[@name=$initial]/@count}"
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
                                                            ('[ohne Initial]')
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
                    <div class="row  justify-content-between">
                        <div class="col-sm-9 	col-md-7 	col-lg-7">
                            <p>Der Katalog verzeichnet derzeit {count($writings)} Schriften.</p>
                        </div>
                        <div class=".col-sm-3 	.col-md-3 	.col-lg-3">
                            {app:filterInput()}
    </div>
                    </div>
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
                                href="#alpha" onclick="pleaseWait()">Jahr</a></li>
                        <li
                            class="nav-item"><a
                                class="nav-link-jra"
                                href="#alpha" onclick="pleaseWait()">Ort</a></li>
                    </ul>
                    <div
                        class="tab-content">
                        <div
                            class="tab-pane fade show active"
                            id="alpha">
                            <br/>
                            <div
                                class="container row">
                                <div id="navigator" class="list-group col-sm-4 col-md-3 col-lg-3" style="height:500px; overflow-y: scroll;">
            					   <ul id="nav" class="nav hidden-xs hidden-sm"> <!-- position: relative; style="height: 500px; overflow-y: scroll; width: 200px;" -->
                                    {
                                        for $each in $WritingsGroupedByInitials
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
                                                            ('[weitere]')
                                                        else
                                                            ($initial)
                                                    }</span>
                                                <span
                                                    class="badge badge-jra badge-pill right">{$count}</span>
                                            </a>
                                    }
                                
                                </ul>
                                </div>
                                <div id="divResults" data-spy="scroll" data-target="#navigator" data-offset="90" class="col-sm col-md col-lg" style="position: relative; height:500px; overflow-y: scroll;">
                                    {$WritingsGroupedByInitials}
                                </div>
                            </div>
                        </div>
            </div>
        </div>
    
};

declare function app:writing($node as node(), $model as map(*)) {
    
    let $id := request:get-parameter("writing-id", "E00000")
    let $writing := $app:collectionWritings/id($id)
    let $collection := $app:collectionInstitutions|
                       $app:collectionTexts|
                       $app:collectionSources
    let $naming := $collection//tei:title[@key=$id]/ancestor::tei:TEI
    let $name := raffWritings:getTitle($id)
    
    return
        (
  <div
    class="container">
     <div
         class="page-header">
         <h2>{$name}</h2>
         <hr/>
         <ul class="nav nav-pills"
                     role="tablist">
                     <li
                         class="nav-item">
                         <a
                             class="nav-link-jra active"
                             data-toggle="tab"
                             href="#metadata">Allgemein</a></li>
                     <li
                         class="nav-item">
                         <a
                             class="nav-link-jra"
                             data-toggle="tab"
                             href="#fulltext">Volltext</a></li>
                     {if (raffShared:getReferences($id)) then(
                     <li
                         class="nav-item">
                         <a
                             class="nav-link-jra"
                             data-toggle="tab"
                             href="#references">Referenzen</a></li>
                             )else()}
                    {if(contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive') or contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
         then(<li
             class="nav-item"><a
                 class="nav-link-jra"
                 data-toggle="tab"
                 href="#viewXML">XML-Ansicht</a></li>)
                 else()}
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
         {transform:transform($writing//tei:teiHeader, doc("/db/apps/raffArchive/resources/xslt/metadataWriting.xsl"), ())}
                     </div>
                     <div
                         class="tab-pane fade"
                         id="fulltext">
                         <br/>
         <div class="row">
            <div class="col">
            {transform:transform($writing//tei:text, doc("/db/apps/raffArchive/resources/xslt/contentWriting.xsl"), ())}
            </div>
            <div class="col-2">
               <h5>Navigation</h5>
               <div style="height:400px; overflow-y: scroll;">
               <ul class="nav flex-column">
               <a class="nav-link" href="#fulltextTitel">Titelseite</a>
               {
               for $pb in $writing//tei:text//tei:pb[@n]
                   let $pageNo := $pb/@n/string()
                   let $pageNoRoman := if($pb[@rend = 'roman'])
                                       then(switch ($pageNo)
                                            case '1' return 'I'
                                            case '2' return 'II'
                                            case '3' return 'III'
                                            case '4' return 'IV'
                                            case '5' return 'V'
                                            case '6' return 'VI'
                                            case '7' return 'VII'
                                            case '8' return 'VIII'
                                            case '9' return 'IX'
                                            case '10' return 'X'
                                            default return $pageNo)
                                       else()
                   let $pageNoLabel := if($pageNoRoman) then($pageNoRoman) else($pageNo)
                   return
                   <li class="nav-item"><a class="nav-link" href="{string-join(('#page', $pageNo, $pb/@rend), '-')}">Seite {$pageNoLabel}</a></li>
               }</ul>
               </div>
            </div>
            </div>
                     </div>
                     {
                         if (raffShared:getReferences($id))
                         then (<div
                                 class="tab-pane fade"
                                 id="references">
                                 <br/>
                                 <div >{
                                     let $entrys := raffShared:getReferences($id)
                                     return
                                         $entrys
                                 }</div>
                               </div>
                         )
                         else
                             ()
                     }
                     {if(contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive') or
                         contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
                     then(<div
                         class="tab-pane fade"
                         id="viewXML">
                             <pre>
                                 <xmp>
                                     {transform:transform($writing/root(), doc("/db/apps/raffArchive/resources/xslt/viewXML.xsl"), ())}
                                 </xmp>
                             </pre>
                         </div>)
                     else()}
                 </div>
                 {raffShared:suggestedCitation($id)}
             </div>
         </div>
     </div>
  </div>
        )
};

declare function app:aboutProject($node as node(), $model as map(*)) {
    
    let $text := doc("/db/apps/jraTexts/data/portal/aboutProject.xml")/tei:TEI
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
    
    let $text := doc("/db/apps/jraTexts/data/portal/aboutRaff.xml")/tei:TEI
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

declare function app:aboutArchive($node as node(), $model as map(*)) {
    
    let $text := doc("/db/apps/jraTexts/data/portal/aboutArchive.xml")/tei:TEI
    let $title := $text//tei:titleStmt/tei:title/text()
    let $subtitle := $text//tei:sourceDesc/tei:p[1]/text()
    
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
    
    let $text := doc("/db/apps/jraTexts/data/portal/aboutDocumentation.xml")/tei:TEI
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
    
    let $text := doc("/db/apps/jraTexts/data/portal/aboutResources.xml")/tei:TEI
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
    
    let $text := doc('/db/apps/jraTexts/data/portal/index.xml')
    
    return
        (
        <div
            class="container">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        )
};

declare function app:impressum($node as node(), $model as map(*)) {
    
    let $text := doc("/db/apps/jraTexts/data/portal/impressum.xml")/tei:TEI
    
    return
        (
        <div class="title-b">Kontakt</div>,
        <div>
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        )
};

declare function app:privacyPolicy($node as node(), $model as map(*)) {
    
    let $text := doc("/db/apps/jraTexts/data/portal/privacyPolicy.xml")/tei:TEI
    
    return
        (
        <div
            class="container">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        )
};

declare function app:disclaimer($node as node(), $model as map(*)) {
    
    let $text := doc("/db/apps/jraTexts/data/portal/disclaimer.xml")/tei:TEI
    
    return
        (
        <div
            class="container">
            {transform:transform($text, doc("/db/apps/raffArchive/resources/xslt/portal.xsl"), ())}
        </div>
        )
};

declare function app:countLetters($node as node(), $model as map(*)){
let $count := count($app:collectionPostals)
return
    (<p class="counter">{$count}</p>,
    <span class="counter-text">Postsachen</span>)
};
declare function app:countWorks($node as node(), $model as map(*)){
let $count := count($app:collectionWorks)
return
    (<p class="counter">{$count}</p>,
    <span class="counter-text">Werke</span>)
};
declare function app:countPersons($node as node(), $model as map(*)){
let $count := count($app:collectionPersons)
return
    (<p class="counter">{$count}</p>,
    <span class="counter-text">Personen</span>)
};
declare function app:countInstitutions($node as node(), $model as map(*)){
let $count := count($app:collectionInstitutions)
return
    (<p class="counter">{$count}</p>,
    <span class="counter-text">Institutionen</span>)
};

declare function app:countWritings($node as node(), $model as map(*)){
let $count := count($app:collectionWritings)
return
    (<p class="counter">{$count}</p>,
    <span class="counter-text">Schriften</span>)
};

declare function app:alert($node as node(), $model as map(*)){
    if (contains(request:get-url(),'http://localhost:8080/exist/apps/raffArchive'))
    then (
            <div class="alert alert-info" role="alert" style="padding-top: 67px;">
               Raff-Portal Entwicklung –  Sie befinden sich auf http://localhost:8080
            </div>
         )
         
    else if (contains(request:get-url(),'http://localhost:8088/exist/apps/raffArchive'))
    then (
            <div class="alert alert-warning" role="alert" style="padding-top: 67px;">
               Raff-Portal intern: Diese Umgebung kann sich in Inhalt und Erscheinung vom offiziellen Raff-Portal unterscheiden! Sie befinden sich auf https://dev.raff-archiv.ch
            </div>
         )
    
    else ()
};

declare function app:portalVersion($node as node(), $model as map(*)){
 let $package := doc('/db/apps/raffArchive/expath-pkg.xml')
 let $version := $package//pkg:package/@version/string()
    return
        <p class="subtitle-b">{concat('(Version ',$version,')')}</p>
};

declare function app:errorReport($node as node(), $model as map(*)){

let $errorReportDir := '/db/apps/raffArchive/errors/'
let $url := request:get-url()
let $date := substring-before(string(current-dateTime()), '+')
let $error := <error url="{$url}" timeStamp="{$date}"/>
let $logIn := xmldb:login($errorReportDir,'errors', 'errorReport12345')
let $store := xmldb:store($errorReportDir, concat('error_', replace($date,':','-'), '.xml'), $error)
let $errorReport := if(contains($url, 'http://localhost:8080/exist/apps/raffArchive'))
                    then(<pre class="error templates:error-description"/>)
                    else()
return
    $errorReport
};

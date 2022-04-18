xquery version "3.1";

module namespace raffShared="https://portal.raff-archiv.ch/ns/raffShared";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace hc = "http://expath.org/ns/http-client";
declare namespace response = "http://exist-db.org/xquery/response";

import module namespace app="https://portal.raff-archiv.ch/templates" at "/db/apps/raffArchive/modules/app.xql";
import module namespace raffPostals="https://portal.raff-archiv.ch/ns/raffPostals" at "/db/apps/raffArchive/modules/raffPostals.xqm";
import module namespace raffWritings="https://portal.raff-archiv.ch/ns/raffWritings" at "/db/apps/raffArchive/modules/raffWritings.xqm";
import module namespace raffWorks="https://portal.raff-archiv.ch/ns/raffWorks" at "/db/apps/raffArchive/modules/raffWorks.xqm";
import module namespace i18n="http://exist-db.org/xquery/i18n" at "i18n.xql";

import module namespace templates = "http://exist-db.org/xquery/html-templating";
(:import module namespace config="https://portal.raff-archiv.ch/config" at "/db/apps/raffArchive/modules/config.xqm";:)
import module namespace request="http://exist-db.org/xquery/request";
import module namespace transform="http://exist-db.org/xquery/transform";

import module namespace functx="http://www.functx.com" at "/db/apps/raffArchive/modules/functx.xqm";
import module namespace json="http://www.json.org";
import module namespace jsonp="http://www.jsonp.org";


(:  Schön formatiertes Datum: format-date($date, "[D]. [MNn,*-4] [Y]", $lang, (), ()) :)

declare function raffShared:get-lang() as xs:string? {
  let $lang := if(string-length(request:get-parameter("lang", "")) gt 0) then
      (: use http parameter lang as selected language :)
      request:get-parameter("lang", "")
  else
     if(string-length(request:get-cookie-value("forceLang")) gt 0) then
       request:get-cookie-value("forceLang")
     else
       raffShared:get-browser-lang()
  (: limit to de and en; en default :)
  return if($lang != "en" and $lang != "de") then "en" else $lang
};


(:~ 
: i18n text from a TEI file
:
: @param $doc the docuemtent node to process
:
: @return html
:)

declare function raffShared:getI18nText($doc) {
    let $lang := raffShared:get-lang()
    return
        if ($lang != 'de')
        then (
            
            (: Is there tei:div[@xml:lang] ?:)
            if (exists($doc//tei:body/tei:div[@xml:lang]))
            then (
            
                (: Is there a $lang summary? :)
                if ($doc//tei:body/tei:div[@xml:lang = $lang and exists(@type = 'summary')])
                then (
                    transform:transform($doc//tei:body/tei:div[@xml:lang = $lang and @type = 'summary'], $raffShared:xsltTEI, ()),
                    transform:transform($doc//tei:body/tei:div[@xml:lang = 'de'], $raffShared:xsltTEI, ())
                )
                
                (: No $lang or 'en' summary but $lang tei:div (text)? :)
                else if ($doc//tei:body/tei:div[@xml:lang = $lang])
                then (
                    transform:transform($doc//tei:body/tei:div[@xml:lang = $lang], $raffShared:xsltTEI, ())
                )
            
                (: Is there no $lang summary but an 'en' summary? :)
                else if ($doc//tei:body/tei:div[@xml:lang = 'en' and exists(@type = 'summary')])
                then (
                    transform:transform($doc//tei:body/tei:div[@xml:lang = 'en' and @type = 'summary'], $raffShared:xsltTEI, ()),
                    transform:transform($doc//tei:body/tei:div[@xml:lang = 'de'], $raffShared:xsltTEI, ())
                )
                
                (: No summary but 'en' tei:div (text)? :)
                else if ($doc//tei:body/tei:div[@xml:lang = 'en'])
                then (
                    transform:transform($doc//tei:body/tei:div[@xml:lang = 'en'], $raffShared:xsltTEI, ())
                )
            
                (: There is no other tei:div than 'de' :)
                else (
                    transform:transform($doc//tei:body/tei:div[@xml:lang = 'de'], $raffShared:xsltTEI, ())
                )
        
            )
            
            (: No tei:div[@xml:lang]:)
            else (transform:transform($doc//tei:body/tei:div, $raffShared:xsltTEI, ()))
        )
        
        (: $lang = 'de' :)
        else (
            if (exists($doc//tei:body/tei:div[@xml:lang]))
            then (transform:transform($doc//tei:body/tei:div[@xml:lang = $lang]/*, $raffShared:xsltTEI, ()))
            else (transform:transform($doc//tei:body/tei:div, $raffShared:xsltTEI, ()))
        )
};


declare function raffShared:translate($content) {
    let $content := element i18n:text {
                        attribute key {$content}
                    }
    return
        i18n:process($content, '', '/db/apps/raffArchive/resources/lang', 'en')
};


(:~
: List all strings from list and retrun html <option>-Element
:
: @param $node the node
: @param $model the model
: @param $listName the requested options list
:
: @return a html <option>-Element ordered by translated option labels.
:
:)



(: DATES:)


(:~
: Return month names from month numbers in dates
:
: @param $monthNo the number of month (1…12)
: @param $lang the requested language
:
: @return a month name.
:
:)

declare function raffShared:monthName($monthNo as xs:integer) as xs:string {
    let $lang := raffShared:get-lang()

    return
    if ($lang = 'de')
    then (
        ('Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember')[$monthNo]
    )
    else (
        ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')[$monthNo]
    )
};


(:~
: Format our custom dates
:
: @param $dateVal the string with custom date to be analyzed, picture 0000-00-00
:
: @return a date string.
:
:)



declare function raffShared:formatDate($date, $form as xs:string, $lang as xs:string) as xs:string {
    let $date := if (functx:atomic-type($date) = 'xs:date')
                    then ($date)
                    else ($date/@when/string())
    return
        if ($form = 'full')
        then (format-date($date, "[D1o]&#160;[MNn]&#160;[Y]", $lang, (), ()))
        else (format-date($date, "[D].[M].[Y]", $lang, (), ()))
};


(:~
: Shorten (if possible) and format two xs:date with respect to language and desired form
:
: @param $dateFrom the start date
: @param $dateTo the end date
: @param $form the form (e.g. full, short, …)
: @param $lang the requested language
:
: @return a i18n date string.
:
: ToDo: find the right type of $date for raffShared:getBirthDeathDates
:
:)

declare function raffShared:shortenAndFormatDates($dateFrom, $dateTo, $form as xs:string, $lang as xs:string) as xs:string {
    if ($form = 'full' and (month-from-date($dateFrom) = month-from-date($dateTo)) and (year-from-date($dateFrom) = year-from-date($dateTo)))
    then (
        concat(
            day-from-date($dateFrom), '.–', day-from-date($dateTo), '. ',
            format-date($dateFrom, "[MNn] [Y]", $lang, (), ())
        )
    )
    else if ($form = 'full' and (year-from-date($dateFrom) = year-from-date($dateTo)))
    then (
        concat(
            day-from-date($dateFrom), '. ', format-date($dateFrom, "[MNn]", $lang, (), ()),
            '–',
            day-from-date($dateTo), '. ', format-date($dateTo, "[MNn] ", $lang, (), ()),
            year-from-date($dateFrom)
        )
    )
    else if ($form = 'full')
    then (
        concat(
            format-date($dateFrom, "[D]. [MNn] [Y]", $lang, (), ()),
            '–',
            format-date($dateTo, "[D]. [MNn] [Y]", $lang, (), ())
        )
    )
    else (
        concat(
            format-date($dateFrom, "[D].[M].[Y]", $lang, (), ()),
            '–',
            format-date($dateTo, "[D].[M].[Y]", $lang, (), ())
        )
    )
};


declare function raffShared:getBirthDeathDates($dates, $lang) {
    let $date := if ($dates/tei:date)
                        then (raffShared:formatDate($dates/tei:date, 'full', $lang))
                        else ()
    let $datePlace := if ($dates/tei:placeName/text())
                        then (normalize-space($dates/tei:placeName/text()))
                        else ()
    return
        if ($date and $datePlace)
        then (concat($date, ', ', $datePlace))
        else if ($date)
        then ($date)
        else if ($date = '' and $datePlace = '')
        then (raffShared:translate('unknown'))
        else if ($datePlace)
        then (concat($datePlace, ', ', raffShared:translate('dateUnknown')))
        else (raffShared:translate('unknown'))
};

declare function raffShared:any-equals-any($args as xs:string*, $searchStrings as xs:string*) as xs:boolean {
    some $arg in $args
    satisfies
        some $searchString in $searchStrings
        satisfies
            $arg = $searchString
};

declare function raffShared:queryKey() {
  functx:substring-before-if-contains(concat(request:get-uri(), request:get-query-string()), "firstRecord")
};



(: Patrick integrates https://jaketrent.com/post/xquery-browser-language-detection/ :)

declare function raffShared:get-browser-lang() as xs:string? {
  let $header := request:get-header("Accept-Language")
  return if (fn:exists($header)) then
    raffShared:get-top-supported-lang(raffShared:get-browser-langs($header), ("de", "en"))
  else
    ()
};

declare function raffShared:get-top-supported-lang($ordered-langs as xs:string*, $translations as xs:string*) as xs:string? {
  if (fn:empty($ordered-langs)) then
    ()
  else
    let $lang := $ordered-langs[1]
    return if ($lang = $translations) then
      $lang
    else
      raffShared:get-top-supported-lang(fn:subsequence($ordered-langs, 2), $translations)
};

declare function raffShared:get-browser-langs($header as xs:string) as xs:string* {
  let $langs :=
    for $entry in fn:tokenize(raffShared:parse-header($header), ",")
    let $data := fn:tokenize($entry, "q=")
    let $quality := $data[2]
    order by
      if (fn:exists($quality) and fn:string-length($quality) gt 0) then
  xs:float($quality)
      else
  xs:float(1.0)
      descending
    return $data[1]
  return $langs
};

declare function raffShared:parse-header($header as xs:string) as xs:string {
  let $regex := "(([a-z]{1,8})(-[a-z]{1,8})?)\s*(;\s*q\s*=\s*(1|0\.[0-9]+))?"
  let $flags := "i"
  let $format := "$2q=$5"
  return fn:replace(fn:lower-case($header), $regex, $format)
};


declare function raffShared:getSelectedLanguage($node as node()*,$selectedLang as xs:string) {
    raffShared:get-lang()
};

declare function raffShared:getDate($date) {
    let $type := $date/tei:date/@type
    let $get := if(count($date/tei:date[matches(@type,'^editor')])=1)
                then(
                        if($date/tei:date[matches(@type,'^editor')]/@when)
                        then($date/tei:date[matches(@type,'^editor')]/@when/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@when-custom)
                        then($date/tei:date[matches(@type,'^editor')]/@when-custom/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@from)
                        then($date/tei:date[matches(@type,'^editor')]/@from/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@from-custom)
                        then($date/tei:date[matches(@type,'^editor')]/@from-custom/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@notBefore)
                        then($date/tei:date[matches(@type,'^editor')]/@notBefore/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@notAfter)
                        then($date/tei:date[matches(@type,'^editor')]/@notAfter/string())
                        else('0000-00-00')
                    )
                else if(count($date/tei:date[matches(@type,'^source')])=1)
                then(
                        if($date/tei:date[matches(@type,'^source')]/@when)
                        then($date/tei:date[matches(@type,'^source')]/@when/string())
                        else if($date/tei:date[matches(@type,'^source')]/@when-custom)
                        then($date/tei:date[matches(@type,'^source')]/@when-custom/string())
                        else if($date/tei:date[matches(@type,'^source')]/@from)
                        then($date/tei:date[matches(@type,'^source')]/@from/string())
                        else if($date/tei:date[matches(@type,'^source')]/@from-custom)
                        then($date/tei:date[matches(@type,'^source')]/@from-custom/string())
                        else if($date/tei:date[matches(@type,'^source')]/@notBefore)
                        then($date/tei:date[matches(@type,'^source')]/@notBefore/string())
                        else if($date/tei:date[matches(@type,'^source')]/@notAfter)
                        then($date/tei:date[matches(@type,'^source')]/@notAfter/string())
                        else('0000-00-00')
                    )
                else if(count($date/tei:date[matches(@type,'^editor') and @confidence])=1)
                then(
                       $date/tei:date[matches(@type,'^editor') and not(matches(@confidence,'0.5'))][@confidence = max(@confidence)]/@when
                    )
                else if(count($date/tei:date[matches(@type,'^source') and @confidence])=1)
                then(
                       $date/tei:date[matches(@type,'^source') and not(matches(@confidence,'0.5'))][@confidence = max(@confidence)]/@when
                    )
                    else if($date/tei:date[matches(@type,'^editor') and matches(@confidence,'0.5')])
                then(
                       $date/tei:date[matches(@type,'^editor') and matches(@confidence,'0.5')][1]/@when
                    )
                else if($date/tei:date[matches(@type,'^source') and matches(@confidence,'0.5')])
                then(
                       $date/tei:date[matches(@type,'^source') and matches(@confidence,'0.5')][1]/@when
                    )
                else if($date/tei:date[matches(@type,'^editor')])
                then(
                        if($date/tei:date[matches(@type,'^editor')]/@when)
                        then($date/tei:date[matches(@type,'^editor')][1]/@when/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@when-custom)
                        then($date/tei:date[matches(@type,'^editor')][1]/@when-custom/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@from)
                        then($date/tei:date[matches(@type,'^editor')][1]/@from/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@from-custom)
                        then($date/tei:date[matches(@type,'^editor')][1]/@from-custom/string())
                        else if($date/tei:date[matches(@type,'^editor')]/@notBefore)
                        then($date/tei:date[matches(@type,'^editor')][1]/@notBefore/string())
                        else('0000-00-00')
                    )
                else if(count($date/tei:date[matches(@type,'^source')]))
                then(
                        if($date/tei:date[matches(@type,'^source')]/@when)
                        then($date/tei:date[matches(@type,'^source')][1]/@when/string())
                        else if($date/tei:date[matches(@type,'^source')]/@when-custom)
                        then($date/tei:date[matches(@type,'^source')][1]/@when-custom/string())
                        else if($date/tei:date[matches(@type,'^source')]/@from)
                        then($date/tei:date[matches(@type,'^source')][1]/@from/string())
                        else if($date/tei:date[matches(@type,'^source')]/@from-custom)
                        then($date/tei:date[matches(@type,'^source')][1]/@from-custom/string())
                        else if($date/tei:date[matches(@type,'^source')]/@notBefore)
                        then($date/tei:date[matches(@type,'^source')][1]/@notBefore/string())
                        else if($date/tei:date[matches(@type,'^source')]/@notAfter)
                        then($date/tei:date[matches(@type,'^source')][1]/@notAfter/string())
                        else('0000-00-00')
                    )
                else('0000-00-00')
                
    return
        $get
};

declare function raffShared:formatDate($dateRaw){
    let $date :=  if(string-length($dateRaw)=10 and not(contains($dateRaw,'-00')) and not(contains($dateRaw,'0000-')))
                  then(format-date(xs:date($dateRaw),'[D]. [M,*-3]. [Y]','de',(),()))
                  else if($dateRaw =('0000','0000-00','0000-00-00'))
                  then('[undatiert]')
                  else if(string-length($dateRaw)=7 and not(contains($dateRaw,'00')))
                  then (concat(upper-case(substring(format-date(xs:date(concat($dateRaw,'-01')),'[Mn,*-3]. [Y]','de',(),()),1,1)),substring(format-date(xs:date(concat($dateRaw,'-01')),'[Mn,*-3]. [Y]','de',(),()),2)))
                  else if(contains($dateRaw,'0000-') and contains($dateRaw,'-00'))
                  then (concat(upper-case(substring(format-date(xs:date(replace(replace($dateRaw,'0000-','9999-'),'-00','-01')),'[Mn,*-3].','de',(),()),1,1)),substring(format-date(xs:date(replace(replace($dateRaw,'0000-','9999-'),'-00','-01')),'[Mn,*-3].','de',(),()),2)))
                  else if(starts-with($dateRaw,'0000-'))
                  then(concat(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[D]. ','de',(),()),upper-case(substring(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[Mn,*-3]. ','de',(),()),1,1)),substring(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[Mn,*-3].','de',(),()),2)))
                  else($dateRaw)
    
    let $replaceMay := $date => replace('Mai.','Mai') => replace('May.','May')
    return
        $replaceMay
};

declare function raffShared:getDateRegistryLetters($correspAction as node()*) as array(*) {
    
    let $dateEditors := $correspAction/tei:date[matches(@type,'^editor')]
    let $dateEditor := $dateEditors[1]
    let $dateEditorType := $dateEditor/@type/string()
    
    let $dateSources := $correspAction/tei:date[matches(@type,'^source')]
    let $dateSource := $dateSources[1]
    let $dateSourceType := $dateSource/@type/string()
    
    let $get := if($dateEditor)
                then(
                        if($dateEditor/@when)
                        then($dateEditor/@when/string())
                        
                        else if($dateEditor/@when-custom)
                        then($dateEditor/@when-custom/string())
                        
                        else if($dateEditor/@from)
                        then($dateEditor/@from/string())
                        
                        else if($dateEditor/@from-custom)
                        then($dateEditor/@from-custom/string())
                        
                        else if($dateEditor/@notBefore)
                        then( if(substring($dateEditor/@notBefore,6,2) = '01')
                              then(
                                   if(substring($dateEditor/@notBefore,9,2) = '01')
                                   then(substring($dateEditor/@notBefore,1,4))
                                   else($dateEditor/@notBefore)
                                  )
                              else ($dateEditor/@notBefore)
                            )
                        else if($dateEditor/@notAfter)
                        then($dateEditor/@notAfter/string())
                        
                        else('0000-00-00')
                    )
                else if($dateSource)
                then(
                        if($dateSource/@when)
                        then($dateSource/@when/string())
                        else if($dateSource/@when-custom)
                        then($dateSource/@when-custom/string())
                        else if($dateSource/@from)
                        then($dateSource/@from/string())
                        else if($dateSource/@from-custom)
                        then($dateSource/@from-custom/string())
                        else if($dateSource/@notBefore)
                        then($dateSource/@notBefore/string())
                        else if($dateSource/@notAfter)
                        then($dateSource/@notAfter/string())
                        else('0000-00-00')
                    )
                else if($dateEditor[@confidence])
                then($dateEditor[not(matches(@confidence,'0.5'))][@confidence = max(@confidence)]/@when)
                else if($dateSource[@confidence])
                then($dateSource[not(matches(@confidence,'0.5'))][@confidence = max(@confidence)]/@when)
                    else if($dateEditor[matches(@confidence,'0.5')])
                then($dateEditor[matches(@confidence,'0.5')]/@when)
                else if($dateSource[matches(@confidence,'0.5')])
                then($dateSource[matches(@confidence,'0.5')]/@when)
                else if($dateEditor)
                then(
                        if($dateEditor/@when)
                        then($dateEditor/@when/string())
                        else if($dateEditor/@when-custom)
                        then($dateEditor/@when-custom/string())
                        else if($dateEditor/@from)
                        then($dateEditor/@from/string())
                        else if($dateEditor/@from-custom)
                        then($dateEditor/@from-custom/string())
                        else if($dateEditor/@notBefore)
                        then($dateEditor/@notBefore/string())
                        else('0000-00-00')
                    )
                else if($dateSource)
                then(
                        if($dateSource/@when)
                        then($dateSource/@when/string())
                        else if($dateSource/@when-custom)
                        then($dateSource/@when-custom/string())
                        else if($dateSource/@from)
                        then($dateSource/@from/string())
                        else if($dateSource/@from-custom)
                        then($dateSource/@from-custom/string())
                        else if($dateSource/@notBefore)
                        then($dateSource/@notBefore/string())
                        else if($dateSource/@notAfter)
                        then($dateSource/@notAfter/string())
                        else('0000-00-00')
                    )
                else('0000-00-00')

    let $type := if($dateEditorType)
                 then($dateEditorType)
                 else if ($dateSourceType)
                 then ($dateSourceType)
                 else ('noType')

    return
        [$get, $type]
};

declare function raffShared:formatDateRegistryLetters($dateArray){
    let $dateRaw := $dateArray(1)
    let $type := $dateArray(2)
    let $date :=  if(string-length($dateRaw)=10 and not(contains($dateRaw,'00')))
                  then(format-date(xs:date($dateRaw),'[D]. [M,*-3]. [Y]','de',(),()))
                  else if($dateRaw =('0000','0000-00','0000-00-00'))
                  then('[undatiert]')
                  else if(string-length($dateRaw)=7 and not(contains($dateRaw,'00')))
                  then (concat(upper-case(substring(format-date(xs:date(concat($dateRaw,'-01')),'[Mn,*-3]. [Y]','de',(),()),1,1)),substring(format-date(xs:date(concat($dateRaw,'-01')),'[Mn,*-3]. [Y]','de',(),()),2)))
                  else if(contains($dateRaw,'0000-') and contains($dateRaw,'-00'))
                  then (concat(upper-case(substring(format-date(xs:date(replace(replace($dateRaw,'0000-','9999-'),'-00','-01')),'[Mn,*-3].','de',(),()),1,1)),substring(format-date(xs:date(replace(replace($dateRaw,'0000-','9999-'),'-00','-01')),'[Mn,*-3].','de',(),()),2)))
                  else if(starts-with($dateRaw,'0000-'))
                  then(concat(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[D]. ','de',(),()),upper-case(substring(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[Mn,*-3]. ','de',(),()),1,1)),substring(format-date(xs:date(replace($dateRaw,'0000-','9999-')),'[Mn,*-3].','de',(),()),2)))
                  else($dateRaw)
    
    let $replace := replace($date,'Mai.','Mai')
    let $bracketify := if(matches($type, 'editor')) then(concat('[', $replace, ']')) else($replace)
    return
        $bracketify
};

declare function raffShared:getBirth($person){
if ($person//tei:birth[1][@when-iso])
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
                    ('noBirth')
};
declare function raffShared:getDeath($person){
if ($person//tei:death[1][@when-iso])
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
                    ('noDeath')
                    };

declare function raffShared:formatLifedata($lifedata){
if(starts-with($lifedata,'-')) then(concat(substring(string(number($lifedata)),2),' v. Chr.')) else($lifedata)
};

declare function raffShared:getLifedata($person){
let $birth := if(raffShared:getBirth($person)='noBirth')then()else(raffShared:getBirth($person))
let $birthFormatted := raffShared:formatLifedata($birth)

let $death := if(raffShared:getDeath($person)='noDeath')then()else(raffShared:getDeath($person))
let $deathFormatted := if (contains($birthFormatted, ' v. Chr.') and not(contains(raffShared:formatLifedata($death), 'v. Chr.')))
                       then(concat(number(raffShared:formatLifedata($death)), ' n. Chr.'))
                       else (raffShared:formatLifedata($death))

let $lifedata:= if ($birthFormatted[. != ''] and $deathFormatted[. != ''])
                then
                    (concat(' (', $birthFormatted, '–', $deathFormatted, ')'))
                else
                    if ($birthFormatted and not($deathFormatted))
                    then
                        (concat(' (*', $birthFormatted, ')'))
                    else
                        if ($deathFormatted and not($birthFormatted))
                        then
                            (concat(' (†', $deathFormatted, ')'))
                        else
                            ()
    return
        $lifedata
                };

declare function raffShared:get-digitalization-tei-as-html($facsimile as node()*){
    
    let $surfaces := $facsimile/tei:surface
    let $images := for $surface at $n in $surfaces
                    let $url := $surface/tei:graphic/@url
                    let $publisher := $surface//tei:bibl[1]/tei:publisher/text()
                    let $publisherSwitched := switch ($publisher)
                                                case 'D-Mbs' return 'Bayerische Staatsbibliothek München (BSB)'
                                                case 'D-Dl' return 'Sächsische Landesbibliothek Dresden (SLUB)'
                                                default return $publisher
                    let $request := if($publisher = 'D-Mbs')
                                    then(hc:send-request(<hc:request method="GET"/>, $url))
                                    else()
                    
                    let $img := if($publisher = 'D-Mbs')
                                then(
                                        let $imgLinkBSB := $request//xhtml:img[@alt="Image"]/@src/string()
                                        let $imgLinkJRA := concat('https://daten.digitale-sammlungen.de',$imgLinkBSB)
                                        return
                                           <img src="{$imgLinkJRA}" class="img-fluid mx-auto d-block img-thumbnail" width="75%"/>
                                    )
                                else if($publisher = 'D-Dl')
                                then(
                                        let $imgLinkJRA := concat('https://digilib.baumann-digital.de/JRA/',$url,'?dh=1000&amp;dw=1000')
                                        return
                                           <img src="{$imgLinkJRA}" class="img-fluid mx-auto d-block img-thumbnail" width="75%"/>
                                    )
                                else(<img src="https://digilib.baumann-digital.de/JRA/img/JRA-Logo.png?dh=200" heigth="200"/>)
                    return
                        <div class="test tab-pane fade {if($n=1)then(' show active')else()}" id="facsimile-{$n}">
                            <hr/>
                            <div class="container">
                                {$img}
                            </div>
                            <hr/>
                            <div>
                            <table>
                                {if($publisher = 'D-Mbs')
                                then(<tr>
                                <td>Zum Digitalisat:</td>
                                <td><a href="{$url}" target="_blank">{$url/string()}</a></td>
                                </tr>)
                                else()}
                                {if($publisher)
                                then(<tr>
                                        <td>Bereitgestellt durch:</td>
                                        <td>{$publisherSwitched}</td>
                                    </tr>)
                                    else()}
                                {if($publisher = 'D-Mbs')
                                then(<tr>
                                        <td>Lizenz:</td>
                                        <td>
                                            {if($publisher = 'D-Mbs')
                                             then(<a href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.de">CC BY-NC-SA 4.0</a>)
                                             else if($surface//tei:licence = '')
                                             then('Lizenzinformationen derzeit nicht verfügbar.')
                                             else($surface//tei:licence/text())}
                                        </td>
                                    </tr>)
                                    else()}
                            </table>
                            </div>
                            <hr/>
                        </div>
                        
    return
        $images
    
};

declare function raffShared:get-digitalization-work-as-html($facsimile as node()*, $facsType as xs:string){
    
    let $bibl := $facsimile/ancestor::mei:mei//mei:source[@xml:id=$facsType]//text() => string-join(' ') => normalize-space()
    let $surfaces := $facsimile[@type=$facsType]/mei:surface
    let $images := for $surface at $n in $surfaces
                    let $url := $surface/mei:graphic/@target
                    let $publisher := 'Joachim-Raff-Archiv' (:$surface/ancestor::mei:mei//mei:sourceDesc/mei:source/tei:bibl[1]/text():)
                    
                    let $img := <img src="{concat('https://digilib.baumann-digital.de/JRA/',$url,'?dh=1000&amp;dw=1000')}" class="img-fluid mx-auto d-block img-thumbnail" width="75%"/>
                    return
                        <div class="test tab-pane fade {if($n=1)then(' show active')else()}" id="facsimile-{$facsType}-{$n}">
                            <hr/>
                            <div class="container">
                                {$img}
                            </div>
                            <hr/>
                            <div>
                                <span class="sublevel">Abbildung aus {$bibl}</span>
                                <br/>
                                <span class="sublevel">Bereitgestellt durch {$publisher}</span>
                            </div>
                            <hr/>
                        </div>
    return
        $images
};

declare function raffShared:getReferences($id) {
    let $collectionReference := ($app:collectionPersons[matches(.//@key,$id)],
                                 $app:collectionInstitutions[matches(.//@key,$id)],
                                 $app:collectionTexts[matches(.//@key,$id)],
                                 $app:collectionSources//tei:note[@type='regeste'][matches(.//@key,$id)],
                                 $app:collectionWorks[matches(.//@auth,$id)],
                                 $app:collectionWritings[matches(.//@key,$id)])
    
    let $entryGroups := for $doc in $collectionReference
                          let $docRoot := $doc/root()/node()
                          let $docID := $docRoot/@xml:id
                          let $docIDInitial := substring($docID,1,1)
                          let $docInfo := if(starts-with($docRoot/@xml:id,'A'))
                                          then('Brief')
                                          else if (starts-with($docRoot/@xml:id,'B'))
                                          then (raffShared:formatWorkDesc($doc//mei:title[@type="desc"]))
                                          else if(starts-with($docRoot/@xml:id,'C'))
                                          then('Person')
                                          else if(starts-with($docRoot/@xml:id,'D'))
                                          then('Institution')
                                          else if(starts-with($docRoot/@xml:id,'E'))
                                          then(
                                                if($doc//tei:analytic)
                                                then('Artikel')
                                                else ('Monographie')
                                              )
                                          else('Sonstige')
                          let $entryOrder := if(starts-with($docRoot/@xml:id,'A'))
                                          then('002')
                                          else if (starts-with($docRoot/@xml:id,'B'))
                                          then ('001')
                                          else if(starts-with($docRoot/@xml:id,'C'))
                                          then('003')
                                          else if(starts-with($docRoot/@xml:id,'D'))
                                          then('004')
                                          else if(starts-with($docRoot/@xml:id,'E'))
                                          then('005')
                                          else('006')
                          let $correspActionSent := $docRoot//tei:correspAction[@type="sent"]
                          let $correspActionReceived := $docRoot//tei:correspAction[@type="received"]
                          let $correspSentTurned := raffPostals:getSenderTurned($correspActionSent)
                          let $correspReceivedTurned := raffPostals:getReceiverTurned($correspActionReceived)
                          let $docDate := if(starts-with($docRoot/@xml:id,'A'))
                                          then(raffShared:getDate($docRoot//tei:correspAction[@type='sent']))
                                          else(<br/>)
                          let $workSortValue := $docRoot//mei:workList/mei:work[1]/string(@auth)
                          let $docTitle := if(starts-with($docRoot/@xml:id,'A'))
                                           then($correspSentTurned,<br/>,'an ',$correspReceivedTurned)
                                           else if(starts-with($docRoot/@xml:id,'B')) 
                                           then($docRoot//mei:workList/mei:work[1]/mei:title[1]/string())
                                           else if(starts-with($docRoot/@xml:id,'E'))
                                           then($docRoot//tei:biblStruct//tei:title[1]/text())
                                           else if($docRoot/name()='TEI')
                                           then($docRoot//tei:titleStmt/tei:title/string())
                                           else('noTitle')
                          let $entry := <div class="row RegisterEntry" xmlns="http://www.w3.org/1999/xhtml">
                                          <div class="col-3" dateToSort="{$docDate}" workSort="{$workSortValue}">
                                            {if(starts-with($docRoot/@xml:id,'A') and $doc[./ancestor::tei:note])
                                              then('Regeste',<br/>)
                                              else()}
                                              {$docInfo}
                                              {if($docDate and starts-with($docRoot/@xml:id,'A'))
                                              then(' vom ',raffShared:formatDate($docDate))
                                              else()}
                                         </div>
                                         <div class="col" docTitle="{normalize-space($docTitle[1])}">{$docTitle}</div>
                                         <div class="col-2"><a href="{$docID}">{string($docID)}</a></div>
                                       </div>
                          group by $docIDInitial
                          return
                              (<div xmlns="http://www.w3.org/1999/xhtml" groupInitial="{$docIDInitial}" order="{$entryOrder}">{for $each in $entry
                                    order by if($each/div/@dateToSort !='')
                                             then($each/div/@dateToSort)
                                             else if($each/div/@workSort)
                                             then($each/div/@workSort)
                                             else ($each/div/@docTitle)
                                    return
                                        $each}</div>)
   let $entryGroupsShow := for $groups in $entryGroups
                              let $groupInitial := $groups/@groupInitial
                              let $order := $groups/@order
                              let $registerSortEntryLabel := switch ($groupInitial/string())
                                                                 case 'A' return 'Briefe und Regesten'
                                                                 case 'B' return 'Werke'
                                                                 case 'C' return 'Personen'
                                                                 case 'D' return 'Institutionen'
                                                                 case 'E' return 'Schriften'
                                                                 default return 'Weitere'
                                order by $order
                                return
                                 <div class="RegisterSortBox" xmlns="http://www.w3.org/1999/xhtml">
                                          <div class="RegisterSortEntry">{$registerSortEntryLabel}</div>
                                          {for $group in $groups
                                              return
                                                  $group}
                                 </div>
   return
    $entryGroupsShow
};


declare function raffShared:suggestedCitation($id as xs:string) {
    
    let $itemLink := request:get-url()
    let $doc := $app:collectionsAll/root()/node()/id($id)
    let $itemType := switch (substring(functx:substring-after-last-match($itemLink, '/'),1,1))
                        case 'A' return 'letter'
                        case 'B' return 'work'
                        case 'C' return 'person'
                        case 'D' return 'institution'
                        case 'E' return 'writing'
                        case 'F' return 'event'
                        case 'G' return 'bibl'
                        case 'H' return 'news'
                        default return 'unknown'
    let $name := if($itemType = 'letter')
                 then(raffPostals:getName($doc//tei:correspAction[@type="sent"]//@key[1]/string(), 'reversed'))
                 else if($itemType = 'person')
                 then(
                        if($id)
                        then(raffPostals:getName($id, 'reversed'))
                        else()
                     )
                 else if($itemType = 'institution')
                 then($doc//tei:org/tei:orgName/text())
                 else if($itemType = 'work')
                 then(concat($doc//mei:work//mei:title[@type="uniform"]/text(), ' ', $doc//mei:work//mei:title[@type="desc"]/text()))
                 else if($itemType = 'writing')
                 then(raffWritings:getTitle($id))
                 else()
    let $nameLetterTo := if($doc//tei:correspAction[@type="received"]//@key[1]/string())
                         then(raffPostals:getName($doc//tei:correspAction[@type="received"]//@key[1]/string(), 'short'))
                         else('')
    let $letterDate := raffShared:formatDateRegistryLetters(raffShared:getDateRegistryLetters($doc//tei:correspAction[@type="sent"]))
    
    let $label := if($itemType = 'letter')
                  then(concat($name, ': Brief an ', $nameLetterTo, ' (', $letterDate, '); '))
                  else if($itemType = 'person')
                  then(concat($name, '; '))
                  else if($itemType = 'institution')
                  then(concat($name, '; '))
                  else if($itemType = 'work')
                  then(concat($name, '; '))
                  else if($itemType = 'writing')
                  then(concat($name, '; '))
                  else('')
    
    let $itemLinkLabel := concat('https://portal.raff-archiv.ch', substring-after($itemLink, 'raffArchive'))
    
    return
        (<hr/>,
        <div class="container">
            <div class="suggestedCitation">
                <span class="heading" style="font-size: medium;">Zitiervorschlag: </span>
                {$label} {$itemLinkLabel},
                abgerufen am {format-date(current-date(), '[D]. [M] [Y]', 'de', (), ())}.
            </div>
        </div>,
        <hr/>)
};

declare function raffShared:forwardEntries($idParam as xs:string) {
    let $currentUri := request:get-url()
    (:let $basicPath := if(starts-with($currentUri, 'http://localhost:8088/exist/apps/raffArchive'))
                          then('https://dev.raff-archiv.ch/html')
                          else if(starts-with($currentUri, 'http://localhost:8084/exist/apps/raffArchive'))
                          then('https://portal.raff-archiv.ch/html')
                          else if(starts-with($currentUri, 'http://localhost:8086/exist/apps/raffArchive'))
                          then('https://portal.raff-archiv.ch/html')
                          else if(starts-with($currentUri, 'http://localhost:8080/exist/apps/raffArchive'))
                          then('http://localhost:8080/exist/apps/raffArchive/html')
                          else('/html/'):)
    let $entryDeleted := $app:collFullAll/id($idParam)//tei:relation[@type='deleted']/@active/string()
    let $entryIdToForward := substring-after($entryDeleted,'#')
    let $entryType := if(starts-with($entryIdToForward, 'A'))
                     then('letter')
                     else if(starts-with($entryIdToForward, 'B'))
                     then('work')
                     else if(starts-with($entryIdToForward, 'C'))
                     then('person')
                     else if(starts-with($entryIdToForward, 'D'))
                     then('institution')
                     else if(starts-with($entryIdToForward, 'E'))
                     then('writing')
                     else()
    let $itemRootPath := functx:substring-before-last(functx:substring-before-last(request:get-url(), '/'), '/')
    let $entryLink := concat($entryType, '/', $entryIdToForward)
    (:let $entryLink := concat($basicPath, '/', $entryType, '/', $entryIdToForward):)
    
    return
       if($entryDeleted)
       then(response:redirect-to($entryLink))
       else()
};


declare function raffShared:replaceToSortDist($input) {

let $fr := 	('ö','ä','ü','É','é','è','ê','á','à')
let $to := 	('oe','ae','ue','E','e','e','e','a','a')
   
   return
      functx:replace-multi(lower-case($input),$fr,$to)
        => distinct-values()

};

declare function raffShared:replaceCutArticlesForSort($input) {

   let $fr := 	('der', 'die', 'das', 'ein', 'eine', '[N.N.]','den','la','le','l’')
   let $to := 	('', '', '', '', '', '', '', '', '', '')
   
   return
      normalize-space(functx:replace-multi(lower-case($input),$fr,$to))
};

declare function raffShared:formatWorkDesc($titleWorkDesc as node()) as xs:string {
   let $tokens := tokenize($titleWorkDesc/text(), ' ')
   let $token1 := $tokens[1]
   let $token2Part1 := number(functx:get-matches($tokens[2],'\d{3}'))
   let $token2Part2 := substring($tokens[2],4)
   
   return
    concat($token1, ' ', $token2Part1, $token2Part2)
};

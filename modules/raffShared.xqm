xquery version "3.1";

module namespace raffShared="https://portal.raff-archiv.ch/ns/raffShared";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace hc = "http://expath.org/ns/http-client";

import module namespace app="https://portal.raff-archiv.ch/templates" at "app.xql";

import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config="https://portal.raff-archiv.ch/config" at "config.xqm";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace transform="http://exist-db.org/xquery/transform";

import module namespace functx="http://www.functx.com" at "functx.xqm";
import module namespace json="http://www.json.org";
import module namespace jsonp="http://www.jsonp.org";

import module namespace raffPostals="https://portal.raff-archiv.ch/ns/raffPostals" at "raffPostals.xqm";
import module namespace i18n="http://exist-db.org/xquery/i18n" at "i18n.xql";

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

declare %templates:wrap function raffShared:listMultiSelectOptions($node as node(), $model as map(*), $listName as xs:string) {
    let $list := if ($listName = 'personRefs2RegerTypes')
                    then ($app:personRefs2RegerTypes)
                    else if ($listName = 'mriPersonaliaOrgaClassificationTypes')
                    then ($app:mriPersonaliaOrgaClassificationTypes)
                    else if ($listName = 'mriPostalObjektTypes')
                    then ($app:mriPostalObjektTypes)
                    else if ($listName = 'mriEventTypes')
                    then ($app:mriEventTypes)
                    else ()

    for $type in $list
        let $typeLabel := raffShared:translate($type)
        order by $typeLabel
        return
            <option value="{$type}">{$typeLabel}</option>
};



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

declare function raffShared:customDate($dateVal as xs:string) as xs:string {
    let $dateValT := tokenize($dateVal, '-')
    let $hasDay := if (number($dateValT[3]) > 0)
                    then (number($dateValT[3]))
                    else ()
    let $hasMonth := if (number($dateValT[2]) > 0)
                        then (number($dateValT[2]))
                        else ()
    let $hasYear := if (number($dateValT[1]) > 0)
                    then (number($dateValT[1]))
                    else ()
    return
        if ($hasDay and $hasMonth and $hasYear)
        then (xs:date($dateVal))
        else if ($hasMonth and $hasYear)
        then (
            concat(
                raffShared:monthName($dateValT[2]),
                ' ',
                $dateValT[1],
                ' [',
                raffShared:translate('raffArchive.entry.postalObject.date.day'),
                ' ',
                raffShared:translate('unknown'),
                ']'
            )
        )
        else if ($hasDay and $hasMonth)
        then (
            concat(
                format-number($dateValT[3], '0'),
                '.&#160;',
                raffShared:monthName($dateValT[2]),
                ', [',
                raffShared:translate('raffArchive.entry.postalObject.date.year'),
                ' ',
                raffShared:translate('unknown'),
                ']'
            )
        )
        else if ($hasMonth)
        then (
            concat(
                raffShared:monthName($dateValT[2]),
                ', [',
                raffShared:translate('raffArchive.entry.postalObject.date.day'),
                '/',
                raffShared:translate('raffArchive.entry.postalObject.date.year'),
                ' ',
                raffShared:translate('unknown'),
                ']'
            )
        )
        else if ($hasDay)
        then (
            concat(
                format-number($dateValT[3], '0'),
                '., [',
                raffShared:translate('raffArchive.entry.postalObject.date.month'),
                '/',
                raffShared:translate('raffArchive.entry.postalObject.date.year'),
                ' ',
                raffShared:translate('unknown'),
                ']'
            )
        )
        else if ($hasYear)
        then (
            concat(
                $dateValT[1],
                ', [',
                raffShared:translate('raffArchive.entry.postalObject.date.day'),
                '/',
                raffShared:translate('raffArchive.entry.postalObject.date.month'),
                ' ',
                raffShared:translate('unknown'),
                ']'
            )
        )
        else (raffShared:translate('raffArchive.entry.postalObject.date.type.undated'))

};


(:~
: Format xs:date with respect to language and desired form
:
: @param $date the date
: @param $form the form (e.g. full, short, …)
: @param $lang the requested language
:
: @return a i18n date string.
:
: ToDo: find the right type of $date for raffShared:getBirthDeathDates
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


declare %templates:wrap function raffShared:readCache($node as node(), $model as map(*), $cacheName as xs:string) {
    doc(concat('xmldb:exist:///db/apps/raffArchive/caches/', $cacheName, '.xml'))/*
};


(: Patrick integrates https://jaketrent.com/post/xquery-browser-language-detection/ :)

declare function raffShared:get-browser-lang() as xs:string? {
  let $header := request:get-header("Accept-Language")
  return if (fn:exists($header)) then
    raffShared:get-top-supported-lang(raffShared:get-browser-langs($header), ("de", "en"))
  else
    ()
};

(:declare function raffShared:get-lang() as xs:string? {
  let $lang := if(string-length(request:get-parameter("lang", "")) gt 0) then
      (\: use http parameter lang as selected language :\)
      request:get-parameter("lang", "")
  else
     if(string-length(request:get-cookie-value("forceLang")) gt 0) then
       request:get-cookie-value("forceLang")
     else
       raffShared:get-browser-lang()
  (\: limit to de and en; en default :\)
  return if($lang != "en" and $lang != "de") then "en" else $lang
};:)

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
    
    let $replaceMay := replace($date,'Mai.','Mai')
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
    let $bracketify := if($type = 'editor') then(concat('[', $replace, ']')) else($replace)
    return
        $bracketify
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

declare function raffShared:suggestedCitation() {
    
    let $itemLink := request:get-url()
    let $id := functx:substring-after-last-match(request:get-url(), '/')
    let $doc := $app:collectionsAll/root()/node()[@xml:id = $id]
    
    let $itemType := functx:substring-after-last-match(functx:substring-before-last($itemLink, '/'), '/')
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
                  else('LABEL')
    
    
    let $itemLinkLabel := if(contains($itemLink, 'http://localhost:8088/exist/apps/raffArchive'))
                          then(replace($itemLink, 'http://localhost:8088/exist/apps/raffArchive', 'https://dev.raff-archiv.ch'))
                          else if(contains($itemLink, 'http://localhost:8084/exist/apps/raffArchive'))
                          then(replace($itemLink, 'http://localhost:8084/exist/apps/raffArchive', 'https://portal.raff-archiv.ch'))
                          else if(contains($itemLink, 'http://localhost:8086/exist/apps/raffArchive'))
                          then(replace($itemLink, 'http://localhost:8086/exist/apps/raffArchive', 'https://portal.raff-archiv.ch'))
                          else($itemLink)
    
    return
        (<hr/>,
        <div class="container">
            <div class="suggestedCitation">
                <span class="heading" style="font-size: medium;">Zitiervorschlag: </span>
                {$label} <a href="{$itemLinkLabel}">{$itemLinkLabel}</a>,
                abgerufen am {format-date(current-date(), '[D]. [M,*-3]. [Y]', 'de', (), ())}.
            </div>
        </div>,
        <hr/>)
};

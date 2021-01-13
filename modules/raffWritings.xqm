xquery version "3.1";

module namespace raffWritings="https://portal.raff-archiv.ch/ns/raffWritings";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace hc = "http://expath.org/ns/http-client";
declare namespace response = "http://exist-db.org/xquery/response";

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

declare function raffWritings:getTitle($id as xs:string?) {
    
    let $file := $app:collFullWritings/id($id)
    
    return
    if(doc-available($file))
    then($file//tei:title[1])
    else('[no Title]')

};
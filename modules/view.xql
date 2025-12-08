(:~
 : This is the main XQuery which will (by default) be called by controller.xql
 : to process any URI ending with ".html". It receives the HTML from
 : the controller and passes it to the templating system.
 :)
xquery version "3.0";

import module namespace templates="http://exist-db.org/xquery/html-templating" ;
import module namespace i18n="http://exist-db.org/xquery/i18n-templates" at "/db/apps/raffArchive/modules/i18n-templates.xql";
import module namespace app-shared="http://xquery.weber-gesamtausgabe.de/modules/app-shared" at "/db/apps/raffArchive/resources/lib/wega-webapp-lib/xquery/app-shared.xqm";

import module namespace raffWorks="https://portal.raff-archiv.ch/ns/raffWorks" at "/db/apps/raffArchive/modules/raffWorks.xqm";
import module namespace raffShared="https://portal.raff-archiv.ch/ns/raffShared" at "/db/apps/raffArchive/modules/raffShared.xqm";
import module namespace raffPostals="https://portal.raff-archiv.ch/ns/raffPostals" at "/db/apps/raffArchive/modules/raffPostals.xqm";
import module namespace raffWritings="https://portal.raff-archiv.ch/ns/raffWritings" at "/db/apps/raffArchive/modules/raffWritings.xqm";
import module namespace search="https://portal.raff-archiv.ch/ns/search" at "/db/apps/raffArchive/modules/search.xqm";
(:import module namespace raffSources="https://portal.raff-archiv.ch/ns/baudiSources" at "raffSources.xqm";:)
(: 
 : The following modules provide functions which will be called by the 
 : templating.
 :)
import module namespace config="https://portal.raff-archiv.ch/config" at "config.xqm";
import module namespace app="https://portal.raff-archiv.ch/templates" at "app.xql";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

let $config := map {
    $templates:CONFIG_APP_ROOT : $config:app-root,
    $templates:CONFIG_STOP_ON_ERROR : true()
}

(:~
 : Initialise the model map for the templating 
 : with the attributes that are passed by the controller,
 : and with user preferences
~:)
let $model := 
	map:merge((
		(
		for $var in request:attribute-names()
		return
			map:entry($var, request:get-attribute($var))
		),
		map:entry('environment', config:app-status())
	))

(:
 : We have to provide a lookup function to templates:apply to help it
 : find functions in the imported application modules. The templates
 : module cannot see the application modules, but the inline function
 : below does see them.
 :)
let $lookup := function($functionName as xs:string, $arity as xs:int) {
    try {
        function-lookup(xs:QName($functionName), $arity)
    } catch * {
        ()
    }
}
(:
 : The HTML is passed in the request from the controller.
 : Run it through the templating system and return the result.
 :)
let $content := request:get-data()
return
    templates:apply($content, $lookup, (), $config)

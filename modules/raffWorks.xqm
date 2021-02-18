xquery version "3.1";

module namespace raffWorks="https://portal.raff-archiv.ch/ns/raffWorks";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace hc = "http://expath.org/ns/http-client";

import module namespace app="https://portal.raff-archiv.ch/templates" at "/db/apps/raffArchive/modules/app.xql";
import module namespace functx="http://www.functx.com" at "/db/apps/raffArchive/modules/functx.xqm";
import module namespace raffShared="https://portal.raff-archiv.ch/ns/raffShared" at "/db/apps/raffArchive/modules/raffShared.xqm";
import module namespace raffPostals="https://portal.raff-archiv.ch/ns/raffPostals" at "/db/apps/raffArchive/modules/raffPostals.xqm";
import module namespace raffWritings="https://portal.raff-archiv.ch/ns/raffWritings" at "/db/apps/raffArchive/modules/raffWritings.xqm";
import module namespace i18n="http://exist-db.org/xquery/i18n" at "/db/apps/raffArchive/modules/i18n.xql";


declare function raffWorks:functOne($idParam as xs:string) {
 'TEST'
};
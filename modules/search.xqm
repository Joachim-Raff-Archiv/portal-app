xquery version "3.1";

module namespace search="https://portal.raff-archiv.ch/ns/search";

import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace app = "https://portal.raff-archiv.ch/templates" at "/db/apps/raffArchive/modules/app.xql";
import module namespace raffShared="https://portal.raff-archiv.ch/ns/raffShared" at "/db/apps/raffArchive/modules/raffShared.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";

declare function search:search($node as node(), $model as map(*))
{
 <div>
    <div class="row ml-2 mt-4 mb-3">{search:form-w-check()}</div>
    
    <div class="row ml-2">
        {
         if (request:get-parameter("term",()) != "")
            then 
                <div>{search:content()}</div>
         else 
             <div><i>{raffShared:translate('jra.search.result.notice')}</i></div>
        }
    </div>
 </div>
};


declare function search:form-w-check()
{
      	<div class="col-8 rounded-lg border">
            <form method="GET" action="http://localhost:8080/exist/apps/raffArchive/search">
              <div class="form-group row mt-3">
                <label for="search-term" class="col-2 col-form-label">{raffShared:translate('jra.search.term')}</label>
                <div class="col-sm-10">
                  <input type="text" class="form-control" id="search-term" name="term"/>
                </div>
              </div>
              <div class="form-group row">
                <div class="col-2"/>
                <div class="form-check col-3">
                  <input type="checkbox" class="form-check-input" id="check-match" name="type" value="exactmatch"/>
                  <label class="form-check-label" for="check-match">{raffShared:translate('jra.search.match')}</label>
                </div>
              </div>
              <div class="form-group row">
                <div class="col-10">
                  <button type="submit" class="btn btn-jra">{raffShared:translate('jra.search.submit')}</button>
                </div>
              </div>
            </form>
        </div>

};

declare function search:content()
{
    let $term := request:get-parameter("term",())

    let $options := <options>
                        {
                         if (request:get-parameter("type",()) = "exactmatch")
                            then ()
                         else
                            <leading-wildcard>yes</leading-wildcard>
                        }
                    </options>
                
    let $parseterm := lower-case($term)
                       => normalize-space()
                       => tokenize(" ")
                      
    let $query := <query>
                    {
                     if (request:get-parameter("type",()) = "exactmatch")
                        then
                            for $term in $parseterm
                            return <term>{$term}</term>
                     else 
                        for $term in $parseterm
                        return <wildcard>{"*" || $term || "*" }</wildcard>
                    }
                  </query>
    
    let $hits := $app:collectionPostals//tei:note[ft:query(., $query, $options)]
    | $app:collectionPersons//tei:person[ft:query(., $query, $options)]
    | $app:collectionInstitutions//tei:org[ft:query(., $query, $options)]
                 | $app:collectionSources//tei:text[ft:query(., $query, $options)]
                 | $app:collectionTexts//tei:text[ft:query(., $query, $options)]
                 | $app:collectionWorks//mei:work[ft:query(., $query, $options)]
    
    return 
            if (count($hits) gt 0)
                then
                    <div>
                       <div class="row mb-2">
                            {count($hits)}&#160;{raffShared:translate('jra.search.result.result')}&#160;<i>{request:get-parameter("term",())}</i><br/>
                            <!--{
                             if (request:get-parameter("type",()) = "exactmatch")
                                then ()
                             else " using wildcard (*) search"
                            }-->
                       </div>
                          { 
                            for $hit in $hits
                            
                            let $docRoot := $hit/root()//tei:TEI | $hit/root()//mei:mei
                            let $docid := if($docRoot[@xml:id])
                                          then($docRoot/string(@xml:id))
                                          else ('noID')
                            
                            let $href := if(starts-with($docid,'A'))
 then('/letter/')
                            else if (starts-with($docid,'B'))
                                          then ('/work/')
                            else if(starts-with($docid,'C'))
                            then('/person/')
                                          else if(starts-with($docid,'D'))
                                          then('/institution/')
                                          else if(starts-with($docid,'E'))
                                          then('/writing/')
                                          else()
                            
                            let $docurl := $app:dbRoot || $href || $docid
                            
                            order by $docid
                            return
                                <div class="row">
                                     <div class="col-10">{kwic:summarize($hit, <config width="50"/>)}</div>
                                     <div class="col-2"><a href="{$docurl}" target="_blank">{$docid}</a></div>
                                 </div>
                          }
                    </div>
                    
            else <div class="row">0&#160;{raffShared:translate('jra.search.result.result')}&#160;«{request:get-parameter("term",())}»</div>
};

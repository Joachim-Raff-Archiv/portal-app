xquery version "3.1";

module namespace search="http://exist.org/apps/bootcamp/search";

declare namespace tei="http://www.tei-c.org/ns/1.0"; 
import module namespace kwic="http://exist-db.org/xquery/kwic";


declare function search:content($node as node(), $model as map(*))
{
    (: search function must coordinate with form type! 
      homework = search:form() + search:result-homework()
      bonus = search:form() + search:result-homework-bonus()
      megabonus = search:form-w-check() + search:result-homework-megabonus()
    :)
    
     <div>
        <h3 class="border-bottom">Search</h3> 
        
        <div class="row ml-2 mt-4 mb-3">{search:form-w-check()}</div>
        
        <div class="row ml-2">
            {
             if (request:get-parameter("term",()) != "")
                then 
                    <div>{search:result-homework-megabonus()}</div>
             else 
                 <div>Search results will display below</div>
            }
        </div>
     </div>
};


declare function search:form()
{
      	<div class="col-8 rounded-lg border">
            <form method="GET" action="http://localhost:8080/exist/apps/bootcamp/search">
              <div class="form-group row mt-3">
                <label for="search-term" class="col-sm-2 col-form-label">Search term:</label>
                <div class="col-9">
                  <input type="text" class="form-control" id="search-term" name="term"/>
                </div>
              </div>
              <div class="form-group row">
                <div class="col-sm-10">
                  <button type="submit" class="btn btn-primary">SUBMIT</button>
                </div>
              </div>
            </form>
        </div>

};

declare function search:form-w-check()
{
      	<div class="col-8 rounded-lg border">
            <form method="GET" action="http://localhost:8080/exist/apps/bootcamp/search">
              <div class="form-group row mt-3">
                <label for="search-term" class="col-2 col-form-label">Search term:</label>
                <div class="col-sm-10">
                  <input type="text" class="form-control" id="search-term" name="term"/>
                </div>
              </div>
              <div class="form-group row">
                <div class="col-2"/>
                <div class="form-check col-3">
                  <input type="checkbox" class="form-check-input" id="check-match" name="type" value="exactmatch"/>
                  <label class="form-check-label" for="check-match">Exact match?</label>
                </div>
              </div>
              <div class="form-group row">
                <div class="col-10">
                  <button type="submit" class="btn btn-primary">SUBMIT</button>
                </div>
              </div>
            </form>
        </div>

};

(:  
 : Modify the present code to make the result display conditional:
 : - if no term submitted, display only the search form and the message "Search results will display below"
 : - if term submitted has no results, display "No results for term 'xyz'"
 : - if term submitted has results, display "1 result(s) for terms 'xyz'", where the number is generated using Xpath count()
 :)
 
 
declare function search:result-fancy()
{
    let $term := request:get-parameter("term",())

    let $collections := $app:collectionsAll
    
    let $options := 
                    <options>
                        {
                         if (request:get-parameter("type",()) = "exactmatch")
                            then ()
                         else
                            <leading-wildcard>yes</leading-wildcard>
                        }
                    </options>
                
    let $parseterm :=  lower-case($term)
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
    
    let $hits := $collections//tei:ab[@xml:lang="la"]/tei:seg[@type=('dep_event','recitation-condemnation')][ft:query(., $query, $options)]
    
    return 
            if (count($hits) gt 0)
                then
                    <div>
                       <div class="row mb-2">
                            {count($hits)} result(s) for term(s) '{request:get-parameter("term",())}'
                            { 
                             if (request:get-parameter("type",()) = "exactmatch")
                                then ()
                             else " using wildcard (*) search"
                            }
                       </div>
                          { 
                            for $hit in $hits
                            
                            let $docid := $hit/ancestor::tei:TEI/string(@xml:id)
                            
                            let $docurl := "http://localhost:8080/exist/apps/bootcamp/document/" || $docid           
                            
                            order by $docid
                            return
                                <div class="row">
                                     <div class="col-2"><a href="{$docurl}">{$docid}</a></div>
                                     <div class="col-10">{kwic:summarize($hit, <config width="50"/>)//span}</div>
                                 </div>
                          }
                    </div>
                    
            else <div class="row">0 results for term(s) '{request:get-parameter("term",())}'</div>
};


declare function search:result-kwic()
{
    let $term := request:get-parameter("term",())

    let $collections := collection($search:basepath)/tei:TEI
    
    let $options := <options>
                        <leading-wildcard>yes</leading-wildcard>
                    </options>
                    
    let $cleanterm := lower-case($term)
                      => normalize-space()
                      
    let $query := <query>
                    <wildcard>{"*" || $cleanterm || "*" }</wildcard>
                  </query>

    for $hit in $collections//tei:ab[@xml:lang="la"]/tei:seg[@type=('dep_event','recitation-condemnation')][ft:query(., $query, $options)]
    
    let $docid := $hit/ancestor::tei:TEI/string(@xml:id)
    
    let $docurl := "http://localhost:8080/exist/apps/bootcamp/document/" || $docid           
    
    order by $docid
    
    return 
             <div class="row">
                 <div class="col-2"><a href="{$docurl}">{$docid}</a></div>
                 <div class="col-10">{kwic:summarize($hit, <config width="50"/>)//span}</div>
             </div>
};


(: the xsl below has an defective trim for the text following exist:match :)
declare function search:xslt-for-hit()
{
    <xsl:stylesheet xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs exist tei" version="3.0"> 
	
	<xsl:output method="html" encoding="UTF-8" html-version="5"/>
	
	<xsl:preserve-space elements="tei:persName tei:placeName tei:lb tei:pb"/>
	
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="tei:seg[@type=('dep_event','recitation-condemnation')]">
		<xsl:variable name="search-hit">
			<xsl:apply-templates/>
		</xsl:variable>
		<div class="row">
			<div class="col-2">
				<xsl:element name="a">
					<xsl:attribute name="href">
						<xsl:value-of select="./ancestor::doc/url/data(@url)"/>
					</xsl:attribute>
				    <xsl:value-of select="./ancestor::doc/url/data(@docid)"/>
				</xsl:element>
			</div>
			<div class="col-10">
				<xsl:apply-templates select="$search-hit" mode="trim"/>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="exist:match">
		<xsl:element name="span">
			<xsl:attribute name="class">search-hit</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="tei:lb">
		<xsl:text> | </xsl:text>
	</xsl:template>
	
	<xsl:template match="tei:pb | tei:surplus  | tei:del | tei:catchwords | tei:note | tei:supplied"/>
	
	<xsl:template match="tei:gap | tei:unclear">
		<xsl:text>[...]</xsl:text>
	</xsl:template>
	
	<xsl:template match="tei:sic">
		<xsl:value-of select="./tei:corr"/>
	</xsl:template>
	
	
	<xsl:param name="trim-to" as="xs:integer" select="40"/>
	
	<xsl:template match="text()[1]" mode="trim">
		<xsl:variable name="normalized" as="xs:string" select="normalize-space(.)"/>
		<xsl:value-of select="concat('...', substring($normalized, string-length($normalized) - $trim-to),' ')"/>
	</xsl:template>
	
	<xsl:template match="text()[last() and not (1)]" mode="trim">
		<xsl:variable name="normalized" as="xs:string" select="normalize-space(.)"/>
		<xsl:value-of select="concat(substring($normalized, 1, $trim-to), '...')"/>
		
	</xsl:template>
	
	<xsl:template match="span[@class = 'search-hit']" mode="trim">
		<xsl:copy-of select="."/>
	</xsl:template>
	
  </xsl:stylesheet>
    
};

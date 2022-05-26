xquery version "3.0";

import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace app = "https://portal.raff-archiv.ch/templates" at "/db/apps/raffArchive/modules/app.xql";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;


if ($exist:path eq '') then 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>

else
    if ($exist:path eq "/") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>

else
    if(contains($exist:path, '/$resources/')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, '/resources/', substring-after($exist:path, '/$resources/'))}">
            <set-header name="Cache-Control" value="max-age=3600,public"/>
        </forward>
    </dispatch>

else
    if(contains($exist:path, '/$index')) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="{substring-before(request:get-uri(),$exist:controller)}{concat($exist:controller, '/index.html')}"/>
        </dispatch>
        
else
    if(contains($exist:path, '/$baseUrl/')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{substring-before(request:get-uri(),$exist:controller)}{concat($exist:controller, substring-after($exist:path, '/$baseUrl'))}"/>
    </dispatch>

else
    if(matches($exist:path, '/html/')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{substring-before(request:get-uri(),$exist:controller)}{concat($exist:controller, '/', $exist:resource)}"/>
    </dispatch>
else
    if(matches($exist:path, '/person/') or matches($exist:path, '/institution/') or matches($exist:path, '/sources/') or matches($exist:path, '/work/') or matches($exist:path, '/letter/')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{substring-before(request:get-uri(),$exist:controller)}{concat($exist:controller, '/', $exist:resource)}"/>
    </dispatch>
    
    (: if it's a registry :)
else
    if (matches($exist:path, "registry") or matches($exist:path, "about") or matches($exist:path, "view") or matches($exist:path, "impressum") or matches($exist:path, "privacy") or matches($exist:path, "search") or matches($exist:path, "disclaimer")) then
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="{$exist:controller}/templates/{$exist:resource}"/>
            <view>
                <forward
                    url="{$exist:controller}/modules/view.xql"/>
            </view>
            <error-handler>
                <forward
                    url="{$exist:controller}/templates/error-page.html"
                    method="get"/>
                <forward
                    url="{$exist:controller}/modules/view.xql"/>
            </error-handler>
        </dispatch>

(: if it's a podcast :)
else
	if (matches($exist:path, "podcast")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			{if($app:collectionPodcasts/id($exist:resource))
			then(<forward
				url="{$exist:controller}/templates/viewPodcast.html">
				<add-parameter
					name="podcast-id"
					value="{$exist:resource}"/>
			</forward>)
			else(<forward url="{$exist:controller}/templates/registryPodcasts.html"/>)}
			<view>
				<forward
					url="{$exist:controller}/modules/view.xql">
					<add-parameter
						name="podcast-id"
						value="{$exist:resource}"/>
				</forward>
			</view>
			<error-handler>
				<forward
					url="{$exist:controller}/templates/error-page.html"
					method="get"/>
				<forward
					url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>

	(: if it's a search :)
else
	if (matches($exist:path, "/search/")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			<forward
				url="{$exist:controller}/templates/search.html">
			</forward>
			<view>
				<forward
					url="{$exist:controller}/modules/view.xql">
				</forward>
			</view>
			<error-handler>
				<forward
					url="{$exist:controller}/templates/error-page.html"
					method="get"/>
				<forward
					url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>
	
	
	(: if its a letter :)
else
	if (matches($exist:path, "A\d*")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			{if($app:collFullPostals/id($exist:resource))
			 then(<forward
				url="{$exist:controller}/templates/viewLetter.html">
				<add-parameter
					name="letter-id"
					value="{$exist:resource}"/>
			</forward>)
			else(<forward url="{$exist:controller}/templates/registryLettersDate.html"/>)}
			<view>
				<forward
					url="{$exist:controller}/modules/view.xql">
					<add-parameter
						name="letter-id"
						value="{$exist:resource}"/>
				</forward>
			</view>
			<error-handler>
				<forward
					url="{$exist:controller}/templates/error-page.html"
					method="get"/>
				<forward
					url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>
		
(: if its a document :)
(:else
	if (matches($exist:path, "/document/")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			<forward
				url="{$exist:controller}/templates/viewDocument.html">
				<add-parameter
					name="document-id"
					value="{$exist:resource}"/>
			</forward>
			<view>
				<forward
					url="{$exist:controller}/modules/view.xql">
					<add-parameter
						name="document-id"
						value="{$exist:resource}"/>
				</forward>
			</view>
			<error-handler>
				<forward
					url="{$exist:controller}/templates/error-page.html"
					method="get"/>
				<forward
					url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>:)
		
		(: if its a person :)
else
	if (matches($exist:path, "C\d*")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			{if($app:collectionPersons/id($exist:resource))
			 then(<forward
				url="{$exist:controller}/templates/viewPerson.html">
				<add-parameter
					name="person-id"
					value="{$exist:resource}"/>
			</forward>)
			else(<forward url="{$exist:controller}/templates/registryPersonsInitial.html"/>)}
			<view>
				<forward
					url="{$exist:controller}/modules/view.xql">
					<add-parameter
						name="person-id"
						value="{$exist:resource}"/>
				</forward>
			</view>
			<error-handler>
				<forward
					url="{$exist:controller}/templates/error-page.html"
					method="get"/>
				<forward
					url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>
		
	(: if its an place :)
(:else
	if (matches($exist:path, "/place/")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			<forward
				url="{$exist:controller}/templates/viewPlace.html">
				<add-parameter
					name="place-id"
					value="{$exist:resource}"/>
			</forward>
			<view>
				<forward
					url="{$exist:controller}/modules/view.xql">
					<add-parameter
						name="place-id"
						value="{$exist:resource}"/>
				</forward>
			</view>
			<error-handler>
				<forward
					url="{$exist:controller}/templates/error-page.html"
					method="get"/>
				<forward
					url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>:)
		
		(: if its an institution :)
else
	if (matches($exist:path, "D\d*")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			{if($app:collectionInstitutions/id($exist:resource))
			then(<forward
				url="{$exist:controller}/templates/viewInstitution.html">
				<add-parameter
					name="institution-id"
					value="{$exist:resource}"/>
			</forward>)
			else(<forward url="{$exist:controller}/templates/registryInstitutions.html"/>)}
			<view>
				<forward
					url="{$exist:controller}/modules/view.xql">
					<add-parameter
						name="institution-id"
						value="{$exist:resource}"/>
				</forward>
			</view>
			<error-handler>
				<forward
					url="{$exist:controller}/templates/error-page.html"
					method="get"/>
				<forward
					url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>
		
			(: if its a work :)
else
	if (matches($exist:path, "B\d*")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			{if($app:collectionWorks/id($exist:resource))
			then(<forward url="{$exist:controller}/templates/viewWork.html">
    				<add-parameter
    					name="work-id"
    					value="{$exist:resource}"/>
    			</forward>)
			else(<forward url="{$exist:controller}/templates/registryWorks.html"/>)}
			<view>
				<forward
					url="{$exist:controller}/modules/view.xql">
			      <add-parameter
    					name="work-id"
    					value="{$exist:resource}"/>
			  </forward>
			</view>
			<error-handler>
				<forward
					url="{$exist:controller}/templates/error-page.html"
					method="get"/>
				<forward
					url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>
		
(: if it's a writing :)
else
	if (matches($exist:path, "E\d*")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			{if($app:collectionWritings/id($exist:resource))
			then(
      			<forward url="{$exist:controller}/templates/viewWriting.html">
      				<add-parameter
      					name="writing-id"
      					value="{$exist:resource}"/>
      			</forward>)
			else(<forward url="{$exist:controller}/templates/registryWritings.html"/>)
			}
			<view>
				<forward url="{$exist:controller}/modules/view.xql">
				 <add-parameter
      					name="writing-id"
      					value="{$exist:resource}"/>
      			</forward>
			</view>
			<error-handler>
				<forward
					url="{$exist:controller}/templates/error-page.html"
					method="get"/>
				<forward
					url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>

else
	if (ends-with($exist:resource, ".html")) then
		(: the html page is run through view.xql to expand templates :)
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			<view>
				<forward
					url="{$exist:controller}/modules/view.xql"/>
			</view>
			<error-handler>
				<forward
					url="{$exist:controller}/templates/error-page.html"
					method="get"/>
				<forward
					url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>
		
else
	(: everything else is passed through :)
	<dispatch
		xmlns="http://exist.sourceforge.net/NS/exist">
		<cache-control
			cache="yes"/>
	</dispatch>

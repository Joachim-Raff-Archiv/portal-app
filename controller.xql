xquery version "3.0";

import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace app = "https://portal.raff-archiv.ch/templates" at "/db/apps/raffArchive/modules/app.xql";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;


    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
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
    if(contains($exist:path, '/html/')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{substring-before(request:get-uri(),'/html/')}{concat('/', substring-after($exist:path, '/html/'))}"/>
    </dispatch>

else
    if(contains($exist:path, '/$index')) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="{substring-before(request:get-uri(),$exist:controller)}{concat($exist:controller, '/index.html')}"/>
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
        
	(: if it's a search :)
else
	if (matches($exist:path, "/search/")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			<forward
				url="{$exist:controller}/html/search.html">
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
	if (matches($exist:path, "/letter/")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			{if($app:collFullPostals/id($exist:resource))
			 then(<forward
				url="{$exist:controller}/html/viewLetter.html">
				<add-parameter
					name="letter-id"
					value="{$exist:resource}"/>
			</forward>)
			else(<forward url="{$exist:controller}/html/registryLettersDate.html"/>)}
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
				url="{$exist:controller}/html/viewDocument.html">
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
		if (matches($exist:path, "/person/")) then
			<dispatch
				xmlns="http://exist.sourceforge.net/NS/exist">
				{if($app:collectionPersons/id($exist:resource))
				 then(<forward
					url="{$exist:controller}/html/viewPerson.html">
					<add-parameter
						name="person-id"
						value="{$exist:resource}"/>
				</forward>)
				else(<forward url="{$exist:controller}/html/registryPersonsInitial.html"/>)}
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
						url="{$exist:controller}/html/viewPlace.html">
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
				if (matches($exist:path, "/institution/")) then
					<dispatch
						xmlns="http://exist.sourceforge.net/NS/exist">
						{if($app:collectionInstitutions/id($exist:resource))
						then(<forward
							url="{$exist:controller}/html/viewInstitution.html">
							<add-parameter
								name="institution-id"
								value="{$exist:resource}"/>
						</forward>)
						else(<forward url="{$exist:controller}/html/registryInstitutions.html"/>)}
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
				if (matches($exist:path, "/work/")) then
					<dispatch
						xmlns="http://exist.sourceforge.net/NS/exist">
						{if($app:collectionWorks/id($exist:resource))
						then(<forward url="{$exist:controller}/html/viewWork.html">
    							<add-parameter
    								name="work-id"
    								value="{$exist:resource}"/>
    						</forward>)
						else(<forward url="{$exist:controller}/html/registryWorks.html"/>)}
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
				if (matches($exist:path, "/writing/")) then
					<dispatch
						xmlns="http://exist.sourceforge.net/NS/exist">
						{if($app:collectionWritings/id($exist:resource))
						then(
      						<forward url="{$exist:controller}/html/viewWriting.html">
      							<add-parameter
      								name="writing-id"
      								value="{$exist:resource}"/>
      						</forward>)
						else(<forward url="{$exist:controller}/html/registryWritings.html"/>)
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
						(: Resource paths starting with $shared are loaded from the shared-resources app :)
					(:else
						if (contains($exist:path, "/$shared/")) then
							<dispatch
								xmlns="http://exist.sourceforge.net/NS/exist">
								<forward
									url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
									<set-header
										name="Cache-Control"
										value="max-age=3600, must-revalidate"/>
								</forward>
							</dispatch>:)
						
						
						else
							(: everything else is passed through :)
							<dispatch
								xmlns="http://exist.sourceforge.net/NS/exist">
								<cache-control
									cache="yes"/>
							</dispatch>



xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;
declare variable $exist:log-in := xmldb:login('/db','Raff','Joachim');

if ($exist:path eq '') then
	<dispatch
		xmlns="http://exist.sourceforge.net/NS/exist">
		<redirect
			url="{request:get-uri()}/"/>
	</dispatch>
	
	
	(: if its a letter :)
else
	if (matches($exist:path, "/letter/")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			<forward
				url="{$exist:controller}/html/viewLetter.html">
				<add-parameter
					name="letter-id"
					value="{$exist:resource}"/>
			</forward>
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
else
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
		</dispatch>
		
		(: if its a person :)
	else
		if (matches($exist:path, "/person/")) then
			<dispatch
				xmlns="http://exist.sourceforge.net/NS/exist">
				<forward
					url="{$exist:controller}/html/viewPerson.html">
					<add-parameter
						name="person-id"
						value="{$exist:resource}"/>
				</forward>
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
		else
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
				</dispatch>
				
				(: if its an institution :)
			else
				if (matches($exist:path, "/institution/")) then
					<dispatch
						xmlns="http://exist.sourceforge.net/NS/exist">
						<forward
							url="{$exist:controller}/html/viewInstitution.html">
							<add-parameter
								name="institution-id"
								value="{$exist:resource}"/>
						</forward>
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
						<forward
							url="{$exist:controller}/html/viewWork.html">
							<add-parameter
								name="work-id"
								value="{$exist:resource}"/>
						</forward>
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
					
						
						(: if its an manuskript :)
					else
						if (matches($exist:path, "/sources/manuscript/")) then
							<dispatch
								xmlns="http://exist.sourceforge.net/NS/exist">
								<forward
									url="{$exist:controller}/html/sources/viewManuscript.html">
									<add-parameter
										name="source-id"
										value="{$exist:resource}"/>
								</forward>
								<view>
									<forward
										url="{$exist:controller}/modules/view.xql">
										<add-parameter
											name="source-id"
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
							
							
							(: if its an druck :)
						else
							if (matches($exist:path, "/sources/print/")) then
								<dispatch
									xmlns="http://exist.sourceforge.net/NS/exist">
									<forward
										url="{$exist:controller}/html/sources/viewPrint.html">
										<add-parameter
											name="source-id"
											value="{$exist:resource}"/>
									</forward>
									<view>
										<forward
											url="{$exist:controller}/modules/view.xql">
											<add-parameter
												name="source-id"
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
								if ($exist:path eq "/") then
									(: forward root path to index.xql :)
									<dispatch
										xmlns="http://exist.sourceforge.net/NS/exist">
										<redirect
											url="index.html"/>
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
									else
										if (contains($exist:path, "/$shared/")) then
											<dispatch
												xmlns="http://exist.sourceforge.net/NS/exist">
												<forward
													url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
													<set-header
														name="Cache-Control"
														value="max-age=3600, must-revalidate"/>
												</forward>
											</dispatch>
										
										
										else
											(: everything else is passed through :)
											<dispatch
												xmlns="http://exist.sourceforge.net/NS/exist">
												<cache-control
													cache="yes"/>
											</dispatch>



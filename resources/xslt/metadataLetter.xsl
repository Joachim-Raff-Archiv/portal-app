<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="https://portal.raff-archive.ch/ns/local" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:include href="formattingDate.xsl"/>

    <xsl:variable name="correspAction" select="//correspAction"/>
    <xsl:variable name="sourceDesc" select="//sourceDesc"/>
    <xsl:variable name="graphic" select="$correspAction/ancestor::TEI/facsimile/graphic[1]"/>

    <xsl:template match="/">
                <xsl:call-template name="letterMetadataView"/>
    </xsl:template>

    <xsl:template name="letterMetadataView">
        <table class="letterView">
            <tr>
                <td valign="top">Absender:</td>
                <td>
                    <xsl:if test="$correspAction[@type = 'sent']/persName != ''">
                        <xsl:for-each select="$correspAction[@type = 'sent']/persName">
                        <xsl:choose>
                            <xsl:when test="contains(text()[1], ', ')">
                                <xsl:value-of select="text()[1]/substring-after(., ',')"/> <xsl:value-of select="text()[1]/substring-before(., ',')"/></xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="text()[1]"/>
                            </xsl:otherwise>
                        </xsl:choose><xsl:if test="$correspAction[@type = 'sent']/persName/@cert">*</xsl:if>
                        <xsl:if test="@key"> (<a href="{concat('https://portal.raff-archiv.ch/html/person/',@key)}"><xsl:value-of select="@key"/></a>)
                        </xsl:if><br/>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="$correspAction[@type = 'sent']/orgName != ''">
                        <xsl:for-each select="$correspAction[@type = 'sent']/orgName">
                        <xsl:choose>
                            <xsl:when test="contains(text()[1], ', ')">
                                <xsl:value-of select="text()[1]/substring-after(., ',')"/> <xsl:value-of select="text()[1]/substring-before(., ',')"/></xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="text()[1]"/>
                            </xsl:otherwise>
                        </xsl:choose><xsl:if test="$correspAction[@type = 'sent']/orgName/@cert">*</xsl:if>
                        <xsl:if test="@key"> (<a href="{concat('https://portal.raff-archiv.ch/html/institution/',@key)}"><xsl:value-of select="@key"/></a>)
                        </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </td>
            </tr>
            <xsl:if test="$correspAction[@type = 'sent']/settlement != ''">
                <tr>
                    <td valign="top">Erstellungsort:</td>
                    <td>
                        <xsl:value-of select="$correspAction[@type = 'sent']/settlement"/> <xsl:if test="$correspAction[@type = 'sent']/settlement/@cert">*</xsl:if>
                    </td>
                </tr>
            </xsl:if>
        </table>
        <table class="letterView">
            <tr>
                <td valign="top">Empfänger:</td>
                <td>
                    <xsl:if test="$correspAction[@type = 'received']/persName != ''">
                        <xsl:for-each select="$correspAction[@type = 'received']/persName">
                            <xsl:choose>
                                <xsl:when test="contains(text()[1], ', ')">
                                    <xsl:value-of select="text()[1]/substring-after(., ',')"/> <xsl:value-of select="text()[1]/substring-before(., ',')"/></xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="text()[1]"/>
                                </xsl:otherwise>
                            </xsl:choose><xsl:if test="$correspAction[@type = 'received']/persName/@cert">*</xsl:if>
                            <xsl:if test="@key"> (<a href="{concat('https://portal.raff-archiv.ch/html/person/',@key)}"><xsl:value-of select="@key"/></a>)
                            </xsl:if><br/>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="$correspAction[@type = 'received']/orgName != ''">
                        <xsl:for-each select="$correspAction[@type = 'received']/orgName">
                            <xsl:choose>
                                <xsl:when test="contains(text()[1], ', ')">
                                    <xsl:value-of select="text()[1]/substring-after(., ',')"/> <xsl:value-of select="text()[1]/substring-before(., ',')"/></xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="text()[1]"/>
                                </xsl:otherwise>
                            </xsl:choose><xsl:if test="$correspAction[@type = 'received']/orgName/@cert">*</xsl:if>
                            <xsl:if test="@key"> (<a href="{concat('https://portal.raff-archiv.ch/html/institution/',@key)}"><xsl:value-of select="@key"/></a>)
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </td>
            </tr>
            <xsl:if test="$correspAction[@type = 'received']/settlement != ''">
                <tr>
                    <td valign="top">Zielort:</td>
                    <td>
                        <xsl:value-of select="$correspAction[@type = 'received']/settlement"/><xsl:if test="$correspAction[@type = 'received']/settlement/@cert">*</xsl:if>
                    </td>
                </tr>
            </xsl:if>
        </table>
        <table class="letterView">
            <tr>
                <td valign="top">Datierung:</td>
                <td>
                    <xsl:choose>
                        <xsl:when test="not($correspAction[@type = 'sent']/date) or empty($correspAction[@type = 'sent']/date)"> [undatiert] </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="$correspAction[@type = 'sent']/date[@type = 'source']/@when">
                                    <xsl:value-of select="local:formatDate($correspAction[@type = 'sent']/date[@type = 'source' and @when][1]/@when)"/> (Quelle) <br/>
                                </xsl:when>
                                <xsl:otherwise>Quelle undatiert<br/></xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="$correspAction[@type = 'sent']/date[@type = 'source']/@from-custom">
                                <xsl:value-of select="local:formatDate($correspAction[@type = 'sent']/date[@type = 'source']/@from-custom)"/> bis <xsl:value-of select="local:formatDate($correspAction[@type = 'sent']/date[@type = 'source']/@to-custom)"/> (Quelle)<br/></xsl:if>
                            <xsl:if test="$correspAction[@type = 'sent']/date[@type = 'editor']/@from">
                                <xsl:value-of select="local:formatDate($correspAction[@type = 'sent']/date[@type = 'editor']/@from)"/> bis <xsl:value-of select="local:formatDate($correspAction[@type = 'sent']/date[@type = 'editor']/@to)"/> (ermittelt)<br/></xsl:if>
                            <xsl:if test="$correspAction[@type = 'sent']/date[@type = 'postal']/@when">
                                <xsl:value-of select="local:formatDate($correspAction[@type = 'sent']/date[@type = 'postal']/@when)"/> (Poststempel)<br/></xsl:if>
                            <xsl:if test="$correspAction[@type = 'sent']/date[@type = 'editor']/@notBefore"> Frühestens <xsl:value-of select="local:formatDate($correspAction[@type = 'sent']/date[@type = 'editor']/@notBefore)"/> (ermittelt)<br/>
                            </xsl:if>
                            <xsl:if test="$correspAction[@type = 'sent']/date[@type = 'editor']/@notAfter"> Spätestens <xsl:value-of select="local:formatDate($correspAction[@type = 'sent']/date[@type = 'editor']/@notAfter)"/> (ermittelt)<br/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose><xsl:if test="$correspAction[@type = 'sent']/date/@cert">*</xsl:if>
                </td>
            </tr>
            <xsl:if test="$correspAction[@type = 'sent']/note[contains(@type,'editor') and contains(@subtype,'public')] != ''">
                <tr>
                    <td valign="top">Anmerkung:</td>
                    <td>
                        <i>
                            <xsl:value-of select="$correspAction[@type = 'sent']/note[@type = 'editor']"/>
                        </i>
                    </td>
                </tr>
            </xsl:if>

        </table>
        <table class="letterView">
            <xsl:if test="exists($correspAction[@type = 'received']/date)">
                <tr>
                    <td valign="top">Ankunftsdatum:</td>
                    <td>
                        <xsl:value-of select="$correspAction[@type = 'received']/date"/><xsl:if test="$correspAction[@type = 'received']/orgName/@cert">*</xsl:if>
                    </td>
                </tr>
            </xsl:if>
        </table>
        <table class="letterView">
            <tr>
                <td/>
                <td/>
            </tr>
        </table>
        <table class="letterView">
            <xsl:if test="$sourceDesc//msIdentifier/institution != ''">
                <tr>
                    <td valign="top">Institution:</td>
                    <td>
                        <xsl:value-of select="$sourceDesc//msIdentifier/institution"/>
                        <xsl:if test="$sourceDesc//msIdentifier/settlement != ''">
                            (<xsl:value-of select="$sourceDesc//msIdentifier/settlement"/>) 
            </xsl:if>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="$sourceDesc//msIdentifier/repository != ''">
                <tr>
                    <td valign="top">Standort:</td>
                    <td>
                        <xsl:value-of select="$sourceDesc//msIdentifier/repository"/>
                        <xsl:if test="$sourceDesc//msIdentifier/settlement != ''">
                            (<xsl:value-of select="$sourceDesc//msIdentifier/settlement"/>) 
                        </xsl:if></td>
                </tr>
            </xsl:if>
            <xsl:if test="$sourceDesc//msIdentifier/collection != ''">
                <tr>
                    <td valign="top">Sammlung:</td>
                    <td>
                        <xsl:value-of select="$sourceDesc//msIdentifier/collection"/>
                        <!--<xsl:choose><xsl:when test="$sourceDesc//msIdentifier/idno[@resp = 'JRA-copy']"> (Kopie im Joachim-Raff-Archiv)</xsl:when>
                            <xsl:when test="$sourceDesc//msIdentifier/idno[@resp = 'JRA']"> (Joachim-Raff-Archiv)</xsl:when>
                            <xsl:when test="$sourceDesc//msIdentifier/idno[@resp = 'BSB']"> (Bayerische Staatsbibliothek)</xsl:when>
                            </xsl:choose>-->
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="$sourceDesc//msIdentifier/idno != ''">
                <tr>
                    <td valign="top">Signatur:</td>
                    <td>
                        <xsl:value-of select="$sourceDesc//msIdentifier/idno"/>
                        <!--<xsl:choose><xsl:when test="$sourceDesc//msIdentifier/idno[@resp = 'JRA-copy']"> (Kopie im Joachim-Raff-Archiv)</xsl:when>
                            <xsl:when test="$sourceDesc//msIdentifier/idno[@resp = 'JRA']"> (Joachim-Raff-Archiv)</xsl:when>
                            <xsl:when test="$sourceDesc//msIdentifier/idno[@resp = 'BSB']"> (Bayerische Staatsbibliothek)</xsl:when>
                            </xsl:choose>-->
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="$sourceDesc//physDesc//supportDesc/extent != ''">
                <tr>
                    <td valign="top">Umfang:</td>
                    <td>
                        <xsl:value-of select="$sourceDesc//physDesc//supportDesc/extent"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="$sourceDesc//physDesc//supportDesc/@material">
                <tr>
                    <td valign="top">Material:</td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="$sourceDesc//physDesc//supportDesc[@material = 'paper']">Papier</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$sourceDesc//physDesc//supportDesc/@material/string()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="$sourceDesc//physDesc//handDesc/p[@decls='schreibmittel'] !=''">
                <tr>
                    <td valign="top">Schreibmittel:</td>
                    <td>
                        <xsl:value-of select="$sourceDesc//physDesc//handDesc/p[@decls='schreibmittel']/string()"/>
                    </td>
                </tr>
            </xsl:if>
            <!--<xsl:if test="$sourceDesc//provenance/p != ''">
                <tr>
                    <td valign="top">Provenienz:</td>
                    <td>
                        <xsl:value-of select="$sourceDesc//provenance"/>
                    </td>
                </tr>
            </xsl:if>-->
            <xsl:if test="$sourceDesc/bibl != ''">
                <tr>
                    <td valign="top">Veröffentlichung:</td>
                    <td>
                        <xsl:value-of select="$sourceDesc/bibl"/>
                    </td>
                </tr>
            </xsl:if>
        </table>
        <table class="letterView">
            <tr>
                <td/>
                <td/>
            </tr>
        </table>
        <xsl:if test="//incipit !=''">
        <table class="letterView">
            <tr>
                <td>Incipit:</td>
                <td>
                    <xsl:value-of select="//opener/string()"/>
                    <br/>
                    <xsl:value-of select="//incipit/string()"/>
                </td>
            </tr>
        </table>
        </xsl:if>
        <xsl:if test="//@cert"><br/>
            <hr/>
            * Daten nicht verifiziert
            <br/></xsl:if>
    </xsl:template>

</xsl:stylesheet>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:template match="/">
        <br/>
        <table>
            <br/>
            <tr>
                <td>Verfasser:</td>
                <td>
                    <xsl:choose>
                        <xsl:when test="doc-available(concat('../../../../contents/texts/persons/', //correspAction[@type = 'sent']/persName/@key, '.xml'))">
                            <a href="{concat($registerRootPerson, //correspAction[@type = 'sent']/persName/@key)}" target="_blank">
                                <xsl:value-of select="//correspAction[@type = 'sent']/persName"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//correspAction[@type = 'sent']/persName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="doc-available(concat('../../../../contents/texts/institutions/', //correspAction[@type = 'sent']/orgName/@key, '.xml'))">
                            <a href="{concat($registerRootInstitution, //correspAction[@type = 'sent']/persName/@key)}" target="_blank">
                                <xsl:value-of select="//correspAction[@type = 'sent']/orgName"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//correspAction[@type = 'sent']/orgName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
            <tr>
                <td>Erstellungsdatum:</td>
                <td>
                    <xsl:value-of select="//correspAction[@type = 'sent']/date"/>
                </td>
            </tr>
            <tr>
                <td>Erstellungsort:</td>
                <td>
                    <xsl:choose>
                        <xsl:when test="doc-available(concat('../../../../contents/texts/loci/', //correspAction[@type = 'sent']/settlement/@key, '.xml'))">
                            <a href="{concat($registerRootOrt, //correspAction[@type = 'sent']/settlement/@key)}" target="_blank">
                                <xsl:value-of select="//correspAction[@type = 'sent']/settlement"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//correspAction[@type = 'sent']/settlement"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
            <tr>
                <td>
                    <br/>
                </td>
                <td/>
            </tr>
            <tr>
                <td>Adressat:</td>
                <td>
                    <xsl:choose>
                        <xsl:when test="doc-available(concat('../../../../contents/texts/persons/', //correspAction[@type = 'received']/persName/@key, '.xml'))">
                            <a href="{concat($registerRootPerson, //correspAction[@type = 'received']/persName/@key)}" target="_blank">
                                <xsl:value-of select="//correspAction[@type = 'received']/persName"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//correspAction[@type = 'received']/persName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="doc-available(concat('../../../../contents/texts/institutions/', //correspAction[@type = 'received']/persName/@key, '.xml'))">
                            <a href="{concat($registerRootInstitution, //correspAction[@type = 'received']/orgName/@key)}" target="_blank">
                                <xsl:value-of select="//correspAction[@type = 'received']/orgName"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//correspAction[@type = 'received']/orgName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
            <tr>
                <td>Ankunftsdatum:</td>
                <td>
                    <xsl:value-of select="//correspAction[@type = 'received']/date"/>
                </td>
            </tr>
            <tr>
                <td>Ankunftsort</td>
                <td>
                    <xsl:choose>
                        <xsl:when test="doc-available(concat('../../../../contents/texts/loci/', //correspAction[@type = 'received']/settlement/@key, '.xml'))">
                            <a href="{concat($registerRootOrt,//correspAction[@type = 'received']/settlement/@key)}" target="_blank">
                                <xsl:value-of select="//correspAction[@type = 'received']/settlement"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//correspAction[@type = 'received']/settlement"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
            <tr>
                <td>
                    <br/>
                </td>
                <td/>
            </tr>
            <tr>
                <td>Beschreibung der Quelle:</td>
                <td>
                    <xsl:value-of select="//sourceDesc/p"/>
                </td>
            </tr>
            <tr>
                <td>
                    <br/>
                </td>
                <td/>
            </tr>
            <tr>
                <td>Publikationsvermerk:</td>
                <td>
                    <xsl:value-of select="//publicationStmt/p"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    
    <!--<xsl:template match="hi[@rend = 'underline']">
        <span style="text-decoration: underline;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend = 'italic']">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    <xsl:template match="lb">
        <br/>
        <xsl:apply-templates/>
    </xsl:template>-->
</xsl:stylesheet>
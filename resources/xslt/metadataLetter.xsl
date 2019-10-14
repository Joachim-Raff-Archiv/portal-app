<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://portal.raff-archive.ch/ns/local" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:include href="formattingDate.xsl"/>

    <xsl:template match="/">
        <table class="letterView">
            <tr>
                <td>Adressat:</td>
                <td>
                    <a href="{concat('http://localhost:8080/exist/apps/raffArchive/html/person/',//correspAction[@type = 'received']/persName/@key)}" target="_blank">
                        <xsl:value-of select="//correspAction[@type = 'received']/persName/text()/substring-after(., ',')"/>
                        <xsl:value-of select="//correspAction[@type = 'received']/persName/text()/substring-before(., ',')"/>
                    </a>
                    (<xsl:value-of select="//correspAction[@type = 'received']/persName/@key"/>)
                </td>
            </tr>
            <!--            </xsl:if>-->
            <tr>
                <td>Absender:</td>
                <td>
                    <a href="{concat('http://localhost:8080/exist/apps/raffArchive/html/person/',//correspAction[@type = 'sent']/persName/@key)}" target="_blank">
                        <xsl:choose>
                            <xsl:when test="contains(//correspAction[@type = 'sent']/persName/text()[1],', ')">
                                <xsl:value-of select="//correspAction[@type = 'sent']/persName/text()[1]/substring-after(., ',')"/> <xsl:value-of select="//correspAction[@type = 'sent']/persName/text()[1]/substring-before(., ',')"/></xsl:when>
                            <xsl:otherwise><xsl:value-of select="//correspAction[@type = 'sent']/persName/text()[1]"/></xsl:otherwise>
                        </xsl:choose>
                        
                    </a>
                    (<xsl:value-of select="//correspAction[@type = 'sent']/persName/@key"/>)
                </td>
            </tr>
        </table>
            <table class="letterView">
            <tr>
                <td>Datierung:</td>
                <td>
                    <xsl:choose>
                        <xsl:when test="not(exists(//correspAction[@type = 'sent']/date)) or empty(//correspAction[@type = 'sent']/date)">
                            [undatiert]
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="//correspAction[@type = 'sent']/date[@type = 'source']/@when">
                                <xsl:value-of select="local:formatDate(//correspAction[@type = 'sent']/date[@type = 'source' and @when][1]/@when)"/> (Quelle)
                                <br/>
                            </xsl:if>
                            <xsl:if test="//correspAction[@type = 'sent']/date[@type = 'source']/@from-custom">
                                <xsl:value-of select="local:formatDate(//correspAction[@type = 'sent']/date[@type = 'source']/@from-custom)"/> bis <xsl:value-of select="local:formatDate(//correspAction[@type = 'sent']/date[@type = 'source']/@to-custom)"/> (Quelle)<br/></xsl:if>
                            <xsl:if test="//correspAction[@type = 'sent']/date[@type = 'editor']/@from">
                                <xsl:value-of select="local:formatDate(//correspAction[@type = 'sent']/date[@type = 'editor']/@from)"/> bis <xsl:value-of select="local:formatDate(//correspAction[@type = 'sent']/date[@type = 'editor']/@to)"/> (ermittelt)<br/></xsl:if>
                            <xsl:if test="//correspAction[@type = 'sent']/date[@type = 'postal']/@when">
                                <xsl:value-of select="local:formatDate(//correspAction[@type = 'sent']/date[@type = 'postal']/@when)"/> (Poststempel)<br/></xsl:if>
                            <xsl:if test="//correspAction[@type = 'sent']/date[@type = 'editor']/@notBefore">
                                Frühestens <xsl:value-of select="local:formatDate(//correspAction[@type = 'sent']/date[@type = 'editor']/@notBefore)"/> (ermittelt)<br/>
                            </xsl:if>
                            <xsl:if test="//correspAction[@type = 'sent']/date[@type = 'editor']/@notAfter">
                                Spätestens <xsl:value-of select="local:formatDate(//correspAction[@type = 'sent']/date[@type = 'editor']/@notAfter)"/> (ermittelt)<br/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
                <xsl:if test="//correspAction[@type = 'sent']/note[@type = 'editor']!=''">
                <tr>
                    <td>Anmerkung:</td>
                    <td>
                        <i><xsl:value-of select="//correspAction[@type = 'sent']/note[@type = 'editor']"/></i>
                    </td>
                </tr>
                </xsl:if>
                <xsl:if test="exists(//correspAction[@type = 'sent']/settlement) and not(empty(//correspAction[@type = 'sent']/settlement))">
                <tr>
                <td>Erstellungsort:</td>
                <td>
                        <xsl:value-of select="//correspAction[@type = 'sent']/settlement"/>
                </td>
            </tr>
                </xsl:if>
            </table>
        <table class="letterView">
            <xsl:if test="exists(//correspAction[@type = 'received']/date)">
                <tr>
                    <td>Ankunftsdatum:</td>
                    <td>
                        <xsl:value-of select="//correspAction[@type = 'received']/date"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists(//correspAction[@type = 'received']/settlement) and not(empty(/correspAction[@type = 'received']/settlement))">
                <tr>
                    <td>Ankunftsort:</td>
                    <td>
                        <xsl:value-of select="//correspAction[@type = 'received']/settlement"/>
                    </td>
                </tr>
            </xsl:if>
        </table>
    </xsl:template>

</xsl:stylesheet>
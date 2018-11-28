<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    
    <xsl:template match="/">
        <br/>
        <table>
            <br/>
            <tr>
                <td width="150px">Verfasser:</td>
                <td>
<!--                    <xsl:value-of select="//correspAction[@type = 'sent']/persName/text()"/>-->
                    <xsl:value-of select="//correspAction[@type = 'sent']/persName/text()/substring-after(.,',')"/>
                    <xsl:value-of select="//correspAction[@type = 'sent']/persName/text()/substring-before(.,',')"/>
                    <xsl:if test="exists(//correspAction[@type = 'sent']/persName/idno[@type='gnd'])">
                        [GND: <a href="{concat('http://d-nb.info/gnd/',//correspAction[@type = 'sent']/persName/idno[@type='gnd']/text())}" target="_blank"><xsl:value-of select="//correspAction[@type = 'sent']/persName/idno[@type='gnd']/text()"/></a>]
                    </xsl:if>
                </td>
            </tr>
            <tr>
                <td valign="top">Erstellungsdatum:</td>
                <td>
                    <xsl:value-of select="//correspAction[@type = 'sent']/date"/>
                    <br/>
                    Zeitraum (Quelle): <xsl:value-of select="//correspAction[@type = 'sent']/date[@type='source']/@from-custom"/> bis 
                    <xsl:value-of select="//correspAction[@type = 'sent']/date[@type='source']/@to-custom"/><br/>
                    Zeitraum (Ermittelt): <xsl:value-of select="//correspAction[@type = 'sent']/date[@type='editor']/@from"/> bis <xsl:value-of select="//correspAction[@type = 'sent']/date[@type='editor']/@to"/><br/>
                    Anmerkung: <xsl:value-of select="//correspAction[@type = 'sent']/note[@type='editor']"/>
                    
                    <!--
                    <xsl:choose>
                        <xsl:when test="not(exists(//correspAction[@type = 'sent']/date)) or empty(//correspAction[@type = 'sent']/date)">
                            [unbekannt]
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//correspAction[@type = 'sent']/date"/>
                        </xsl:otherwise>
                    </xsl:choose>-->
                </td>
            </tr>
            <tr>
                <td>Erstellungsort:</td>
                <td>
                    <xsl:if test="exists(//correspAction[@type = 'sent']/settlement) and not(empty(//correspAction[@type = 'sent']/settlement))">
                        <xsl:value-of select="//correspAction[@type = 'sent']/settlement"/>
                    </xsl:if>
                    <xsl:if test="not(exists(//correspAction[@type = 'sent']/settlement)) or empty(//correspAction[@type = 'sent']/settlement)"/>
                </td>
            </tr>
            <tr>
                <td>
                    <br/>
                </td>
                <td/>
            </tr>
            <xsl:if test="exists(//correspAction[@type = 'received']/persName)">
            <tr>
                <td>Adressat:</td>
                <td>
                    
                    <xsl:value-of select="//correspAction[@type = 'received']/persName/text()/substring-after(.,',')"/>
                    <xsl:value-of select="//correspAction[@type = 'received']/persName/text()/substring-before(.,',')"/>
                    <xsl:if test="exists(//correspAction[@type = 'received']/persName/idno[@type='gnd'])">
                        [GND: <a href="{concat('http://d-nb.info/gnd/',//correspAction[@type = 'received']/persName/idno[@type='gnd']/text())}" target="_blank"><xsl:value-of select="//correspAction[@type = 'received']/persName/idno[@type='gnd']/text()"/></a>]
                    </xsl:if>
                </td>
            </tr>
            </xsl:if>
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
            <tr>
                <td>
                    <br/>
                </td>
                <td/>
            </tr>
            
        </table>
    </xsl:template>
    
</xsl:stylesheet>
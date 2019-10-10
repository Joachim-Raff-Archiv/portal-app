<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>

    <xsl:template match="/">
        <br/>
        <table>
            <br/>
            <!--            <xsl:if test="exists(//correspAction[@type = 'received']/persName)">-->
            <tr>
                <td valign="top">Adressat:</td>
                <td>
                    <!--<xsl:choose>
                        <xsl:when test="doc-available(concat('../../../../contents/jra/persons/', //correspAction[@type = 'received']/persName/@key, '.xml'))">
                            <a href="{concat($registerRootPerson, //correspAction[@type = 'received']/persName/@key)}" target="_blank">
                                <xsl:value-of select="//correspAction[@type = 'received']/persName/text()/substring-after(.,',')"/>
                                <xsl:value-of select="//correspAction[@type = 'received']/persName/text()/substring-before(.,',')"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>-->
                    <a href="{concat('http://localhost:8080/exist/apps/raffArchive/html/person/',//correspAction[@type = 'received']/persName/@key)}" target="_blank">
                        <xsl:value-of select="//correspAction[@type = 'received']/persName/text()/substring-after(., ',')"/>
                        <xsl:value-of select="//correspAction[@type = 'received']/persName/text()/substring-before(., ',')"/>
                    </a>
                    <!-- </xsl:otherwise>
                    </xsl:choose>--> [ID: <xsl:value-of select="//correspAction[@type = 'received']/persName/@key"/>]
                    <!--<xsl:if test="exists(//correspAction[@type = 'received']/persName/idno[@type='gnd'])">
                        [GND: <a href="{concat('http://d-nb.info/gnd/',//correspAction[@type = 'received']/persName/idno[@type='gnd']/text())}" target="_blank"><xsl:value-of select="//correspAction[@type = 'received']/persName/idno[@type='gnd']/text()"/></a>]
                    </xsl:if>-->
                </td>
            </tr>
            <!--            </xsl:if>-->
            <tr>
                <td valign="top" width="150px">Absender:</td>
                <td>
                    <!-- <xsl:choose>
                        <xsl:when test="doc-available(concat('../../../../contents/jra/persons/', //correspAction[@type = 'sent']/persName/@key, '.xml'))">
                            <a href="{concat($registerRootPerson, //correspAction[@type = 'sent']/persName/@key)}" target="_blank">
                                <xsl:value-of select="//correspAction[@type = 'sent']/persName/text()/substring-after(.,',')"/>
                                <xsl:value-of select="//correspAction[@type = 'sent']/persName/text()/substring-before(.,',')"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>-->
                    <a href="{concat('http://localhost:8080/exist/apps/raffArchive/html/person/',//correspAction[@type = 'sent']/persName/@key)}" target="_blank">
                        <xsl:value-of select="//correspAction[@type = 'sent']/persName/text()/substring-after(., ',')"/>
                        <xsl:value-of select="//correspAction[@type = 'sent']/persName/text()/substring-before(., ',')"/>
                    </a>
                    <!--</xsl:otherwise>
                    </xsl:choose>--> [ID: <xsl:value-of select="//correspAction[@type = 'sent']/persName/@key"/>]
                    <!--<xsl:if test="exists(//correspAction[@type = 'sent']/persName/idno[@type='gnd'])">
                        [GND: <a href="{concat('http://d-nb.info/gnd/',//correspAction[@type = 'sent']/persName/idno[@type='gnd']/text())}" target="_blank"><xsl:value-of select="//correspAction[@type = 'sent']/persName/idno[@type='gnd']/text()"/></a>]
                    </xsl:if>-->
                </td>
            </tr>
            <tr>
                <td valign="top">Datierung:</td>
                <td>
                    <xsl:if test="//correspAction[@type = 'sent']/date[@type = 'source']/@when">
                        <xsl:value-of select="format-date(xs:date(//correspAction[@type = 'sent']/date[@type = 'source' and @when][1]/@when), '[D]. [M,*-3]. [Y]', 'en', (), ())"/> (Quelle)
                        <br/>
                    </xsl:if>
                    <xsl:if test="//correspAction[@type = 'sent']/date[@type = 'source']/@from-custom">
                        <xsl:value-of select="format-date(xs:date(//correspAction[@type = 'sent']/date[@type = 'source']/@from-custom), '[D]. [M,*-3]. [Y]', 'de', (), ())"/> bis <xsl:value-of select="format-date(xs:date(//correspAction[@type = 'sent']/date[@type = 'source']/@to-custom), '[D]. [M,*-3]. [Y]', 'de', (), ())"/> (Quelle)<br/></xsl:if>
                    <xsl:if test="//correspAction[@type = 'sent']/date[@type = 'editor']/@from">
                        <xsl:value-of select="//correspAction[@type = 'sent']/date[@type = 'editor']/@from"/> bis <xsl:value-of select="//correspAction[@type = 'sent']/date[@type = 'editor']/@to"/> (ermittelt)<br/></xsl:if>
                    <xsl:if test="//correspAction[@type = 'sent']/note[@type = 'editor']">
                        Anmerkung: <xsl:value-of select="//correspAction[@type = 'sent']/note[@type = 'editor']"/>
                    </xsl:if>

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
            <xsl:if test="//correspAction[@type = 'sent']/date[@type = 'postal']">
                <tr>
                    <td valign="top">Poststempel:</td>
                    <td>
                        <xsl:value-of select="format-date(xs:date(//correspAction[@type = 'sent']/date[@type = 'postal']/@when), '[D]. [M,*-3]. [Y]', 'en', (), ())"/>
                    </td>
                </tr>
            </xsl:if>
            <tr>
                <td valign="top">Erstellungsort:</td>
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

            <xsl:if test="exists(//correspAction[@type = 'received']/date)">
                <tr>
                    <td valign="top">Ankunftsdatum:</td>
                    <td>
                        <xsl:value-of select="//correspAction[@type = 'received']/date"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists(//correspAction[@type = 'received']/settlement) and not(empty(/correspAction[@type = 'received']/settlement))">
                <tr>
                    <td valign="top">Ankunftsort:</td>
                    <td>
                        <xsl:value-of select="//correspAction[@type = 'received']/settlement"/>
                    </td>
                </tr>
            </xsl:if>
            <tr>
                <td valign="top">Regeste:</td>
                <td>
                    <xsl:value-of select="//notesStmt/note[@type = 'regeste']"/>
                </td>
            </tr>
            <tr>
                <td>
                    <br/>
                </td>
                <td/>
            </tr>

        </table>
    </xsl:template>

</xsl:stylesheet>
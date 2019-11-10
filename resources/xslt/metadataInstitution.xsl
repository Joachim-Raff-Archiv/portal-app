<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="institution" select="//org"/>
    <xsl:variable name="graphic" select="$institution/ancestor::TEI/facsimile/graphic[1]"/>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$institution/ancestor::TEI/facsimile/graphic">
                <div class="col-3"><img src="{$graphic/@url}" class="img-thumbnail" width="200px"/><br/><br/>
                    <xsl:if test="$graphic/desc"><xsl:value-of select="$graphic/desc"/><br/></xsl:if>Quelle: <a href="{$graphic/@source}" target="_blank"><xsl:value-of select="$graphic/@resp"/></a></div>
                <div class="col">
                    <xsl:call-template name="institutionMetadataView"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="institutionMetadataView"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="institutionMetadataView">
        <table class="institutionView">
            <tr>
                <td valign="top" width="250px">Name:</td>
                <td>
                    <xsl:if test="$institution/orgName">
                        <xsl:value-of select="$institution/orgName"/>
                    </xsl:if>

                </td>
            </tr>
            <tr>
                <td>Ort:</td>
                <td>
                    <xsl:if test="$institution/place/placeName">
                        <xsl:value-of select="string-join($institution/place/placeName, '/')"/>
                    </xsl:if>
                </td>
            </tr>
        </table>
        <table class="institutionView">
            <tr>
                <td> Kategorie: </td>
                <td>
                    <xsl:if test="$institution/desc">
                        <xsl:value-of select="$institution/desc"/>
                    </xsl:if>
                </td>
            </tr>
        </table>
        <table class="institutionView">
            <xsl:if test="exists($institution/persName/roleName)">
                <tr>
                    <td>Funktion:</td>
                    <td>
                        <xsl:value-of select="$institution/persName/roleName"/>
                    </td>
                </tr>
            </xsl:if>
            <!--<xsl:if test="exists($institution//relation[@name = 'reference']//item/text())">
                <tr>
                    <td>Referenzen:</td>
                    <td>
                        <xsl:for-each select="$institution//relation[@name = 'reference']//item">
                        <xsl:value-of
                            select="."/><br/>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>-->
        </table>

        <table class="institutionView">
            <xsl:if test="$institution/idno[@type = 'GND']">
                <tr>
                    <td>Normdaten:</td>
                    <td><a href="{concat('http://d-nb.info/gnd/',$institution/idno[@type='GND'])}" target="_blank"><xsl:value-of select="$institution/idno[@type = 'GND']"/></a>
                        (GND)</td>
                </tr>
            </xsl:if>
            <xsl:if test="$institution/idno[@type = 'VIAF']">
                <tr>
                    <td><xsl:choose><xsl:when test="$institution/idno[@type = 'GND']"/><xsl:otherwise>Normdaten:</xsl:otherwise></xsl:choose></td>
                    <td><a href="{concat('https://viaf.org/viaf/',$institution/idno[@type='VIAF'])}" target="_blank"><xsl:value-of select="$institution/idno[@type = 'VIAF']"/></a>
                        (VIAF)</td>
                </tr>
            </xsl:if>
        </table>
    </xsl:template>
</xsl:stylesheet>
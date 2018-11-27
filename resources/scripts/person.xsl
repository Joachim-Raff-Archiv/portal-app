<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="addrLine | dateline | p | salute | closer">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:variable name="LinkZurPerson" select="concat('http://baumann-digital.de/exist/apps/baudi/html/person/', ./@key, '.xml')"/>
    <xsl:template match="div[@decls = 'inhalt']">
        <p>
            <xsl:apply-templates select=".//body"/>
        </p>
    </xsl:template>
    <xsl:template match="hi[@rend = 'underline']">
        <span style="text-decoration: underline;">
            <xsl:apply-templates select=".//body"/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend = 'italic']">
        <i>
            <xsl:apply-templates select=".//body"/>
        </i>
    </xsl:template>
    <xsl:template match="lb">
        <br/>
        <xsl:apply-templates select=".//body"/>
    </xsl:template>
    <xsl:template match="hi[@rend = 'right']">
        <center>
            <xsl:apply-templates select=".//body"/>
        </center>
    </xsl:template>
    <xsl:template match="persName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('../../../../contents/texts/persons/', ./@key, '.xml'))">
                <a href="{concat('../baudi/html/person/', ./@key, '.html')}" target="_blank">
                    <xsl:apply-templates select=".//body"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select=".//body"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="orgName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('../../../../contents/texts/institutions/', ./@key, '.xml'))">
                <a href="{concat('../baudi/html/institution/', ./@key, '.html')}" target="_blank">
                    <xsl:apply-templates select=".//body"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select=".//body"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="settlement">
        <xsl:choose>
            <xsl:when test="doc-available(concat('../../../../contents/texts/loci/', ./@key, '.xml'))">
                <a href="{concat('../baudi/html/ort/', ./@key, '.html')}" target="_blank">
                    <xsl:apply-templates select=".//body"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select=".//body"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="note[@type = 'editor']">
        <i>[<xsl:apply-templates select=".//body"/>]</i>
    </xsl:template>
    <xsl:template match="figure[@type='Stammbaum']">
        <div>
            <img src="{./@facs}" width="2000"/>
        </div>
    </xsl:template>
    <xsl:template name="Steckbrief" match="//teiHeader">
        <table>
            <tr>
                <td>Name:</td>
                <td>
                    <xsl:value-of select="//listPerson/person/persName/surname"/>
                </td>
            </tr>
            <tr>
                <td>Vorname(n)</td>
                <td>
                    <xsl:for-each select="//listPerson/person/persName/forename">
                        <xsl:sort select="./@n" data-type="text" order="ascending"/>
                        <xsl:if test="./@type='used'">
                            <xsl:value-of select="."/> | </xsl:if>
                        <xsl:if test="not(./@type='used')">(<xsl:value-of select="."/>) | </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
            <tr>
                <td>Geschlecht:</td>
                <td/>
            </tr>
            <tr>
                <td>Geboren</td>
                <td>am "DATUM" in "ORT"</td>
            </tr>
            <tr>
                <td>Gestorben</td>
                <td>am "DATUM" in "ORT"</td>
            </tr>
            <tr>
                <td>Nationalität</td>
                <td/>
            </tr>
            <tr>
                <td>Konfession</td>
                <td/>
            </tr>
            <tr>
                <td>Beruf</td>
                <td/>
            </tr>
            <tr>
                <td>Biographische Stationen</td>
                <td/>
            </tr>
        </table>
        <xsl:apply-templates select=".//body"/>
    </xsl:template>
</xsl:stylesheet>
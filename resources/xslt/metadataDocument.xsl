<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:template match="/">
        <br/>
        <table>
            <br/>
            <tr>
                <td>Titel:</td>
                <td>
                    <xsl:value-of select="//sourceDesc/bibl/title"/>
                    <xsl:choose>
                        <xsl:when test="doc-available(concat('../../../../contents/texts/persons/', //sourceDesc/bibl/title/@key, '.xml'))">
                            <a href="{concat($registerRootPerson, //sourceDesc/bibl/title/@key, '.html')}" target="_blank">
                                <xsl:value-of select="//sourceDesc/bibl/title"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//sourceDesc/bibl/title"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
            <tr>
                <td>Autor:</td>
                <td>
                    <xsl:value-of select="//sourceDesc/bibl/author"/>
                </td>
            </tr>
            <tr>
                <td>Ort:</td>
                <td>
                    <xsl:value-of select="//sourceDesc/bibl/settlement"/>
                </td>
            </tr>
            <tr>
                <td>Datum:</td>
                <td>
                    <xsl:value-of select="//sourceDesc/bibl/date"/>
                </td>
            </tr>
            <tr>
                <td>Verlag:</td>
                <td>
                    <xsl:value-of select="//sourceDesc/bibl/publisher"/>
                </td>
            </tr>
            <tr>
                <td>
                    <br/>
                </td>
                <td/>
            </tr>
            <tr>
                <td>Erwähnte Daten:</td>
                <td>
                    <xsl:call-template name="genannteDaten"/>
                </td>
            </tr>
            <tr>
                <td>Erwähnte Orte:</td>
                <td>
                    <xsl:call-template name="genannteOrte"/>
                </td>
            </tr>
            <tr>
                <td>
                    <br/>
                </td>
                <td/>
            </tr>
            <tr>
                <td>Erwähnte Personen:</td>
                <td>
                    <xsl:call-template name="genanntePersonen"/>
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
    <xsl:template name="genannteDaten">
        <xsl:for-each select="//div[@type='page']//date/@when-iso">
            <xsl:sort select="data(.)" data-type="text" order="ascending"/>
            <xsl:if test="string-length(.)=10">
                <xsl:value-of select="./substring(.,9,10)"/>.</xsl:if>
            <xsl:if test="string-length(.)=7 or string-length(.)=10">
                <xsl:value-of select="./substring(.,6,2)"/>.</xsl:if>
            <xsl:value-of select="./substring(.,1,4)"/> (<xsl:value-of select="parent::node()"/>)<br/>
        </xsl:for-each>
        <br/>
        <xsl:for-each select="//div[@type='page']//date/@from-iso">
            <xsl:sort select="data(.)" data-type="text" order="ascending"/>
            ab <xsl:if test="string-length(.)=10">
                <xsl:value-of select="./substring(.,9,10)"/>.</xsl:if>
            <xsl:if test="string-length(.)=7 or string-length(.)=10">
                <xsl:value-of select="./substring(.,6,2)"/>.</xsl:if>
            <xsl:value-of select="./substring(.,1,4)"/> (<xsl:value-of select="parent::node()"/>)<br/>
        </xsl:for-each>
        <br/>
        <xsl:for-each select="//div[@type='page']//date[not(@from-iso)]/@to-iso">
            <xsl:sort select="data(.)" data-type="text" order="ascending"/>
            bis <xsl:if test="string-length(.)=10">
                <xsl:value-of select="./substring(.,9,10)"/>.</xsl:if>
            <xsl:if test="string-length(.)=7 or string-length(.)=10">
                <xsl:value-of select="./substring(.,6,2)"/>.</xsl:if>
            <xsl:value-of select="./substring(.,1,4)"/> (<xsl:value-of select="parent::node()"/>)<br/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="genannteOrte">
        <xsl:for-each select="//div[@type='page']//distinct-values(placeName)">
            <xsl:sort select="." data-type="text" order="ascending"/>
            <xsl:value-of select="."/>
            <br/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="genanntePersonen">
        <xsl:for-each select="//div[@type='page']//distinct-values(persName)">
            <xsl:sort select="." data-type="text" order="ascending"/>
            <xsl:value-of select="."/>
            <br/>
        </xsl:for-each>
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
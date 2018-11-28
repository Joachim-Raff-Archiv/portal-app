<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:template match="/">
        <link href="../../resources/css/dokument.css" rel="stylesheet" type="text/css"/>
        <br/>
        <br/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="div[@type = 'titlepage']">
        <div class="titlepage">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="div[@type = 'page']">
        <xsl:for-each select=".">
            <br/>
            <div class="page">
                <p class="text-center">
                    [Seite <xsl:value-of select="@n"/>]
                </p>
                <xsl:if test="exists(@decls)">
                    <p class="text-right">
                        <i>Abschnitt: <xsl:value-of select="@decls"/>
                        </i>
                    </p>
                </xsl:if>
                <xsl:apply-templates/>
                <br/>
                <p class="text-center">
                    [Seite <xsl:value-of select="@n"/>]
                </p>
            </div>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="hi[@rend = 'right']">
        <p class="text-right">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="hi[@rend = 'center']">
        <p class="text-center">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="hi[@rend = 'left']">
        <p class="text-left">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="hi[@rend='underline']">
        <span style="text-decoration: underline;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend = 'italic']">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    <xsl:template match="hi[@rend='heading1']">
        <h1>
            <xsl:apply-templates/>
        </h1>
    </xsl:template>
    <xsl:template match="hi[@rend='heading3']">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    <xsl:template match="hi[@rend='heading5']">
        <h5>
            <xsl:apply-templates/>
        </h5>
    </xsl:template>
    <xsl:template match="lb">
        <br/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="persName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('../../../../contents/texts/persons/', ./@key, '.xml'))">
                <a href="{concat($registerRootPerson, ./@key, '.html')}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="orgName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('../../../../contents/texts/institutions/', ./@key, '.xml'))">
                <a href="{concat($registerRootInstitution, ./@key, '.html')}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="settlement">
        <xsl:choose>
            <xsl:when test="doc-available(concat('../../../../contents/texts/loci/', ./@key, '.xml'))">
                <a href="{concat($registerRootOrt, ./@key, '.html')}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="note[@type = 'editor']">
        <i>[<xsl:apply-templates/>]</i>
    </xsl:template>
    <xsl:template match="table">
        <xsl:choose>
            <xsl:when test="exists(element(cb))">
                <table>
                    <tr>
                        <td valign="top">
                            <table>
                                <tr>
                                    <td>
                                        <xsl:for-each select="row[following-sibling::cb]">
                                            <tr>
                                                <xsl:choose>
                                                    <xsl:when test="cell[1][@rows]">
                                                        <xsl:variable name="rows" select="cell[1]/@rows/data(.)"/>
                                                        <td rowspan="{$rows}" class="rowspanned">
                                                            <xsl:value-of select="cell[1]"/>
                                                        </td>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <td>
                                                            <xsl:value-of select="cell[1]"/>
                                                        </td>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:choose>
                                                    <xsl:when test="cell[2][@rows]">
                                                        <xsl:variable name="rows" select="cell[2]/@rows/data(.)"/>
                                                        <td rowspan="{$rows}" class="rowspanned">
                                                            <img src="http://localhost:8080/exist/apps/baudi/resources/img/rightBracket.svg" height="55"/>
                                                            <xsl:value-of select="cell[2]"/>
                                                        </td>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <td>
                                                            <xsl:value-of select="cell[2]"/>
                                                        </td>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </tr>
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td valign="top">
                            <table>
                                <tr>
                                    <td>
                                        <xsl:for-each select="row[preceding-sibling::cb]">
                                            <tr>
                                                <td>
                                                    <xsl:value-of select="cell[1]"/>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="cell[2]"/>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </xsl:when>
            <xsl:when test="row/count(cell) = 8">
                <table>
                    <xsl:for-each select="row">
                        <tr>
                            <td>
                                <xsl:value-of select="cell[1]"/>
                            </td>
                            <td>
                                <xsl:value-of select="cell[2]"/>
                            </td>
                            <td>
                                <xsl:value-of select="cell[3]"/>
                            </td>
                            <td>
                                <xsl:value-of select="cell[4]"/>
                            </td>
                            <td>
                                <xsl:value-of select="cell[5]"/>
                            </td>
                            <td>
                                <xsl:value-of select="cell[6]"/>
                            </td>
                            <td>
                                <xsl:value-of select="cell[7]"/>
                            </td>
                            <td>
                                <xsl:value-of select="cell[8]"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <table>
                    <xsl:for-each select="row">
                        <tr>
                            <td>
                                <xsl:value-of select="cell[1]"/>
                            </td>
                            <td>
                                <xsl:value-of select="cell[2]"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
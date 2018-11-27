<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output encoding="UTF-8" indent="yes" method="xhtml"/>
    <xsl:template match="/">
        <html xml:lang="dt">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>Theaterzettel (TEI als HTML-Ansicht)</title>
                <meta name="author" content="Dennis Ried"/>
                <link href="../css/TZ.css" rel="stylesheet" type="text/css"/>
            </head>
            <body class="boxed">
                <div>
                    <xsl:apply-templates/>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:variable name="pKopfzeile" select="//tei:text//tei:p[@decls = 'kopfzeile']"/>
    <xsl:variable name="pTitelBesetzung" select="//tei:text//tei:div[1]/tei:p[@decls = 'titelBesetzung']"/>
    <xsl:variable name="pTitelBesetzung2" select="//tei:text//tei:div[2]/tei:p[@decls = 'titelBesetzung']"/>
    <xsl:variable name="castItem" select="$pTitelBesetzung/tei:castList/tei:castItem"/>
    <xsl:variable name="castItem2" select="$pTitelBesetzung2/tei:castList/tei:castItem"/>
    <xsl:template match="tei:TEI">
        <xsl:choose>
            <xsl:when test="$pKopfzeile/tei:orgName/@rend = 'center'">
                <xsl:element name="center">
                    <xsl:element name="h3">
                        <xsl:value-of select="tei:text//tei:p[@decls = 'kopfzeile']/tei:orgName/text()"/>
                    </xsl:element>
                    <br/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="h3">
                    <xsl:value-of select="tei:text//tei:p[@decls = 'kopfzeile']/tei:orgName/text()"/>
                </xsl:element>
                <br/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="tei:text//tei:p[@decls = 'kopfzeile']/tei:orgName/@rend = 'center'">
                <xsl:element name="center">
                    <xsl:value-of select="tei:text//tei:p[@decls = 'kopfzeile']/tei:date/text()"/>
                    <br/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="tei:text//tei:p[@decls = 'kopfzeile']/tei:date/text()"/>
                <br/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:element name="hr"/>
        <xsl:element name="center">
            <xsl:element name="h1">
                <xsl:value-of select="$pTitelBesetzung/tei:title[@type = 'main']"/>
            </xsl:element>
            <xsl:value-of select="$pTitelBesetzung/tei:title[@type = 'sub']"/>
            <xsl:value-of select="$pTitelBesetzung/substring-before(substring-after(., tei:title[2]), tei:castList)"/>
        </xsl:element>
        <xsl:element name="hr"/>
        <xsl:element name="center">
            <xsl:value-of select="$pTitelBesetzung/tei:castList/tei:head"/>
        </xsl:element>
        <xsl:element name="hr"/>
        <xsl:element name="center">
            <table>
                <xsl:for-each select="$castItem">
                    <tr>
                        <td class="role">
                            <xsl:element name="span">
                                <xsl:value-of select="tei:role"/>
                                <xsl:if test="exists(tei:roleDesc)">, <xsl:value-of select="tei:roleDesc"/>
                                </xsl:if>
                            </xsl:element>
                        </td>
                        <td class="name">
                            <xsl:element name="span">
                                <xsl:value-of select="tei:actor"/>
                            </xsl:element>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>
        </xsl:element>
        <xsl:element name="center">
            <xsl:element name="h1">
                <xsl:value-of select="$pTitelBesetzung2/tei:title[@type = 'main']"/>
            </xsl:element>
            <xsl:value-of select="$pTitelBesetzung2/tei:title[@type = 'sub']"/>
            <xsl:value-of select="$pTitelBesetzung2/substring-before(substring-after(., tei:title[2]), tei:castList)"/>
        </xsl:element>
        <xsl:element name="hr"/>
        <xsl:element name="center">
            <xsl:value-of select="$pTitelBesetzung2/tei:castList/tei:head"/>
        </xsl:element>
        <xsl:element name="hr"/>
        <xsl:element name="center">
            <table>
                <xsl:for-each select="$pTitelBesetzung2//$castItem2">
                    <tr>
                        <td class="role">
                            <xsl:element name="span">
                                <xsl:value-of select="tei:role"/>
                                <xsl:if test="exists(tei:roleDesc)">, <xsl:value-of select="tei:roleDesc"/>
                                </xsl:if>
                            </xsl:element>
                        </td>
                        <td class="name">
                            <xsl:element name="span">
                                <xsl:value-of select="tei:actor"/>
                            </xsl:element>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>
        </xsl:element>
        <xsl:element name="hr"/>
        <xsl:element name="center">
            <xsl:element name="h4">
                <xsl:value-of select="//tei:div[@decls = 'zeitspanne']"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
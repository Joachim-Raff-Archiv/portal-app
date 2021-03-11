<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="https://portal.raff-archive.ch/ns/local" exclude-result-prefixes="xs" version="2.0">

    <xsl:function name="local:formatDate">
        <xsl:param name="dateRaw"/>
            <xsl:choose>
                <xsl:when test="$dateRaw = '0000' or $dateRaw = '0000-00' or $dateRaw = '0000-00-00'">
                    <xsl:value-of select="'[undatiert]'"/>
                </xsl:when>
                <xsl:when test="string-length($dateRaw) = 4 and not(contains($dateRaw, '00'))">
                    <xsl:variable name="date" select="concat($dateRaw, '-01-01')"/>
                    <xsl:value-of select="format-date(xs:date($date), '[Y]', (), (), ())"/>
                </xsl:when>
                <xsl:when test="string-length($dateRaw) = 7 and not(contains($dateRaw, '00'))">
                    <xsl:variable name="date" select="concat($dateRaw, '-01')"/>
                    <xsl:variable name="dateFormatted" select="format-date(xs:date($date), '[Mn] [Y]', (), (), ())"/>
                    <xsl:value-of select="concat(upper-case(substring($dateFormatted,1,1)), substring($dateFormatted,2))"/>
                </xsl:when>
                <!--<xsl:when test="contains($dateRaw, '-01-01') or contains($dateRaw, '-12-31')">
                    <xsl:value-of select="format-date(xs:date($dateRaw), '[Y]', (), (), ())"/>
                </xsl:when>-->
                <xsl:when test="ends-with($dateRaw, '-01') or ends-with($dateRaw, '-31') or ends-with($dateRaw, '-30') or ends-with($dateRaw, '-02-28')">
                    <xsl:variable name="dateFormatted" select="format-date(xs:date($dateRaw), '[Mn] [Y]', (), (), ())"/>
                    <xsl:value-of select="concat(upper-case(substring($dateFormatted,1,1)), substring($dateFormatted,2))"/>
                </xsl:when>
                <xsl:when test="string-length($dateRaw) = 10 and not(contains($dateRaw, '00'))">
                    <xsl:variable name="date" select="$dateRaw"/>
                    <xsl:variable name="dateFormatted" select="format-date(xs:date($dateRaw), '[D]. [M]. [Y]', (), (), ())"/>
                    <xsl:value-of select="$dateFormatted"/>
<!--                    <xsl:value-of select="concat(upper-case(substring(subsequence(tokenize($dateFormatted, ' '),2,1),1,1)), substring(subsequence(tokenize($dateFormatted, ' '),2,1),2))"/>-->
                </xsl:when>
                <xsl:otherwise>
                    [undatiert]
                </xsl:otherwise>
            </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
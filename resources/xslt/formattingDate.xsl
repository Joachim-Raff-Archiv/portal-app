<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="https://portal.raff-archive.ch/ns/local" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0" xml:lang="de">

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
                    <xsl:value-of select="format-date(xs:date($date), '[Mn,*-3]. [Y]', (), (), ())"/>
                </xsl:when>
                <xsl:when test="contains($dateRaw, '-01-01') or contains($dateRaw, '-12-31')">
                    <xsl:value-of select="format-date(xs:date($dateRaw), '[Y]', (), (), ())"/>
                </xsl:when>
                <xsl:when test="string-length($dateRaw) = 10 and not(contains($dateRaw, '00'))">
                    <xsl:variable name="date" select="$dateRaw"/>
                    <xsl:value-of select="format-date(xs:date($date), '[D]. [M]. [Y]', (), (), ())"/>
                </xsl:when>
                <xsl:otherwise>
                    [undatiert]
                </xsl:otherwise>
            </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
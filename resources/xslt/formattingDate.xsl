<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="https://portal.raff-archive.ch/ns/local" exclude-result-prefixes="xs" version="2.0">
    
    <xsl:function name="local:monthSwitch">
        <xsl:param name="input"/>
        <xsl:choose>
            <xsl:when test="$input = 'january'">Januar</xsl:when>
            <xsl:when test="$input = 'february'">Februar</xsl:when>
            <xsl:when test="$input = 'march'">März</xsl:when>
            <xsl:when test="$input = 'april'">April</xsl:when>
            <xsl:when test="$input = 'may'">Mai</xsl:when>
            <xsl:when test="$input = 'june'">Juni</xsl:when>
            <xsl:when test="$input = 'july'">Juli</xsl:when>
            <xsl:when test="$input = 'august'">August</xsl:when>
            <xsl:when test="$input = 'september'">September</xsl:when>
            <xsl:when test="$input = 'october'">Oktober</xsl:when>
            <xsl:when test="$input = 'november'">November</xsl:when>
            <xsl:when test="$input = 'december'">Dezember</xsl:when>
            <xsl:otherwise><xsl:value-of select="$input"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
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
                    <xsl:variable name="monthFormatted" select="local:monthSwitch(format-date(xs:date($date), '[Mn]', (), (), ()))"/>
                    <xsl:variable name="dateFormatted" select="format-date(xs:date($date), '[Y]', (), (), ())"/>
                    <xsl:value-of select="concat($monthFormatted, ' ', $dateFormatted)"/>
                </xsl:when>
                <xsl:when test="ends-with($dateRaw, '-01') or ends-with($dateRaw, '-31') or ends-with($dateRaw, '-30') or ends-with($dateRaw, '-02-28')">
                    <xsl:variable name="date" select="$dateRaw"/>
                    <xsl:variable name="monthFormatted" select="local:monthSwitch(format-date(xs:date($date), '[Mn]', (), (), ()))"/>
                    <xsl:variable name="yearFormatted" select="format-date(xs:date($date), '[Y]', (), (), ())"/>
                    <xsl:value-of select="concat($monthFormatted, ' ', $yearFormatted)"/>
                </xsl:when>
                <xsl:when test="string-length($dateRaw) = 10 and not(contains($dateRaw, '00'))">
                    <xsl:variable name="date" select="$dateRaw"/>
                    <xsl:variable name="dateFormatted" select="format-date(xs:date($dateRaw), '[D]', (), (), ())"/>
                    <xsl:variable name="monthFormatted" select="local:monthSwitch(format-date(xs:date($date), '[Mn]', (), (), ()))"/>
                    <xsl:variable name="yearFormatted" select="format-date(xs:date($date), '[Y]', (), (), ())"/>
                    <xsl:value-of select="concat($dateFormatted, '. ', $monthFormatted, ' ', $yearFormatted)"/>
                </xsl:when>
                <xsl:otherwise>
                    [undatiert]
                </xsl:otherwise>
            </xsl:choose>
    </xsl:function>
    
    

</xsl:stylesheet>
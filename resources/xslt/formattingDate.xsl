<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://portal.raff-archive.ch/ns/local" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0" xml:lang="de">

    <xsl:function name="local:formatDate">
        <xsl:param name="dateRaw"/>
        
        <xsl:choose>
        <xsl:when test="$dateRaw/ancestor::mei:mei">

            <xsl:if test="string-length($dateRaw) = 10 and not(contains($dateRaw, '00'))">
                <xsl:variable name="date" select="$dateRaw"/>
                <xsl:value-of select="format-date(xs:date($date), '[D]. [M]. [Y]', 'en', (), ())"/>
            </xsl:if>

            <xsl:if test="$dateRaw = '0000' or $dateRaw = '0000-00' or $dateRaw = '0000-00-00'">
                <xsl:value-of select="'[undatiert]'"/>
            </xsl:if>

            <xsl:if test="string-length($dateRaw) = 7 and not(contains($dateRaw, '00'))">
                <xsl:variable name="date" select="concat($dateRaw, '-01')"/>
                <xsl:variable name="dateFormattedStep1" select="format-date(xs:date($date), '[M]. [Y]', 'en', (), ())"/>

                <xsl:choose>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '1'">
                        <xsl:value-of select="concat('Januar', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '2'">
                        <xsl:value-of select="concat('Februar', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '3'">
                        <xsl:value-of select="concat('März', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '4'">
                        <xsl:value-of select="concat('April', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '5'">
                        <xsl:value-of select="concat('Mai', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '6'">
                        <xsl:value-of select="concat('Juni', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '7'">
                        <xsl:value-of select="concat('Juli', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '8'">
                        <xsl:value-of select="concat('August', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '9'">
                        <xsl:value-of select="concat('September', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '10'">
                        <xsl:value-of select="concat('Oktober', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '11'">
                        <xsl:value-of select="concat('November', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:when test="substring-before($dateFormattedStep1, '.') = '12'">
                        <xsl:value-of select="concat('Dezember', substring-after($dateFormattedStep1, '.'))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$dateFormattedStep1"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:if>

        </xsl:when>
            
            <!--<xsl:when test="$dateRaw/ancestor::tei:TEI">
                
                <xsl:if test="string-length($dateRaw) = 10 and not(contains($dateRaw, '00'))">
                    <xsl:variable name="date" select="$dateRaw"/>
                    <xsl:value-of select="format-date(xs:date($date), '[D]. [M]. [Y]', 'en', (), ())"/>
                </xsl:if>
                
                <xsl:if test="$dateRaw = '0000' or $dateRaw = '0000-00' or $dateRaw = '0000-00-00'">
                    <xsl:value-of select="'[undatiert]'"/>
                </xsl:if>
                
                <xsl:if test="string-length($dateRaw) = 7 and not(contains($dateRaw, '00'))">
                    <xsl:variable name="date" select="concat($dateRaw, '-01')"/>
                    <xsl:variable name="dateFormattedStep1"
                        select="format-date(xs:date($date), '[M]. [Y]', 'en', (), ())"/>
                    
                    <xsl:choose>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '1'">
                            <xsl:value-of
                                select="concat('Januar', substring-after($dateFormattedStep1, '.'))"/>
                        </xsl:when>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '2'">
                            <xsl:value-of
                                select="concat('Februar', substring-after($dateFormattedStep1, '.'))"/>
                        </xsl:when>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '3'">
                            <xsl:value-of
                                select="concat('März', substring-after($dateFormattedStep1, '.'))"/>
                        </xsl:when>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '4'">
                            <xsl:value-of
                                select="concat('April', substring-after($dateFormattedStep1, '.'))"/>
                        </xsl:when>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '5'">
                            <xsl:value-of
                                select="concat('Mai', substring-after($dateFormattedStep1, '.'))"/>
                        </xsl:when>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '6'">
                            <xsl:value-of
                                select="concat('Juni', substring-after($dateFormattedStep1, '.'))"/>
                        </xsl:when>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '7'">
                            <xsl:value-of
                                select="concat('Juli', substring-after($dateFormattedStep1, '.'))"/>
                        </xsl:when>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '8'">
                            <xsl:value-of
                                select="concat('August', substring-after($dateFormattedStep1, '.'))"/>
                        </xsl:when>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '9'">
                            <xsl:value-of
                                select="concat('September', substring-after($dateFormattedStep1, '.'))"
                            />
                        </xsl:when>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '10'">
                            <xsl:value-of
                                select="concat('Oktober', substring-after($dateFormattedStep1, '.'))"/>
                        </xsl:when>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '11'">
                            <xsl:value-of
                                select="concat('November', substring-after($dateFormattedStep1, '.'))"/>
                        </xsl:when>
                        <xsl:when test="substring-before($dateFormattedStep1, '.') = '12'">
                            <xsl:value-of
                                select="concat('Dezember', substring-after($dateFormattedStep1, '.'))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$dateFormattedStep1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:if>
                
            </xsl:when>-->
            <xsl:otherwise>
                <xsl:value-of select="$dateRaw"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
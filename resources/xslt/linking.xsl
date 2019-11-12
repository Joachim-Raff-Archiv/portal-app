<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:variable name="viewPerson" select="'http://portal.raff-archiv.ch/html/person/'"/>
    <xsl:variable name="viewInstitution" select="'http://portal.raff-archiv.ch/html/institution/'"/>
    <xsl:variable name="viewWork" select="'http://portal.raff-archiv.ch/html/work/'"/>
    <xsl:variable name="viewLocus" select="'http://portal.raff-archiv.ch/html/locus/'"/>
    <xsl:variable name="viewManuscript" select="'http://portal.raff-archiv.ch/html/sources/manuscript/'"/>
    <xsl:variable name="viewPrint" select="'http://portal.raff-archiv.ch/html/sources/print/'"/>
    
    <!-- Linking persons -->
    <xsl:template match="persName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/contents/jra/persons/', ./@key, '.xml'))">
                <a href="{concat($viewPerson, ./@key)}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Linking institutions -->
    <xsl:template match="orgName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/contents/jra/institutions/', ./@key, '.xml'))">
                <a href="{concat($viewInstitution, ./@key)}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Linking works -->
    <xsl:template match="title">
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/contents/jra/works/', ./@key, '.xml'))">
                <a href="{concat($viewWork, ./@key)}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Linking settlements -->
    <!--<xsl:template match="settlement">
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/contents/jra/loci/', ./@key, '.xml'))">
                <a href="{concat($viewLocus, ./@key)}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    
    
</xsl:stylesheet>
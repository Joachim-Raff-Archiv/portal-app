<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:variable name="viewPerson" select="'http://portal.raff-archiv.ch/html/person/'"/>
    <xsl:variable name="viewInstitution" select="'http://portal.raff-archiv.ch/html/institution/'"/>
    <xsl:variable name="viewWork" select="'http://portal.raff-archiv.ch/html/work/'"/>
    <xsl:variable name="viewLocus" select="'http://portal.raff-archiv.ch/html/locus/'"/>
    <xsl:variable name="viewManuscript" select="'http://portal.raff-archiv.ch/html/sources/manuscript/'"/>
    <xsl:variable name="viewPrint" select="'http://portal.raff-archiv.ch/html/sources/print/'"/>
    
    <!-- Linking persons -->
    <xsl:template match="tei:persName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/contents/jra/persons/', ./@key, '.xml'))">
                <a href="{concat($viewPerson, ./@key)}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mei:persName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/contents/jra/persons/', ./@auth, '.xml'))">
                <a href="{concat($viewPerson, ./@auth)}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Linking institutions -->
    <xsl:template match="tei:orgName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/contents/jra/institutions/', ./@key, '.xml'))">
                <a href="{concat($viewInstitution, ./@key)}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mei:corpName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/contents/jra/institutions/', ./@auth, '.xml'))">
                <a href="{concat($viewInstitution, ./@auth)}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Linking works -->
    <xsl:template match="tei:title">
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/contents/jra/works/', ./@key, '.xml'))">
                <a href="{concat($viewWork, ./@key)}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mei:title">
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/contents/jra/works/', ./@auth, '.xml'))">
                <a href="{concat($viewWork, ./@auth)}">
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
                <a href="{concat($viewLocus, ./@key)}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    
    
</xsl:stylesheet>
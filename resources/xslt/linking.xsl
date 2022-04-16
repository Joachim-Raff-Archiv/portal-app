<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:variable name="viewPerson" select="'person/'"/>
    <xsl:variable name="viewInstitution" select="'institution/'"/>
    <xsl:variable name="viewWork" select="'work/'"/>
    <xsl:variable name="viewLocus" select="'locus/'"/>
    <xsl:variable name="viewManuscript" select="'sources/manuscript/'"/>
    <xsl:variable name="viewPrint" select="'sources/print/'"/>
    
    <!-- Linking persons -->
    <xsl:template match="tei:persName">
        <xsl:variable name="dirPersons" select="concat('C', substring(@key, 2, 3), '00')"/>
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/apps/jra-data/persons/', $dirPersons, '/',  ./@key, '.xml'))">
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
        <xsl:variable name="dirPersons" select="concat('C', substring(@key, 2, 3), '00')"/>
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/apps/jra-data/persons/', $dirPersons, '/',  ./@key, '.xml'))">
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
        <xsl:variable name="dirInstitutions" select="concat('D', substring(@key, 2, 3), '00')"/>
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/apps/jra-data/institutions/', $dirInstitutions, '/',  ./@key, '.xml'))">
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
        <xsl:variable name="dirInstitutions" select="concat('D', substring(@key, 2, 3), '00')"/>
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/apps/jra-data/institutions/', $dirInstitutions, '/',  ./@key, '.xml'))">
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
        <xsl:variable name="dirWorks" select="concat('B', substring(@key, 2,2), '00')"/>
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/apps/jra-data/works/', $dirWorks, '/',  ./@key, '.xml'))">
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
        <xsl:variable name="dirWorks" select="concat('B', substring(@key, 2,2), '00')"/>
        <xsl:choose>
            <xsl:when test="doc-available(concat('/db/apps/jra-data/works/', $dirWorks, '/',  ./@key, '.xml'))">
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
            <xsl:when test="doc-available(concat('/db/apps/jra-data/loci/', ./@key, '.xml'))">
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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:variable name="registerRootPerson" select="'http://185.194.143.51:8080/exist/apps/raffArchive/html/person/'"/>
    <xsl:variable name="registerRootInstitution" select="'http://185.194.143.51:8080/exist/apps/raffArchive/html/institution/'"/>
    <xsl:variable name="registerRootOrt" select="'http://185.194.143.51:8080/exist/apps/raffArchive/html/ort/'"/>
    <xsl:variable name="registerRootManuskript" select="'http://185.194.143.51:8080/exist/apps/raffArchive/html/sources/manuscript/'"/>
    <xsl:variable name="registerRootDruck" select="'http://185.194.143.51:8080/exist/apps/raffArchive/html/sources/print/'"/>
    <!--<xsl:variable name="LinkPerson">
        <xsl:choose>
            <xsl:when test="doc-available(concat('http://185.194.143.51:8080/exist/contents/texts/persons/', ./@key, '.xml'))">
                <a href="{concat($registerRootPerson, ./@key, '.html')}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>-->
</xsl:stylesheet>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="formattingText.xsl"/>
    <xsl:variable name="briefID" select="//TEI/@xml:id/string(.)"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
</xsl:stylesheet>
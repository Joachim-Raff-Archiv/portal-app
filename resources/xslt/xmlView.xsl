<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="/">
        <div data-spy="scroll" id="list-letters" class="list-group pre-scrollable">
        <xmp>
            <xsl:copy-of select="."/>
        </xmp>
        </div>
    </xsl:template>
</xsl:stylesheet>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:template match="/">
        <br/>
        <table class="letterContentView">
            <xsl:if test="//notesStmt/note[@type='regeste']">
            <tr>
                <td>Regeste:</td>
                <td>
                    <xsl:value-of select="//notesStmt/note[@type = 'regeste']"/>
                </td>
            </tr>
            <tr>
                <td>
                    <br/>
                </td>
                <td/>
            </tr>
            </xsl:if>
        </table>
            
            <xsl:if test="//body/opener[. != '']">
                <table class="letterContentView">
                <tr>
                    <td>Beginn:</td>
                    <td>
                            <xsl:value-of select="//body/opener"/>
                            <br/>
                    </td>
                </tr>
                </table>
        
            </xsl:if>
            <xsl:if test="//body/div[@type = 'volltext']/p[. != '']">
                <table class="letterContentView">
                <tr>
                    <td>Volltext:</td>
                    <td>
                        <xsl:value-of select="//body/div[@type = 'volltext']"/>
                    </td>
                </tr>
                </table>
            </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
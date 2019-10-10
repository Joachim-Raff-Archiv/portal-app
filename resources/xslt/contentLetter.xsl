<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:template match="/">
        <br/>
        <table>
            <xsl:if test="//notesStmt/note[@type='regeste']">
                <tr>
                    <td width="150px" valign="top">Regeste:</td>
                    <td>
                            <xsl:value-of select="//notesStmt/note[@type='regeste']"/>
                            <br/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="//body/opener[. != '']">
                <tr>
                    <td width="150px" valign="top">Beginn:</td>
                    <td>
                            <xsl:value-of select="//body/opener"/>
                            <br/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="//body/div[@type = 'volltext']/p[. != '']">
                <tr>
                    <td width="150px" valign="top">Volltext:</td>
                    <td>
                            <xsl:value-of select="//body/div[@type = 'volltext']"/>
                    </td>
                </tr>
            </xsl:if>
            <tr>
                <td>
                    <br/>
                </td>
                <td/>
            </tr>
        </table>

    </xsl:template>
</xsl:stylesheet>
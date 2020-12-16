<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="formattingText.xsl"/>
    <xsl:template match="/">
        <xsl:apply-templates select="//body"/>
    </xsl:template>
    <xsl:template match="figure[@type='icon']">
        <xsl:variable name="picture" select="@source"/>
        <img src="{$picture}" width="20" style="padding: 5px 0px 7px 0px;"/>
    </xsl:template>
    <xsl:template match="figure[@type='logo']">
        <xsl:variable name="picture" select="@source"/>
        <img src="{$picture}" width="115"/>
    </xsl:template>
    
    <xsl:template match="table">
        
        <table>
            <xsl:apply-templates/> <!-- select="//table" -->
        </table>
    </xsl:template>
    <xsl:template match="row">
        <tr>
            <xsl:apply-templates/> <!-- select="//table" -->
        </tr>
    </xsl:template>
    <xsl:template match="cell[not(ancestor::table/@style='impressum')]">
        <xsl:choose>
            <xsl:when test="@rend='top'">
                <td valign="top">
                    <xsl:apply-templates/> <!-- select="//table" -->
                </td>
            </xsl:when>
            <xsl:otherwise>
                <td>
                    <xsl:apply-templates/> <!-- select="//table" -->
                </td>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    <xsl:template match="cell[ancestor::table/@style='impressum']">
        <td valign="center" width="225px">
            <xsl:apply-templates/> <!-- select="//table" -->
        </td>
    </xsl:template>
    
    <xsl:template match="listBibl">
        
        <ul>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    
    <xsl:template match="listBibl/bibl">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
</xsl:stylesheet>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:variable name="docID" select="//TEI/@xml:id/data(.)"/>
    <xsl:template match="p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="lb">
        <br/>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="div/head">
        <b class="heading">
            <xsl:apply-templates/>
        </b>
    </xsl:template>
    <xsl:template match="hi[@rend = 'bold']">
        <b>
            <xsl:apply-templates/>
        </b>
    </xsl:template>
    <xsl:template match="hi[@rend = 'italic']">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    <xsl:template match="hi[@rend = 'underline']">
        <span style="text-decoration: underline;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend = 'strike']">
        <span class="text-decoration: line-through;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend = 'overline']">
        <span class="text-decoration: overline;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend = 'underover']">
        <span class="text-decoration: underline overline;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="hi[@rend = 'left']">
        <p class="text-left">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="hi[@rend = 'center']">
        <p class="text-center">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="hi[@rend = 'right']">
        <p class="text-right">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="hi[@rend = 'code']">
        <span class="font-family: monospace, monospace; padding: 1rem; word-wrap: normal;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="note[@type = 'editor']">
        [<i><xsl:apply-templates/></i>]
    </xsl:template>
    
    <xsl:template match="ref">
        <a href="{./@target}" target="_blank"><xsl:apply-templates/></a>
    </xsl:template>
    <xsl:template match="code">
        <pre><xsl:apply-templates/></pre>
    </xsl:template>

    <xsl:template match="figure">
        <xsl:variable name="picture" select="@facs"/>
        <p class="text-center">
            <img src="{$picture}" width="250"/>
        </p>
    </xsl:template>
    
    <xsl:template match="//choice">
        <xsl:for-each select=".">
            <xsl:variable name="expan" select="expan"/>
            <span class="abk" data-toggle="tooltip" data-placement="top" title="{$expan}">
                <xsl:value-of select="abbr"/>
            </span>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:variable name="briefID" select="//TEI/@xml:id/string(.)"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="hi[@rend = 'underline']">
        <span style="text-decoration: underline;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="hi[@rend = 'italic']">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    
    <xsl:template match="lb">
        <br/>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="hi[@rend = 'right']">
        <p class="text-right">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="hi[@rend = 'center']">
        <p class="text-center">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="hi[@rend = 'left']">
        <p class="text-left">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="persName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('../../../../contents/baudi/persons/', ./@key, '.xml'))">
                <a href="{concat($registerRootPerson,./@key)}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="orgName">
        <xsl:choose>
            <xsl:when test="doc-available(concat('../../../../contents/baudi/institutions/', ./@key, '.xml'))">
                <a href="{concat($registerRootInstitution, ./@key)}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="settlement">
        <xsl:choose>
            <xsl:when test="doc-available(concat('../../../../contents/texts/loci/', ./@key, '.xml'))">
                <a href="{concat($registerRootOrt,./@key)}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="note[@type = 'editor']">
        <i>[<xsl:apply-templates/>]</i>
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
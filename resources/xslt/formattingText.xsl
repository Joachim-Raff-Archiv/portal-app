<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:pod="https://portal.raff-archiv.ch/ns/raffPodcasts" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:variable name="docID" select="//TEI/@xml:id/data(.)"/>
    
    <!--front
    pb n="6" rend="roman"
    pb n="1" rend="none"-->
    
    <xsl:template match="front">
        <div style="padding: 25px; border: 1px solid gray; text-align: center; min-height: 450px" id="fulltextTitel">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="back">
        <div style="padding: 50px; border: 1px solid gray; text-align: center;">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    
    <xsl:template match="front/p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="p[not(parent::front)]">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="mei:p | pod:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="lb">
        <br/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="mei:lb">
        <br/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="pb">
        <xsl:variable name="pageID" select="string-join(('page', @n, @rend), '-')"/>
        <div style="border-style: solid none solid none; border-width: 1px;
                    margin-top: 1em; margin-bottom: 1em; text-align: center;"
             id="{$pageID}">
        <xsl:choose>
                <xsl:when test="@n and @rend = 'roman'">
                    Seite <xsl:choose>
                        <xsl:when test="@n = '1'">I</xsl:when>
                        <xsl:when test="@n = '2'">II</xsl:when>
                        <xsl:when test="@n = '3'">III</xsl:when>
                        <xsl:when test="@n = '4'">IV</xsl:when>
                        <xsl:when test="@n = '5'">V</xsl:when>
                        <xsl:when test="@n = '6'">VI</xsl:when>
                        <xsl:when test="@n = '7'">VII</xsl:when>
                        <xsl:when test="@n = '8'">VIII</xsl:when>
                        <xsl:when test="@n = '9'">IX</xsl:when>
                        <xsl:when test="@n = '10'">X</xsl:when>
                    </xsl:choose>
                </xsl:when>
            <xsl:when test="@n and not(@rend = 'roman') and not(@rend = 'none')">
                Seite <xsl:value-of select="@n"/>
            </xsl:when>
            <xsl:when test="@n and @rend = 'none'">
                Seite [<xsl:value-of select="@n"/>]
            </xsl:when>
            <xsl:when test="not(@n)">
                <span style="color:gray;">– Seitenumbruch – </span>
            </xsl:when>
            </xsl:choose>
        </div>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="div/head">
        <b class="heading" style="padding-top: 1.5em;">
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
    <xsl:template match="hi[@rend = 'spaced']">
        <span style="letter-spacing: 3px;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend = 'latin']">
        <i>
            <xsl:apply-templates/>
        </i>
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
    
    <xsl:template match="note[not(@type='regeste')]">
        <xsl:variable name="noteContent" select="./text()"/>
        <xsl:variable name="noteCounter">
            <xsl:if test="@n = '1'">*)</xsl:if>
            <xsl:if test="@n = '2'">**)</xsl:if>
        </xsl:variable>
        <span data-container="body" data-toggle="popover" title="Fußnote {$noteCounter}" data-placement="top" data-content="{$noteContent}" style="color: #641a85;">
            <xsl:value-of select="$noteCounter"/>
        </span>
    </xsl:template>
    
    <xsl:template match="note[@type='regeste']">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="q">
        «<xsl:apply-templates/>»
    </xsl:template>
</xsl:stylesheet>
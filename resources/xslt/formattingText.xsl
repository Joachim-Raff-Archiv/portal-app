<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:pod="https://portal.raff-archiv.ch/ns/raffPodcasts" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:variable name="docID" select="//TEI/@xml:id/data(.)"/>
    
    <!-- Root template -->
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!--front
    pb n="6" rend="roman"
    pb n="1" rend="none"-->
    
    <xsl:template match="front">
        <div style="background: white; 
                    padding: 3em 2em; 
                    text-align: center; 
                    min-height: 450px;
                    margin-bottom: 2em;
                    box-shadow: 0 1px 4px rgba(0,0,0,0.1);" 
             id="fulltextTitel">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="back">
        <div style="background: white; 
                    padding: 3em 2em; 
                    text-align: center;
                    margin-top: 2em;
                    box-shadow: 0 1px 4px rgba(0,0,0,0.1);">
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
        <!-- Seitenumbruch-Trennlinie mit Seitennummer -->
        <div class="page-break" style="border-top: 1px solid #ddd;
                    margin: 3em 0 2em 0; 
                    padding-top: 1em;
                    text-align: center; 
                    color: #666; 
                    font-size: 0.9em;"
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
                        <xsl:when test="@n = '11'">XI</xsl:when>
                        <xsl:when test="@n = '12'">XII</xsl:when>
                        <xsl:otherwise><xsl:value-of select="@n"/></xsl:otherwise>
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
        <h3 class="heading" style="padding-top: 1em; margin-bottom: 1em; color: #641a85;">
            <xsl:apply-templates/>
        </h3>
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
    
    <xsl:template match="choice[abbr]">
        <xsl:variable name="expan" select="expan"/>
        <span class="abk" data-toggle="tooltip" data-placement="top" title="{$expan}">
            <xsl:value-of select="abbr"/>
        </span>
    </xsl:template>
    
    <xsl:template match="choice[sic and corr]">
        <xsl:variable name="original" select="sic"/>
        <span class="corr" data-toggle="tooltip" data-placement="top" title="Original: {$original}" style="border-bottom: 1px dotted #999;">
            <xsl:value-of select="corr"/>
        </span>
    </xsl:template>
    
    <xsl:template match="note[not(@type='regeste') and not(@type='commentary')]">
        <xsl:variable name="noteCounter">
            <xsl:if test="@n = '1'">*)</xsl:if>
            <xsl:if test="@n = '2'">**)</xsl:if>
        </xsl:variable>
        <xsl:variable name="noteID" select="concat('note-', $docID, '-', generate-id())"/>
        <span data-toggle="modal" data-target="#{$noteID}" style="color: #641a85; cursor: pointer;">
            <xsl:value-of select="$noteCounter"/>
        </span>
        <div class="modal fade" id="{$noteID}" tabindex="-1" role="dialog">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Fußnote <xsl:value-of select="$noteCounter"/></h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">×</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <xsl:apply-templates/>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="note[@type='regeste']">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="note[@type='commentary']">
        <xsl:variable name="commentaryResp" select="./@resp"/>
        <xsl:variable name="commentaryID" select="concat('commentary-', $docID, '-', generate-id())"/>
        <button type="button" class="btn btn-jra btn-jra-annot" data-toggle="modal" data-target="#{$commentaryID}">i</button>
        <div class="modal fade" id="{$commentaryID}" tabindex="-1" role="dialog">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Kritischer Kommentar</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">×</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <xsl:apply-templates/>
                        <xsl:if test="$commentaryResp">
                            <p class="text-muted" style="margin-top: 1em;">(<xsl:value-of select="$commentaryResp"/>)</p>
                        </xsl:if>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="q">
        «<xsl:apply-templates/>»
    </xsl:template>
    
    <!-- Additional templates for elements within notes -->
    <xsl:template match="quote">
        <span style="font-style: italic;">"<xsl:apply-templates/>"</span>
    </xsl:template>
    
    <xsl:template match="foreign">
        <i><xsl:apply-templates/></i>
    </xsl:template>
    
    <xsl:template match="title[not(@key)]">
        <i><xsl:apply-templates/></i>
    </xsl:template>
    
    <xsl:template match="date">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="rs[@type='postal']">
        <xsl:choose>
            <xsl:when test="@key">
                <a href="/html/letter/{@key}"><xsl:apply-templates/></a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="rs[@type='person']">
        <xsl:choose>
            <xsl:when test="@key">
                <a href="/html/person/{@key}"><xsl:apply-templates/></a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="rs[@type='work']">
        <xsl:choose>
            <xsl:when test="@key">
                <a href="/html/work/{@key}"><xsl:apply-templates/></a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="unclear">
        <span style="color: #666; font-style: italic;" title="Unklare Lesart">[<xsl:apply-templates/>?]</span>
    </xsl:template>
    
    <xsl:template match="gap">
        <span style="color: #999;" title="Lücke im Text">[...]</span>
    </xsl:template>
    
    <!-- Templates for div elements -->
    <xsl:template match="div[@type='Kapitel']">
        <div class="chapter" id="{@xml:id}" style="border-left: 4px solid #641a85; 
                                                       padding-left: 1.5em; 
                                                       margin: 2em 0 3em 0;">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="div[not(@type)]">
        <div>
            <xsl:if test="@xml:id">
                <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="body">
        <div class="writing-body" style="background: white; 
                                         padding: 2em 3em; 
                                         box-shadow: 0 1px 4px rgba(0,0,0,0.1);">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Templates for lists -->
    <xsl:template match="list[@type='toc']">
        <ul class="toc-list" style="list-style: none; padding-left: 0;">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    
    <xsl:template match="list[not(@type) or @type!='toc']">
        <ul style="margin: 1em 0; padding-left: 2em;">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    
    <xsl:template match="list[@type='toc']/item">
        <li style="margin: 0.5em 0;">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    
    <xsl:template match="item">
        <li style="margin: 0.3em 0;">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    
    <!-- Template for abstract -->
    <xsl:template match="abstract">
        <div class="abstract" style="background: #f9f9f9; 
                                     padding: 1.5em; 
                                     margin: 2em 0;
                                     border-left: 3px solid #641a85;">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="g">
        <xsl:variable name="alt" select="concat('SMUFL ',doc(@ref)//desc/text())"/>
        <xsl:variable name="url" select="doc(@ref)//graphic/@url/data()"/>
        <img src="{$url}" alt="{$alt}" class="smufl-glyph"/>
    </xsl:template>


    
</xsl:stylesheet>
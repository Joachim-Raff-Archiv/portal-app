<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="https://portal.raff-archive.ch/ns/local" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:include href="formattingDate.xsl"/>

    <xsl:variable name="sourceDesc" select="//sourceDesc"/>
<!--    <xsl:variable name="graphic" select="./ancestor::TEI/facsimile/graphic[1]"/>-->

    <xsl:template match="/">
                <xsl:call-template name="writingMetadataView"/>
    </xsl:template>

    <xsl:template name="writingMetadataView">
        <table class="letterView">
            <tr>
                <td valign="top">Titel:</td>
                <td><xsl:value-of select="$sourceDesc//title[1]"/></td>
            </tr>
            <tr>
                <td valign="top">Autor:</td>
                <td><xsl:value-of select="$sourceDesc//author[1]"/></td>
            </tr>
            <xsl:if test="$sourceDesc//biblStruct/@type">
                <tr>
                    <td valign="top">Ausgabe:</td>
                    <td><xsl:value-of select="$sourceDesc//biblStruct/@type"/></td>
                </tr>
            </xsl:if>
            <tr>
                <td valign="top">Verlag:</td>
                <td><xsl:value-of select="$sourceDesc//imprint/publisher[1]"/></td>
            </tr>
            <tr>
                <td valign="top">Ort:</td>
                <td><xsl:value-of select="$sourceDesc//imprint/pubPlace[1]"/></td>
            </tr>
            <tr>
                <td valign="top">Jahr:</td>
                <td><xsl:value-of select="$sourceDesc//imprint/date[1]"/></td>
            </tr>
        </table>
        
        <!-- Inhaltsverzeichnis aus abstract anzeigen -->
        <xsl:if test="//profileDesc/abstract">
            <div class="writing-toc">
                <h4>Inhalt</h4>
                <xsl:apply-templates select="//profileDesc/abstract" mode="toc"/>
            </div>
        </xsl:if>
        
    </xsl:template>
    
    <!-- Template für abstract im TOC-Modus -->
    <xsl:template match="abstract" mode="toc">
        <xsl:apply-templates mode="toc"/>
    </xsl:template>
    
    <xsl:template match="abstract/p" mode="toc">
        <p><xsl:apply-templates mode="toc"/></p>
    </xsl:template>
    
    <xsl:template match="abstract//list[@type='toc']" mode="toc">
        <ul class="toc-list">
            <xsl:apply-templates mode="toc"/>
        </ul>
    </xsl:template>
    
    <xsl:template match="abstract//list[not(@type='toc')]" mode="toc">
        <ul class="toc-sublist">
            <xsl:apply-templates mode="toc"/>
        </ul>
    </xsl:template>
    
    <xsl:template match="abstract//list/head" mode="toc">
        <li class="toc-head">
            <xsl:apply-templates mode="toc"/>
        </li>
    </xsl:template>
    
    <xsl:template match="abstract//list[@type='toc']/item" mode="toc">
        <li>
            <xsl:apply-templates mode="toc"/>
        </li>
    </xsl:template>
    
    <xsl:template match="abstract//list[not(@type='toc')]/item" mode="toc">
        <li>
            <xsl:apply-templates mode="toc"/>
        </li>
    </xsl:template>
    
    <xsl:template match="abstract//ref" mode="toc">
        <a href="#{@target}">
            <xsl:apply-templates mode="toc"/>
        </a>
    </xsl:template>
    
    <xsl:template match="abstract//hi[@rend='italic']" mode="toc">
        <i><xsl:apply-templates mode="toc"/></i>
    </xsl:template>
    
    <xsl:template match="abstract//hi[@rend='bold']" mode="toc">
        <b><xsl:apply-templates mode="toc"/></b>
    </xsl:template>

</xsl:stylesheet>
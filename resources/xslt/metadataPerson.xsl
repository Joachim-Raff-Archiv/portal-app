<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:http="http://expath.org/ns/http-client" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:include href="formattingText.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="person" select="//listPerson/person"/>
    <xsl:variable name="graphic" select="$person/ancestor::TEI/facsimile/graphic[1]"/>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$person/ancestor::TEI/facsimile/graphic[1]/@url">
                <div class="row">
                    <div class="col-sm-6 col-md-4 col-lm-3">
                    <img src="{$graphic/@url}" class="img-thumbnail" width="200px"/>
                    <br/>
                    <br/>
                    <xsl:if test="$graphic/desc">
                        <xsl:value-of select="$graphic/desc"/>
                        <br/>
                    </xsl:if>
                    Quelle: <a href="{$graphic/@source}" target="_blank"> <xsl:value-of select="$graphic/@resp"/> </a>
                </div>
                <div class="col">
                    <xsl:call-template name="personMetadataView"/>
                </div>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="personMetadataView"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="personMetadataView">
        <table class="personView">
            <xsl:if test="$person/persName/surname/node()">
            <tr>
                <td valign="top" width="250px">Name:</td>
                <td>
                    <xsl:if test="$person/persName/surname[@type = 'used']">
                        <xsl:value-of select="$person/persName/surname[@type = 'used']"/>
                    </xsl:if>
                    <xsl:if test="exists($person/persName/genName)">
                        (<xsl:value-of select="$person/persName/genName"/>)
                    </xsl:if>
                    <xsl:if test="$person/persName/surname[@type = 'altWriting']"> [Auch:
                            <xsl:value-of select="$person/persName/surname[@type = 'altWriting']"/>] </xsl:if>
                    <xsl:if test="$person/persName/surname[@type = 'birth']"> (geb. <xsl:value-of select="$person/persName/surname[@type = 'birth']"/>) </xsl:if>
                    <!--<xsl:if test="$person/persName/surname[@type = 'married']">
                            [Heiratsname: <xsl:value-of select="$person/persName/surname[@type = 'married']"/>]
                        </xsl:if>-->

                </td>
            </tr>
            </xsl:if>
            <xsl:if test="$person/persName/forename/node()">
            <tr>
                <td>
                    <xsl:choose>
                        <xsl:when test="not($person/persName/surname/node())">Name:</xsl:when>
                        <xsl:when test="count($person/persName/forename/node()) = 1">Vorname:</xsl:when>
                        <xsl:otherwise>Vornamen:</xsl:otherwise>
                    </xsl:choose>
                </td>
                <td>
                    <xsl:if test="$person/persName/forename[@type = 'used']">
                        <xsl:value-of select="$person/persName/forename[@type = 'used']"/>
                    </xsl:if>
                    <xsl:if test="$person/persName/forename[@type = 'altWriting']"> [Auch: <xsl:value-of select="$person/persName/forename[@type = 'altWriting']"/>] </xsl:if>
                    <xsl:if test="exists($person/persName/nameLink)">
                        <xsl:if test="$person/persName/genName[@type = 'used'] or exists($person/persName/genName)"> </xsl:if>
                        <xsl:value-of select="concat(' ', $person/persName/nameLink)"/>
                    </xsl:if>
                    <!--</xsl:for-each>-->
                </td>
            </tr>
            </xsl:if>
            <xsl:if test="exists($person/persName/addName[@type = 'epithet'])">
                <tr>
                    <td>Beiname:</td>
                    <td>
                        <xsl:if test="exists($person/persName/addName[@type = 'epithet'])">
                            <xsl:value-of select="$person/persName/addName[@type = 'epithet']"/>
                        </xsl:if>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists($person/persName//addName[@type = 'title'])">
                <tr>
                    <td>Titel:</td>
                    <td>
                        <xsl:value-of select="$person/persName//addName[@type = 'title']"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists($person/persName//addName[@type = 'noble'])">
                <tr>
                    <td>Adelsgeschlecht:</td>
                    <td>
                        <xsl:value-of select="$person/persName//addName[@type = 'noble']"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists($person/persName/forename[@type = 'pseudonym']) or exists($person/persName/surname[@type = 'pseudonym'])">
                <tr>
                    <td>Pseudonym:</td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="exists($person/persName/forename[@type = 'pseudonym']) and not(exists($person/persName/surname[@type = 'pseudonym']))">
                                <xsl:value-of select="$person/persName/forename[@type = 'pseudonym']"/>
                            </xsl:when>
                            <xsl:when test="exists($person/persName/surname[@type = 'pseudonym']) and not(exists($person/persName/forename[@type = 'pseudonym']))">
                                <xsl:value-of select="$person/persName/surname[@type = 'pseudonym']"/>
                            </xsl:when>
                            <xsl:when test="exists($person/persName/forename[@type = 'pseudonym']) and exists($person/persName/surname[@type = 'pseudonym'])">
                                <xsl:value-of select="$person/persName/forename[@type = 'pseudonym']"/> <xsl:value-of select="$person/persName/surname[@type = 'pseudonym']"/>
                            </xsl:when>
                        </xsl:choose>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists($person/persName/addName[@type = 'nick'])">
                <tr>
                    <td>Spitzname:</td>
                    <td>
                        <xsl:value-of select="$person/persName/addName[@type = 'nick']"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists($person/persName/name[@type = 'unspecified'])">
                <tr>
                    <td>Namensbezeichnung:</td>
                    <td>
                        <xsl:value-of select="$person/persName/name[@type = 'unspecified']"/>
                    </td>
                </tr>
            </xsl:if>
        </table>
        <table class="personView">
            <xsl:if test="exists($person/persName/roleName)">
                <tr>
                    <td>Funktion:</td>
                    <td>
                        <xsl:value-of select="$person/persName/roleName"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists($person/occupation[.!=''])">
                <tr>
                    <td>Beruf:</td>
                    <td>
                        <xsl:value-of select="$person/occupation"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists($person/affiliation/text())">
                <tr>
                    <td>Affiliation:</td>
                    <td>
                        <xsl:value-of select="$person/affiliation"/>
                    </td>
                </tr>
            </xsl:if>
        </table>
        <table class="personView">
            <xsl:if test="exists($person/birth/node()) or exists($person/birth/@when-iso) or exists($person/death/node()) or exists($person/death/@when-iso)">
                <tr>
                    <td valign="top">Lebensdaten:</td>
                    <td>
                        <xsl:if test="$person/birth"> *
                            <xsl:choose>
                                <xsl:when test="$person/birth[not(date)]/node()"><xsl:value-of select="$person/birth"/></xsl:when>
                                <xsl:otherwise><xsl:value-of select="$person/birth/@when-iso"/></xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="$person/birth[placeName]"> (<xsl:value-of select="$person/birth/placeName"/>)</xsl:if>
                        </xsl:if>
                        
                        <xsl:if test="exists($person/death/node()) and exists($person/birth/node())">
                            <br/>
                        </xsl:if>
                    
                        <xsl:if test="$person/death"> †
                            <xsl:choose>
                                <xsl:when test="$person/death[not(date)]/node()"><xsl:value-of select="$person/death"/></xsl:when>
                                <xsl:otherwise><xsl:value-of select="$person/death/@when-iso"/></xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="$person/death[placeName]"> (<xsl:value-of select="$person/death/placeName"/>)</xsl:if>
                        </xsl:if>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists($person/listEvent)">
                <xsl:for-each select="$person/listEvent/event">
                    <tr>
                        <td>Besonderes Ereignis:</td>
                        <td>
                            <xsl:apply-templates/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="exists($person/residence/placeName/text())">
                <td>Wirkungsorte:</td>
                <td>
                    <xsl:for-each select="$person/residence/placeName">
                        <xsl:value-of select="."/>
                        <br/>
                    </xsl:for-each>
                </td>
            </xsl:if>
        </table>
        <table class="personView">
            <xsl:if test="exists($person/idno[@type = 'GND'])">
                <tr>
                    <td>Normdaten:</td>
                    <td><a href="{concat('http://d-nb.info/gnd/',$person/idno[@type='GND']/normalize-space(text()))}" target="_blank"><xsl:value-of select="$person/idno[@type = 'GND']/normalize-space(text())"/></a> (GND)</td>
                </tr>
            </xsl:if>
            <xsl:if test="exists($person/idno[@type = 'VIAF'])">
                <tr>
                    <td><xsl:choose>
                            <xsl:when test="exists($person/idno[@type = 'GND'])"/>
                        <xsl:otherwise>Normdaten:</xsl:otherwise>
                    </xsl:choose></td>
                    <td><a href="{concat('https://viaf.org/viaf/',$person/idno[@type='VIAF']/normalize-space(text()))}" target="_blank"><xsl:value-of select="$person/idno[@type = 'VIAF']/normalize-space(text())"/></a>
                        (VIAF)</td>
                </tr>
            </xsl:if>
        </table>
        <xsl:if test="//bibl[@type = 'links']/ref[@target]">
        <table class="personView">
            
            <xsl:choose>
            <xsl:when test="//bibl[@type = 'links'][1]/ref[@type='wikipedia']">
                <tr>
                    <td>Links:</td>
                <td>Wikipedia <a href="{//bibl[@type = 'links']/ref/@target}" target="_blank"><img src="https://digilib.baumann-digital.de/JRA/img/wikipedia-icon-5.jpg?dh=1000&amp;dw=1000" height="20" width="20"/></a></td>
                </tr>
            </xsl:when>
                <xsl:when test="//bibl[@type = 'links'][1]">
                    <tr>
                        <td>Links:</td>
                        <td><a href="{//bibl[@type = 'links']/ref/@target}" target="_blank"><xsl:value-of select="if(//bibl[@type = 'links'][1]/ref/text() = '')then('Externer Link')else(//bibl[@type = 'links'][1]/ref/text())"/></a></td>
                    </tr>
            </xsl:when>
            </xsl:choose>
                <xsl:for-each select="//bibl[@type = 'links'][position() > 1]">
                <tr>
                    <td/>
                    <td>
                        <a href="{./ref/@target}" target="_blank">
                        <xsl:choose>
                            <xsl:when test="not(./ref/text())">Externer Link</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="./ref/text()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        </a>
                    </td>
                </tr>
                </xsl:for-each>
        </table>
        </xsl:if>
        <table class="personView">
            <xsl:if test="//relation[@name = 'reference']//item[. != '']">
                <tr>
                    <td>Referenzen:</td>
                    <td>
                        <xsl:for-each select="//relation[@name = 'reference']//item[. != '']">
                            <li><xsl:value-of select="./text()"/></li>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>
        </table>
    </xsl:template>
</xsl:stylesheet>
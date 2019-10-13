<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="person" select="//listPerson/person"/>
    <xsl:variable name="graphic" select="$person/ancestor::TEI/facsimile/graphic[1]"/>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$person/ancestor::TEI/facsimile/graphic">
                <div class="col-3"><img src="{$graphic/@url}" class="img-thumbnail" width="200px"/><br/><br/>
                    <xsl:if test="$graphic/desc"><xsl:value-of select="$graphic/desc"/><br/></xsl:if>Quelle: 
                    <a href="{$graphic/@source}" target="_blank"><xsl:value-of select="$graphic/@resp"/></a></div>
                <div class="col">
                    <xsl:call-template name="personMetadataView"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="personMetadataView"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="personMetadataView">
        <table class="personView">
            <tr>
                <td valign="top" width="250px">Name:</td>
                <td>
                    <xsl:if test="$person/persName/surname[@type = 'used']">
                        <xsl:value-of select="$person/persName/surname[@type = 'used']"/>
                    </xsl:if>
                    <xsl:if test="$person/persName/surname[@type = 'altWriting']"> [Auch:
                            <xsl:value-of select="$person/persName/surname[@type = 'altWriting']"/>] </xsl:if>
                    <xsl:if test="$person/persName/surname[@type = 'birth']"> (geb. <xsl:value-of select="$person/persName/surname[@type = 'birth']"/>) </xsl:if>
                    <!--<xsl:if test="$person/persName/surname[@type = 'married']">
                            [Heiratsname: <xsl:value-of select="$person/persName/surname[@type = 'married']"/>]
                        </xsl:if>-->

                </td>
            </tr>
            <tr>
                <td>
                    <xsl:choose>
                        <xsl:when test="count($person/persName/forename/node()) = 1">Vorname:</xsl:when>
                        <xsl:otherwise>Vornamen:</xsl:otherwise>
                    </xsl:choose>
                </td>
                <td>
                    <xsl:if test="$person/persName/forename[@type = 'used']">
                        <xsl:value-of select="$person/persName/forename[@type = 'used']"/>
                    </xsl:if>
                    <xsl:if test="$person/persName/forename[@type = 'altWriting']"> [<xsl:value-of select="$person/persName/forename[@type = 'altWriting']"/>] </xsl:if>
                    <xsl:if test="exists($person/persName/genName)">
                        <xsl:if test="$person/persName/genName[@type = 'used']"> </xsl:if>
                        <xsl:value-of select="$person/persName/genName"/>
                    </xsl:if>
                    <xsl:if test="exists($person/persName/nameLink)">
                        <xsl:if test="$person/persName/genName[@type = 'used'] or exists($person/persName/genName)"> </xsl:if>
                        <xsl:value-of select="$person/persName/nameLink"/>
                    </xsl:if>
                    <!--</xsl:for-each>-->
                </td>
            </tr>
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
            <xsl:if test="exists($person/birth) or exists($person/death)">
                <tr>
                    <td valign="top">Lebensdaten:</td>
                    <td>
                        <xsl:if test="$person/birth"> * <xsl:if test="$person/birth[not(date)]"><xsl:value-of select="$person/birth/@when-iso"/> </xsl:if><xsl:value-of select="$person/birth"/><xsl:if test="$person/birth[not(name[@type = 'place'])]"> (<xsl:value-of select="$person/birth/name[@type = 'place']"/>)</xsl:if></xsl:if>
                        <xsl:if test="exists($person/death/node()) and exists($person/birth/node())">
                            <br/>
                        </xsl:if>
                        <xsl:if test="$person/death">† <xsl:if test="$person/death[not(date)]"><xsl:value-of select="$person/death/@when-iso"/> </xsl:if><xsl:value-of select="$person/death"/><xsl:if test="$person/death[not(name[@type = 'place'])]"> (<xsl:value-of select="$person/death/name[@type = 'place']"/>)</xsl:if></xsl:if>
                        <xsl:if test="exists($person/death/node()) and exists($person/death/node())">
                            <br/>
                        </xsl:if>
                    </td>
                </tr>
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
                    <td><a href="{concat('http://d-nb.info/gnd/',$person/idno[@type='GND'])}"><xsl:value-of select="$person/idno[@type = 'GND']"/></a> (GND)</td>
                </tr>
            </xsl:if>

        </table>
    </xsl:template>
</xsl:stylesheet>
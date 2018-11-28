<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="person" select="//listPerson/person"/>
    <xsl:template match="/">
        <table>
            <tr>
                <td width="200px">Name:</td>
                <td>
                    <xsl:for-each select="$person/persName/surname">
                        <xsl:if test="./@type = 'used'">
                            <xsl:value-of select="."/>
                        </xsl:if>
                        <xsl:if test="exists($person/persName/addName[@type = 'epithet'])">
                            <xsl:value-of select="$person/persName/addName[@type = 'epithet']"/>
                        </xsl:if>
                        <xsl:if test="./@type = 'altWriting'">
                            [Auch: <xsl:value-of select="."/>]
                        </xsl:if>
                        <xsl:if test="./@type = 'birth'">
                            [Geburtsname: <xsl:value-of select="."/>]
                        </xsl:if>
                        <xsl:if test="./@type = 'married'">
                            [Heiratsname: <xsl:value-of select="."/>]
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="exists($person/persName/nameLink)">
                        <xsl:value-of select="$person/persName/nameLink"/>
                    </xsl:if>
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
                    <xsl:for-each select="$person/persName/forename">
                        <xsl:sort select="." data-type="text" order="ascending"/>
                        <xsl:if test="./@type = 'used'">
                            <xsl:value-of select="."/>
                        </xsl:if>
                        <xsl:if test="exists($person/persName/genName)">
                            <xsl:value-of select="$person/persName/genName"/>
                        </xsl:if>
                        <xsl:if test="./@type = 'altWriting'">
                            [<xsl:value-of select="."/>]
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
            <xsl:if test="exists($person/persName/forename[@type = 'pseudonym']) or exists($person/persName/surname[@type = 'pseudonym'])">
                <tr>
                    <td>Pseudonym:</td>
                    <td>
                        <xsl:if test="exists($person/persName/forename[@type = 'pseudonym'])">
                            <xsl:value-of select="$person/persName/forename[@type = 'pseudonym']"/>
                        </xsl:if>

                        <xsl:if test="exists($person/persName/surname[@type = 'pseudonym'])">
                            <xsl:value-of select="$person/persName/surname[@type = 'pseudonym']"/>
                        </xsl:if>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists($person/persName/roleName)">
                <tr>
                    <td>Funktion:</td>
                    <td>
                        <xsl:value-of select="$person/persName/roleName"/>
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
            <tr>
                <td>Normdaten:</td>
                <td><a href="{concat('http://d-nb.info/gnd/',$person/idno[@type='GND'])}"><xsl:value-of select="$person/idno[@type = 'GND']"/></a> (GND)</td>
            </tr>
            <xsl:if test="exists($person/birth) or exists($person/death)">
                <tr>
                    <td valign="top">Lebensdaten:</td>
                    <td>
                        <xsl:if test="$person/birth/node()">
                        * <xsl:value-of select="$person/birth"/> (Geburtsort)</xsl:if>
                        <xsl:if test="exists($person/death/node()) and exists($person/birth/node())">
                            <br/>
                        </xsl:if>
                        <xsl:if test="$person/death/node()">† <xsl:value-of select="$person/death"/> (Sterbeort)</xsl:if>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="exists($person/affiliation)">
                <tr>
                    <td>Affiliation:</td>
                    <td>
                        <xsl:value-of select="$person/affiliation"/>
                    </td>
                </tr>
            </xsl:if>
        </table>
        <br/>
        <xsl:if test="exists($person/residence/placeName)">
            <h5>Wirkungsorte:</h5>
            <ul>
                <xsl:for-each select="$person/residence/placeName">
                    <li>
                        <xsl:value-of select="."/>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
        <xsl:if test="exists($person/bibl//relation[@name = 'letters']/desc/list/item/text())">
            <h5>Zugehörige Briefe:</h5>
            <ul>
                <xsl:for-each select="$person/bibl//relation[@name = 'letters']/desc/list/item">
                    <li>
                        <xsl:value-of select="."/>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
        <xsl:if test="exists($person/bibl//relation[@name = 'reference']/desc/list/item/text())">
            <h5>Referenzen:</h5>
            <ul>
                <xsl:for-each select="$person/bibl//relation[@name = 'reference']/desc/list/item">
                    <li>
                        <xsl:value-of select="."/>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
        <xsl:if test="exists($person/bibl[@type = 'links'])">
            <h5>Literaturlinks:</h5>
            <ul>
                <xsl:for-each select="$person/bibl[@type = 'links']">
                    <li>
                        <xsl:value-of select="."/>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
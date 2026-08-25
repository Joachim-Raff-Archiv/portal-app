<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="https://portal.raff-archive.ch/ns/local" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:include href="formattingDate.xsl"/>

    <xsl:variable name="sourceDesc" select="//sourceDesc"/>
    <xsl:variable name="fileDesc" select="//teiHeader/fileDesc"/>
    <xsl:variable name="profileDesc" select="//teiHeader/profileDesc"/>
    <xsl:variable name="encodingDesc" select="//teiHeader/encodingDesc"/>

    <xsl:template match="/">
                <xsl:call-template name="writingMetadataView"/>
    </xsl:template>

    <xsl:template name="writingMetadataView">
        <table class="letterView">
            <tr>
                <td valign="top">Werktitel:</td>
                <td><xsl:value-of select="$fileDesc/titleStmt/title[2]"/></td>
            </tr>
            <tr>
                <td valign="top">Untertitel, Bandtitel:</td>
                <td><xsl:value-of select="$fileDesc/titleStmt/title[3]"/></td>
            </tr>
            <tr>
                <td valign="top">Kurztitel:</td>
                <td><xsl:value-of select="$fileDesc/titleStmt/title[4]"/></td>
            </tr>
            <tr>
                <td valign="top">Autor:</td>
                <td><xsl:value-of select="$fileDesc/titleStmt/author"/></td>
            </tr>
            <tr>
                <td valign="top">Textkategorie:</td>
                <td><xsl:value-of select="$profileDesc/textClass/keywords/term"/></td>
            </tr>
            <tr>
                <td valign="top">Entstehungszeit:</td>
                <td><xsl:value-of select="$profileDesc/creation/origDate"/></td>
            </tr>
            <tr>
                <td valign="top">Entstehungsort:</td>
                <td><xsl:value-of select="$profileDesc/creation/origPlace"/></td>
            </tr>
            <xsl:if test="$profileDesc/notesStmt/note[@type='history']">
                <tr>
                <td valign="top">Entstehungsgeschichte:</td>
                <td><xsl:value-of select="$profileDesc/notesStmt/note[@type='history']"/></td>
            </tr>
            </xsl:if>
            <table class="letterView">
                <tr>
                    <td valign="top"><h5 style="padding-top: 1rem;">Quellen</h5></td>
                    <td></td>
                </tr>
                <tr>
                    <td valign="top">Typ:</td>
                    <td><xsl:value-of select="$sourceDesc/biblStruct/@type"/></td>
                </tr>
                <tr>
                    <td valign="top">Autor:</td>
                    <td><xsl:value-of select="$sourceDesc/biblStruct/analytic/author"/></td>
                </tr>
                <tr>
                    <td valign="top">Titel:</td>
                    <td><xsl:value-of select="$sourceDesc/biblStruct/monogr/title"/></td>
                </tr>
                <tr>
                    <td valign="top">Verlag:</td>
                    <td><xsl:value-of select="$sourceDesc/biblStruct/monogr/imprint/publisher"/></td>
                </tr>
                <tr>
                    <td valign="top">Erscheinungsort:</td>
                    <td><xsl:value-of select="$sourceDesc/biblStruct/monogr/imprint/pubPlace"/></td>
                </tr>
                <tr>
                    <td valign="top">Erscheinungsjahr:</td>
                    <td><xsl:value-of select="$sourceDesc/biblStruct/monogr/imprint/date"/></td>
                </tr>
                <tr>
                    <td valign="top">benutztes Exemplar:</td>
                    <td><xsl:apply-templates select="$sourceDesc/biblStruct/monogr/imprint/biblScope[2]"/></td>
                </tr>
                <!--<tr>
                    <td valign="top">Digitalisat:</td>
                    <td><xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$sourceDesc/biblStruct/monogr/imprint/biblScope[2]/ref[1]/@target"/>
                        </xsl:attribute>
                        <xsl:value-of select="$sourceDesc/biblStruct/monogr/imprint/biblScope[2]/ref[1]/@target"/>
                    </xsl:element></td>
                </tr>-->
                <!--<tr>
                    <td valign="top">IIIF-Manifest:</td>
                    <td><xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$sourceDesc/biblStruct/monogr/imprint/biblScope[2]/ref[2]/@target"/>
                        </xsl:attribute>
                        <xsl:value-of select="$sourceDesc/biblStruct/monogr/imprint/biblScope[2]/ref[2]/@target"/>
                    </xsl:element></td>
                </tr>-->
                
            </table>
            <table class="letterView">
                <tr>
                    <td valign="top"><h5 style="padding-top: 1rem;">Edition</h5></td>
                    <td></td>
                </tr>
                <tr>
                    <td valign="top">Herausgeber der Edition:</td>
                    <td><xsl:value-of select="$fileDesc/titleStmt/editor"/></td>
                </tr>
            <tr>
                <td valign="top">Lizenz:</td>
                <td><xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$fileDesc/publicationStmt/availability/licence/@target"/>
                    </xsl:attribute>
                    <xsl:value-of select="$fileDesc/publicationStmt/availability/licence"/>
                </xsl:element></td>
            </tr>
            <tr>
                <td valign="top">Projektzusammenhang:</td>
                <td><xsl:value-of select="$encodingDesc/projectDesc/p"/></td>
            </tr>
            <tr>
                <td valign="top">Editorische Grundsätze:</td>
                <td><xsl:apply-templates select="$encodingDesc/editorialDecl/p"/></td>
            </tr>
        </table>
        </table>
        
    </xsl:template>

    <xsl:template match="hi[@rend = 'italic']">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    
</xsl:stylesheet>
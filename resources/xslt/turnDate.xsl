<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math" version="3.0">

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="date">
        <xsl:variable name="yearSelect" select="substring(., 1, 4)"/>
        <xsl:variable name="monthSelect" select="substring(., 6, 2)"/>
        <xsl:variable name="daySelect" select="substring(., 9, 2)"/>
        <xsl:variable name="MonthAsText" select="                 if ($monthSelect = '01') then                     ('Jan.')                 else                     if ($monthSelect = '02') then                         ('Feb.')                     else                         if ($monthSelect = '03') then                             ('Mrz.')                         else                             if ($monthSelect = '04') then                                 ('Apr.')                             else                                 if ($monthSelect = '05') then                                     ('Mai')                                 else                                     if ($monthSelect = '06') then                                         ('Jun.')                                     else                                         if ($monthSelect = '07') then                                             ('Jul.')                                         else                                             if ($monthSelect = '08') then                                                 ('Aug.')                                             else                                                 if ($monthSelect = '09') then                                                     ('Sep.')                                                 else                                                     if ($monthSelect = '10') then                                                         ('Okt.')                                                     else                                                         if ($monthSelect = '11') then                                                             ('Nov.')                                                         else                                                             if ($monthSelect = '12') then                                                                 ('Dez.')                                                             else                                                                 ('[o.M.]')"/>
        <xsl:variable name="turnedDate" select="concat($daySelect, '. ', $MonthAsText, ' ', $yearSelect)"/>
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="/">
        <br/>
        <div class="container">
            <ul class="nav nav-pills" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" data-toggle="tab" href="#musSource">Mus.-Quellen</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-toggle="tab" href="#docSource">Dokumente</a>
                </li>
            </ul>
            <br/>
            <!-- Tab panels -->
            <div class="tab-content">
                <div class="tab-pane fade show active" id="musSource">
                    <p>
                        <b>Musikalsiche Quelle (Einzeln)</b>
                    </p>
                    <p>Beispieldatei:<br/>
                        <xmp>
                            <xsl:copy-of select="//music/nonCollections/structure/mei"/>
                        </xmp>
                    </p>
                </div>
                <div class="tab-pane fade" id="docSource">
                    <p>
                        <b>Briefe</b>
                    </p>
                    <p>Beispieldatei:<br/>
                        <xmp>
                            <xsl:copy-of select="//documents/letters/structure/TEI"/>
                        </xmp>
                    </p>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
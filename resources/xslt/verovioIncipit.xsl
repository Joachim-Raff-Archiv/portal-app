<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        <div id="output"/>
        <script type="text/javascript">
                var vrvToolkit = new verovio.toolkit();
                /* Load the file using HTTP GET */
                $.get( "*", function( data ) {
                var svg = vrvToolkit.renderData(data, {});
                $("#output").html(svg);
                }, 'xml');
            </script>
    </xsl:template>
</xsl:stylesheet>

var vrvToolkit = new verovio.toolkit();

var voice = 1;

function set_options() {
    pageHeight = 100;
    pageWidth = 100;
    border = 50;
    options = JSON.stringify({
        inputFormat: 'mei',
        pageHeight: pageHeight,
        pageWidth: pageWidth,
        border: border,
        scale: zoom,
        adjustPageHeight: 1,
        ignoreLayout: 1
    });
    vrvToolkit.setOptions(options);
}

function load_data(data) {
    set_options();
    vrvToolkit.loadData(data);
    
    page = 1;
    load_page();
}

function load_page() {
    svg = vrvToolkit.renderPage(page, "");
    $("#svg_output").html(svg);
};

////////////////////////////////////////////////////////
/* A function that applies the XSLT and load the data */
////////////////////////////////////////////////////////
function load_file() {
    var file = "{$incipit}";
    var xsl = Saxon.requestXML("xslt/stripStaff.xsl");
    var xml = Saxon.requestXML(file);
    var proc = Saxon.newXSLT20Processor(xsl);
    proc.setParameter(null, "voice", voice);
    load_data(Saxon.serializeXML(proc.transformToDocument(xml)));
}

var onSaxonLoad = function () {
    load_file();
};
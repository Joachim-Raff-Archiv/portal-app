function next_page() {
	if (page >= vrvToolkit.getPageCount()) {
		return;
	}

	page = page + 1;
	load_page();
};

function prev_page() {
	if (page <= 1) {
		return;
	}

	page = page - 1;
	load_page();
};

function first_page() {
	page = 1;
	load_page();
};

function last_page() {
	page = vrvToolkit.getPageCount();
	load_page();
};

function apply_zoom() {
	set_options();
	vrvToolkit.redoLayout();

	page = 1;
	load_page();
}

function zoom_out() {
	if (zoom < 20) {
		return;
	}

	zoom = zoom / 2;
	apply_zoom();
}

function zoom_in() {
	if (zoom > 80) {
		return;
	}

	zoom = zoom * 2;
	apply_zoom();
}
window.addEventListener("hashchange", function () {
    console.log("hashchange");
    // Calculate navbar height dynamically
    var mainNavbar = document.querySelector('.navbar.fixed-top');
    var navbarHeight = mainNavbar ? mainNavbar.offsetHeight : 60;
    var offset = navbarHeight + 20;
    scrollBy(0, -offset);
});

var msg = {
    "action": "push", "id": self.frameElement.id, "url": self.frameElement.contentWindow.location.href
};
parent.postMessage(msg, "*");

function triggerBack() {
    parent.postMessage({
        "action": "back", "id": self.frameElement.id
    },
    "*");
}
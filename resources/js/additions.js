window.addEventListener("hashchange", function () {
    console.log("haschange");
    scrollBy(0, -60)
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
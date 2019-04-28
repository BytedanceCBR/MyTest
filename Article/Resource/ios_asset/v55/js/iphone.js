function processArticle() {
_processArticle(), setTimeout(function() {
document.body.classList.remove("opacity");
}, 0);
}

APP_VERSION = "v55", CLIENT_VERSION = "ios", document.addEventListener("DOMContentLoaded", function() {
document.body.getAttribute("inited") || (document.body.setAttribute("inited", !0), 
loadscript("lib.js", function() {
loadscript("ios-common.js", function() {
setExtra();
});
}));
}, !1);
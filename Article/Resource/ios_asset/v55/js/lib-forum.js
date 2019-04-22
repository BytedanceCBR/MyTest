var MONITOR_SERVICE = "fe_article_detail_error", loadscript = function() {
for (var r = document.querySelectorAll("script"), e = "", s = 0, i = r.length; i > s; s++) {
var t = r[s].src, l = t.indexOf(t.indexOf("/v55/js/lib.js") > -1 ? "/v55/js/lib.js" : "/v55/js/lib-forum.js");
if (l > -1) {
e = t.substr(0, l);
break;
}
if (l = t.indexOf("/v60/js/lib.js"), l > -1) {
e = t.substr(0, l);
break;
}
}
return e && (e += "/shared/js/"), function(r, s) {
if (e) {
var i = document.createElement("script");
i.src = e + r, i.onload = s, document.body.appendChild(i), i = null;
}
};
}();
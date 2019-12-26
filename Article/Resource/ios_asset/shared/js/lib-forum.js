function SelfEvent(t) {
this.channelId = t, this.eventMap = {};
}

function _flushErrors(t) {
globalErrors.forEach(function(e) {
e.gid || (e.gid = t, window.ToutiaoJSBridge && ToutiaoJSBridge.call("monitor", {
service: MONITOR_SERVICE,
status: 1,
extra: e
}));
});
}

function flushErrors(t) {
clearTimeout(flushErrorsTimer);
var e = window.Page && Page.statistics ? Page.statistics.group_id : "";
t && !e && (e = "gid_still_n/a"), e ? _flushErrors(e) : flushErrorsTimer = setTimeout(flushErrors, 3e3);
}

!function(t, e) {
"function" == typeof define && define.amd ? define(function() {
return e(t);
}) : e(t);
}(this, function(t) {
var e = function() {
function e(t) {
return null == t ? String(t) : Z[K.call(t)] || "object";
}
function n(t) {
return "function" == e(t);
}
function r(t) {
return null != t && t == t.window;
}
function i(t) {
return null != t && t.nodeType == t.DOCUMENT_NODE;
}
function o(t) {
return "object" == e(t);
}
function a(t) {
return o(t) && !r(t) && Object.getPrototypeOf(t) == Object.prototype;
}
function s(t) {
var e = !!t && "length" in t && t.length, n = _.type(t);
return "function" != n && !r(t) && ("array" == n || 0 === e || "number" == typeof e && e > 0 && e - 1 in t);
}
function u(t) {
return N.call(t, function(t) {
return null != t;
});
}
function c(t) {
return t.length > 0 ? _.fn.concat.apply([], t) : t;
}
function l(t) {
return t.replace(/::/g, "/").replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2").replace(/([a-z\d])([A-Z])/g, "$1_$2").replace(/_/g, "-").toLowerCase();
}
function f(t) {
return t in M ? M[t] : M[t] = new RegExp("(^|\\s)" + t + "(\\s|$)");
}
function h(t, e) {
return "number" != typeof e || F[l(t)] ? e : e + "px";
}
function p(t) {
var e, n;
return L[t] || (e = P.createElement(t), P.body.appendChild(e), n = getComputedStyle(e, "").getPropertyValue("display"), 
e.parentNode.removeChild(e), "none" == n && (n = "block"), L[t] = n), L[t];
}
function d(t) {
return "children" in t ? A.call(t.children) : _.map(t.childNodes, function(t) {
return 1 == t.nodeType ? t : void 0;
});
}
function m(t, e) {
var n, r = t ? t.length : 0;
for (n = 0; r > n; n++) this[n] = t[n];
this.length = r, this.selector = e || "";
}
function v(t, e, n) {
for (k in e) n && (a(e[k]) || te(e[k])) ? (a(e[k]) && !a(t[k]) && (t[k] = {}), te(e[k]) && !te(t[k]) && (t[k] = []), 
v(t[k], e[k], n)) : e[k] !== S && (t[k] = e[k]);
}
function g(t, e) {
return null == e ? _(t) : _(t).filter(e);
}
function y(t, e, r, i) {
return n(e) ? e.call(t, r, i) : e;
}
function b(t, e, n) {
null == n ? t.removeAttribute(e) : t.setAttribute(e, n);
}
function x(t, e) {
var n = t.className || "", r = n && n.baseVal !== S;
return e === S ? r ? n.baseVal : n : void (r ? n.baseVal = e : t.className = e);
}
function w(t) {
try {
return t ? "true" == t || ("false" == t ? !1 : "null" == t ? null : +t + "" == t ? +t : /^[\[\{]/.test(t) ? _.parseJSON(t) : t) : t;
} catch (e) {
return t;
}
}
function E(t, e) {
e(t);
for (var n = 0, r = t.childNodes.length; r > n; n++) E(t.childNodes[n], e);
}
var S, k, _, j, T, C, O = [], R = O.concat, N = O.filter, A = O.slice, P = t.document, L = {}, M = {}, F = {
"column-count": 1,
columns: 1,
"font-weight": 1,
"line-height": 1,
opacity: 1,
"z-index": 1,
zoom: 1
}, D = /^\s*<(\w+|!)[^>]*>/, q = /^<(\w+)\s*\/?>(?:<\/\1>|)$/, I = /<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/gi, U = /^(?:body|html)$/i, B = /([A-Z])/g, $ = [ "val", "css", "html", "text", "data", "width", "height", "offset" ], H = [ "after", "prepend", "before", "append" ], z = P.createElement("table"), J = P.createElement("tr"), V = {
tr: P.createElement("tbody"),
tbody: z,
thead: z,
tfoot: z,
td: J,
th: J,
"*": P.createElement("div")
}, W = /complete|loaded|interactive/, X = /^[\w-]*$/, Z = {}, K = Z.toString, G = {}, Y = P.createElement("div"), Q = {
tabindex: "tabIndex",
readonly: "readOnly",
"for": "htmlFor",
"class": "className",
maxlength: "maxLength",
cellspacing: "cellSpacing",
cellpadding: "cellPadding",
rowspan: "rowSpan",
colspan: "colSpan",
usemap: "useMap",
frameborder: "frameBorder",
contenteditable: "contentEditable"
}, te = Array.isArray || function(t) {
return t instanceof Array;
};
return G.matches = function(t, e) {
if (!e || !t || 1 !== t.nodeType) return !1;
var n = t.matches || t.webkitMatchesSelector || t.mozMatchesSelector || t.oMatchesSelector || t.matchesSelector;
if (n) return n.call(t, e);
var r, i = t.parentNode, o = !i;
return o && (i = Y).appendChild(t), r = ~G.qsa(i, e).indexOf(t), o && Y.removeChild(t), 
r;
}, T = function(t) {
return t.replace(/-+(.)?/g, function(t, e) {
return e ? e.toUpperCase() : "";
});
}, C = function(t) {
return N.call(t, function(e, n) {
return t.indexOf(e) == n;
});
}, G.fragment = function(t, e, n) {
var r, i, o;
return q.test(t) && (r = _(P.createElement(RegExp.$1))), r || (t.replace && (t = t.replace(I, "<$1></$2>")), 
e === S && (e = D.test(t) && RegExp.$1), e in V || (e = "*"), o = V[e], o.innerHTML = "" + t, 
r = _.each(A.call(o.childNodes), function() {
o.removeChild(this);
})), a(n) && (i = _(r), _.each(n, function(t, e) {
$.indexOf(t) > -1 ? i[t](e) : i.attr(t, e);
})), r;
}, G.Z = function(t, e) {
return new m(t, e);
}, G.isZ = function(t) {
return t instanceof G.Z;
}, G.init = function(t, e) {
var r;
if (!t) return G.Z();
if ("string" == typeof t) if (t = t.trim(), "<" == t[0] && D.test(t)) r = G.fragment(t, RegExp.$1, e), 
t = null; else {
if (e !== S) return _(e).find(t);
r = G.qsa(P, t);
} else {
if (n(t)) return _(P).ready(t);
if (G.isZ(t)) return t;
if (te(t)) r = u(t); else if (o(t)) r = [ t ], t = null; else if (D.test(t)) r = G.fragment(t.trim(), RegExp.$1, e), 
t = null; else {
if (e !== S) return _(e).find(t);
r = G.qsa(P, t);
}
}
return G.Z(r, t);
}, _ = function(t, e) {
return G.init(t, e);
}, _.extend = function(t) {
var e, n = A.call(arguments, 1);
return "boolean" == typeof t && (e = t, t = n.shift()), n.forEach(function(n) {
v(t, n, e);
}), t;
}, G.qsa = function(t, e) {
var n, r = "#" == e[0], i = !r && "." == e[0], o = r || i ? e.slice(1) : e, a = X.test(o);
return t.getElementById && a && r ? (n = t.getElementById(o)) ? [ n ] : [] : 1 !== t.nodeType && 9 !== t.nodeType && 11 !== t.nodeType ? [] : A.call(a && !r && t.getElementsByClassName ? i ? t.getElementsByClassName(o) : t.getElementsByTagName(e) : t.querySelectorAll(e));
}, _.contains = P.documentElement.contains ? function(t, e) {
return t !== e && t.contains(e);
} : function(t, e) {
for (;e && (e = e.parentNode); ) if (e === t) return !0;
return !1;
}, _.type = e, _.isFunction = n, _.isWindow = r, _.isArray = te, _.isPlainObject = a, 
_.isEmptyObject = function(t) {
var e;
for (e in t) return !1;
return !0;
}, _.isNumeric = function(t) {
var e = Number(t), n = typeof t;
return null != t && "boolean" != n && ("string" != n || t.length) && !isNaN(e) && isFinite(e) || !1;
}, _.inArray = function(t, e, n) {
return O.indexOf.call(e, t, n);
}, _.camelCase = T, _.trim = function(t) {
return null == t ? "" : String.prototype.trim.call(t);
}, _.uuid = 0, _.support = {}, _.expr = {}, _.noop = function() {}, _.map = function(t, e) {
var n, r, i, o = [];
if (s(t)) for (r = 0; r < t.length; r++) n = e(t[r], r), null != n && o.push(n); else for (i in t) n = e(t[i], i), 
null != n && o.push(n);
return c(o);
}, _.each = function(t, e) {
var n, r;
if (s(t)) {
for (n = 0; n < t.length; n++) if (e.call(t[n], n, t[n]) === !1) return t;
} else for (r in t) if (e.call(t[r], r, t[r]) === !1) return t;
return t;
}, _.grep = function(t, e) {
return N.call(t, e);
}, t.JSON && (_.parseJSON = JSON.parse), _.each("Boolean Number String Function Array Date RegExp Object Error".split(" "), function(t, e) {
Z["[object " + e + "]"] = e.toLowerCase();
}), _.fn = {
constructor: G.Z,
length: 0,
forEach: O.forEach,
reduce: O.reduce,
push: O.push,
sort: O.sort,
splice: O.splice,
indexOf: O.indexOf,
concat: function() {
var t, e, n = [];
for (t = 0; t < arguments.length; t++) e = arguments[t], n[t] = G.isZ(e) ? e.toArray() : e;
return R.apply(G.isZ(this) ? this.toArray() : this, n);
},
map: function(t) {
return _(_.map(this, function(e, n) {
return t.call(e, n, e);
}));
},
slice: function() {
return _(A.apply(this, arguments));
},
ready: function(t) {
return W.test(P.readyState) && P.body ? t(_) : P.addEventListener("DOMContentLoaded", function() {
t(_);
}, !1), this;
},
get: function(t) {
return t === S ? A.call(this) : this[t >= 0 ? t : t + this.length];
},
toArray: function() {
return this.get();
},
size: function() {
return this.length;
},
remove: function() {
return this.each(function() {
null != this.parentNode && this.parentNode.removeChild(this);
});
},
each: function(t) {
return O.every.call(this, function(e, n) {
return t.call(e, n, e) !== !1;
}), this;
},
filter: function(t) {
return n(t) ? this.not(this.not(t)) : _(N.call(this, function(e) {
return G.matches(e, t);
}));
},
add: function(t, e) {
return _(C(this.concat(_(t, e))));
},
is: function(t) {
return this.length > 0 && G.matches(this[0], t);
},
not: function(t) {
var e = [];
if (n(t) && t.call !== S) this.each(function(n) {
t.call(this, n) || e.push(this);
}); else {
var r = "string" == typeof t ? this.filter(t) : s(t) && n(t.item) ? A.call(t) : _(t);
this.forEach(function(t) {
r.indexOf(t) < 0 && e.push(t);
});
}
return _(e);
},
has: function(t) {
return this.filter(function() {
return o(t) ? _.contains(this, t) : _(this).find(t).size();
});
},
eq: function(t) {
return -1 === t ? this.slice(t) : this.slice(t, +t + 1);
},
first: function() {
var t = this[0];
return t && !o(t) ? t : _(t);
},
last: function() {
var t = this[this.length - 1];
return t && !o(t) ? t : _(t);
},
find: function(t) {
var e, n = this;
return e = t ? "object" == typeof t ? _(t).filter(function() {
var t = this;
return O.some.call(n, function(e) {
return _.contains(e, t);
});
}) : 1 == this.length ? _(G.qsa(this[0], t)) : this.map(function() {
return G.qsa(this, t);
}) : _();
},
closest: function(t, e) {
var n = [], r = "object" == typeof t && _(t);
return this.each(function(o, a) {
for (;a && !(r ? r.indexOf(a) >= 0 : G.matches(a, t)); ) a = a !== e && !i(a) && a.parentNode;
a && n.indexOf(a) < 0 && n.push(a);
}), _(n);
},
parents: function(t) {
for (var e = [], n = this; n.length > 0; ) n = _.map(n, function(t) {
return (t = t.parentNode) && !i(t) && e.indexOf(t) < 0 ? (e.push(t), t) : void 0;
});
return g(e, t);
},
parent: function(t) {
return g(C(this.pluck("parentNode")), t);
},
children: function(t) {
return g(this.map(function() {
return d(this);
}), t);
},
contents: function() {
return this.map(function() {
return this.contentDocument || A.call(this.childNodes);
});
},
siblings: function(t) {
return g(this.map(function(t, e) {
return N.call(d(e.parentNode), function(t) {
return t !== e;
});
}), t);
},
empty: function() {
return this.each(function() {
this.innerHTML = "";
});
},
pluck: function(t) {
return _.map(this, function(e) {
return e[t];
});
},
show: function() {
return this.each(function() {
"none" == this.style.display && (this.style.display = ""), "none" == getComputedStyle(this, "").getPropertyValue("display") && (this.style.display = p(this.nodeName));
});
},
replaceWith: function(t) {
return this.before(t).remove();
},
wrap: function(t) {
var e = n(t);
if (this[0] && !e) var r = _(t).get(0), i = r.parentNode || this.length > 1;
return this.each(function(n) {
_(this).wrapAll(e ? t.call(this, n) : i ? r.cloneNode(!0) : r);
});
},
wrapAll: function(t) {
if (this[0]) {
_(this[0]).before(t = _(t));
for (var e; (e = t.children()).length; ) t = e.first();
_(t).append(this);
}
return this;
},
wrapInner: function(t) {
var e = n(t);
return this.each(function(n) {
var r = _(this), i = r.contents(), o = e ? t.call(this, n) : t;
i.length ? i.wrapAll(o) : r.append(o);
});
},
unwrap: function() {
return this.parent().each(function() {
_(this).replaceWith(_(this).children());
}), this;
},
clone: function() {
return this.map(function() {
return this.cloneNode(!0);
});
},
hide: function() {
return this.css("display", "none");
},
toggle: function(t) {
return this.each(function() {
var e = _(this);
(t === S ? "none" == e.css("display") : t) ? e.show() : e.hide();
});
},
prev: function(t) {
return _(this.pluck("previousElementSibling")).filter(t || "*");
},
next: function(t) {
return _(this.pluck("nextElementSibling")).filter(t || "*");
},
html: function(t) {
return 0 in arguments ? this.each(function(e) {
var n = this.innerHTML;
_(this).empty().append(y(this, t, e, n));
}) : 0 in this ? this[0].innerHTML : null;
},
text: function(t) {
return 0 in arguments ? this.each(function(e) {
var n = y(this, t, e, this.textContent);
this.textContent = null == n ? "" : "" + n;
}) : 0 in this ? this.pluck("textContent").join("") : null;
},
attr: function(t, e) {
var n;
return "string" != typeof t || 1 in arguments ? this.each(function(n) {
if (1 === this.nodeType) if (o(t)) for (k in t) b(this, k, t[k]); else b(this, t, y(this, e, n, this.getAttribute(t)));
}) : 0 in this && 1 == this[0].nodeType && null != (n = this[0].getAttribute(t)) ? n : S;
},
removeAttr: function(t) {
return this.each(function() {
1 === this.nodeType && t.split(" ").forEach(function(t) {
b(this, t);
}, this);
});
},
prop: function(t, e) {
return t = Q[t] || t, 1 in arguments ? this.each(function(n) {
this[t] = y(this, e, n, this[t]);
}) : this[0] && this[0][t];
},
removeProp: function(t) {
return t = Q[t] || t, this.each(function() {
delete this[t];
});
},
data: function(t, e) {
var n = "data-" + t.replace(B, "-$1").toLowerCase(), r = 1 in arguments ? this.attr(n, e) : this.attr(n);
return null !== r ? w(r) : S;
},
val: function(t) {
return 0 in arguments ? (null == t && (t = ""), this.each(function(e) {
this.value = y(this, t, e, this.value);
})) : this[0] && (this[0].multiple ? _(this[0]).find("option").filter(function() {
return this.selected;
}).pluck("value") : this[0].value);
},
offset: function(e) {
if (e) return this.each(function(t) {
var n = _(this), r = y(this, e, t, n.offset()), i = n.offsetParent().offset(), o = {
top: r.top - i.top,
left: r.left - i.left
};
"static" == n.css("position") && (o.position = "relative"), n.css(o);
});
if (!this.length) return null;
if (P.documentElement !== this[0] && !_.contains(P.documentElement, this[0])) return {
top: 0,
left: 0
};
var n = this[0].getBoundingClientRect();
return {
left: n.left + t.pageXOffset,
top: n.top + t.pageYOffset,
width: Math.round(n.width),
height: Math.round(n.height)
};
},
css: function(t, n) {
if (arguments.length < 2) {
var r = this[0];
if ("string" == typeof t) {
if (!r) return;
return r.style[T(t)] || getComputedStyle(r, "").getPropertyValue(t);
}
if (te(t)) {
if (!r) return;
var i = {}, o = getComputedStyle(r, "");
return _.each(t, function(t, e) {
i[e] = r.style[T(e)] || o.getPropertyValue(e);
}), i;
}
}
var a = "";
if ("string" == e(t)) n || 0 === n ? a = l(t) + ":" + h(t, n) : this.each(function() {
this.style.removeProperty(l(t));
}); else for (k in t) t[k] || 0 === t[k] ? a += l(k) + ":" + h(k, t[k]) + ";" : this.each(function() {
this.style.removeProperty(l(k));
});
return this.each(function() {
this.style.cssText += ";" + a;
});
},
index: function(t) {
return t ? this.indexOf(_(t)[0]) : this.parent().children().indexOf(this[0]);
},
hasClass: function(t) {
return t ? O.some.call(this, function(t) {
return this.test(x(t));
}, f(t)) : !1;
},
addClass: function(t) {
return t ? this.each(function(e) {
if ("className" in this) {
j = [];
var n = x(this), r = y(this, t, e, n);
r.split(/\s+/g).forEach(function(t) {
_(this).hasClass(t) || j.push(t);
}, this), j.length && x(this, n + (n ? " " : "") + j.join(" "));
}
}) : this;
},
removeClass: function(t) {
return this.each(function(e) {
if ("className" in this) {
if (t === S) return x(this, "");
j = x(this), y(this, t, e, j).split(/\s+/g).forEach(function(t) {
j = j.replace(f(t), " ");
}), x(this, j.trim());
}
});
},
toggleClass: function(t, e) {
return t ? this.each(function(n) {
var r = _(this), i = y(this, t, n, x(this));
i.split(/\s+/g).forEach(function(t) {
(e === S ? !r.hasClass(t) : e) ? r.addClass(t) : r.removeClass(t);
});
}) : this;
},
scrollTop: function(t) {
if (this.length) {
var e = "scrollTop" in this[0];
return t === S ? e ? this[0].scrollTop : this[0].pageYOffset : this.each(e ? function() {
this.scrollTop = t;
} : function() {
this.scrollTo(this.scrollX, t);
});
}
},
scrollLeft: function(t) {
if (this.length) {
var e = "scrollLeft" in this[0];
return t === S ? e ? this[0].scrollLeft : this[0].pageXOffset : this.each(e ? function() {
this.scrollLeft = t;
} : function() {
this.scrollTo(t, this.scrollY);
});
}
},
position: function() {
if (this.length) {
var t = this[0], e = this.offsetParent(), n = this.offset(), r = U.test(e[0].nodeName) ? {
top: 0,
left: 0
} : e.offset();
return n.top -= parseFloat(_(t).css("margin-top")) || 0, n.left -= parseFloat(_(t).css("margin-left")) || 0, 
r.top += parseFloat(_(e[0]).css("border-top-width")) || 0, r.left += parseFloat(_(e[0]).css("border-left-width")) || 0, 
{
top: n.top - r.top,
left: n.left - r.left
};
}
},
offsetParent: function() {
return this.map(function() {
for (var t = this.offsetParent || P.body; t && !U.test(t.nodeName) && "static" == _(t).css("position"); ) t = t.offsetParent;
return t;
});
}
}, _.fn.detach = _.fn.remove, [ "width", "height" ].forEach(function(t) {
var e = t.replace(/./, function(t) {
return t[0].toUpperCase();
});
_.fn[t] = function(n) {
var o, a = this[0];
return n === S ? r(a) ? a["inner" + e] : i(a) ? a.documentElement["scroll" + e] : (o = this.offset()) && o[t] : this.each(function(e) {
a = _(this), a.css(t, y(this, n, e, a[t]()));
});
};
}), H.forEach(function(n, r) {
var i = r % 2;
_.fn[n] = function() {
var n, o, a = _.map(arguments, function(t) {
var r = [];
return n = e(t), "array" == n ? (t.forEach(function(t) {
return t.nodeType !== S ? r.push(t) : _.zepto.isZ(t) ? r = r.concat(t.get()) : void (r = r.concat(G.fragment(t)));
}), r) : "object" == n || null == t ? t : G.fragment(t);
}), s = this.length > 1;
return a.length < 1 ? this : this.each(function(e, n) {
o = i ? n : n.parentNode, n = 0 == r ? n.nextSibling : 1 == r ? n.firstChild : 2 == r ? n : null;
var u = _.contains(P.documentElement, o);
a.forEach(function(e) {
if (s) e = e.cloneNode(!0); else if (!o) return _(e).remove();
o.insertBefore(e, n), u && E(e, function(e) {
if (!(null == e.nodeName || "SCRIPT" !== e.nodeName.toUpperCase() || e.type && "text/javascript" !== e.type || e.src)) {
var n = e.ownerDocument ? e.ownerDocument.defaultView : t;
n.eval.call(n, e.innerHTML);
}
});
});
});
}, _.fn[i ? n + "To" : "insert" + (r ? "Before" : "After")] = function(t) {
return _(t)[n](this), this;
};
}), G.Z.prototype = m.prototype = _.fn, G.uniq = C, G.deserializeValue = w, _.zepto = G, 
_;
}();
return t.Zepto = e, void 0 === t.$ && (t.$ = e), function(e) {
function n(t) {
return t._zid || (t._zid = p++);
}
function r(t, e, r, a) {
if (e = i(e), e.ns) var s = o(e.ns);
return (g[n(t)] || []).filter(function(t) {
return !(!t || e.e && t.e != e.e || e.ns && !s.test(t.ns) || r && n(t.fn) !== n(r) || a && t.sel != a);
});
}
function i(t) {
var e = ("" + t).split(".");
return {
e: e[0],
ns: e.slice(1).sort().join(" ")
};
}
function o(t) {
return new RegExp("(?:^| )" + t.replace(" ", " .* ?") + "(?: |$)");
}
function a(t, e) {
return t.del && !b && t.e in x || !!e;
}
function s(t) {
return w[t] || b && x[t] || t;
}
function u(t, r, o, u, c, f, p) {
var d = n(t), m = g[d] || (g[d] = []);
r.split(/\s/).forEach(function(n) {
if ("ready" == n) return e(document).ready(o);
var r = i(n);
r.fn = o, r.sel = c, r.e in w && (o = function(t) {
var n = t.relatedTarget;
return !n || n !== this && !e.contains(this, n) ? r.fn.apply(this, arguments) : void 0;
}), r.del = f;
var d = f || o;
r.proxy = function(e) {
if (e = l(e), !e.isImmediatePropagationStopped()) {
e.data = u;
var n = d.apply(t, e._args == h ? [ e ] : [ e ].concat(e._args));
return n === !1 && (e.preventDefault(), e.stopPropagation()), n;
}
}, r.i = m.length, m.push(r), "addEventListener" in t && t.addEventListener(s(r.e), r.proxy, a(r, p));
});
}
function c(t, e, i, o, u) {
var c = n(t);
(e || "").split(/\s/).forEach(function(e) {
r(t, e, i, o).forEach(function(e) {
delete g[c][e.i], "removeEventListener" in t && t.removeEventListener(s(e.e), e.proxy, a(e, u));
});
});
}
function l(t, n) {
return (n || !t.isDefaultPrevented) && (n || (n = t), e.each(_, function(e, r) {
var i = n[e];
t[e] = function() {
return this[r] = E, i && i.apply(n, arguments);
}, t[r] = S;
}), t.timeStamp || (t.timeStamp = Date.now()), (n.defaultPrevented !== h ? n.defaultPrevented : "returnValue" in n ? n.returnValue === !1 : n.getPreventDefault && n.getPreventDefault()) && (t.isDefaultPrevented = E)), 
t;
}
function f(t) {
var e, n = {
originalEvent: t
};
for (e in t) k.test(e) || t[e] === h || (n[e] = t[e]);
return l(n, t);
}
var h, p = 1, d = Array.prototype.slice, m = e.isFunction, v = function(t) {
return "string" == typeof t;
}, g = {}, y = {}, b = "onfocusin" in t, x = {
focus: "focusin",
blur: "focusout"
}, w = {
mouseenter: "mouseover",
mouseleave: "mouseout"
};
y.click = y.mousedown = y.mouseup = y.mousemove = "MouseEvents", e.event = {
add: u,
remove: c
}, e.proxy = function(t, r) {
var i = 2 in arguments && d.call(arguments, 2);
if (m(t)) {
var o = function() {
return t.apply(r, i ? i.concat(d.call(arguments)) : arguments);
};
return o._zid = n(t), o;
}
if (v(r)) return i ? (i.unshift(t[r], t), e.proxy.apply(null, i)) : e.proxy(t[r], t);
throw new TypeError("expected function");
}, e.fn.bind = function(t, e, n) {
return this.on(t, e, n);
}, e.fn.unbind = function(t, e) {
return this.off(t, e);
}, e.fn.one = function(t, e, n, r) {
return this.on(t, e, n, r, 1);
};
var E = function() {
return !0;
}, S = function() {
return !1;
}, k = /^([A-Z]|returnValue$|layer[XY]$|webkitMovement[XY]$)/, _ = {
preventDefault: "isDefaultPrevented",
stopImmediatePropagation: "isImmediatePropagationStopped",
stopPropagation: "isPropagationStopped"
};
e.fn.delegate = function(t, e, n) {
return this.on(e, t, n);
}, e.fn.undelegate = function(t, e, n) {
return this.off(e, t, n);
}, e.fn.live = function(t, n) {
return e(document.body).delegate(this.selector, t, n), this;
}, e.fn.die = function(t, n) {
return e(document.body).undelegate(this.selector, t, n), this;
}, e.fn.on = function(t, n, r, i, o) {
var a, s, l = this;
return t && !v(t) ? (e.each(t, function(t, e) {
l.on(t, n, r, e, o);
}), l) : (v(n) || m(i) || i === !1 || (i = r, r = n, n = h), (i === h || r === !1) && (i = r, 
r = h), i === !1 && (i = S), l.each(function(l, h) {
o && (a = function(t) {
return c(h, t.type, i), i.apply(this, arguments);
}), n && (s = function(t) {
var r, o = e(t.target).closest(n, h).get(0);
return o && o !== h ? (r = e.extend(f(t), {
currentTarget: o,
liveFired: h
}), (a || i).apply(o, [ r ].concat(d.call(arguments, 1)))) : void 0;
}), u(h, t, i, r, n, s || a);
}));
}, e.fn.off = function(t, n, r) {
var i = this;
return t && !v(t) ? (e.each(t, function(t, e) {
i.off(t, n, e);
}), i) : (v(n) || m(r) || r === !1 || (r = n, n = h), r === !1 && (r = S), i.each(function() {
c(this, t, r, n);
}));
}, e.fn.trigger = function(t, n) {
return t = v(t) || e.isPlainObject(t) ? e.Event(t) : l(t), t._args = n, this.each(function() {
t.type in x && "function" == typeof this[t.type] ? this[t.type]() : "dispatchEvent" in this ? this.dispatchEvent(t) : e(this).triggerHandler(t, n);
});
}, e.fn.triggerHandler = function(t, n) {
var i, o;
return this.each(function(a, s) {
i = f(v(t) ? e.Event(t) : t), i._args = n, i.target = s, e.each(r(s, t.type || t), function(t, e) {
return o = e.proxy(i), i.isImmediatePropagationStopped() ? !1 : void 0;
});
}), o;
}, "focusin focusout focus blur load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select keydown keypress keyup error".split(" ").forEach(function(t) {
e.fn[t] = function(e) {
return 0 in arguments ? this.bind(t, e) : this.trigger(t);
};
}), e.Event = function(t, e) {
v(t) || (e = t, t = e.type);
var n = document.createEvent(y[t] || "Events"), r = !0;
if (e) for (var i in e) "bubbles" == i ? r = !!e[i] : n[i] = e[i];
return n.initEvent(t, r, !0), l(n);
};
}(e), function(e) {
function n(t, n, r) {
var i = e.Event(n);
return e(t).trigger(i, r), !i.isDefaultPrevented();
}
function r(t, e, r, i) {
return t.global ? n(e || x, r, i) : void 0;
}
function i(t) {
t.global && 0 === e.active++ && r(t, null, "ajaxStart");
}
function o(t) {
t.global && !--e.active && r(t, null, "ajaxStop");
}
function a(t, e) {
var n = e.context;
return e.beforeSend.call(n, t, e) === !1 || r(e, n, "ajaxBeforeSend", [ t, e ]) === !1 ? !1 : void r(e, n, "ajaxSend", [ t, e ]);
}
function s(t, e, n, i) {
var o = n.context, a = "success";
n.success.call(o, t, a, e), i && i.resolveWith(o, [ t, a, e ]), r(n, o, "ajaxSuccess", [ e, n, t ]), 
c(a, e, n);
}
function u(t, e, n, i, o) {
var a = i.context;
i.error.call(a, n, e, t), o && o.rejectWith(a, [ n, e, t ]), r(i, a, "ajaxError", [ n, i, t || e ]), 
c(e, n, i);
}
function c(t, e, n) {
var i = n.context;
n.complete.call(i, e, t), r(n, i, "ajaxComplete", [ e, n ]), o(n);
}
function l(t, e, n) {
if (n.dataFilter == f) return t;
var r = n.context;
return n.dataFilter.call(r, t, e);
}
function f() {}
function h(t) {
return t && (t = t.split(";", 2)[0]), t && (t == _ ? "html" : t == k ? "json" : E.test(t) ? "script" : S.test(t) && "xml") || "text";
}
function p(t, e) {
return "" == e ? t : (t + "&" + e).replace(/[&?]{1,2}/, "?");
}
function d(t) {
t.processData && t.data && "string" != e.type(t.data) && (t.data = e.param(t.data, t.traditional)), 
!t.data || t.type && "GET" != t.type.toUpperCase() && "jsonp" != t.dataType || (t.url = p(t.url, t.data), 
t.data = void 0);
}
function m(t, n, r, i) {
return e.isFunction(n) && (i = r, r = n, n = void 0), e.isFunction(r) || (i = r, 
r = void 0), {
url: t,
data: n,
success: r,
dataType: i
};
}
function v(t, n, r, i) {
var o, a = e.isArray(n), s = e.isPlainObject(n);
e.each(n, function(n, u) {
o = e.type(u), i && (n = r ? i : i + "[" + (s || "object" == o || "array" == o ? n : "") + "]"), 
!i && a ? t.add(u.name, u.value) : "array" == o || !r && "object" == o ? v(t, u, r, n) : t.add(n, u);
});
}
var g, y, b = +new Date(), x = t.document, w = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, E = /^(?:text|application)\/javascript/i, S = /^(?:text|application)\/xml/i, k = "application/json", _ = "text/html", j = /^\s*$/, T = x.createElement("a");
T.href = t.location.href, e.active = 0, e.ajaxJSONP = function(n, r) {
if (!("type" in n)) return e.ajax(n);
var i, o, c = n.jsonpCallback, l = (e.isFunction(c) ? c() : c) || "Zepto" + b++, f = x.createElement("script"), h = t[l], p = function(t) {
e(f).triggerHandler("error", t || "abort");
}, d = {
abort: p
};
return r && r.promise(d), e(f).on("load error", function(a, c) {
clearTimeout(o), e(f).off().remove(), "error" != a.type && i ? s(i[0], d, n, r) : u(null, c || "error", d, n, r), 
t[l] = h, i && e.isFunction(h) && h(i[0]), h = i = void 0;
}), a(d, n) === !1 ? (p("abort"), d) : (t[l] = function() {
i = arguments;
}, f.src = n.url.replace(/\?(.+)=\?/, "?$1=" + l), x.head.appendChild(f), n.timeout > 0 && (o = setTimeout(function() {
p("timeout");
}, n.timeout)), d);
}, e.ajaxSettings = {
type: "GET",
beforeSend: f,
success: f,
error: f,
complete: f,
context: null,
global: !0,
xhr: function() {
return new t.XMLHttpRequest();
},
accepts: {
script: "text/javascript, application/javascript, application/x-javascript",
json: k,
xml: "application/xml, text/xml",
html: _,
text: "text/plain"
},
crossDomain: !1,
timeout: 0,
processData: !0,
cache: !0,
dataFilter: f
}, e.ajax = function(n) {
var r, o, c = e.extend({}, n || {}), m = e.Deferred && e.Deferred();
for (g in e.ajaxSettings) void 0 === c[g] && (c[g] = e.ajaxSettings[g]);
i(c), c.crossDomain || (r = x.createElement("a"), r.href = c.url, r.href = r.href, 
c.crossDomain = T.protocol + "//" + T.host != r.protocol + "//" + r.host), c.url || (c.url = t.location.toString()), 
(o = c.url.indexOf("#")) > -1 && (c.url = c.url.slice(0, o)), d(c);
var v = c.dataType, b = /\?.+=\?/.test(c.url);
if (b && (v = "jsonp"), c.cache !== !1 && (n && n.cache === !0 || "script" != v && "jsonp" != v) || (c.url = p(c.url, "_=" + Date.now())), 
"jsonp" == v) return b || (c.url = p(c.url, c.jsonp ? c.jsonp + "=?" : c.jsonp === !1 ? "" : "callback=?")), 
e.ajaxJSONP(c, m);
var w, E = c.accepts[v], S = {}, k = function(t, e) {
S[t.toLowerCase()] = [ t, e ];
}, _ = /^([\w-]+:)\/\//.test(c.url) ? RegExp.$1 : t.location.protocol, C = c.xhr(), O = C.setRequestHeader;
if (m && m.promise(C), c.crossDomain || k("X-Requested-With", "XMLHttpRequest"), 
k("Accept", E || "*/*"), (E = c.mimeType || E) && (E.indexOf(",") > -1 && (E = E.split(",", 2)[0]), 
C.overrideMimeType && C.overrideMimeType(E)), (c.contentType || c.contentType !== !1 && c.data && "GET" != c.type.toUpperCase()) && k("Content-Type", c.contentType || "application/x-www-form-urlencoded"), 
c.headers) for (y in c.headers) k(y, c.headers[y]);
if (C.setRequestHeader = k, C.onreadystatechange = function() {
if (4 == C.readyState) {
C.onreadystatechange = f, clearTimeout(w);
var t, n = !1;
if (C.status >= 200 && C.status < 300 || 304 == C.status || 0 == C.status && "file:" == _) {
if (v = v || h(c.mimeType || C.getResponseHeader("content-type")), "arraybuffer" == C.responseType || "blob" == C.responseType) t = C.response; else {
t = C.responseText;
try {
t = l(t, v, c), "script" == v ? (1, eval)(t) : "xml" == v ? t = C.responseXML : "json" == v && (t = j.test(t) ? null : e.parseJSON(t));
} catch (r) {
n = r;
}
if (n) return u(n, "parsererror", C, c, m);
}
s(t, C, c, m);
} else u(C.statusText || null, C.status ? "error" : "abort", C, c, m);
}
}, a(C, c) === !1) return C.abort(), u(null, "abort", C, c, m), C;
var R = "async" in c ? c.async : !0;
if (C.open(c.type, c.url, R, c.username, c.password), c.xhrFields) for (y in c.xhrFields) C[y] = c.xhrFields[y];
for (y in S) O.apply(C, S[y]);
return c.timeout > 0 && (w = setTimeout(function() {
C.onreadystatechange = f, C.abort(), u(null, "timeout", C, c, m);
}, c.timeout)), C.send(c.data ? c.data : null), C;
}, e.get = function() {
return e.ajax(m.apply(null, arguments));
}, e.post = function() {
var t = m.apply(null, arguments);
return t.type = "POST", e.ajax(t);
}, e.getJSON = function() {
var t = m.apply(null, arguments);
return t.dataType = "json", e.ajax(t);
}, e.fn.load = function(t, n, r) {
if (!this.length) return this;
var i, o = this, a = t.split(/\s/), s = m(t, n, r), u = s.success;
return a.length > 1 && (s.url = a[0], i = a[1]), s.success = function(t) {
o.html(i ? e("<div>").html(t.replace(w, "")).find(i) : t), u && u.apply(o, arguments);
}, e.ajax(s), this;
};
var C = encodeURIComponent;
e.param = function(t, n) {
var r = [];
return r.add = function(t, n) {
e.isFunction(n) && (n = n()), null == n && (n = ""), this.push(C(t) + "=" + C(n));
}, v(r, t, n), r.join("&").replace(/%20/g, "+");
};
}(e), function(t) {
t.fn.serializeArray = function() {
var e, n, r = [], i = function(t) {
return t.forEach ? t.forEach(i) : void r.push({
name: e,
value: t
});
};
return this[0] && t.each(this[0].elements, function(r, o) {
n = o.type, e = o.name, e && "fieldset" != o.nodeName.toLowerCase() && !o.disabled && "submit" != n && "reset" != n && "button" != n && "file" != n && ("radio" != n && "checkbox" != n || o.checked) && i(t(o).val());
}), r;
}, t.fn.serialize = function() {
var t = [];
return this.serializeArray().forEach(function(e) {
t.push(encodeURIComponent(e.name) + "=" + encodeURIComponent(e.value));
}), t.join("&");
}, t.fn.submit = function(e) {
if (0 in arguments) this.bind("submit", e); else if (this.length) {
var n = t.Event("submit");
this.eq(0).trigger(n), n.isDefaultPrevented() || this.get(0).submit();
}
return this;
};
}(e), function() {
try {
getComputedStyle(void 0);
} catch (e) {
var n = getComputedStyle;
t.getComputedStyle = function(t, e) {
try {
return n(t, e);
} catch (r) {
return null;
}
};
}
}(), e;
}), _ = {}, _.escape = function() {
var t = {
"&": "&amp;",
"<": "&lt;",
">": "&gt;",
'"': "&quot;",
"'": "&#x27;",
"`": "&#x60;"
}, e = function(e) {
return t[e];
}, n = "(?:" + Object.keys(t).join("|") + ")", r = RegExp(n), i = RegExp(n, "g");
return function(t) {
return t = null == t ? "" : "" + t, r.test(t) ? t.replace(i, e) : t;
};
}(), _.isFunction = function(t) {
return "[object Function]" === Object.prototype.toString.call(t);
}, "function" != typeof /./ && "object" != typeof Int8Array && (_.isFunction = function(t) {
return "function" == typeof t || !1;
}), _.has = function(t, e) {
return null != t && Object.prototype.hasOwnProperty.call(t, e);
};

var eq = function(t, e, n, r) {
if (t === e) return 0 !== t || 1 / t === 1 / e;
if (null == t || null == e) return t === e;
var i = toString.call(t);
if (i !== toString.call(e)) return !1;
switch (i) {
case "[object RegExp]":
case "[object String]":
return "" + t == "" + e;

case "[object Number]":
return +t !== +t ? +e !== +e : 0 === +t ? 1 / +t === 1 / e : +t === +e;

case "[object Date]":
case "[object Boolean]":
return +t === +e;
}
var o = "[object Array]" === i;
if (!o) {
if ("object" != typeof t || "object" != typeof e) return !1;
var a = t.constructor, s = e.constructor;
if (a !== s && !(_.isFunction(a) && a instanceof a && _.isFunction(s) && s instanceof s) && "constructor" in t && "constructor" in e) return !1;
}
n = n || [], r = r || [];
for (var u = n.length; u--; ) if (n[u] === t) return r[u] === e;
if (n.push(t), r.push(e), o) {
if (u = t.length, u !== e.length) return !1;
for (;u--; ) if (!eq(t[u], e[u], n, r)) return !1;
} else {
var c, l = Object.keys(t);
if (u = l.length, Object.keys(e).length !== u) return !1;
for (;u--; ) if (c = l[u], !_.has(e, c) || !eq(t[c], e[c], n, r)) return !1;
}
return n.pop(), r.pop(), !0;
};

_.isEqual = function(t, e) {
return eq(t, e);
}, _.now = Date.now || function() {
return new Date().getTime();
}, _.throttle = function(t, e, n) {
var r, i, o, a = null, s = 0;
n || (n = {});
var u = function() {
s = n.leading === !1 ? 0 : _.now(), a = null, o = t.apply(r, i), a || (r = i = null);
};
return function() {
var c = _.now();
s || n.leading !== !1 || (s = c);
var l = e - (c - s);
return r = this, i = arguments, 0 >= l || l > e ? (a && (clearTimeout(a), a = null), 
s = c, o = t.apply(r, i), a || (r = i = null)) : a || n.trailing === !1 || (a = setTimeout(u, l)), 
o;
};
}, !function() {
function t() {
var t = JSON.stringify(c);
return c = [], r("SCENE_FETCHQUEUE", t), t;
}
function e(t) {
var e, n = t.__msg_type, i = t.__params, o = t.__event_id, a = t.__callback_id;
return "callback" == n ? (e = {
__err_code: "cb404"
}, "string" == typeof a && "function" == typeof f[a] && (e = f[a](i), delete f[a])) : "event" == n && (e = {
__err_code: "ev404"
}, "string" == typeof o && "function" == typeof h[o] && (e = h[o](i))), r("SCENE_HANDLEMSGFROMTT", JSON.stringify(e)), 
JSON.stringify(e);
}
function n(t) {
return btoa(encodeURIComponent(t).replace(/%(..)/gi, function(t, e) {
return String.fromCharCode(parseInt(e, 16));
}));
}
function r(t, e) {
u.src = p + "private/setresult/" + t + "&" + n(e);
}
function i(t, e, n, r) {
if (r = r || 1, t && "string" == typeof t) {
"object" != typeof e && (e = {});
var i = (l++).toString();
"function" == typeof n && (f[i] = n);
var o = {
JSSDK: r,
func: t,
params: e,
__msg_type: "call",
__callback_id: i
};
c.push(o), s.src = p + "dispatch_message/";
}
}
function o(t, e) {
t && "string" == typeof t && "function" == typeof e && (h[t] = e, i("addEventListener", {
name: t
}, null));
}
function a(t, e) {
"function" != typeof h[t] && h[t](e);
}
var s, u, c = [], l = 1e3, f = {}, h = {}, p = "bytedance://";
window.ToutiaoJSBridge = {
call: i,
on: o,
_fetchQueue: t,
_handleMessageFromToutiao: e
}, window.toutiao = {
on: o,
trigger: a
}, u = document.createElement("iframe"), u.id = "__ToutiaoJSBridgeIframe_SetResult", 
u.style.display = "none", document.documentElement.appendChild(u), s = document.createElement("iframe"), 
s.id = "__ToutiaoJSBridgeIframe", s.style.display = "none", document.documentElement.appendChild(s);
}(), !function(t) {
"use strict";
function e() {
var e = this;
e.reads = [], e.writes = [], e.raf = u.bind(t), s("initialized", e);
}
function n(t) {
t.scheduled || (t.scheduled = !0, t.raf(r.bind(null, t)), s("flush scheduled"));
}
function r(t) {
s("flush");
var e, r = t.writes, o = t.reads;
try {
s("flushing reads", o.length), i(o), s("flushing writes", r.length), i(r);
} catch (a) {
e = a;
}
if (t.scheduled = !1, (o.length || r.length) && n(t), e) {
if (s("task errored", e.message), !t.catch) throw e;
t.catch(e);
}
}
function i(t) {
s("run tasks");
for (var e; e = t.shift(); ) e();
}
function o(t, e) {
var n = t.indexOf(e);
return !!~n && !!t.splice(n, 1);
}
function a(t, e) {
for (var n in e) e.hasOwnProperty(n) && (t[n] = e[n]);
}
var s = function() {}, u = t.requestAnimationFrame || t.webkitRequestAnimationFrame || t.mozRequestAnimationFrame || t.msRequestAnimationFrame || function(t) {
return setTimeout(t, 16);
};
e.prototype = {
constructor: e,
measure: function(t, e) {
s("measure");
var r = e ? t.bind(e) : t;
return this.reads.push(r), n(this), r;
},
mutate: function(t, e) {
s("mutate");
var r = e ? t.bind(e) : t;
return this.writes.push(r), n(this), r;
},
clear: function(t) {
return s("clear", t), o(this.reads, t) || o(this.writes, t);
},
extend: function(t) {
if (s("extend", t), "object" != typeof t) throw new Error("expected object");
var e = Object.create(this);
return a(e, t), e.fastdom = this, e.initialize && e.initialize(), e;
},
"catch": null
};
var c = t.fastdom = t.fastdom || new e();
"f" == (typeof define)[0] ? define(function() {
return c;
}) : "o" == (typeof module)[0] && (module.exports = c);
}("undefined" != typeof window ? window : this), !function(t, e) {
"object" == typeof exports && "object" == typeof module ? module.exports = e() : "function" == typeof define && define.amd ? define([], e) : "object" == typeof exports ? exports.Slardar = e() : t.Slardar = e();
}("undefined" != typeof self ? self : this, function() {
return function(t) {
function e(r) {
if (n[r]) return n[r].exports;
var i = n[r] = {
i: r,
l: !1,
exports: {}
};
return t[r].call(i.exports, i, i.exports, e), i.l = !0, i.exports;
}
var n = {};
return e.m = t, e.c = n, e.d = function(t, n, r) {
e.o(t, n) || Object.defineProperty(t, n, {
configurable: !1,
enumerable: !0,
get: r
});
}, e.n = function(t) {
var n = t && t.__esModule ? function() {
return t.default;
} : function() {
return t;
};
return e.d(n, "a", n), n;
}, e.o = function(t, e) {
return Object.prototype.hasOwnProperty.call(t, e);
}, e.p = "", e(e.s = 1);
}([ function(t) {
function e(t) {
return "object" == typeof t && null !== t;
}
function n(t) {
return "function" == typeof t;
}
function r(t) {
return "[object String]" === Object.prototype.toString.call(t);
}
function i(t) {
return "[object Array]" === Object.prototype.toString.call(t);
}
function o(t) {
return "[object Date]" === Object.prototype.toString.call(t);
}
function a(t) {
return void 0 === t;
}
function s(t, e) {
return Object.prototype.hasOwnProperty.call(t, e);
}
function u(t, e) {
var n, r;
if (a(t.length)) for (n in t) s(t, n) && e.call(null, n, t[n]); else if (r = t.length) for (n = 0; r > n; n++) e.call(null, n, t[n]);
}
function c(t) {
for (var e in t) if (t.hasOwnProperty(e)) return !1;
return !0;
}
function l(t) {
for (var e, n = [], i = 0, o = t.length; o > i; i++) e = t[i], r(e) ? n.push(e.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1")) : e && e.source && n.push(e.source);
return new RegExp(n.join("|"), "i");
}
function f(t) {
var e = document.createElement("a");
e.href = t;
var n = e.pathname || "/";
return "/" !== n[0] && (n = "/" + n), {
protocol: e.protocol.slice(0, -1),
hostname: e.hostname,
pathname: n
};
}
function h(t) {
var e = [];
return u(t, function(t, n) {
e.push(encodeURIComponent(t) + "=" + encodeURIComponent(n));
}), e.join("&");
}
function p() {
return +new Date();
}
function d(t) {
var e = t.offsetTop;
return null !== t.offsetParent && (e += d(t.offsetParent)), e;
}
function m() {
return window.innerHeight ? window.innerHeight : document.documentElement && document.documentElement.clientHeight ? document.documentElement.clientHeight : void 0;
}
t.exports = {
isObject: e,
isFunction: n,
isString: r,
isArray: i,
isDate: o,
each: u,
isEmptyObject: c,
joinRegExp: l,
urlParser: f,
urlencode: h,
now: p,
getOffsetTop: d,
getWinHeight: m
};
}, function(t, e, n) {
t.exports = n(2);
}, function(t, e, n) {
var r = n(3), i = new r();
t.exports = i;
}, function(t, e, n) {
function r() {
this._baseParams = {}, this._globalOptions = {
sampleRate: 1,
ignoreStatic: [],
ignoreAjax: []
}, this.recordCtx = {
__firstScreenLoadEndTime: 0
};
}
var i = n(4), o = n(5), a = n(7), s = n(8), u = n(0), c = u.isObject, l = u.isArray, f = u.each, h = u.isEmptyObject, p = u.urlencode, d = u.joinRegExp, m = u.now;
r.prototype = {
VERSION: "1.0.0",
install: function(t) {
var e = this, n = e._baseParams, r = e._globalOptions;
e._baseEnvCheck() && c(t) && !h(t) && t.bid && t.pid && (n.version = this.VERSION, 
n.bid = t.bid, n.pid = t.pid, n.hostname = window.location.hostname, n.protocol = window.location.protocol.slice(0, -1), 
r.sampleRate = t.sampleRate || 1, r.ignoreStatic = !(!l(t.ignoreStatic) || !t.ignoreStatic.length) && d(t.ignoreStatic), 
r.ignoreAjax = !(!l(t.ignoreAjax) || !t.ignoreAjax.length) && d(t.ignoreAjax), o.start(this.recordCtx), 
a.start(function() {
e._send.apply(e, arguments);
}, this.recordCtx), i.start(function() {
e._send.apply(e, arguments);
}, r.ignoreStatic), s.start(function() {
e._send.apply(e, arguments);
}, r.ignoreAjax));
},
sendCustomTimeLog: function(t, e, n) {
if (t) {
var r = {
ev_type: "custom",
cm_name: t,
cm_type: "time"
};
e && (r.cm_tag = e), +n && (r.cm_value = +n, this._send(r, !0));
}
},
sendCustomCountLog: function(t, e) {
if (t) {
var n = {
ev_type: "custom",
cm_name: t,
cm_type: "count"
};
e && (n.cm_tag = e), this._send(n);
}
},
_send: function(t, e) {
var n = this._globalOptions, r = this._paramsPack(t);
r && ("number" == typeof n.sampleRate ? Math.random() < n.sampleRate && this._makeRequest(r, e) : this._makeRequest(r, e));
},
_makeRequest: function(t, e) {
var n = new Image(), r = e ? "https://m.toutiao.com/log/sentry/v2/api/slardar/custom/?" : "https://m.toutiao.com/log/sentry/v2/api/slardar/main/?";
n.src = r + t;
},
_paramsPack: function(t) {
return !c(t) || h(t) ? null : (f(this._baseParams, function(e, n) {
t[e] = n;
}), t.timestamp = m(), p(t));
},
_baseEnvCheck: function() {
return !!window.addEventListener;
}
}, t.exports = r;
}, function(t, e, n) {
var r = n(0), i = r.urlParser, o = {
start: function(t, e) {
function n(t, e) {
var n = {
ev_type: "static",
st_type: e
}, r = i(t);
return n.st_protocol = r.protocol, n.st_domain = r.hostname, n.st_domain ? ("script" !== e && "link" !== e || (n.st_path = r.pathname), 
"img" !== e || r.pathname && "/" !== r.pathname ? n : null) : null;
}
function r(r) {
var i = r || window.event || {}, o = {};
try {
o = i.target || i.srcElement || {};
} catch (i) {
return;
}
var a = o.src || o.href || "", s = o.tagName && o.tagName.toLowerCase() || "";
a && s && a !== window.location.href && (e && e.test(a) || t && t(n(a, s)));
}
window.addEventListener("error", r, !0);
}
};
t.exports = o;
}, function(t, e, n) {
var r = n(0), i = n(6), o = r.getOffsetTop, a = r.getWinHeight, s = r.now, u = i.raf, c = i.caf, l = {
start: function(t) {
var e = a(), n = [], r = !1, i = !1, l = u(function f() {
var a, h;
if (r) {
if (n.length && !i) for (a = 0; a < n.length; a++) {
if (h = n[a], !h.complete) {
i = !1;
break;
}
i = !0;
} else i = !0;
if (i) return t.__firstScreenLoadEndTime = s(), void c(l);
} else {
var p = document.querySelectorAll("img");
for (a = 0; a < p.length; a++) {
h = p[a];
var d = o(h);
if (d > e) {
r = !0;
break;
}
e >= d && !h.hasPushed && (h.hasPushed = 1, n.push(h));
}
}
l = u(f);
});
document.addEventListener("DOMContentLoaded", function() {
document.querySelectorAll("img").length || (r = !0);
}), window.addEventListener("load", function() {
i = !0, r = !0;
}, !1);
}
};
t.exports = l;
}, function(t) {
for (var e = 0, n = [ "ms", "moz", "webkit", "o" ], r = window.requestAnimationFrame, i = window.cancelAnimationFrame, o = 0; o < n.length && !r; ++o) r = window[n[o] + "RequestAnimationFrame"], 
i = window[n[o] + "CancelAnimationFrame"] || window[n[o] + "CancelRequestAnimationFrame"];
r || (r = function(t) {
var n = new Date().getTime(), r = Math.max(0, 16 - (n - e)), i = window.setTimeout(function() {
t(n + r);
}, r);
return e = n + r, i;
}), i || (i = function(t) {
clearTimeout(t);
}), t.exports = {
raf: r,
caf: i
};
}, function(t, e, n) {
var r = n(0), i = r.isObject, o = window.performance, a = {
start: function(t, e) {
function n() {
var t = {
ev_type: "perf"
}, n = o.timing;
return t.dns = n.domainLookupEnd - n.domainLookupStart, t.tcp = n.connectEnd - n.connectStart, 
t.request = n.responseStart - n.requestStart, t.response = n.responseEnd - n.responseStart, 
t.processing = n.domComplete - n.domLoading, t.blank = n.responseEnd - n.navigationStart, 
t.domready = n.domInteractive - n.navigationStart, t.load = n.loadEventEnd - n.navigationStart, 
t.firstscreen = e.__firstScreenLoadEndTime ? e.__firstScreenLoadEndTime - n.navigationStart : t.domready, 
t;
}
function r() {
t && t(n());
}
i(o) && window.addEventListener("load", function() {
setTimeout(r, 1500);
}, !1);
}
};
t.exports = a;
}, function(t, e, n) {
var r = n(0), i = r.urlParser, o = r.now, a = /m\.toutiao\.com\/log\/sentry\/v2\/api\/(\d+)\/store\/$/, s = window.XMLHttpRequest, u = {
start: function(t, e) {
function n(n, r) {
if (!(e && e.test(r) || a.test(r) || 0 === n.ax_status)) {
var o = i(r);
n.ax_protocol = o.protocol, n.ax_domain = o.hostname, n.ax_path = o.pathname, n.ax_domain && t && t(n);
}
}
function r(t) {
var e = "[object String]" === Object.prototype.toString.call(t);
return t ? e ? t.length : window.ArrayBuffer && t instanceof ArrayBuffer ? t.byteLength : window.Blob && t instanceof Blob ? t.size : t.length ? t.length : 0 : 0;
}
function u(t, e) {
return this._url = e && e.split("?")[0] || "", this._method = t && t.toLowerCase() || "", 
f.apply(this, arguments);
}
function c() {
if (4 === this.readyState) {
var t = {
ev_type: "ajax",
ax_status: this.status,
ax_type: this._method
};
if (200 === this.status) if (t.ax_duration = o() - this._start, "" === this.responseType || "text" === this.responseType) t.ax_size = r(this.responseText); else if (this.response) t.ax_size = r(this.response); else try {
t.ax_size = r(this.responseText);
} catch (e) {}
n(t, this._url);
}
return this._onreadystatechange ? this._onreadystatechange.apply(this, arguments) : void 0;
}
function l() {
return this.onreadystatechange && (this._onreadystatechange = this.onreadystatechange), 
this.onreadystatechange = c, this._start = o(), h.apply(this, arguments);
}
if ("function" == typeof s) {
var f = s.prototype.open, h = s.prototype.send;
s.prototype.open = u, s.prototype.send = l;
}
}
};
t.exports = u;
} ]);
}), window.Slardar && window.Slardar.install({
sampleRate: .01,
bid: "article_app",
pid: "article",
ignoreAjax: [],
ignoreStatic: []
}), SelfEvent.prototype.on = function(t, e) {
t && "string" == typeof t && "function" == typeof e && (Array.isArray(this.eventMap[t]) ? -1 === this.eventMap[t].indexOf(e) && this.eventMap[t].push(e) : this.eventMap[t] = [ e ]);
}, SelfEvent.prototype.off = function(t, e) {
if (t && "string" == typeof t) if (e) {
if ("function" == typeof e && Array.isArray(this.eventMap[t])) {
var n = this.eventMap[t].indexOf(e);
n > -1 && this.eventMap[t].splice(n, 1);
}
} else delete this.eventMap[t];
}, SelfEvent.prototype.emit = function(t, e) {
t && "string" == typeof t && e && Array.isArray(this.eventMap[t]) && this.eventMap[t].forEach(function(t) {
t.call(e);
});
};

var pgcEvent = new SelfEvent("pgc");

!function(t) {
if ("object" == typeof exports && "undefined" != typeof module) module.exports = t(); else if ("function" == typeof define && define.amd) define([], t); else {
var e;
e = "undefined" != typeof window ? window : "undefined" != typeof global ? global : "undefined" != typeof self ? self : this, 
e.Raven = t();
}
}(function() {
return function t(e, n, r) {
function i(a, s) {
if (!n[a]) {
if (!e[a]) {
var u = "function" == typeof require && require;
if (!s && u) return u(a, !0);
if (o) return o(a, !0);
var c = new Error("Cannot find module '" + a + "'");
throw c.code = "MODULE_NOT_FOUND", c;
}
var l = n[a] = {
exports: {}
};
e[a][0].call(l.exports, function(t) {
var n = e[a][1][t];
return i(n ? n : t);
}, l, l.exports, t, e, n, r);
}
return n[a].exports;
}
for (var o = "function" == typeof require && require, a = 0; a < r.length; a++) i(r[a]);
return i;
}({
1: [ function(t, e) {
"use strict";
function n(t) {
this.name = "RavenConfigError", this.message = t;
}
n.prototype = new Error(), n.prototype.constructor = n, e.exports = n;
}, {} ],
2: [ function(t, e) {
"use strict";
var n = function(t, e, n) {
var r = t[e], i = t;
if (e in t) {
var o = "warn" === e ? "warning" : e;
t[e] = function() {
var t = [].slice.call(arguments), e = "" + t.join(" "), a = {
level: o,
logger: "console",
extra: {
arguments: t
}
};
n && n(e, a), r && Function.prototype.apply.call(r, i, t);
};
}
};
e.exports = {
wrapMethod: n
};
}, {} ],
3: [ function(t, e) {
(function(n) {
"use strict";
function r() {
return +new Date();
}
function i(t, e) {
return s(e) ? function(n) {
return e(n, t);
} : e;
}
function o() {
this.a = !("object" != typeof JSON || !JSON.stringify), this.b = !a(M), this.c = !a(F), 
this.d = null, this.e = null, this.f = null, this.g = null, this.h = null, this.i = null, 
this.j = {}, this.k = {
logger: "javascript",
ignoreErrors: [],
ignoreUrls: [],
whitelistUrls: [],
includePaths: [],
crossOrigin: "anonymous",
collectWindowErrors: !0,
maxMessageLength: 0,
maxUrlLength: 250,
stackTraceLimit: 50,
autoBreadcrumbs: !0,
instrument: !0,
sampleRate: 1
}, this.l = 0, this.m = !1, this.n = Error.stackTraceLimit, this.o = L.console || {}, 
this.p = {}, this.q = [], this.r = r(), this.s = [], this.t = [], this.u = null, 
this.v = L.location, this.w = this.v && this.v.href, this.x();
for (var t in this.o) this.p[t] = this.o[t];
}
function a(t) {
return void 0 === t;
}
function s(t) {
return "function" == typeof t;
}
function u(t) {
return "[object String]" === D.toString.call(t);
}
function c(t) {
for (var e in t) return !1;
return !0;
}
function l(t, e) {
var n, r;
if (a(t.length)) for (n in t) d(t, n) && e.call(null, n, t[n]); else if (r = t.length) for (n = 0; r > n; n++) e.call(null, n, t[n]);
}
function f(t, e) {
return e ? (l(e, function(e, n) {
t[e] = n;
}), t) : t;
}
function h(t) {
return !!Object.isFrozen && Object.isFrozen(t);
}
function p(t, e) {
return !e || t.length <= e ? t : t.substr(0, e) + "…";
}
function d(t, e) {
return D.hasOwnProperty.call(t, e);
}
function m(t) {
for (var e, n = [], r = 0, i = t.length; i > r; r++) e = t[r], u(e) ? n.push(e.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1")) : e && e.source && n.push(e.source);
return new RegExp(n.join("|"), "i");
}
function v(t) {
var e = [];
return l(t, function(t, n) {
e.push(encodeURIComponent(t) + "=" + encodeURIComponent(n));
}), e.join("&");
}
function g(t) {
var e = t.match(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?$/);
if (!e) return {};
var n = e[6] || "", r = e[8] || "";
return {
protocol: e[2],
host: e[4],
path: e[5],
relative: e[5] + n + r
};
}
function y() {
var t = L.crypto || L.msCrypto;
if (!a(t) && t.getRandomValues) {
var e = new Uint16Array(8);
t.getRandomValues(e), e[3] = 4095 & e[3] | 16384, e[4] = 16383 & e[4] | 32768;
var n = function(t) {
for (var e = t.toString(16); e.length < 4; ) e = "0" + e;
return e;
};
return n(e[0]) + n(e[1]) + n(e[2]) + n(e[3]) + n(e[4]) + n(e[5]) + n(e[6]) + n(e[7]);
}
return "xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx".replace(/[xy]/g, function(t) {
var e = 16 * Math.random() | 0, n = "x" === t ? e : 3 & e | 8;
return n.toString(16);
});
}
function b(t) {
for (var e, n = 5, r = 80, i = [], o = 0, a = 0, s = " > ", u = s.length; t && o++ < n && (e = x(t), 
!("html" === e || o > 1 && a + i.length * u + e.length >= r)); ) i.push(e), a += e.length, 
t = t.parentNode;
return i.reverse().join(s);
}
function x(t) {
var e, n, r, i, o, a = [];
if (!t || !t.tagName) return "";
if (a.push(t.tagName.toLowerCase()), t.id && a.push("#" + t.id), e = t.className, 
e && u(e)) for (n = e.split(/\s+/), o = 0; o < n.length; o++) a.push("." + n[o]);
var s = [ "type", "name", "title", "alt" ];
for (o = 0; o < s.length; o++) r = s[o], i = t.getAttribute(r), i && a.push("[" + r + '="' + i + '"]');
return a.join("");
}
function w(t, e) {
return !!(!!t ^ !!e);
}
function E(t, e) {
return !w(t, e) && (t = t.values[0], e = e.values[0], t.type === e.type && t.value === e.value && S(t.stacktrace, e.stacktrace));
}
function S(t, e) {
if (w(t, e)) return !1;
var n = t.frames, r = e.frames;
if (n.length !== r.length) return !1;
for (var i, o, a = 0; a < n.length; a++) if (i = n[a], o = r[a], i.filename !== o.filename || i.lineno !== o.lineno || i.colno !== o.colno || i["function"] !== o["function"]) return !1;
return !0;
}
function k(t, e, n, r) {
var i = t[e];
t[e] = n(i), r && r.push([ t, e, i ]);
}
var _ = t(6), j = t(7), T = t(1), C = t(5), O = C.isError, R = C.isObject, N = t(2).wrapMethod, A = "source protocol user pass host port path".split(" "), P = /^(?:(\w+):)?\/\/(?:(\w+)(:\w+)?@)?([\w\.-]+)(?::(\d+))?(\/.*)/, L = "undefined" != typeof window ? window : "undefined" != typeof n ? n : "undefined" != typeof self ? self : {}, M = L.document, F = L.navigator;
o.prototype = {
VERSION: "3.17.0",
debug: !1,
TraceKit: _,
config: function(t, e) {
var n = this;
if (n.g) return this.y("error", "Error: Raven has already been configured"), n;
if (!t) return n;
var r = n.k;
e && l(e, function(t, e) {
"tags" === t || "extra" === t || "user" === t ? n.j[t] = e : r[t] = e;
}), n.setDSN(t), r.ignoreErrors.push(/^Script error\.?$/), r.ignoreErrors.push(/^Javascript error: Script error\.? on line 0$/), 
r.ignoreErrors = m(r.ignoreErrors), r.ignoreUrls = !!r.ignoreUrls.length && m(r.ignoreUrls), 
r.whitelistUrls = !!r.whitelistUrls.length && m(r.whitelistUrls), r.includePaths = m(r.includePaths), 
r.maxBreadcrumbs = Math.max(0, Math.min(r.maxBreadcrumbs || 100, 100));
var i = {
xhr: !0,
console: !0,
dom: !0,
location: !0
}, o = r.autoBreadcrumbs;
"[object Object]" === {}.toString.call(o) ? o = f(i, o) : o !== !1 && (o = i), r.autoBreadcrumbs = o;
var a = {
tryCatch: !0
}, s = r.instrument;
return "[object Object]" === {}.toString.call(s) ? s = f(a, s) : s !== !1 && (s = a), 
r.instrument = s, _.collectWindowErrors = !!r.collectWindowErrors, n;
},
install: function() {
var t = this;
return t.isSetup() && !t.m && (_.report.subscribe(function() {
t.z.apply(t, arguments);
}), t.k.instrument && t.k.instrument.tryCatch && t.A(), t.k.autoBreadcrumbs && t.B(), 
t.C(), t.m = !0), Error.stackTraceLimit = t.k.stackTraceLimit, this;
},
setDSN: function(t) {
var e = this, n = e.D(t), r = n.path.lastIndexOf("/"), i = n.path.substr(1, r);
e.E = t, e.h = n.user, e.F = n.pass && n.pass.substr(1), e.i = n.path.substr(r + 1), 
e.g = e.G(n), e.H = e.g + "/" + i + "api/" + e.i + "/store/", this.x();
},
context: function(t, e, n) {
return s(t) && (n = e || [], e = t, t = void 0), this.wrap(t, e).apply(this, n);
},
wrap: function(t, e, n) {
function r() {
var r = [], o = arguments.length, a = !t || t && t.deep !== !1;
for (n && s(n) && n.apply(this, arguments); o--; ) r[o] = a ? i.wrap(t, arguments[o]) : arguments[o];
try {
return e.apply(this, r);
} catch (u) {
throw i.I(), i.captureException(u, t), u;
}
}
var i = this;
if (a(e) && !s(t)) return t;
if (s(t) && (e = t, t = void 0), !s(e)) return e;
try {
if (e.J) return e;
if (e.K) return e.K;
} catch (o) {
return e;
}
for (var u in e) d(e, u) && (r[u] = e[u]);
return r.prototype = e.prototype, e.K = r, r.J = !0, r.L = e, r;
},
uninstall: function() {
return _.report.uninstall(), this.M(), Error.stackTraceLimit = this.n, this.m = !1, 
this;
},
captureException: function(t, e) {
if (!O(t)) return this.captureMessage(t, f({
trimHeadFrames: 1,
stacktrace: !0
}, e));
this.d = t;
try {
var n = _.computeStackTrace(t);
this.N(n, e);
} catch (r) {
if (t !== r) throw r;
}
return this;
},
captureMessage: function(t, e) {
if (!this.k.ignoreErrors.test || !this.k.ignoreErrors.test(t)) {
e = e || {};
var n = f({
message: t + ""
}, e);
if (this.k.stacktrace || e && e.stacktrace) {
var r;
try {
throw new Error(t);
} catch (i) {
r = i;
}
r.name = null, e = f({
fingerprint: t,
trimHeadFrames: (e.trimHeadFrames || 0) + 1
}, e);
var o = _.computeStackTrace(r), a = this.O(o, e);
n.stacktrace = {
frames: a.reverse()
};
}
return this.P(n), this;
}
},
captureBreadcrumb: function(t) {
var e = f({
timestamp: r() / 1e3
}, t);
if (s(this.k.breadcrumbCallback)) {
var n = this.k.breadcrumbCallback(e);
if (R(n) && !c(n)) e = n; else if (n === !1) return this;
}
return this.t.push(e), this.t.length > this.k.maxBreadcrumbs && this.t.shift(), 
this;
},
addPlugin: function(t) {
var e = [].slice.call(arguments, 1);
return this.q.push([ t, e ]), this.m && this.C(), this;
},
setUserContext: function(t) {
return this.j.user = t, this;
},
setExtraContext: function(t) {
return this.Q("extra", t), this;
},
setTagsContext: function(t) {
return this.Q("tags", t), this;
},
clearContext: function() {
return this.j = {}, this;
},
getContext: function() {
return JSON.parse(j(this.j));
},
setEnvironment: function(t) {
return this.k.environment = t, this;
},
setRelease: function(t) {
return this.k.release = t, this;
},
setDataCallback: function(t) {
var e = this.k.dataCallback;
return this.k.dataCallback = i(e, t), this;
},
setBreadcrumbCallback: function(t) {
var e = this.k.breadcrumbCallback;
return this.k.breadcrumbCallback = i(e, t), this;
},
setShouldSendCallback: function(t) {
var e = this.k.shouldSendCallback;
return this.k.shouldSendCallback = i(e, t), this;
},
setTransport: function(t) {
return this.k.transport = t, this;
},
lastException: function() {
return this.d;
},
lastEventId: function() {
return this.f;
},
isSetup: function() {
return !(!this.a || !this.g && (this.ravenNotConfiguredError || (this.ravenNotConfiguredError = !0, 
this.y("error", "Error: Raven has not been configured.")), 1));
},
afterLoad: function() {
var t = L.RavenConfig;
t && this.config(t.dsn, t.config).install();
},
showReportDialog: function(t) {
if (M) {
t = t || {};
var e = t.eventId || this.lastEventId();
if (!e) throw new T("Missing eventId");
var n = t.dsn || this.E;
if (!n) throw new T("Missing DSN");
var r = encodeURIComponent, i = "";
i += "?eventId=" + r(e), i += "&dsn=" + r(n);
var o = t.user || this.j.user;
o && (o.name && (i += "&name=" + r(o.name)), o.email && (i += "&email=" + r(o.email)));
var a = this.G(this.D(n)), s = M.createElement("script");
s.async = !0, s.src = a + "/api/embed/error-page/" + i, (M.head || M.body).appendChild(s);
}
},
I: function() {
var t = this;
this.l += 1, setTimeout(function() {
t.l -= 1;
});
},
R: function(t, e) {
var n, r;
if (this.b) {
e = e || {}, t = "raven" + t.substr(0, 1).toUpperCase() + t.substr(1), M.createEvent ? (n = M.createEvent("HTMLEvents"), 
n.initEvent(t, !0, !0)) : (n = M.createEventObject(), n.eventType = t);
for (r in e) d(e, r) && (n[r] = e[r]);
if (M.createEvent) M.dispatchEvent(n); else try {
M.fireEvent("on" + n.eventType.toLowerCase(), n);
} catch (i) {}
}
},
S: function(t) {
var e = this;
return function(n) {
if (e.T = null, e.u !== n) {
e.u = n;
var r;
try {
r = b(n.target);
} catch (i) {
r = "<unknown>";
}
e.captureBreadcrumb({
category: "ui." + t,
message: r
});
}
};
},
U: function() {
var t = this, e = 1e3;
return function(n) {
var r;
try {
r = n.target;
} catch (i) {
return;
}
var o = r && r.tagName;
if (o && ("INPUT" === o || "TEXTAREA" === o || r.isContentEditable)) {
var a = t.T;
a || t.S("input")(n), clearTimeout(a), t.T = setTimeout(function() {
t.T = null;
}, e);
}
};
},
V: function(t, e) {
var n = g(this.v.href), r = g(e), i = g(t);
this.w = e, n.protocol === r.protocol && n.host === r.host && (e = r.relative), 
n.protocol === i.protocol && n.host === i.host && (t = i.relative), this.captureBreadcrumb({
category: "navigation",
data: {
to: e,
from: t
}
});
},
A: function() {
function t(t) {
return function() {
for (var e = new Array(arguments.length), r = 0; r < e.length; ++r) e[r] = arguments[r];
var i = e[0];
return s(i) && (e[0] = n.wrap(i)), t.apply ? t.apply(this, e) : t(e[0], e[1]);
};
}
function e(t) {
var e = L[t] && L[t].prototype;
e && e.hasOwnProperty && e.hasOwnProperty("addEventListener") && (k(e, "addEventListener", function(e) {
return function(r, o, a, s) {
try {
o && o.handleEvent && (o.handleEvent = n.wrap(o.handleEvent));
} catch (u) {}
var c, l, f;
return i && i.dom && ("EventTarget" === t || "Node" === t) && (l = n.S("click"), 
f = n.U(), c = function(t) {
if (t) {
var e;
try {
e = t.type;
} catch (n) {
return;
}
return "click" === e ? l(t) : "keypress" === e ? f(t) : void 0;
}
}), e.call(this, r, n.wrap(o, void 0, c), a, s);
};
}, r), k(e, "removeEventListener", function(t) {
return function(e, n, r, i) {
try {
n = n && (n.K ? n.K : n);
} catch (o) {}
return t.call(this, e, n, r, i);
};
}, r));
}
var n = this, r = n.s, i = this.k.autoBreadcrumbs;
k(L, "setTimeout", t, r), k(L, "setInterval", t, r), L.requestAnimationFrame && k(L, "requestAnimationFrame", function(t) {
return function(e) {
return t(n.wrap(e));
};
}, r);
for (var o = [ "EventTarget", "Window", "Node", "ApplicationCache", "AudioTrackList", "ChannelMergerNode", "CryptoOperation", "EventSource", "FileReader", "HTMLUnknownElement", "IDBDatabase", "IDBRequest", "IDBTransaction", "KeyOperation", "MediaController", "MessagePort", "ModalWindow", "Notification", "SVGElementInstance", "Screen", "TextTrack", "TextTrackCue", "TextTrackList", "WebSocket", "WebSocketWorker", "Worker", "XMLHttpRequest", "XMLHttpRequestEventTarget", "XMLHttpRequestUpload" ], a = 0; a < o.length; a++) e(o[a]);
},
B: function() {
function t(t, n) {
t in n && s(n[t]) && k(n, t, function(t) {
return e.wrap(t);
});
}
var e = this, n = this.k.autoBreadcrumbs, r = e.s;
if (n.xhr && "XMLHttpRequest" in L) {
var i = XMLHttpRequest.prototype;
k(i, "open", function(t) {
return function(n, r) {
return u(r) && -1 === r.indexOf(e.h) && (this.W = {
method: n,
url: r,
status_code: null
}), t.apply(this, arguments);
};
}, r), k(i, "send", function(n) {
return function() {
function r() {
if (i.W && (1 === i.readyState || 4 === i.readyState)) {
try {
i.W.status_code = i.status;
} catch (t) {}
e.captureBreadcrumb({
type: "http",
category: "xhr",
data: i.W
});
}
}
for (var i = this, o = [ "onload", "onerror", "onprogress" ], a = 0; a < o.length; a++) t(o[a], i);
return "onreadystatechange" in i && s(i.onreadystatechange) ? k(i, "onreadystatechange", function(t) {
return e.wrap(t, void 0, r);
}) : i.onreadystatechange = r, n.apply(this, arguments);
};
}, r);
}
n.xhr && "fetch" in L && k(L, "fetch", function(t) {
return function() {
for (var n = new Array(arguments.length), r = 0; r < n.length; ++r) n[r] = arguments[r];
var i, o = n[0], a = "GET";
"string" == typeof o ? i = o : (i = o.url, o.method && (a = o.method)), n[1] && n[1].method && (a = n[1].method);
var s = {
method: a,
url: i,
status_code: null
};
return e.captureBreadcrumb({
type: "http",
category: "fetch",
data: s
}), t.apply(this, n).then(function(t) {
return s.status_code = t.status, t;
});
};
}, r), n.dom && this.b && (M.addEventListener ? (M.addEventListener("click", e.S("click"), !1), 
M.addEventListener("keypress", e.U(), !1)) : (M.attachEvent("onclick", e.S("click")), 
M.attachEvent("onkeypress", e.U())));
var o = L.chrome, a = o && o.app && o.app.runtime, c = !a && L.history && history.pushState;
if (n.location && c) {
var f = L.onpopstate;
L.onpopstate = function() {
var t = e.v.href;
return e.V(e.w, t), f ? f.apply(this, arguments) : void 0;
}, k(history, "pushState", function(t) {
return function() {
var n = arguments.length > 2 ? arguments[2] : void 0;
return n && e.V(e.w, n + ""), t.apply(this, arguments);
};
}, r);
}
if (n.console && "console" in L && console.log) {
var h = function(t, n) {
e.captureBreadcrumb({
message: t,
level: n.level,
category: "console"
});
};
l([ "debug", "info", "warn", "error", "log" ], function(t, e) {
N(console, e, h);
});
}
},
M: function() {
for (var t; this.s.length; ) {
t = this.s.shift();
var e = t[0], n = t[1], r = t[2];
e[n] = r;
}
},
C: function() {
var t = this;
l(this.q, function(e, n) {
var r = n[0], i = n[1];
r.apply(t, [ t ].concat(i));
});
},
D: function(t) {
var e = P.exec(t), n = {}, r = 7;
try {
for (;r--; ) n[A[r]] = e[r] || "";
} catch (i) {
throw new T("Invalid DSN: " + t);
}
if (n.pass && !this.k.allowSecretKey) throw new T("Do not specify your secret key in the DSN. See: http://bit.ly/raven-secret-key");
return n;
},
G: function(t) {
var e = "//" + t.host + (t.port ? ":" + t.port : "");
return t.protocol && (e = t.protocol + ":" + e), e;
},
z: function() {
this.l || this.N.apply(this, arguments);
},
N: function(t, e) {
var n = this.O(t, e);
this.R("handle", {
stackInfo: t,
options: e
}), this.X(t.name, t.message, t.url, t.lineno, n, e);
},
O: function(t, e) {
var n = this, r = [];
if (t.stack && t.stack.length && (l(t.stack, function(t, e) {
var i = n.Y(e);
i && r.push(i);
}), e && e.trimHeadFrames)) for (var i = 0; i < e.trimHeadFrames && i < r.length; i++) r[i].in_app = !1;
return r = r.slice(0, this.k.stackTraceLimit);
},
Y: function(t) {
if (t.url) {
var e = {
filename: t.url,
lineno: t.line,
colno: t.column,
"function": t.func || "?"
};
return e.in_app = !(this.k.includePaths.test && !this.k.includePaths.test(e.filename) || /(Raven|TraceKit)\./.test(e["function"]) || /raven\.(min\.)?js$/.test(e.filename)), 
e;
}
},
X: function(t, e, n, r, i, o) {
var a;
if (!(this.k.ignoreErrors.test && this.k.ignoreErrors.test(e) || (e += "", i && i.length ? (n = i[0].filename || n, 
i.reverse(), a = {
frames: i
}) : n && (a = {
frames: [ {
filename: n,
lineno: r,
in_app: !0
} ]
}), this.k.ignoreUrls.test && this.k.ignoreUrls.test(n) || this.k.whitelistUrls.test && !this.k.whitelistUrls.test(n)))) {
var s = f({
exception: {
values: [ {
type: t,
value: e,
stacktrace: a
} ]
},
culprit: n
}, o);
this.P(s);
}
},
Z: function(t) {
var e = this.k.maxMessageLength;
if (t.message && (t.message = p(t.message, e)), t.exception) {
var n = t.exception.values[0];
n.value = p(n.value, e);
}
var r = t.request;
return r && (r.url && (r.url = p(r.url, this.k.maxUrlLength)), r.Referer && (r.Referer = p(r.Referer, this.k.maxUrlLength))), 
t.breadcrumbs && t.breadcrumbs.values && this.$(t.breadcrumbs), t;
},
$: function(t) {
for (var e, n, r, i = [ "to", "from", "url" ], o = 0; o < t.values.length; ++o) if (n = t.values[o], 
n.hasOwnProperty("data") && R(n.data) && !h(n.data)) {
r = f({}, n.data);
for (var a = 0; a < i.length; ++a) e = i[a], r.hasOwnProperty(e) && (r[e] = p(r[e], this.k.maxUrlLength));
t.values[o].data = r;
}
},
_: function() {
if (this.c || this.b) {
var t = {};
return this.c && F.userAgent && (t.headers = {
"User-Agent": navigator.userAgent
}), this.b && (M.location && M.location.href && (t.url = M.location.href), M.referrer && (t.headers || (t.headers = {}), 
t.headers.Referer = M.referrer)), t;
}
},
x: function() {
this.aa = 0, this.ba = null;
},
ca: function() {
return this.aa && r() - this.ba < this.aa;
},
da: function(t) {
var e = this.e;
return !(!e || t.message !== e.message || t.culprit !== e.culprit) && (t.stacktrace || e.stacktrace ? S(t.stacktrace, e.stacktrace) : !t.exception && !e.exception || E(t.exception, e.exception));
},
ea: function(t) {
if (!this.ca()) {
var e = t.status;
if (400 === e || 401 === e || 429 === e) {
var n;
try {
n = t.getResponseHeader("Retry-After"), n = 1e3 * parseInt(n, 10);
} catch (i) {}
this.aa = n ? n : 2 * this.aa || 1e3, this.ba = r();
}
}
},
P: function(t) {
var e = this.k, n = {
project: this.i,
logger: e.logger,
platform: "javascript"
}, i = this._();
return i && (n.request = i), t.trimHeadFrames && delete t.trimHeadFrames, t = f(n, t), 
t.tags = f(f({}, this.j.tags), t.tags), t.extra = f(f({}, this.j.extra), t.extra), 
t.extra["session:duration"] = r() - this.r, this.t && this.t.length > 0 && (t.breadcrumbs = {
values: [].slice.call(this.t, 0)
}), c(t.tags) && delete t.tags, this.j.user && (t.user = this.j.user), e.environment && (t.environment = e.environment), 
e.release && (t.release = e.release), e.serverName && (t.server_name = e.serverName), 
s(e.dataCallback) && (t = e.dataCallback(t) || t), !t || c(t) || s(e.shouldSendCallback) && !e.shouldSendCallback(t) ? void 0 : this.ca() ? void this.y("warn", "Raven dropped error due to backoff: ", t) : void ("number" == typeof e.sampleRate ? Math.random() < e.sampleRate && this.fa(t) : this.fa(t));
},
ga: function() {
return y();
},
fa: function(t, e) {
var n = this, r = this.k;
if (this.isSetup()) {
if (this.f = t.event_id || (t.event_id = this.ga()), t = this.Z(t), !this.k.allowDuplicates && this.da(t)) return void this.y("warn", "Raven dropped repeat event: ", t);
this.e = t, this.y("debug", "Raven about to send:", t);
var i = {
sentry_version: "7",
sentry_client: "raven-js/" + this.VERSION,
sentry_key: this.h
};
this.F && (i.sentry_secret = this.F);
var o = t.exception && t.exception.values[0];
this.captureBreadcrumb({
category: "sentry",
message: o ? (o.type ? o.type + ": " : "") + o.value : t.message,
event_id: t.event_id,
level: t.level || "error"
});
var a = this.H;
(r.transport || this.ha).call(this, {
url: a,
auth: i,
data: t,
options: r,
onSuccess: function() {
n.x(), n.R("success", {
data: t,
src: a
}), e && e();
},
onError: function(r) {
n.y("error", "Raven transport failed to send: ", r), r.request && n.ea(r.request), 
n.R("failure", {
data: t,
src: a
}), r = r || new Error("Raven send failed (no additional details provided)"), e && e(r);
}
});
}
},
ha: function(t) {
var e = new XMLHttpRequest(), n = "withCredentials" in e || "undefined" != typeof XDomainRequest;
if (n) {
var r = t.url;
"withCredentials" in e ? e.onreadystatechange = function() {
if (4 === e.readyState) if (200 === e.status) t.onSuccess && t.onSuccess(); else if (t.onError) {
var n = new Error("Sentry error code: " + e.status);
n.request = e, t.onError(n);
}
} : (e = new XDomainRequest(), r = r.replace(/^https?:/, ""), t.onSuccess && (e.onload = t.onSuccess), 
t.onError && (e.onerror = function() {
var n = new Error("Sentry error code: XDomainRequest");
n.request = e, t.onError(n);
})), e.open("POST", r + "?" + v(t.auth)), e.send(j(t.data));
}
},
y: function(t) {
this.p[t] && this.debug && Function.prototype.apply.call(this.p[t], this.o, [].slice.call(arguments, 1));
},
Q: function(t, e) {
a(e) ? delete this.j[t] : this.j[t] = f(this.j[t] || {}, e);
}
};
var D = Object.prototype;
o.prototype.setUser = o.prototype.setUserContext, o.prototype.setReleaseContext = o.prototype.setRelease, 
e.exports = o;
}).call(this, "undefined" != typeof global ? global : "undefined" != typeof self ? self : "undefined" != typeof window ? window : {});
}, {
1: 1,
2: 2,
5: 5,
6: 6,
7: 7
} ],
4: [ function(t, e) {
(function(n) {
"use strict";
var r = t(3), i = "undefined" != typeof window ? window : "undefined" != typeof n ? n : "undefined" != typeof self ? self : {}, o = i.Raven, a = new r();
a.noConflict = function() {
return i.Raven = o, a;
}, a.afterLoad(), e.exports = a;
}).call(this, "undefined" != typeof global ? global : "undefined" != typeof self ? self : "undefined" != typeof window ? window : {});
}, {
3: 3
} ],
5: [ function(t, e) {
"use strict";
function n(t) {
return "object" == typeof t && null !== t;
}
function r(t) {
switch ({}.toString.call(t)) {
case "[object Error]":
return !0;

case "[object Exception]":
return !0;

case "[object DOMException]":
return !0;

default:
return t instanceof Error;
}
}
function i(t) {
function e(e, n) {
var r = t(e) || e;
return n ? n(r) || r : r;
}
return e;
}
e.exports = {
isObject: n,
isError: r,
wrappedCallback: i
};
}, {} ],
6: [ function(t, e) {
(function(n) {
"use strict";
function r() {
return "undefined" == typeof document || "undefined" == typeof document.location ? "" : document.location.href;
}
var i = t(5), o = {
collectWindowErrors: !0,
debug: !1
}, a = "undefined" != typeof window ? window : "undefined" != typeof n ? n : "undefined" != typeof self ? self : {}, s = [].slice, u = "?", c = /^(?:[Uu]ncaught (?:exception: )?)?(?:((?:Eval|Internal|Range|Reference|Syntax|Type|URI|)Error): )?(.*)$/;
o.report = function() {
function t(t) {
h(), y.push(t);
}
function e(t) {
for (var e = y.length - 1; e >= 0; --e) y[e] === t && y.splice(e, 1);
}
function n() {
p(), y = [];
}
function l(t, e) {
var n = null;
if (!e || o.collectWindowErrors) {
for (var r in y) if (y.hasOwnProperty(r)) try {
y[r].apply(null, [ t ].concat(s.call(arguments, 2)));
} catch (i) {
n = i;
}
if (n) throw n;
}
}
function f(t, e, n, a, s) {
var f = null;
if (w) o.computeStackTrace.augmentStackTraceWithInitialElement(w, e, n, t), d(); else if (s && i.isError(s)) f = o.computeStackTrace(s), 
l(f, !0); else {
var h, p = {
url: e,
line: n,
column: a
}, m = void 0, g = t;
if ("[object String]" === {}.toString.call(t)) {
var h = t.match(c);
h && (m = h[1], g = h[2]);
}
p.func = u, f = {
name: m,
message: g,
url: r(),
stack: [ p ]
}, l(f, !0);
}
return !!v && v.apply(this, arguments);
}
function h() {
g || (v = a.onerror, a.onerror = f, g = !0);
}
function p() {
g && (a.onerror = v, g = !1, v = void 0);
}
function d() {
var t = w, e = b;
b = null, w = null, x = null, l.apply(null, [ t, !1 ].concat(e));
}
function m(t, e) {
var n = s.call(arguments, 1);
if (w) {
if (x === t) return;
d();
}
var r = o.computeStackTrace(t);
if (w = r, x = t, b = n, setTimeout(function() {
x === t && d();
}, r.incomplete ? 2e3 : 0), e !== !1) throw t;
}
var v, g, y = [], b = null, x = null, w = null;
return m.subscribe = t, m.unsubscribe = e, m.uninstall = n, m;
}(), o.computeStackTrace = function() {
function t(t) {
if ("undefined" != typeof t.stack && t.stack) {
for (var e, n, i, o = /^\s*at (.*?) ?\(((?:file|https?|blob|chrome-extension|native|eval|webpack|<anonymous>|\/).*?)(?::(\d+))?(?::(\d+))?\)?\s*$/i, a = /^\s*(.*?)(?:\((.*?)\))?(?:^|@)((?:file|https?|blob|chrome|webpack|resource|\[native).*?|[^@]*bundle)(?::(\d+))?(?::(\d+))?\s*$/i, s = /^\s*at (?:((?:\[object object\])?.+) )?\(?((?:file|ms-appx|https?|webpack|blob):.*?):(\d+)(?::(\d+))?\)?\s*$/i, c = /(\S+) line (\d+)(?: > eval line \d+)* > eval/i, l = /\((\S*)(?::(\d+))(?::(\d+))\)/, f = t.stack.split("\n"), h = [], p = (/^(.*) is undefined$/.exec(t.message), 
0), d = f.length; d > p; ++p) {
if (n = o.exec(f[p])) {
var m = n[2] && 0 === n[2].indexOf("native"), v = n[2] && 0 === n[2].indexOf("eval");
v && (e = l.exec(n[2])) && (n[2] = e[1], n[3] = e[2], n[4] = e[3]), i = {
url: m ? null : n[2],
func: n[1] || u,
args: m ? [ n[2] ] : [],
line: n[3] ? +n[3] : null,
column: n[4] ? +n[4] : null
};
} else if (n = s.exec(f[p])) i = {
url: n[2],
func: n[1] || u,
args: [],
line: +n[3],
column: n[4] ? +n[4] : null
}; else {
if (!(n = a.exec(f[p]))) continue;
var v = n[3] && n[3].indexOf(" > eval") > -1;
v && (e = c.exec(n[3])) ? (n[3] = e[1], n[4] = e[2], n[5] = null) : 0 !== p || n[5] || "undefined" == typeof t.columnNumber || (h[0].column = t.columnNumber + 1), 
i = {
url: n[3],
func: n[1] || u,
args: n[2] ? n[2].split(",") : [],
line: n[4] ? +n[4] : null,
column: n[5] ? +n[5] : null
};
}
!i.func && i.line && (i.func = u), h.push(i);
}
return h.length ? {
name: t.name,
message: t.message,
url: r(),
stack: h
} : null;
}
}
function e(t, e, n) {
var r = {
url: e,
line: n
};
if (r.url && r.line) {
if (t.incomplete = !1, r.func || (r.func = u), t.stack.length > 0 && t.stack[0].url === r.url) {
if (t.stack[0].line === r.line) return !1;
if (!t.stack[0].line && t.stack[0].func === r.func) return t.stack[0].line = r.line, 
!1;
}
return t.stack.unshift(r), t.partial = !0, !0;
}
return t.incomplete = !0, !1;
}
function n(t, a) {
for (var s, c, l = /function\s+([_$a-zA-Z\xA0-\uFFFF][_$a-zA-Z0-9\xA0-\uFFFF]*)?\s*\(/i, f = [], h = {}, p = !1, d = n.caller; d && !p; d = d.caller) if (d !== i && d !== o.report) {
if (c = {
url: null,
func: u,
line: null,
column: null
}, d.name ? c.func = d.name : (s = l.exec(d.toString())) && (c.func = s[1]), "undefined" == typeof c.func) try {
c.func = s.input.substring(0, s.input.indexOf("{"));
} catch (m) {}
h["" + d] ? p = !0 : h["" + d] = !0, f.push(c);
}
a && f.splice(0, a);
var v = {
name: t.name,
message: t.message,
url: r(),
stack: f
};
return e(v, t.sourceURL || t.fileName, t.line || t.lineNumber, t.message || t.description), 
v;
}
function i(e, i) {
var a = null;
i = null == i ? 0 : +i;
try {
if (a = t(e)) return a;
} catch (s) {
if (o.debug) throw s;
}
try {
if (a = n(e, i + 1)) return a;
} catch (s) {
if (o.debug) throw s;
}
return {
name: e.name,
message: e.message,
url: r()
};
}
return i.augmentStackTraceWithInitialElement = e, i.computeStackTraceFromStackProp = t, 
i;
}(), e.exports = o;
}).call(this, "undefined" != typeof global ? global : "undefined" != typeof self ? self : "undefined" != typeof window ? window : {});
}, {
5: 5
} ],
7: [ function(t, e, n) {
"use strict";
function r(t, e) {
for (var n = 0; n < t.length; ++n) if (t[n] === e) return n;
return -1;
}
function i(t, e, n, r) {
return JSON.stringify(t, o(e, r), n);
}
function o(t, e) {
var n = [], i = [];
return null == e && (e = function(t, e) {
return n[0] === e ? "[Circular ~]" : "[Circular ~." + i.slice(0, r(n, e)).join(".") + "]";
}), function(o, a) {
if (n.length > 0) {
var s = r(n, this);
~s ? n.splice(s + 1) : n.push(this), ~s ? i.splice(s, 1 / 0, o) : i.push(o), ~r(n, a) && (a = e.call(this, o, a));
} else n.push(a);
return null == t ? a : t.call(this, o, a);
};
}
n = e.exports = i, n.getSerialize = o;
}, {} ]
}, {}, [ 4 ])(4);
}), JSVERSION = 390;

var globalErrors = [], startTimestamp = Date.now(), flushErrorsTimer;

window.onerror = function(t, e, n, r, i) {
"string" != typeof t && (t = "");
var o = {
version: JSVERSION,
message: t,
col: r,
url: e,
line: n,
timestamp: Date.now() - startTimestamp
};
o.stack = i && i.stack ? (i.stack || i.stacktrace).toString() : "", "ReferenceError: Can't find variable: getElementPosition" !== t && (t.indexOf("h.el.trigger") > -1 || (globalErrors.push(o), 
flushErrors()));
}, ToutiaoJSBridge && ToutiaoJSBridge.call("TTNetwork.commonParams", {}, function(t) {
var e = t.data || t;
e && e.device_id && window.Raven && Raven.config("http://key@m.toutiao.com/log/sentry/v2/183", {
tags: {
bid: "article_app",
pid: "article",
ac: e.ac,
aid: e.aid,
channel: e.channel,
device_brand: e.device_brand,
device_id: e.device_id,
device_platform: e.device_platform,
device_type: e.device_type,
os_version: e.os_version,
resolution: e.resolution,
uuid: e.uuid,
version_name: e.version_name || e.version_code,
js_version: JSVERSION,
gid: "",
service: MONITOR_SERVICE
},
ignoreErrors: [ "ReferenceError: Can't find variable: getElementPosition", "Unexpected token ')'" ],
dataCallback: function(t) {
var e = [ "lib.js", "iphone.js", "ios-common.js", "android.js", "android-common.js", "lib-forum.js", "iphone-forum.js", "ios-common-forum.js", "android-forum.js", "android-common-forum.js" ], n = [ "js" ], r = [ "v55", "v60", "shared" ], i = "http://s3.pstatp.com/toutiao/app_web_article_online_updates/";
return t && t.exception && Array.isArray(t.exception.values) && t.exception.values.forEach(function(t) {
t && t.stacktrace && Array.isArray(t.stacktrace.frames) && t.stacktrace.frames.forEach(function(t) {
var o = t.filename, a = o.split("/"), s = a.length;
e.indexOf(a[s - 1]) >= 0 && n.indexOf(a[s - 2]) >= 0 && r.indexOf(a[s - 3]) >= 0 && (t.filename = i + JSVERSION + (client.isAndroid ? "/android" : "/iphone") + "/" + a[s - 3] + "/" + a[s - 2] + "/" + a[s - 1]);
});
}), t.tags.gid = window.Page && Page.statistics ? Page.statistics.group_id : "", 
t;
}
}).install();
});
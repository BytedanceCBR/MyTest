function _getNewsArticleVersion() {
var e = /NewsArticle\/([\d\.]*)/i.exec(navigator.userAgent);
return e ? e[1] : "";
}

function _getAndroidVersion() {
var e = /android ([0-9\.]*)/i.exec(navigator.userAgent);
return e ? e[1] : "";
}

function _getIOSVersion() {
var e = /iPhone OS ([0-9_]*)/i.exec(navigator.userAgent);
return e ? e[1].replace(/_/g, ".") : "";
}

function _isNewsArticleVersionNoLessThan(e) {
var t = client.newsArticleVersion;
if (!t) {
var a = _getNewsArticleVersion();
if (!a) return !1;
client.newsArticleVersion = a;
}
return e = e.split(".").slice(0, 3), t = +t.split(".").slice(0, e.length).join(""), 
t >= +e.join("");
}

function hash2string(e) {
var t = "#";
for (var a in e) t += a + "=" + e[a] + "&";
return "&" == t.substr(-1) ? t = t.slice(0, -1) : "#" == t.substr(-1) && (t = ""), 
t;
}

function formatCount(e, t, a) {
var i = "";
if ("number" != typeof t || 0 === t) i = a || "赞"; else if (1e4 > t) i = t; else if (1e8 > t) {
var o = (Math.floor(t / 1e3) / 10).toFixed(1);
i = (o.indexOf(".0") > -1 || o >= 10 ? o.slice(0, -2) : o) + "万";
} else {
var o = (Math.floor(t / 1e7) / 10).toFixed(1);
i = (o.indexOf(".0") > -1 || o >= 10 ? o.slice(0, -2) : o) + "亿";
}
return e && $(e).each(function() {
$(this).attr("realnum", t).html(i);
}), i;
}

function commentTimeFormat(e) {
var t, a = new Date(), i = "";
try {
if (t = new Date(1e3 * e), isNaN(t.getTime())) throw new Error("Invalid Date");
} catch (o) {
return "";
}
return i += t.getFullYear() < a.getFullYear() ? t.getFullYear() + "-" : "", i += t.getMonth() >= 9 ? t.getMonth() + 1 : "0" + (t.getMonth() + 1), 
i += "-", i += t.getDate() > 9 ? t.getDate() : "0" + t.getDate(), i += " ", i += t.getHours() > 9 ? t.getHours() : "0" + t.getHours(), 
i += ":", i += t.getMinutes() > 9 ? t.getMinutes() : "0" + t.getMinutes();
}

function formatDuration(e) {
if (isNaN(Number(e))) return "00:00";
var t = [ Math.floor(e / 60), ":", Math.ceil(e % 60) ];
return t[2] <= 9 && t.splice(2, 0, 0), t[0] <= 9 && t.unshift(0), t.join("");
}

function formatTime(e) {
var t = 6e4, a = 60 * t, i = new Date(), o = i.getTime(), n = new Date(i.getFullYear(), i.getMonth(), i.getDate()), r = new Date(+e);
if (isNaN(r.getTime())) return "";
var s = o - e;
if (0 > s) return "";
if (t > s) return "刚刚";
if (a > s) return Math.floor(s / t) + "分钟前";
if (24 * a > s) return Math.floor(s / a) + "小时前";
for (var l = (r.getHours() > 9 ? r.getHours() : "0" + r.getHours()) + ":" + (r.getMinutes() > 9 ? r.getMinutes() : "0" + r.getMinutes()), c = 0; c++ <= 8; ) if (n.setDate(n.getDate() - 1), 
e > n.getTime()) return 1 === c ? "昨天 " + l : 2 === c ? "前天 " + l : c + "天前";
return (r.getFullYear() < i.getFullYear() ? r.getFullYear() + "年" : "") + (r.getMonth() + 1) + "月" + r.getDate() + "日";
}

function send_umeng_event(e, t, a) {
var i = "bytedance://" + event_type + "?category=umeng&tag=" + e + "&label=" + encodeURIComponent(t);
if (a) for (var o in a) {
var n = a[o];
if ("extra" === o && "object" == typeof n) if (client.isAndroid) i += "&extra=" + JSON.stringify(n); else {
var r = "";
for (var s in n) r += "object" == typeof n[s] ? "&" + s + "=" + JSON.stringify(n[s]) : "&" + s + "=" + encodeURIComponent(n[s]);
i += r;
} else i += "&" + o + "=" + n;
}
try {
window.webkit.messageHandlers.observe.postMessage(i);
} catch (l) {
console.log(i);
}
}

function sendUmengEventV3(e, t, a) {
if ("string" == typeof e && "" !== e) {
var i = "log_event_v3?event=" + e + "&params=" + JSON.stringify(t || {}) + "&is_double_sending=" + (a ? "1" : "0");
sendBytedanceRequest(i);
}
}

function send_request(e, t) {
var a = "bytedance://" + e;
if (t) {
a += "?";
for (var i in t) a += i + "=" + t[i] + "&";
a = a.slice(0, -1);
}
location.href = a;
}

function send_exposure_event_once(e, t, a) {
function i() {
n && clearTimeout(n), n = setTimeout(function() {
var a = o(e, r);
console.info(a, e), a && (t(), document.removeEventListener("scroll", i, !1));
}, 50);
}
function o(e, t) {
var i = e.getBoundingClientRect(), o = i.top, n = i.height || i.bottom - i.top, r = o;
return a && (r = o + n), t >= r;
}
if (e && "function" == typeof t) {
var n = 0, r = window.innerHeight;
o(e, r) ? t() : document.addEventListener("scroll", i, !1);
}
}

function isElementInViewportY(e, t) {
var a = e.getBoundingClientRect(), i = window.innerHeight || document.body.clientHeight;
return t ? a.height < i ? a.top >= 0 && a.top <= i && a.bottom >= 0 && a.bottom <= i : a.top <= 0 && a.bottom >= i : a.top <= i && a.bottom >= 0;
}

function sendUmengWhenTargetShown(e, t, a, i, o, n) {
e && (isElementInViewportY(e, o) ? n && 3 === n.version ? sendUmengEventV3(t, i, !!n.isDoubleSend) : send_umeng_event(t, a, i) : imprProcessQueue.push(arguments));
}

function wendaCacheAdd(e) {
WendaCacheUmeng.push(e);
}

function wendaCacheRemove() {
var e, t;
for (e = 0, t = WendaCacheUmeng.length; t > e; e++) "function" == typeof WendaCacheUmeng[e] && WendaCacheUmeng[e]();
WendaCacheUmeng = [];
}

function buildServerVIcon(e, t) {
var a = Page.h5_settings.user_verify_info_conf["" + e];
if (!a) return "";
if (a = a[t], !a) return "";
var t = a.icon;
return t = client.isIOS ? a.web_icon_ios : client.isSeniorAndroid ? a.web_icon_android : a.icon_png, 
'<i class="server-v-icon" style="background-image: url(' + t + ');">&nbsp;</i>';
}

function buildServerVIcon2(e, t) {
var a = Page.h5_settings.user_verify_info_conf["" + e];
if (!a) return "";
if (a = a[t], !a) return "";
var t = a.icon;
return t = client.isIOS ? a.web_icon_ios : parseFloat(client.osVersion) > 4.4 ? a.web_icon_android : a.icon_png, 
'<div class="server-v-icon-wrap"><i class="server-v-icon" style="background-image: url(' + t + ');">&nbsp;</i></div>';
}

function trans_v_info(e) {
var t = {};
if (Array.isArray(e.type_config)) for (var a = 0; a < e.type_config.length; a++) {
var i = e.type_config[a];
t[i.type] = i;
}
return t;
}

function nz_closest(e, t) {
for (var a = e.matches || e.webkitMatchesSelector || e.mozMatchesSelector || e.msMatchesSelector; e; ) {
if (a.call(e, t)) return e;
e = e.parentElement;
}
return null;
}

function buildScoreByStar(e) {
var t = "";
e = parseInt(e), 0 > e ? e = 0 : e > 10 && (e = 10);
for (var a = 0; 10 > a; a++) {
var i;
a % 2 === 1 && (i = a > e ? "empty" : a === e ? "half" : "full", t += '<span class="score-star ' + i + '"></span>');
}
return t;
}

function buildPage(e) {
function t() {
var t = e.h5_extra, a = {
font_size: t.font_size || "m",
image_type: t.image_type || "thumb",
is_daymode: !!t.is_daymode,
use_lazyload: !!t.use_lazyload,
url_prefix: t.url_prefix || "content://com.ss.android.article.base.ImageProvider/",
group_id: t.str_group_id || t.group_id || ""
};
return a;
}
function a() {
var e = {
font_size: getMeta("font_size") || "m",
image_type: getMeta("load_image") || "thumb",
is_daymode: getMeta("night_mode") ? !1 : !0,
use_lazyload: "undefined" == typeof window.close_lazyload ? !0 : !1,
url_prefix: "undefined" == typeof window.url_prefix ? "content://com.ss.android.article.base.ImageProvider/" : window.url_prefix,
group_id: getMeta("group_id") || ""
};
return e;
}
function i() {
var e = {
font_size: hash("tt_font") || "m",
image_type: hash("tt_image") || "thumb",
is_daymode: "1" == hash("tt_daymode"),
use_lazyload: !!parseInt(getMeta("lazy_load")),
url_prefix: "",
group_id: ""
};
return e;
}
var o = {
v55: {
android: a,
ios: i
},
v60: {
ios: t,
android: t
}
}, n = {
article: {},
author: {},
tags: [],
h5_settings: {},
statistics: {},
pageSettings: {}
}, r = {
getArticleType: function() {
var t = "zhuanma";
if ("object" == typeof e.wenda_extra) t = "wenda"; else if ("object" == typeof e.forum_extra) t = "forum"; else if ("object" == typeof e.h5_extra) {
var a = e.h5_extra.media;
"object" == typeof a && null !== a && 0 != a.id && (t = "pgc");
}
return t;
},
wenda: function() {
var t = e.wenda_extra, a = t.user || {};
e.wenda_extra.title = _.escape(e.wenda_extra.title), n.article = {
title: t.title,
publishTime: t.show_time
}, n.author = {
userId: a.user_id,
name: a.user_name,
link: n.h5_settings.is_liteapp ? "javascript:;" : a.schema + "&group_id=" + t.ansid + "&from_page=detail_answer_wenda",
intro: a.user_intro,
avatar: a.user_profile_image_url,
isAuthorSelf: !1,
verifiedContent: a.is_verify ? "PLACE_HOLDER" : "",
medals: a.medals
};
var i = {
auth_type: "",
auth_info: ""
};
try {
i = JSON.parse(a.user_auth_info);
} catch (o) {}
n.author.auth_type = a.user_auth_info ? i.auth_type || 0 : "", n.author.auth_info = i.auth_info, 
"is_following" in t && (n.author.followState = t.is_following ? "following" : ""), 
n.wenda_extra = t, n.wenda_extra.aniok = client.isSeniorAndroid, n.statistics.group_id = t.ansid;
},
forum: function() {
var t = window.forum_extra, a = e.h5_extra, i = {};
if (n.article = {
title: t.thread_title || "",
publishTime: formatTime(1e3 * t.publish_timestamp)
}, a.user_info) {
if ("string" == typeof a.user_info) try {
i = JSON.parse(a.user_info);
} catch (o) {
i = {};
} else i = a.user_info;
n.author = {
userId: i.user_id,
name: i.screen_name,
link: i.schema + "&group_id=" + t.thread_id + "&from_page=detail_topic" + (a.category_name ? "&from_page=" + a.category_name : ""),
avatar: i.avatar_url,
isAuthorSelf: !!a.is_author,
verifiedContent: i.verified_content,
medals: i.medals,
remarkName: i.remark_name,
followState: i.is_following ? "following" : ""
};
var r = {
auth_type: "",
auth_info: ""
};
try {
r = JSON.parse(i.user_auth_info);
} catch (s) {}
try {
if ("string" == typeof n.author.medals) {
var l = n.author.medals;
l = l.substring(l.indexOf("[") + 1, l.indexOf("]")), l = l.split(","), n.author.medals = [], 
n.author.medals = l.map(function(e) {
return "string" == typeof e ? e.trim() : e;
});
}
} catch (o) {}
n.author.auth_type = i.user_auth_info ? r.auth_type || "0" : "", n.author.auth_info = r.auth_info, 
n.tags = [];
var c = [];
"object" == typeof i.media && i.media.name && c.push(i.media.name), i.verified_content && c.push(i.verified_content), 
n.author.intro = c.join("，");
}
void 0 != a.read_count && (n.read_count = a.read_count), n.use_9_layout = a.use_9_layout, 
n.show_origin = 0 == a.show_origin ? 0 : 1, a.show_tips && (n.show_tips = a.show_tips), 
n.forum_extra = t, a.category_name && (n.category_name = a.category_name), a.log_pb && (n.log_pb = a.log_pb), 
n.forumStatisticsParams = {
value: t.thread_id,
ext_value: t.forum_id,
extra: {
enter_from: a.enter_from,
concern_id: a.concern_id,
refer: a.refer,
group_type: a.group_type,
category_id: a.category_id
}
};
},
pgc: function() {
var t = e.h5_extra, a = t.media || {};
n.article = {
title: t.title,
publishTime: t.publish_stamp ? formatTime(1e3 * t.publish_stamp) : t.publish_time
}, n.author = {
userId: t.media_user_id,
mediaId: a.id,
name: a.name,
link: "sslocal://profile?refer=all&source=article_top_author&uid=" + t.media_user_id + "&group_id=" + n.statistics.group_id + "&from_page=detail_article" + (t.category_name ? "&category_name=" + t.category_name : ""),
intro: a.description,
avatar: a.avatar_url,
isAuthorSelf: !!t.is_author
}, (n.h5_settings.is_liteapp || !t.media_user_id) && (n.author.link = "bytedance://media_account?refer=all&media_id=" + a.id + "&loc=0&entry_id=" + a.id);
var i = {
auth_type: "",
auth_info: ""
};
try {
i = JSON.parse(a.user_auth_info);
} catch (o) {}
n.author.auth_type = a.user_auth_info ? i.auth_type || 0 : "", n.author.auth_info = i.auth_info, 
n.author.verifiedContent = a.user_verified && n.author.auth_info || "", "is_subscribed" in t && (n.author.followState = t.is_subscribed ? "following" : ""), 
t.is_original && n.tags.push("原创"), t.category_name && (n.category_name = t.category_name), 
t.log_pb && (n.log_pb = t.log_pb);
},
zhuanma: function() {
var t = e.h5_extra;
n.article = {
title: t.title,
publishTime: t.publish_time || "0000-00-00 00:00"
}, n.author.name = t.source;
},
common: function() {
var t = e.h5_extra;
if ("custom_style" in e && (n.customStyle = e.custom_style), "novel_data" in t) if ("object" == typeof t.novel_data) n.novel_data = t.novel_data; else if ("string" == typeof t.novel_data) try {
n.novel_data = JSON.parse(t.novel_data);
} catch (a) {}
var i = t.ab_client || [];
n.topbuttonType = "pgc" !== n.article.type || i.indexOf("f7") > -1 ? "concern" : "digg";
try {
n.h5_settings = "object" == typeof t.h5_settings ? t.h5_settings : JSON.parse(t.h5_settings);
} catch (a) {
n.h5_settings = {};
}
n.h5_settings.pgc_over_head = !!n.h5_settings.pgc_over_head && "pgc" === n.article.type, 
n.h5_settings.is_liteapp = !!t.is_lite;
try {
n.isRedFocusButton = "red" === n.h5_settings.tt_follow_button_template.color_style;
} catch (a) {
n.isRedFocusButton = !1;
}
if (n.h5_settings.user_verify_info_conf) {
if ("string" == typeof n.h5_settings.user_verify_info_conf) try {
n.h5_settings.user_verify_info_conf = JSON.parse(n.h5_settings.user_verify_info_conf);
} catch (a) {
n.h5_settings.user_verify_info_conf = {};
}
n.h5_settings.user_verify_info_conf = trans_v_info(n.h5_settings.user_verify_info_conf), 
n.useServerV = !0;
} else n.useServerV = !1;
n.hasExtraSpace = !n.h5_settings.is_liteapp && client.isSeniorAndroid, n.hideFollowButton = !!t.hideFollowButton, 
n.statistics = {
group_id: t.str_group_id || t.group_id || "",
item_id: t.str_item_id || t.item_id || ""
};
}
};
"object" != typeof e && (e = window);
var s = r.getArticleType();
return n.article.type = s, r.common(), window.OldPage && (n.hasExtraSpace = OldPage.hasExtraSpace), 
r[s](), n.pageSettings = o[APP_VERSION][CLIENT_VERSION](), n.article.type = s, n;
}

function buildHeader(e) {
if (e.author && e.author.userId) {
var t = renderHeader({
data: e
}), a = $("header");
a.length <= 0 ? $(document.body).prepend(t) : a.replaceWith(t);
}
}

function buildArticle(e) {
document.body.classList.add(Page.article.type), document.body.classList.add(CLIENT_VERSION), 
document.body.classList.add(APP_VERSION), "string" == typeof e && $("article").html(e), 
"wenda" === Page.article.type && processWendaArticle(), "forum" === Page.article.type && processForumArticle2();
}

function buildFooter(e) {
var t = renderFooter({
data: e
}), a = $("footer");
a.length > 0 ? a.replaceWith(t) : $(document.body).append(t);
}

function processWendaArticle() {
var e, t = Page.wenda_extra, a = t.show_post_answer_strategy || {}, i = t.wd_version || 0, o = Page.h5_settings.is_liteapp, n = "show_top" in a && !o, r = "show_default" in a && !o;
if (window.wendaStatisticsParams = {
value: t.qid,
ext_value: t.nice_ans_count,
extra: {
enter_from: t.enter_from,
ansid: t.ansid,
parent_enterfrom: t.parent_enterfrom || "",
group_id: t.ansid
}
}, window.assignThroughWendaNiceanscount = function(e) {
wendaStatisticsParams.ext_value = e;
}, 1 > i || i >= 3 && 1 == t.showMode) $("header").find(".tt-title").remove(); else {
e = $(n ? '<div class="wt">' + t.title + '</div><div class="ft"><span class="see-all-answers" id="total-answer-count"></span><span class="hide-placeholder">&nbsp;</span></div><a class="big-answer-buttoon go-to-answer" data-type="big" href="' + urlAddQueryParams(a.show_top.schema, {
source: "answer_detail_top_write_answer"
}) + '">' + a.show_top.text + '</a><div class="big-answer-buttoon-gap"></div>' : r ? '<div class="wt">' + t.title + '</div><div class="ft"><a class="go-to-answer go-to-answer-small" data-type="small" href="' + urlAddQueryParams(a.show_default.schema, {
source: "answer_detail_write_answer"
}) + '">回答</a><span class="see-all-answers" id="total-answer-count"></span></div>' : '<div class="wt">' + t.title + '</div><div class="ft"><span class="see-all-answers" id="total-answer-count"></span><span class="hide-placeholder">&nbsp;</span></div>');
var s = n ? "bigans" : r ? "smlans" : "noans";
$("header").find(".tt-title").removeClass("tt-title").addClass("wenda-title " + s + " title-type" + (t.answer_detail_type || 0)).html(e).on("click", function() {
return "wenda_title_handle" in t && t.wenda_title_handle ? void (ToutiaoJSBridge && ToutiaoJSBridge.call("clickWendaDetailHeader")) : void ("need_return" in t ? t.need_return ? ToutiaoJSBridge && ToutiaoJSBridge.call("close") : t.list_schema && (window.location.href = t.list_schema) : [ "click_answer", "click_answer_fold" ].indexOf(t.enter_from) > -1 ? ToutiaoJSBridge && ToutiaoJSBridge.call("close") : t.list_schema && (window.location.href = t.list_schema));
}), new PressState({
bindSelector: ".wenda-title,.big-answer-buttoon",
exceptSelector: ".go-to-answer-small,.see-all-answers",
pressedClass: "pressing",
removeLatency: 500
}), n ? $(".go-to-answer").on("click", function(e) {
e.stopPropagation(), send_umeng_event("answer_detail", "top_write_answer", wendaStatisticsParams);
}) : r && (window.wenda_extra && window.wenda_extra.answer_detail_type && wendaCacheAdd(function() {}), 
$(".go-to-answer").on("click", function(e) {
e.stopPropagation(), send_umeng_event("answer_detail", "wirte_answer", wendaStatisticsParams);
}));
}
$("#wenda_index_link").on("click", function() {
[ "click_answer", "click_answer_fold" ].indexOf(t.enter_from) > -1 ? ToutiaoJSBridge.call("close") : location.href = t.list_schema;
});
}

function processWendaFooter() {
var wenda_extra = Page.wenda_extra, ansStrategy = wenda_extra.show_post_answer_strategy || {}, wdVersion = wenda_extra.wd_version || 0, isLiteApp = Page.h5_settings.is_liteapp;
if (!(1 > wdVersion || wdVersion >= 3 && 1 == wenda_extra.showMode)) {
var isShowBottomUser = 0, wendaUserTmpl = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="wenda-bt-panel"><div class="wenda-bt-user" topbutton-type="' + (null == (__t = data.topbuttonType) ? "" : __t) + '"><div class="authorbar wenda">', 
__p += '<a class="author-avatar-link pgc-link" href="' + (null == (__t = data.author.link) ? "" : __t) + '"><div class="author-avatar"><img class="author-avatar-img" src="' + (null == (__t = data.author.avatar) ? "" : __t) + '"></div>', 
data.useServerV && data.author.auth_info && (__p += "" + (null == (__t = buildServerVIcon2(data.author.auth_type, "avatar_icon")) ? "" : __t)), 
__p += "</a>", __p += '<div class="author-function-buttons"><button class="subscribe-button-bottom follow-button ' + (null == (__t = "followState" in data.author ? data.author.followState : "disabled") ? "" : __t) + " " + (null == (__t = data.isRedFocusButton ? "red-follow-button" : "") ? "" : __t) + '"data-user-id="' + (null == (__t = data.author.userId) ? "" : __t) + '"data-media-id="' + (null == (__t = data.author.mediaId) ? "" : __t) + '"style="display: ' + (null == (__t = data.author.isAuthorSelf || "wenda" === data.article.type && data.h5_settings.is_liteapp || "forum" === data.article.type && "following" === data.author.followState || data.hideFollowButton ? "none" : "block") ? "" : __t) + ';"id="subscribe"><i class="iconfont focusicon">&nbsp;</i><i class="redpack"></i></button></div>', 
__p += '<div class="author-bar ' + (null == (__t = "" !== data.author.intro ? " auth-intro" : "") ? "" : __t) + '"><div class="name-link-wrap"><div class="name-link-w"><a class="author-name-link pgc-link" href="' + (null == (__t = data.author.link) ? "" : __t) + '">' + (null == (__t = data.author.name) ? "" : __t) + "</a></div></div>", 
"" !== data.author.intro && (__p += '<a class="sub-title-w" href="' + (null == (__t = data.author.link) ? "" : __t) + '"><span class="sub-title">' + (null == (__t = data.author.intro) ? "" : __t) + "</span></a>"), 
__p += '<a class="sub-title-w" href="' + (null == (__t = data.author.link) ? "" : __t) + '"><span class="sub-title" id="wenda-user-intro"></span></a></div></div></div></div>';
return __p;
};
if (!Page.author.isAuthorSelf && "following" !== Page.author.followState && "is_show_bottom_user" in wenda_extra && wenda_extra.is_show_bottom_user && $("article").height() > 1.5 * window.innerHeight && !isLiteApp) {
isShowBottomUser = 1;
var wendaUser = wendaUserTmpl({
data: Page
});
$("footer").append(wendaUser).css({
overflow: "initial"
});
}
if (!isShowBottomUser && "show_bottom" in ansStrategy && $("article").height() > 2 * window.innerHeight && !isLiteApp) {
var $btc = $('<a href="' + urlAddQueryParams(ansStrategy.show_bottom.schema, {
source: "answer_detail_bottom_write_answer"
}) + '" class="bottom-big-answer-button"><div class="pr"><div class="wdq"><span>' + wenda_extra.title + '</span></div><div class="bottom-answer-btn"><div class="btn-text"><i>&#xe645;</i>' + ansStrategy.show_bottom.text + '</div></div><i class="left-quote" >&#xe619;</i><i class="right-quote" >&#xe618;</i></div></a>');
$("footer").append($btc).css({
overflow: "initial"
}), $btc.on("click", function() {
sendUmengEventV3("answer_detail_bottom_write_answer", wendaStatisticsParams);
}), send_exposure_event_once($btc.get(0), function() {
sendUmengEventV3("answer_detail_bottom_write_answer_show", wendaStatisticsParams);
}, !0);
}
}
}

function buildUIStyle(settings) {
if ("forum" !== Page.article.type && settings.font_size_ui_test) {
if (1 !== settings.font_size_ui_test && 2 !== settings.font_size_ui_test && 3 !== settings.font_size_ui_test) return;
var CustomStyleTemplateFunction = function(obj) {
var __p = "";
with (Array.prototype.join, obj || {}) __p += "", "1" == plane ? (__p += ".font_s article p, .font_s article h1, .font_s article h2, .font_s article h3, .font_s article h4, .font_s article h5, .font_s article h6, .font_s article ul, .font_s article ol, .font_s article hr, .font_s article .image-wrap {margin-top: 18px;margin-bottom: 18px;}article p, article h1, article h2, article h3, article h4, article h5, article h6, article blockquote, article ul, article ol, article hr, .font_m article p, .font_m article h1, .font_m article h2, .font_m article h3, .font_m article h4, .font_m article h5, .font_m article h6, .font_m article ul, .font_m article ol, .font_m article hr, .font_m article .image-wrap {margin-top: 20px;margin-bottom: 20px;}.font_l article p, .font_l article h1, .font_l article h2, .font_l article h3, .font_l article h4, .font_l article h5, .font_l article h6, .font_l article ul, .font_l article ol, .font_l article hr, .font_s article .image-wrap {margin-top: 22px;margin-bottom: 22px;}.font_xl article p, .font_xl article h1, .font_xl article h2, .font_xl article h3, .font_xl article h4, .font_xl article h5, .font_xl article h6, .font_xl article ul, .font_xl article ol, .font_xl article hr, .font_s article .image-wrap {margin-top: 25px;margin-bottom: 25px;}", 
client.isIOS && (__p += "@media(max-device-width: 374px){.font_s article p, .font_s article h1, .font_s article h2, .font_s article h3, .font_s article h4, .font_s article h5, .font_s article h6, .font_s article ul, .font_s article ol, .font_s article hr, .font_s article .image-wrap {margin-top: 16px;margin-bottom: 16px;}article p, article h1, article h2, article h3, article h4, article h5, article h6, article blockquote, article ul, article ol, article hr, .font_m article p, .font_m article h1, .font_m article h2, .font_m article h3, .font_m article h4, .font_m article h5, .font_m article h6, .font_m article ul, .font_m article ol, .font_m article hr, .font_m article .image-wrap {margin-top: 18px;margin-bottom: 18px;}.font_l article p, .font_l article h1, .font_l article h2, .font_l article h3, .font_l article h4, .font_l article h5, .font_l article h6, .font_l article ul, .font_l article ol, .font_l article hr, .font_s article .image-wrap {margin-top: 20px;margin-bottom: 20px;}.font_xl article p, .font_xl article h1, .font_xl article h2, .font_xl article h3, .font_xl article h4, .font_xl article h5, .font_xl article h6, .font_xl article ul, .font_xl article ol, .font_xl article hr, .font_s article .image-wrap {margin-top: 23px;margin-bottom: 23px;}}"), 
__p += "") : "2" == plane ? (__p += "", __p += client.isIOS ? ".font_s article, .font_s article h1, .font_s article h2, .font_s article h3, .font_s article h4, .font_s article h5, .font_s article h6 {line-height: 28px;}article, article h1, article h2, article h3, article h4, article h5, article h6, .font_m article, .font_m article h1, .font_m article h2, .font_m article h3, .font_m article h4, .font_m article h5, .font_m article h6 {line-height: 30px;}.font_l article, .font_l article h1, .font_l article h2, .font_l article h3, .font_l article h4, .font_l article h5, .font_l article h6 {line-height: 32px;}.font_xl article, .font_xl article h1, .font_xl article h2, .font_xl article h3, .font_xl article h4, .font_xl article h5, .font_xl article h6 {line-height: 35px;}@media(max-device-width: 374px){.font_s article, .font_s article h1, .font_s article h2, .font_s article h3, .font_s article h4, .font_s article h5, .font_s article h6 {line-height: 23px;}article, article h1, article h2, article h3, article h4, article h5, article h6, .font_m article, .font_m article h1, .font_m article h2, .font_m article h3, .font_m article h4, .font_m article h5, .font_m article h6 {line-height: 25px;}.font_l article, .font_l article h1, .font_l article h2, .font_l article h3, .font_l article h4, .font_l article h5, .font_l article h6 {line-height: 27px;}.font_xl article, .font_xl article h1, .font_xl article h2, .font_xl article h3, .font_xl article h4, .font_xl article h5, .font_xl article h6 {line-height: 30px;}}" : ".font_s article, .font_s article h1, .font_s article h2, .font_s article h3, .font_s article h4, .font_s article h5, .font_s article h6 {line-height: 26px;}article, article h1, article h2, article h3, article h4, article h5, article h6, .font_m article, .font_m article h1, .font_m article h2, .font_m article h3, .font_m article h4, .font_m article h5, .font_m article h6 {line-height: 28px;}.font_l article, .font_l article h1, .font_l article h2, .font_l article h3, .font_l article h4, .font_l article h5, .font_l article h6 {line-height: 30px;}.font_xl article, .font_xl article h1, .font_xl article h2, .font_xl article h3, .font_xl article h4, .font_xl article h5, .font_xl article h6 {line-height: 33px;}", 
__p += "") : "3" == plane && (__p += "", __p += client.isIOS ? ".font_s article, .font_s article h1, .font_s article h2, .font_s article h3, .font_s article h4, .font_s article h5, .font_s article h6 {line-height: 28px;}article, article h1, article h2, article h3, article h4, article h5, article h6, .font_m article, .font_m article h1, .font_m article h2, .font_m article h3, .font_m article h4, .font_m article h5, .font_m article h6 {line-height: 30px;}.font_l article, .font_l article h1, .font_l article h2, .font_l article h3, .font_l article h4, .font_l article h5, .font_l article h6 {line-height: 32px;}.font_xl article, .font_xl article h1, .font_xl article h2, .font_xl article h3, .font_xl article h4, .font_xl article h5, .font_xl article h6 {line-height: 35px;}.font_s article p, .font_s article h1, .font_s article h2, .font_s article h3, .font_s article h4, .font_s article h5, .font_s article h6, .font_s article ul, .font_s article ol, .font_s article hr, .font_s article .image-wrap {margin-top: 18px;margin-bottom: 18px;}article p, article h1, article h2, article h3, article h4, article h5, article h6, article blockquote, article ul, article ol, article hr, .font_m article p, .font_m article h1, .font_m article h2, .font_m article h3, .font_m article h4, .font_m article h5, .font_m article h6, .font_m article ul, .font_m article ol, .font_m article hr, .font_m article .image-wrap {margin-top: 20px;margin-bottom: 20px;}.font_l article p, .font_l article h1, .font_l article h2, .font_l article h3, .font_l article h4, .font_l article h5, .font_l article h6, .font_l article ul, .font_l article ol, .font_l article hr, .font_s article .image-wrap {margin-top: 22px;margin-bottom: 22px;}.font_xl article p, .font_xl article h1, .font_xl article h2, .font_xl article h3, .font_xl article h4, .font_xl article h5, .font_xl article h6, .font_xl article ul, .font_xl article ol, .font_xl article hr, .font_s article .image-wrap {margin-top: 25px;margin-bottom: 25px;}@media(max-device-width: 374px){.font_s article, .font_s article h1, .font_s article h2, .font_s article h3, .font_s article h4, .font_s article h5, .font_s article h6 {line-height: 23px;}article, article h1, article h2, article h3, article h4, article h5, article h6, .font_m article, .font_m article h1, .font_m article h2, .font_m article h3, .font_m article h4, .font_m article h5, .font_m article h6 {line-height: 25px;}.font_l article, .font_l article h1, .font_l article h2, .font_l article h3, .font_l article h4, .font_l article h5, .font_l article h6 {line-height: 27px;}.font_xl article, .font_xl article h1, .font_xl article h2, .font_xl article h3, .font_xl article h4, .font_xl article h5, .font_xl article h6 {line-height: 30px;}.font_s article p, .font_s article h1, .font_s article h2, .font_s article h3, .font_s article h4, .font_s article h5, .font_s article h6, .font_s article ul, .font_s article ol, .font_s article hr, .font_s article .image-wrap {margin-top: 16px;margin-bottom: 16px;}article p, article h1, article h2, article h3, article h4, article h5, article h6, article blockquote, article ul, article ol, article hr, .font_m article p, .font_m article h1, .font_m article h2, .font_m article h3, .font_m article h4, .font_m article h5, .font_m article h6, .font_m article ul, .font_m article ol, .font_m article hr, .font_m article .image-wrap {margin-top: 18px;margin-bottom: 18px;}.font_l article p, .font_l article h1, .font_l article h2, .font_l article h3, .font_l article h4, .font_l article h5, .font_l article h6, .font_l article ul, .font_l article ol, .font_l article hr, .font_s article .image-wrap {margin-top: 20px;margin-bottom: 20px;}.font_xl article p, .font_xl article h1, .font_xl article h2, .font_xl article h3, .font_xl article h4, .font_xl article h5, .font_xl article h6, .font_xl article ul, .font_xl article ol, .font_xl article hr, .font_s article .image-wrap {margin-top: 23px;margin-bottom: 23px;}}" : ".font_s article, .font_s article h1, .font_s article h2, .font_s article h3, .font_s article h4, .font_s article h5, .font_s article h6 {line-height: 26px;}article, article h1, article h2, article h3, article h4, article h5, article h6, .font_m article, .font_m article h1, .font_m article h2, .font_m article h3, .font_m article h4, .font_m article h5, .font_m article h6 {line-height: 28px;}.font_l article, .font_l article h1, .font_l article h2, .font_l article h3, .font_l article h4, .font_l article h5, .font_l article h6 {line-height: 30px;}.font_xl article, .font_xl article h1, .font_xl article h2, .font_xl article h3, .font_xl article h4, .font_xl article h5, .font_xl article h6 {line-height: 33px;}.font_s article p, .font_s article h1, .font_s article h2, .font_s article h3, .font_s article h4, .font_s article h5, .font_s article h6, .font_s article ul, .font_s article ol, .font_s article hr, .font_s article .image-wrap {margin-top: 18px;margin-bottom: 18px;}article p, article h1, article h2, article h3, article h4, article h5, article h6, article blockquote, article ul, article ol, article hr, .font_m article p, .font_m article h1, .font_m article h2, .font_m article h3, .font_m article h4, .font_m article h5, .font_m article h6, .font_m article ul, .font_m article ol, .font_m article hr, .font_m article .image-wrap {margin-top: 20px;margin-bottom: 20px;}.font_l article p, .font_l article h1, .font_l article h2, .font_l article h3, .font_l article h4, .font_l article h5, .font_l article h6, .font_l article ul, .font_l article ol, .font_l article hr, .font_s article .image-wrap {margin-top: 22px;margin-bottom: 22px;}.font_xl article p, .font_xl article h1, .font_xl article h2, .font_xl article h3, .font_xl article h4, .font_xl article h5, .font_xl article h6, .font_xl article ul, .font_xl article ol, .font_xl article hr, .font_s article .image-wrap {margin-top: 25px;margin-bottom: 25px;}", 
__p += ""), __p += "";
return __p;
}, CustomStyleTemplateString = CustomStyleTemplateFunction({
plane: settings.font_size_ui_test,
client: client
}), originStyle = document.querySelector("head").querySelectorAll("style[source=abtest]");
if (0 === originStyle.length) {
var style = document.createElement("style");
style.setAttribute("source", "abtest"), style.setAttribute("plane", "plane" + settings.font_size_ui_test), 
style.innerHTML = CustomStyleTemplateString, document.querySelector("head").appendChild(style), 
style = null;
} else for (var i = 0; i < originStyle.length; i++) {
var item = originStyle[i];
if (item.getAttribute("plane") === "plane" + settings.font_size_ui_test) return;
item.setAttribute("plane", "plane" + settings.font_size_ui_test), item.innerHTML = CustomStyleTemplateString;
}
} else $("style[source=abtest]").remove();
}

function update_forum_tags(e) {
"string" == typeof e && (e = e.split(","));
var t = $('<div class="article-tags">');
e.forEach(function(e) {
"" !== e && t.append($('<div class="article-tag">').html(e));
}), e.length >= 1 ? $(".name-link-w").removeClass("no-intro") : "" === $(".sub-title").text() && $(".name-link-w").addClass("no-intro"), 
$(".article-tags").replaceWith(t);
}

function on_page_disappear() {
"object" == typeof window.mediasugScroll && null !== window.mediasugScroll && "function" == typeof window.mediasugScroll.pushimpr && window.mediasugScroll.pushimpr(!1);
}

function set_info(e) {
if ("string" == typeof e) e = JSON.parse(e); else if ("object" != typeof e) return;
$.extend(window.globalWendaStates, e), "is_concern_user" in e && change_following_state(!!e.is_concern_user), 
"brow_count" in e && ($(".brow-count").text(e.brow_count), formatCount(".brow-count", e.brow_count, "0")), 
"is_digg" in e && "digg_count" in e && (e.is_digg && $("#digg").attr({
"wenda-state": "digged",
aniok: "false"
}), formatCount(".digg-count", e.digg_count, "赞"), formatCount(".digg-count-special", e.digg_count, "0")), 
"is_buryed" in e && "bury_count" in e && (e.is_buryed && $("#bury").attr({
"wenda-state": "buryed",
aniok: "false"
}), formatCount(".bury-count", e.bury_count, "踩")), "is_show_bury" in e && e.is_show_bury && $("#bury").show().parent().removeClass("only-one").addClass("only-two");
}

function getElementPosition(e) {
var t = /^.image:nth-child\((\d+)\)$/, a = e.match(t);
a && (e = ".image-container:nth-child(" + a[1] + ")>.image");
var i = "{{0,0},{0,0}}", o = document.querySelector(e);
if (o) {
var n = o.getBoundingClientRect();
i = "{{" + (n.left + window.pageXOffset) + "," + (n.top + window.pageYOffset) + "},{" + n.width + "," + n.height + "}}";
}
return i;
}

function setFontSize(e) {
var t = e.split("_")[0], a = (e.split("_")[1], [ "s", "m", "l", "xl" ]), i = $.map(a, function(e) {
return "font_" + e;
}).join(" ");
a.indexOf(t) > -1 && $("body").removeClass(i).addClass("font_" + t);
}

function setDayMode(e) {
var t = [ 0, 1, "0", "1" ];
if (t.indexOf(e) > -1) {
e = parseInt(e), $(document.body)[e ? "removeClass" : "addClass"]("night");
try {
$(document).trigger("dayModeChange", e);
} catch (a) {}
}
}

function appCloseVideoNoticeWeb(e) {
var t = $('[data-vid="' + e + '"]');
t.each(function() {
$(this).css("display", "block"), $(this).next(".cv-wd-info-wrapper").show();
}), $("body").css("margin-top", "0px");
}

function getVideoFrame(e) {
var t = document.querySelector('[data-vid="' + e + '"]'), a = "{{0,0},{0,0}}";
if (t) {
var i = t.getBoundingClientRect();
a = "{{" + i.left + "," + t.offsetTop + "},{" + i.width + "," + i.height + "}}";
}
return a;
}

function processMenuItemPressEvent() {
ToutiaoJSBridge.call("typos", {
strings: getThreeStrings()
});
}

function getThreeStrings() {
var e = "", t = "", a = "", i = document.getSelection();
if ("Range" !== i.type) return [ e, t, a ];
var o = i.getRangeAt(0);
if (!o) return [ e, t, a ];
try {
e = o.startContainer.textContent.substring(0, o.startOffset).substr(-20), t = o.toString(), 
a = o.endContainer.textContent.substring(o.endOffset).substring(0, 20);
} catch (n) {}
return o.detach(), o = null, [ e, t, a ];
}

function subscribe_switch(e) {
"pgc" == Page.article.type && change_following_state(!!e);
}

function dealNovelButton(e, t, a, i) {
return e.preventDefault(), t.is_concerned ? (sendUmengEventV3("click_enter_bookshelf", {
novel_id: t.book_id,
group_id: Page.statistics.group_id,
item_id: Page.statistics.item_id
}, 0), void (location.href = t.bookshelf_url)) : (send_umeng_event("detail", "click_fictioncard_care", i), 
ToutiaoJSBridge.call("addChannel", {
category: "novel_channel",
web_url: "https://ic.snssdk.com/novel_channel/",
name: "小说",
type: 5,
flags: 1
}), void $.ajax({
url: "https://ic.snssdk.com/novel/book/bookshelf/v1/" + (t.is_concerned ? "delete/" : "add/"),
dataType: "jsonp",
data: {
book_id: t.book_id
},
beforeSend: function() {
return t.isclicking ? !1 : void (t.isclicking = !0);
},
complete: function() {
t.isclicking = !1;
},
error: function() {
ToutiaoJSBridge.call("toast", {
text: "操作失败，请重试",
icon_type: "icon_error"
});
},
success: function(e) {
return 0 != e.code ? (ToutiaoJSBridge.call("toast", {
text: "操作失败，请重试",
con_type: "icon_error"
}), !1) : (t.is_concerned = !t.is_concerned, a.attr("is-concerned", Boolean(t.is_concerned)).html(t.is_concerned ? "查看书架" : "加入书架"), 
ToutiaoJSBridge.call("page_state_change", {
type: "concern_action",
id: t.concern_id,
status: t.is_concerned ? 1 : 0
}), ToutiaoJSBridge.call("page_state_change", {
type: "forum_action",
id: t.forum_id,
status: t.is_concerned ? 1 : 0
}), send_umeng_event(t.is_concerned ? "concern_novel" : "unconcern_novel", "detail", {
value: Page.statistics.group_id,
extra: {
item_id: Page.statistics.item_id,
novel_id: t.id
}
}), void sendUmengEventV3(t.is_concerned ? "concern_novel_detail" : "unconcern_novel_detail", {
item_id: +Page.statistics.item_id,
group_id: +Page.statistics.group_id,
novel_id: t.id
}, !0));
}
}));
}

function dealOptionalStockButton(e, t, a, i, o) {
e.stopPropagation(), send_umeng_event("stock", "article_add_stock", o);
var n, r = 0, s = t.attr("data-stock"), l = 0;
i.forEach(function(e, t) {
e.code == s && (l = t, n = e.market), 0 == e.selected && r++;
}), 1 != i[l].selected && $.ajax({
url: "http://ic.snssdk.com/stock/like/",
dataType: "jsonp",
data: {
code: s,
market: n
},
beforeSend: function() {
return i[l].isclicking || 1 == i[l].selected ? !1 : void (i[l].isclicking = !0);
},
complete: function() {
i[l].isclicking = !1;
},
error: function() {
ToutiaoJSBridge.call("toast", {
text: "操作失败，请重试",
icon_type: "icon_error"
});
},
success: function(e) {
return 1 != e.code ? (ToutiaoJSBridge.call("toast", {
text: 0 == e.code && e.data.msg ? e.data.msg : "操作失败，请重试",
con_type: "icon_error"
}), !1) : (a.stocks.click_mount++, "single" === t.attr("type") ? t.attr("selected", "") : (t.removeClass("pcard-w1").addClass("pcard-w3").html('<i class="pcard-icon opstock-iconfont icon-done"></i>已添加'), 
r > 3 && (t.css("height", 0), $parent = t.parent(), $parent.on("webkitAnimationEnd", function() {
$parent.remove();
}), $parent.on("animationend", function() {
$parent.remove();
}), $parent.addClass("ant-notification-fade-leave"))), void (i[l].selected = !0));
}
});
}

function wendaCooperateCard() {
var cooperateCardTmpl = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="wenda-panel-co"><div class="wenda-cooperate"><div class="authorbar wenda clearfix"><a class="author-avatar-link pgc-link" href="' + (null == (__t = data.author.link) ? "" : __t) + '"><div class="author-avatar"><img class="author-avatar-img" src="' + (null == (__t = data.author.avatar) ? "" : __t) + '"></div>', 
data.useServerV && data.author.auth_info && (__p += "" + (null == (__t = buildServerVIcon2(data.author.auth_type, "avatar_icon")) ? "" : __t)), 
__p += "</a>", data.showUserDecoration && data.author.user_decoration && data.author.user_decoration.url && (__p += '<div class="avatar-decoration" style="background-image: url(' + (null == (__t = data.author.user_decoration.url) ? "" : __t) + ')"></div>'), 
__p += '<div class="avatar-decoration avatar-night-mask"></div><div class="author-bar"><div class="name-link-wrap"><div class="name-link-w"><a class="author-name-link pgc-link" href="' + (null == (__t = data.author.link) ? "" : __t) + '">' + (null == (__t = data.author.name) ? "" : __t) + '<span class="cooper-tag">问答战略合作伙伴</span></a></div></div><a class="sub-title-w" href="' + (null == (__t = data.author.link) ? "" : __t) + '"><span class="sub-title">' + (null == (__t = data.author.cooperate_text) ? "" : __t) + '</span></a></div></div><a class="cooperate-link" href="' + (null == (__t = data.author.cooperate_link) ? "" : __t) + '"><span class="txt">查看官方网站<em class="iconfont">&#xe644;</em></span></a></div></div>';
return __p;
};
$.extend(Page.author, {
cooperate_text: wenda_extra.mis_coop_user.profile,
cooperate_link: -1 !== wenda_extra.mis_coop_user.link.indexOf("http") ? "sslocal://webview?url=" + encodeURIComponent(wenda_extra.mis_coop_user.link) + "&title=%E7%BD%91%E9%A1%B5%E6%B5%8F%E8%A7%88" : wenda_extra.mis_coop_user.link
});
var cooperateStr = cooperateCardTmpl({
data: Page
});
$("footer").append(cooperateStr).css({
overflow: "initial"
});
}

function WendaRuleTip(e) {
var t;
if (e && e.show_tips && e.text && e.schema) {
t = $('<div class="answer-tips"><div class="line-gap"></div><p class="tip-text"><a class="tip-link" style="" href="' + e.schema + '">' + e.text + '</a></p><div class="line-border"></div></div>'), 
$("header").find(".wenda-title").after(t), $("header").find(".wenda-title .ft").addClass("hide-border");
var a = {
group_id: Page.statistics.group_id,
user_id: Page.author.userId,
tips_from: e.tips_from || "",
tips_type: e.tips_type || ""
}, i = setInterval(function() {
window.wenda_extra.gd_ext_json && (clearInterval(i), a = $.extend(a, window.wenda_extra.gd_ext_json), 
sendUmengEventV3("answer_detail_guide_show", a));
}, 100);
t.on("click", ".tip-link", function() {
sendUmengEventV3("answer_detail_guide_click", a);
});
}
}

function wendaContextRender(context) {
!function() {
if ("wenda_context" in context) {
var e = context.wenda_context;
if (window.wendaContext = e, "is_author" in e && (e.is_author ? ($(".follow-button").hide(), 
$(".author-function-buttons").hide(), $(".wenda-info").show()) : "wenda" === Page.article.type && Page.h5_settings.is_liteapp ? ($(".follow-button").hide(), 
$(".author-function-buttons").hide(), $(".wenda-info").hide()) : ($(".author-function-buttons").show(), 
$(".follow-button").show(), $(".wenda-info").hide())), "is_author" in e && e.is_author ? (Page.author.isAuthorSelf = !!e.is_author, 
$(".wd-footer .editor-edit-answer").attr("href", e.edit_answer_schema).show(), $(".wd-footer .dislike-and-report").hide()) : ($(".wd-footer .editor-edit-answer").hide(), 
"detail_related_report_style" in wenda_extra && 0 !== wenda_extra.detail_related_report_style && wenda_extra.wd_version >= 13 ? $(".wd-footer .dislike-and-report").hide() : $(".wd-footer .dislike-and-report").show()), 
"is_author" in e && e.is_author || ("detail_related_report_style" in wenda_extra && (2 === wenda_extra.detail_related_report_style || 3 === wenda_extra.detail_related_report_style) && wenda_extra.wd_version >= 13 ? ($(".report").hide(), 
$(".sep.for-report").hide()) : ($(".report").show(), "detail_related_report_style" in wenda_extra && 1 === wenda_extra.detail_related_report_style && wenda_extra.wd_version >= 13 ? $(".report").removeClass("no-icon") : $(".sep.for-report").show())), 
"brow_count" in e && ($(".brow-count").text(e.brow_count), formatCount(".brow-count", e.brow_count, "0")), 
"all_brow_count" in e || "fans_count" in e) {
var t = [];
"all_brow_count" in e && t.push(formatCount(!1, e.all_brow_count, "0") + "阅读"), 
"fans_count" in e && t.push(formatCount(!1, e.fans_count, "0") + "粉丝"), t.length > 0 && setTimeout(function() {
$("#wenda-user-intro").html(t.join(" · "));
}, 50);
}
if ("linkurl" in e && e.linkurl && $("#wd-link-more").attr("href", "sslocal://webview?url=" + encodeURIComponent(e.linkurl) + "&title=%E7%BD%91%E9%A1%B5%E6%B5%8F%E8%A7%88").show(), 
"is_digg" in e && "digg_count" in e && (e.is_digg && $("#digg").attr({
"wenda-state": "digged",
aniok: "false"
}), formatCount(".digg-count", e.digg_count, "赞"), formatCount(".digg-count-special", e.digg_count, "0")), 
"is_buryed" in e && "bury_count" in e && (e.is_buryed && $("#bury").attr({
"wenda-state": "buryed",
aniok: "false"
}), formatCount(".bury-count", e.bury_count, "踩"), e.is_buryed && $(".dislike-and-report").css("color", "#999999").text("已反对"), 
wenda_extra.wd_version >= 6)) {
var a = e.is_buryed;
$('[item="dislike-and-report"]').on("click", function() {
var e = this;
ToutiaoJSBridge.call("dislike", {
options: 17
}, function(t) {
0 == t.err_no && (a ? wenda_extra.wd_version >= 8 && ($(e).removeClass("is-buryed"), 
e.innerHTML = "反对", a = !a) : ($(e).addClass("is-buryed"), e.innerHTML = "已反对", 
a = !a));
});
});
}
if ("is_show_bury" in e && e.is_show_bury && $("#bury").show().parent().removeClass("only-one").addClass("only-two"), 
"is_concern_user" in e && change_following_state(!!e.is_concern_user), "ans_count" in e && ($("#total-answer-count").html(e.ans_count + "个回答").css("display", "inline-block"), 
$("#total-answer-count-index").html("全部" + e.ans_count + "个回答")), "nice_ans_count" in e && "wenda_extra" in window && ("function" == typeof window.assignThroughWendaNiceanscount ? window.assignThroughWendaNiceanscount(e.nice_ans_count) : window.wenda_extra.nice_ans_count = e.nice_ans_count), 
"question_schema" in e && e.question_schema && (window.wenda_extra.list_schema = e.question_schema), 
"post_answer_schema" in e && e.post_answer_schema && $(".go-to-answer").attr("href", urlAddQueryParams(e.post_answer_schema, {
source: "big" === $(".go-to-answer").attr("data-type") ? "answer_detail_top_write_answer" : "answer_detail_write_answer"
})), "is_following" in e && Page && Page.author && (Page.author.followState = e.is_following ? "following" : ""), 
"has_profit" in e && e.has_profit && Page.wenda_extra.showBigAns && !Page.wenda_extra.disable_profit && $(".go-to-answer").text("写回答，得红包").addClass("red_packet_wd"), 
"gd_ext_json" in e) {
var i = e.gd_ext_json || {};
if ("string" == typeof e.gd_ext_json) try {
i = JSON.parse(e.gd_ext_json);
} catch (o) {
i = {};
}
window.wenda_extra.gd_ext_json = i, "category_name" in i && "wenda" === Page.article.type && (Page.author.link = Page.author.link + "&category_name=" + i.category_name, 
$(".author-avatar-link").attr("href", Page.author.link), $(".author-name-link").attr("href", Page.author.link), 
$(".sub-title-w").attr("href", Page.author.link));
}
if (WendaRuleTip(e.tips_data || {}), (!("show_next" in e) || e.show_next) && ($(".serial").show(), 
"has_next" in e)) {
var n = $("#next_answer_link");
e.has_next ? (n.attr("href", e.next_answer_schema), n.attr("onclick", null)) : (n.attr("onclick", null), 
n.addClass("disabled").on("click", function() {
ToutiaoJSBridge.call("toast", {
text: "这是最后一个回答",
icon_type: ""
});
}), needCleanDoms.push(n));
}
}
}(), function() {
if ("wenda_recommend" in context && Page.wenda_extra) {
var templateFunction = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<a class="jrwdpd" href="' + (null == (__t = data.open_url) ? "" : __t) + '"><div class="jrwdpd-slogan">' + (null == (__t = data.text) ? "" : __t) + '</div><button class="jrwdpd-button">' + (null == (__t = data.button_text) ? "" : __t) + '</button><div class="jrwdpd-logo"></div><div class="jrwdpd-logo-wrap"></div></a>';
return __p;
}, $template = $(templateFunction({
data: context.wenda_recommend
}));
$("footer").append($template), $template.on("click", function() {
send_umeng_event("wenda_channel_detail", "enter", {
extra: {
qid: Page.wenda_extra.qid,
ansid: Page.wenda_extra.ansid,
enter_from: Page.wenda_extra.enter_from,
parent_enterfrom: Page.wenda_extra.parent_enterfrom || ""
}
});
}), needCleanDoms.push($template);
}
}(), function() {
var e = document.querySelector("#profile"), t = document.querySelector(".wenda-title"), a = 0, i = 0;
t && (a = t.getBoundingClientRect().height), e && (i = e.getBoundingClientRect().height + 20 + a), 
ToutiaoJSBridge.call("onGetHeaderAndProfilePosition", {
header_position: a,
profile_position: i
});
}(), wendaCacheRemove();
}

function processScoreCardByStar(networkCommonParams) {
var scoredArticle, scoreCardTemplateFunction = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="pcard score-star" style="margin-top: 15px;"><div class="p-scorecard pcard-container pcard-vertical-border"><div class="pcard-clearfix score-wrapper"><div class="info-wrapper"><div class="title question pcard-h16 pcard-w1" style="margin-top: 3px;">' + (null == (__t = question) ? "" : __t) + '</div><div class="title thx-letter pcard-h16 pcard-w1" style="margin-top: 2px;">谢谢你为文章打分！</div></div><div class="star-wrap mt11"><span class="star" data-index="0" data-selected="false"></span><span class="star" data-index="1" data-selected="false"></span><span class="star" data-index="2" data-selected="false"></span><span class="star" data-index="3" data-selected="false"></span><span class="star" data-index="4" data-selected="false"></span></div><div class="info pcard-h12 pcard-w1 mt11" style="margin-bottom: 3px;">轻触打分</div></div><div class="pcard-clearfix result-wrapper"><div class="thx-press" style="margin-top: 2px;"><span class="press"></span></div><div class="pcard-h16 pcard-w1 mt8">感谢你的打分，你的打分对我们很重要！</div><a class="rescore-button pcard-h12 pcard-w1">重新打分</a></div></div></div>';
return __p;
};
try {
scoredArticle = localStorage.getItem("article_detail_score");
} catch (e) {}
var group_id = Page.statistics.group_id, score_card_info_string = parseInt(Page.h5_settings.score_card_info_string);
score_card_info_string = score_card_info_string > -1 && 5 > score_card_info_string ? score_card_info_string : 0;
var startTime, lastTimeOutThx, lastTimeOutDone, starQuestions = [ "为文章打分", "这篇文章是否有价值？", "你后悔看过本文吗？", "本文是否浪费了你的时间？", "与其他文章相比，你觉得本文如何？" ], starInfo = [ "轻触打分", "浪费时间", "后悔点进来", "没什么感觉", "比较受益", "非常受益" ], $template = $(scoreCardTemplateFunction({
question: starQuestions[score_card_info_string]
})), $stars = $template.find(".star"), score = 0, has_scored = !1;
$template.on("touchstart", ".star", function(e) {
var t = parseInt(e.target.getAttribute("data-index"));
e.target.getAttribute("data-selected"), $stars.forEach(function(e, a) {
t >= a ? e.setAttribute("data-selected", "true") : e.setAttribute("data-selected", "false");
}), score = t + 1, document.querySelector(".info").innerHTML = starInfo[score], 
lastTimeOutThx && clearTimeout(lastTimeOutThx), lastTimeOutDone && clearTimeout(lastTimeOutDone), 
lastTimeOutThx = setTimeout(function() {
$(".info-wrapper").addClass("move");
}, 500), $(".info-wrapper").addClass("move"), lastTimeOutDone = setTimeout(function() {
var e = {
evaluate_id: JSON.stringify({
gid: group_id,
style: "star",
string_id: score_card_info_string,
interval: Date.now() - startTime
}),
survey_type: "point",
prefer_id: score
};
if ($.extend(!0, e, networkCommonParams), $.ajax({
url: "https://eva.snssdk.com/eva/survey.json",
dataType: "jsonp",
data: e,
error: function() {},
success: function() {}
}), !has_scored) {
scoredArticle = scoredArticle ? scoredArticle + "," + group_id : group_id;
try {
localStorage.setItem("article_detail_score", scoredArticle);
} catch (t) {}
has_scored = !0;
}
$(".p-scorecard").addClass("moveUp"), send_umeng_event("score_card", "click", {
value: group_id,
extra: {
score: score,
interval: Date.now() - startTime
}
});
}, 1500);
}), $template.on("click", ".rescore-button", function() {
$(".info-wrapper").removeClass("move"), $(".p-scorecard").removeClass("moveUp"), 
$stars.forEach(function(e) {
e.setAttribute("data-selected", "false");
}), score = 0, document.querySelector(".info").innerHTML = starInfo[score];
}), $("footer").append($template), send_exposure_event_once($template.get(0), function() {
startTime = Date.now(), send_umeng_event("score_card", "show", {
value: group_id,
extra: {
style: "star"
}
});
}, !0);
}

function processScoreCardByEmoji(networkCommonParams) {
var scoredArticle, scoreCardTemplateFunction = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="pcard score-emoji ' + (null == (__t = 5 == style ? "has-title" : "") ? "" : __t) + '" style="margin-top: 15px"><div class="p-scorecard pcard-container ' + (null == (__t = 2 == style || 5 == style ? "pcard-vertical-top-border" : "") ? "" : __t) + ' "><div class="pcard-clearfix score-wrapper">', 
(2 == style || 5 == style) && (__p += '<div class="title question pcard-h16 pcard-w1" style="margin-top: 3px;">与其他文章相比，您觉得本文如何？</div>'), 
__p += '<div class="emoji-wrap mt10"><div class="good emoji-button ' + (null == (__t = 3 == style ? "color-bg" : 4 == style || 5 == style ? "grey-bg" : "") ? "" : __t) + '" data-index="0" data-score="5" data-type="good" data-status="init"><span class="pcard-icon good-press button">', 
(3 == style || 4 == style || 5 == style) && (__p += '<span class="press"></span>'), 
__p += '</span><div class="animation-wrapper" id="good-press-animation"></div><div class="pcard-h12 title">' + (null == (__t = letters[0]) ? "" : __t) + '</div></div><div class="general emoji-button ' + (null == (__t = 3 == style ? "color-bg" : 4 == style || 5 == style ? "grey-bg" : "") ? "" : __t) + '" data-index="1" data-score="3" data-type="general" data-status="init"><span class="pcard-icon general-press button">', 
(3 == style || 4 == style || 5 == style) && (__p += '<span class="press"></span>'), 
__p += '</span><div class="animation-wrapper" id="general-press-animation"></div><div class="pcard-h12 title">' + (null == (__t = letters[1]) ? "" : __t) + '</div></div><div class="bad emoji-button ' + (null == (__t = 3 == style ? "color-bg" : 4 == style || 5 == style ? "grey-bg" : "") ? "" : __t) + '" data-index="2" data-score="1" data-type="bad" data-status="init"><span class="pcard-icon bad-press button">', 
(3 == style || 4 == style || 5 == style) && (__p += '<span class="press"></span>'), 
__p += '</span><div class="animation-wrapper" id="bad-press-animation"></div><div class="pcard-h12 title">' + (null == (__t = letters[2]) ? "" : __t) + '</div></div></div></div><div class="pcard-clearfix result-wrapper ' + (null == (__t = 5 == style ? "pcard-vertical-bottom-border" : "") ? "" : __t) + '"><div class="pcard-clearfix"><div class="thx-press" style="margin-top: 2px;"><span id="thx-press-emoji"></span></div><div class="pcard-h16 pcard-w1 mt10" id="thx-word">感谢你的打分，你的打分对我们很重要！</div><a class="rescore-button pcard-h14 ' + (null == (__t = 5 == style ? "pcard-vertical-bottom-border rescore-button-with-bottom" : "") ? "" : __t) + '">重新评价</a></div></div></div></div>';
return __p;
};
try {
scoredArticle = localStorage.getItem("article_detail_score");
} catch (e) {}
var lastTimeOutDone, group_id = Page.statistics.group_id, last_score = -1, score_card_info_string = parseInt(Page.h5_settings.score_card_info_string) || 0;
score_card_info_string = score_card_info_string > -1 && 3 > score_card_info_string ? score_card_info_string : 0;
var startTime, letters = [ [ "非常受益", "一般般", "浪费时间" ], [ "很有帮助", "一般般", "没有帮助" ], [ "很棒的文章", "一般般", "很差的文章" ] ], has_scored = !1, $template = $(scoreCardTemplateFunction({
letters: letters[score_card_info_string],
style: Page.h5_settings.score_card_style
})), $emojiButtons = $template.find(".emoji-button"), emojiAnimationArray = [ null, null, null ];
$template.on("click", ".emoji-button", function(e) {
var t = $(e.target).closest(".emoji-button"), a = parseInt(t.attr("data-score"));
if (a !== last_score) {
var i = t.attr("data-type"), o = parseInt(t.attr("data-index")), n = {
evaluate_id: JSON.stringify({
gid: group_id,
style: "face",
string_id: score_card_info_string,
interval: Date.now() - startTime
}),
survey_type: "point",
prefer_id: a
};
if ($.extend(!0, n, networkCommonParams), $.ajax({
url: "https://eva.snssdk.com/eva/survey.json",
dataType: "jsonp",
data: n,
error: function() {},
success: function() {}
}), !has_scored) {
scoredArticle = scoredArticle ? scoredArticle + "," + group_id : group_id;
try {
localStorage.setItem("article_detail_score", scoredArticle);
} catch (r) {}
has_scored = !0;
}
if (last_score = a, $emojiButtons.forEach(function(e, t) {
o === t ? e.setAttribute("data-status", "selected") : e.setAttribute("data-status", "unselected");
}), 2 == Page.h5_settings.score_card_style || 3 == Page.h5_settings.score_card_style) {
emojiAnimationArray[o] && emojiAnimationArray[o].destroy();
var s = bodymovin.loadAnimation({
container: document.querySelector("#" + i + "-press-animation"),
path: 3 == Page.h5_settings.score_card_style ? baseFilePath() + "images/score-" + i + "/data2.json" : baseFilePath() + "images/score-" + i + "/data.json",
renderer: "svg",
loop: !1,
autoplay: !0
});
emojiAnimationArray[o] = s;
}
send_umeng_event("score_card", "click", {
value: group_id,
extra: {
score: a,
interval: Date.now() - startTime
}
}), 3 == Page.h5_settings.score_card_style && (lastTimeOutDone && clearTimeout(lastTimeOutDone), 
document.getElementById("thx-press-emoji").className = i + "-press", document.getElementById("thx-word").innerHTML = "您对本文的评价是：" + letters[score_card_info_string][o], 
lastTimeOutDone = setTimeout(function() {
$(".p-scorecard").addClass("moveUp");
}, 1e3)), (4 == Page.h5_settings.score_card_style || 5 == Page.h5_settings.score_card_style) && (lastTimeOutDone && clearTimeout(lastTimeOutDone), 
document.getElementById("thx-press-emoji").className = i + "-press", document.getElementById("thx-word").innerHTML = "您对本文的评价是：" + letters[score_card_info_string][o], 
lastTimeOutDone = setTimeout(function() {
$(".p-scorecard").addClass("moveUp");
}, 300));
}
}), $template.on("click", ".rescore-button", function() {
$(".p-scorecard").removeClass("moveUp"), $(".emoji-button").forEach(function(e) {
e.setAttribute("data-status", "init");
}), last_score = -1;
}), $("footer").append($template), send_exposure_event_once($template.get(0), function() {
startTime = Date.now(), send_umeng_event("score_card", "show", {
value: group_id,
extra: {
style: "face"
}
});
}, !0);
}

function processScoreCard() {
if (client.isSeniorAndroid) {
var e;
try {
e = localStorage.getItem("article_detail_score");
} catch (t) {}
var a = Page.statistics.group_id;
if (e) {
var i = e.split(",");
if (i.indexOf(a) > -1) return;
}
var o = {};
client.isAndroid && client.isNewsArticleVersionNoLessThan("6.2.5") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.2.6") ? ToutiaoJSBridge.call("TTNetwork.commonParams", {}, function(e) {
o = e.data || e, 1 === Page.h5_settings.score_card_style ? processScoreCardByStar(o) : (Page.h5_settings.score_card_style > 1 || Page.h5_settings.score_card_style < 6) && processScoreCardByEmoji(o);
}) : 1 === Page.h5_settings.score_card_style ? processScoreCardByStar(o) : (Page.h5_settings.score_card_style > 1 || Page.h5_settings.score_card_style < 6) && processScoreCardByEmoji(o);
}
}

function processScoreCardWenda(scoredValue) {
function doStar(e) {
var t = $template.find(".star");
t.removeClass("active").removeClass("the-one"), t.eq(e).addClass("the-one");
for (var a = 0; e >= a; a++) t.eq(a).addClass("active");
$template.find(".info-wrapper").addClass("stared"), $.ajax({
url: "https://lf.snssdk.com/wenda/v1/commit/scoring/",
dataType: "jsonp",
data: {
score: 1 * e + 1,
ansid: Page.wenda_extra.ansid,
stay_time: Math.round((new Date() - enterTime) / 1e3)
},
error: function() {},
success: function() {}
});
var i = {
group_id: Page.statistics.group_id,
user_id: Page.wenda_extra.user.user_id,
qid: Page.wenda_extra.qid,
ansid: Page.wenda_extra.ansid,
score: 1 * e + 1
};
sendUmengEventV3("answer_score", $.extend(i, Page.wenda_extra.gd_ext_json)), clearTimeout(timerUp), 
timerUp = setTimeout(function() {
$(".score-star-wenda .inner").addClass("done");
}, 5e3);
}
var templateFunction = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) {
__p += '<div class="pcard score-star-wenda" style="margin-top: 8px;"><div class="p-scorecard pcard-container pcard-vertical-border"><div class="wrapper"><div class="inner ', 
scoredValue && (__p += "done done-pre"), __p += '"><div class="pcard-clearfix score-wrapper"><div class="info-wrapper ', 
scoredValue && (__p += "stared"), __p += '"><div class="star-wenda-title star-wenda-question">你觉得刚看过的回答怎么样？</div><div class="star-wenda-title star-wenda-question q-ok">谢谢你为回答打分！</div></div><div class="star-wrap">';
for (var i = 0; i < txt.length; i++) __p += '<div class="star ', scoredValue > i && (__p += "active"), 
__p += " ", scoredValue == i + 1 && (__p += "the-one"), __p += '" data-index="' + (null == (__t = i) ? "" : __t) + '"><i></i><span>' + (null == (__t = txt[i]) ? "" : __t) + "</span></div>";
__p += '</div></div><div class="pcard-clearfix result-wrapper"><div class="thx-press"><span class="press"></span></div><div class="thx-word">感谢你的打分，你的打分对我们很重要！</div>', 
scoredValue || (__p += '<a class="rescore-button">重新打分</a>'), __p += "</div></div></div></div></div>";
}
return __p;
};
scoredValue = scoredValue || 0;
var timerUp, $template = $(templateFunction({
scoredValue: scoredValue,
txt: [ "极差", "较差", "一般", "不错", "很棒" ]
})), enterTime = new Date();
$template.on("click", ".star", function() {
var e = $(this).data("index");
ToutiaoJSBridge.call("is_login", {}, function(t) {
t.is_login || 1 == t.code ? doStar(e) : ToutiaoJSBridge.call("login", {}, function(t) {
1 == t.code && doStar(e);
});
});
}), $template.on("click", ".rescore-button", function() {
$(".score-star-wenda .inner").removeClass("done");
var e = $template.find(".star");
e.removeClass("active").removeClass("the-one"), $template.find(".info-wrapper").removeClass("stared");
}), $("footer").prepend($template);
var time = 3, timer = setInterval(function() {
var e = document.querySelector("footer").getBoundingClientRect(), t = e.top + e.height;
ToutiaoJSBridge.call("webviewContentResize", {
height: t
}), time--, time || clearInterval(timer);
}, 100);
}

function renderLightAnswerPics() {
if (wenda_extra.image_list && wenda_extra.image_list.length) {
var templateFunction = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) {
__p += '<div class="pic-cell-wenda col-3">';
for (var index = 0; index < images.length; index++) __p += '<div class="pic-cell-pic" data-index="' + (null == (__t = index) ? "" : __t) + '"><div class="pic-cell-pic-inner"><div class="pic-cell-pic-c">', 
__p += 1 == images.length ? '<img src="https://p1.pstatp.com/large/' + (null == (__t = images[index].web_uri) ? "" : __t) + '" />' : '<img width="400" height="400" src="https://p1.pstatp.com/list/400x400/' + (null == (__t = images[index].web_uri) ? "" : __t) + '" />', 
__p += "</div></div></div>";
__p += "</div>";
}
return __p;
}, $template = $(templateFunction({
images: wenda_extra.image_list
}));
$template.on("click", ".pic-cell-pic", function() {
for (var e = $(this), t = e.attr("data-index"), a = [], i = 0; i < wenda_extra.image_list.length; i++) a.push("https://p1.pstatp.com/large/" + wenda_extra.image_list[i].web_uri);
var o = e.offset();
location.href = "ios" == window.CLIENT_VERSION ? "bytedance://full_image?index=" + t + "&url=" + a[t] + "&left=" + o.left + "&top=" + o.top + "&width=" + e.width() + "&height=" + e.height() : "bytedance://large_image?index=" + t + "&url=" + a[t] + "&left=" + o.left + "&top=" + o.top + "&width=" + e.width() + "&height=" + e.height();
}), $template.addClass(1 === wenda_extra.image_list.length ? "col-1" : 2 === wenda_extra.image_list.length || 4 === wenda_extra.image_list.length ? "col-2" : "col-3"), 
$("footer").prepend($template).addClass("has-wenda-pic-cell");
}
}

function oldMotorDealerContextRender(e, t, a, i, o) {
var n = $(e({
data: o
})), r = {
page_id: "page_detail",
data_from: "motor_media",
group_id: Page.statistics.group_id,
media_id: Page.author.mediaId,
media_name: Page.author.name,
series_id: o.series_id,
series_name: o.series_name,
position: o.pos,
req_id: i,
card_id: o.card_id,
card_type: o.card_type,
extra_params: JSON.stringify({})
};
n.data("series_id", o.series_id), n.data("series_name", o.series_name), n.on("focus", ".j-motor-form-user", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_focus",
focus_dom: "user_name"
}, r), !1);
}).on("focus", ".j-motor-form-mobile", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_focus",
focus_dom: "phone"
}, r), !1);
}).on("click", ".j-motor-form-btn", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation"
}, r), !1);
var e = $(this), t = e.closest(".motor-form-body"), i = t.find("[name=userName]"), s = t.find("[name=userMobile]"), l = t.find("[name=userAgree]"), c = i.val(), d = s.val(), _ = l.is(":checked");
return "" === c ? (i.addClass("error").next(".motor-form-tip").show(), !1) : (i.removeClass("error").next(".motor-form-tip").hide(), 
"" !== d && /^1[3|4|5|7|8|9]\d{9}$/.test(d) ? (s.removeClass("error").next(".motor-form-tip").hide(), 
_ ? ($("article").find(".motor-form-body [name=userName]").val(c), $("article").find(".motor-form-body [name=userMobile]").val(d), 
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_sure"
}, r), !1), e.attr("disabled", "disabled").text("提交中..."), void $.ajax({
url: "https://i.snssdk.com/motor/dealer/m/v1/commit_inquiry_info/",
data: {
user_name: c,
phone: d,
city_name: a,
dealer_ids: o.dealer_ids.join(","),
car_id: o.car_id,
data_from: "motor_media",
extra: JSON.stringify({
zt: "motor_media"
})
},
dataType: "jsonp",
success: function(t) {
e.removeAttr("disabled").text("立即获取最低价"), t.data && "true" === t.data.result ? (n.find(".motor-form-edit").hide(), 
n.find(".motor-form-sheet").show(), n.find(".j-close-dealer-card").hide()) : ToutiaoJSBridge.call("toast", {
text: "提交失败，请稍后重试",
icon_type: "icon_error"
});
},
error: function(t, a) {
e.removeAttr("disabled").text("立即获取最低价"), console.warn(t, a);
}
})) : (ToutiaoJSBridge.call("alert", {
title: "温馨提醒",
message: "请勾选《个人信息保护声明》后进行询价，我们将保护您的个人信息安全",
confirm_text: "确认",
cancel_text: "取消"
}), !1)) : (s.addClass("error").next(".motor-form-tip").show(), !1));
}).on("click", ".j-motor-sheet-rewrite", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_rewrite"
}, r), !1), n.find(".motor-form-edit").show(), n.find(".motor-form-sheet").hide();
}), n.find(".j-close-dealer-card").on("click", function(e) {
e.preventDefault(), e.stopPropagation(), ToutiaoJSBridge.call("alert", {
title: "提示",
message: "确定要隐藏此内容？",
confirm_text: "确认",
cancel_text: "取消"
}, function(e) {
return e.code ? (sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_close"
}, r), !1), void ToutiaoJSBridge.call("appInfo", {}, function(e) {
var t = e.device_id || 0;
$.ajax({
url: "https://i.snssdk.com/motor/operation/activity/zhuduan/dislike/",
data: {
device_id: t,
series_id: o.series_id,
group_id: Page.statistics.group_id,
media_id: Page.author.mediaId
},
dataType: "jsonp",
success: function(e) {
"success" === e.message ? n.hide() : console.warn(e.message);
},
error: function(e, t) {
n.hide(), console.warn(e, t);
}
});
})) : void sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_close_cancel"
}, r), !1);
});
}), n.find(".j-motor-form-head").on("click", function(e) {
e.preventDefault(), sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_gotoCar"
}, r), !1);
var t = "https://m.dcdapp.com/motor/m/car_series/index?series_id=" + o.series_id + "&zt=tt_card_article";
location.href = "sslocal://webview?url=" + encodeURIComponent(t) + "&title=" + o.series_name + "&use_wk=1";
}), needCleanDoms.push(n), o.pos > t ? $("article > div p:nth-of-type(" + Math.ceil(t / 2) + ")").before(n) : $("article > div p:nth-of-type(" + o.pos + ")").before(n), 
sendUmengEventV3("web_show_event", $.extend({
obj_id: "detail_scard_n_consultation_render"
}, r), !1), sendUmengWhenTargetShown(n.get(0), "web_show_event", "", $.extend({
obj_id: "detail_scard_n_consultation"
}, r), !0, {
version: 3,
isDoubleSend: !1
});
}

function motorDealerContextRender(e, t, a, i, o) {
var n = $(e({
data: o
})), r = {
page_id: "page_detail",
data_from: "motor_media",
group_id: Page.statistics.group_id,
media_id: Page.author.mediaId,
media_name: Page.author.name,
series_id: o.series_id,
series_name: o.series_name,
position: o.pos,
req_id: i,
card_id: o.card_id,
card_type: o.card_type,
extra_params: JSON.stringify({})
};
n.data("series_id", o.series_id), n.data("series_name", o.series_name), n.find(".j-motor-enter").on("click", function(e) {
e.stopPropagation(), e.preventDefault(), sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_open"
}, r), !1), n.find(".motor-form-body").show(), $(this).hide();
}), n.find(".j-motor-form-normal").on("click", function(e) {
e.preventDefault(), sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_gotoCar"
}, r), !1);
var t = "https://m.dcdapp.com/motor/m/car_series/index?series_id=" + o.series_id + "&zt=tt_card_article";
location.href = "sslocal://webview?url=" + encodeURIComponent(t) + "&title=" + o.series_name + "&use_wk=1";
}), n.find(".j-motor-form-user").on("focus", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_focus",
focus_dom: "user_name"
}, r), !1);
}), n.find(".j-motor-form-mobile").on("focus", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_focus",
focus_dom: "phone"
}, r), !1);
}), n.find(".j-motor-form-btn").on("click", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation"
}, r), !1);
var e = $(this), t = e.closest(".motor-form-body"), i = t.find("[name=userName]"), s = t.find("[name=userMobile]"), l = t.find("[name=userAgree]"), c = i.val(), d = s.val(), _ = l.is(":checked");
return "" === c ? (i.addClass("error").next(".motor-form-tip").show(), !1) : (i.removeClass("error").next(".motor-form-tip").hide(), 
"" !== d && /^1[3|4|5|7|8|9]\d{9}$/.test(d) ? (s.removeClass("error").next(".motor-form-tip").hide(), 
_ ? ($("article").find(".motor-form-body [name=userName]").val(c), $("article").find(".motor-form-body [name=userMobile]").val(d), 
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_sure"
}, r), !1), e.attr("disabled", "disabled").text("提交中..."), void $.ajax({
url: "https://i.snssdk.com/motor/dealer/m/v1/commit_inquiry_info/",
data: {
user_name: c,
phone: d,
city_name: a,
dealer_ids: o.dealer_ids.join(","),
car_id: o.car_id,
data_from: "motor_media",
extra: JSON.stringify({
zt: "motor_media"
})
},
dataType: "jsonp",
success: function(t) {
e.removeAttr("disabled").text("立即获取最低价"), t.data && "true" === t.data.result ? (n.find(".motor-form-edit").hide(), 
n.find(".motor-form-sheet").show(), n.find(".j-close-dealer-card").hide()) : ToutiaoJSBridge.call("toast", {
text: "提交失败，请稍后重试",
icon_type: "icon_error"
});
},
error: function(t, a) {
e.removeAttr("disabled").text("立即获取最低价"), console.warn(t, a);
}
})) : (ToutiaoJSBridge.call("alert", {
title: "温馨提醒",
message: "请勾选《个人信息保护声明》后进行询价，我们将保护您的个人信息安全",
confirm_text: "确认",
cancel_text: "取消"
}), !1)) : (s.addClass("error").next(".motor-form-tip").show(), !1));
}), n.find(".j-motor-sheet-rewrite").on("click", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_rewrite"
}, r), !1), n.find(".motor-form-edit").show(), n.find(".motor-form-sheet").hide();
}), n.find(".j-close-dealer-card").on("click", function(e) {
e.preventDefault(), e.stopPropagation(), ToutiaoJSBridge.call("alert", {
title: "提示",
message: "确定要隐藏此内容？",
confirm_text: "确认",
cancel_text: "取消"
}, function(e) {
return e.code ? (sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_close"
}, r), !1), void ToutiaoJSBridge.call("appInfo", {}, function(e) {
var t = e.device_id || 0;
$.ajax({
url: "https://i.snssdk.com/motor/operation/activity/zhuduan/dislike/",
data: {
device_id: t,
series_id: o.series_id,
group_id: Page.statistics.group_id,
media_id: Page.author.mediaId
},
dataType: "jsonp",
success: function(e) {
"success" === e.message ? n.hide() : console.warn(e.message);
},
error: function(e, t) {
n.hide(), console.warn(e, t);
}
});
})) : void sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_close_cancel"
}, r), !1);
});
}), needCleanDoms.push(n), o.pos > t ? $("article > div p:nth-of-type(" + Math.ceil(t / 2) + ")").before(n) : $("article > div p:nth-of-type(" + o.pos + ")").before(n), 
sendUmengEventV3("web_show_event", $.extend({
obj_id: "detail_scard_n_consultation_render"
}, r), !1), sendUmengWhenTargetShown(n.get(0), "web_show_event", "", $.extend({
obj_id: "detail_scard_n_consultation"
}, r), !0, {
version: 3,
isDoubleSend: !1
});
}

function followActionHandler() {
var e = $(this), t = e.data("userId"), a = e.data("mediaId"), i = e.hasClass("following"), o = e.attr("data-concerntype") || "", n = Page.article.type, r = "" === o, s = Page.hasExtraSpace && r;
if (!e.hasClass("disabled")) if ($(".subscribe-button").addClass("disabled"), $("header").addClass("canmoving"), 
$(".boot-outer-container").css("display", "none"), "pgc" === n) doFollowMedia(t, a, i, o), 
s && !Page.author.hasRedPack && (i ? "open" === $("header").attr("sugstate") ? NativePlayGif.willStart(function() {
$("header").attr("sugstate", "no");
}) : $("header").attr("sugstate", "no") : doRecommendUsers(Page.author.userId, recommendUsersSuccess, recommendUsersError)); else if ("wenda" === n) {
doFollowUser(t, a, i, void 0, followSource.wenda, "answer_detail_top_card");
var l = $.extend({}, wenda_extra.gd_ext_json || {}, {
source: "answer_detail_top_card",
position: "detail",
to_user_id: t,
follow_type: "from_group",
group_id: wenda_extra.ansid,
server_source: 28
});
Page.author.hasRedPack && (l.is_redpacket = 1), sendUmengEventV3(i ? "rt_unfollow" : "rt_follow", l), 
s && (client.isAndroid && client.isNewsArticleVersionNoLessThan("6.2.5") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.3.3")) && (i ? "open" === $("header").attr("sugstate") ? NativePlayGif.willStart(function() {
$("header").attr("sugstate", "no");
}) : $("header").attr("sugstate", "no") : doRecommendUsers(Page.author.userId, recommendUsersSuccess, recommendUsersError));
} else "forum" === n && (doFollowUser(t, a, i, void 0, followSource.forum, "detail"), 
s && (client.isAndroid && client.isNewsArticleVersionNoLessThan("6.2.5") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.2.6")) && (i ? "open" === $("header").attr("sugstate") ? NativePlayGif.willStart(function() {
$("header").attr("sugstate", "no");
}) : $("header").attr("sugstate", "no") : doRecommendUsers(Page.author.userId, recommendUsersSuccess, recommendUsersError)), 
(client.isNewsArticleVersionNoLessThan("6.4.4") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.4.5")) && sendUmengEventV3(i ? "rt_unfollow" : "rt_follow", {
to_user_id: t,
follow_type: "from_group",
group_id: forum_extra.thread_id,
item_id: forum_extra.thread_id,
category_name: Page.category_name,
source: "weitoutiao_detail",
server_source: followSource.forum,
position: "title_below",
log_pb: Page.log_pb
}, !1));
}

function followBottomAction() {
var e = $(this), t = e.data("userId"), a = e.data("mediaId"), i = e.hasClass("following");
if (!e.hasClass("disabled")) {
if ($(".subscribe-button-bottom").addClass("disabled"), $(".boot-outer-container").css("display", "none"), 
"wenda" === Page.article.type) {
var o = $.extend({}, wenda_extra.gd_ext_json || {}, {
source: "answer_detail_bottom_card",
position: "detail",
to_user_id: t,
follow_type: "from_group",
group_id: wenda_extra.ansid,
server_source: 80
});
Page.author.hasRedPack && (o.is_redpacket = 1), sendUmengEventV3(i ? "rt_unfollow" : "rt_follow", o);
}
doFollowUser(t, a, i, void 0, followSource[Page.article.type] || "", "wenda" === Page.article.type ? "answer_detail_bottom_card" : "detail_bottom");
}
}

function mediasugArrowAction() {
var e = $("header"), t = "close" === e.attr("sugstate");
NativePlayGif.willStart(function() {
e.attr("sugstate", t ? "open" : "close");
}), send_umeng_event("detail", t ? "click_arrow_down" : "click_arrow_up", {
extra: {
source: "article_detail"
}
});
}

function mediasugCardClickHandler(e) {
if (!$(e.target).is(".ms-subs")) {
var t = $(this).attr("it-is-user-id"), a = "", i = "", o = "";
"pgc" === Page.article.type ? (send_umeng_event("detail", "sub_rec_click", {
value: t,
extra: {
source: "article_detail",
profile_user_id: Page.author.userId
}
}), a = "detail_follow_card_article", i = Page.category_name, o = Page.statistics.group_id) : "forum" === Page.article.type ? (send_umeng_event("follow_card", "click_avatar", {
value: forum_extra.thread_id,
ext_value: t,
extra: {
source: "weitoutiao_detail",
profile_user_id: Page.author.userId
}
}), a = "detail_follow_card_topic", i = Page.category_name, o = Page.forum_extra.thread_id) : "wenda" === Page.article.type && (send_umeng_event("follow_card", "click_avatar", {
value: wenda_extra.ansid,
ext_value: t,
extra: {
source: "wenda_detail",
profile_user_id: Page.author.userId
}
}), a = "detail_follow_card_wenda", i = wenda_extra.gd_ext_json ? wenda_extra.gd_ext_json.category_name : "", 
o = wenda_extra.ansid), window.location.href = "sslocal://profile?uid=" + t + ("wenda" === Page.article.type ? "&refer=wenda" : "") + "&group_id=" + o + "&from_page=" + a + "&profile_user_id=" + Page.author.userId + (i ? "&category_name=" + i : "");
}
}

function mediasugFollowAction() {
var e = $(this), t = null != e.attr("isfollowing"), a = e.closest(".ms-item").attr("it-is-user-id"), i = e.attr("reason"), o = followSource[Page.article.type + "_sug"], n = e.closest(".ms-item").data("index");
if (e.attr("disabled", !0), "wenda" === Page.article.type) sendUmengEventV3(t ? "rt_unfollow" : "rt_follow", $.extend({}, wenda_extra.gd_ext_json || {}, {
source: "answer_detail_follow_card",
position: "detail",
to_user_id: a,
order: n,
profile_user_id: wenda_extra.user ? wenda_extra.user.user_id : "",
follow_type: "from_recommend"
})); else if ("forum" !== Page.article.type || client.isNewsArticleVersionNoLessThan("6.4.2")) {
if (client.isNewsArticleVersionNoLessThan("6.4.4") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.4.5")) {
var r = {
source: "detail_follow_card",
to_user_id: a,
order: n,
profile_user_id: Page.author.userId,
follow_type: "from_recommend",
category_name: Page.category_name,
server_source: followSource[Page.article.type + "_sug"],
log_pb: Page.log_pb
};
Page.author.mediaId && (r.media_id = Page.author.mediaId), sendUmengEventV3(t ? "rt_unfollow" : "rt_follow", r, !1);
}
} else send_umeng_event(t ? "unfollow" : "follow", "weitoutiao_detail_sug", {
ext_value: a,
value: forum_extra.thread_id,
extra: {
profile_user_id: Page.author.userId,
source: "weitoutiao_detail"
}
});
ToutiaoJSBridge.call("user_follow_action", {
id: a,
action: t ? "unfollow" : "dofollow",
reason: i,
source: o,
order: n,
from: "sug"
}, function(i) {
e.attr("disabled", null), "object" == typeof i && 1 === +i.code && ("pgc" !== Page.article.type || client.isNewsArticleVersionNoLessThan("6.4.2") || send_umeng_event("detail", t ? "sub_rec_unsubscribe" : "sub_rec_subscribe", {
value: a,
extra: {
source: "article_detail",
profile_user_id: Page.author.userId
}
}), e.attr("isfollowing", t ? null : ""), doRecommendUsers(Page.author.userId, function(e) {
if (Array.isArray(e)) for (var i = e.length, o = 0; i > o; o++) e[o].user_id == a && (e[o].is_following = !t);
}, function() {}));
});
}

function domPrepare() {
var e = document.querySelector(".mediasug-outer-container"), t = document.querySelector(".mediasug-inner-container");
if (e && t) {
e.addEventListener("transitionend", function() {
console.info("transitionend"), NativePlayGif.ended();
}, !1);
var a = window.MutationObserver || window.WebKitMutationObserver;
if (a) {
var i = new a(function(e) {
e.forEach(function(e) {
var t = e.attributeName;
if ("sugstate" === t) {
var a = e.target.getAttribute(t);
if ("open" === a) {
console.info("SUG-OEPN"), mediasugScroll.open(), $(document).on("scroll", mediasugScroll.pagescroll), 
ToutiaoJSBridge.on("webviewScrollEvent", function(e) {
mediasugScroll.webviewScroll(e);
});
var i, o;
"pgc" === Page.article.type ? (i = "article_detail", o = Page.statistics.group_id) : "forum" === Page.article.type ? (i = "weitoutiao_detail", 
o = forum_extra.thread_id) : "wenda" === Page.article.type && (i = "wenda_detail", 
o = wenda_extra.ansid), send_umeng_event("follow_card", "show", {
value: o,
extra: {
source: i
}
});
} else "close" === a ? (console.info("SUG-HIDE"), $(document).off("scroll", mediasugScroll.pagescroll), 
mediasugScroll.pushimpr(!0)) : (console.info("SUG-HIDE"), $(document).off("scroll", mediasugScroll.pagescroll), 
mediasugScroll.pushimpr(!0));
}
});
});
i.observe(document.getElementsByTagName("header")[0], {
attributes: !0
});
}
}
}

function recommendUsersError() {
console.info(arguments);
}

function recommendUsersSuccess(list) {
if (!($("header").get(0).getBoundingClientRect().bottom + 232 < 0)) {
list.forEach(function(e) {
if (e.user_auth_info && "string" == typeof e.user_auth_info) try {
e.user_auth_info = JSON.parse(e.user_auth_info);
} catch (t) {
e.user_auth_info = {};
}
}), mediasugScroll.init(list);
var MediasugTemplateFunction = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) {
__p += "";
for (var i = 0; i < data.length; i++) {
var item = data[i];
__p += '<div class="ms-item" it-is-user-id="' + (null == (__t = item.user_id) ? "" : __t) + '" data-index="' + (null == (__t = i + 1) ? "" : __t) + '" it-is-media-id="' + (null == (__t = item.media_id ? item.media_id : "") ? "" : __t) + '"><div class="ms-avatar"><div class="ms-avatar-wrap"><img class="ms-avatar-image" src="' + (null == (__t = item.avatar_url) ? "" : __t) + '"></div>', 
useServerV && item.user_verified && item.user_auth_info && item.user_auth_info.auth_type && (__p += "" + (null == (__t = buildServerVIcon2(item.user_auth_info.auth_type, "avatar_icon")) ? "" : __t)), 
__p += "</div>", Page.showUserDecoration && item.user_decoration && item.user_decoration.url && (__p += '<div class="avatar-decoration" style="background-image: url(' + (null == (__t = item.user_decoration.url) ? "" : __t) + ')"></div>'), 
__p += '<div class="avatar-decoration avatar-night-mask"></div><div class="ms-name-wrap"><div class="ms-name ' + (null == (__t = !useServerV && item.user_verified ? " verified" : "") ? "" : __t) + '">' + (null == (__t = item.name) ? "" : __t) + '</div></div><div class="ms-desc">' + (null == (__t = item.reason_description) ? "" : __t) + '</div><button reason="' + (null == (__t = item.reason) ? "" : __t) + '" class="ms-subs ' + (null == (__t = isRedFocusButton ? "ms-red-btn" : "") ? "" : __t) + '" ' + (null == (__t = item.is_following ? " isfollowing " : "") ? "" : __t) + " " + (null == (__t = item.is_followed ? " isfollowed " : "") ? "" : __t) + ' ><span class="focus-icon">&nbsp;</span></button></div>';
}
__p += "";
}
return __p;
}, MediasugTemplateString = MediasugTemplateFunction({
data: list,
useServerV: Page.useServerV,
isRedFocusButton: Page.isRedFocusButton
});
$("#mediasug-list-html").html(MediasugTemplateString).css("width", 150 * list.length + 10 + 15 + "px"), 
NativePlayGif.willStart(function() {
$("header").attr("sugstate", "open");
}), $("#mediasug-list").on("touchstart touchmove", function() {
sendBytedanceRequest("disable_swipe");
}).on("touchend touchcancel", function() {
sendBytedanceRequest("enable_swipe");
}), $("#mediasug-list").on("scroll", _.throttle(mediasugScroll.handler, 150)), needCleanDoms.push($("#mediasug-list"));
}
}

function doFollowUser(e, t, a, i, o, n) {
subscribeTimeoutTimer = setTimeout(change_following_state, 1e4, a, !0), ToutiaoJSBridge.call("user_follow_action", {
id: e,
action: a ? "unfollow" : "dofollow",
reason: i,
source: o,
from: n
}, function(e) {
clearTimeout(subscribeTimeoutTimer), e && "object" == typeof e && 1 === +e.code ? change_following_state(!!e.status, !0) : change_following_state(a, !0);
});
}

function doFollowMedia(e, t, a, i) {
subscribeTimeoutTimer = setTimeout(change_following_state, 1e4, a, !0), ToutiaoJSBridge.call(a ? "do_media_unlike" : "do_media_like", {
id: t,
uid: e,
concern_type: i,
source: !a && Page.author.hasRedPack ? followSource.pgc + 1e3 : followSource.pgc
}, function(i) {
clearTimeout(subscribeTimeoutTimer), 1 === +i.code ? change_following_state(!a, !0, function(a) {
client.isNewsArticleVersionNoLessThan("6.4.2") ? (client.isNewsArticleVersionNoLessThan("6.4.4") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.4.5")) && sendUmengEventV3(a ? "rt_follow" : "rt_unfollow", {
to_user_id: e,
media_id: t,
follow_type: "from_group",
group_id: Page.statistics.group_id,
item_id: Page.statistics.item_id,
category_name: Page.category_name,
source: "article_detail",
server_source: followSource.pgc,
position: "title_below",
log_pb: Page.log_pb
}, !1) : a ? send_umeng_event("preview", "preview_click_sub") : send_umeng_event("preview", "preview_click_cancel_sub");
}) : client.isAndroid || client.isNewsArticleVersionNoLessThan("5.7.2") ? change_following_state(a, !0) : change_following_state(a, !0);
});
}

function bindStatisticsEvents23() {
$(document.body).on("click", ".subscribe-button", followActionHandler), $(document.body).on("click", ".subscribe-button-bottom", followBottomAction), 
$(document.body).on("click", ".mediasug-arrow-button", mediasugArrowAction), $(document.body).on("click", ".ms-item", mediasugCardClickHandler), 
$(document.body).on("click", ".ms-subs", mediasugFollowAction);
}

function processForumArticle2() {
if (Page.show_origin || $(".tt-repost-thread").each(function(e, t) {
$(t).html(Page.show_tips || "原内容已经删除").removeClass("tt-repost-thread").addClass("tt-repost-delete");
}), void 0 != Page.read_count && Page.read_count >= 0) {
var e = formatCount(null, Page.read_count, "0");
$("#origin-read-count").html(e);
}
for (var t = document.querySelectorAll(".emoji"), a = 0, i = t.length, a = 0; i > a; a++) t[a].style.backgroundImage = "url(http://s3.pstatp.com/toutiao/tt_tps/static/images/ttemoji_v2/" + t[a].classList[1] + "@3x.png)";
}

function bindRepostEvent() {
$(".tt-repost-thread").on("click", function(e) {
var t = $(e.target);
0 === t.closest("a").length && (location.href = this.dataset.openUrl);
}), $(".tt-repost-ugcvideo").on("click", function(e) {
var t = $(e.target);
0 === t.closest(".cover").length && 0 === t.closest(".originuser").length && (location.href = this.dataset.openUrl);
}), $(".out-link").on("click", function() {
sendUmengEventV3("external_link_click", {
category_name: Page.category_name,
group_id: Page.forum_extra.thread_id
});
});
}

function processTable() {
client.isAndroid ? $("table").each(function(e, t) {
$(t).addClass("border").wrap('<div class="table-wrap horizontal_scroll_android"/>');
}) : client.isIOS && $("table").each(function(e, t) {
var a = $(t);
if (a.addClass("border").wrap('<div class="table-wrap horizontal_scroll"/>'), a.width() > innerWidth - 30) {
var i = a.parent(), o = $('<div class="swipe_tip">左滑查看更多</div>');
i.append(o), i.on("touchstart", function() {
o.css("opacity", "0");
}).on("scroll touchend", function() {
0 === this.scrollLeft && o.css("opacity", "1");
}), needCleanDoms.push(i);
}
});
}

function appendVideoImg() {
var e = this.parentNode;
e && (e.style.background = "black");
var t = $(this), a = this.dataset;
if (!a.width && !a.height) {
var i = .75, o = 0, n = i, r = "", s = this.naturalWidth, l = this.naturalHeight;
s && l && (o = l / s, i >= o ? n = o : r = "height: 100%; width: auto;");
var c = t.clientWidth;
t.css("height", c * n + "px"), this.setAttribute("style", r), e.setAttribute("data-video-size", JSON.stringify({
normal: {
h: l,
w: s
}
}));
}
}

function errorVideoImg() {
var e = this.parentNode;
e && e.removeChild(this);
}

function processCustomVideo() {
$(".custom-video").each(function(e, t) {
var a = $(t), i = t.dataset, o = i.width, n = i.height, r = .75, s = 0, l = r, c = "";
o && n && (s = n / o, r >= s ? l = s : c = "height: 100%; width: auto;");
var d = t.clientWidth;
if (a.css("height", d * l + "px"), i.wendaSource && "object" == typeof window.wenda_extra) {
var _ = formatDuration(i.duration);
if (a.html('<img src="' + i.poster + '" style="' + c + '" onload="appendVideoImg.call(this)" onerror="errorVideoImg.call(this)" /><i class="custom-video-trigger"></i><i class="custom-video-duration">' + _ + "</i>"), 
"pgc" === i.wendaSource) {
var u = $('<a class="cv-wd-info-wrapper" href="' + i.openUrl + '"><span class="cv-wd-info-name" ' + (Boolean(Number(i.isVerify)) ? "is-verify" : "") + ">" + i.mediaName + '</span><span class="cv-wd-info-pc">' + i.playCount + "次播放</span></a>");
u.on("click", function() {
ToutiaoJSBridge.call("pauseVideo"), send_umeng_event("answer_detail", "click_video_detail", {
value: wenda_extra.ansid,
extra: {
video_id: i.vid,
enter_from: wenda_extra.enter_from || "",
ansid: wenda_extra.ansid,
qid: wenda_extra.qid,
parent_enterfrom: wenda_extra.parent_enterfrom || ""
}
});
}), needCleanDoms.push(u), a.after(u);
}
var p = {
value: wenda_extra.ansid,
extra: {
position: "detail",
video_id: i.vid,
enter_from: wenda_extra.enter_from || "",
value: wenda_extra.ansid,
ansid: wenda_extra.ansid,
qid: wenda_extra.qid,
parent_enterfrom: wenda_extra.parent_enterfrom || ""
}
};
wendaCacheAdd(function() {
$.extend(p.extra, wenda_extra.gd_ext_json), delete p.extra.log_pb, $.extend(p.extra, wenda_extra.gd_ext_json.log_pb), 
window.wenda_extra && window.wenda_extra.answer_detail_type ? sendUmengWhenTargetShown(t, "video_show", "click_" + wenda_extra.gd_ext_json.category_name, p, !0) : sendUmengWhenTargetShown(t, "video_show", "click_" + wenda_extra.gd_ext_json.category_name, p, !0);
});
} else a.html('<img src="' + i.poster + '" style="' + c + '" onload="appendVideoImg.call(this)" onerror="errorVideoImg.call(this)" /><i class="custom-video-trigger"></i>');
Page.hasExtraSpace = !1;
});
}

function checkDisplayedFactory(e, t) {
return lastBottom = {}, function() {
var a = document.querySelector(e);
if (a) {
var i = a.getBoundingClientRect();
i.bottom < 0 && lastBottom[e] >= 0 ? ToutiaoJSBridge.call(t, {
show: !0
}) : i.bottom >= 0 && lastBottom[e] < 0 && ToutiaoJSBridge.call(t, {
show: !1
}), lastBottom[e] = i.bottom;
}
};
}

function processPageStateChangeEvent(e) {
switch (e.type) {
case "pgc_action":
console.info("pgc_action", e), subscribeTimeoutTimer && clearTimeout(subscribeTimeoutTimer);
var t = $(".subscribe-button"), a = t.data("mediaId");
e.id == a && "status" in e && (change_following_state(!!e.status, !0), e.status && (Page.author.hasRedPack = !1));
break;

case "user_action":
console.info("user_action", e), subscribeTimeoutTimer && clearTimeout(subscribeTimeoutTimer);
var t = $(".subscribe-button"), i = t.data("userId");
if (e.id == i && "status" in e) change_following_state(!!e.status, !0); else {
var o = $('[it-is-user-id="' + e.id + '"]');
o.length > 0 && "status" in e && (o.find(".ms-subs").attr("isfollowing", e.status ? "" : null).attr("disabled", null), 
e.status && mediasugScroll.next(), doRecommendUsers(Page.author.userId, function(t) {
if (Array.isArray(t)) for (var a = t.length, i = 0; a > i; i++) t[i].user_id == e.id && (t[i].is_following = !!e.status);
}, function() {}));
}
break;

case "wenda_digg":
var n = $("#digg").attr("data-answerid");
if (window.wenda_extra && window.wenda_extra.wd_version >= 8 && e.id === window.wenda_extra.ansid) {
var r = +$(".digg-count-special").attr("realnum");
"status" in e && (1 == e.status ? formatCount(".digg-count-special", r + 1, "0") : r > 0 && formatCount(".digg-count-special", r - 1, "0"));
} else if (e.id == n && "digged" !== $("#digg").attr("wenda-state")) {
$("#digg").attr("wenda-state", "digged");
var r = +$("#digg").find(".digg-count").attr("realnum");
formatCount(".digg-count", r + 1, "赞"), formatCount(".digg-count-special", r + 1, "0");
}
break;

case "wenda_bury":
var n = $("#bury").attr("data-answerid");
if (e.id == n && "buryed" !== $("#bury").attr("wenda-state")) {
$("#bury").attr("wenda-state", "buryed");
var s = +$("#bury").find(".bury-count").attr("realnum");
formatCount(".bury-count", s + 1, "踩");
}
break;

case "forum_action":
var l = $(".pcard.fiction").find(".button"), c = l.attr("forum-id");
e.id == c && l.attr("is-concerned", Boolean(e.status)).html(e.status ? "已关注" : "关注");
break;

case "concern_action":
var l = $(".pcard.fiction").find(".button"), d = l.attr("concern-id");
e.id == d && l.attr("is-concerned", Boolean(e.status)).html(e.status ? "查看书架" : "加入书架");
break;

case "carousel_image_switch":
"function" == typeof onCarouselImageSwitch && (Page.forum_extra && Page.forum_extra.thread_id == e.id ? onCarouselImageSwitch(e.status) : Page.wenda_extra && Page.wenda_extra.ansid == e.id ? onCarouselImageSwitch(e.status) : Page.statistics.group_id == e.id && onCarouselImageSwitch(e.status));
break;

case "block_action":
if (console.info(e), 1 == e.status) {
var t = $(".subscribe-button"), i = t.data("userId");
if (e.id == i) change_following_state(!1, !0); else {
var o = $('[it-is-user-id="' + e.id + '"]');
o.length > 0 && o.find(".ms-subs").attr("isfollowing", null);
}
}
}
}

function processParagraph() {
var e = /[\u2e80-\u2eff\u3000-\u303f\u3200-\u9fff\uf900-\ufaff\ufe30-\ufe4f]/, t = /[a-z0-9_:\-\/.%]{26,}/gi, a = /huawei/.test(navigator.userAgent.toLowerCase());
a && document.body.classList.add("huawei"), $("article p").each(function(a, i) {
if (!(i.classList.contains("pgc-img-caption") || !i.textContent || $(i).find(".image").length > 0)) if (e.test(i.textContent)) {
if (t.test(i.textContent)) {
var o = i.textContent.match(t);
o.forEach(function(e) {
i.innerHTML = i.innerHTML.replace(e, function(e) {
return '<br class="sysbr">' + e;
});
});
}
} else i.style.textAlign = "left";
});
}

function processNovelSeria() {
if (!Page.novel_data.show_bookshelf_window || !client.isNewsArticleVersionNoLessThan("6.4.7")) return void (location.href = $("#next_serial_link").attr("href"));
var e = !0, t = {
category_name: "novel_channel",
enter_from: "detail",
item_id: Page.statistics.item_id,
novel_id: Page.novel_data.book_id,
group_id: Page.statistics.group_id
};
ToutiaoJSBridge.call("getSubScribedChannelList", {}, function(a) {
var i = a.list || [];
i.slice(0, 6).indexOf("novel_channel") > -1 && (e = !1), t.popup_type = e ? "top_channel" : "add_bookshelf", 
sendUmengEventV3("show_addbookshelf_popup", t), ToutiaoJSBridge.call("alert", {
title: "加入书架",
message: "喜欢这本书就加入书架吧\n(头条首页选择小说频道，可找到书架)",
confirm_text: "确认",
cancel_text: "取消"
}, function(a) {
1 == a.code ? ($.ajax({
url: "https://ic.snssdk.com/novel/book/bookshelf/v1/add/",
dataType: "jsonp",
data: {
book_id: Page.novel_data.book_id
},
success: function(e) {
ToutiaoJSBridge.call("toast", {
text: 0 != e.code ? "添加失败" : "添加成功",
con_type: 0 != e.code ? "icon_error" : "icon_success"
}), setTimeout(function() {
location.href = $("#next_serial_link").attr("href");
}, 200);
}
}), e && ToutiaoJSBridge.call("addChannel", {
category: "novel_channel",
web_url: "https://ic.snssdk.com/novel_channel/",
name: "小说",
type: 5,
flags: 1
})) : location.href = $("#next_serial_link").attr("href"), t.clicked_button = 1 == a.code ? "yes" : "no", 
sendUmengEventV3("click_addbookshelf_popup", t);
});
});
}

function setContent(e) {
if (startTimestamp = Date.now(), null !== e) {
var t = e.indexOf("<article>"), a = e.indexOf("</article>"), i = e.substring(t + 9, a);
globalContent = i || e;
}
}

function setExtra(e) {
void 0 === e ? globalExtras = window : "object" == typeof e.h5_extra ? globalExtras = e : client.isIOS ? globalExtras.h5_extra = e : client.isAndroid && (globalExtras.h5_extra = $.extend(!0, globalExtras.h5_extra, e)), 
window.Page = buildPage(globalExtras), window.OldPage ? _.isEqual(window.OldPage, window.Page) || (window.OldPage = window.Page, 
buildHeader(window.Page), "forum" == Page.article.type && buildArticle(globalContent)) : (Slardar && Slardar.sendCustomTimeLog("start_build_article", window.CLIENT_VERSION + "_" + window.APP_VERSION, +new Date() - startTimestamp), 
Slardar && Slardar.sendCustomCountLog("fe_article_version", JSVERSION), window.OldPage = window.Page, 
TouTiao.setDayMode(Page.pageSettings.is_daymode ? 1 : 0), TouTiao.setFontSize(Page.pageSettings.font_size), 
buildUIStyle(Page.h5_settings), buildHeader(window.Page), buildArticle(globalContent), 
buildFooter(window.Page), functionName());
}

function functionName() {
sendBytedanceRequest("domReady"), Slardar && Slardar.sendCustomTimeLog("start_process_article", window.CLIENT_VERSION + "_" + window.APP_VERSION, +new Date() - startTimestamp), 
ToutiaoJSBridge.on("page_state_change", processPageStateChangeEvent), processArticle(), 
Slardar && Slardar.sendCustomTimeLog("end_process_article", window.CLIENT_VERSION + "_" + window.APP_VERSION, +new Date() - startTimestamp), 
null !== globalCachedContext && contextRenderer(globalCachedContext), canSetContext = !0;
}

function insertDiv(e) {
Slardar && Slardar.sendCustomTimeLog("start_insert_div", window.CLIENT_VERSION + "_" + window.APP_VERSION, +new Date() - startTimestamp), 
canSetContext ? contextRenderer(e) : globalCachedContext = e;
}

function onQuit() {
Page && Page.author && Page.author.userId && mediasugScroll.clearData(Page.author.userId), 
Page = {}, OldPage = null, globalContent = void 0, canSetContext = !1, window.imageInited = !1, 
window.imageSizeInitTimer && clearTimeout(window.imageSizeInitTimer), appCloseVideoNoticeWeb(), 
NativePlayGif.clean(), needCleanDoms.forEach(function(e) {
e.off();
}), needCleanDoms = [], imprProcessQueue = [], flushErrors(!0), $("header").replaceWith("<header>"), 
$("article").empty(), $("footer").empty(), $(document).off("scroll"), "onGetSeriesLinkPositionTimer" in window && clearInterval(onGetSeriesLinkPositionTimer);
}

function bindStatisticsEvents() {
document.addEventListener("scroll", function() {
imprProcessQueue.length > 0 && imprProcessQueue.forEach(function(e, t, a) {
e && isElementInViewportY(e[0], e[4]) && (e[5] && 3 === e[5].version ? sendUmengEventV3(e[1], e[3], !!e[5].isDoubleSend) : send_umeng_event(e[1], e[2], e[3]), 
a[t] = void 0);
});
}, !1);
var e = $(document.body);
e.on("click", ".pgc-link", function() {
var e, t = "", a = "";
"forum" === Page.article.type ? (send_umeng_event("talk_detail", "click_ugc_header", Page.forumStatisticsParams), 
t = "detail_topic", a = Page.forum_extra.category_name, e = Page.forum_extra.thread_id) : "pgc" === Page.article.type ? (send_umeng_event("detail", "click_pgc_header", {
value: Page.author.mediaId,
extra: {
item_id: Page.statistics.item_id
}
}), t = "detail_article", a = Page.category_name, e = Page.statistics.group_id) : (t = "detail_answer_wenda", 
a = wenda_extra.gd_ext_json ? wenda_extra.gd_ext_json.category_name : "", e = wenda_extra.ansid);
}), e.on("click", "#prev_serial_link", function() {
send_umeng_event("detail", "click_pre_group", {
value: Page.statistics.group_id,
extra: {
item_id: Page.statistics.item_id
}
});
}).on("click", "#next_serial_link", function() {
send_umeng_event("detail", "click_next_group", {
value: Page.statistics.group_id,
extra: {
item_id: Page.statistics.item_id
}
});
}).on("click", "#index_serial_link", function() {
send_umeng_event("detail", "click_catalog", {
value: Page.statistics.group_id,
extra: {
item_id: Page.statistics.item_id
}
});
}), e.on("click", ".custom-video", function() {
playVideo(this, 0);
}), e.on("click", "#digg", function() {
"digged" === $(this).attr("wenda-state") ? ToutiaoJSBridge.call("toast", {
text: "你已经赞过",
icon_type: "icon_error"
}) : "buryed" === $("#bury").attr("wenda-state") ? ToutiaoJSBridge.call("toast", {
text: "你已经踩过",
icon_type: "icon_error"
}) : ToutiaoJSBridge.call("page_state_change", {
type: "wenda_digg",
id: $(this).attr("data-answerid"),
status: 1
});
}), e.on("click", "#bury", function() {
"buryed" === $(this).attr("wenda-state") ? ToutiaoJSBridge.call("toast", {
text: "你已经踩过",
icon_type: "icon_error"
}) : "digged" === $("#digg").attr("wenda-state") ? ToutiaoJSBridge.call("toast", {
text: "你已经赞过",
icon_type: "icon_error"
}) : ToutiaoJSBridge.call("page_state_change", {
type: "wenda_bury",
id: $(this).attr("data-answerid"),
status: 1
});
});
}

function playVideo(e, t) {
var a = e.getBoundingClientRect(), i = {
sp: e.getAttribute("data-sp"),
vid: e.getAttribute("data-vid"),
frame: [ a.left + window.pageXOffset, a.top + window.pageYOffset, a.width, a.height ],
status: t
};
"object" == typeof window.wenda_extra && (i.extra = {
log_pb: wenda_extra.gd_ext_json && wenda_extra.gd_ext_json.log_pb ? wenda_extra.gd_ext_json.log_pb : "",
group_source: 10,
group_id: wenda_extra.ansid,
video_id: e.getAttribute("data-vid"),
category_id: wenda_extra.gd_ext_json && wenda_extra.gd_ext_json.category_name ? wenda_extra.gd_ext_json.category_name : "question_and_answer",
category_name: wenda_extra.gd_ext_json && wenda_extra.gd_ext_json.category_name ? wenda_extra.gd_ext_json.category_name : "question_and_answer",
qid: wenda_extra.qid,
ansid: wenda_extra.ansid,
value: wenda_extra.ansid,
enter_from: wenda_extra.enter_from,
position: "detail",
parent_enterfrom: wenda_extra.parent_enterfrom || "",
group_id: Page.statistics.group_id,
article_type: wenda_extra.article_type || wenda_extra.gd_ext_json ? wenda_extra.gd_ext_json.article_type : ""
}), window.ToutiaoJSBridge.call("playNativeVideo", i, null);
}

function obj2search(e) {
return Object.keys(e).reduce(function(t, a) {
return t + "&" + a + "=" + e[a];
}, "").substr(1);
}

function onCarouselImageSwitch(e) {
console.info("onCarouselImageSwitch", e), ToutiaoJSBridge.call("loadDetailImage", {
type: (IOSImageProcessor.isDuoTuThread ? "thumb" : "origin") + "_image",
index: e
});
}

function doInitImage() {
window.NativePlayGifSwitch = Page.h5_settings.is_use_native_play_gif, IOSImageProcessor.threadGGSwitch = "forum" === Page.article.type && Page.use_9_layout, 
IOSImageProcessor.image_type = Page.pageSettings.image_type, IOSImageProcessor.lazy_load = Page.pageSettings.use_lazyload, 
IOSImageProcessor.start(), window.imageInited = !0;
}

function doInitVideo() {
("pgc" == Page.article.type || "wenda" == Page.article.type) && processCustomVideo();
}

function checkWindowSize() {
window.iH = window.innerHeight, window.aW = window.innerWidth - 30, window.aW <= 0 || window.iH <= 0 ? imageSizeInitTimer = setTimeout(function() {
checkWindowSize();
}, 250) : (doInitImage(), doInitVideo());
}

function _processArticle() {
switch (checkWindowSize(), processParagraph(), Page.article.type) {
case "forum":
bindRepostEvent();
break;

case "pgc":
processTable(), pgcEvent.emit("card-render", document.body);
break;

case "wenda":
processTable();
}
}

window.client = {
isAndroid: /android/i.test(navigator.userAgent),
isIOS: /iphone|ipad/i.test(navigator.userAgent),
newsArticleVersion: _getNewsArticleVersion()
}, client.osVersion = client.isAndroid ? _getAndroidVersion() : client.isIOS ? _getIOSVersion() : "", 
client.isSeniorAndroid = client.isAndroid ? parseFloat(client.osVersion) >= 4.4 : !0, 
client.isNewsArticleVersionNoLessThan = _isNewsArticleVersionNoLessThan;

var hash = function() {
var e = location.hash.substr(1), t = {};
return e && e.split("&").forEach(function(e) {
e = e.split("=");
var a = e[0], i = e[1];
a && (t[a] = i);
}), function(e, a) {
var i = {};
return void 0 === e && void 0 === a ? location.hash : void 0 === a && "string" == typeof e ? t[e] : ("string" == typeof e && "string" == typeof a ? i[e] = a : void 0 === a && "object" == typeof e && (i = e), 
$.extend(t, i), void (location.hash = hash2string(t)));
};
}(), getMeta = function() {
for (var e = document.getElementsByTagName("meta"), t = {}, a = 0, i = e.length; i > a; a++) {
var o = e[a].name.toLowerCase(), n = e[a].getAttribute("content");
o && n && (t[o] = n);
}
return function(e) {
return t[e];
};
}(), urlAddQueryParams = function(e, t) {
var a, i = [], o = "?";
for (a in t) t.hasOwnProperty(a) && i.push(a + "=" + encodeURIComponent(t[a]));
return -1 !== e.indexOf("?") && (o = "&"), [ e, o, i.join("&") ].join("");
}, event_type = client.isAndroid ? "log_event" : "custom_event", sendBytedanceRequest = function() {
function e() {
r.length > 0 && (i.src = r.shift(), l = Date.now(), t());
}
function t() {
clearTimeout(n), n = setTimeout(e, s);
}
var a = "SEND-BYTE--DANCE-REQUEST", i = document.getElementById(a), o = "bytedance://";
i || (i = document.createElement("iframe"), i.id = a, i.style.display = "none", 
document.body.appendChild(i));
var n, r = [], s = 100, l = Date.now() - s - 1;
return function(e) {
var a = Date.now();
0 === r.length && a - l > s ? (i.src = o + e, l = a) : (r.push(o + e), t());
};
}(), WendaCacheUmeng = [];

!function() {
var e = {};
window.PressState = function(e) {
var t = {
holder: "body",
bindSelector: "",
exceptSelector: "",
pressedClass: "pressed",
triggerLatency: 100,
removeLatency: 100
};
this.settings = $.extend({}, t, e), this._init();
}, PressState.prototype = {
_init: function() {
"" != this.settings.bindSelector && (this._appendClass(), this._bindEvent());
},
_appendClass: function() {
if ("pressed" == this.settings.pressedClass) {
var e = "<style type='text/css'>.pressed{background-color: #e0e0e0 !important;} .night .pressed{background-color: #1b1b1b !important;}</style>";
$("body").append(e);
}
},
_bindEvent: function() {
var t = this.settings.holder, a = "" == this.settings.exceptSelector ? this.settings.bindSelector : [ this.settings.bindSelector, this.settings.exceptSelector ].join(","), i = this.settings.exceptSelector, o = this.settings.pressedClass, n = parseInt(this.settings.triggerLatency), r = parseInt(this.settings.removeLatency);
$(t).on("touchstart", a, function(t) {
if (!$(this).is(i)) {
var a = $(this);
e.mytimer = setTimeout(function() {
a.addClass(o);
}, n), e.tar = t.target;
}
}), $(t).on("touchmove", a, function() {
$(this).is(i) || (clearTimeout(e.mytimer), $(this).removeClass(o), e.tar = null);
}), $(t).on("touchend touchcancel", a, function(t) {
if (!$(this).is(i) && e.tar === t.target) {
clearTimeout(e.mytimer), $(this).hasClass(o) || $(this).addClass(o);
var a = $(this);
setTimeout(function() {
a.removeClass(o);
}, r);
}
});
}
};
}();

var baseFilePath = function() {
function e() {
for (var e = document.querySelectorAll("script"), a = 0, i = e.length; i > a; a++) {
var o = e[a].src, n = o.indexOf("/v55/js/lib.js");
if (n > -1) {
t = o.substr(0, n);
break;
}
if (n = o.indexOf("/v60/js/lib.js"), n > -1) {
t = o.substr(0, n);
break;
}
}
t && (t += "/shared/");
}
var t = "";
return function() {
return t || e(), t;
};
}(), getCommonParams = function() {
function e(e) {
ToutiaoJSBridge.call("TTNetwork.commonParams", {}, function(a) {
t = a.data || a, "function" == typeof e && e(t);
});
}
var t;
return e(), function(a) {
t ? "function" == typeof a && a(t) : a && e(a);
};
}(), fnTimeCountDown = function(e, t, a, i) {
var o = {
time_delta: t - new Date().getTime(),
zero: function(e) {
var e = parseInt(e, 10);
return e > 0 ? (9 >= e && (e = "0" + e), String(e)) : "00";
},
dv: function() {
e = e || Date.now();
var t = new Date(e), a = new Date(), n = Math.round((t.getTime() - (a.getTime() + this.time_delta)) / 1e3), r = {
sec: "00",
mini: "00",
hour: "00"
};
return n > 0 ? (r.sec = o.zero(n % 60), r.mini = Math.floor(n / 60) > 0 ? o.zero(Math.floor(n / 60) % 60) : "00", 
r.hour = Math.floor(n / 3600) > 0 ? o.zero(Math.floor(n / 3600) % 24) : "00") : i && i(), 
r;
},
ui: function() {
a.sec && (a.sec.innerHTML = o.dv().sec + "秒"), a.mini && (a.mini.innerHTML = o.dv().mini + "分"), 
a.hour && (a.hour.innerHTML = o.dv().hour + "小时"), setTimeout(o.ui, 1e3);
}
};
o.ui();
}, renderHeader = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) {
if (__p += '<header topbutton-type="' + (null == (__t = data.topbuttonType) ? "" : __t) + '" sugstate="no" ' + (null == (__t = data.hasExtraSpace ? "" : "no-extra-space") ? "" : __t) + ">", 
__p += "", data.h5_settings.pgc_over_head || (__p += '<div class="tt-title">' + (null == (__t = data.article.title) ? "" : __t) + "</div>"), 
__p += "", __p += "", "zhuanma" == data.article.type) __p += '<div class="zhuanma-wrapper"><span class="zm-time">' + (null == (__t = data.article.publishTime) ? "" : __t) + '</span><span class="zm-author">' + (null == (__t = data.author.name) ? "" : __t) + "</span></div>"; else if ("pgc" != data.article.type || !data.novel_data || data.novel_data.can_read) {
if (__p += '<div class="authorbar ' + (null == (__t = data.article.type) ? "" : __t) + '" id="profile">', 
__p += '<a class="author-avatar-link pgc-link" href="' + (null == (__t = data.author.link) ? "" : __t) + '"><div class="author-avatar"><img class="author-avatar-img" src="' + (null == (__t = data.author.avatar) ? "" : __t) + '"></div>', 
data.useServerV && data.author.auth_info && (__p += "" + (null == (__t = buildServerVIcon2(data.author.auth_type, "avatar_icon")) ? "" : __t)), 
__p += "</a>", data.showUserDecoration && data.author.user_decoration && data.author.user_decoration.url && (__p += '<div class="avatar-decoration" style="background-image: url(' + (null == (__t = data.author.user_decoration.url) ? "" : __t) + ')"></div>'), 
__p += '<a class="avatar-decoration avatar-night-mask pgc-link" href="' + (null == (__t = data.author.link) ? "" : __t) + '"></a>', 
__p += "", "wenda" === data.article.type ? __p += '<div class="wenda-info" style="display: ' + (null == (__t = data.author.isAuthorSelf ? "block" : "none") ? "" : __t) + ';"><span class="read-info brow-count"></span><span class="like-info digg-count-special"></span></div>' : "forum" === data.article.type && (__p += '<div class="wenda-info" style="display: ' + (null == (__t = data.author.isAuthorSelf ? "block" : "none") ? "" : __t) + ';"><span></span></div>'), 
__p += "", __p += '<div class="author-function-buttons" style="display: ' + (null == (__t = data.author.isAuthorSelf || "wenda" === data.article.type && data.h5_settings.is_liteapp || "forum" === data.article.type && "following" === data.author.followState || data.hideFollowButton ? "none" : "block") ? "" : __t) + ';"><div class="mediasug-arrow-button iconfont"></div><button class="subscribe-button follow-button ' + (null == (__t = "followState" in data.author ? data.author.followState : "disabled") ? "" : __t) + " " + (null == (__t = data.isRedFocusButton ? "red-follow-button" : "") ? "" : __t) + " " + (null == (__t = data.focusButtonStyle) ? "" : __t) + '"data-user-id="' + (null == (__t = data.author.userId) ? "" : __t) + '"data-media-id="' + (null == (__t = data.author.mediaId) ? "" : __t) + '"id="subscribe"><i class="iconfont focusicon">&nbsp;</i><i class="redpack"></i></button></div>', 
__p += '<div class="author-bar"><div class="name-link-wrap"><div class="name-link-w ' + (null == (__t = "wenda" === data.article.type && 0 === data.tags.length ? "no-intro" : "") ? "" : __t) + '">', 
("forum" === data.article.type || "wenda" === data.article.type) && data.author.medals && data.h5_settings.ugc_user_medal) {
__p += '<div class="article-medal">';
for (var medal in data.author.medals) {
var _medal = data.author.medals[medal];
__p += "", data.h5_settings.ugc_user_medal[_medal] && (__p += '<img src="' + (null == (__t = data.h5_settings.ugc_user_medal[_medal]) ? "" : __t) + '">'), 
__p += "";
}
__p += "</div>";
}
if (__p += "", data.useServerV || (__p += "", "" != data.author.verifiedContent && (__p += '<div class="iconfont verified-icon">&#xe600;</div>'), 
__p += ""), __p += '<a class="author-name-link pgc-link" href="' + (null == (__t = data.author.link) ? "" : __t) + '">' + (null == (__t = data.author.name) ? "" : __t) + '</a></div></div><a class="sub-title-w" href="' + (null == (__t = data.author.link) ? "" : __t) + '"><div class="article-tags">', 
data.tags.length > 0) {
__p += "";
for (var tag in data.tags) __p += "", __p += "原创" == data.tags[tag] ? '<div class="article-tag-original"></div>' : '<div class="article-tag">' + (null == (__t = data.tags[tag]) ? "" : __t) + "</div>", 
__p += "";
__p += "";
}
__p += "</div>", "pgc" === data.article.type ? __p += '<span class="sub-title">' + (null == (__t = data.article.publishTime) ? "" : __t) + "</span>" : "forum" === data.article.type && (__p += '<span class="sub-title">' + (null == (__t = data.article.publishTime) ? "" : __t) + (null == (__t = data.author.remarkName && data.article.publishTime ? "&nbsp;&middot;&nbsp;" : "") ? "" : __t) + (null == (__t = data.author.remarkName ? data.author.remarkName : "") ? "" : __t) + "</span>"), 
__p += "</a></div></div>", __p += '<div class="mediasug-outer-container"><div class="mediasug-inner-container"><div class="ms-pointer"></div><div class="ms-title">相关推荐</div><div class="ms-list" id="mediasug-list"><div class="ms-list-scroller" id="mediasug-list-html"></div></div></div></div>';
} else __p += '<div class="empty_authorbar"></div>';
__p += "", __p += "", data.h5_settings.pgc_over_head && (__p += '<div class="tt-title pgc-over-head">' + (null == (__t = data.article.title) ? "" : __t) + "</div>"), 
__p += "</header>";
}
return __p;
}, renderFooter = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += "<footer>", data.wenda_extra && (__p += "", 
data.wenda_extra.wd_version >= 3 ? (__p += '<div class="wd-footer"><a href="#" class="link-more" id="wd-link-more" style="display:none;">了解更多</a><div class="publish-datetime">' + (null == (__t = data.article.publishTime) ? "" : __t) + "</div>", 
__p += data.wenda_extra.wd_version >= 6 ? '<a class="report no-icon" style="display:none" onclick="ToutiaoJSBridge.call(\'report\')">举报</a><span style="display:none" class="sep for-report" style="font-size:12px;">|</span><a class="editor-edit-answer no-icon" style="display:none">编辑</a><div item="dislike-and-report" class="dislike-and-report no-icon" style="display:none;" >反对</div>' : '<a class="editor-edit-answer" style="display:none">编辑</a><div class="dislike-and-report" onclick="ToutiaoJSBridge.call(\'dislike\', {options: 0x11});">不喜欢</div>', 
__p += "</div>") : __p += '<div class="wenda-bottom clearfix"><div class="create-time">' + (null == (__t = data.article.publishTime) ? "" : __t) + '</div></div><div class="bottom-buttons only-one"><div id="digg" data-answerid="' + (null == (__t = data.wenda_extra.ansid) ? "" : __t) + '" class="ib like" wenda-state="" aniok="' + (null == (__t = data.wenda_extra.aniok) ? "" : __t) + '"><span class="ibinner"><i class="iconfont iconb">&nbsp;</i><span class="b digg-count" realnum="0">赞</span></span></div><div id="bury" data-answerid="' + (null == (__t = data.wenda_extra.ansid) ? "" : __t) + '" class="ib unlike" wenda-state="" aniok="' + (null == (__t = data.wenda_extra.aniok) ? "" : __t) + '" style="display: none;"><span class="ibinner"><i class="iconfont iconb">&nbsp;</i><span class="b bury-count" realnum="0">踩</span></span></div></div>', 
__p += ""), __p += "", data.novel_data ? (__p += "", data.novel_data.can_read ? (__p += "", 
data.novel_data.show_new_keep_reading ? (__p += '<div class="serial special-serial">', 
data.novel_data.next_group_url && (__p += '<a class="next special-next" id="next_serial_link" href="' + (null == (__t = data.novel_data.use_deep_reader && data.novel_data.next_deep_reader_schema_url ? data.novel_data.next_deep_reader_schema_url : data.novel_data.next_group_url) ? "" : __t) + '">点击继续阅读 <i class="iconfont icon-next"></i></a>'), 
__p += "</div>") : (__p += '<div class="serial">', __p += data.novel_data.pre_group_url ? '<a class="prev" id="prev_serial_link" href="' + (null == (__t = data.novel_data.use_deep_reader && data.novel_data.pre_deep_reader_schema_url ? data.novel_data.pre_deep_reader_schema_url : data.novel_data.pre_group_url) ? "" : __t) + '">上一章</a>' : '<span class="prev disabled">上一章</span>', 
__p += "", __p += data.novel_data.next_group_url ? '<a class="next" id="next_serial_link" href="' + (null == (__t = data.novel_data.use_deep_reader && data.novel_data.next_deep_reader_schema_url ? data.novel_data.next_deep_reader_schema_url : data.novel_data.next_group_url) ? "" : __t) + '">下一章</a>' : '<span class="next disabled">下一章</span>', 
__p += '<div class="index-wrap"><a class="index" id="index_serial_link" href="' + (null == (__t = data.novel_data.url) ? "" : __t) + '">目录（共' + (null == (__t = data.novel_data.serial_count) ? "" : __t) + "章）</a></div></div>"), 
__p += "") : (__p += '<div class="pay">', data.pay_status ? (2 == data.pay_status || -1 == data.pay_status && !data.is_login) && (__p += '<div class="split"></div><div class="button"><button class="buy"></button></div>') : __p += '<div class="split"></div><div class="content">当前版本不支持阅读付费章节，请升级到最新版本继续阅读</div><div class="button"><button class="update"></button></div>', 
__p += "</div>"), __p += "") : data.wenda_extra && data.wenda_extra.wd_version >= 1 && data.wenda_extra.wd_version < 3 && (__p += '<div class="serial" style="display: ' + (null == (__t = data.wenda_extra.wd_version >= 2 ? "block" : "none") ? "" : __t) + ';"><a class="prev" id="wenda_index_link"><span id="total-answer-count-index"></span></a><a class="next" id="next_answer_link" onclick="ToutiaoJSBridge.call(\'tellClientRetryPrefetch\');">下一个回答</a></div>'), 
__p += "</footer>";
return __p;
}, globalWendaStates = {}, TouTiao = {
setFontSize: setFontSize,
setDayMode: setDayMode
}, sendWeitoutiaoCardDisplayEvent = function() {
var e = "out", t = !0;
return function(a) {
if (a && a.needRecord && (t = a.needRecord), t) {
var i = $(".pcard.forum").get(0), o = "out", n = i.getBoundingClientRect();
n.bottom <= (window.innerHeight || document.body.clientHeight) && (o = "in"), "in" === o && "out" === e && (console.info("weitoutiao_in"), 
send_umeng_event("widget", "show_wtt", {
value: $("[data-content]").get(0).dataset.id,
extra: {
card_type: "1"
}
}), t = !1), e = o;
}
};
}(), contextRenderer = function(context) {
if ("object" == typeof context) {
if (context.motor_info && context.motor_info.dealer_cards) {
for (var reqId = context.motor_info.req_id || "", dealerCards = context.motor_info.dealer_cards || [], seriesIds = [], seriesNames = [], positions = [], i = 0; i < dealerCards.length; i++) seriesIds.push(dealerCards[i].series_id), 
seriesNames.push(dealerCards[i].series_name), positions.push(dealerCards[i].pos);
sendUmengEventV3("web_page_enter", {
obj_id: "detail_scard_n_consultation",
page_id: "page_detail",
data_from: "motor_media",
group_id: Page.statistics.group_id,
media_id: Page.author.mediaId,
media_name: Page.author.name,
series_id: seriesIds.join(","),
series_name: seriesNames.join(","),
position: positions.join(","),
req_id: reqId,
extra_params: JSON.stringify({})
}, !1);
var paragraphLen = $("article > div p").length, cityName = context.motor_info.city_name || "北京", oldTemplateFunction = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="pcard motor-dealer-old"><em class="iconfont close-dealer-card j-close-dealer-card" style="' + (null == (__t = data.dislike_show ? "initial" : "none") ? "" : __t) + '">&#xe66e;</em><div class="motor-form-edit"><div class="motor-form-head j-motor-form-head"><h3 class="motor-car-name">' + (null == (__t = data.series_name) ? "" : __t) + '</h3><p class="motor-car-price">' + (null == (__t = data.text1 || "厂商指导价") ? "" : __t) + '：<span class="price">' + (null == (__t = data.price) ? "" : __t) + '</span></p></div><div class="motor-form-body"><input type="text" class="motor-form-user j-motor-form-user" name="userName" placeholder="输入您的姓名" /><span class="motor-form-tip">请输入您的姓名</span><input type="tel" class="motor-form-mobile j-motor-form-mobile" name="userMobile" maxlength="11" placeholder="输入您的手机号" /><span class="motor-form-tip">请输入正确的手机号</span><label for="motor-form-agree-' + (null == (__t = data.pos) ? "" : __t) + '" class="motor-form-agree-wrap"><input type="checkbox" id="motor-form-agree-' + (null == (__t = data.pos) ? "" : __t) + '" class="motor-form-agree" name="userAgree" checked="checked" /><i class="pcard-icon motor-icon-cb"></i><span class="motor-form-agree-label">同意<a class="motor-form-agree-link" href="sslocal://webview?url=http%3A%2F%2Fi.snssdk.com%2Fmotor%2Fugc%2Fstatement.html&hide_bar=1">《个人信息保护声明》</a></span></label><button class="motor-form-btn j-motor-form-btn">' + (null == (__t = data.text2 || "立即获取最低价") ? "" : __t) + '</button></div><p class="motor-form-foot">我们将为你选出<strong>最低报价</strong>的4S店为你服务</p></div><div class="motor-form-sheet"><h4 class="motor-sheet-car">' + (null == (__t = data.series_name) ? "" : __t) + '</h4><p class="motor-sheet-title">您的资料已经成功提交</p><p class="motor-sheet-tip">我们将为你选出<strong>最低报价</strong>的4S店为你服务</p><button class="motor-sheet-rewrite j-motor-sheet-rewrite"><em class="iconfont">&#xe654;</em>重新填写</button></div></div>';
return __p;
}, templateFunction = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="pcard motor-dealer"><em class="iconfont close-dealer-card j-close-dealer-card" style="display: ' + (null == (__t = data.dislike_show ? "initial" : "none") ? "" : __t) + ';">&#xe66e;</em><div class="motor-form-edit"><div class="motor-form-normal j-motor-form-normal"><div class="motor-form-left"><h3 class="motor-car-name">' + (null == (__t = data.series_name) ? "" : __t) + '</h3><p class="motor-car-price">' + (null == (__t = data.text1 || "厂商指导价") ? "" : __t) + '：<span class="price">' + (null == (__t = data.price) ? "" : __t) + '</span></p></div><button class="motor-form-right motor-form-enter-btn j-motor-enter">' + (null == (__t = data.text3 || "展开询价") ? "" : __t) + '<em class="iconfont">&#xe609;</em></button></div><div class="motor-form-body"><input type="text" class="motor-form-input motor-form-user j-motor-form-user" name="userName" placeholder="输入您的姓名" /><span class="motor-form-tip">请输入您的姓名</span><input type="tel" class="motor-form-input motor-form-mobile j-motor-form-mobile" name="userMobile" maxlength="11" placeholder="输入您的手机号" /><span class="motor-form-tip">请输入正确的手机号</span><label for="motor-form-agree-' + (null == (__t = data.pos) ? "" : __t) + '" class="motor-form-agree-wrap"><input type="checkbox" id="motor-form-agree-' + (null == (__t = data.pos) ? "" : __t) + '" class="motor-form-agree" name="userAgree" checked="checked" /><i class="pcard-icon motor-icon-cb"></i><span class="motor-form-agree-label">同意<a class="motor-form-agree-link" href="sslocal://webview?url=http%3A%2F%2Fi.snssdk.com%2Fmotor%2Fugc%2Fstatement.html&hide_bar=1">《个人信息保护声明》</a></span></label><button class="motor-form-btn j-motor-form-btn">' + (null == (__t = data.text2 || "立即获取最低价") ? "" : __t) + '</button><p class="motor-form-foot">我们将为你选出最低报价的4S店为你服务</p></div></div><div class="motor-form-sheet"><h4 class="motor-sheet-car">' + (null == (__t = data.series_name) ? "" : __t) + '</h4><p class="motor-sheet-title">您的资料已经成功提交</p><p class="motor-sheet-tip">我们将为你选出最低报价的4S店为你服务</p><button class="motor-sheet-rewrite j-motor-sheet-rewrite"><em class="iconfont">&#xe654;</em>重新填写</button></div></div>';
return __p;
};
dealerCards.forEach(function(e) {
e.card_type || 1, 1 === e.card_type ? oldMotorDealerContextRender(oldTemplateFunction, paragraphLen, cityName, reqId, e) : motorDealerContextRender(templateFunction, paragraphLen, cityName, reqId, e);
});
}
wendaContextRender(context), function() {
var cardTemplateFunctions = {
fiction: function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<a class="pcard fiction" href="' + (null == (__t = url) ? "" : _.escape(__t)) + '"><div class="pcard-container pcard-vertical-border"><div class="pcard-clearfix"><div class="pcard-pull-left" style="position: relative"><img class="fiction-image" src="' + (null == (__t = poster) ? "" : _.escape(__t)) + '"/><span class="tag ' + (null == (__t = 0 == free_status || 2 == free_status ? "free" : 3 == free_status ? "sell" : "") ? "" : __t) + '"></span></div><div class="fiction-right"><button class="button pcard-button fiction-button pcard-pull-right ' + (null == (__t = isRedButton ? "red-pcard-button" : "") ? "" : __t) + " " + (null == (__t = buttonStyle ? buttonStyle : "") ? "" : __t) + '" action="concern" is-concerned="' + (null == (__t = Boolean(is_concerned)) ? "" : _.escape(__t)) + '" concern-id="' + (null == (__t = concern_id) ? "" : _.escape(__t)) + '" forum-id="' + (null == (__t = forum_id) ? "" : _.escape(__t)) + '" book-id="' + (null == (__t = book_id) ? "" : _.escape(__t)) + '">' + (null == (__t = is_concerned ? "查看书架" : "加入书架") ? "" : _.escape(__t)) + '</button><div class="pcard-h16 pcard-w1 pcard-o1" style="margin-top: 2px">' + (null == (__t = name) ? "" : _.escape(__t)) + '</div><div class="pcard-h14 pcard-w1" style="margin-top: 4px">' + (null == (__t = 0 == creation_status ? "已完结" : "连载中") ? "" : __t) + " " + (null == (__t = word_number) ? "" : _.escape(__t)) + "</div>", 
0 == free_status ? __p += '<div class="pcard-h14 pcard-w1" style="margin-top: 4px">免费书籍，自由畅读</div>' : 1 == free_status ? __p += '<div class="pcard-h14 pcard-w1" style="margin-top: 4px">' + (null == (__t = base_price) ? "" : _.escape(__t)) + "书币／千字</div>" : (2 == free_status || 3 == free_status) && (__p += '<div class="pcard-h12 pcard-o1" style="margin-top: 6px"><span class="pcard-w9 pcard-w-delete origin-price">' + (null == (__t = base_price) ? "" : _.escape(__t)) + '书币／千字</span> &nbsp; <span class="pcard-w1 sale-price">' + (null == (__t = discount_price) ? "" : _.escape(__t)) + '书币／千字</span></div><div class="pcard-h12 pcard-w4 sale" style="margin-top: 4px">限时' + (null == (__t = 2 == free_status ? "免费" : "特价") ? "" : __t) + '，还剩<span id="day"></span><span id="hour"></span><span id="mini"></span><span id="sec"></span></div>'), 
__p += "</div></div></div></a>";
return __p;
},
auto: function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="pcard  auto"><div class="pcard-caption"><span class="pcard-h14 pcard-w1">相关车型</span><span class="pcard-h14 pcard-w3 pcard-vr icon-vr width16"></span><span class="pcard-h14 pcard-w3">数据来源于' + (null == (__t = data.data_source_show) ? "" : __t) + '</span></div><div class="p-autocard pcard-container pcard-vertical-border" data-href="' + (null == (__t = data.open_url) ? "" : __t) + '" data-content="content"><div class="pcard-clearfix"><div class="auto-image pcard-pull-left ' + (null == (__t = "dongchedi" == data.data_source ? "no-bg" : "") ? "" : __t) + '" style="background-image: url(' + (null == (__t = data.cover_url) ? "" : __t) + ');"></div><div class="container-right"><button type="button" class="pcard-button pcard-pull-right ' + (null == (__t = data.isRedButton ? "red-pcard-button" : "") ? "" : __t) + " " + (null == (__t = data.buttonStyle ? data.buttonStyle : "") ? "" : __t) + '" data-href="' + (null == (__t = "dongchedi" == data.data_source && data.xunjia_web_url ? data.xunjia_web_url : data.open_url) ? "" : __t) + '" style="margin-top: ' + (null == (__t = "dongchedi" === data.data_source ? "18px" : "") ? "" : __t) + '">' + (null == (__t = "dongchedi" == data.data_source ? "询底价" : "详情") ? "" : __t) + '</button><div class="" style="margin-right: 88px;"><div class="pcard-h16 pcard-w1" style="margin-bottom: 5px; padding-top: ' + (null == (__t = "dongchedi" === data.data_source ? "10px" : "") ? "" : __t) + '">' + (null == (__t = data.car_series) ? "" : __t) + "</div>", 
"rate" in data && (__p += '<div class="pcard-h12 iconfont film-star-score" style="margin-bottom: 5px;">' + (null == (__t = buildScoreByStar(Math.ceil(2 * data.rate))) ? "" : __t) + "&nbsp;" + (null == (__t = data.rate) ? "" : __t) + "</div>"), 
__p += "</div>", __p += "dongchedi" == data.data_source ? '<div class="pcard-w1 pcard-o1"><span class="pcard-w4 pcard-h16">' + (null == (__t = data.show_agent_price ? data.show_agent_price : "暂无报价") ? "" : __t) + '</span><span class="pcard-w4 pcard-h12">' + (null == (__t = data.show_agent_price ? data.show_agent_price_unit : "") ? "" : __t) + '</span>&nbsp;<span class="pcard-w3 pcard-h12 pcard-w-delete">' + (null == (__t = data.show_agent_price ? data.show_origin_price ? data.show_origin_price : "暂无报价" : "") ? "" : __t) + (null == (__t = data.show_agent_price && data.show_origin_price ? data.show_origin_price_unit : "") ? "" : __t) + "</span></div>" : '<div class="pcard-h14 pcard-w1">' + (null == (__t = data.price_prefix) ? "" : __t) + '<span class="pcard-w4">' + (null == (__t = data.price) ? "" : __t) + "</span></div>", 
__p += "</div></div>", Array.isArray(data.jump_url) && data.jump_url.length >= 4 && (__p += '<div class="mt8"><a class="pcard-h14 pcard-w1-a" href="' + (null == (__t = data.jump_url[0]) ? "" : __t) + '" data-label="card_ask">询底价</a><span class="pcard-h14 pcard-w3 pcard-vr icon-vr" style="width: 30px;"></span><a class="pcard-h14 pcard-w1-a" href="' + (null == (__t = data.jump_url[1]) ? "" : __t) + '" data-label="card_second">二手车</a><span class="pcard-h14 pcard-w3 pcard-vr icon-vr" style="width: 30px;"></span><a class="pcard-h14 pcard-w1-a" href="' + (null == (__t = data.jump_url[2]) ? "" : __t) + '" data-label="card_sale">厂商活动</a><span class="pcard-h14 pcard-w3 pcard-vr icon-vr" style="width: 30px;"></span><a class="pcard-h14 pcard-w1-a" href="' + (null == (__t = data.jump_url[3]) ? "" : __t) + '" data-label="card_stages">分期买车</a></div>'), 
__p += "</div></div>";
return __p;
},
stock: function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) {
if (__p += '<div class="pcard op-stock">', data.length >= 3) {
__p += '<div class="pcard-container pcard-vertical-border opstock-body">';
for (var i in data) {
var _tempStock = data[i];
__p += '<div class="pcard-h16-large opstock-item"><a href="' + (null == (__t = _tempStock.url) ? "" : __t) + '" data-label = "card_detail"><span class="pcard-w1" style="width:64px;">' + (null == (__t = _tempStock.name) ? "" : __t) + "</span>", 
__p += 2 == _tempStock.rise ? '<span class="opstock-txt-up ml15">' + (null == (__t = _tempStock.price) ? "" : __t) + '</span><span class="opstock-txt-up ml15">' + (null == (__t = _tempStock.rate) ? "" : __t) + "</span>" : 3 == _tempStock.rise ? '<span class="opstock-txt-down ml15">' + (null == (__t = _tempStock.price) ? "" : __t) + '</span><span class="opstock-txt-down ml15">' + (null == (__t = _tempStock.rate) ? "" : __t) + "</span>" : '<span class="opstock-txt-stop ml15">' + (null == (__t = _tempStock.price) ? "" : __t) + '</span><span class="opstock-txt-stop ml15">' + (null == (__t = _tempStock.rate) ? "" : __t) + "</span>", 
__p += "</a>", __p += 0 == _tempStock.selected ? '<a class="button pcard-pull-right pcard-w1 opstock-button" data-stock="' + (null == (__t = _tempStock.code) ? "" : __t) + '" action="addStock"><span><i class="pcard-icon opstock-iconfont icon-plus"></i></span>自选股</a>' : '<a class="pcard-pull-right pcard-w3"><span><i class="pcard-icon opstock-iconfont icon-done"></i></span>已添加</a>', 
__p += "</div>";
}
__p += '</div><a class="pcard-w1 pcard-h14 pcard-footer" href="sslocal://webview?hide_bar=1&bounce_disable=1&url=http%3A%2F%2Fic.snssdk.com%2Fstock%2Fget_quota%2F%23tab%3Dportfolio" data-label="card_selected">进入我的自选股<span><i class="pcard-icon opstock-iconfont icon-rarrow opstock-rarrow"></i></span></a>';
} else __p += '<div class="pcard-caption"><span class="pcard-h14 pcard-w1">相关股票</span></div><div class="pcard-container pcard-border opstock-body-single" ><div class="pcard-clearfix"><div class="pcard-pull-left opstock-block ' + (null == (__t = 2 === data[0].rise ? "opstock-upblock" : 3 === data[0].rise ? "opstock-downblock" : "opstock-stopblock") ? "" : __t) + '" data-label="card_content" data-href="' + (null == (__t = data[0].url) ? "" : __t) + '"><div class="opstock-price">' + (null == (__t = 0 === data[0].rise ? "停牌" : data[0].price) ? "" : __t) + '</div><div class="opstock-change">' + (null == (__t = 0 === data[0].rise ? 0 : data[0].change) ? "" : __t) + "(" + (null == (__t = 0 === data[0].rise ? "0.00%" : data[0].rate) ? "" : __t) + ')</div></div><div class="opstock-right opstock-info"><button class="button pcard-button pcard-pull-right opstock-button-single ml8 mt16 ' + (null == (__t = isRedButton ? "red-pcard-button" : "") ? "" : __t) + " " + (null == (__t = buttonStyle ? buttonStyle : "") ? "" : __t) + '" ' + (null == (__t = data[0].selected ? "selected" : "") ? "" : __t) + ' data-stock="' + (null == (__t = data[0].code) ? "" : __t) + '" action="addStock" type=\'single\'><i class="pcard-icon opstock-iconfont icon-plus"></i></button><div class="pcard-h16 pcard-w1 pcard-o1" style="font-weight: bold; margin-top: 8px;" data-label="card_content" data-href="' + (null == (__t = data[0].url) ? "" : __t) + '">' + (null == (__t = data[0].name) ? "" : _.escape(__t)) + '</div><div class="pcard-h14 pcard-w3" style="margin-top: 4px;" data-label="card_content" data-href="' + (null == (__t = data[0].url) ? "" : __t) + '">', 
("HK" == data[0].market || "US" == data[0].market) && (__p += '<i class="pcard-icon opstock-iconfont ' + (null == (__t = "HK" == data[0].market ? "icon-hk" : "icon-us") ? "" : __t) + '"></i>'), 
__p += "" + (null == (__t = data[0].code) ? "" : _.escape(__t)) + '</div></div></div><a class="pcard-w1 pcard-h14 pcard-footer" href="sslocal://webview?hide_bar=1&bounce_disable=1&url=http%3A%2F%2Fic.snssdk.com%2Fstock%2Fget_quota%2F%23tab%3Dportfolio" data-label="card_selected">进入我的自选股<span><i class="pcard-icon opstock-iconfont icon-rarrow opstock-rarrow"></i></span></a></div>';
__p += "</div>";
}
return __p;
},
weitoutiao: function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) {
if (__p += '<div class="pcard forum"><div class="pcard-caption"><span class="pcard-h14 pcard-w1">微头条</span></div><div class="p-autocard pcard-container pcard-vertical-border" data-href="' + (null == (__t = data.open_url) ? "" : __t) + '" data-id="' + (null == (__t = data.id) ? "" : __t) + '" data-content="content"><div class="pcard-clearfix"><div class="header"><div class="authorbar" id="profile">', 
__p += '<a class="author-avatar-link"><div class="author-avatar"><img class="author-avatar-img" src="' + (null == (__t = data.user.avatar) ? "" : __t) + '"></div>', 
data.useServerV && data.user.auth && (__p += "" + (null == (__t = buildServerVIcon2(data.user.auth.auth_type, "avatar_icon")) ? "" : __t)), 
__p += '</a><div class="author-bar"><div class="name-link-wrap"><div class="name-link-w"><a class="author-name-link">' + (null == (__t = data.user.name) ? "" : __t) + '</a></div></div><a class="sub-title-w"><span class="sub-title">' + (null == (__t = data.time_disp) ? "" : __t) + (null == (__t = data.user.auth.auth_info && data.time_disp ? "&nbsp;&middot;&nbsp;" : "") ? "" : __t) + (null == (__t = data.user.auth.auth_info) ? "" : __t) + '</span></a></div></div></div><div class="content">', 
data.text && (__p += '<div class="title-outer"><div class="title-wrap"><div class="title"><span class="title-inner">' + (null == (__t = data.text) ? "" : _.escape(__t)) + "</span></div></div></div>"), 
__p += "", "video" == data.content_type) __p += '<div class="images-wrap video" style="width:' + (null == (__t = data.img_width) ? "" : __t) + "px;height:" + (null == (__t = data.img_height) ? "" : __t) + 'px; margin-bottom: 10px;"><div class="images" style="width:' + (null == (__t = data.img_width) ? "" : __t) + "px;height:" + (null == (__t = data.img_height) ? "" : __t) + "px;background-image: url(" + (null == (__t = data.video.cover_url) ? "" : __t) + ');"></div><i class="custom-video-trigger"></i><i class="custom-video-duration"> ' + (null == (__t = data.video.duration_str) ? "" : __t) + " </i></div>"; else if ("image" == data.content_type) {
__p += '<div style="margin-bottom: 10px;">';
for (var i in data.images) {
var tmp_img = data.images[i];
__p += '<div class="images-wrap ' + (null == (__t = 2 == i && data.more_img ? "more_img" : "") ? "" : __t) + '"><div class="images" style="width:' + (null == (__t = data.img_width) ? "" : __t) + "px;height:" + (null == (__t = data.img_height) ? "" : __t) + "px;background-image: url(" + (null == (__t = tmp_img.url) ? "" : __t) + ');"></div>', 
2 == i && data.more_img && (__p += '<span class="has_more">+' + (null == (__t = data.more_img) ? "" : __t) + "</span>"), 
__p += "</div>";
}
__p += "</div>";
}
__p += '<p class="poi">', data.location && (__p += '<span class="location" style="margin-right: 10px;">' + (null == (__t = data.location) ? "" : __t) + "</span>"), 
__p += "<span>" + (null == (__t = data.read_count_tips) ? "" : __t) + "</span></p></div></div></div></div>";
}
return __p;
},
score_star: function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="pcard score-star" style="margin-top: 15px;"><div class="p-scorecard pcard-container pcard-vertical-border"><div class="pcard-clearfix score-wrapper"><div class="info-wrapper"><div class="title question pcard-h16 pcard-w1" style="margin-top: 3px;">' + (null == (__t = question) ? "" : __t) + '</div><div class="title thx-letter pcard-h16 pcard-w1" style="margin-top: 2px;">谢谢你为文章打分！</div></div><div class="star-wrap mt11"><span class="star" data-index="0" data-selected="false"></span><span class="star" data-index="1" data-selected="false"></span><span class="star" data-index="2" data-selected="false"></span><span class="star" data-index="3" data-selected="false"></span><span class="star" data-index="4" data-selected="false"></span></div><div class="info pcard-h12 pcard-w1 mt11" style="margin-bottom: 3px;">轻触打分</div></div><div class="pcard-clearfix result-wrapper"><div class="thx-press" style="margin-top: 2px;"><span class="press"></span></div><div class="pcard-h16 pcard-w1 mt8">感谢你的打分，你的打分对我们很重要！</div><a class="rescore-button pcard-h12 pcard-w1">重新打分</a></div></div></div>';
return __p;
},
score_emoji: function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="pcard score-emoji ' + (null == (__t = 5 == style ? "has-title" : "") ? "" : __t) + '" style="margin-top: 15px"><div class="p-scorecard pcard-container ' + (null == (__t = 2 == style || 5 == style ? "pcard-vertical-top-border" : "") ? "" : __t) + ' "><div class="pcard-clearfix score-wrapper">', 
(2 == style || 5 == style) && (__p += '<div class="title question pcard-h16 pcard-w1" style="margin-top: 3px;">与其他文章相比，您觉得本文如何？</div>'), 
__p += '<div class="emoji-wrap mt10"><div class="good emoji-button ' + (null == (__t = 3 == style ? "color-bg" : 4 == style || 5 == style ? "grey-bg" : "") ? "" : __t) + '" data-index="0" data-score="5" data-type="good" data-status="init"><span class="pcard-icon good-press button">', 
(3 == style || 4 == style || 5 == style) && (__p += '<span class="press"></span>'), 
__p += '</span><div class="animation-wrapper" id="good-press-animation"></div><div class="pcard-h12 title">' + (null == (__t = letters[0]) ? "" : __t) + '</div></div><div class="general emoji-button ' + (null == (__t = 3 == style ? "color-bg" : 4 == style || 5 == style ? "grey-bg" : "") ? "" : __t) + '" data-index="1" data-score="3" data-type="general" data-status="init"><span class="pcard-icon general-press button">', 
(3 == style || 4 == style || 5 == style) && (__p += '<span class="press"></span>'), 
__p += '</span><div class="animation-wrapper" id="general-press-animation"></div><div class="pcard-h12 title">' + (null == (__t = letters[1]) ? "" : __t) + '</div></div><div class="bad emoji-button ' + (null == (__t = 3 == style ? "color-bg" : 4 == style || 5 == style ? "grey-bg" : "") ? "" : __t) + '" data-index="2" data-score="1" data-type="bad" data-status="init"><span class="pcard-icon bad-press button">', 
(3 == style || 4 == style || 5 == style) && (__p += '<span class="press"></span>'), 
__p += '</span><div class="animation-wrapper" id="bad-press-animation"></div><div class="pcard-h12 title">' + (null == (__t = letters[2]) ? "" : __t) + '</div></div></div></div><div class="pcard-clearfix result-wrapper ' + (null == (__t = 5 == style ? "pcard-vertical-bottom-border" : "") ? "" : __t) + '"><div class="pcard-clearfix"><div class="thx-press" style="margin-top: 2px;"><span id="thx-press-emoji"></span></div><div class="pcard-h16 pcard-w1 mt10" id="thx-word">感谢你的打分，你的打分对我们很重要！</div><a class="rescore-button pcard-h14 ' + (null == (__t = 5 == style ? "pcard-vertical-bottom-border rescore-button-with-bottom" : "") ? "" : __t) + '">重新评价</a></div></div></div></div>';
return __p;
}
};
if ("wenda" === Page.article.type && window.wenda_extra && window.wenda_extra.mis_coop_user && window.wenda_extra.mis_coop_user.uid === Page.author.userId) return void wendaCooperateCard();
var isShowWendaFooter = 1;
if (!("cards" in context && Array.isArray(context.cards))) return void ("wenda" === Page.article.type && isShowWendaFooter && processWendaFooter());
if (context.cards.forEach(function(e) {
var t = e.type, a = {
value: Page.statistics.group_id,
extra: {
item_id: Page.statistics.item_id,
card_type: e.type,
card_id: e.id
}
};
if (t in cardTemplateFunctions) {
if (e.isRedButton = Page.isRedFocusButton, e.buttonStyle = Page.focusButtonStyle, 
"auto" === t) {
e.data_source_show = {
dongchedi: "懂车帝",
yiche: "易车"
}[e.data_source], e.min_price && e.min_price > 0 && (e.show_origin_price = parseFloat(e.min_price), 
e.show_origin_price = e.show_origin_price.toFixed(2), e.show_origin_price_unit = "万起"), 
e.pd_eries_agent_min_price && e.pd_eries_agent_min_price > 0 && (e.show_agent_price = parseFloat(e.pd_eries_agent_min_price), 
e.show_agent_price = e.show_agent_price.toFixed(2), e.show_agent_price_unit = "万起"), 
/^http/.test(e.xunjia_web_url) && (e.xunjia_web_url = "sslocal://webview?url=" + encodeURIComponent(e.xunjia_web_url)), 
a.extra.data_source = "wenda_extra" in Page ? e.data_source + "_wenda" : e.data_source;
var i = $(cardTemplateFunctions[t]({
data: e
}));
} else if ("stock" == t) {
var o = [], n = [];
try {
n = JSON.parse(e.keyphrase_stock);
} catch (r) {}
if (n.forEach(function(t) {
if (e.stocks[t]) try {
o.push(JSON.parse(e.stocks[t]));
} catch (a) {}
}), 0 == o.length) return;
send_umeng_event("stock", "article_with_card", a);
var s = [];
if (s = o.filter(function(e) {
return 0 == e.selected;
}), 0 == s.length) return;
o.map(function(e) {
e.url = "sslocal://webview?hide_bar=1&bounce_disable=1&url=" + encodeURIComponent("http://ic.snssdk.com/stock/slice/?code=" + e.market + e.code + "&from=article"), 
1 == e.selected && s.push(e);
});
var i = $(cardTemplateFunctions[t]({
data: s,
isRedButton: e.isRedButton,
buttonStyle: e.buttonStyle
}));
} else if ("weitoutiao" == t) {
e = e.weitoutiao;
try {
e.user.auth = JSON.parse(e.user.auth);
} catch (r) {}
if ("image" === e.content_type && e.images && Array.isArray(e.images)) {
switch (e.images.length) {
case 1:
e.img_width = innerWidth / 2, e.img_height = Math.min(e.images[0].height / e.images[0].width * e.img_width, e.img_width);
break;

case 2:
e.img_width = e.img_height = (innerWidth - 33) / 2;
break;

case 3:
e.img_width = e.img_height = (innerWidth - 36) / 3;
break;

default:
e.img_width = e.img_height = (innerWidth - 36) / 3, e.more_img = e.images.length - 3, 
e.images = e.images.splice(0, 3);
}
e.img_width = Math.floor(e.img_width), e.img_height = Math.floor(e.img_height);
}
"video" === e.content_type && (e.img_width = innerWidth - 30, e.img_height = 9 * e.img_width / 16, 
e.img_width = Math.floor(e.img_width), e.img_height = Math.floor(e.img_height)), 
e.useServerV = Page.useServerV;
var i = $(cardTemplateFunctions[t]({
data: e
}));
} else if ("fiction" == t) {
if ("pgc" === Page.article.type && Page.novel_data && !Page.novel_data.can_read) return;
e.base_price && (e.base_price = parseInt(e.base_price)), e.discount_price && (e.discount_price = parseInt(e.discount_price));
var i = $(cardTemplateFunctions[t](e));
if (e.benefit_time && e.time_now && e.benefit_time > e.time_now && e.benefit_time - e.time_now < 86400) {
var l = {
sec: i.find("#sec").get(0),
mini: i.find("#mini").get(0),
hour: i.find("#hour").get(0)
};
fnTimeCountDown(1e3 * e.benefit_time, 1e3 * e.time_now, l, function() {
i.find(".tag").css("display", "none"), i.find(".sale").css("display", "none"), i.find(".sale-price").css("display", "none"), 
i.find(".origin-price").removeClass("pcard-w-delete pcard-w9").addClass("pcard-w1");
});
} else i.find("#day").text(e.benefit_time <= e.time_now ? "0天" : Math.floor((e.benefit_time - e.time_now) / 86400) + "天");
} else var i = $(cardTemplateFunctions[t](e));
i.on("click", ".button", function(t) {
t.stopPropagation(), send_umeng_event("detail", "click_card_button", a);
var i = $(this), o = i.attr("action");
"concern" === o ? dealNovelButton(t, e, i, a) : "addStock" == o && dealOptionalStockButton(t, i, e, s, a);
}), "auto" === t ? (i.find("[data-label]").on("click", function(e) {
e.stopPropagation(), send_umeng_event("detail", "click_" + this.dataset.label, a);
}), i.find('[type="button"]').on("click", function(e) {
e.stopPropagation(), location.href = this.dataset.href, send_umeng_event("detail", "click_card_button", a);
}), i.on("click", "[data-content]", function() {
location.href = this.dataset.href, send_umeng_event("detail", "click_card_content", a);
})) : "stock" === t ? (i.find('[data-label="card_selected"]').on("click", function(e) {
e.stopPropagation(), send_umeng_event("stock", "article_into_mystock", a);
}), i.find('[data-label="card_detail"]').on("click", function(e) {
e.stopPropagation(), send_umeng_event("stock", "article_into_stock", a);
}), i.find('[data-label="card_content"]').on("click", function(e) {
e.stopPropagation(), location.href = this.dataset.href, send_umeng_event("stock", "article_into_stock", a);
})) : "weitoutiao" === t ? i.on("click", "[data-content]", function() {
send_umeng_event("widget", "go_detail", {
value: this.dataset.id,
extra: {
enter_from: "widget_wtt",
card_type: 1
}
}), location.href = this.dataset.href;
}) : i.on("click", function() {
send_umeng_event("detail", "click_card_content", a);
}), needCleanDoms.push(i), "wenda" === Page.article.type ? (isShowWendaFooter = 0, 
$("footer").append(i)) : "pgc" == Page.article.type && Page.novel_data && Page.novel_data.show_new_keep_reading ? $("footer").append(i) : $("footer").prepend(i), 
"weitoutiao" === t && ($(".content .title").width() < $(".content .title-inner").width() && $(".content .title-wrap").before('<div class="whole-forum"><a class="whole-forum-inner">全文</a></div>'), 
sendWeitoutiaoCardDisplayEvent({
needRecord: !0
}), $(document).on("scroll", sendWeitoutiaoCardDisplayEvent), needCleanDoms.push($(document))), 
sendUmengWhenTargetShown(i.get(0), "detail", "card_show", a, !0);
}
}), "wenda" === Page.article.type && isShowWendaFooter) {
processWendaFooter(), context.wenda_context && void 0 !== context.wenda_context.scoring && processScoreCardWenda(context.wenda_context.scoring), 
wenda_extra.is_light && renderLightAnswerPics();
var logData = {
group_id: Page.statistics.group_id,
qid: Page.wenda_extra.qid,
ansid: Page.wenda_extra.ansid,
is_pic_typesetting: wenda_extra.is_light,
picture_count: wenda_extra.image_list ? wenda_extra.image_list.length : ""
};
sendUmengEventV3("answer_detail_show", $.extend(logData, Page.wenda_extra.gd_ext_json));
}
}(), function() {
if ("know_more_url" in context) {
var e = $('<p><a href="sslocal://webview?url=' + encodeURIComponent(context.know_more_url) + '&title=%E7%BD%91%E9%A1%B5%E6%B5%8F%E8%A7%88">了解更多</a></p>');
$("article").append(e), e.on("click", function() {
send_umeng_event("detail", "click_landingpage", {
value: Page.author.mediaId,
extra: {
item_id: Page.statistics.item_id
}
}), sendUmengEventV3("detail_click_landingpage", {
enter_from: "click_landingpage",
media_id: +Page.author.mediaId,
item_id: +Page.statistics.item_id
}, !0);
}), needCleanDoms.push(e);
}
}(), function() {
var e = function() {
return "wenda" !== Page.article.type ? !0 : client.isAndroid && _isNewsArticleVersionNoLessThan("6.4.4") || client.isIOS && _isNewsArticleVersionNoLessThan("6.4.4") ? !0 : !1;
};
"red_pack" in context && context.red_pack && context.red_pack.token && parseInt(context.red_pack.redpack_id) > 0 && (Page.author.hasRedPack = !Page.author.followState && !Page.author.isAuthorSelf, 
Page.author.isFirstPack = context.red_pack.is_first_pack, e() && Page.author.hasRedPack && $(".author-function-buttons").addClass("redpack-button-just-word follow-button-large"), 
"wenda" === Page.article.type && Page.author.hasRedPack && (sendUmengWhenTargetShown($(".subscribe-button")[0], "red_button", "", $.extend({}, wenda_extra.gd_ext_json || {}, {
user_id: Page.author.userId,
action_type: "show",
source: "answer_detail_top_card",
position: "detail"
}), !0, {
version: 3
}), sendUmengWhenTargetShown($(".subscribe-button-bottom")[0], "red_button", "", $.extend({}, wenda_extra.gd_ext_json || {}, {
user_id: Page.author.userId,
action_type: "show",
source: "answer_detail_bottom_card",
position: "detail"
}), !0, {
version: 3
})));
}(), function() {
"car_image_info" in context && ("IOSImageProcessor" in window ? window.IOSImageProcessor.addAutoScript(context.car_image_info) : "AndroidImageProcessor" in window && window.AndroidImageProcessor.addAutoScript(context.car_image_info));
}(), globalCachedContext = null, canSetContext = !1, Slardar && Slardar.sendCustomTimeLog("end_context_render", window.CLIENT_VERSION + "_" + window.APP_VERSION, +new Date() - startTimestamp);
}
}, change_following_state = function() {
function e(e) {
var t = $("header"), i = $(".subscribe-button"), o = $(".subscribe-button-bottom");
a = void 0, Page && Page.author && (Page.author.followState = e ? "following" : ""), 
e ? ($(".author-function-buttons").removeClass("redpack-button redpack-button-just-word"), 
i.addClass("following").removeClass("disabled"), t.attr("fbs", "following"), o.addClass("following").removeClass("disabled")) : (i.removeClass("following disabled"), 
t.attr("fbs", ""), t.attr("sugstate", "no"), o.removeClass("following disabled"));
}
var t, a;
return function(i, o, n) {
"function" == typeof n && n(i), o ? i !== a && (clearTimeout(t), a = i, t = setTimeout(e, 450, i, n)) : e(i, n);
};
}(), followSource = {
pgc: 30,
pgc_sug: 34,
forum: 68,
forum_sug: 69,
wenda: 28,
wenda_sug: 71
}, doRecommendUsers = function() {
function e(e, i, o) {
$.ajax({
dataType: "jsonp",
url: "http://ic.snssdk.com/api/2/relation/follow_recommends/",
data: e,
timeout: 1e4,
beforeSend: function() {
return t ? !1 : void (t = !0);
},
success: function(t, n, r) {
"article" in Page && ("success" === t.message && "object" == typeof t.data && Array.isArray(t.data.recommend_users) && t.data.recommend_users.length >= 3 ? (a[e.to_user_id] = t.data.recommend_users, 
domPrepare(), i(t.data.recommend_users)) : o(t, n, r));
},
error: function(e, t, a) {
o(a, t, e);
},
complete: function() {
t = !1;
}
});
}
var t = !1, a = {}, i = {};
return function(t, o, n, r) {
if ("function" == typeof o && "function" == typeof n) {
if (r && r.deleteCache) return void (a[t] && delete a[t]);
if (a[t]) return void o(a[t]);
var s, l;
"pgc" === Page.article.type ? (s = "article_detail", l = Page.statistics.group_id) : "forum" === Page.article.type ? (s = "weitoutiao_detail", 
l = Page.forumStatisticsParams.value) : (s = Page.article.type + "_detail", l = Page.wenda_extra.ansid);
var c = {
to_user_id: t,
page: 34,
source: s,
group_id: l
};
(client.isAndroid && client.isNewsArticleVersionNoLessThan("6.2.5") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.2.6")) && $.isEmptyObject(i) ? ToutiaoJSBridge.call("TTNetwork.commonParams", {}, function(t) {
i = t.data || t, $.extend(!0, c, i), e(c, o, n);
}) : ($.extend(!0, c, i), e(c, o, n));
}
};
}(), mediasugScroll = function() {
var e, t, a, i = innerWidth, o = 150, n = 0, r = {}, s = 0, l = !1, c = [], d = "in", u = null, p = 0, m = $("header").height() + 232;
return {
init: function(d) {
l || (l = !0, r = d, s = d.length, i = innerWidth, n = s * o + 24, this.imprcache = {}, 
this.imprlog = [], c = [], "pgc" === Page.article.type ? (e = "article", t = Page.statistics.group_id) : "forum" === Page.article.type ? (e = "weitoutiao", 
t = Page.forumStatisticsParams.value) : (e = Page.article.type, t = Page.wenda_extra.ansid), 
this.sendResult = {
imp_group_list_type: 19,
imp_group_key_name: "u11_recommend_user_" + e + "_detail_" + Page.author.userId,
imp_group_key: Page.author.userId,
imp_group_extra: {
source: e,
profile_user_id: Page.author.userId
},
impressions_in: [],
impressions_out: []
}, a = _.throttle(mediasugScroll.handler, 150), m = $("header").height() + 232);
},
range: function(e) {
var t = Math.floor(e / o);
t = Math.max(t, 0), e += i;
var a = Math.ceil(e / o);
a = Math.min(a, s) - 1;
for (var n = []; a >= t; ) n[n.length] = t++;
return n;
},
pushimpr: function(a) {
if (l) {
if (this.sendResult.impressions_in = [], Object.keys(this.imprcache).length > 0) {
this.sendResult.impressions_out = [];
for (var i in this.imprcache) {
var o = this.imprcache[i];
this.imprlog.push({
uid: i,
time: o,
duration: new Date().getTime() - o
}), console.info("leave", i), this.sendResult.impressions_out.push({
imp_item_type: 51,
imp_item_id: i,
imp_item_extra: {}
});
}
this.imprcache = {}, a && ToutiaoJSBridge.call("impression", this.sendResult);
}
console.info("pushimpr", this.imprlog), this.imprlog.length > 0 && (send_umeng_event("detail", "sub_reco_impression_v2", {
value: Page.author.userId,
extra: {
group_id: t,
impression: client.isIOS ? encodeURIComponent(JSON.stringify(mediasugScroll.imprlog)) : mediasugScroll.imprlog,
need_decode: client.isIOS ? 1 : 0,
source: e
}
}), this.imprlog = []);
}
},
dealimpr: function(e, t) {
var a = this, i = [];
if (e.forEach(function(e) {
var t = r[e].user_id;
if (t in a.imprcache) {
var o = a.imprcache[t];
a.imprlog.push({
uid: t,
time: o,
duration: new Date().getTime() - o
}), delete a.imprcache[t], a.sendResult.impressions_in = a.sendResult.impressions_in.filter(function(e) {
return e.imp_item_id != t;
}), i.push({
imp_item_type: 51,
imp_item_id: t,
imp_item_extra: {}
}), console.info("leave", t);
}
}), t.forEach(function(e) {
var t = r[e].user_id;
a.imprcache[t] = new Date().getTime(), a.sendResult.impressions_in.push({
imp_item_type: 51,
imp_item_id: t,
imp_item_extra: {}
}), console.info("enter", t);
}), e.length > 0 || t.length > 0) {
a.sendResult.impressions_out = i;
var o = {};
$.extend(!0, o, a.sendResult), ToutiaoJSBridge.call("impression", o);
}
},
handler: function() {
if (l) {
for (var e = mediasugScroll.range(this.scrollLeft || 0), t = [], a = {}, i = 0; i < c.length; i++) a[c[i]] = !0;
for (i = 0; i < e.length; i++) e[i] in a ? delete a[e[i]] : t.push(e[i]);
var o = Object.keys(a);
mediasugScroll.dealimpr(o, t), c = e;
}
},
open: function() {
c = [], mediasugScroll.handler();
},
pagescroll: function() {
if (l) {
var e = $("#mediasug-list").get(0), t = "in", a = e.getBoundingClientRect();
(a.bottom <= 0 || a.top > (window.innerHeight || document.body.clientHeight)) && (t = "out"), 
"in" === t && "out" === d ? (console.info("IN"), mediasugScroll.dealimpr([], c)) : "out" === t && "in" === d && (console.info("OUT"), 
mediasugScroll.pushimpr(!0)), d = t;
}
},
clearData: function(e) {
l = !1, doRecommendUsers(e, function() {}, function() {}, {
deleteCache: !0
});
},
horizontalScrollLeft: function(e) {
null === u && (u = e);
var t = e - u, a = Math.ceil(p / o) * o - p;
a = 0 === a ? o : a, $("#mediasug-list").scrollLeft(p + Math.min(t / 2, a)), 2 * o > t && requestAnimationFrame(mediasugScroll.horizontalScrollLeft);
},
next: function() {
var e = window.requestAnimationFrame || window.webkitRequestAnimationFrame;
p = $("#mediasug-list").scrollLeft(), console.info("current ", p), u = null, setTimeout(function() {
e(mediasugScroll.horizontalScrollLeft);
}, 400);
},
webviewScroll: function(e) {
if ("open" === $("header").attr("sugstate") && e.rect && !($("body").height() > innerHeight + 232)) {
var t, a, i, o, n, r, s = $("body").height();
if (n = e.rect.substring(1, e.rect.length - 1).split(","), t = n[0], a = Math.abs(n[1]), 
i = n[2], o = n[3], s === innerHeight) r = a >= m ? "out" : "in"; else {
var l = s - innerHeight;
r = a >= m - l ? "out" : "in";
}
"out" === d && "in" === r ? mediasugScroll.dealimpr([], c) : "in" === d && "out" === r && mediasugScroll.pushimpr(!0), 
d = r;
}
}
};
}(), subscribeTimeoutTimer, checkHeaderDisplayed = checkDisplayedFactory("#profile", "showTitleBarPgcLayout"), checkWendanextDisplayed = checkDisplayedFactory(".serial", "showWendaNextLayout"), checkWendaABHeaderLayout = checkDisplayedFactory(".wenda-title", "showWendaABHeaderLayout"), canSetContext = !1, globalContent, globalCachedContext = null, needCleanDoms = [], imprProcessQueue = [];

window.Page = {}, window.OldPage = null, window.globalExtras = {};

var IOSImageProcessor = {
state2size: {
origin: "big",
none: "big",
thumb: "small"
},
start: function() {
var e = document.querySelectorAll("a.image");
if (e = Array.prototype.slice.call(e), this.loadedOrigins = 0, this.HAS_SHOW_ALL_ORIGINS_BUTTON = !1, 
this.allPicturesCount = e.length, this.pictures = [], this.gifs = [], this.currentViewing = {}, 
0 !== this.allPicturesCount) {
if (this.threadGGSwitch && ("none" === this.image_type || (1 === this.allPicturesCount ? this.image_type = "origin" : (this.image_type = "thumb", 
this.lazy_load = !0))), this.isDuoTuThread = this.threadGGSwitch && 1 !== this.allPicturesCount, 
this.allPicturesCount > 10 && (this.lazy_load = !0), e.forEach(function(e, t) {
var a = e.getAttribute("type") || "", i = +e.getAttribute("width") || 0, o = +e.getAttribute("height") || 0, n = +e.getAttribute("thumb_width") || 0, r = +e.getAttribute("thumb_height") || 0, s = {
index: t,
holder: e,
state: IOSImageProcessor.image_type,
url: "",
href: e.getAttribute("href") || "",
link: e.getAttribute("redirect-link") || "",
isGIF: "gif" === a || "2" === a,
isLONG: i > 3 * o || o > 3 * i,
sizeArray: {
big: [ i, o ],
small: [ n, r ]
},
sizeType: IOSImageProcessor.state2size[IOSImageProcessor.image_type],
probableOffsetTop: void 0,
nativePlayGifLoaded: !1,
autoscript: null
};
IOSImageProcessor.pictures.push(s), s.isGIF && IOSImageProcessor.gifs.push(s);
}), "origin" !== this.image_type && !this.threadGGSwitch) {
this.HAS_SHOW_ALL_ORIGINS_BUTTON = !0;
var t = document.createElement("div");
t.innerHTML = '<div class="toggle-img" id="toggle-img">显示大图</div>', e[0].parentNode.insertBefore(t, e[0]);
}
this.threadGGSwitch || this.wrapStandardNative(), this.renderAllHolders(!0), NativePlayGif.tellNativeImagesPosition(), 
this.lazy_load && "none" !== this.image_type ? (document.removeEventListener("scroll", IOSImageProcessor._pollImages), 
document.addEventListener("scroll", IOSImageProcessor._pollImages, !1), IOSImageProcessor._pollImages()) : this.isDuoTuThread ? ToutiaoJSBridge.call("loadDetailImage", {
type: "all",
all_cache_size: "thumb"
}) : ToutiaoJSBridge.call("loadDetailImage", {
type: "all"
});
}
},
renderAllHolders: function(e) {
var t = this.pictures;
if (Array.isArray(t) && t.length > 0) for (var a = 0, i = t.length; i > a; a++) this.renderHolder(t[a], e);
},
renderHolder: function(e, t, a, i) {
console.info("picture", e, t, a, i);
var o = document.createDocumentFragment(), n = this.adjustOriginImageScale(e.sizeArray[e.sizeType], e.state);
if ("" !== e.url) {
var r = document.createElement("img");
r.onload = function() {
console.info("onload", e, this), "function" == typeof i && i();
var t = this.naturalWidth, a = this.naturalHeight, o = e.sizeArray[e.sizeType];
(t || a) && (o[0] !== t || o[1] !== a) && (console.info(o[0], t, o[1], a), e.sizeArray[e.sizeType] = [ t, a ], 
IOSImageProcessor.renderHolder(e)), this.onload = null;
}, r.src = e.url, o.appendChild(r);
}
var s;
if (e.isGIF) (IOSImageProcessor.isDuoTuThread || "origin" !== e.state) && (s = document.createElement("i"), 
s.setAttribute("class", "image-subscript gif-subscript"), s.textContent = "GIF", 
o.appendChild(s), s = null); else if (e.isLONG && IOSImageProcessor.isDuoTuThread) s = document.createElement("i"), 
s.setAttribute("class", "image-subscript long-subscript"), s.textContent = "长图", 
o.appendChild(s), s = null; else if (e.autoscript && "big" === e.sizeType) {
var l = document.createElement("i");
l.dataset.href = e.autoscript.open_url, l.innerHTML = '<span class="ovf">' + e.autoscript.series_name + "</span><span>" + e.autoscript.price + '</span><span class="sx">&#xe60a;</span><span>查看详情</span>', 
l.setAttribute("class", "image-subscript autoscript"), o.appendChild(l), l = null;
}
"origin" !== e.state && (s = document.createElement("i"), s.classList.add("spinner"), 
o.appendChild(s), s = null);
var c = e.holder;
if (t ? c.setAttribute("index", e.index) : c.innerHTML = "", c.appendChild(o), c.setAttribute("state", e.state), 
c.setAttribute("bg", n[0] > 140 && n[1] > 44), IOSImageProcessor.threadGGSwitch && 1 === IOSImageProcessor.allPicturesCount && (c.parentNode.style.paddingTop = 0, 
c.parentNode.style.height = n[1] + "px"), c.style.width = n[0] + "px", c.style.height = n[1] + "px", 
t || IOSImageProcessor.threadGGSwitch || a) ; else if (c.classList.contains("animation")) NativePlayGif.willStart(), 
c.addEventListener("transitionend", NativePlayGif.te, !1); else if (NativePlayGif.tellNativeImagesPosition(), 
IOSImageProcessor.currentViewing.index === e.index) {
var d = IOSImageProcessor.pictures[e.index].holder.getBoundingClientRect();
ToutiaoJSBridge.call("updateCarouselBackPosition", {
index: e.index,
left: d.left + window.pageXOffset,
top: d.top + window.pageYOffset,
width: Math.round(d.width),
height: Math.round(d.height)
}), console.info("updateCarouselBackPosition");
}
},
tapEventHandler: function() {
var e = this.getAttribute("index"), t = IOSImageProcessor.pictures[e], a = t.state, i = "full";
if (IOSImageProcessor.threadGGSwitch) send_umeng_event("talk_detail", "picture_click", Page.forumStatisticsParams), 
"none" === a && 1 === IOSImageProcessor.allPicturesCount && (i = "origin"); else if ("origin" === a || t.isGIF) {
if (t.link.indexOf("sslocal") > -1) return location.href = t.link, !1;
if (/^http(s)?:\/\//i.test(t.href)) return location.href = t.href, !1;
} else i = "origin";
switch (i) {
case "origin":
t.holder.classList.add("animation");

case "thumb":
ToutiaoJSBridge.call("loadDetailImage", {
type: i + "_image",
index: e
});
break;

default:
var o = this.getBoundingClientRect();
IOSImageProcessor.currentViewing = {
index: +e,
left: o.left + window.pageXOffset,
top: o.top + window.pageYOffset,
width: Math.round(o.width),
height: Math.round(o.height)
};
var n = "full_image?" + obj2search(IOSImageProcessor.currentViewing);
sendBytedanceRequest(n), console.info(n), "origin" !== a && ToutiaoJSBridge.call("loadDetailImage", {
type: (IOSImageProcessor.isDuoTuThread ? "thumb" : "origin") + "_image",
index: e
});
}
},
appendLocalImage: function(e, t, a, i, o) {
console.info("appendLocalImage", arguments);
var n = IOSImageProcessor.pictures[e];
if (n.url = t, n.state = a, n.sizeType = IOSImageProcessor.state2size[a], !t && "origin" === a && i && o ? (n.nativePlayGifLoaded = !0, 
n.sizeArray.big = [ i, o ], IOSImageProcessor.renderHolder(n)) : "boolean" == typeof i && "function" == typeof o ? IOSImageProcessor.renderHolder(n, !1, i, o) : IOSImageProcessor.renderHolder(n), 
IOSImageProcessor.HAS_SHOW_ALL_ORIGINS_BUTTON && "origin" === a && (IOSImageProcessor.loadedOrigins++, 
IOSImageProcessor.allPicturesCount === IOSImageProcessor.loadedOrigins)) {
var r = document.getElementById("toggle-img");
r && (r.style.visibility = "hidden");
}
var s = n.href, l = s.match(/url=([^&]*)/);
if (l) {
l = l[0];
var c = arguments[3], d = arguments[4];
"number" == typeof c && "number" == typeof d || IOSImageProcessor.pictures.forEach(function(i, o) {
!i.url && o !== e && i.href.indexOf(l) > -1 && (console.info("找到相同图片", e, o), IOSImageProcessor.appendLocalImage.call(IOSImageProcessor, o, t, a, c, d));
});
}
},
_pollImages: function() {
clearTimeout(IOSImageProcessor._pollImagesTimer), IOSImageProcessor._pollImagesTimer = setTimeout(IOSImageProcessor._pollImagesHandler, 100);
},
_pollImagesHandler: function() {
console.info("POLLING...");
var e = IOSImageProcessor.pictures.every(function(e) {
if ("" !== e.url || e.nativePlayGifLoaded) return !0;
var t = e.holder.getBoundingClientRect().top;
return console.info(e.index, t), 0 > t || (t >= 0 && t) <= 2 * window.iH ? (ToutiaoJSBridge.call("loadDetailImage", {
type: IOSImageProcessor.image_type + "_image",
index: e.index
}), !0) : !1;
});
return e ? (console.info("所有图片已加载完毕，取消懒加载事件监听"), void document.removeEventListener("scroll", IOSImageProcessor._pollImages)) : void 0;
},
wrapStandardNative: function() {
function e(e, t, a) {
var i = document.createElement(a);
i.classList.add("image-wrap"), e.insertBefore(i, t), i.appendChild(t);
}
this.pictures.forEach(function(t, a) {
var i = t.holder, o = i.parentNode;
"P" === o.tagName ? "" !== o.textContent ? (console.info("[" + a + "]所在段落有文本，应当分割"), 
e(o, i, "span")) : o.querySelectorAll(".image").length > 1 ? (console.info("[" + a + "]所在段落有其他图片，应当分割"), 
e(o, i, "span")) : (console.info("[" + a + "]正确"), o.classList.add("image-wrap")) : (console.info("[" + a + "]直接加包裹"), 
e(o, i, "p"));
});
},
adjustOriginImageScale: function(e, t) {
var a = 200, i = 200, o = window.aW / 2;
if (this.isDuoTuThread) return [ "ERROR", "ERROR" ];
var n, r, s = e[0] / e[1];
return n = e[0] ? e[0] > o ? window.aW : e[0] : a, r = s ? parseInt(n / s) : i, 
"none" === t && (r = Math.min(r, .8 * window.iH)), [ n, r ];
},
bindEvents: function() {
$(document.body).on("click", ".image", function(e) {
var t = nz_closest(e.target, ".autoscript");
return t ? (send_umeng_event("detail", "pic_card_click", {
value: +Page.statistics.group_id
}), sendUmengEventV3("clk_event", {
obj_id: "page_detail_pic_tag",
group_id: Page.statistics.group_id
}, !0), location.href = t.dataset.href, !1) : void IOSImageProcessor.tapEventHandler.call(this, e);
}).on("click", "#toggle-img", function() {
IOSImageProcessor.image_type = "origin", sendBytedanceRequest("toggle_image"), this.style.visibility = "hidden";
});
},
addAutoScript: function(e) {
if (Array.isArray(IOSImageProcessor.pictures)) {
for (var t in e) {
var a = +t;
IOSImageProcessor.pictures[a] && (IOSImageProcessor.pictures[a].autoscript = e[t]);
}
IOSImageProcessor.renderAllHolders(), setTimeout(function() {
if (Array.isArray(IOSImageProcessor.pictures)) for (var t in e) {
var a = IOSImageProcessor.pictures[+t];
if (a && a.holder) {
var i = a.holder.querySelector(".autoscript");
i && send_exposure_event_once(i, function() {
Page.statistics && (send_umeng_event("detail", "pic_card_show", {
value: Page.statistics.group_id
}), sendUmengEventV3("show_event", {
obj_id: "page_detail_pic_tag",
group_id: Page.statistics.group_id
}, !0));
}, !0);
}
}
}, 200);
}
}
};

window.appendLocalImage = IOSImageProcessor.appendLocalImage;

var NativePlayGif = {
positions: {},
NativePlayGifMovingCount: 0,
clean: function() {
console.info("NativePlayGif.clean"), NativePlayGif.positions = {}, NativePlayGif.NativePlayGifMovingCount = 0;
},
tellNativeImagesPosition: function() {
window.NativePlayGifSwitch && (IOSImageProcessor.gifs.forEach(function(e) {
var t = e.holder.getBoundingClientRect();
NativePlayGif.positions[e.index] = {
x: t.left + window.pageXOffset,
y: t.top + window.pageYOffset,
width: t.width,
height: t.height
};
}), console.info(NativePlayGif.positions), ToutiaoJSBridge.call("updateGIFPositions", NativePlayGif.positions));
},
tellNativeAnimationWillStart: function() {
window.NativePlayGifSwitch && (NativePlayGif.NativePlayGifMovingCount++, console.info("tellNativeAnimationWillStart", NativePlayGif.NativePlayGifMovingCount), 
1 === NativePlayGif.NativePlayGifMovingCount && (console.info("tellNativeAnimationWillStart", NativePlayGif.NativePlayGifMovingCount), 
ToutiaoJSBridge.call("NativePlayGif", {
action: "animationWillStart"
})));
},
tellNativeAnimationDidEnd: function(e) {
window.NativePlayGifSwitch && (NativePlayGif.NativePlayGifMovingCount--, console.info("tellNativeAnimationDidEnd", NativePlayGif.NativePlayGifMovingCount), 
0 === NativePlayGif.NativePlayGifMovingCount ? (console.info("tellNativeAnimationDidEnd", NativePlayGif.NativePlayGifMovingCount), 
ToutiaoJSBridge.call("NativePlayGif", {
action: "animationDidEnd"
}, function() {
"function" == typeof e && e();
})) : NativePlayGif.NativePlayGifMovingCount < 0 && (NativePlayGif.NativePlayGifMovingCount = 0));
},
tellNativeGetFrames: function(e) {
window.NativePlayGifSwitch ? ToutiaoJSBridge.call("NativePlayGif", {
action: "getFrames"
}, function(t) {
if (Array.isArray(t.frames)) {
console.info("tellNativeGetFrames", t.frames);
var a = t.frames.length;
a > 0 ? t.frames.forEach(function(t) {
var i = Array.prototype.slice.call(t);
i.push(!0, function() {
0 === --a && "function" == typeof e && e();
}), appendLocalImage.apply(this, i);
}) : "function" == typeof e && e();
}
}) : "function" == typeof e && e();
},
cleanFrames: function() {
window.NativePlayGifSwitch && (console.info("cleanFrames"), IOSImageProcessor.gifs.forEach(function(e) {
e.nativePlayGifLoaded && (e.holder.innerHTML = "", e.url = "");
}));
},
te: function(e) {
console.info("transitionend", e.target, this.getAttribute("index")), this.removeEventListener("transitionend", NativePlayGif.te), 
NativePlayGif.ended();
},
willStart: function(e) {
NativePlayGif.tellNativeGetFrames(function() {
NativePlayGif.tellNativeAnimationWillStart(), "function" == typeof e && e();
});
},
ended: function() {
setTimeout(function() {
NativePlayGif.tellNativeImagesPosition(), NativePlayGif.tellNativeAnimationDidEnd(function() {
NativePlayGif.cleanFrames();
});
}, 100);
}
}, imageSizeInitTimer;

!function() {
IOSImageProcessor.bindEvents(), bindStatisticsEvents(), bindStatisticsEvents23(), 
window.onresize = function() {
window.aW = document.body.offsetWidth - 30 || window.innerWidth - 30, console.info("resize", window.aW, window.abcdefg), 
window.imageInited && IOSImageProcessor.renderAllHolders();
}, ToutiaoJSBridge.on("menuItemPress", processMenuItemPressEvent);
}();
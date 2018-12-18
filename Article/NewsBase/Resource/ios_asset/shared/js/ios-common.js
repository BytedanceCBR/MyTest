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
var n = "";
if ("number" != typeof t || 0 === t) n = a || "赞"; else if (1e4 > t) n = t; else if (1e8 > t) {
var o = (Math.floor(t / 1e3) / 10).toFixed(1);
n = (o.indexOf(".0") > -1 || o >= 10 ? o.slice(0, -2) : o) + "万";
} else {
var o = (Math.floor(t / 1e7) / 10).toFixed(1);
n = (o.indexOf(".0") > -1 || o >= 10 ? o.slice(0, -2) : o) + "亿";
}
return e && $(e).each(function() {
$(this).attr("realnum", t).html(n);
}), n;
}

function commentTimeFormat(e) {
var t, a = new Date(), n = "";
try {
if (t = new Date(1e3 * e), isNaN(t.getTime())) throw new Error("Invalid Date");
} catch (o) {
return "";
}
return n += t.getFullYear() < a.getFullYear() ? t.getFullYear() + "-" : "", n += t.getMonth() >= 9 ? t.getMonth() + 1 : "0" + (t.getMonth() + 1), 
n += "-", n += t.getDate() > 9 ? t.getDate() : "0" + t.getDate(), n += " ", n += t.getHours() > 9 ? t.getHours() : "0" + t.getHours(), 
n += ":", n += t.getMinutes() > 9 ? t.getMinutes() : "0" + t.getMinutes();
}

function formatDuration(e) {
if (isNaN(Number(e))) return "00:00";
var t = [ Math.floor(e / 60), ":", Math.ceil(e % 60) ];
return t[2] <= 9 && t.splice(2, 0, 0), t[0] <= 9 && t.unshift(0), t.join("");
}

function formatTime(e) {
var t = 6e4, a = 60 * t, n = new Date(), o = n.getTime(), i = new Date(n.getFullYear(), n.getMonth(), n.getDate()), r = new Date(+e);
if (isNaN(r.getTime())) return "";
var s = o - e;
if (0 > s) return "";
if (t > s) return "刚刚";
if (a > s) return Math.floor(s / t) + "分钟前";
if (24 * a > s) return Math.floor(s / a) + "小时前";
for (var l = (r.getHours() > 9 ? r.getHours() : "0" + r.getHours()) + ":" + (r.getMinutes() > 9 ? r.getMinutes() : "0" + r.getMinutes()), c = 0; c++ <= 8; ) if (i.setDate(i.getDate() - 1), 
e > i.getTime()) return 1 === c ? "昨天 " + l : 2 === c ? "前天 " + l : c + "天前";
return (r.getFullYear() < n.getFullYear() ? r.getFullYear() + "年" : "") + (r.getMonth() + 1) + "月" + r.getDate() + "日";
}

function send_umeng_event(e, t, a) {
var n = "bytedance://" + event_type + "?category=umeng&tag=" + e + "&label=" + encodeURIComponent(t);
if (a) for (var o in a) {
var i = a[o];
if ("extra" === o && "object" == typeof i) if (client.isAndroid) n += "&extra=" + JSON.stringify(i); else {
var r = "";
for (var s in i) r += "object" == typeof i[s] ? "&" + s + "=" + JSON.stringify(i[s]) : "&" + s + "=" + encodeURIComponent(i[s]);
n += r;
} else n += "&" + o + "=" + i;
}
try {
window.webkit.messageHandlers.observe.postMessage(n);
} catch (l) {
console.log(n);
}
}

function sendUmengEventV3(e, t, a) {
if ("string" == typeof e && "" !== e) {
var n = "log_event_v3?event=" + e + "&params=" + JSON.stringify(t || {}) + "&is_double_sending=" + (a ? "1" : "0");
sendBytedanceRequest(n);
}
}

function send_request(e, t) {
var a = "bytedance://" + e;
if (t) {
a += "?";
for (var n in t) a += n + "=" + t[n] + "&";
a = a.slice(0, -1);
}
location.href = a;
}

function send_exposure_event_once(e, t, a) {
function n() {
i && clearTimeout(i), i = setTimeout(function() {
var a = o(e, r);
console.info(a, e), a && (t(), document.removeEventListener("scroll", n, !1));
}, 50);
}
function o(e, t) {
var n = e.getBoundingClientRect(), o = n.top, i = n.height || n.bottom - n.top, r = o;
return a && (r = o + i), t >= r;
}
if (e && "function" == typeof t) {
var i = 0, r = window.innerHeight;
o(e, r) ? t() : document.addEventListener("scroll", n, !1);
}
}

function isElementInViewportY(e, t) {
var a = e.getBoundingClientRect(), n = window.innerHeight || document.body.clientHeight;
return t ? a.height < n ? a.top >= 0 && a.top <= n && a.bottom >= 0 && a.bottom <= n : a.top <= 0 && a.bottom >= n : a.top <= n && a.bottom >= 0;
}

function sendUmengWhenTargetShown(e, t, a, n, o, i) {
e && (isElementInViewportY(e, o) ? i && 3 === i.version ? sendUmengEventV3(t, n, !!i.isDoubleSend) : send_umeng_event(t, a, n) : imprProcessQueue.push(arguments));
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
return ""
var a = Page.h5_settings.user_verify_info_conf["" + e];
if (!a) return "";
if (a = a[t], !a) return "";
var t = a.icon;
return t = client.isIOS ? a.web_icon_ios : client.isSeniorAndroid ? a.web_icon_android : a.icon_png, 
'<i class="server-v-icon" style="background-image: url(' + t + ');">&nbsp;</i>';
}

function buildServerVIcon2(e, t) {
return ""
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
var n = e.type_config[a];
t[n.type] = n;
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
var n;
a % 2 === 1 && (n = a > e ? "empty" : a === e ? "half" : "full", t += '<span class="score-star ' + n + '"></span>');
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
function n() {
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
ios: n
},
v60: {
ios: t,
android: t
}
}, i = {
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
e.wenda_extra.title = _.escape(e.wenda_extra.title), i.article = {
title: t.title,
publishTime: t.show_time
}, i.author = {
userId: a.user_id,
name: a.user_name,
link: i.h5_settings.is_liteapp ? "javascript:;" : a.schema + "&group_id=" + t.ansid + "&from_page=detail_answer_wenda",
intro: a.user_intro,
avatar: a.user_profile_image_url,
isAuthorSelf: !1,
verifiedContent: a.is_verify ? "PLACE_HOLDER" : "",
medals: a.medals
};
var n = {
auth_type: "",
auth_info: ""
};
try {
n = JSON.parse(a.user_auth_info);
} catch (o) {}
if (i.author.auth_type = a.user_auth_info ? n.auth_type || 0 : "", i.author.auth_info = n.auth_info, 
a.user_decoration) {
var r = {};
try {
r = JSON.parse(a.user_decoration);
} catch (o) {}
i.author.user_decoration = r;
}
"is_following" in t && (i.author.followState = t.is_following ? "following" : ""), 
i.wenda_extra = t, i.wenda_extra.aniok = client.isSeniorAndroid, i.statistics.group_id = t.ansid;
},
forum: function() {
var t = e.forum_extra, a = t.user_info || {};
t.forum_info || {}, i.article = {
title: t.thread_title || "",
publishTime: formatTime(1e3 * t.publish_timestamp)
}, i.author = {
userId: a.id,
name: a.name,
link: a.schema + "&group_id=" + t.thread_id + "&from_page=detail_topic" + (t.category_name ? "&category_name=" + t.category_name : ""),
avatar: a.avatar_url,
isAuthorSelf: !!t.is_author,
verifiedContent: a.verified_content,
medals: a.medals,
remarkName: a.remark_name
};
var n = {
auth_type: "",
auth_info: ""
};
try {
n = JSON.parse(a.user_auth_info);
} catch (o) {}
i.author.auth_type = a.user_auth_info ? n.auth_type || "0" : "", i.author.auth_info = n.auth_info, 
"is_following" in t && (i.author.followState = t.is_following ? "following" : "");
var r = [];
"object" == typeof a.media && a.media.name && r.push(a.media.name), a.verified_content && r.push(a.verified_content), 
i.author.intro = r.join("，"), i.tags = t.label_list, i.forum_extra = t, i.forumStatisticsParams = {
value: t.thread_id,
ext_value: t.forum_id,
extra: {
enter_from: t.enter_from,
concern_id: t.concern_id,
refer: t.refer,
group_type: t.group_type,
category_id: t.category_id
}
};
},
pgc: function() {
var t = e.h5_extra, a = t.media || {};
i.article = {
title: t.title,
publishTime: t.publish_stamp ? formatTime(1e3 * t.publish_stamp) : t.publish_time
}, i.author = {
userId: t.media_user_id,
mediaId: a.id,
name: a.name,
link: "sslocal://profile?refer=all&source=article_top_author&uid=" + t.media_user_id + "&group_id=" + i.statistics.group_id + "&from_page=detail_article" + (t.category_name ? "&category_name=" + t.category_name : ""),
intro: a.description,
avatar: a.avatar_url,
isAuthorSelf: !!t.is_author
}, (i.h5_settings.is_liteapp || !t.media_user_id) && (i.author.link = (i.h5_settings.is_liteapp && client.isIOS ? "sslocal" : "bytedance") + "://media_account?refer=all&media_id=" + a.id + "&loc=0&entry_id=" + a.id);
var n = {
auth_type: "",
auth_info: ""
};
try {
n = JSON.parse(a.user_auth_info);
} catch (o) {}
if (i.author.auth_type = a.user_auth_info ? n.auth_type || 0 : "", i.author.auth_info = n.auth_info, 
i.author.verifiedContent = a.user_verified && i.author.auth_info || "", a.user_decoration) {
var r = {};
try {
r = JSON.parse(a.user_decoration);
} catch (o) {}
i.author.user_decoration = r;
}
"is_subscribed" in t && (i.author.followState = t.is_subscribed ? "following" : ""), 
t.is_original && i.tags.push("原创"), t.category_name && (i.category_name = t.category_name), 
t.log_pb && (i.log_pb = t.log_pb);
},
zhuanma: function() {
var t = e.h5_extra;
i.article = {
title: t.title,
publishTime: t.publish_time || "0000-00-00 00:00"
}, i.author.name = t.source;
},
common: function() {
var t = e.h5_extra;
if ("custom_style" in e && (i.customStyle = e.custom_style), "pay_status" in t && (i.pay_status = Page && Page.pay_status && -1 != Page.pay_status && -1 == t.pay_status.status ? Page.pay_status : t.pay_status.status, 
i.auto_pay_status = t.pay_status.auto_pay_status), "novel_data" in t) {
if ("object" == typeof t.novel_data) i.novel_data = t.novel_data; else if ("string" == typeof t.novel_data) try {
i.novel_data = JSON.parse(t.novel_data);
} catch (a) {}
i.novel_data.can_read = i.h5_settings.is_liteapp || 0 == t.novel_data.book_free_status || 0 == t.novel_data.need_pay || 1 == i.pay_status || 3 == i.pay_status, 
i.novel_data.use_deep_reader = client.isIOS && client.isNewsArticleVersionNoLessThan("6.5.3") || client.isAndroid && client.isNewsArticleVersionNoLessThan("6.5.6");
}
var n = t.ab_client || [];
i.topbuttonType = "pgc" !== i.article.type || n.indexOf("f7") > -1 ? "concern" : "digg";
try {
i.h5_settings = "object" == typeof t.h5_settings ? t.h5_settings : JSON.parse(t.h5_settings);
} catch (a) {
i.h5_settings = {};
}
i.h5_settings.pgc_over_head = !!i.h5_settings.pgc_over_head && "pgc" === i.article.type, 
i.h5_settings.is_liteapp = !!t.is_lite;
try {
i.isRedFocusButton = "red" === i.h5_settings.tt_follow_button_template.color_style;
} catch (a) {
i.isRedFocusButton = !1;
}
if (i.h5_settings.tt_follow_button_template && i.h5_settings.tt_follow_button_template.color_style && "blue" != i.h5_settings.tt_follow_button_template.color_style && "red" != i.h5_settings.tt_follow_button_template.color_style && (i.focusButtonStyle = i.h5_settings.tt_follow_button_template.color_style), 
i.h5_settings.user_verify_info_conf) {
if ("string" == typeof i.h5_settings.user_verify_info_conf) try {
i.h5_settings.user_verify_info_conf = JSON.parse(i.h5_settings.user_verify_info_conf);
} catch (a) {
i.h5_settings.user_verify_info_conf = {};
}
i.h5_settings.user_verify_info_conf = trans_v_info(i.h5_settings.user_verify_info_conf), 
i.useServerV = !0;
} else i.useServerV = !1;
i.hasExtraSpace = !i.h5_settings.is_liteapp && client.isSeniorAndroid, i.hideFollowButton = !!t.hideFollowButton, 
i.statistics = {
group_id: t.str_group_id || t.group_id || "",
item_id: t.str_item_id || t.item_id || ""
}, i.showUserDecoration = client.isNewsArticleVersionNoLessThan("6.5.6");
}
};
"object" != typeof e && (e = window);
var s = r.getArticleType();
return i.article.type = s, r.common(), window.OldPage && (i.hasExtraSpace = OldPage.hasExtraSpace), 
r[s](), i.pageSettings = o[APP_VERSION][CLIENT_VERSION](), i.article.type = s, i;
}

function buildHeader(e) {
var t = renderHeader({
data: e
}), a = $("header");
a.length <= 0 ? $(document.body).prepend(t) : a.replaceWith(t);
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
a.length > 0 ? a.replaceWith(t) : $(document.body).append(t), Page.novel_data && processNovelFooter(e.is_login);
}

function processWendaArticle() {
var e, t = Page.wenda_extra, a = t.show_post_answer_strategy || {}, n = t.wd_version || 0, o = Page.h5_settings.is_liteapp, i = "show_top" in a && !o, r = "show_default" in a && !o, s = [ "wt" ];
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
}, 1 > n || n >= 3 && 1 == t.showMode) $("header").find(".tt-title").remove(); else {
t.wd_version >= 13 && s.push("no-icon"), i ? (Page.wenda_extra.showBigAns = 1, e = $('<div class="' + s.join(" ") + '">' + t.title + '</div><div class="ft"><span class="see-all-answers" id="total-answer-count">个回答</span><span class="hide-placeholder">&nbsp;</span></div><a class="big-answer-buttoon go-to-answer" data-type="big" href="' + urlAddQueryParams(a.show_top.schema, {
source: "answer_detail_top_write_answer"
}) + '">' + a.show_top.text + '</a><div class="big-answer-buttoon-gap"></div>')) : e = $(r ? '<div class="' + s.join(" ") + '">' + t.title + '</div><div class="ft"><a class="go-to-answer go-to-answer-small" data-type="small" href="' + urlAddQueryParams(a.show_default.schema, {
source: "answer_detail_write_answer"
}) + '">回答</a><span class="see-all-answers" id="total-answer-count">个回答</span></div>' : '<div class="' + s.join(" ") + '">' + t.title + '</div><div class="ft"><span class="see-all-answers" id="total-answer-count">个回答</span><span class="hide-placeholder">&nbsp;</span></div>');
var l = i ? "bigans" : r ? "smlans" : "noans";
$("header").find(".tt-title").removeClass("tt-title").addClass("wenda-title " + l + " title-type" + (t.answer_detail_type || 0)).html(e).on("click", function() {
return "wenda_title_handle" in t && t.wenda_title_handle ? void (ToutiaoJSBridge && ToutiaoJSBridge.call("clickWendaDetailHeader")) : void ("need_return" in t ? t.need_return ? ToutiaoJSBridge && ToutiaoJSBridge.call("close") : t.list_schema && (window.location.href = t.list_schema) : [ "click_answer", "click_answer_fold" ].indexOf(t.enter_from) > -1 ? ToutiaoJSBridge && ToutiaoJSBridge.call("close") : t.list_schema && (window.location.href = t.list_schema));
}), new PressState({
bindSelector: ".wenda-title,.big-answer-buttoon",
exceptSelector: ".go-to-answer-small,.see-all-answers",
pressedClass: "pressing",
removeLatency: 500
}), i ? $(".go-to-answer").on("click", function(e) {
e.stopPropagation(), send_umeng_event("answer_detail", "top_write_answer", wendaStatisticsParams);
}) : r && (window.wenda_extra && window.wenda_extra.answer_detail_type && wendaCacheAdd(function() {}), 
$(".go-to-answer").on("click", function(e) {
e.stopPropagation(), send_umeng_event("answer_detail", "wirte_answer", wendaStatisticsParams);
}));
}
$(document.body).on("click", "#wenda_index_link", function() {
[ "click_answer", "click_answer_fold" ].indexOf(t.enter_from) > -1 ? ToutiaoJSBridge.call("close") : location.href = t.list_schema;
}), $("article").on("click", "a.out-link", function(e) {
e.preventDefault();
var t = $(this);
location.href = "sslocal://webview?nightbackground_disable=1&url=" + encodeURIComponent(t.attr("href")) + "&title=" + encodeURIComponent(t.text());
}), $("article").on("click", "a.link-at", function(e) {
e.preventDefault();
var t = $(this).attr("data-uid");
t && (location.href = "sslocal://profile?uid=" + t + "&source=wenda_detail&refer=wenda");
});
}

function processWendaFooter() {
var wenda_extra = Page.wenda_extra, ansStrategy = wenda_extra.show_post_answer_strategy || {}, wdVersion = wenda_extra.wd_version || 0, isLiteApp = Page.h5_settings.is_liteapp;
if (!(1 > wdVersion || wdVersion >= 3 && 1 == wenda_extra.showMode)) {
var isShowBottomUser = 0, wendaUserTmpl = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="wenda-bt-panel"><div class="wenda-bt-user" topbutton-type="' + (null == (__t = data.topbuttonType) ? "" : __t) + '"><div class="authorbar wenda">', 
__p += '<a class="author-avatar-link pgc-link" href="' + (null == (__t = data.author.link) ? "" : __t) + '"><div class="author-avatar"><img class="author-avatar-img" src="' + (null == (__t = data.author.avatar) ? "" : __t) + '"></div>', 
false && data.author.auth_info && (__p += "" + (null == (__t = buildServerVIcon2(data.author.auth_type, "avatar_icon")) ? "" : __t)),
__p += "</a>", __p += '<div class="author-function-buttons"><button class="subscribe-button-bottom follow-button ' + (null == (__t = "followState" in data.author ? data.author.followState : "disabled") ? "" : __t) + " " + (null == (__t = data.isRedFocusButton ? "red-follow-button" : "") ? "" : __t) + '"data-user-id="' + (null == (__t = data.author.userId) ? "" : __t) + '"data-media-id="' + (null == (__t = data.author.mediaId) ? "" : __t) + '"style="display: ' + (null == (__t = data.author.isAuthorSelf || "wenda" === data.article.type && data.h5_settings.is_liteapp || "forum" === data.article.type && "following" === data.author.followState || data.hideFollowButton ? "none" : "block") ? "" : __t) + ';"id="subscribe"><i class="iconfont focusicon">&nbsp;</i><i class="redpack"></i></button></div>', 
__p += '<div class="author-bar ' + (null == (__t = "" !== data.author.intro ? " auth-intro" : "") ? "" : __t) + '"><div class="name-link-wrap"><div class="name-link-w"><a class="author-name-link pgc-link" href="' + (null == (__t = data.author.link) ? "" : __t) + '">' + (null == (__t = data.author.name) ? "" : __t) + "</a></div></div>", 
"" !== data.author.intro && (__p += '<a class="sub-title-w" href="' + (null == (__t = data.author.link) ? "" : __t) + '"><span class="sub-title">' + (null == (__t = data.author.intro) ? "" : __t) + "</span></a>"), 
__p += '<a class="sub-title-w" href="' + (null == (__t = data.author.link) ? "" : __t) + '"><span class="sub-title" id="wenda-user-intro"></span></a></div></div></div></div>';
return __p;
};
if (!_isNewsArticleVersionNoLessThan("6.4.1") && !Page.author.isAuthorSelf && "following" !== Page.author.followState && "is_show_bottom_user" in wenda_extra && wenda_extra.is_show_bottom_user && $("article").height() > 1.5 * window.innerHeight && !isLiteApp) {
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

function processNovelFooter(e) {
1 == Page.novel_data.show_bookshelf_window && $.ajax({
url: "https://ic.snssdk.com/novel/book/bookshelf/v1/check/",
dataType: "jsonp",
data: {
book_id: Page.novel_data.book_id
},
error: function() {},
success: function(e) {
e.data && 1 == e.data.status && (Page.novel_data.show_bookshelf_window = 0);
}
});
var t = "https://ic.snssdk.com/novel/book/pay/v1/single_payment/page/?book_id=" + Page.novel_data.book_id + "&item_id=" + Page.statistics.item_id + "&group_id=" + Page.statistics.group_id;
document.querySelector(".update") && (document.querySelector(".update").addEventListener("click", function() {
client.isAndroid ? location.href = "http://app.toutiao.com/news_article/" : client.isIOS && client.isNewsArticleVersionNoLessThan("6.2.6") && getCommonParams(function(e) {
switch (e.app_name) {
case "news_article_social":
t = "itms-apps://itunes.apple.com/cn/app/id582528844";
break;

case "explore_article":
t = "itms-apps://itunes.apple.com/cn/app/id672151725";
break;

default:
t = "itms-apps://itunes.apple.com/cn/app/id529092160";
}
ToutiaoJSBridge.call("openApp", {
url: t
}, null);
}), sendUmengEventV3("click_version_update", {
group_id: Page.statistics.group_id,
item_id: Page.statistics.item_id,
enter_from: "detail",
category_name: "novel_channel",
novel_id: Page.novel_data.book_id,
concern_id: Page.novel_data.concern_id,
log_pb: ""
}, !1);
}, !1), sendUmengEventV3("go_version_update", {
group_id: Page.statistics.group_id,
item_id: Page.statistics.item_id,
enter_from: "version_update",
category_name: "novel_channel",
novel_id: Page.novel_data.book_id,
concern_id: Page.novel_data.concern_id,
type: 0,
log_pb: ""
}, !1)), document.querySelector(".buy") && (document.querySelector(".buy").addEventListener("click", function() {
e ? location.href = "sslocal://popup_browser?url=" + encodeURIComponent(t) + "&pull_close=1" : ToutiaoJSBridge.call("login", {
platform: ""
}), sendUmengEventV3("click_purchase_read", {
group_id: Page.statistics.group_id,
item_id: Page.statistics.item_id,
enter_from: "purchase_reminder",
category_name: "novel_channel",
novel_id: Page.novel_data.book_id,
log_pb: ""
}, !1);
}, !1), sendUmengEventV3("go_purchase_reminder", {
group_id: Page.statistics.group_id,
item_id: Page.statistics.item_id,
enter_from: "detail",
category_name: "novel_channel",
novel_id: Page.novel_data.book_id,
type: 0,
log_pb: ""
}, !1)), 1 == Page.pay_status && 1 == Page.auto_pay_status && 1 == Page.novel_data.book_free_status && $.ajax({
url: "https://ic.snssdk.com/novel/trade/purchase/v1/auto_pay/",
dataType: "jsonp",
data: {
book_id: Page.novel_data.book_id,
item_id: Page.statistics.item_id,
device_platform: client.isIOS ? 1 : 2
},
error: function() {},
success: function(e) {
console.info("fhru", e);
}
}), 255 == Page.pay_status && 1 == Page.novel_data.book_free_status && ToutiaoJSBridge.call("toast", {
text: "系统异常 请稍后再试",
icon_type: "icon_error"
});
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
var n = "{{0,0},{0,0}}", o = document.querySelector(e);
if (o) {
var i = o.getBoundingClientRect();
n = "{{" + (i.left + window.pageXOffset) + "," + (i.top + window.pageYOffset) + "},{" + i.width + "," + i.height + "}}";
}
return n;
}

function setFontSize(e) {
var t = e.split("_")[0], a = (e.split("_")[1], [ "s", "m", "l", "xl" ]), n = $.map(a, function(e) {
return "font_" + e;
}).join(" ");
a.indexOf(t) > -1 && $("body").removeClass(n).addClass("font_" + t);
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
var n = t.getBoundingClientRect();
a = "{{" + n.left + "," + t.offsetTop + "},{" + n.width + "," + n.height + "}}";
}
return a;
}

function processMenuItemPressEvent() {
ToutiaoJSBridge.call("typos", {
strings: getThreeStrings()
});
}

function getThreeStrings() {
var e = "", t = "", a = "", n = document.getSelection();
if ("Range" !== n.type) return [ e, t, a ];
var o = n.getRangeAt(0);
if (!o) return [ e, t, a ];
try {
e = o.startContainer.textContent.substring(0, o.startOffset).substr(-20), t = o.toString(), 
a = o.endContainer.textContent.substring(o.endOffset).substring(0, 20);
} catch (i) {}
return o.detach(), o = null, [ e, t, a ];
}

function subscribe_switch(e) {
"pgc" == Page.article.type && change_following_state(!!e);
}

function dealNovelButton(e, t, a, n) {
return e.preventDefault(), t.is_concerned ? (sendUmengEventV3("click_enter_bookshelf", {
novel_id: t.book_id,
group_id: Page.statistics.group_id,
item_id: Page.statistics.item_id
}, 0), void (location.href = t.bookshelf_url)) : (send_umeng_event("detail", "click_fictioncard_care", n), 
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

function dealOptionalStockButton(e, t, a, n, o) {
e.stopPropagation(), send_umeng_event("stock", "article_add_stock", o);
var i, r = 0, s = t.attr("data-stock"), l = 0;
n.forEach(function(e, t) {
e.code == s && (l = t, i = e.market), 0 == e.selected && r++;
}), 1 != n[l].selected && $.ajax({
url: "http://ic.snssdk.com/stock/like/",
dataType: "jsonp",
data: {
code: s,
market: i
},
beforeSend: function() {
return n[l].isclicking || 1 == n[l].selected ? !1 : void (n[l].isclicking = !0);
},
complete: function() {
n[l].isclicking = !1;
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
}), $parent.addClass("ant-notification-fade-leave"))), void (n[l].selected = !0));
}
});
}

function wendaCooperateCard() {
var cooperateCardTmpl = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="wenda-panel-co"><div class="wenda-cooperate"><div class="authorbar wenda clearfix"><a class="author-avatar-link pgc-link" href="' + (null == (__t = data.author.link) ? "" : __t) + '"><div class="author-avatar"><img class="author-avatar-img" src="' + (null == (__t = data.author.avatar) ? "" : __t) + '"></div>', 
false && data.author.auth_info && (__p += "" + (null == (__t = buildServerVIcon2(data.author.auth_type, "avatar_icon")) ? "" : __t)),
__p += "</a>", false && data.author.user_decoration && data.author.user_decoration.url && (__p += '<div class="avatar-decoration" style="background-image: url(' + (null == (__t = data.author.user_decoration.url) ? "" : __t) + ')"></div>'),
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
}, n = setInterval(function() {
window.wenda_extra.gd_ext_json && (clearInterval(n), a = $.extend(a, window.wenda_extra.gd_ext_json), 
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
Page.h5_settings.is_liteapp && wenda_extra.wd_version < 3 && ToutiaoJSBridge.call("appInfo", {}, function(e) {
1206 === e.aid && e.versionCode >= 631 && $(".bottom-buttons").hide();
}), "is_concern_user" in e && change_following_state(!!e.is_concern_user), "ans_count" in e && ($("#total-answer-count").html(e.ans_count + "个回答").css("display", "inline-block"), 
$("#total-answer-count-index").html("全部" + e.ans_count + "个回答")), "nice_ans_count" in e && "wenda_extra" in window && ("function" == typeof window.assignThroughWendaNiceanscount ? window.assignThroughWendaNiceanscount(e.nice_ans_count) : window.wenda_extra.nice_ans_count = e.nice_ans_count), 
"question_schema" in e && e.question_schema && (window.wenda_extra.list_schema = e.question_schema), 
"post_answer_schema" in e && e.post_answer_schema && $(".go-to-answer").attr("href", urlAddQueryParams(e.post_answer_schema, {
source: "big" === $(".go-to-answer").attr("data-type") ? "answer_detail_top_write_answer" : "answer_detail_write_answer"
})), "is_following" in e && Page && Page.author && (Page.author.followState = e.is_following ? "following" : ""), 
"has_profit" in e && e.has_profit && Page.wenda_extra.showBigAns && !Page.wenda_extra.disable_profit && $(".go-to-answer").text("写回答，得红包").addClass("red_packet_wd"), 
"gd_ext_json" in e) {
var n = e.gd_ext_json || {};
if ("string" == typeof e.gd_ext_json) try {
n = JSON.parse(e.gd_ext_json);
} catch (o) {
n = {};
}
window.wenda_extra.gd_ext_json = n, "category_name" in n && "wenda" === Page.article.type && (Page.author.link = Page.author.link + "&category_name=" + n.category_name, 
$(".author-avatar-link").attr("href", Page.author.link), $(".author-name-link").attr("href", Page.author.link), 
$(".sub-title-w").attr("href", Page.author.link));
}
if (WendaRuleTip(e.tips_data || {}), (!("show_next" in e) || e.show_next) && ($(".serial").show(), 
"has_next" in e)) {
var i = $("#next_answer_link");
e.has_next ? (i.attr("href", e.next_answer_schema), i.attr("onclick", null)) : (i.attr("onclick", null), 
i.addClass("disabled").on("click", function() {
ToutiaoJSBridge.call("toast", {
text: "这是最后一个回答",
icon_type: ""
});
}), needCleanDoms.push(i));
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
var e = document.querySelector("#profile"), t = document.querySelector(".wenda-title"), a = 0, n = 0;
t && (a = t.getBoundingClientRect().height), e && (n = e.getBoundingClientRect().height + 20 + a), 
ToutiaoJSBridge.call("onGetHeaderAndProfilePosition", {
header_position: a,
profile_position: n
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
var n = t.attr("data-type"), o = parseInt(t.attr("data-index")), i = {
evaluate_id: JSON.stringify({
gid: group_id,
style: "face",
string_id: score_card_info_string,
interval: Date.now() - startTime
}),
survey_type: "point",
prefer_id: a
};
if ($.extend(!0, i, networkCommonParams), $.ajax({
url: "https://eva.snssdk.com/eva/survey.json",
dataType: "jsonp",
data: i,
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
container: document.querySelector("#" + n + "-press-animation"),
path: 3 == Page.h5_settings.score_card_style ? baseFilePath() + "images/score-" + n + "/data2.json" : baseFilePath() + "images/score-" + n + "/data.json",
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
document.getElementById("thx-press-emoji").className = n + "-press", document.getElementById("thx-word").innerHTML = "您对本文的评价是：" + letters[score_card_info_string][o], 
lastTimeOutDone = setTimeout(function() {
$(".p-scorecard").addClass("moveUp");
}, 1e3)), (4 == Page.h5_settings.score_card_style || 5 == Page.h5_settings.score_card_style) && (lastTimeOutDone && clearTimeout(lastTimeOutDone), 
document.getElementById("thx-press-emoji").className = n + "-press", document.getElementById("thx-word").innerHTML = "您对本文的评价是：" + letters[score_card_info_string][o], 
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
var n = e.split(",");
if (n.indexOf(a) > -1) return;
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
var n = {
group_id: Page.statistics.group_id,
user_id: Page.wenda_extra.user.user_id,
qid: Page.wenda_extra.qid,
ansid: Page.wenda_extra.ansid,
score: 1 * e + 1
};
sendUmengEventV3("answer_score", $.extend(n, Page.wenda_extra.gd_ext_json)), clearTimeout(timerUp), 
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
for (var e = $(this), t = e.attr("data-index"), a = [], n = 0; n < wenda_extra.image_list.length; n++) a.push("https://p1.pstatp.com/large/" + wenda_extra.image_list[n].web_uri);
var o = e.offset();
location.href = "ios" == window.CLIENT_VERSION ? "bytedance://full_image?index=" + t + "&url=" + a[t] + "&left=" + o.left + "&top=" + o.top + "&width=" + e.width() + "&height=" + e.height() : "bytedance://large_image?index=" + t + "&url=" + a[t] + "&left=" + o.left + "&top=" + o.top + "&width=" + e.width() + "&height=" + e.height();
}), $template.addClass(1 === wenda_extra.image_list.length ? "col-1" : 2 === wenda_extra.image_list.length || 4 === wenda_extra.image_list.length ? "col-2" : "col-3"), 
$("footer").prepend($template).addClass("has-wenda-pic-cell");
}
}

function oldMotorDealerContextRender(e, t, a, n, o) {
var i = $(e({
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
req_id: n,
card_id: o.card_id,
card_type: o.card_type,
extra_params: JSON.stringify({})
};
i.data("series_id", o.series_id), i.data("series_name", o.series_name), i.on("focus", ".j-motor-form-user", function() {
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
var e = $(this), t = e.closest(".motor-form-body"), n = t.find("[name=userName]"), s = t.find("[name=userMobile]"), l = t.find("[name=userAgree]"), c = n.val(), d = s.val(), u = l.is(":checked");
return "" === c ? (n.addClass("error").next(".motor-form-tip").show(), !1) : (n.removeClass("error").next(".motor-form-tip").hide(), 
"" !== d && /^1[3|4|5|7|8|9]\d{9}$/.test(d) ? (s.removeClass("error").next(".motor-form-tip").hide(), 
u ? ($("article").find(".motor-form-body [name=userName]").val(c), $("article").find(".motor-form-body [name=userMobile]").val(d), 
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
e.removeAttr("disabled").text("立即获取最低价"), t.data && "true" === t.data.result ? (i.find(".motor-form-edit").hide(), 
i.find(".motor-form-sheet").show(), i.find(".j-close-dealer-card").hide()) : ToutiaoJSBridge.call("toast", {
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
}, r), !1), i.find(".motor-form-edit").show(), i.find(".motor-form-sheet").hide();
}), i.find(".j-close-dealer-card").on("click", function(e) {
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
"success" === e.message ? i.hide() : console.warn(e.message);
},
error: function(e, t) {
i.hide(), console.warn(e, t);
}
});
})) : void sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_close_cancel"
}, r), !1);
});
}), i.find(".j-motor-form-head").on("click", function(e) {
e.preventDefault(), sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_gotoCar"
}, r), !1);
var t = "https://m.dcdapp.com/motor/m/car_series/index?series_id=" + o.series_id + "&zt=tt_card_article";
location.href = "sslocal://webview?url=" + encodeURIComponent(t) + "&title=" + o.series_name + "&use_wk=1";
}), needCleanDoms.push(i), o.pos > t ? $("article > div p:nth-of-type(" + Math.ceil(t / 2) + ")").before(i) : $("article > div p:nth-of-type(" + o.pos + ")").before(i), 
sendUmengEventV3("web_show_event", $.extend({
obj_id: "detail_scard_n_consultation_render"
}, r), !1), sendUmengWhenTargetShown(i.get(0), "web_show_event", "", $.extend({
obj_id: "detail_scard_n_consultation"
}, r), !0, {
version: 3,
isDoubleSend: !1
});
}

function motorDealerContextRender(e, t, a, n, o) {
var i = $(e({
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
req_id: n,
card_id: o.card_id,
card_type: o.card_type,
extra_params: JSON.stringify({})
};
i.data("series_id", o.series_id), i.data("series_name", o.series_name), i.find(".j-motor-enter").on("click", function(e) {
e.stopPropagation(), e.preventDefault(), sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_open"
}, r), !1), i.find(".motor-form-body").show(), $(this).hide();
}), i.find(".j-motor-form-normal").on("click", function(e) {
e.preventDefault(), sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_gotoCar"
}, r), !1);
var t = "https://m.dcdapp.com/motor/m/car_series/index?series_id=" + o.series_id + "&zt=tt_card_article";
location.href = "sslocal://webview?url=" + encodeURIComponent(t) + "&title=" + o.series_name + "&use_wk=1";
}), i.find(".j-motor-form-user").on("focus", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_focus",
focus_dom: "user_name"
}, r), !1);
}), i.find(".j-motor-form-mobile").on("focus", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_focus",
focus_dom: "phone"
}, r), !1);
}), i.find(".j-motor-form-btn").on("click", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation"
}, r), !1);
var e = $(this), t = e.closest(".motor-form-body"), n = t.find("[name=userName]"), s = t.find("[name=userMobile]"), l = t.find("[name=userAgree]"), c = n.val(), d = s.val(), u = l.is(":checked");
return "" === c ? (n.addClass("error").next(".motor-form-tip").show(), !1) : (n.removeClass("error").next(".motor-form-tip").hide(), 
"" !== d && /^1[3|4|5|7|8|9]\d{9}$/.test(d) ? (s.removeClass("error").next(".motor-form-tip").hide(), 
u ? ($("article").find(".motor-form-body [name=userName]").val(c), $("article").find(".motor-form-body [name=userMobile]").val(d), 
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
e.removeAttr("disabled").text("立即获取最低价"), t.data && "true" === t.data.result ? (i.find(".motor-form-edit").hide(), 
i.find(".motor-form-sheet").show(), i.find(".j-close-dealer-card").hide()) : ToutiaoJSBridge.call("toast", {
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
}), i.find(".j-motor-sheet-rewrite").on("click", function() {
sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_rewrite"
}, r), !1), i.find(".motor-form-edit").show(), i.find(".motor-form-sheet").hide();
}), i.find(".j-close-dealer-card").on("click", function(e) {
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
"success" === e.message ? i.hide() : console.warn(e.message);
},
error: function(e, t) {
i.hide(), console.warn(e, t);
}
});
})) : void sendUmengEventV3("web_clk_event", $.extend({
obj_id: "detail_scard_n_consultation_close_cancel"
}, r), !1);
});
}), needCleanDoms.push(i), o.pos > t ? $("article > div p:nth-of-type(" + Math.ceil(t / 2) + ")").before(i) : $("article > div p:nth-of-type(" + o.pos + ")").before(i), 
sendUmengEventV3("web_show_event", $.extend({
obj_id: "detail_scard_n_consultation_render"
}, r), !1), sendUmengWhenTargetShown(i.get(0), "web_show_event", "", $.extend({
obj_id: "detail_scard_n_consultation"
}, r), !0, {
version: 3,
isDoubleSend: !1
});
}

function followActionHandler() {
var e = $(this), t = e.data("userId"), a = e.data("mediaId"), n = e.hasClass("following"), o = e.attr("data-concerntype") || "", i = Page.article.type, r = "" === o, s = Page.hasExtraSpace && r;
if (!e.hasClass("disabled")) if ($(".subscribe-button").addClass("disabled"), $("header").addClass("canmoving"), 
$(".boot-outer-container").css("display", "none"), "pgc" === i) doFollowMedia(t, a, n, o), 
s && !Page.author.hasRedPack && (n ? "open" === $("header").attr("sugstate") ? NativePlayGif.willStart(function() {
$("header").attr("sugstate", "no");
}) : $("header").attr("sugstate", "no") : doRecommendUsers(Page.author.userId, recommendUsersSuccess, recommendUsersError)); else if ("wenda" === i) {
doFollowUser(t, a, n, void 0, followSource.wenda, "answer_detail_top_card");
var l = $.extend({}, wenda_extra.gd_ext_json || {}, {
source: "answer_detail_top_card",
position: "detail",
to_user_id: t,
follow_type: "from_group",
group_id: wenda_extra.ansid,
server_source: 28
});
Page.author.hasRedPack && (l.is_redpacket = 1), sendUmengEventV3(n ? "rt_unfollow" : "rt_follow", l), 
s && (client.isAndroid && client.isNewsArticleVersionNoLessThan("6.2.5") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.3.3")) && (n ? "open" === $("header").attr("sugstate") ? NativePlayGif.willStart(function() {
$("header").attr("sugstate", "no");
}) : $("header").attr("sugstate", "no") : doRecommendUsers(Page.author.userId, recommendUsersSuccess, recommendUsersError));
} else "forum" === i && (doFollowUser(t, a, n, void 0, followSource.forum, "detail"), 
s && (client.isAndroid && client.isNewsArticleVersionNoLessThan("6.2.5") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.2.6")) && (n ? "open" === $("header").attr("sugstate") ? NativePlayGif.willStart(function() {
$("header").attr("sugstate", "no");
}) : $("header").attr("sugstate", "no") : doRecommendUsers(Page.author.userId, recommendUsersSuccess, recommendUsersError)), 
(client.isAndroid && client.isNewsArticleVersionNoLessThan("6.4.4") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.4.5")) && sendUmengEventV3(n ? "rt_unfollow" : "rt_follow", {
to_user_id: t,
follow_type: "from_group",
group_id: forum_extra.thread_id,
item_id: forum_extra.thread_id,
category_name: forum_extra.category_name,
source: "weitoutiao_detail",
server_source: followSource.forum,
position: "title_below",
log_pb: forum_extra.log_pb
}, !1));
}

function followBottomAction() {
var e = $(this), t = e.data("userId"), a = e.data("mediaId"), n = e.hasClass("following");
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
Page.author.hasRedPack && (o.is_redpacket = 1), sendUmengEventV3(n ? "rt_unfollow" : "rt_follow", o);
}
doFollowUser(t, a, n, void 0, followSource[Page.article.type] || "", "wenda" === Page.article.type ? "answer_detail_bottom_card" : "detail_bottom");
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
var t = $(this).attr("it-is-user-id"), a = "", n = "", o = "";
"pgc" === Page.article.type ? (send_umeng_event("detail", "sub_rec_click", {
value: t,
extra: {
source: "article_detail",
profile_user_id: Page.author.userId
}
}), a = "detail_follow_card_article", n = Page.category_name, o = Page.statistics.group_id) : "forum" === Page.article.type ? (send_umeng_event("follow_card", "click_avatar", {
value: forum_extra.thread_id,
ext_value: t,
extra: {
source: "weitoutiao_detail",
profile_user_id: Page.author.userId
}
}), a = "detail_follow_card_topic", n = Page.forum_extra.category_name, o = Page.forum_extra.thread_id) : "wenda" === Page.article.type && (send_umeng_event("follow_card", "click_avatar", {
value: wenda_extra.ansid,
ext_value: t,
extra: {
source: "wenda_detail",
profile_user_id: Page.author.userId
}
}), a = "detail_follow_card_wenda", n = wenda_extra.gd_ext_json ? wenda_extra.gd_ext_json.category_name : "", 
o = wenda_extra.ansid), window.location.href = "sslocal://profile?uid=" + t + ("wenda" === Page.article.type ? "&refer=wenda" : "") + "&group_id=" + o + "&from_page=" + a + "&profile_user_id=" + Page.author.userId + (n ? "&category_name=" + n : "");
}
}

function mediasugFollowAction() {
var e = $(this), t = null != e.attr("isfollowing"), a = e.closest(".ms-item").attr("it-is-user-id"), n = e.closest(".ms-item").attr("it-is-media-id"), o = e.attr("reason"), i = followSource[Page.article.type + "_sug"], r = e.closest(".ms-item").data("index");
if (e.attr("disabled", !0), "wenda" === Page.article.type) sendUmengEventV3(t ? "rt_unfollow" : "rt_follow", $.extend({}, wenda_extra.gd_ext_json || {}, {
source: "answer_detail_follow_card",
position: "detail",
to_user_id: a,
order: r,
profile_user_id: wenda_extra.user ? wenda_extra.user.user_id : "",
follow_type: "from_recommend"
})); else if ("forum" !== Page.article.type || client.isNewsArticleVersionNoLessThan("6.4.2")) {
if (client.isAndroid && client.isNewsArticleVersionNoLessThan("6.4.4") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.4.5")) {
var s = {
source: "detail_follow_card",
to_user_id: a,
order: r,
profile_user_id: Page.author.userId,
follow_type: "from_recommend",
category_name: "forum" === Page.article.type ? forum_extra.category_name : Page.category_name,
server_source: followSource[Page.article.type + "_sug"],
log_pb: "forum" === Page.article.type ? forum_extra.log_pb : Page.log_pb
};
"" != n && (s.media_id = n), sendUmengEventV3(t ? "rt_unfollow" : "rt_follow", s, !1);
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
reason: o,
source: i,
order: r,
from: "sug"
}, function(n) {
e.attr("disabled", null), "object" == typeof n && 1 === +n.code && ("pgc" !== Page.article.type || client.isNewsArticleVersionNoLessThan("6.4.2") || send_umeng_event("detail", t ? "sub_rec_unsubscribe" : "sub_rec_subscribe", {
value: a,
extra: {
source: "article_detail",
profile_user_id: Page.author.userId
}
}), e.attr("isfollowing", t ? null : ""), doRecommendUsers(Page.author.userId, function(e) {
if (Array.isArray(e)) for (var n = e.length, o = 0; n > o; o++) e[o].user_id == a && (e[o].is_following = !t);
}, function() {}));
});
}

function domPrepare() {
var e = document.querySelector(".mediasug-outer-container"), t = document.querySelector(".mediasug-inner-container"), a = document.querySelector("header");
if (e && t) {
e.addEventListener("transitionend", function() {
console.info("transitionend"), NativePlayGif.ended();
var t = e.querySelector(".ms-list").classList;
"open" == a.getAttribute("sugstate") ? t.contains("no-scrolling") && t.remove("no-scrolling") : t.add("no-scrolling");
}, !1);
var n = window.MutationObserver || window.WebKitMutationObserver;
if (n) {
var o = new n(function(e) {
e.forEach(function(e) {
var t = e.attributeName;
if ("sugstate" === t) {
var a = e.target.getAttribute(t);
if ("open" === a) {
console.info("SUG-OEPN"), mediasugScroll.open(), $(document).on("scroll", mediasugScroll.pagescroll), 
ToutiaoJSBridge.on("webviewScrollEvent", function(e) {
mediasugScroll.webviewScroll(e);
});
var n, o;
"pgc" === Page.article.type ? (n = "article_detail", o = Page.statistics.group_id) : "forum" === Page.article.type ? (n = "weitoutiao_detail", 
o = forum_extra.thread_id) : "wenda" === Page.article.type && (n = "wenda_detail", 
o = wenda_extra.ansid), send_umeng_event("follow_card", "show", {
value: o,
extra: {
source: n
}
});
} else "close" === a ? (console.info("SUG-HIDE"), $(document).off("scroll", mediasugScroll.pagescroll), 
mediasugScroll.pushimpr(!0)) : (console.info("SUG-HIDE"), $(document).off("scroll", mediasugScroll.pagescroll), 
mediasugScroll.pushimpr(!0));
}
});
});
o.observe(document.getElementsByTagName("header")[0], {
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
if (e.user_decoration && "string" == typeof e.user_decoration) try {
e.user_decoration = JSON.parse(e.user_decoration);
} catch (t) {
e.user_decoration = {};
}
}), mediasugScroll.init(list);
var MediasugTemplateFunction = function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) {
__p += "";
for (var i = 0; i < data.length; i++) {
var item = data[i];
__p += '<div class="ms-item" it-is-user-id="' + (null == (__t = item.user_id) ? "" : __t) + '" data-index="' + (null == (__t = i + 1) ? "" : __t) + '" it-is-media-id="' + (null == (__t = item.media_id ? item.media_id : "") ? "" : __t) + '"><div class="ms-avatar"><div class="ms-avatar-wrap"><img class="ms-avatar-image" src="' + (null == (__t = item.avatar_url) ? "" : __t) + '"></div>', 
useServerV && false && item.user_auth_info && item.user_auth_info.auth_type && (__p += "" + (null == (__t = buildServerVIcon2(item.user_auth_info.auth_type, "avatar_icon")) ? "" : __t)),
__p += "</div>", false && item.user_decoration && item.user_decoration.url && (__p += '<div class="avatar-decoration" style="background-image: url(' + (null == (__t = item.user_decoration.url) ? "" : __t) + ')"></div>'),
__p += '<div class="avatar-decoration avatar-night-mask"></div><div class="ms-name-wrap"><div class="ms-name ' + (null == (__t = !fa && item.user_verified ? "" : "") ? "" : __t) + '">' + (null == (__t = item.name) ? "" : __t) + '</div></div><div class="ms-desc">' + (null == (__t = item.reason_description) ? "" : __t) + '</div><button reason="' + (null == (__t = item.reason) ? "" : __t) + '" class="ms-subs ' + (null == (__t = isRedFocusButton ? "ms-red-btn" : "") ? "" : __t) + '" ' + (null == (__t = item.is_following ? " isfollowing " : "") ? "" : __t) + " " + (null == (__t = item.is_followed ? " isfollowed " : "") ? "" : __t) + ' ><span class="focus-icon">&nbsp;</span></button></div>';
}
__p += "";
}
return __p;
}, MediasugTemplateString = MediasugTemplateFunction({
data: list,
useServerV: false,
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

function doFollowUser(e, t, a, n, o, i) {
subscribeTimeoutTimer = setTimeout(change_following_state, 1e4, a, !0), ToutiaoJSBridge.call("user_follow_action", {
id: e,
action: a ? "unfollow" : "dofollow",
reason: n,
source: o,
from: i
}, function(e) {
clearTimeout(subscribeTimeoutTimer), e && "object" == typeof e && 1 === +e.code ? change_following_state(!!e.status, !0) : change_following_state(a, !0);
});
}

function doFollowMedia(e, t, a, n) {
subscribeTimeoutTimer = setTimeout(change_following_state, 1e4, a, !0), ToutiaoJSBridge.call(a ? "do_media_unlike" : "do_media_like", {
id: t,
uid: e,
concern_type: n,
source: !a && Page.author.hasRedPack ? followSource.pgc + 1e3 : followSource.pgc
}, function(n) {
clearTimeout(subscribeTimeoutTimer), 1 === +n.code ? change_following_state(!a, !0, function(a) {
client.isNewsArticleVersionNoLessThan("6.4.2") ? (client.isAndroid && client.isNewsArticleVersionNoLessThan("6.4.4") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.4.5")) && sendUmengEventV3(a ? "rt_follow" : "rt_unfollow", {
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
var e = formatCount(null, forum_extra.read_count, "0");
$("#origin-read-count").html(e);
for (var t = document.querySelectorAll(".emoji"), a = 0, n = t.length, a = 0; n > a; a++) t[a].style.backgroundImage = "url(http://s3.pstatp.com/toutiao/tt_tps/static/images/ttemoji/" + t[a].classList[1] + "@3x.png)";
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
category_name: forum_extra.category_name,
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
var n = a.parent(), o = $('<div class="swipe_tip">左滑查看更多</div>');
n.append(o), n.on("touchstart", function() {
o.css("opacity", "0");
}).on("scroll touchend", function() {
0 === this.scrollLeft && o.css("opacity", "1");
}), needCleanDoms.push(n);
}
});
}

function appendVideoImg() {
var e = this.parentNode;
e && (e.style.background = "black");
var t = $(this), a = this.dataset;
if (!a.width && !a.height) {
var n = .75, o = 0, i = n, r = "", s = this.naturalWidth, l = this.naturalHeight;
s && l && (o = l / s, n >= o ? i = o : r = "height: 100%; width: auto;");
var c = t.clientWidth;
t.css("height", c * i + "px"), this.setAttribute("style", r), e.setAttribute("data-video-size", JSON.stringify({
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
var a = $(t), n = t.dataset, o = n.width, i = n.height, r = .75, s = 0, l = r, c = "";
o && i && (s = i / o, r >= s ? l = s : c = "height: 100%; width: auto;");
var d = t.clientWidth;
if (a.css("height", d * l + "px"), n.wendaSource && "object" == typeof window.wenda_extra) {
var u = formatDuration(n.duration);
if (a.html('<img src="' + n.poster + '" style="' + c + '" onload="appendVideoImg.call(this)" onerror="errorVideoImg.call(this)" /><i class="custom-video-trigger"></i><i class="custom-video-duration">' + u + "</i>"), 
"pgc" === n.wendaSource) {
var _ = $('<a class="cv-wd-info-wrapper" href="' + n.openUrl + '"><span class="cv-wd-info-name" ' + (Boolean(Number(n.isVerify)) ? "is-verify" : "") + ">" + n.mediaName + '</span><span class="cv-wd-info-pc">' + n.playCount + "次播放</span></a>");
_.on("click", function() {
ToutiaoJSBridge.call("pauseVideo"), send_umeng_event("answer_detail", "click_video_detail", {
value: wenda_extra.ansid,
extra: {
video_id: n.vid,
enter_from: wenda_extra.enter_from || "",
ansid: wenda_extra.ansid,
qid: wenda_extra.qid,
parent_enterfrom: wenda_extra.parent_enterfrom || ""
}
});
}), needCleanDoms.push(_), a.after(_);
}
var p = {
value: wenda_extra.ansid,
extra: {
position: "detail",
video_id: n.vid,
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
} else a.html('<img src="' + n.poster + '" style="' + c + '" onload="appendVideoImg.call(this)" onerror="errorVideoImg.call(this)" /><i class="custom-video-trigger"></i>');
Page.hasExtraSpace = !1;
});
}

function checkDisplayedFactory(e, t) {
return lastBottom = {}, function() {
var a = document.querySelector(e);
if (a) {
var n = a.getBoundingClientRect();
n.bottom < 0 && lastBottom[e] >= 0 ? ToutiaoJSBridge.call(t, {
show: !0
}) : n.bottom >= 0 && lastBottom[e] < 0 && ToutiaoJSBridge.call(t, {
show: !1
}), lastBottom[e] = n.bottom;
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
var t = $(".subscribe-button"), n = t.data("userId");
if (e.id == n && "status" in e) change_following_state(!!e.status, !0); else {
var o = $('[it-is-user-id="' + e.id + '"]');
o.length > 0 && "status" in e && (o.find(".ms-subs").attr("isfollowing", e.status ? "" : null).attr("disabled", null), 
e.status && mediasugScroll.next(), doRecommendUsers(Page.author.userId, function(t) {
if (Array.isArray(t)) for (var a = t.length, n = 0; a > n; n++) t[n].user_id == e.id && (t[n].is_following = !!e.status);
}, function() {}));
}
break;

case "wenda_digg":
var i = $("#digg").attr("data-answerid");
if (window.wenda_extra && window.wenda_extra.wd_version >= 8 && e.id === window.wenda_extra.ansid) {
var r = +$(".digg-count-special").attr("realnum");
"status" in e && (1 == e.status ? formatCount(".digg-count-special", r + 1, "0") : r > 0 && formatCount(".digg-count-special", r - 1, "0"));
} else if (e.id == i && "digged" !== $("#digg").attr("wenda-state")) {
$("#digg").attr("wenda-state", "digged");
var r = +$("#digg").find(".digg-count").attr("realnum");
formatCount(".digg-count", r + 1, "赞"), formatCount(".digg-count-special", r + 1, "0");
}
break;

case "wenda_bury":
var i = $("#bury").attr("data-answerid");
if (e.id == i && "buryed" !== $("#bury").attr("wenda-state")) {
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
"function" == typeof onCarouselImageSwitch && (Page.forum_extra && Page.forum_extra.thread_id == e.id ? onCarouselImageSwitch(e.status) : Page.wenda_extra && Page.wenda_extra.ansid == e.id ? !Page.wenda_extra.is_light && onCarouselImageSwitch(e.status) : Page.statistics.group_id == e.id && onCarouselImageSwitch(e.status));
break;

case "block_action":
if (console.info(e), 1 == e.status) {
var t = $(".subscribe-button"), n = t.data("userId");
if (e.id == n) change_following_state(!1, !0); else {
var o = $('[it-is-user-id="' + e.id + '"]');
o.length > 0 && o.find(".ms-subs").attr("isfollowing", null);
}
}
}
}

function processParagraph() {
var e = /[\u2e80-\u2eff\u3000-\u303f\u3200-\u9fff\uf900-\ufaff\ufe30-\ufe4f]/, t = /[a-z0-9_:\-\/.%]{26,}/gi, a = /huawei/.test(navigator.userAgent.toLowerCase());
a && document.body.classList.add("huawei"), $("article p").each(function(a, n) {
if (!(n.classList.contains("pgc-img-caption") || !n.textContent || $(n).find(".image").length > 0)) if (e.test(n.textContent)) {
if (t.test(n.textContent)) {
var o = n.textContent.match(t);
o.forEach(function(e) {
n.innerHTML = n.innerHTML.replace(e, function(e) {
return '<br class="sysbr">' + e;
});
});
}
} else n.style.textAlign = "left";
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
var n = a.list || [];
n.slice(0, 6).indexOf("novel_channel") > -1 && (e = !1), t.popup_type = e ? "top_channel" : "add_bookshelf", 
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
var t = e.indexOf("<article>"), a = e.indexOf("</article>"), n = e.substring(t + 9, a);
globalContent = n || e, needUpdateContent = !0;
}
}

function setExtra(e) {
if (void 0 === e ? globalExtras = window : "object" == typeof e.h5_extra ? globalExtras = e : client.isIOS ? globalExtras.h5_extra = e : client.isAndroid && (globalExtras.h5_extra = $.extend(!0, globalExtras.h5_extra, e)), 
window.Page = buildPage(globalExtras), window.OldPage) _.isEqual(window.OldPage, window.Page) || (window.OldPage = window.Page, 
buildHeader(window.Page), Page.novel_data && ToutiaoJSBridge.call("is_login", {}, function(e) {
Page.is_login = e && (e.is_login || 1 == e.code), needUpdateContent && (buildArticle(globalContent), 
needUpdateContent = !1), processArticle(), buildFooter(window.Page), globalContext && contextRenderer(globalContext);
})); else {
if (Slardar && Slardar.sendCustomTimeLog("start_build_article", window.CLIENT_VERSION + "_" + window.APP_VERSION, +new Date() - startTimestamp), 
Slardar && Slardar.sendCustomCountLog("fe_article_version", JSVERSION), window.OldPage = window.Page, 
TouTiao.setDayMode(Page.pageSettings.is_daymode ? 1 : 0), TouTiao.setFontSize(Page.pageSettings.font_size), 
buildUIStyle(Page.h5_settings), buildHeader(window.Page), buildArticle(globalContent), 
needUpdateContent = !1, !Page.novel_data || Page.can_read) return buildFooter(window.Page), 
functionName(), !0;
setTimeout(function() {
ToutiaoJSBridge.call("is_login", {}, function(e) {
Page.is_login = e && (e.is_login || 1 == e.code), buildFooter(window.Page), functionName();
});
}, 100);
}
return !1;
}

function functionName() {
sendBytedanceRequest("domReady"), Slardar && Slardar.sendCustomTimeLog("start_process_article", window.CLIENT_VERSION + "_" + window.APP_VERSION, +new Date() - startTimestamp), 
ToutiaoJSBridge.on("page_state_change", processPageStateChangeEvent), processArticle(), 
Slardar && Slardar.sendCustomTimeLog("end_process_article", window.CLIENT_VERSION + "_" + window.APP_VERSION, +new Date() - startTimestamp), 
null !== globalCachedContext && contextRenderer(globalCachedContext), canSetContext = !0;
}

function insertDiv(e) {
Slardar && Slardar.sendCustomTimeLog("start_insert_div", window.CLIENT_VERSION + "_" + window.APP_VERSION, +new Date() - startTimestamp), 
canSetContext ? (contextRenderer(e), globalContext = e) : globalCachedContext = e;
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
}).on("click", "#next_serial_link", function(e) {
send_umeng_event("detail", "click_next_group", {
value: Page.statistics.group_id,
extra: {
item_id: Page.statistics.item_id
}
}), processNovelSeria(), e.preventDefault();
}).on("click", "#index_serial_link", function() {
send_umeng_event("detail", "click_catalog", {
value: Page.statistics.group_id,
extra: {
item_id: Page.statistics.item_id
}
});
}), e.on("click", ".custom-video", function() {
playVideo(this, 0);
}), e.on("click", ".toutiaopage", function() {
sendUmengEventV3("article_toutiaopage_click", {
gid: Page.statistics.group_id
}, 0);
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
var a = e.getBoundingClientRect(), n = {
sp: e.getAttribute("data-sp"),
vid: e.getAttribute("data-vid"),
frame: [ a.left + window.pageXOffset, a.top + window.pageYOffset, a.width, a.height ],
status: t
};
"object" == typeof window.wenda_extra && (n.extra = {
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
}), window.ToutiaoJSBridge.call("playNativeVideo", n, null);
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
window.NativePlayGifSwitch = Page.h5_settings.is_use_native_play_gif, IOSImageProcessor.threadGGSwitch = "forum" === Page.article.type && Page.forum_extra.use_9_layout, 
IOSImageProcessor.image_type = Page.pageSettings.image_type, IOSImageProcessor.lazy_load = Page.pageSettings.use_lazyload, 
IOSImageProcessor.start(), window.imageInited = !0;
}

function doInitVideo() {
("pgc" == Page.article.type || "wenda" == Page.article.type) && processCustomVideo();
}

function checkWindowSize() {
window.iH = window.innerHeight, window.aW = window.innerWidth, window.aW <= 0 || window.iH <= 0 ? imageSizeInitTimer = setTimeout(function() {
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
var a = e[0], n = e[1];
a && (t[a] = n);
}), function(e, a) {
var n = {};
return void 0 === e && void 0 === a ? location.hash : void 0 === a && "string" == typeof e ? t[e] : ("string" == typeof e && "string" == typeof a ? n[e] = a : void 0 === a && "object" == typeof e && (n = e), 
$.extend(t, n), void (location.hash = hash2string(t)));
};
}(), getMeta = function() {
for (var e = document.getElementsByTagName("meta"), t = {}, a = 0, n = e.length; n > a; a++) {
var o = e[a].name.toLowerCase(), i = e[a].getAttribute("content");
o && i && (t[o] = i);
}
return function(e) {
return t[e];
};
}(), urlAddQueryParams = function(e, t) {
var a, n = [], o = "?";
for (a in t) t.hasOwnProperty(a) && n.push(a + "=" + encodeURIComponent(t[a]));
return -1 !== e.indexOf("?") && (o = "&"), [ e, o, n.join("&") ].join("");
}, event_type = client.isAndroid ? "log_event" : "custom_event", sendBytedanceRequest = function() {
function e() {
r.length > 0 && (n.src = r.shift(), l = Date.now(), t());
}
function t() {
clearTimeout(i), i = setTimeout(e, s);
}
var a = "SEND-BYTE--DANCE-REQUEST", n = document.getElementById(a), o = "bytedance://";
n || (n = document.createElement("iframe"), n.id = a, n.style.display = "none", 
document.body.appendChild(n));
var i, r = [], s = 100, l = Date.now() - s - 1;
return function(e) {
var a = Date.now();
0 === r.length && a - l > s ? (n.src = o + e, l = a) : (r.push(o + e), t());
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
var t = this.settings.holder, a = "" == this.settings.exceptSelector ? this.settings.bindSelector : [ this.settings.bindSelector, this.settings.exceptSelector ].join(","), n = this.settings.exceptSelector, o = this.settings.pressedClass, i = parseInt(this.settings.triggerLatency), r = parseInt(this.settings.removeLatency);
$(t).on("touchstart", a, function(t) {
if (!$(this).is(n)) {
var a = $(this);
e.mytimer = setTimeout(function() {
a.addClass(o);
}, i), e.tar = t.target;
}
}), $(t).on("touchmove", a, function() {
$(this).is(n) || (clearTimeout(e.mytimer), $(this).removeClass(o), e.tar = null);
}), $(t).on("touchend touchcancel", a, function(t) {
if (!$(this).is(n) && e.tar === t.target) {
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
for (var e = document.querySelectorAll("script"), a = 0, n = e.length; n > a; a++) {
var o = e[a].src, i = o.indexOf("/v55/js/lib.js");
if (i > -1) {
t = o.substr(0, i);
break;
}
if (i = o.indexOf("/v60/js/lib.js"), i > -1) {
t = o.substr(0, i);
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
}(), fnTimeCountDown = function(e, t, a, n) {
var o = {
time_delta: t - new Date().getTime(),
zero: function(e) {
var e = parseInt(e, 10);
return e > 0 ? (9 >= e && (e = "0" + e), String(e)) : "00";
},
dv: function() {
e = e || Date.now();
var t = new Date(e), a = new Date(), i = Math.round((t.getTime() - (a.getTime() + this.time_delta)) / 1e3), r = {
sec: "00",
mini: "00",
hour: "00"
};
return i > 0 ? (r.sec = o.zero(i % 60), r.mini = Math.floor(i / 60) > 0 ? o.zero(Math.floor(i / 60) % 60) : "00", 
r.hour = Math.floor(i / 3600) > 0 ? o.zero(Math.floor(i / 3600) % 24) : "00") : n && n(), 
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
__p += "</a>", false && data.author.user_decoration && data.author.user_decoration.url && (__p += '<div class="avatar-decoration" style="background-image: url(' + (null == (__t = data.author.user_decoration.url) ? "" : __t) + ')"></div>'),
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
__p += data.wenda_extra.wd_version >= 6 ? '<a class="editor-edit-answer no-icon" style="display:none">编辑</a><div item="dislike-and-report" class="dislike-and-report no-icon" style="display:none;" >反对</div>' : '<a class="editor-edit-answer" style="display:none">编辑</a><div class="dislike-and-report" onclick="ToutiaoJSBridge.call(\'dislike\', {options: 0x11});">不喜欢</div>',
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
var n = $(".pcard.forum").get(0), o = "out", i = n.getBoundingClientRect();
i.bottom <= (window.innerHeight || document.body.clientHeight) && (o = "in"), "in" === o && "out" === e && (console.info("weitoutiao_in"), 
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
group_chat: function(obj) {
var __t, __p = "";
with (Array.prototype.join, obj || {}) __p += '<div class="pcard  aikan-qq"><div class="wrapper pcard-border"><div class="avatar"><img src="' + (null == (__t = data.coverImage) ? "" : __t) + '" alt="头像" class="image"></div><div class="pcard-h18 title">' + (null == (__t = data.qq_group_name) ? "" : __t) + '</div><div class="pcard-h14 supplement">' + (null == (__t = data.qq_group_desc) ? "" : __t) + '</div><div class="pcard-h14 dynamic">' + (null == (__t = data.people_num) ? "" : __t) + '</div><a class="pcard-h16 enter " href=' + (null == (__t = data.schema) ? "" : __t) + "><img class='qq-icon'src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAMAAAC7IEhfAAAAh1BMVEUAAAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9qkf8RAAAALHRSTlMA/PDj2MBbLfnm3c+Q9vLrnJZ9USYjIA0IxqqlhoRzTzQQC9+3oYhrYlM8KNw1y7UAAADhSURBVDjL1dPHFsIgEIVhIJBeNMYYe+/3/Z/PlUcJF4/b/Otvw8wgBti0ngdxMl9Hv9lsgXeL/Q/XpPiUPr3uoPGdnvngCHZnj2tlD8qGwxz9xhymDkz4BOFGpzkhMGRwQ2DN4IXAnD/abcTH7bZk96AILMhlXMHauDCjUDsuAm/XhyvwcrJoWtBzO/h62LD2wpUNT4Dk0NgwgDFEZQaVDeNyOmYrbBVsqCZiS+9xW9iwFaI7Oq46CNH8c+I3wVuTT8jqwsRyKuyoiwJ3fxGDd11KQBZVZrKkjKWMlQ7FoHoBHm5nLnqnuccAAAAASUVORK5CYII=\" />进入群聊</a></div></div>";
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
var n = $(cardTemplateFunctions[t]({
data: e
}));
} else if ("stock" == t) {
var o = [], i = [];
try {
i = JSON.parse(e.keyphrase_stock);
} catch (r) {}
if (i.forEach(function(t) {
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
var n = $(cardTemplateFunctions[t]({
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
var n = $(cardTemplateFunctions[t]({
data: e
}));
} else if ("fiction" == t) {
if ("pgc" === Page.article.type && Page.novel_data && !Page.novel_data.can_read) return;
e.base_price && (e.base_price = parseInt(e.base_price)), e.discount_price && (e.discount_price = parseInt(e.discount_price));
var n = $(cardTemplateFunctions[t](e));
if (e.benefit_time && e.time_now && e.benefit_time > e.time_now && e.benefit_time - e.time_now < 86400) {
var l = {
sec: n.find("#sec").get(0),
mini: n.find("#mini").get(0),
hour: n.find("#hour").get(0)
};
fnTimeCountDown(1e3 * e.benefit_time, 1e3 * e.time_now, l, function() {
n.find(".tag").css("display", "none"), n.find(".sale").css("display", "none"), n.find(".sale-price").css("display", "none"), 
n.find(".origin-price").removeClass("pcard-w-delete pcard-w9").addClass("pcard-w1");
});
} else n.find("#day").text(e.benefit_time <= e.time_now ? "0天" : Math.floor((e.benefit_time - e.time_now) / 86400) + "天");
} else if ("group_chat" === t) {
var c = e.data || {}, d = c.link ? c.link : "", u = c.qq_link ? c.qq_link : "";
e.coverImage = c.coverImage || "http://p3.pstatp.com/large/7bcf0002fa942ff0784d.png", 
e.link = d, e.qq_link = u, e.qq_group_name = c.qq_group_name || "", e.qq_group_desc = c.qq_group_desc || "", 
e.people_num = c.people_num || "", e.schema = client.isAndroid ? u : "sslocal://webview?url=" + encodeURIComponent(d);
var n = $(cardTemplateFunctions[t]({
data: e
}));
} else var n = $(cardTemplateFunctions[t](e));
n.on("click", ".button", function(t) {
t.stopPropagation(), send_umeng_event("detail", "click_card_button", a);
var n = $(this), o = n.attr("action");
"concern" === o ? dealNovelButton(t, e, n, a) : "addStock" == o && dealOptionalStockButton(t, n, e, s, a);
}), "auto" === t ? (n.find("[data-label]").on("click", function(e) {
e.stopPropagation(), send_umeng_event("detail", "click_" + this.dataset.label, a);
}), n.find('[type="button"]').on("click", function(e) {
e.stopPropagation(), location.href = this.dataset.href, send_umeng_event("detail", "click_card_button", a);
}), n.on("click", "[data-content]", function() {
location.href = this.dataset.href, send_umeng_event("detail", "click_card_content", a);
})) : "stock" === t ? (n.find('[data-label="card_selected"]').on("click", function(e) {
e.stopPropagation(), send_umeng_event("stock", "article_into_mystock", a);
}), n.find('[data-label="card_detail"]').on("click", function(e) {
e.stopPropagation(), send_umeng_event("stock", "article_into_stock", a);
}), n.find('[data-label="card_content"]').on("click", function(e) {
e.stopPropagation(), location.href = this.dataset.href, send_umeng_event("stock", "article_into_stock", a);
})) : "weitoutiao" === t ? n.on("click", "[data-content]", function() {
send_umeng_event("widget", "go_detail", {
value: this.dataset.id,
extra: {
enter_from: "widget_wtt",
card_type: 1
}
}), location.href = this.dataset.href;
}) : "group_chat" === t ? n.on("click", ".enter", function() {
send_umeng_event("detail", "enter_group_chat", a);
}) : n.on("click", function() {
send_umeng_event("detail", "click_card_content", a);
}), needCleanDoms.push(n), "wenda" === Page.article.type ? (isShowWendaFooter = 0, 
$("footer").append(n)) : "pgc" == Page.article.type && Page.novel_data && Page.novel_data.show_new_keep_reading ? $("footer").append(n) : $("footer").prepend(n), 
"weitoutiao" === t && ($(".content .title").width() < $(".content .title-inner").width() && $(".content .title-wrap").before('<div class="whole-forum"><a class="whole-forum-inner">全文</a></div>'), 
sendWeitoutiaoCardDisplayEvent({
needRecord: !0
}), $(document).on("scroll", sendWeitoutiaoCardDisplayEvent), needCleanDoms.push($(document))), 
sendUmengWhenTargetShown(n.get(0), "detail", "card_show", a, !0);
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
var t = $("header"), n = $(".subscribe-button"), o = $(".subscribe-button-bottom");
a = void 0, Page && Page.author && (Page.author.followState = e ? "following" : ""), 
e ? ($(".author-function-buttons").removeClass("redpack-button redpack-button-just-word"), 
n.addClass("following").removeClass("disabled"), t.attr("fbs", "following"), o.addClass("following").removeClass("disabled")) : (n.removeClass("following disabled"), 
t.attr("fbs", ""), t.attr("sugstate", "no"), o.removeClass("following disabled"));
}
var t, a;
return function(n, o, i) {
"function" == typeof i && i(n), o ? n !== a && (clearTimeout(t), a = n, t = setTimeout(e, 450, n, i)) : e(n, i);
};
}(), followSource = {
pgc: 30,
pgc_sug: 34,
forum: 68,
forum_sug: 69,
wenda: 28,
wenda_sug: 71
}, doRecommendUsers = function() {
function e(e, n, o) {
$.ajax({
dataType: "jsonp",
url: "http://ic.snssdk.com/api/2/relation/follow_recommends/",
data: e,
timeout: 1e4,
beforeSend: function() {
return t ? !1 : void (t = !0);
},
success: function(t, i, r) {
"article" in Page && ("success" === t.message && "object" == typeof t.data && Array.isArray(t.data.recommend_users) && t.data.recommend_users.length >= 3 ? (a[e.to_user_id] = t.data.recommend_users, 
domPrepare(), n(t.data.recommend_users)) : o(t, i, r));
},
error: function(e, t, a) {
o(a, t, e);
},
complete: function() {
t = !1;
}
});
}
var t = !1, a = {}, n = {};
return function(t, o, i, r) {
if ("function" == typeof o && "function" == typeof i) {
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
(client.isAndroid && client.isNewsArticleVersionNoLessThan("6.2.5") || client.isIOS && client.isNewsArticleVersionNoLessThan("6.2.6")) && $.isEmptyObject(n) ? getCommonParams(function(t) {
n = t.data || t, $.extend(!0, c, n), e(c, o, i);
}) : ($.extend(!0, c, n), e(c, o, i));
}
};
}(), mediasugScroll = function() {
var e, t, a, n = innerWidth, o = 150, i = 0, r = {}, s = 0, l = !1, c = [], d = "in", u = null, p = 0, f = $("header").height() + 232;
return {
init: function(d) {
l || (l = !0, r = d, s = d.length, n = innerWidth, i = s * o + 24, this.imprcache = {}, 
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
}, a = _.throttle(mediasugScroll.handler, 150), f = $("header").height() + 232);
},
range: function(e) {
var t = Math.floor(e / o);
t = Math.max(t, 0), e += n;
var a = Math.ceil(e / o);
a = Math.min(a, s) - 1;
for (var i = []; a >= t; ) i[i.length] = t++;
return i;
},
pushimpr: function(a) {
if (l) {
if (this.sendResult.impressions_in = [], Object.keys(this.imprcache).length > 0) {
this.sendResult.impressions_out = [];
for (var n in this.imprcache) {
var o = this.imprcache[n];
this.imprlog.push({
uid: n,
time: o,
duration: new Date().getTime() - o
}), console.info("leave", n), this.sendResult.impressions_out.push({
imp_item_type: 51,
imp_item_id: n,
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
var a = this, n = [];
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
}), n.push({
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
a.sendResult.impressions_out = n;
var o = {};
$.extend(!0, o, a.sendResult), ToutiaoJSBridge.call("impression", o);
}
},
handler: function() {
if (l) {
for (var e = mediasugScroll.range(this.scrollLeft || 0), t = [], a = {}, n = 0; n < c.length; n++) a[c[n]] = !0;
for (n = 0; n < e.length; n++) e[n] in a ? delete a[e[n]] : t.push(e[n]);
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
var t, a, n, o, i, r, s = $("body").height();
if (i = e.rect.substring(1, e.rect.length - 1).split(","), t = i[0], a = Math.abs(i[1]), 
n = i[2], o = i[3], s === innerHeight) r = a >= f ? "out" : "in"; else {
var l = s - innerHeight;
r = a >= f - l ? "out" : "in";
}
"out" === d && "in" === r ? mediasugScroll.dealimpr([], c) : "in" === d && "out" === r && mediasugScroll.pushimpr(!0), 
d = r;
}
}
};
}(), subscribeTimeoutTimer, checkHeaderDisplayed = checkDisplayedFactory("#profile", "showTitleBarPgcLayout"), checkWendanextDisplayed = checkDisplayedFactory(".serial", "showWendaNextLayout"), checkWendaABHeaderLayout = checkDisplayedFactory(".wenda-title", "showWendaABHeaderLayout"), canSetContext = !1, globalContent, globalCachedContext = null, globalContext, needCleanDoms = [], imprProcessQueue = [], needUpdateContent = !1;

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
var a = e.getAttribute("type") || "", n = +e.getAttribute("width") || 0, o = +e.getAttribute("height") || 0, i = +e.getAttribute("thumb_width") || 0, r = +e.getAttribute("thumb_height") || 0, s = {
index: t,
holder: e,
state: IOSImageProcessor.image_type,
url: "",
href: e.getAttribute("href") || "",
link: e.getAttribute("redirect-link") || "",
isGIF: "gif" === a || "2" === a,
isLONG: n > 3 * o || o > 3 * n,
sizeArray: {
big: [ n, o ],
small: [ i, r ]
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
if (Array.isArray(t) && t.length > 0) for (var a = 0, n = t.length; n > a; a++) this.renderHolder(t[a], e);
},
renderHolder: function(e, t, a, n) {
console.info("picture", e, t, a, n);
var o = document.createDocumentFragment(), i = this.adjustOriginImageScale(e.sizeArray[e.sizeType], e.state);
if ("" !== e.url) {
var r = document.createElement("img");
r.onload = function() {
console.info("onload", e, this), "function" == typeof n && n();
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
c.setAttribute("bg", i[0] > 140 && i[1] > 44), IOSImageProcessor.threadGGSwitch && 1 === IOSImageProcessor.allPicturesCount && (c.parentNode.style.paddingTop = 0, 
c.parentNode.style.height = i[1] + "px"), c.style.width = i[0] + "px", c.style.height = i[1] + "px", 
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
var e = this.getAttribute("index"), t = IOSImageProcessor.pictures[e], a = t.state, n = "full";
if (IOSImageProcessor.threadGGSwitch) send_umeng_event("talk_detail", "picture_click", Page.forumStatisticsParams), 
"none" === a && 1 === IOSImageProcessor.allPicturesCount && (n = "origin"); else if ("origin" === a || t.isGIF) {
if (t.link.indexOf("sslocal") > -1) return location.href = t.link, !1;
if (/^http(s)?:\/\//i.test(t.href)) return location.href = t.href, !1;
} else n = "origin";
switch (n) {
case "origin":
t.holder.classList.add("animation");

case "thumb":
ToutiaoJSBridge.call("loadDetailImage", {
type: n + "_image",
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
var i = "full_image?" + obj2search(IOSImageProcessor.currentViewing);
sendBytedanceRequest(i), console.info(i), "origin" !== a && ToutiaoJSBridge.call("loadDetailImage", {
type: (IOSImageProcessor.isDuoTuThread ? "thumb" : "origin") + "_image",
index: e
});
}
},
appendLocalImage: function(e, t, a, n, o) {
console.info("appendLocalImage", arguments);
var i = IOSImageProcessor.pictures[e];
if (i.url = t, i.state = a, i.sizeType = IOSImageProcessor.state2size[a], !t && "origin" === a && n && o ? (i.nativePlayGifLoaded = !0, 
i.sizeArray.big = [ n, o ], IOSImageProcessor.renderHolder(i)) : "boolean" == typeof n && "function" == typeof o ? IOSImageProcessor.renderHolder(i, !1, n, o) : IOSImageProcessor.renderHolder(i), 
IOSImageProcessor.HAS_SHOW_ALL_ORIGINS_BUTTON && "origin" === a && (IOSImageProcessor.loadedOrigins++, 
IOSImageProcessor.allPicturesCount === IOSImageProcessor.loadedOrigins)) {
var r = document.getElementById("toggle-img");
r && (r.style.visibility = "hidden");
}
var s = i.href, l = s.match(/url=([^&]*)/);
if (l) {
l = l[0];
var c = arguments[3], d = arguments[4];
"number" == typeof c && "number" == typeof d || IOSImageProcessor.pictures.forEach(function(n, o) {
!n.url && o !== e && n.href.indexOf(l) > -1 && (console.info("找到相同图片", e, o), IOSImageProcessor.appendLocalImage.call(IOSImageProcessor, o, t, a, c, d));
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
var n = document.createElement(a);
n.classList.add("image-wrap"), e.insertBefore(n, t), n.appendChild(t);
}
this.pictures.forEach(function(t, a) {
var n = t.holder, o = n.parentNode;
"P" === o.tagName ? "" !== o.textContent ? (console.info("[" + a + "]所在段落有文本，应当分割"), 
e(o, n, "span")) : o.querySelectorAll(".image").length > 1 ? (console.info("[" + a + "]所在段落有其他图片，应当分割"), 
e(o, n, "span")) : (console.info("[" + a + "]正确"), o.classList.add("image-wrap")) : (console.info("[" + a + "]直接加包裹"), 
e(o, n, "p"));
});
},
adjustOriginImageScale: function(e, t) {
var a = 200, n = 200, o = window.aW / 2;
if (this.isDuoTuThread) return [ "ERROR", "ERROR" ];
var i, r, s = e[0] / e[1];
return i = e[0] ? e[0] > o ? window.aW : e[0] : a, r = s ? parseInt(i / s) : n, 
"none" === t && (r = Math.min(r, .8 * window.iH)), [ i, r ];
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
var n = a.holder.querySelector(".autoscript");
n && send_exposure_event_once(n, function() {
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
var n = Array.prototype.slice.call(t);
n.push(!0, function() {
0 === --a && "function" == typeof e && e();
}), appendLocalImage.apply(this, n);
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
window.aW = document.body.offsetWidth || window.innerWidth, console.info("resize", window.aW, window.abcdefg), 
window.imageInited && IOSImageProcessor.renderAllHolders();
}, ToutiaoJSBridge.on("menuItemPress", processMenuItemPressEvent);
}(), !function(e) {
function t(a) {
if (n[a]) return n[a].exports;
var o = n[a] = {
i: a,
l: !1,
exports: {}
};
return e[a].call(o.exports, o, o.exports, t), o.l = !0, o.exports;
}
var a = window.webpackJsonp;
window.webpackJsonp = function(t, n, i) {
for (var r, s, l = 0, c = []; l < t.length; l++) s = t[l], o[s] && c.push(o[s][0]), 
o[s] = 0;
for (r in n) Object.prototype.hasOwnProperty.call(n, r) && (e[r] = n[r]);
for (a && a(t, n, i); c.length; ) c.shift()();
};
var n = {}, o = {
1: 0
};
return t.e = function(e) {
function a() {
s.onerror = s.onload = null, clearTimeout(l);
var t = o[e];
0 !== t && (t && t[1](new Error("Loading chunk " + e + " failed.")), o[e] = void 0);
}
var n = o[e];
if (0 === n) return new Promise(function(e) {
e();
});
if (n) return n[2];
var i = new Promise(function(t, a) {
n = o[e] = [ t, a ];
});
n[2] = i;
var r = document.getElementsByTagName("head")[0], s = document.createElement("script");
s.type = "text/javascript", s.charset = "utf-8", s.async = !0, s.timeout = 12e4, 
t.nc && s.setAttribute("nonce", t.nc), s.src = t.p + "" + ({
"0": "component"
}[e] || e) + "." + {
"0": "f9ddddaa224c408d0486"
}[e] + ".js";
var l = setTimeout(a, 12e4);
return s.onerror = s.onload = a, r.appendChild(s), i;
}, t.m = e, t.c = n, t.i = function(e) {
return e;
}, t.d = function(e, a, n) {
t.o(e, a) || Object.defineProperty(e, a, {
configurable: !1,
enumerable: !0,
get: n
});
}, t.n = function(e) {
var a = e && e.__esModule ? function() {
return e["default"];
} : function() {
return e;
};
return t.d(a, "a", a), a;
}, t.o = function(e, t) {
return Object.prototype.hasOwnProperty.call(e, t);
}, t.p = "https://s2.pstatp.com/pgc/v2/resource/card/", t.oe = function(e) {
throw console.error(e), e;
}, t(t.s = 29);
}([ function(e, t, a) {
"use strict";
Object.defineProperty(t, "__esModule", {
value: !0
}), function(e) {
function n() {
return null;
}
function o(e) {
var t = e.nodeName, a = e.attributes;
e.attributes = {}, t.defaultProps && b(e.attributes, t.defaultProps), a && b(e.attributes, a);
}
function i(e, t) {
var a, n, o;
if (t) {
for (o in t) if (a = W.test(o)) break;
if (a) {
n = e.attributes = {};
for (o in t) t.hasOwnProperty(o) && (n[W.test(o) ? o.replace(/([A-Z0-9])/, "-$1").toLowerCase() : o] = t[o]);
}
}
}
function r(e, t, n) {
var o = t && t._preactCompatRendered && t._preactCompatRendered.base;
o && o.parentNode !== t && (o = null), !o && t && (o = t.firstElementChild);
for (var i = t.childNodes.length; i--; ) t.childNodes[i] !== o && t.removeChild(t.childNodes[i]);
var r = a.i(U.c)(e, t, o);
return t && (t._preactCompatRendered = r && (r._component || {
base: r
})), "function" == typeof n && n(), r && r._component || r;
}
function s(e, t, n, o) {
var i = a.i(U.a)(X, {
context: e.context
}, t), s = r(i, n), l = s._component || s.base;
return o && o.call(l, s), l;
}
function l(e) {
var t = e._preactCompatRendered && e._preactCompatRendered.base;
return t && t.parentNode === e ? (a.i(U.c)(a.i(U.a)(n), e, t), !0) : !1;
}
function c(e) {
return f.bind(null, e);
}
function d(e, t) {
for (var a = t || 0; a < e.length; a++) {
var n = e[a];
Array.isArray(n) ? d(n) : n && "object" == typeof n && !g(n) && (n.props && n.type || n.attributes && n.nodeName || n.children) && (e[a] = f(n.type || n.nodeName, n.props || n.attributes, n.children));
}
}
function u(e) {
return "function" == typeof e && !(e.prototype && e.prototype.render);
}
function _(e) {
return S({
displayName: e.displayName || e.name,
render: function() {
return e(this.props, this.context);
}
});
}
function p(e) {
var t = e[q];
return t ? t === !0 ? e : t : (t = _(e), Object.defineProperty(t, q, {
configurable: !0,
value: !0
}), t.displayName = e.displayName, t.propTypes = e.propTypes, t.defaultProps = e.defaultProps, 
Object.defineProperty(e, q, {
configurable: !0,
value: t
}), t);
}
function f() {
for (var e = [], t = arguments.length; t--; ) e[t] = arguments[t];
return d(e, 2), m(U.a.apply(void 0, e));
}
function m(e) {
e.preactCompatNormalized = !0, y(e), u(e.nodeName) && (e.nodeName = p(e.nodeName));
var t = e.attributes.ref, a = t && typeof t;
return !Z || "string" !== a && "number" !== a || (e.attributes.ref = v(t, Z)), w(e), 
e;
}
function h(e, t) {
for (var n = [], o = arguments.length - 2; o-- > 0; ) n[o] = arguments[o + 2];
if (!g(e)) return e;
var i = e.attributes || e.props, r = a.i(U.a)(e.nodeName || e.type, i, e.children || i && i.children), s = [ r, t ];
return n && n.length ? s.push(n) : t && t.children && s.push(t.children), m(U.d.apply(void 0, s));
}
function g(e) {
return e && (e instanceof H || e.$$typeof === F);
}
function v(e, t) {
return t._refProxies[e] || (t._refProxies[e] = function(a) {
t && t.refs && (t.refs[e] = a, null === a && (delete t._refProxies[e], t = null));
});
}
function w(e) {
var t = e.nodeName, a = e.attributes;
if (a && "string" == typeof t) {
var n = {};
for (var o in a) n[o.toLowerCase()] = o;
if (n.ondoubleclick && (a.ondblclick = a[n.ondoubleclick], delete a[n.ondoubleclick]), 
n.onchange && ("textarea" === t || "input" === t.toLowerCase() && !/^fil|che|rad/i.test(a.type))) {
var i = n.oninput || "oninput";
a[i] || (a[i] = j([ a[i], a[n.onchange] ]), delete a[n.onchange]);
}
}
}
function y(e) {
var t = e.attributes || (e.attributes = {});
nt.enumerable = "className" in t, t.className && (t.class = t.className), Object.defineProperty(t, "className", nt);
}
function b(e) {
for (var t = arguments, a = 1, n = void 0; a < arguments.length; a++) if (n = t[a]) for (var o in n) n.hasOwnProperty(o) && (e[o] = n[o]);
return e;
}
function x(e, t) {
for (var a in e) if (!(a in t)) return !0;
for (var n in t) if (e[n] !== t[n]) return !0;
return !1;
}
function k(e) {
return e && e.base || e;
}
function P() {}
function S(e) {
function t(e, t) {
I(this), B.call(this, e, t, G), E.call(this, e, t);
}
return e = b({
constructor: t
}, e), e.mixins && C(e, T(e.mixins)), e.statics && b(t, e.statics), e.propTypes && (t.propTypes = e.propTypes), 
e.defaultProps && (t.defaultProps = e.defaultProps), e.getDefaultProps && (t.defaultProps = e.getDefaultProps()), 
P.prototype = B.prototype, t.prototype = b(new P(), e), t.displayName = e.displayName || "Component", 
t;
}
function T(e) {
for (var t = {}, a = 0; a < e.length; a++) {
var n = e[a];
for (var o in n) n.hasOwnProperty(o) && "function" == typeof n[o] && (t[o] || (t[o] = [])).push(n[o]);
}
return t;
}
function C(e, t) {
for (var a in t) t.hasOwnProperty(a) && (e[a] = j(t[a].concat(e[a] || K), "getDefaultProps" === a || "getInitialState" === a || "getChildContext" === a));
}
function I(e) {
for (var t in e) {
var a = e[t];
"function" != typeof a || a.__bound || J.hasOwnProperty(t) || ((e[t] = a.bind(e)).__bound = !0);
}
}
function N(e, t, a) {
return "string" == typeof t && (t = e.constructor.prototype[t]), "function" == typeof t ? t.apply(e, a) : void 0;
}
function j(e, t) {
return function() {
for (var a, n = arguments, o = this, i = 0; i < e.length; i++) {
var r = N(o, e[i], n);
if (t && null != r) {
a || (a = {});
for (var s in r) r.hasOwnProperty(s) && (a[s] = r[s]);
} else "undefined" != typeof r && (a = r);
}
return a;
};
}
function E(e, t) {
A.call(this, e, t), this.componentWillReceiveProps = j([ A, this.componentWillReceiveProps || "componentWillReceiveProps" ]), 
this.render = j([ A, $, this.render || "render", O ]);
}
function A(e) {
if (e) {
var t = e.children;
if (t && Array.isArray(t) && 1 === t.length && ("string" == typeof t[0] || "function" == typeof t[0] || t[0] instanceof H) && (e.children = t[0], 
e.children && "object" == typeof e.children && (e.children.length = 1, e.children[0] = e.children)), 
z) {
var a = "function" == typeof this ? this : this.constructor, n = this.propTypes || a.propTypes, o = this.displayName || a.name;
n && D.a.checkPropTypes(n, e, "prop", o);
}
}
}
function $() {
Z = this;
}
function O() {
Z === this && (Z = null);
}
function B(e, t, a) {
U.e.call(this, e, t), this.state = this.getInitialState ? this.getInitialState() : {}, 
this.refs = {}, this._refProxies = {}, a !== G && E.call(this, e, t);
}
function L(e, t) {
B.call(this, e, t);
}
a.d(t, "version", function() {
return V;
}), a.d(t, "DOM", function() {
return tt;
}), a.d(t, "Children", function() {
return et;
}), a.d(t, "render", function() {
return r;
}), a.d(t, "createClass", function() {
return S;
}), a.d(t, "createFactory", function() {
return c;
}), a.d(t, "createElement", function() {
return f;
}), a.d(t, "cloneElement", function() {
return h;
}), a.d(t, "isValidElement", function() {
return g;
}), a.d(t, "findDOMNode", function() {
return k;
}), a.d(t, "unmountComponentAtNode", function() {
return l;
}), a.d(t, "Component", function() {
return B;
}), a.d(t, "PureComponent", function() {
return L;
}), a.d(t, "unstable_renderSubtreeIntoContainer", function() {
return s;
}), a.d(t, "__spread", function() {
return b;
});
var R = a(24), D = a.n(R), U = a(21);
a.d(t, "PropTypes", function() {
return D.a;
});
var V = "15.1.0", M = "a abbr address area article aside audio b base bdi bdo big blockquote body br button canvas caption cite code col colgroup data datalist dd del details dfn dialog div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup hr html i iframe img input ins kbd keygen label legend li link main map mark menu menuitem meta meter nav noscript object ol optgroup option output p param picture pre progress q rp rt ruby s samp script section select small source span strong style sub summary sup table tbody td textarea tfoot th thead time title tr track u ul var video wbr circle clipPath defs ellipse g image line linearGradient mask path pattern polygon polyline radialGradient rect stop svg text tspan".split(" "), F = "undefined" != typeof Symbol && Symbol.for && Symbol.for("react.element") || 60103, q = "undefined" != typeof Symbol ? Symbol.for("__preactCompatWrapper") : "__preactCompatWrapper", J = {
constructor: 1,
render: 1,
shouldComponentUpdate: 1,
componentWillReceiveProps: 1,
componentWillUpdate: 1,
componentDidUpdate: 1,
componentWillMount: 1,
componentDidMount: 1,
componentWillUnmount: 1,
componentDidUnmount: 1
}, W = /^(?:accent|alignment|arabic|baseline|cap|clip|color|fill|flood|font|glyph|horiz|marker|overline|paint|stop|strikethrough|stroke|text|underline|unicode|units|v|vector|vert|word|writing|x)[A-Z]/, G = {}, z = "undefined" == typeof e || !a.i({
NODE_ENV: "production"
}) || !1, H = a.i(U.a)("a", null).constructor;
H.prototype.$$typeof = F, H.prototype.preactCompatUpgraded = !1, H.prototype.preactCompatNormalized = !1, 
Object.defineProperty(H.prototype, "type", {
get: function() {
return this.nodeName;
},
set: function(e) {
this.nodeName = e;
},
configurable: !0
}), Object.defineProperty(H.prototype, "props", {
get: function() {
return this.attributes;
},
set: function(e) {
this.attributes = e;
},
configurable: !0
});
var Y = U.b.event;
U.b.event = function(e) {
return Y && (e = Y(e)), e.persist = Object, e.nativeEvent = e, e;
};
var Q = U.b.vnode;
U.b.vnode = function(e) {
if (!e.preactCompatUpgraded) {
e.preactCompatUpgraded = !0;
var t = e.nodeName, a = e.attributes = b({}, e.attributes);
"function" == typeof t ? (t[q] === !0 || t.prototype && "isReactComponent" in t.prototype) && (e.children && "" === String(e.children) && (e.children = void 0), 
e.children && (a.children = e.children), e.preactCompatNormalized || m(e), o(e)) : (e.children && "" === String(e.children) && (e.children = void 0), 
e.children && (a.children = e.children), a.defaultValue && (a.value || 0 === a.value || (a.value = a.defaultValue), 
delete a.defaultValue), i(e, a));
}
Q && Q(e);
};
var X = function() {};
X.prototype.getChildContext = function() {
return this.props.context;
}, X.prototype.render = function(e) {
return e.children[0];
};
for (var Z, K = [], et = {
map: function(e, t, a) {
return null == e ? null : (e = et.toArray(e), a && a !== e && (t = t.bind(a)), e.map(t));
},
forEach: function(e, t, a) {
return null == e ? null : (e = et.toArray(e), a && a !== e && (t = t.bind(a)), void e.forEach(t));
},
count: function(e) {
return e && e.length || 0;
},
only: function(e) {
if (e = et.toArray(e), 1 !== e.length) throw new Error("Children.only() expects only one child.");
return e[0];
},
toArray: function(e) {
return null == e ? [] : K.concat(e);
}
}, tt = {}, at = M.length; at--; ) tt[M[at]] = c(M[at]);
var nt = {
configurable: !0,
get: function() {
return this.class;
},
set: function(e) {
this.class = e;
}
};
b(B.prototype = new U.e(), {
constructor: B,
isReactComponent: {},
replaceState: function(e, t) {
var a = this;
this.setState(e, t);
for (var n in a.state) n in e || delete a.state[n];
},
getDOMNode: function() {
return this.base;
},
isMounted: function() {
return !!this.base;
}
}), P.prototype = B.prototype, L.prototype = new P(), L.prototype.isPureReactComponent = !0, 
L.prototype.shouldComponentUpdate = function(e, t) {
return x(this.props, e) || x(this.state, t);
};
var ot = {
version: V,
DOM: tt,
PropTypes: D.a,
Children: et,
render: r,
createClass: S,
createFactory: c,
createElement: f,
cloneElement: h,
isValidElement: g,
findDOMNode: k,
unmountComponentAtNode: l,
Component: B,
PureComponent: L,
unstable_renderSubtreeIntoContainer: s,
__spread: b
};
t["default"] = ot;
}.call(t, a(5));
}, function() {}, function(e, t) {
"use strict";
function a(e, t) {
if (t(e), e.firstChild) {
var n = e.firstChild;
if (n) do a(n, t); while (n = n.nextSibling);
}
}
function n(e) {
for (var t = {}, a = 0, n = e.length; n > a; a++) t[e[a].name] = e[a].value;
return t;
}
function o(e) {
for (var t = {}, a = e.attributes, n = e.dataset, o = 0, i = a.length; i > o; o++) "class" !== a[o].name && (t[a[o].name] = a[o].value);
for (var o in n) t[o] = n[o];
return t;
}
function i(e) {
e = e.toLowerCase();
var t = /\b(\w)|\s(\w)/g;
return e.replace(t, function(e) {
return e.toUpperCase();
});
}
function r(e) {
var t = e % 60;
return parseInt(e / 60) + ":" + (10 > t ? "0" + t : t);
}
Object.defineProperty(t, "__esModule", {
value: !0
}), t.default = {
map: a,
attr: n,
buildAttrs: o,
firstUpper: i,
formatTime: r
};
}, function(e) {
var t = {
utf8: {
stringToBytes: function(e) {
return t.bin.stringToBytes(unescape(encodeURIComponent(e)));
},
bytesToString: function(e) {
return decodeURIComponent(escape(t.bin.bytesToString(e)));
}
},
bin: {
stringToBytes: function(e) {
for (var t = [], a = 0; a < e.length; a++) t.push(255 & e.charCodeAt(a));
return t;
},
bytesToString: function(e) {
for (var t = [], a = 0; a < e.length; a++) t.push(String.fromCharCode(e[a]));
return t.join("");
}
}
};
e.exports = t;
}, function(e, t) {
var a, n, o;
!function(i, r) {
n = [ t, e ], a = r, o = "function" == typeof a ? a.apply(t, n) : a, !(void 0 !== o && (e.exports = o));
}(this, function(e, t) {
"use strict";
function a() {
return "jsonp_" + Date.now() + "_" + Math.ceil(1e5 * Math.random());
}
function n(e) {
try {
delete window[e];
} catch (t) {
window[e] = void 0;
}
}
function o(e) {
var t = document.getElementById(e);
t && document.getElementsByTagName("head")[0].removeChild(t);
}
function i(e) {
var t = arguments.length <= 1 || void 0 === arguments[1] ? {} : arguments[1], i = e, s = t.timeout || r.timeout, l = t.jsonpCallback || r.jsonpCallback, c = void 0;
return new Promise(function(r, d) {
var u = t.jsonpCallbackFunction || a(), _ = l + "_" + u;
window[u] = function(e) {
r({
ok: !0,
json: function() {
return Promise.resolve(e);
}
}), c && clearTimeout(c), o(_), n(u);
}, i += -1 === i.indexOf("?") ? "?" : "&";
var p = document.createElement("script");
p.setAttribute("src", "" + i + l + "=" + u), t.charset && p.setAttribute("charset", t.charset), 
p.id = _, document.getElementsByTagName("head")[0].appendChild(p), c = setTimeout(function() {
d(new Error("JSONP request to " + e + " timed out")), n(u), o(_), window[u] = function() {
n(u);
};
}, s), p.onerror = function() {
d(new Error("JSONP request to " + e + " failed")), n(u), o(_), c && clearTimeout(c);
};
});
}
var r = {
timeout: 5e3,
jsonpCallback: "callback",
jsonpCallbackFunction: null
};
t.exports = i;
});
}, function(e) {
function t() {
throw new Error("setTimeout has not been defined");
}
function a() {
throw new Error("clearTimeout has not been defined");
}
function n(e) {
if (c === setTimeout) return setTimeout(e, 0);
if ((c === t || !c) && setTimeout) return c = setTimeout, setTimeout(e, 0);
try {
return c(e, 0);
} catch (a) {
try {
return c.call(null, e, 0);
} catch (a) {
return c.call(this, e, 0);
}
}
}
function o(e) {
if (d === clearTimeout) return clearTimeout(e);
if ((d === a || !d) && clearTimeout) return d = clearTimeout, clearTimeout(e);
try {
return d(e);
} catch (t) {
try {
return d.call(null, e);
} catch (t) {
return d.call(this, e);
}
}
}
function i() {
f && _ && (f = !1, _.length ? p = _.concat(p) : m = -1, p.length && r());
}
function r() {
if (!f) {
var e = n(i);
f = !0;
for (var t = p.length; t; ) {
for (_ = p, p = []; ++m < t; ) _ && _[m].run();
m = -1, t = p.length;
}
_ = null, f = !1, o(e);
}
}
function s(e, t) {
this.fun = e, this.array = t;
}
function l() {}
var c, d, u = e.exports = {};
!function() {
try {
c = "function" == typeof setTimeout ? setTimeout : t;
} catch (e) {
c = t;
}
try {
d = "function" == typeof clearTimeout ? clearTimeout : a;
} catch (e) {
d = a;
}
}();
var _, p = [], f = !1, m = -1;
u.nextTick = function(e) {
var t = new Array(arguments.length - 1);
if (arguments.length > 1) for (var a = 1; a < arguments.length; a++) t[a - 1] = arguments[a];
p.push(new s(e, t)), 1 !== p.length || f || n(r);
}, s.prototype.run = function() {
this.fun.apply(null, this.array);
}, u.title = "browser", u.browser = !0, u.env = {}, u.argv = [], u.version = "", 
u.versions = {}, u.on = l, u.addListener = l, u.once = l, u.off = l, u.removeListener = l, 
u.removeAllListeners = l, u.emit = l, u.prependListener = l, u.prependOnceListener = l, 
u.listeners = function() {
return [];
}, u.binding = function() {
throw new Error("process.binding is not supported");
}, u.cwd = function() {
return "/";
}, u.chdir = function() {
throw new Error("process.chdir is not supported");
}, u.umask = function() {
return 0;
};
}, function(e, t, a) {
"use strict";
function n(e) {
return e && e.__esModule ? e : {
"default": e
};
}
var o = a(15), i = n(o), r = a(22), s = n(r);
!function() {
window.Promise || (window.Promise = s.default), pgcEvent.on("card-render", function() {
var e = {};
document.querySelector("body"), i.default.init({
match: /^(tt-|pre)/i,
text: /^{!--.*--}/,
context: e
}).render(this);
});
}(), window.ttCard = i.default || {};
}, function(e, t, a) {
"use strict";
function n(e) {
return e && e.__esModule ? e : {
"default": e
};
}
function o(e, t) {
if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function");
}
function i(e, t) {
if (!e) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
return !t || "object" != typeof t && "function" != typeof t ? e : t;
}
function r(e, t) {
if ("function" != typeof t && null !== t) throw new TypeError("Super expression must either be null or a function, not " + typeof t);
e.prototype = Object.create(t && t.prototype, {
constructor: {
value: e,
enumerable: !1,
writable: !0,
configurable: !0
}
}), t && (Object.setPrototypeOf ? Object.setPrototypeOf(e, t) : e.__proto__ = t);
}
Object.defineProperty(t, "__esModule", {
value: !0
});
var s = function() {
function e(e, t) {
for (var a = 0; a < t.length; a++) {
var n = t[a];
n.enumerable = n.enumerable || !1, n.configurable = !0, "value" in n && (n.writable = !0), 
Object.defineProperty(e, n.key, n);
}
}
return function(t, a, n) {
return a && e(t.prototype, a), n && e(t, n), t;
};
}(), l = a(0), c = n(l), d = function(e) {
function t(e) {
o(this, t);
var a = i(this, (t.__proto__ || Object.getPrototypeOf(t)).call(this, e));
return a.state = {
show: !0
}, a.show = function() {
a.setState({
show: !0
});
}, a.cancel = function(e) {
e.preventDefault();
var t = a.props.onCancel;
t(), a.setState({
show: !1
});
}, a;
}
return r(t, e), s(t, [ {
key: "render",
value: function() {
var e = this, t = this.state.show, a = this.props.phone;
return t ? c.default.createElement("div", {
className: "phone-confirm"
}, c.default.createElement("div", {
className: "main"
}, c.default.createElement("div", null, "联系电话"), c.default.createElement("div", null, a)), c.default.createElement("div", {
className: "footer"
}, c.default.createElement("div", {
className: "btn-group"
}, c.default.createElement("a", {
className: "btn",
onClick: function(t) {
return e.cancel(t);
}
}, "取消"), c.default.createElement("a", {
className: "btn",
href: "tel:" + a
}, "呼叫")))) : null;
}
} ]), t;
}(l.Component);
t.default = d;
}, function(e, t, a) {
"use strict";
function n(e) {
return e && e.__esModule ? e : {
"default": e
};
}
function o(e, t) {
if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function");
}
function i(e, t) {
if (!e) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
return !t || "object" != typeof t && "function" != typeof t ? e : t;
}
function r(e, t) {
if ("function" != typeof t && null !== t) throw new TypeError("Super expression must either be null or a function, not " + typeof t);
e.prototype = Object.create(t && t.prototype, {
constructor: {
value: e,
enumerable: !1,
writable: !0,
configurable: !0
}
}), t && (Object.setPrototypeOf ? Object.setPrototypeOf(e, t) : e.__proto__ = t);
}
Object.defineProperty(t, "__esModule", {
value: !0
});
var s = function() {
function e(e, t) {
for (var a = 0; a < t.length; a++) {
var n = t[a];
n.enumerable = n.enumerable || !1, n.configurable = !0, "value" in n && (n.writable = !0), 
Object.defineProperty(e, n.key, n);
}
}
return function(t, a, n) {
return a && e(t.prototype, a), n && e(t, n), t;
};
}(), l = a(0), c = n(l), d = function(e) {
function t(e) {
o(this, t);
var a = i(this, (t.__proto__ || Object.getPrototypeOf(t)).call(this, e));
return a.play.bind(a), a.pause.bind(a), a;
}
return r(t, e), s(t, [ {
key: "play",
value: function() {
this.audio.play();
}
}, {
key: "pause",
value: function() {
this.audio.pause();
}
}, {
key: "render",
value: function() {
var e = this;
return c.default.createElement("audio", {
autoPlay: this.props.autoPlay,
className: "audio-player " + this.props.className,
controls: this.props.controls,
loop: this.props.loop,
muted: this.props.muted,
onPlay: this.props.onPlay,
preload: this.props.preload,
ref: function(t) {
e.audio = t;
},
src: this.props.src,
style: this.props.style
});
}
}, {
key: "componentDidMount",
value: function() {
var e = this, t = this.audio;
t.addEventListener("error", function(t) {
e.props.onError(t);
}), t.addEventListener("canplay", function(t) {
e.props.onCanPlay(t);
}), t.addEventListener("canplaythrough", function(t) {
e.props.onCanPlayThrough(t);
}), t.addEventListener("play", function(t) {
e.setListenTrack(), e.props.onPlay(t);
}), t.addEventListener("abort", function(t) {
e.clearListenTrack(), e.props.onAbort(t);
}), t.addEventListener("ended", function(t) {
e.clearListenTrack(), e.props.onEnded(t);
}), t.addEventListener("pause", function(t) {
e.clearListenTrack(), e.props.onPause(t);
}), t.addEventListener("seeked", function(t) {
e.clearListenTrack(), e.props.onSeeked(t);
});
}
}, {
key: "setListenTrack",
value: function() {
var e = this;
if (!this.listenTracker) {
var t = this.props.listenInterval;
this.listenTracker = setInterval(function() {
e.props.onListen(e.audio.currentTime);
}, t);
}
}
}, {
key: "clearListenTrack",
value: function() {
this.listenTracker && (clearInterval(this.listenTracker), this.listenTracker = null);
}
} ]), t;
}(l.Component);
d.defaultProps = {
autoPlay: !1,
children: null,
className: "",
controls: !1,
listenInterval: 3e3,
loop: !1,
muted: !1,
onAbort: function() {},
onCanPlay: function() {},
onCanPlayThrough: function() {},
onEnded: function() {},
onError: function() {},
onListen: function() {},
onPause: function() {},
onPlay: function() {},
onSeeked: function() {},
preload: "auto",
src: null
}, t.default = d;
}, function(e, t, a) {
"use strict";
function n(e) {
return e && e.__esModule ? e : {
"default": e
};
}
function o(e, t) {
if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function");
}
function i(e, t) {
if (!e) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
return !t || "object" != typeof t && "function" != typeof t ? e : t;
}
function r(e, t) {
if ("function" != typeof t && null !== t) throw new TypeError("Super expression must either be null or a function, not " + typeof t);
e.prototype = Object.create(t && t.prototype, {
constructor: {
value: e,
enumerable: !1,
writable: !0,
configurable: !0
}
}), t && (Object.setPrototypeOf ? Object.setPrototypeOf(e, t) : e.__proto__ = t);
}
Object.defineProperty(t, "__esModule", {
value: !0
});
var s = function() {
function e(e, t) {
for (var a = 0; a < t.length; a++) {
var n = t[a];
n.enumerable = n.enumerable || !1, n.configurable = !0, "value" in n && (n.writable = !0), 
Object.defineProperty(e, n.key, n);
}
}
return function(t, a, n) {
return a && e(t.prototype, a), n && e(t, n), t;
};
}(), l = a(0), c = n(l), d = a(8), u = n(d), _ = a(4), p = n(_);
a(1);
var f = a(2), m = n(f), h = function(e) {
function t(e) {
o(this, t);
var a = i(this, (t.__proto__ || Object.getPrototypeOf(t)).call(this, e));
return a.state = {
playing: !1,
progress: 0,
audioSrc: "",
duration: 0
}, a;
}
return r(t, e), s(t, [ {
key: "control",
value: function() {
this.state.playing ? this.refs.player.pause() : this.refs.player.play();
}
}, {
key: "progress",
value: function a(e) {
var t = this.props.time;
0 == parseInt(t) && (t = this.state.duration);
var a = Math.ceil(100 * e / t) + "%";
this.setState({
progress: a
});
}
}, {
key: "onPlay",
value: function() {
this.setState({
playing: !0,
duration: this.refs.player.audio.duration
});
for (var e in t.audioList) e !== this.props.id && t.audioList[e].pause();
send_umeng_event && send_umeng_event("sound", "detail_play", {
value: Page.statistics.item_id,
extra: {
sound_id: this.props.id
}
});
}
}, {
key: "onPause",
value: function() {
this.setState({
playing: !1
});
}
}, {
key: "onEnded",
value: function() {
this.setState({
playing: !1,
progress: 0
}), this.refs.player.audio.currentTime = 0;
}
}, {
key: "onError",
value: function() {}
}, {
key: "render",
value: function() {
var e = this, t = this.props, a = t.title, n = t.time, o = t.content, i = (t.id, 
this.state), r = i.playing, s = i.progress, l = i.audioSrc;
return c.default.createElement("div", {
className: r ? "musicplayer playing" : "musicplayer not-playing",
onClick: function() {
return e.control();
}
}, c.default.createElement("div", {
className: "music-state"
}, c.default.createElement("div", {
className: "music-info"
}, c.default.createElement("span", {
className: "music-name"
}, a), c.default.createElement("span", {
className: "music-time"
}, m.default.formatTime(n))), c.default.createElement("div", {
className: "music-musician"
}, o)), c.default.createElement("div", {
className: "progressbar",
style: {
width: s
}
}), c.default.createElement(u.default, {
ref: "player",
src: l,
onError: function() {
return e.onError();
},
onListen: function(t) {
return e.progress(t);
},
onPause: function() {
return e.onPause();
},
onPlay: function(t) {
return e.onPlay(t);
},
onEnded: function(t) {
return e.onEnded(t);
}
}));
}
}, {
key: "getAudioSourceById",
value: function(e) {
var t = this;
p.default("http://i.snssdk.com/audio/urls/1/toutiao/mp4/" + e).then(function(e) {
return e.status >= 400 && ToutiaoJSBridge.call("toast", {
text: "音频获取失败，请重试",
icon_type: "icon_error"
}), e.json();
}).then(function(e) {
return atob(e.data.audio_list.audio_1.main_url.replace(/\n/gi, ""));
}).then(function(e) {
t.setState({
audioSrc: e
});
});
}
}, {
key: "componentDidMount",
value: function() {
this.getAudioSourceById(this.props.id), t.audioList[this.props.id] = this.refs.player;
}
}, {
key: "componentWillUnmount",
value: function() {
t.audioList = null;
}
} ]), t;
}(l.Component);
h.audioList = {}, t.default = h;
}, function(e, t, a) {
"use strict";
function n(e) {
return e && e.__esModule ? e : {
"default": e
};
}
function o(e, t) {
var a = {};
for (var n in e) t.indexOf(n) >= 0 || Object.prototype.hasOwnProperty.call(e, n) && (a[n] = e[n]);
return a;
}
function i(e, t) {
if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function");
}
function r(e, t) {
if (!e) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
return !t || "object" != typeof t && "function" != typeof t ? e : t;
}
function s(e, t) {
if ("function" != typeof t && null !== t) throw new TypeError("Super expression must either be null or a function, not " + typeof t);
e.prototype = Object.create(t && t.prototype, {
constructor: {
value: e,
enumerable: !1,
writable: !0,
configurable: !0
}
}), t && (Object.setPrototypeOf ? Object.setPrototypeOf(e, t) : e.__proto__ = t);
}
Object.defineProperty(t, "__esModule", {
value: !0
});
var l = function() {
function e(e, t) {
for (var a = 0; a < t.length; a++) {
var n = t[a];
n.enumerable = n.enumerable || !1, n.configurable = !0, "value" in n && (n.writable = !0), 
Object.defineProperty(e, n.key, n);
}
}
return function(t, a, n) {
return a && e(t.prototype, a), n && e(t, n), t;
};
}(), c = a(0), d = n(c);
a(1);
var u = function(e) {
function t(e) {
i(this, t);
var a = r(this, (t.__proto__ || Object.getPrototypeOf(t)).call(this, e));
return a.state = {
status: "idle",
installed: 0,
progress: 0
}, a;
}
return s(t, e), l(t, [ {
key: "hasDownloader",
value: function() {
return client.isNewsArticleVersionNoLessThan("6.1.4");
}
}, {
key: "setInstalledState",
value: function(e) {
this.setState({
installed: e
});
}
}, {
key: "isInstalled",
value: function() {
var e = this;
ToutiaoJSBridge.call("isAppInstalled", {
pkg_name: this.props.pkg_name
}, function(t) {
e.setInstalledState(1 == t.installed ? 1 : 0);
});
}
}, {
key: "renderProgress",
value: function() {
var e = void 0, t = this.state.progress;
return 50 >= t ? (e = "rotate(" + (180 + 3.6 * t) + "deg)", d.default.createElement("div", {
className: "progress-ring"
}, d.default.createElement("i", {
className: "left"
}, d.default.createElement("i", {
style: {
WebkitTransform: e,
transform: e
}
})))) : (e = "rotate(" + (-360 + 3.6 * t) + "deg)", d.default.createElement("div", {
className: "progress-ring"
}, d.default.createElement("i", {
className: "left"
}, d.default.createElement("i", null)), d.default.createElement("i", {
className: "right"
}, d.default.createElement("i", {
style: {
WebkitTransform: e,
transform: e
}
}))));
}
}, {
key: "renderIcon",
value: function(e) {
return d.default.Children.only("download_active" === e ? d.default.createElement("div", null, this.renderProgress(), "暂停") : "download_paused" === e ? d.default.createElement("div", null, this.renderProgress(), "继续") : "download_finished" === e ? d.default.createElement("div", null, "安装") : "download_failed" === e ? d.default.createElement("div", null, d.default.createElement("i", null, ""), "下载") : d.default.createElement("div", null, d.default.createElement("i", null, ""), "下载"));
}
}, {
key: "renderButton",
value: function(e, t) {
var a = this, n = 1 == e ? "gd-button gd1-btn iconfont" : "gd-button gd2-btn iconfont";
return 1 == this.state.installed ? d.default.createElement("div", {
className: n,
onClick: function(e) {
return a.handleButton(e);
}
}, d.default.createElement("i", null, ""), "打开") : d.default.createElement("div", {
className: n,
onClick: function(e) {
return a.handleButton(e);
}
}, this.renderIcon(t));
}
}, {
key: "render",
value: function() {
var e = this, t = this.props, a = t.logo, n = t.banner, o = t.name, i = t.game_type, r = t.size, s = t.desc, l = t.detail, c = t.download_url_for_ios, u = (t.pkg_name, 
t.download_url_for_android), _ = this.state.status, p = void 0;
if (a && (p = 1), n && (p = 2), client.isIOS && c) l = c, setTimeout(function() {
return e.setInstalledState(0);
}, 0); else {
if (!client.isAndroid || !u) return null;
l = l ? "sslocal://webview?url=" + encodeURIComponent(l) : u;
}
return 1 == p ? d.default.createElement("a", {
className: "game-downloader gd1",
onClick: function() {
return e.log("detail");
},
href: l
}, d.default.createElement("img", {
className: "gd-icon",
src: a
}), " ", this.renderButton(p, _), d.default.createElement("div", {
className: "gd1-cont"
}, d.default.createElement("div", {
className: "gd1-cont-name"
}, o), d.default.createElement("div", {
className: "gd1-cont-text"
}, i, " ", i ? d.default.createElement("span", {
className: "gd1-cont-split"
}) : "", r), d.default.createElement("div", {
className: "gd1-cont-text"
}, s))) : 2 == p ? d.default.createElement("a", {
className: "game-downloader gd2",
onClick: function() {
return e.log("detail");
},
href: l
}, d.default.createElement("img", {
className: "gd2-cover",
src: n
}), d.default.createElement("div", {
className: "gd2-info"
}, this.renderButton(p, _), d.default.createElement("div", {
className: "gd2-cont"
}, d.default.createElement("div", {
className: "gd2-cont-name"
}, o), d.default.createElement("div", {
className: "gd2-cont-text"
}, i, " ", i ? d.default.createElement("span", {
className: "gd2-cont-split"
}) : "", r)))) : null;
}
}, {
key: "subscribe",
value: function() {
t.eventList[this.appad.id] = this.handler.bind(this), ToutiaoJSBridge.call("subscribe_app_ad", {
data: this.state.appad
});
}
}, {
key: "unsubscribe",
value: function() {
delete t.eventList[this.appad.id], ToutiaoJSBridge.call("unsubscribe_app_ad", {
data: this.appad
});
}
}, {
key: "handler",
value: function(e) {
e.current_bytes = e.current_bytes >= 0 ? e.current_bytes : 0;
var t = e.current_bytes / e.total_bytes;
t = isNaN(t) ? 0 : Math.floor(100 * t), "download_failed" === e.status && ToutiaoJSBridge.call("toast", {
text: "应用下载失败"
}), this.setState({
status: e.status,
progress: t
});
}
}, {
key: "log",
value: function(e) {
send_umeng_event(this.appad.tag, e, this.statisticsData);
}
}, {
key: "handleButton",
value: function(e) {
1 == this.state.installed ? (e.stopPropagation(), e.preventDefault(), this.log("click_open"), 
ToutiaoJSBridge.call("openThirdApp", {
pkg_name: this.props.pkg_name
}, function(e) {
0 == e.code && ToutiaoJSBridge.call("toast", {
text: "打开应用失败，请稍后尝试"
});
})) : client.isAndroid && this.hasDownloader() ? (e.stopPropagation(), e.preventDefault(), 
ToutiaoJSBridge.call("download_app_ad", {
data: this.appad
})) : client.isAndroid && (e.stopPropagation(), e.preventDefault(), location.href = this.appad.download_url_for_android, 
this.log("click_download"));
}
}, {
key: "componentDidMount",
value: function() {
var e = o(this.props, []);
e.type = "app", e.source = "pgc", e.tag = "article_card_app_ad", e.item_id = Page.statistics.item_id, 
e.media_id = Page.author.mediaId, e.log_extra = '{"rit":3,"item_id":0,"convert_id":0}', 
client.isIOS && e.download_url_for_ios ? e.detail = e.download_url_for_ios : client.isAndroid && e.download_url_for_android && (e.detail = e.detail ? "sslocal://webview?url=" + encodeURIComponent(e.detail) : e.download_url_for_android, 
e.download_url = e.download_url_for_android), e.download_url = e.download_url_for_android, 
this.appad = e, this.hasDownloader() && this.subscribe(), this.isInstalled(), t.startListen || (ToutiaoJSBridge.on("app_ad_event", function(e) {
e = e || {};
var a = e.appad || {}, n = a.id;
t.eventList[n](e);
}), t.startListen = !0), this.statisticsData = {
value: Page.statistics.item_id,
extra: {
card_type: e.card_type,
app_name: encodeURIComponent(e.name),
pkg_name: e.pkg_name,
app_id: e.app_id,
app_category: encodeURIComponent(e.game_type),
media_id: Page.author.mediaId,
item_id: Page.statistics.item_id
}
}, this.log("show"), ToutiaoJSBridge.call("subscribe_app_ad", {
data: this.appad
});
}
}, {
key: "componentWillUnmount",
value: function() {
ToutiaoJSBridge.call("unsubscribe_app_ad", {
data: this.appad
}), t.eventList = null;
}
} ]), t;
}(c.Component);
u.defaultProps = {
card_type: 0,
card_id: 0,
type: "game",
logo: "http://p3.pstatp.com/large/22d30005ec3a6f01ff6a",
banner: "http://p3.pstatp.com/large/22d30005ec3a6f01ff6a",
name: "游戏",
game_type: "游戏类型",
size: "0",
desc: "游戏描述",
detail: "",
pkg_name: "",
download_url_for_android: "",
download_url_for_ios: ""
}, u.startListen = !1, u.eventList = {}, t.default = u;
}, function(e, t, a) {
"use strict";
function n(e) {
return e && e.__esModule ? e : {
"default": e
};
}
Object.defineProperty(t, "__esModule", {
value: !0
});
var o = a(9), i = n(o), r = a(10), s = n(r), l = a(12), c = n(l), d = a(14), u = n(d), _ = a(13), p = n(_);
t.default = {
Audio: i.default,
Game: s.default,
Novel: c.default,
Temai: u.default,
PhoneGroup: p.default
};
}, function(e, t, a) {
"use strict";
function n(e) {
return e && e.__esModule ? e : {
"default": e
};
}
function o(e, t) {
if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function");
}
function i(e, t) {
if (!e) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
return !t || "object" != typeof t && "function" != typeof t ? e : t;
}
function r(e, t) {
if ("function" != typeof t && null !== t) throw new TypeError("Super expression must either be null or a function, not " + typeof t);
e.prototype = Object.create(t && t.prototype, {
constructor: {
value: e,
enumerable: !1,
writable: !0,
configurable: !0
}
}), t && (Object.setPrototypeOf ? Object.setPrototypeOf(e, t) : e.__proto__ = t);
}
Object.defineProperty(t, "__esModule", {
value: !0
});
var s = function() {
function e(e, t) {
for (var a = 0; a < t.length; a++) {
var n = t[a];
n.enumerable = n.enumerable || !1, n.configurable = !0, "value" in n && (n.writable = !0), 
Object.defineProperty(e, n.key, n);
}
}
return function(t, a, n) {
return a && e(t.prototype, a), n && e(t, n), t;
};
}(), l = a(0), c = n(l);
a(1);
var d = function(e) {
function t() {
return o(this, t), i(this, (t.__proto__ || Object.getPrototypeOf(t)).apply(this, arguments));
}
return r(t, e), s(t, [ {
key: "render",
value: function() {
var e = this.props, t = e.thumb_url, a = e.book_name, n = e.schema_url, o = e.abstract, i = e.author, r = e.category;
return c.default.createElement("div", {
className: "novel-card"
}, c.default.createElement("a", {
href: n,
target: "_blank",
className: "novel-card-link"
}, c.default.createElement("div", {
className: "novel-card-cover"
}, c.default.createElement("img", {
className: "movie-image",
src: t,
alt: a
})), c.default.createElement("div", {
className: "novel-card-content"
}, c.default.createElement("p", {
className: "novel-card-title"
}, a), c.default.createElement("p", {
className: "novel-card-abstract"
}, o), c.default.createElement("div", {
className: "novel-card-detail"
}, c.default.createElement("span", {
className: "novel-card-detail-item novel-card-author"
}, i), c.default.createElement("span", {
className: "novel-card-detail-item novel-card-category"
}, r), c.default.createElement("i", {
className: "novel-card-icon"
}), c.default.createElement("span", {
className: "novel-card-more"
}, "查看更多")))));
}
} ]), t;
}(l.Component);
t.default = d;
}, function(e, t, a) {
"use strict";
function n(e) {
return e && e.__esModule ? e : {
"default": e
};
}
function o(e, t) {
if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function");
}
function i(e, t) {
if (!e) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
return !t || "object" != typeof t && "function" != typeof t ? e : t;
}
function r(e, t) {
if ("function" != typeof t && null !== t) throw new TypeError("Super expression must either be null or a function, not " + typeof t);
e.prototype = Object.create(t && t.prototype, {
constructor: {
value: e,
enumerable: !1,
writable: !0,
configurable: !0
}
}), t && (Object.setPrototypeOf ? Object.setPrototypeOf(e, t) : e.__proto__ = t);
}
function s(e) {
return e ? e.replace(/&amp;/g, "&") : "";
}
Object.defineProperty(t, "__esModule", {
value: !0
});
var l = function() {
function e(e, t) {
for (var a = 0; a < t.length; a++) {
var n = t[a];
n.enumerable = n.enumerable || !1, n.configurable = !0, "value" in n && (n.writable = !0), 
Object.defineProperty(e, n.key, n);
}
}
return function(t, a, n) {
return a && e(t.prototype, a), n && e(t, n), t;
};
}(), c = a(0), d = n(c);
a(1);
var u = a(7), _ = n(u), p = a(4), f = n(p), m = a(20), h = n(m), g = function(e) {
function t(e) {
o(this, t);
var a = i(this, (t.__proto__ || Object.getPrototypeOf(t)).call(this, e));
return a.state = {
phone: null
}, a.setConfirm = function(e) {
a.confirm = e;
}, a.contactDial = function() {
var e = a.props["contact-phone"], t = a.props.ai_type, n = a.props.is_smart, o = a.props.custom_data;
a.log("call", "click", e, {
actualPhone: e,
ai_type: t,
is_smart: n,
custom_data: o
});
}, a.dial = function(e) {
e.preventDefault();
var t = a.props["contact-phone"], n = a.props.ai_type, o = a.props.is_smart, i = a.props.custom_data;
a.getPhone(function(e, r) {
a.log("call", "click", t, {
actualPhone: r,
ai_type: n,
is_smart: o,
custom_data: i
});
}), a.confirm && a.confirm.show();
}, a.smartDial = function(e) {
e.preventDefault();
var t = a.props["contact-phone"], n = a.props.ai_type, o = a.props.is_smart, i = a.props.custom_data;
a.getVirtualPhone(function(e, r) {
a.log("call", "click", t, {
actualPhone: r,
ai_type: n,
is_smart: o,
custom_data: i
}), location.href = "tel:" + r;
});
}, a.log = function(e, t, a, n) {
t = t || "click";
var o = {
value: Page.statistics.item_id,
extra: {
action_type: e,
button_value: a,
action_time: new Date().getTime()
}
};
"call" === e && (o.extra.button_value_show = n.actualPhone, o.extra.ai_type = n.ai_type, 
o.extra.is_smart = n.is_smart, o.extra.custom_data = n.custom_data), send_umeng_event("embeded_button_ad", t, o);
}, a.logWhenShow = function(e, t) {
var n = a.props.ai_type, o = a.props.is_smart, i = a.props.custom_data;
sendUmengWhenTargetShown(e, "embeded_button_ad", "show", $.extend({}, {
value: Page.statistics.item_id,
extra: {
action_type: "show",
button_value: t,
ai_type: n,
is_smart: o,
custom_data: i,
action_time: new Date().getTime()
}
}, !0));
}, a.getVirtualPhone = function(e) {
var t = a.props["contact-phone"], n = a.props.custom_data, o = a.props.call_back_url, i = a.props.ai_type;
ToutiaoJSBridge && ToutiaoJSBridge.call("TTNetwork.commonParams", {}, function(a) {
var r = a.data || a;
r && r.device_id && $.ajax({
url: "http://i.snssdk.com/pgcui/get_smart_phone_dynamic_number/",
data: {
item_id: Page.statistics.item_id,
device_id: r.device_id,
user_uid: Page.author.userId,
ai_type: i,
custom_data: n,
callback_url: o,
phone_number: t
},
success: function(a) {
return "success" === a.message && a.data.virtual_number ? void e(1, a.data.virtual_number) : void e(0, t);
},
error: function() {
e(0, t);
}
});
});
}, a.getPhone = function(e) {
var t = a, n = a.props, o = n.hid, i = n.city, r = a.props["contact-phone"];
if (r) {
var s = r.split(",");
if (s.length <= 1) return void a.setState({
phone: r
});
var l = s[0], c = s[1], d = {
hid: o,
fzz: l,
ext: c,
city: i,
cstr: h.default("" + i + o + "callcenter")
}, u = [];
for (var _ in d) u.push(_ + "=" + d[_]);
var p = u.join("&");
f.default("http://m.leju.com/?site=api&ctl=callcenter&act=calling&" + p).then(function(e) {
return e.status >= 400 && ToutiaoJSBridge.call("toast", {
text: "电话拨打失败",
icon_type: "icon_error"
}), e.json();
}).then(function(e) {
return 1 == e.status ? e.info.fzz : null;
}).then(function(t) {
e(1, t), a.setState({
phone: t
});
}).catch(function() {
e(0, t.props["contact-phone"]);
});
}
}, a.cancelPhone = function() {
var e = a.state.phone, t = {
fzz: e,
cstr: h.default(e + "callcenter")
}, n = [];
for (var o in t) n.push(o + "=" + t[o]);
var i = n.join("&");
f.default("http://m.leju.com/?site=api&ctl=callcenter&act=cancel&" + i).then(function(e) {
return e.json();
}).then(function(e) {
return 1 == e.status && this.setState({
phone: null
}), null;
});
}, a;
}
return r(t, e), l(t, [ {
key: "render",
value: function() {
var e = this, t = this.props["contact-phone"], a = this.props["contact-name"], n = this.props["book-url"], o = this.props["book-name"], i = this.props.city, r = this.props.hid, l = (this.props.house_type, 
this.props.agent_phone, this.props.is_smart), c = (this.props.ai_type, this.props.context), u = this.state.phone, p = 0, f = 0, m = 0;
return a && t && (p++, f = 1), n && o && (p++, m = 1), "pc" == c.platform ? null : 2 == l || i && r ? /iPhone|XiaoMi/.test(window.navigator.userAgent) || /MI/.test(window.navigator.userAgent.split("/")[1]) ? d.default.createElement("div", {
className: "cpg-container",
"button-count": p
}, f ? d.default.createElement("a", {
ref: function(t) {
return e.phoneRef = t;
},
className: "cpg-button cpg-call",
onClick: this.contactDial,
href: "tel:" + t
}, a) : null, m ? d.default.createElement("a", {
className: "cpg-button cpg-link",
onClick: function() {
return e.log("url", "click", n);
},
href: "sslocal://webview?url=" + encodeURIComponent(s(n))
}, o) : null) : d.default.createElement("div", {
className: "cpg-container",
"button-count": p
}, f ? d.default.createElement("a", {
ref: function(t) {
return e.phoneRef = t;
},
className: "cpg-button cpg-call",
onClick: this.dial,
href: "tel:" + t
}, a) : null, m ? d.default.createElement("a", {
className: "cpg-button cpg-link",
onClick: function() {
return e.log("url", "click", n);
},
href: "sslocal://webview?url=" + encodeURIComponent(s(n))
}, o) : null, u ? d.default.createElement(_.default, {
phone: u,
onCancel: this.cancelPhone,
city: i,
hid: r,
ref: this.setConfirm
}) : null) : 1 == l ? d.default.createElement("div", {
className: "cpg-container",
"button-count": p
}, f ? d.default.createElement("a", {
ref: function(t) {
return e.phoneRef = t;
},
className: "cpg-button cpg-call",
onClick: this.smartDial,
href: "tel:" + t
}, a) : null, m ? d.default.createElement("a", {
ref: function(t) {
return e.urlRef = t;
},
className: "cpg-button cpg-link",
onClick: function() {
return e.log("url", "click", n);
},
href: "sslocal://webview?url=" + encodeURIComponent(s(n))
}, o) : null) : d.default.createElement("div", {
className: "cpg-container",
"button-count": p
}, f ? d.default.createElement("a", {
ref: function(t) {
return e.phoneRef = t;
},
className: "cpg-button cpg-call",
onClick: this.contactDial,
href: "tel:" + t
}, a) : null, m ? d.default.createElement("a", {
ref: function(t) {
return e.urlRef = t;
},
className: "cpg-button cpg-link",
onClick: function() {
return e.log("url", "click", n);
},
href: "sslocal://webview?url=" + encodeURIComponent(s(n))
}, o) : null);
}
}, {
key: "componentDidMount",
value: function() {
var e = this.props["contact-phone"];
this.phoneRef && this.logWhenShow(this.phoneRef, e);
}
}, {
key: "componentWillUnmount",
value: function() {
this.state.phone && this.cancelPhone();
}
} ]), t;
}(c.Component);
t.default = g;
}, function(e, t, a) {
"use strict";
function n(e) {
return e && e.__esModule ? e : {
"default": e
};
}
function o(e, t) {
if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function");
}
function i(e, t) {
if (!e) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
return !t || "object" != typeof t && "function" != typeof t ? e : t;
}
function r(e, t) {
if ("function" != typeof t && null !== t) throw new TypeError("Super expression must either be null or a function, not " + typeof t);
e.prototype = Object.create(t && t.prototype, {
constructor: {
value: e,
enumerable: !1,
writable: !0,
configurable: !0
}
}), t && (Object.setPrototypeOf ? Object.setPrototypeOf(e, t) : e.__proto__ = t);
}
Object.defineProperty(t, "__esModule", {
value: !0
});
var s = function() {
function e(e, t) {
for (var a = 0; a < t.length; a++) {
var n = t[a];
n.enumerable = n.enumerable || !1, n.configurable = !0, "value" in n && (n.writable = !0), 
Object.defineProperty(e, n.key, n);
}
}
return function(t, a, n) {
return a && e(t.prototype, a), n && e(t, n), t;
};
}(), l = a(0), c = n(l);
a(1);
var d = function(e) {
function t() {
return o(this, t), i(this, (t.__proto__ || Object.getPrototypeOf(t)).apply(this, arguments));
}
return r(t, e), s(t, [ {
key: "render",
value: function() {
var e = this.props, t = e.charge_url, a = (e.commodity_id, e.img_url), n = e.price, o = (e.slave_commodity_id, 
e.source), i = e.title;
return c.default.createElement("div", {
className: "pgc-commodity"
}, c.default.createElement("a", {
className: "pgc-commodity-link",
href: t
}, c.default.createElement("div", {
className: "pgc-commodity-box"
}, c.default.createElement("div", {
className: "pgc-commodity-img-box"
}, c.default.createElement("div", {
className: "pgc-commodity-img-square"
}, c.default.createElement("img", {
src: a,
alt: "特卖"
}))), c.default.createElement("div", {
className: "pgc-commodity-info"
}, c.default.createElement("h3", {
className: "pgc-commodity-title"
}, i), c.default.createElement("div", {
className: "pgc-commodity-bar"
}, c.default.createElement("span", {
className: "pgc-commodity-price"
}, "￥", n), c.default.createElement("span", {
className: "pgc-commodity-from"
}, o), c.default.createElement("span", {
className: "pgc-commodity-buy"
}, "购买"))))));
}
} ]), t;
}(l.Component);
t.default = d;
}, function(e, t, a) {
"use strict";
function n(e) {
return e && e.__esModule ? e : {
"default": e
};
}
function o(e, t) {
if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function");
}
Object.defineProperty(t, "__esModule", {
value: !0
});
var i = Object.assign || function(e) {
for (var t = 1; t < arguments.length; t++) {
var a = arguments[t];
for (var n in a) Object.prototype.hasOwnProperty.call(a, n) && (e[n] = a[n]);
}
return e;
}, r = function() {
function e(e, t) {
for (var a = 0; a < t.length; a++) {
var n = t[a];
n.enumerable = n.enumerable || !1, n.configurable = !0, "value" in n && (n.writable = !0), 
Object.defineProperty(e, n.key, n);
}
}
return function(t, a, n) {
return a && e(t.prototype, a), n && e(t, n), t;
};
}(), s = a(0), l = n(s), c = a(0), d = n(c), u = a(2), _ = n(u), p = a(11), f = n(p), m = {}, h = function() {
function e() {
o(this, e), this.init({
match: /^(tt-|pre)/i,
selector: ".novel-card, .pgc-commodit, pre[lang]",
context: {
platform: "client"
}
});
}
return r(e, null, [ {
key: "getInstance",
value: function() {
return e.instance || (e.instance = new e()), e.instance;
}
} ]), r(e, [ {
key: "init",
value: function(e) {
return this.config = i({}, this.config, e), this;
}
}, {
key: "registerCard",
value: function(e) {
return m[e.tag] = e.component, this;
}
}, {
key: "getComponentByTag",
value: function(e) {
return e = e.toLowerCase(), m[e];
}
}, {
key: "isCard",
value: function(e) {
return void 0 !== m[e];
}
}, {
key: "checkCardTag",
value: function(e) {
if (e && e.nodeName) {
var t = this.config.match;
return t.test(e.nodeName);
}
return !1;
}
}, {
key: "resolveTagToComponent",
value: function(e) {
if (e) {
var t = e.toLowerCase().split("-");
t.length > 1 && t.shift();
for (var a = "", n = 0, o = t.length; o > n; n++) a += _.default.firstUpper(t[n]);
return a;
}
}
}, {
key: "render",
value: function(e) {
var t = this, n = void 0;
_.default.map(e, function(e) {
if (t.checkCardTag(e)) {
var o = _.default.buildAttrs(e), r = i({}, t.config, o);
if (t.getComponentByTag(e.nodeName)) n = d.default.createElement(t.getComponentByTag(e.nodeName), r), 
l.default.render(n, e); else {
var s = t.resolveTagToComponent(e.nodeName);
a.e(0).then(a.bind(null, 30)).then(function(t) {
var a = t.default;
"pre" == e.nodeName.toLowerCase() && (s = "Code"), n = d.default.createElement(a[s], r, e.textContent), 
l.default.render(n, e);
});
}
}
});
}
}, {
key: "componentWillUnmount",
value: function() {
this.config = null;
}
} ]), e;
}(), g = h.getInstance();
g.registerCard({
tag: "tt-audio",
component: f.default.Audio
}), g.registerCard({
tag: "tt-game",
component: f.default.Game
}), g.registerCard({
tag: "tt-novel",
component: f.default.Novel
}), g.registerCard({
tag: "tt-temai",
component: f.default.Temai
}), g.registerCard({
tag: "tt-phone-group",
component: f.default.PhoneGroup
}), t.default = g;
}, function(e) {
!function() {
var t = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", a = {
rotl: function(e, t) {
return e << t | e >>> 32 - t;
},
rotr: function(e, t) {
return e << 32 - t | e >>> t;
},
endian: function(e) {
if (e.constructor == Number) return 16711935 & a.rotl(e, 8) | 4278255360 & a.rotl(e, 24);
for (var t = 0; t < e.length; t++) e[t] = a.endian(e[t]);
return e;
},
randomBytes: function(e) {
for (var t = []; e > 0; e--) t.push(Math.floor(256 * Math.random()));
return t;
},
bytesToWords: function(e) {
for (var t = [], a = 0, n = 0; a < e.length; a++, n += 8) t[n >>> 5] |= e[a] << 24 - n % 32;
return t;
},
wordsToBytes: function(e) {
for (var t = [], a = 0; a < 32 * e.length; a += 8) t.push(e[a >>> 5] >>> 24 - a % 32 & 255);
return t;
},
bytesToHex: function(e) {
for (var t = [], a = 0; a < e.length; a++) t.push((e[a] >>> 4).toString(16)), t.push((15 & e[a]).toString(16));
return t.join("");
},
hexToBytes: function(e) {
for (var t = [], a = 0; a < e.length; a += 2) t.push(parseInt(e.substr(a, 2), 16));
return t;
},
bytesToBase64: function(e) {
for (var a = [], n = 0; n < e.length; n += 3) for (var o = e[n] << 16 | e[n + 1] << 8 | e[n + 2], i = 0; 4 > i; i++) a.push(8 * n + 6 * i <= 8 * e.length ? t.charAt(o >>> 6 * (3 - i) & 63) : "=");
return a.join("");
},
base64ToBytes: function(e) {
e = e.replace(/[^A-Z0-9+\/]/gi, "");
for (var a = [], n = 0, o = 0; n < e.length; o = ++n % 4) 0 != o && a.push((t.indexOf(e.charAt(n - 1)) & Math.pow(2, -2 * o + 8) - 1) << 2 * o | t.indexOf(e.charAt(n)) >>> 6 - 2 * o);
return a;
}
};
e.exports = a;
}();
}, function(e) {
"use strict";
function t(e) {
return function() {
return e;
};
}
var a = function() {};
a.thatReturns = t, a.thatReturnsFalse = t(!1), a.thatReturnsTrue = t(!0), a.thatReturnsNull = t(null), 
a.thatReturnsThis = function() {
return this;
}, a.thatReturnsArgument = function(e) {
return e;
}, e.exports = a;
}, function(e) {
"use strict";
function t(e, t, n, o, i, r, s, l) {
if (a(t), !e) {
var c;
if (void 0 === t) c = new Error("Minified exception occurred; use the non-minified dev environment for the full error message and additional helpful warnings."); else {
var d = [ n, o, i, r, s, l ], u = 0;
c = new Error(t.replace(/%s/g, function() {
return d[u++];
})), c.name = "Invariant Violation";
}
throw c.framesToPop = 1, c;
}
}
var a = function() {};
e.exports = t;
}, function(e) {
function t(e) {
return !!e.constructor && "function" == typeof e.constructor.isBuffer && e.constructor.isBuffer(e);
}
function a(e) {
return "function" == typeof e.readFloatLE && "function" == typeof e.slice && t(e.slice(0, 0));
}
e.exports = function(e) {
return null != e && (t(e) || a(e) || !!e._isBuffer);
};
}, function(e, t, a) {
!function() {
var t = a(16), n = a(3).utf8, o = a(19), i = a(3).bin, r = function(e, a) {
e.constructor == String ? e = a && "binary" === a.encoding ? i.stringToBytes(e) : n.stringToBytes(e) : o(e) ? e = Array.prototype.slice.call(e, 0) : Array.isArray(e) || (e = e.toString());
for (var s = t.bytesToWords(e), l = 8 * e.length, c = 1732584193, d = -271733879, u = -1732584194, _ = 271733878, p = 0; p < s.length; p++) s[p] = 16711935 & (s[p] << 8 | s[p] >>> 24) | 4278255360 & (s[p] << 24 | s[p] >>> 8);
s[l >>> 5] |= 128 << l % 32, s[(l + 64 >>> 9 << 4) + 14] = l;
for (var f = r._ff, m = r._gg, h = r._hh, g = r._ii, p = 0; p < s.length; p += 16) {
var v = c, w = d, y = u, b = _;
c = f(c, d, u, _, s[p + 0], 7, -680876936), _ = f(_, c, d, u, s[p + 1], 12, -389564586), 
u = f(u, _, c, d, s[p + 2], 17, 606105819), d = f(d, u, _, c, s[p + 3], 22, -1044525330), 
c = f(c, d, u, _, s[p + 4], 7, -176418897), _ = f(_, c, d, u, s[p + 5], 12, 1200080426), 
u = f(u, _, c, d, s[p + 6], 17, -1473231341), d = f(d, u, _, c, s[p + 7], 22, -45705983), 
c = f(c, d, u, _, s[p + 8], 7, 1770035416), _ = f(_, c, d, u, s[p + 9], 12, -1958414417), 
u = f(u, _, c, d, s[p + 10], 17, -42063), d = f(d, u, _, c, s[p + 11], 22, -1990404162), 
c = f(c, d, u, _, s[p + 12], 7, 1804603682), _ = f(_, c, d, u, s[p + 13], 12, -40341101), 
u = f(u, _, c, d, s[p + 14], 17, -1502002290), d = f(d, u, _, c, s[p + 15], 22, 1236535329), 
c = m(c, d, u, _, s[p + 1], 5, -165796510), _ = m(_, c, d, u, s[p + 6], 9, -1069501632), 
u = m(u, _, c, d, s[p + 11], 14, 643717713), d = m(d, u, _, c, s[p + 0], 20, -373897302), 
c = m(c, d, u, _, s[p + 5], 5, -701558691), _ = m(_, c, d, u, s[p + 10], 9, 38016083), 
u = m(u, _, c, d, s[p + 15], 14, -660478335), d = m(d, u, _, c, s[p + 4], 20, -405537848), 
c = m(c, d, u, _, s[p + 9], 5, 568446438), _ = m(_, c, d, u, s[p + 14], 9, -1019803690), 
u = m(u, _, c, d, s[p + 3], 14, -187363961), d = m(d, u, _, c, s[p + 8], 20, 1163531501), 
c = m(c, d, u, _, s[p + 13], 5, -1444681467), _ = m(_, c, d, u, s[p + 2], 9, -51403784), 
u = m(u, _, c, d, s[p + 7], 14, 1735328473), d = m(d, u, _, c, s[p + 12], 20, -1926607734), 
c = h(c, d, u, _, s[p + 5], 4, -378558), _ = h(_, c, d, u, s[p + 8], 11, -2022574463), 
u = h(u, _, c, d, s[p + 11], 16, 1839030562), d = h(d, u, _, c, s[p + 14], 23, -35309556), 
c = h(c, d, u, _, s[p + 1], 4, -1530992060), _ = h(_, c, d, u, s[p + 4], 11, 1272893353), 
u = h(u, _, c, d, s[p + 7], 16, -155497632), d = h(d, u, _, c, s[p + 10], 23, -1094730640), 
c = h(c, d, u, _, s[p + 13], 4, 681279174), _ = h(_, c, d, u, s[p + 0], 11, -358537222), 
u = h(u, _, c, d, s[p + 3], 16, -722521979), d = h(d, u, _, c, s[p + 6], 23, 76029189), 
c = h(c, d, u, _, s[p + 9], 4, -640364487), _ = h(_, c, d, u, s[p + 12], 11, -421815835), 
u = h(u, _, c, d, s[p + 15], 16, 530742520), d = h(d, u, _, c, s[p + 2], 23, -995338651), 
c = g(c, d, u, _, s[p + 0], 6, -198630844), _ = g(_, c, d, u, s[p + 7], 10, 1126891415), 
u = g(u, _, c, d, s[p + 14], 15, -1416354905), d = g(d, u, _, c, s[p + 5], 21, -57434055), 
c = g(c, d, u, _, s[p + 12], 6, 1700485571), _ = g(_, c, d, u, s[p + 3], 10, -1894986606), 
u = g(u, _, c, d, s[p + 10], 15, -1051523), d = g(d, u, _, c, s[p + 1], 21, -2054922799), 
c = g(c, d, u, _, s[p + 8], 6, 1873313359), _ = g(_, c, d, u, s[p + 15], 10, -30611744), 
u = g(u, _, c, d, s[p + 6], 15, -1560198380), d = g(d, u, _, c, s[p + 13], 21, 1309151649), 
c = g(c, d, u, _, s[p + 4], 6, -145523070), _ = g(_, c, d, u, s[p + 11], 10, -1120210379), 
u = g(u, _, c, d, s[p + 2], 15, 718787259), d = g(d, u, _, c, s[p + 9], 21, -343485551), 
c = c + v >>> 0, d = d + w >>> 0, u = u + y >>> 0, _ = _ + b >>> 0;
}
return t.endian([ c, d, u, _ ]);
};
r._ff = function(e, t, a, n, o, i, r) {
var s = e + (t & a | ~t & n) + (o >>> 0) + r;
return (s << i | s >>> 32 - i) + t;
}, r._gg = function(e, t, a, n, o, i, r) {
var s = e + (t & n | a & ~n) + (o >>> 0) + r;
return (s << i | s >>> 32 - i) + t;
}, r._hh = function(e, t, a, n, o, i, r) {
var s = e + (t ^ a ^ n) + (o >>> 0) + r;
return (s << i | s >>> 32 - i) + t;
}, r._ii = function(e, t, a, n, o, i, r) {
var s = e + (a ^ (t | ~n)) + (o >>> 0) + r;
return (s << i | s >>> 32 - i) + t;
}, r._blocksize = 16, r._digestsize = 16, e.exports = function(e, a) {
if (void 0 === e || null === e) throw new Error("Illegal argument " + e);
var n = t.wordsToBytes(r(e, a));
return a && a.asBytes ? n : a && a.asString ? i.bytesToString(n) : t.bytesToHex(n);
};
}();
}, function(e, t, a) {
"use strict";
function n() {}
function o(e, t) {
var a, o, i, r, s = B;
for (r = arguments.length; r-- > 2; ) O.push(arguments[r]);
for (t && null != t.children && (O.length || O.push(t.children), delete t.children); O.length; ) if ((o = O.pop()) && void 0 !== o.pop) for (r = o.length; r--; ) O.push(o[r]); else "boolean" == typeof o && (o = null), 
(i = "function" != typeof e) && (null == o ? o = "" : "number" == typeof o ? o = String(o) : "string" != typeof o && (i = !1)), 
i && a ? s[s.length - 1] += o : s === B ? s = [ o ] : s.push(o), a = i;
var l = new n();
return l.nodeName = e, l.children = s, l.attributes = null == t ? void 0 : t, l.key = null == t ? void 0 : t.key, 
void 0 !== $.vnode && $.vnode(l), l;
}
function i(e, t) {
for (var a in t) e[a] = t[a];
return e;
}
function r(e, t) {
return o(e.nodeName, i(i({}, e.attributes), t), arguments.length > 2 ? [].slice.call(arguments, 2) : e.children);
}
function s(e) {
!e._dirty && (e._dirty = !0) && 1 == D.push(e) && ($.debounceRendering || L)(l);
}
function l() {
var e, t = D;
for (D = []; e = t.pop(); ) e._dirty && I(e);
}
function c(e, t, a) {
return "string" == typeof t || "number" == typeof t ? void 0 !== e.splitText : "string" == typeof t.nodeName ? !e._componentConstructor && d(e, t.nodeName) : a || e._componentConstructor === t.nodeName;
}
function d(e, t) {
return e.normalizedNodeName === t || e.nodeName.toLowerCase() === t.toLowerCase();
}
function u(e) {
var t = i({}, e.attributes);
t.children = e.children;
var a = e.nodeName.defaultProps;
if (void 0 !== a) for (var n in a) void 0 === t[n] && (t[n] = a[n]);
return t;
}
function _(e, t) {
var a = t ? document.createElementNS("http://www.w3.org/2000/svg", e) : document.createElement(e);
return a.normalizedNodeName = e, a;
}
function p(e) {
var t = e.parentNode;
t && t.removeChild(e);
}
function f(e, t, a, n, o) {
if ("className" === t && (t = "class"), "key" === t) ; else if ("ref" === t) a && a(null), 
n && n(e); else if ("class" !== t || o) if ("style" === t) {
if (n && "string" != typeof n && "string" != typeof a || (e.style.cssText = n || ""), 
n && "object" == typeof n) {
if ("string" != typeof a) for (var i in a) i in n || (e.style[i] = "");
for (var i in n) e.style[i] = "number" == typeof n[i] && R.test(i) === !1 ? n[i] + "px" : n[i];
}
} else if ("dangerouslySetInnerHTML" === t) n && (e.innerHTML = n.__html || ""); else if ("o" == t[0] && "n" == t[1]) {
var r = t !== (t = t.replace(/Capture$/, ""));
t = t.toLowerCase().substring(2), n ? a || e.addEventListener(t, h, r) : e.removeEventListener(t, h, r), 
(e._listeners || (e._listeners = {}))[t] = n;
} else if ("list" !== t && "type" !== t && !o && t in e) m(e, t, null == n ? "" : n), 
(null == n || n === !1) && e.removeAttribute(t); else {
var s = o && t !== (t = t.replace(/^xlink\:?/, ""));
null == n || n === !1 ? s ? e.removeAttributeNS("http://www.w3.org/1999/xlink", t.toLowerCase()) : e.removeAttribute(t) : "function" != typeof n && (s ? e.setAttributeNS("http://www.w3.org/1999/xlink", t.toLowerCase(), n) : e.setAttribute(t, n));
} else e.className = n || "";
}
function m(e, t, a) {
try {
e[t] = a;
} catch (n) {}
}
function h(e) {
return this._listeners[e.type]($.event && $.event(e) || e);
}
function g() {
for (var e; e = U.pop(); ) $.afterMount && $.afterMount(e), e.componentDidMount && e.componentDidMount();
}
function v(e, t, a, n, o, i) {
V++ || (M = null != o && void 0 !== o.ownerSVGElement, F = null != e && !("__preactattr_" in e));
var r = w(e, t, a, n, i);
return o && r.parentNode !== o && o.appendChild(r), --V || (F = !1, i || g()), r;
}
function w(e, t, a, n, o) {
var i = e, r = M;
if ((null == t || "boolean" == typeof t) && (t = ""), "string" == typeof t || "number" == typeof t) return e && void 0 !== e.splitText && e.parentNode && (!e._component || o) ? e.nodeValue != t && (e.nodeValue = t) : (i = document.createTextNode(t), 
e && (e.parentNode && e.parentNode.replaceChild(i, e), b(e, !0))), i.__preactattr_ = !0, 
i;
var s = t.nodeName;
if ("function" == typeof s) return N(e, t, a, n);
if (M = "svg" === s ? !0 : "foreignObject" === s ? !1 : M, s = String(s), (!e || !d(e, s)) && (i = _(s, M), 
e)) {
for (;e.firstChild; ) i.appendChild(e.firstChild);
e.parentNode && e.parentNode.replaceChild(i, e), b(e, !0);
}
var l = i.firstChild, c = i.__preactattr_, u = t.children;
if (null == c) {
c = i.__preactattr_ = {};
for (var p = i.attributes, f = p.length; f--; ) c[p[f].name] = p[f].value;
}
return !F && u && 1 === u.length && "string" == typeof u[0] && null != l && void 0 !== l.splitText && null == l.nextSibling ? l.nodeValue != u[0] && (l.nodeValue = u[0]) : (u && u.length || null != l) && y(i, u, a, n, F || null != c.dangerouslySetInnerHTML), 
k(i, t.attributes, c), M = r, i;
}
function y(e, t, a, n, o) {
var i, r, s, l, d, u = e.childNodes, _ = [], f = {}, m = 0, h = 0, g = u.length, v = 0, y = t ? t.length : 0;
if (0 !== g) for (var x = 0; g > x; x++) {
var k = u[x], P = k.__preactattr_, S = y && P ? k._component ? k._component.__key : P.key : null;
null != S ? (m++, f[S] = k) : (P || (void 0 !== k.splitText ? o ? k.nodeValue.trim() : !0 : o)) && (_[v++] = k);
}
if (0 !== y) for (var x = 0; y > x; x++) {
l = t[x], d = null;
var S = l.key;
if (null != S) m && void 0 !== f[S] && (d = f[S], f[S] = void 0, m--); else if (!d && v > h) for (i = h; v > i; i++) if (void 0 !== _[i] && c(r = _[i], l, o)) {
d = r, _[i] = void 0, i === v - 1 && v--, i === h && h++;
break;
}
d = w(d, l, a, n), s = u[x], d && d !== e && d !== s && (null == s ? e.appendChild(d) : d === s.nextSibling ? p(s) : e.insertBefore(d, s));
}
if (m) for (var x in f) void 0 !== f[x] && b(f[x], !1);
for (;v >= h; ) void 0 !== (d = _[v--]) && b(d, !1);
}
function b(e, t) {
var a = e._component;
a ? j(a) : (null != e.__preactattr_ && e.__preactattr_.ref && e.__preactattr_.ref(null), 
(t === !1 || null == e.__preactattr_) && p(e), x(e));
}
function x(e) {
for (e = e.lastChild; e; ) {
var t = e.previousSibling;
b(e, !0), e = t;
}
}
function k(e, t, a) {
var n;
for (n in a) t && null != t[n] || null == a[n] || f(e, n, a[n], a[n] = void 0, M);
for (n in t) "children" === n || "innerHTML" === n || n in a && t[n] === ("value" === n || "checked" === n ? e[n] : a[n]) || f(e, n, a[n], a[n] = t[n], M);
}
function P(e) {
var t = e.constructor.name;
(q[t] || (q[t] = [])).push(e);
}
function S(e, t, a) {
var n, o = q[e.name];
if (e.prototype && e.prototype.render ? (n = new e(t, a), E.call(n, t, a)) : (n = new E(t, a), 
n.constructor = e, n.render = T), o) for (var i = o.length; i--; ) if (o[i].constructor === e) {
n.nextBase = o[i].nextBase, o.splice(i, 1);
break;
}
return n;
}
function T(e, t, a) {
return this.constructor(e, a);
}
function C(e, t, a, n, o) {
e._disable || (e._disable = !0, (e.__ref = t.ref) && delete t.ref, (e.__key = t.key) && delete t.key, 
!e.base || o ? e.componentWillMount && e.componentWillMount() : e.componentWillReceiveProps && e.componentWillReceiveProps(t, n), 
n && n !== e.context && (e.prevContext || (e.prevContext = e.context), e.context = n), 
e.prevProps || (e.prevProps = e.props), e.props = t, e._disable = !1, 0 !== a && (1 !== a && $.syncComponentUpdates === !1 && e.base ? s(e) : I(e, 1, o)), 
e.__ref && e.__ref(e));
}
function I(e, t, a, n) {
if (!e._disable) {
var o, r, s, l = e.props, c = e.state, d = e.context, _ = e.prevProps || l, p = e.prevState || c, f = e.prevContext || d, m = e.base, h = e.nextBase, w = m || h, y = e._component, x = !1;
if (m && (e.props = _, e.state = p, e.context = f, 2 !== t && e.shouldComponentUpdate && e.shouldComponentUpdate(l, c, d) === !1 ? x = !0 : e.componentWillUpdate && e.componentWillUpdate(l, c, d), 
e.props = l, e.state = c, e.context = d), e.prevProps = e.prevState = e.prevContext = e.nextBase = null, 
e._dirty = !1, !x) {
o = e.render(l, c, d), e.getChildContext && (d = i(i({}, d), e.getChildContext()));
var k, P, T = o && o.nodeName;
if ("function" == typeof T) {
var N = u(o);
r = y, r && r.constructor === T && N.key == r.__key ? C(r, N, 1, d, !1) : (k = r, 
e._component = r = S(T, N, d), r.nextBase = r.nextBase || h, r._parentComponent = e, 
C(r, N, 0, d, !1), I(r, 1, a, !0)), P = r.base;
} else s = w, k = y, k && (s = e._component = null), (w || 1 === t) && (s && (s._component = null), 
P = v(s, o, d, a || !m, w && w.parentNode, !0));
if (w && P !== w && r !== y) {
var E = w.parentNode;
E && P !== E && (E.replaceChild(P, w), k || (w._component = null, b(w, !1)));
}
if (k && j(k), e.base = P, P && !n) {
for (var A = e, O = e; O = O._parentComponent; ) (A = O).base = P;
P._component = A, P._componentConstructor = A.constructor;
}
}
if (!m || a ? U.unshift(e) : x || (e.componentDidUpdate && e.componentDidUpdate(_, p, f), 
$.afterUpdate && $.afterUpdate(e)), null != e._renderCallbacks) for (;e._renderCallbacks.length; ) e._renderCallbacks.pop().call(e);
V || n || g();
}
}
function N(e, t, a, n) {
for (var o = e && e._component, i = o, r = e, s = o && e._componentConstructor === t.nodeName, l = s, c = u(t); o && !l && (o = o._parentComponent); ) l = o.constructor === t.nodeName;
return o && l && (!n || o._component) ? (C(o, c, 3, a, n), e = o.base) : (i && !s && (j(i), 
e = r = null), o = S(t.nodeName, c, a), e && !o.nextBase && (o.nextBase = e, r = null), 
C(o, c, 1, a, n), e = o.base, r && e !== r && (r._component = null, b(r, !1))), 
e;
}
function j(e) {
$.beforeUnmount && $.beforeUnmount(e);
var t = e.base;
e._disable = !0, e.componentWillUnmount && e.componentWillUnmount(), e.base = null;
var a = e._component;
a ? j(a) : t && (t.__preactattr_ && t.__preactattr_.ref && t.__preactattr_.ref(null), 
e.nextBase = t, p(t), P(e), x(t)), e.__ref && e.__ref(null);
}
function E(e, t) {
this._dirty = !0, this.context = t, this.props = e, this.state = this.state || {};
}
function A(e, t, a) {
return v(a, e, {}, !1, t, !1);
}
a.d(t, "a", function() {
return o;
}), a.d(t, "d", function() {
return r;
}), a.d(t, "e", function() {
return E;
}), a.d(t, "c", function() {
return A;
}), a.d(t, "b", function() {
return $;
});
var $ = {}, O = [], B = [], L = "function" == typeof Promise ? Promise.resolve().then.bind(Promise.resolve()) : setTimeout, R = /acit|ex(?:s|g|n|p|$)|rph|ows|mnc|ntw|ine[ch]|zoo|^ord/i, D = [], U = [], V = 0, M = !1, F = !1, q = {};
i(E.prototype, {
setState: function(e, t) {
var a = this.state;
this.prevState || (this.prevState = i({}, a)), i(a, "function" == typeof e ? e(a, this.props) : e), 
t && (this._renderCallbacks = this._renderCallbacks || []).push(t), s(this);
},
forceUpdate: function(e) {
e && (this._renderCallbacks = this._renderCallbacks || []).push(e), I(this, 2);
},
render: function() {}
});
}, function(e, t, a) {
(function(t) {
!function(a) {
function n() {}
function o(e, t) {
return function() {
e.apply(t, arguments);
};
}
function i(e) {
if (!(this instanceof i)) throw new TypeError("Promises must be constructed via new");
if ("function" != typeof e) throw new TypeError("not a function");
this._state = 0, this._handled = !1, this._value = void 0, this._deferreds = [], 
u(e, this);
}
function r(e, t) {
for (;3 === e._state; ) e = e._value;
return 0 === e._state ? void e._deferreds.push(t) : (e._handled = !0, void i._immediateFn(function() {
var a = 1 === e._state ? t.onFulfilled : t.onRejected;
if (null === a) return void (1 === e._state ? s : l)(t.promise, e._value);
var n;
try {
n = a(e._value);
} catch (o) {
return void l(t.promise, o);
}
s(t.promise, n);
}));
}
function s(e, t) {
try {
if (t === e) throw new TypeError("A promise cannot be resolved with itself.");
if (t && ("object" == typeof t || "function" == typeof t)) {
var a = t.then;
if (t instanceof i) return e._state = 3, e._value = t, void c(e);
if ("function" == typeof a) return void u(o(a, t), e);
}
e._state = 1, e._value = t, c(e);
} catch (n) {
l(e, n);
}
}
function l(e, t) {
e._state = 2, e._value = t, c(e);
}
function c(e) {
2 === e._state && 0 === e._deferreds.length && i._immediateFn(function() {
e._handled || i._unhandledRejectionFn(e._value);
});
for (var t = 0, a = e._deferreds.length; a > t; t++) r(e, e._deferreds[t]);
e._deferreds = null;
}
function d(e, t, a) {
this.onFulfilled = "function" == typeof e ? e : null, this.onRejected = "function" == typeof t ? t : null, 
this.promise = a;
}
function u(e, t) {
var a = !1;
try {
e(function(e) {
a || (a = !0, s(t, e));
}, function(e) {
a || (a = !0, l(t, e));
});
} catch (n) {
if (a) return;
a = !0, l(t, n);
}
}
var _ = setTimeout;
i.prototype["catch"] = function(e) {
return this.then(null, e);
}, i.prototype.then = function(e, t) {
var a = new this.constructor(n);
return r(this, new d(e, t, a)), a;
}, i.all = function(e) {
return new i(function(t, a) {
function n(e, r) {
try {
if (r && ("object" == typeof r || "function" == typeof r)) {
var s = r.then;
if ("function" == typeof s) return void s.call(r, function(t) {
n(e, t);
}, a);
}
o[e] = r, 0 === --i && t(o);
} catch (l) {
a(l);
}
}
if (!e || "undefined" == typeof e.length) throw new TypeError("Promise.all accepts an array");
var o = Array.prototype.slice.call(e);
if (0 === o.length) return t([]);
for (var i = o.length, r = 0; r < o.length; r++) n(r, o[r]);
});
}, i.resolve = function(e) {
return e && "object" == typeof e && e.constructor === i ? e : new i(function(t) {
t(e);
});
}, i.reject = function(e) {
return new i(function(t, a) {
a(e);
});
}, i.race = function(e) {
return new i(function(t, a) {
for (var n = 0, o = e.length; o > n; n++) e[n].then(t, a);
});
}, i._immediateFn = "function" == typeof t && function(e) {
t(e);
} || function(e) {
_(e, 0);
}, i._unhandledRejectionFn = function(e) {
"undefined" != typeof console && console && console.warn("Possible Unhandled Promise Rejection:", e);
}, i._setImmediateFn = function(e) {
i._immediateFn = e;
}, i._setUnhandledRejectionFn = function(e) {
i._unhandledRejectionFn = e;
}, "undefined" != typeof e && e.exports ? e.exports = i : a.Promise || (a.Promise = i);
}(this);
}).call(t, a(27).setImmediate);
}, function(e, t, a) {
"use strict";
var n = a(17), o = a(18), i = a(25);
e.exports = function() {
function e(e, t, a, n, r, s) {
s !== i && o(!1, "Calling PropTypes validators directly is not supported by the `prop-types` package. Use PropTypes.checkPropTypes() to call them. Read more at http://fb.me/use-check-prop-types");
}
function t() {
return e;
}
e.isRequired = e;
var a = {
array: e,
bool: e,
func: e,
number: e,
object: e,
string: e,
symbol: e,
any: e,
arrayOf: t,
element: e,
instanceOf: t,
node: e,
objectOf: t,
oneOf: t,
oneOfType: t,
shape: t,
exact: t
};
return a.checkPropTypes = n, a.PropTypes = a, a;
};
}, function(e, t, a) {
e.exports = a(23)();
}, function(e) {
"use strict";
var t = "SECRET_DO_NOT_PASS_THIS_OR_YOU_WILL_BE_FIRED";
e.exports = t;
}, function(e, t, a) {
(function(e, t) {
!function(e, a) {
"use strict";
function n(e) {
"function" != typeof e && (e = new Function("" + e));
for (var t = new Array(arguments.length - 1), a = 0; a < t.length; a++) t[a] = arguments[a + 1];
var n = {
callback: e,
args: t
};
return m[f] = n, p(f), f++;
}
function o(e) {
delete m[e];
}
function i(e) {
var t = e.callback, n = e.args;
switch (n.length) {
case 0:
t();
break;

case 1:
t(n[0]);
break;

case 2:
t(n[0], n[1]);
break;

case 3:
t(n[0], n[1], n[2]);
break;

default:
t.apply(a, n);
}
}
function r(e) {
if (h) setTimeout(r, 0, e); else {
var t = m[e];
if (t) {
h = !0;
try {
i(t);
} finally {
o(e), h = !1;
}
}
}
}
function s() {
p = function(e) {
t.nextTick(function() {
r(e);
});
};
}
function l() {
if (e.postMessage && !e.importScripts) {
var t = !0, a = e.onmessage;
return e.onmessage = function() {
t = !1;
}, e.postMessage("", "*"), e.onmessage = a, t;
}
}
function c() {
var t = "setImmediate$" + Math.random() + "$", a = function(a) {
a.source === e && "string" == typeof a.data && 0 === a.data.indexOf(t) && r(+a.data.slice(t.length));
};
e.addEventListener ? e.addEventListener("message", a, !1) : e.attachEvent("onmessage", a), 
p = function(a) {
e.postMessage(t + a, "*");
};
}
function d() {
var e = new MessageChannel();
e.port1.onmessage = function(e) {
var t = e.data;
r(t);
}, p = function(t) {
e.port2.postMessage(t);
};
}
function u() {
var e = g.documentElement;
p = function(t) {
var a = g.createElement("script");
a.onreadystatechange = function() {
r(t), a.onreadystatechange = null, e.removeChild(a), a = null;
}, e.appendChild(a);
};
}
function _() {
p = function(e) {
setTimeout(r, 0, e);
};
}
if (!e.setImmediate) {
var p, f = 1, m = {}, h = !1, g = e.document, v = Object.getPrototypeOf && Object.getPrototypeOf(e);
v = v && v.setTimeout ? v : e, "[object process]" === {}.toString.call(e.process) ? s() : l() ? c() : e.MessageChannel ? d() : g && "onreadystatechange" in g.createElement("script") ? u() : _(), 
v.setImmediate = n, v.clearImmediate = o;
}
}("undefined" == typeof self ? "undefined" == typeof e ? this : e : self);
}).call(t, a(28), a(5));
}, function(e, t, a) {
function n(e, t) {
this._id = e, this._clearFn = t;
}
var o = Function.prototype.apply;
t.setTimeout = function() {
return new n(o.call(setTimeout, window, arguments), clearTimeout);
}, t.setInterval = function() {
return new n(o.call(setInterval, window, arguments), clearInterval);
}, t.clearTimeout = t.clearInterval = function(e) {
e && e.close();
}, n.prototype.unref = n.prototype.ref = function() {}, n.prototype.close = function() {
this._clearFn.call(window, this._id);
}, t.enroll = function(e, t) {
clearTimeout(e._idleTimeoutId), e._idleTimeout = t;
}, t.unenroll = function(e) {
clearTimeout(e._idleTimeoutId), e._idleTimeout = -1;
}, t._unrefActive = t.active = function(e) {
clearTimeout(e._idleTimeoutId);
var t = e._idleTimeout;
t >= 0 && (e._idleTimeoutId = setTimeout(function() {
e._onTimeout && e._onTimeout();
}, t));
}, a(26), t.setImmediate = setImmediate, t.clearImmediate = clearImmediate;
}, function(e) {
var t;
t = function() {
return this;
}();
try {
t = t || Function("return this")() || (1, eval)("this");
} catch (a) {
"object" == typeof window && (t = window);
}
e.exports = t;
}, function(e, t, a) {
e.exports = a(6);
} ]);

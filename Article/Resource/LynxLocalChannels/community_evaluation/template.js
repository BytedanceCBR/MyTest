ť.   asm0.2.0.01.4.121.01.0card  .content_right_row_description18px#99999912pxcontent_right_row_description.content_right_row_title22px600#33333316pxcontent_right_row_title.content_right_row_icon020pxcontent_right_row_icon.readnowrapellipsis#f5f5f5lefthidden2px1fit-contentread.description_icon10px4px5pxdescription_icon.description#ffffff500description.card_titleauto100%
card_title.content_leftcolumn50%content_left	.top_icon68pxtop_icon.background_imageabsolutebackground_image.content_right_rowcenterrowcontent_right_row.content_right_row_arrowcontent_right_row_arrow.content_rightcontent_right
.read_icon	read_icon.cardflexcard'/entry-community_evaluation-684f82bf.jsŹ+;tt.define("entry-community_evaluation-684f82bf.js", function(require, module, exports, Card,setTimeout,setInterval,clearInterval,clearTimeout,NativeModules,tt,console,Component,TaroLynx,nativeAppId,Behavior,LynxJSBI,lynx,window,document,frames,self,location,navigator,localStorage,history,Caches,screen,alert,confirm,prompt,fetch,XMLHttpRequest,WebSocket,webkit,Reporter,print,Function,global){
 ; 
  var lynxGlobal = (function(){
    if(typeof globalThis === 'object'){
      return globalThis;
    }else {
      return (0, eval)('this');
    }
  })();
;var Promise = (typeof lynx === "object" ? lynx.Promise : null) || lynxGlobal.Promise;"use strict";function e(n){return(e="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&"function"==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?"symbol":typeof e})(n)}var n="undefined"!=typeof globalThis?globalThis:"undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self?self:{};function o(e,n,o){return e(o={path:n,exports:{},require:function(e,n){return function(){throw new Error("Dynamic requires are not currently supported by @rollup/plugin-commonjs")}(null==n&&o.path)}},o.exports),o.exports}o((function(o,t){!function(r){var i=t&&!t.nodeType&&t,u=o&&!o.nodeType&&o,c="object"==e(n)&&n;c.global!==c&&c.window!==c&&c.self!==c||(r=c);var a,s,f=2147483647,l=36,d=/^xn--/,p=/[^\x20-\x7E]/,h=/[\x2E\u3002\uFF0E\uFF61]/g,m={overflow:"Overflow: input needs wider integers to process","not-basic":"Illegal input >= 0x80 (not a basic code point)","invalid-input":"Invalid input"},y=Math.floor,v=String.fromCharCode;function b(e){throw RangeError(m[e])}function g(e,n){for(var o=e.length,t=[];o--;)t[o]=n(e[o]);return t}function w(e,n){var o=e.split("@"),t="";return o.length>1&&(t=o[0]+"@",e=o[1]),t+g((e=e.replace(h,".")).split("."),n).join(".")}function x(e){for(var n,o,t=[],r=0,i=e.length;r<i;)(n=e.charCodeAt(r++))>=55296&&n<=56319&&r<i?56320==(64512&(o=e.charCodeAt(r++)))?t.push(((1023&n)<<10)+(1023&o)+65536):(t.push(n),r--):t.push(n);return t}function C(e){return g(e,(function(e){var n="";return e>65535&&(n+=v((e-=65536)>>>10&1023|55296),e=56320|1023&e),n+=v(e)})).join("")}function j(e,n){return e+22+75*(e<26)-((0!=n)<<5)}function S(e,n,o){var t=0;for(e=o?y(e/700):e>>1,e+=y(e/n);e>455;t+=l)e=y(e/35);return y(t+36*e/(e+38))}function I(e){var n,o,t,r,i,u,c,a,s,d,p,h=[],m=e.length,v=0,g=128,w=72;for((o=e.lastIndexOf("-"))<0&&(o=0),t=0;t<o;++t)e.charCodeAt(t)>=128&&b("not-basic"),h.push(e.charCodeAt(t));for(r=o>0?o+1:0;r<m;){for(i=v,u=1,c=l;r>=m&&b("invalid-input"),((a=(p=e.charCodeAt(r++))-48<10?p-22:p-65<26?p-65:p-97<26?p-97:l)>=l||a>y((f-v)/u))&&b("overflow"),v+=a*u,!(a<(s=c<=w?1:c>=w+26?26:c-w));c+=l)u>y(f/(d=l-s))&&b("overflow"),u*=d;w=S(v-i,n=h.length+1,0==i),y(v/n)>f-g&&b("overflow"),g+=y(v/n),v%=n,h.splice(v++,0,g)}return C(h)}function R(e){var n,o,t,r,i,u,c,a,s,d,p,h,m,g,w,C=[];for(h=(e=x(e)).length,n=128,o=0,i=72,u=0;u<h;++u)(p=e[u])<128&&C.push(v(p));for(t=r=C.length,r&&C.push("-");t<h;){for(c=f,u=0;u<h;++u)(p=e[u])>=n&&p<c&&(c=p);for(c-n>y((f-o)/(m=t+1))&&b("overflow"),o+=(c-n)*m,n=c,u=0;u<h;++u)if((p=e[u])<n&&++o>f&&b("overflow"),p==n){for(a=o,s=l;!(a<(d=s<=i?1:s>=i+26?26:s-i));s+=l)w=a-d,g=l-d,C.push(v(j(d+w%g,0))),a=y(w/g);C.push(v(j(a,0))),i=S(o,m,t==r),o=0,++t}++o,++n}return C.join("")}if(a={version:"1.3.2",ucs2:{decode:x,encode:C},decode:I,encode:R,toASCII:function(e){return w(e,(function(e){return p.test(e)?"xn--"+R(e):e}))},toUnicode:function(e){return w(e,(function(e){return d.test(e)?I(e.slice(4).toLowerCase()):e}))}},i&&u)if(o.exports==i)u.exports=a;else for(s in a)a.hasOwnProperty(s)&&(i[s]=a[s]);else r.punycode=a}(n)}));function t(e,n){return Object.prototype.hasOwnProperty.call(e,n)}var r=function(e,n,o,r){n=n||"&",o=o||"=";var i={};if("string"!=typeof e||0===e.length)return i;var u=/\+/g;e=e.split(n);var c=1e3;r&&"number"==typeof r.maxKeys&&(c=r.maxKeys);var a=e.length;c>0&&a>c&&(a=c);for(var s=0;s<a;++s){var f,l,d,p,h=e[s].replace(u,"%20"),m=h.indexOf(o);m>=0?(f=h.substr(0,m),l=h.substr(m+1)):(f=h,l=""),d=decodeURIComponent(f),p=decodeURIComponent(l),t(i,d)?Array.isArray(i[d])?i[d].push(p):i[d]=[i[d],p]:i[d]=p}return i},i=function(n){switch(e(n)){case"string":return n;case"boolean":return n?"true":"false";case"number":return isFinite(n)?n:"";default:return""}},u=function(n,o,t,r){return o=o||"&",t=t||"=",null===n&&(n=void 0),"object"===e(n)?Object.keys(n).map((function(e){var r=encodeURIComponent(i(e))+t;return Array.isArray(n[e])?n[e].map((function(e){return r+encodeURIComponent(i(e))})).join(o):r+encodeURIComponent(i(n[e]))})).join(o):r?encodeURIComponent(i(r))+t+encodeURIComponent(i(n)):""};o((function(e,n){n.decode=n.parse=r,n.encode=n.stringify=u}));Card({touchgrade:function(e){NativeModules.FLynxBridge.jumpSchema(this.modifySchema(this.data.score.schema))},touchcontrasts:function(e){NativeModules.FLynxBridge.jumpSchema(this.modifySchema(this.data.compare.schema))},touchlookmore:function(e){NativeModules.FLynxBridge.jumpSchema(this.modifySchema(this.data.article.schema))},modifySchema:function(e){var n=e.indexOf("http"),o=e.substr(n);return o="sslocal://webview?url="+(o=o+"&"+encodeURIComponent(this.encodeSearchParams(this.data.report_params))+"&title="+encodeURIComponent("ĺ°ĺşćľčŻ"))},encodeSearchParams:function(e){var n=[];return Object.keys(e).forEach((function(o){var t=e[o];void 0===t&&(t=""),n.push([o,encodeURIComponent(t)].join("="))})),n.join("&")},data:{}});module.exports={};
});
/app-service.jsŐ(function(){'use strict';var g = (new Function('return this;'))();var inited = false;function __init_card_bundle__(lynxCoreInject){if(inited){return;}inited = true;g.__bundle__holder = undefined;var tt = lynxCoreInject.tt;;globComponentRegistPath = 'index';;tt.require("entry-community_evaluation-684f82bf.js");
};if(g && g.bundleSupportLoadScript){var res = {init: __init_card_bundle__};g.__bundle__holder = res;return res}else{__init_card_bundle__({"tt": tt});};})();/indexcompareschema
sslocal://čŞćéćżćć§çtitleĺ°ĺşĺŻšćŻscorevalue7.6çšçšĺ¨č§Łćĺ°ĺşčŻĺcommon_paramsdisplay_height140display_width332articleicon_url2https://p1.pstatp.com/origin/33a3f00004fbce8e5bfc1log_pbgroup_source2impr_id"202012101109320101980590340691C759group_id6892677982075552263article_typeĺš¸çŚć˛é¨copy_writing
0äşşéčŻťŁsslocal://webview?url=http%3a%2f%2fm.xflapp.com%2ff100%2flandpage%2fmeasure%3fid%3d6587273820271280387&title=%e5%b0%8f%e5%8c%ba%e6%b5%8b%e8%af%84%e5%95%8a%e5%95%8apicture2https://p1.pstatp.com/origin/2f884000bd1211092378elalalalĺ°ĺşćľčŻconsoleassertlogStringlengthsubstrindexOfMathtanroundrandomatanmaxfloorexpasinsqrtacoscosminceilpowabssin$kTemplateAssemblerviewwidth:px;textraw-textwidth:100%;height:&px;flex-direction:row;margin-top:12px;	bindEventtaptouchlookmoreimagesrccontentCgecko://community_evaluation/resource/community_evaluation_more.png2px 0 10px 10pxHgecko://community_evaluation/resource/community_evaluation_more_fire.png7gecko://community_evaluation/resource/content_right.png
touchgrade4gecko://community_evaluation/resource/medal_icon.png5gecko://community_evaluation/resource/arrow-right.pngtouchcontrasts4gecko://community_evaluation/resource/house_icon.png#f1e5d30.6px42px14px$renderPage0$page{"dsl":0,"bundleModuleMode":1}  Š   -/ -0/	
&3
*.,/&1'3'&	*.,0 /	!"0#/	$%"&5'$()&*+,*-.$$/-037152"($30435465'$(768&398:5';<:   =>?@  A      BCD!EFGHCDIJ!KFLMNOPQRSTUVWXYZ[\]ZÁâśŘ˝úëC^_C`abFcFd efghijklmnopqrstuvgwxyz{|} @0 ¤0H 0¤0¨ H a~ <Př?%@@N@)@a/@S,@ ¤@@$@ŕĽ@1 Ľ@2ŔĄ@@!@F@@ Ą@@9@@^@7Ŕ@@3Ŕ@@'Ŕ@
@IŔ@@Ŕ@5Ŕ@@Ŕ@@Ŕ@ @  @Ŕ @.(0H0H0H0¤Ź °¨ ¤H0 H0 H0 H0 ¤H0 ¤¨ H0 ¤H0 H0 H0¨° ´Ź¤¨ H0 ¤H0 ¤H0 ¤H0 ¤¨ŹH 0¤¨ H 0¤¨ H 0¤¨° ´Ź H 0¤¨ H 0¤¨ H 0¤¨ H 0¤¨° ´Ź H 0¤¨ H 0¤¨ H 0¤¨ H 0¤¨Ź H 0¤¨ Ź H 0¤Ą¨ H 0¤¨ H 0¤˘¨ŁŹ H 0¤¨¤Ź H 0¤Ľ¨ŚŹ H 0¤§¨¨Ź H¤0¨ŠŹ¤H¤0¨Ź¤H¤0¨ŞŹ¤H ¨0ŹŤ°¨H¨0Ź°¸ Źź´¨H¨0Ź°¨H¤0¨­Ź¤H¤0¨Ź¤H¤0¨ŹŽ°¤H¤0¨ŻŹ¤H 0¤°¨ H 0¤¨ H 0¤˘¨ŁŹ H 0¤Ľ¨ŚŹ H 0¤ą¨˛Ź H¤0¨łŹ¤H¤0¨Ź¤H¤0¨Ź´°¤H¤0¨ľŹ¤H¤0¨śŹ¤H¤0¨Ź¤H¤0¨ˇŹ¤H ¨0Ź¸°¨H¨0Ź°¸ šź´¨H¨0Ź°¨H0 ş¤H0 ¤H0 ť¤H 0¤ź¨ H 0¤¨ H 0¤¨˝Ź H 0¤¨ H 0¤ž¨ H 0¤¨ H 0¤ż¨ H 0¤¨ŹŔ° H¤0¨ÁŹ¤H¤0¨Ź¤H¤0¨ŹÂ°¤H¤0¨ĂŹ¤H¤0¨ÄŹ¤H¤0¨Ź¤H¤0¨Ź°¤H¤0¨ĽŹĹ°¤H¤0¨ŹĆ°¤H¤0¨§Ź¨°¤H ¨0ŹÇ°¨H¨0Ź°¨H¨0ŹČ°¨H¤Ź0°É´ŹHŹ0°´Ŕ ŹÄ źÄ ĘČ˘Ŕ¸ŹHŹ0°´ŹH¨0ŹË°¨H¨0Ź°¨H¨0ŹĚ°¨H¤Ź0°Í´ŹHŹ0°´ź ŞŔ¸ŹHŹ0°´ŹH¤0¨ÎŹ¤H¤0¨Ź¤H¤0¨ŹĎ°¤H¤0¨ĐŹ¤H 0¤¨ H 0¤¨ H 0¤ż¨ H 0¤¨ŹŃ° H¤0¨ŇŹ¤H¤0¨Ź¤H¤0¨ŹÓ°¤H¤0¨ĂŹ¤H¤0¨ÔŹ¤H¤0¨Ź¤H¤0¨Ź°¤H¤0¨ĽŹĹ°¤H¤0¨ŹĆ°¤H¤0¨§Ź¨°¤H ¨0ŹŐ°¨H¨0Ź°¨H¨0ŹČ°¨H¤Ź0°Ö´ŹHŹ0°´ź ŹŔ¸ŹHŹ0°´ŹH¨0Ź×°¨H¨0Ź°¨H¨0ŹĚ°¨H¤Ź0°Ř´ŹHŹ0°´ź ŞŔ¸ŹHŹ0°´ŹH¤0¨ŮŹ¤H¤0¨Ź¤H¤0¨ŹĎ°¤H¤0¨ĐŹ¤H 0¤Ú¨ H 0¤¨ H 0¤¨ŰŹ H 0¤¨ÜŹ H 0¤¨ÝŹ H 0¤¨ŢŹ H 0¤¨ßŹ H 0¤¨ŕŹ HM FM RHB BHFRM 
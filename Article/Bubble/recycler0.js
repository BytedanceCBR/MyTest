R(   asm0.0.1.0  	.bc_greengreenbc_green.bc_bluebluebc_blue
.bc_yellowyellow	bc_yellow.toutiaobold2pxredwhite16pxtoutiao.card3_contentellipsishidden#12318pxcard3_content.red_tag14pxred_tag.card2_progress10pxcard2_progress.scroll-view-item200px100%scroll-view-item	.blue_tag#66CCFFblue_tag
.crowd-num12px#aaa1px	crowd-num.bc_redbc_red.trendblacktrend.card3_more
card3_more.card3_trend22pxcard3_trend.card2_time3px
card2_time.card2_bottom#dddcenter6pxcard2_bottom.card3_toutiaocard3_toutiao.card2_image045px80pxcard2_image.card2_content1card2_content.card3_imagecard3_image.vertical-line0.5px30pxvertical-line.card2_trend_textcard2_trend_text.card2_trendcolumn5pxcard2_trend.contentcontent/pages/index/index.js!define("pages/index/index.js", function(require, module, exports, window,document,frames,self,location,navigator,localStorage,history,Caches,screen,alert,confirm,prompt,fetch,XMLHttpRequest,WebSocket,webkit,ttJSCore,Reporter,print){
 'use strict';

var app = getApp();
var order = ['red', 'yellow', 'blue', 'green', 'red'];
var age = age;
Page({
  touchstart: function touchstart(event) {
    var _this = this;

    console.log("touchstart", event);
    this.setData({
      touchcount: this.data.touchcount + 1
    }, function () {
      console.log("touchcount:", _this.data.touchcount);
    });
  },
  touchend: function touchend(event) {
    var _this2 = this;

    console.log("touchend", event);
    this.setData({
      touchcount: this.data.touchcount + 1
    }, function () {
      console.log("touchcount:", _this2.data.touchcount);
    });
  },
  tap: function tap(event) {
    console.log("tap", event);
  },
  longpress: function longpress(event) {
    console.log("longpress", event);
  },

  upper: function upper(event) {
    console.log("upper", event);
  },
  lower: function lower(event) {
    console.log("lower", event);
  },
  scroll: function scroll(event) {
    console.log("scroll", event);
  },
  data: {
    touchcount: 1,
    toView: 'red',
    scrollTop: 100,
    testArray: [1, 2, 3],
    age: 99,
    childage: 101,
    testObject: {
      image: "https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1943135834,2154880862&fm=58&bpow=900&bpoh=600"
    },
    testObjectArray: {
      image: ["https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1943135834,2154880862&fm=58&bpow=900&bpoh=600"]
    },
    testArrayObject: [{
      image: "https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1943135834,2154880862&fm=58&bpow=900&bpoh=600"
    }],
    testArrayArray: [["https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1943135834,2154880862&fm=58&bpow=900&bpoh=600"]],
    testObjectObject: {
      image: {
        image: "https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1943135834,2154880862&fm=58&bpow=900&bpoh=600"
      }
    },
    // card1
    crowd: "233ไธ",
    content: "ๆๅฅ็็ธ๏ผ่ฐๆฅ็ป่ฟ้ฉป่ฐๆฅ๏ผ็บฟไธ้ๅฎๅทฒๅจ้ข้ญๅฐโๅฐ็ฆ...",
    // card2
    content2: "่้7%็คพๅบๅฑๅฎถๅป่ไบบ็พค ้ฟๆคๅ",
    image2: "https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1943135834,2154880862&fm=58&bpow=900&bpoh=600",
    time2: "22:35",
    progress: "ๆๅฅ็็ธ๏ผ่ฐๆฅ็ป่ฟๅฅ่ฐๆฅ๏ผ",
    isNew: true,
    isExclusive: true,
    // card3
    news: [{
      content: "ๆๅฅ็็ธ๏ผ่ฐๆฅ็ป่ฟ้ฉป่ฐๆฅ๏ผ็บฟไธ้ๅฎๅทฒๅจ้ข้ญๅฐโๅฐ็ฆ...",
      image: "https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1943135834,2154880862&fm=58&bpow=900&bpoh=600"
    }, {
      content: "ๆๅฅ็็ธ๏ผ่ฐๆฅ็ป่ฟ้ฉป่ฐๆฅ๏ผ็บฟไธ้ๅฎๅทฒๅจ้ข้ญๅฐโๅฐ็ฆ...",
      image: "https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1943135834,2154880862&fm=58&bpow=900&bpoh=600"
    }, {
      content: "ๆๅฅ็็ธ๏ผ่ฐๆฅ็ป่ฟ้ฉป่ฐๆฅ๏ผ็บฟไธ้ๅฎๅทฒๅจ้ข้ญๅฐโๅฐ็ฆ...",
      image: "https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1943135834,2154880862&fm=58&bpow=900&bpoh=600"
    }],

    //card4
    update_time: "22:35",
    hot_news: [{
      content: "ๆๅฅ็็ธ๏ผ่ฐๆฅ็ป่ฟ้ฉป่ฐๆฅ๏ผ็บฟไธ้ๅฎๅทฒๅจ้ข้ญๅฐโๅฐ็ฆ...",
      is_new: false,
      is_exclusive: false
    }, {
      content: "่้7%็คพๅบๅฑๅฎถๅป่ไบบ็พค ้ฟๆคๅ",
      is_new: true,
      is_exclusive: true
    }],
    curIndex: 1
  },
  onLoad: function onLoad() {
    console.log('Welcome to Mini Code');
  },
  onReady: function onReady() {
    this.setData({
      testArray: [3, 4, 5]
    });
  },
  onShow: function onShow() {
    console.log('onShow====>');
  },
  onHide: function onHide() {
    console.log('onHide=======>');
  },
  onUnload: function onUnload() {
    console.log('onUnload======>');
  },
  onPullDownRefresh: function onPullDownRefresh() {
    console.log('onPullDownRefresh======>');
  },
  onReachBottom: function onReachBottom() {
    console.log('onReachBottom===>');
  },
  onShareAppMessage: function onShareAppMessage() {
    console.log('onShareAppMessage===>');
  },
  onPageScroll: function onPageScroll() {
    console.log('onPageScroll===>');
  }
});
});/pages/index/index-service.jsh;globPageRegistPath = 'pages/index/index';globPageRegistering = true;
;require("pages/index/index.js");
/components/test/test.jsวdefine("components/test/test.js", function(require, module, exports, window,document,frames,self,location,navigator,localStorage,history,Caches,screen,alert,confirm,prompt,fetch,XMLHttpRequest,WebSocket,webkit,ttJSCore,Reporter,print){
 'use strict';

Component({
    properties: {
        // ่ฟ้ๅฎไนไบinnerTextๅฑๆง๏ผๅฑๆงๅผๅฏไปฅๅจ็ปไปถไฝฟ็จๆถๆๅฎ
        innerText: {
            type: String,
            value: 'default value'
        },
        selected: Boolean
    },
    data: {
        // ่ฟ้ๆฏไธไบ็ปไปถๅ้จๆฐๆฎ
        someData: {}
    }
});
});/app.jsยdefine("app.js", function(require, module, exports, window,document,frames,self,location,navigator,localStorage,history,Caches,screen,alert,confirm,prompt,fetch,XMLHttpRequest,WebSocket,webkit,ttJSCore,Reporter,print){
 "use strict";

var NetworkingModule = NativeModules.NetworkingModule;

App({
  onLaunch: function onLaunch() {
    // commonModule.publish("sdfsdf");

    var param = {
      url: "https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/js/min_super_fdb28b91.js",
      method: "GET"
    };
    NetworkingModule.request(param, function (msg) {
      console.log("NetworkingModule.request info:", msg);
    });

    // LynxTestModule.callbackTest(function (msg) {
    //   console.log("LynxTestModule.callbackTest info:", msg);
    // });
  },
  onShow: function onShow() {
    console.log('onShow==========>');
  },
  onHide: function onHide() {
    console.log('onHide==========>');
  },
  onError: function onError() {
    console.log('onError==========>');
  },
  onPageNotFound: function onPageNotFound() {
    console.log('onPageNotFound==========>');
  }
});
});/app-service.js	;var globPageRegistPath;
      var globPageRegistering;
      global = {};;
      ;
    var TMAConfig = {"pages":["pages/index/index"],"entryPagePath":"pages/index/index","debug":false,"networkTimeout":{"request":60000,"uploadFile":60000,"connectSocket":60000,"downloadFile":60000},"widgets":[],"global":{"window":{"backgroundTextStyle":"light","navigationBarBackgroundColor":"#fff","navigationBarTitleText":"Mini Program","navigationBarTextStyle":"black"}},"ext":{},"extAppid":"","appId":"testappId","network":{"maxRequestConcurrent":5,"maxUploadConcurrent":2,"maxDownloadConcurrent":5},"appLaunchInfo":{"path":"pages/index/index","query":{}},"navigateToMiniProgramAppIdList":[],"permission":{},"ssr":true};
    try {
        nativeTMAConfig = JSON.parse(nativeTMAConfig);
    } catch (err) {

    }
    try {
        for (var ii in nativeTMAConfig) {
            TMAConfig[ii] = nativeTMAConfig[ii];
        }
    } catch (err) {

    } finally {
        if (!TMAConfig['launch']) {
            TMAConfig['launch'] = TMAConfig['appLaunchInfo']
        }
    }
    var __allConfig__ = {"pages/index/index":{"usingComponents":{}}};
    ;
      ;require('app.js');
      /pages/index/indexNๆๅฅ็็ธ๏ผ่ฐๆฅ็ป่ฟ้ฉป่ฐๆฅ๏ผ็บฟไธ้ๅฎๅทฒๅจ้ข้ญๅฐโๅฐ็ฆ...crowd233ไธconsoleassertlogStringsubstrlengthindexOfMathsqrtroundrandompowminmaxexpsinceilcosatanacostanasinfloorabs$kTemplateAssemblerview	bindEventtouchend15pxflexrow50px
touchstarttextraw-textๅคดๆก็ญๆฆ	ไบบๅด่ง$renderPage0$page ญฐ ญ      	0
 / 	./ / & &/   / !& " #/$%(& '#( )(*0
&+/ ,*-/$%& .-/0
&+/0 1/23"3!33/+ 425677(8 95:0
 / ;:<3=>&$? @<A/&$2B CAD?3=>&$ EDF'G&H3=% IFJ0
/ KJL	>5M!N"N$3#33= OLP./ QP      RSTUVWXYZ[  \     Q]^_ `abcdefghijklmnopbqrstuvwx 	@00H00H ,y  ฅ@Mz{๘?@|@เฅ@7@}~  @ภ @@เค@=@@@@,@@'@@I@Q@@0H0H0 H0 คH0 H0 H0 คH0 H0 H0 คH0 คH0 คH0 คH0 คH0 คH0 คจH0 คH0 คH0 คจH0 คจH 0คจ H 0คจ H 0คจฌ Hค0จฌคHค0จฌคHค0จฌคH จ0ฌฐจHจ0ฌฐดจHจ0ฌฐจHค0จฌคHค0จฌคHค0จฌคH จ0ฌ ฐจHจ0ฌฐกดจHจ0ฌฐจH 0คขจ H 0คจ H 0คฃจ Hค0จคฌคHค0จฌด ฅธฐคHค0จฌคH0 ฆคH0 คH0 งคH0 จคH0 คH0 ฉคH 0คชจ H 0คจฌ  H 0คจ H0ซ H0 H0 คH^ Q Q^ 
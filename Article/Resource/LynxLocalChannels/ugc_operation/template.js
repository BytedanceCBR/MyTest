½   asm0.1.0.0card  5
.containerwhite20px	container/template.jsÁ/app-service.js#;tt.require("operation/index.js");
/operation/index.jsŻ;tt.define("operation/index.js", function(require, module, exports, Card,setTimeout,setInterval,clearInterval,clearTimeout,NativeModules,tt,window,document,frames,self,location,navigator,localStorage,history,Caches,screen,alert,confirm,prompt,fetch,XMLHttpRequest,WebSocket,webkit,Reporter,print,Function,global){
 "use strict";

Card({
  touchend: function touchend(event) {
    console.log("touchend", event);
    console.log("report_params", JSON.stringify(this.data.report_params));
    NativeModules.FLynxBridge.onEventV3("banner_click", JSON.stringify(this.data.report_params));
    NativeModules.FLynxBridge.jumpSchema(this.data.jump_url);
  },
  data: {
    img_height: 58,
    img_width: 400,
    img_url: "",
    jump_url: "",
    padding_top: 20,
    padding_bottom: 20,
    report_params: {}
  }
});
});/operation/indexpadding_bottompadding_topimg_url 	img_width
img_heightconsoleassertlogStringsubstrlengthindexOfMathsqrtroundrandompowminmaxexpsinceilcosatanacostanasinfloorabs$kTemplateAssemblerviewpx	bindEventtouchendimagesrc#e8e8e84px$page$renderPage0{"ssr":false}             	  
     @@Àĵ@ÀĤ@  !"#$%&'() @0 ¤0H 0¤0¨ H * @  @À @Ħ@+à @,-.ĝ?/0@1@À@U0H0H0 H0 H0 H0¤ ¨ H0¤ ¨ H0 ¤H0 H0 H0 ¤ H0 ¤H0 ¤H0 ¨ Ĵ¤H0 ¨ Ĵ¤H  23 4
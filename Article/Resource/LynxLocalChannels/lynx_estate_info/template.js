   asm0.2.0.00.1.26-test.28unknownunknowncard  |.estate_info_value#66666614pxestate_info_value.estate_info_value_light#ff9629estate_info_value_light.estate_info_court_tags#aeadad12pxestate_info_court_tags.estate_info_key70px0estate_info_key.estate_info_court_alias_value600estate_info_court_alias_value.estate_info_shadow_rounded_box8px#ffffff15px10px16px20pxestate_info_shadow_rounded_box.estate_info_court_alias_keyestate_info_court_alias_key.disclaimercenter#bbbbbb13px 15px 21px
disclaimer.estate_info_item9px
flex-startestate_info_item.estate_info_court_title#33333324pxestate_info_court_title/estate_info/estate_info.jsá;
tt.define("estate_info/estate_info.js", function (require, module, exports, Card, setTimeout, setInterval, clearInterval, clearTimeout, NativeModules, tt, console, Component, TaroLynx, nativeAppId, window, document, frames, self, location, navigator, localStorage, history, Caches, screen, alert, confirm, prompt, fetch, XMLHttpRequest, WebSocket, webkit, Reporter, print, Function, global) {
  "use strict";

  Card({
    data: {},
    onReady: function onReady() {},
    touchPermit: function touchPermit(event) {
      var modlueIndex = event.currentTarget.dataset['module_index'];
      var itemIndex = event.currentTarget.dataset['item_index']; //å¤ç©º

      if (this.data == null && this.data.request_params == null && this.data.request_params.estate_info == null && this.data.request_params.estate_info.court_detail_modules == null) {
        return;
      }

      var moduleList = this.data.request_params.estate_info.court_detail_modules;

      if (moduleList.length <= 0) {
        return;
      }

      var moduleLen = moduleList.length; //å¤æ­moudleIndex

      if (modlueIndex == null || modlueIndex < 0 || modlueIndex >= moduleLen) {
        return;
      }

      var selectModule = moduleList[modlueIndex]; //itemå¤ç©º

      if (selectModule == null || selectModule.court_detail_item_list == null) {
        return;
      }

      var itemList = selectModule.court_detail_item_list;

      if (itemList.length <= 0) {
        return;
      }

      var images_preview = [];
      var imagePreviewInex = 0;

      for (var i = 0; i < itemList.length; i++) {
        var item = itemList[i];

        if (item == null || item.item_type == null || item.item_type != 2 || item.image == null || item.image.url == null) {
          continue;
        }

        images_preview.push(item.image.url);

        if (itemIndex == i) {
          imagePreviewInex = images_preview.length - 1;
        }
      }

      if (images_preview.length <= 0) {
        return;
      }

      NativeModules.FLynxBridge.previewImage(JSON.stringify({
        "index": imagePreviewInex,
        "images": images_preview
      }));
    }
  });
});/app-service.js+;tt.require("estate_info/estate_info.js");
/estate_info/estate_infopermit_list_size	tags_sizecommon_paramsiOS_iPhoneXSeriesdisplay_widthdisplay_heightrequest_paramsestate_infoestate_info_disclaimer¬{"text":"æ¥¼çä¿¡æ¯ä»ä¾åèï¼è¯·ä»¥å¼ååå¬ç¤ºä¸ºåï¼è¥æè¯¯ï¼å¯åé¦çº éã","rich_text":[{"highlight_range":[23,28],"link_url":"fschema://feedback"}]}
court_infotagsalias titleconsoleassertlogStringsubstrlengthindexOfMathsqrtroundrandompowminmaxexpsinceilcosatanacostanasinfloorabs$kTemplateAssemblerscroll-viewscroll-y#F5F5F5column100%pxviewflextextraw-textå«å Â· contentcourt_detail_modulescourt_detail_item_list	item_name
item_value	item_typemodule_index
item_index	bindEventtaptouchPermit#e7e7e70.5pxf-rich-text
text-alignleftrichData	itemIndex$pagemodlueIndex$renderPage0infoItem
moudleItemitemNameidx{"ssr":false} ®± ® 
 /& /&/	
/3/	0&	
)('"&!$#/	, /	 !$"7##"$!%&/'(%      )*+,  -     . / 01 2Ð¿@3ÀÄ@45 6789 :;<; =>?@ABCDEFGHIJKLM?NOPQRSTU  ¤@¬0°´0¬H°0´0¸°H QV W@X ¥@YÀ@Z@3[\ø?@]@¢@^@(_@8<:;@@`@@@à¥@9@
@ab5c@def@$@@À@ghijkl@À@mn ¢@o@pqr6 0H0H0 H0 H0 H0 H0¨ ¬¤¨ H0 H0 H0 ¤H0 ¤H0 ¤H0 ¤H0 ¤H0 ¤¨H0 ¤¨H0 ¤¨H 0¤¨ H 0¤¨ H 0¤¨ H¤0¨¬¤H¤0¨¬¸ ¼´¸°¤H¤0¨¬¤H¨ ¬¤¨ ¤ØÍX¤0¨¬¤H¤0¨¬¤H¤0¨¬°¤H ¨0¬ °¨H¨0¬°¨H¨0¬¡°¨H¤¬0°´¬H¬0°´¢¸¬H¬0°´¬H¨0¬£°¨H¨0¬°¨H¨0¬¤°¨H¤¬0°¥´¬H¬0°´À Ä ¼À¸¬H¬0°´¬H`  ¤ÈÐX¤0¨¦¬¤H¤0¨¬¤H¤0¨§¬¨°¤H¤0¨¬©°¤H ¬ °¨ª¬¤¨°¸0¼¸H¬À¯¬X´0¸¼´H¸0¼«À¸H¸0¼À¸H¸0¼¬À¸H´¼0À­Ä¼H¼0ÀÄÐÔ¨ÌÈÌX®ÐØ¯Ü¬Ô¨È`Ð¯Ô¨È¼H¼0ÀÄ¼H¨Íÿ``¤ ¨ Ø¬ °°¨¬¤Ø°¬ °°¨±¬¤¨ Ø°ÏX¤ °¨ ±¤ ¨°0´°H¤ÀÂ¤X¬0°´¬H°0´²¸°H°0´¸°H°0´¸°H°0´¸¼°H°0´¸¼°H¬´³¸°´¼Ä0ÈÄH¸À¸XÀ0ÄÈÀHÌ´Ð¦ÈÌ¤ÄØÐµÔ¨ÌÐ¦ÈØ¢À°äÀXÈ0Ì¶ÐÈH¢È0ÌÐÈHÈ0Ì·ÐÈHÄÌ0Ð¸ÔÌH¤Ì0¢ÐÔÌHÌ0Ð¹ÔÌHÈÐ0ÔºØÐH¦Ð0ÔØà´ä°ÜÐHÐ0¤ÔØÐHÌ0Ð»ÔÌH¤Ì0¢ÐÔÌHÌ0Ðà¼ä°Üà®ØÐØX½Ô`¾ÔÌHÌ0Ð¿ÔØÌHÌ0ÐÀÔØÌHÌ0ÐÁÔÂØÃÜÌHÈÐ0ÔÄØÐH¦Ð0ÔØàµä°ÜÐHÐ0¤ÔØÐH`È¼Ì¤ÄÈ¢ÀÐÀXÈ0ÌÅÐÈH¢È0ÌÐÈHÈ0ÌÐÆÔÈHÈ0ÌÐÇÔÈHÈ0ÌÈÐÉÔÈHÈ0ÌÐÉÔÈH`´âþ` ºþ``0Ê Ë¤H0 ¤H0 Ì¤Í¨H0 Î¤¬ Ï°¨H0 Ð¤H0 444/444444 st
uv	wxyz/40 {
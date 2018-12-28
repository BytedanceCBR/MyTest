//
//  TTRDynamicPluginRegister.m
//  Article
//
//  Created by lizhuoli on 2017/9/5.
//
//

#import "TTRDynamicPluginRegister.h"
#import <TTRexxar/TTRJSBForwarding.h>

@implementation TTRDynamicPluginRegister

+ (void)load {
       
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRShortVideo.redpackWebIntroClicked" for:@"redpackWebIntroClicked"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRPageState.isVisible" for:@"is_visible"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRPageState.pageStateChange" for:@"page_state_change"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRPageState.addEventListener" for:@"addEventListener"];
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRPay.pay" for:@"pay"];
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRVideo.playVideo" for:@"playVideo"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRVideo.playNativeVideo" for:@"playNativeVideo"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRVideo.pauseVideo" for:@"pauseVideo"];
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRApp.copyToClipboard" for:@"copyToClipboard"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRApp.isAppInstalled" for:@"isAppInstalled"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRApp.appInfo" for:@"appInfo"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRApp.config" for:@"config"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRApp.getStatusBarInfo" for:@"getStatusBarInfo"];

    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTNetwork.fetch" for:@"fetch"];

    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRLogin.login" for:@"login"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRLogin.isLogin" for:@"is_login"];
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRNavi.close" for:@"close"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRNavi.open" for:@"open"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRNavi.handleNavBack" for:@"handleNavBack"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRNavi.openHotsoon" for:@"openHotsoon"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRNavi.openApp" for:@"openApp"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRNavi.disableDragBack" for:@"disableDragBack"];
    
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRShare.share" for:@"share"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRShare.sharePGC" for:@"share_pgc"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRShare.sharePanel" for:@"sharePanel"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRShare.systemShare" for:@"systemShare"];
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRChannel.addChannel" for:@"addChannel"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRChannel.getSubScribedChannelList" for:@"getSubScribedChannelList"];
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRAd.openCommodity" for:@"openCommodity"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRAd.callNativePhone" for:@"callNativePhone"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRAd.getAddress" for:@"getAddress"];
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRUIWidget.toast" for:@"toast"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRUIWidget.alert" for:@"alert"];

    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRMonitor.status" for:@"monitor"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRMonitor.value" for:@"monitor_performance"];
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRImpression.onWebImpression" for:@"impression"];
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRPhoto.takePhoto" for:@"takePhoto"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRPhoto.confirmUploadPhoto" for:@"confirmUploadPhoto"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRContacts.getContacts" for:@"getContacts"];
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRWenda.deleteAnswerDraft" for:@"delete_answer_draft"];
    
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRShortVideo.getRedPackIntro" for:@"get_redpack_state"];

}

@end

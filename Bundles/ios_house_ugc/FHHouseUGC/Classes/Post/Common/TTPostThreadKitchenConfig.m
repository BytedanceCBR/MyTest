//
//  TTPostThreadKitchenConfig.m
//  AWEVideoPlayer
//
//  Created by SongChai on 2018/5/19.
//

#import "TTPostThreadKitchenConfig.h"
#import <TTGaiaExtension/GAIAEngine+TTBase.h>

@implementation TTKitchenManager (PostThreadConfig)

TTRegisterKitchenFunction() {
    TTKitchenRegisterBlock(^{
        TTKConfigString(kTTKCommentRepostRepostToCommentText, @"转发发布器转发并评论文字", @"同时评论");
        TTKConfigBOOL(kTTKCommentRepostRepostToCommentEnable, @"转发发布器转发并评论开关", YES); // 隐藏相当于没选中
        TTKConfigBOOL(kTTKCommentRepostRepostToCommentSelected, @"转发并评论 上次选中状态", YES); // 漏出时有效
        TTKConfigFloat(kTTKUGCRepostCommentCheckBoxType, @"转发并评论:1每次选中,2隐藏选中", 0);
        TTKConfigArray(kTTKUGCRepostCommentTypes, @"支持转发并评论的repostType", @[@"211", @"212", @"213", @"214", @"215", @"220", @"221", @"223"]);
        
        TTKConfigFloat(kTTKUGCPostAndRepostContentMaxCount, @"UGC发布器字数限制", 2000);
        
        TTKConfigBOOL(kTTKUGCPostAndRepostBanHashtag, @"转发并评论 上次选中状态", NO);
        TTKConfigBOOL(kTTKUGCPostAndRepostBanAt, @"转发并评论 上次选中状态", NO);

        TTKConfigBOOL(kTTKUGCDirectRepostAlwaysComment, @"转发分享面板直接转发时，同时评论", YES);

        TTKConfigString(kTTKGMapKey, @"GoogleI API Key", @"");
        TTKConfigBOOL(kTTKGMapServiceAvailable, @"是否开启GoogleI API", NO);
        TTKConfigString(kTTUGCBusinessAllianceChoiceProtocolUrl, @"精选联盟协议", @"https://sf1-ttcdn-tos.pstatp.com/obj/ttfe/temai/jingxuanlianmengxieyi.html");
        TTKConfigBOOL(kTTKUGCPostLocationSuggestEnable, @"地址选择器增加搜索推荐", NO);
        NSString *text = [NSString stringWithFormat:@"同%@聊",@"步到飞"];
        TTKConfigString(kTTKUGCPostSyncToRocketText, @"发布器右下角文案", text);
        TTKConfigBOOL(kTTKUGCSyncToRocketFirstChecked, @"同步到R首次状态", YES);//默认勾选
        TTKConfigFloat(kTTKUGCSyncToRocketCheckStatus, @"同步到R勾选状态", -1);//初始为无状态
        TTKConfigArray(kTTPostThreadSyncToRocketSupportPublishEnterFrom, @"微头条发布器同步到R支持的来源", @[@(1),@(2),@(3)]);
        TTKConfigBOOL(kTTKCommonUgcPostBindingPhoneNumberKey, @"发帖／转发是否需要绑定手机号",NO);

    });
}

@end

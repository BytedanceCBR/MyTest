//
//  TTCommentKitchenConfig.m
//  Article
//
//  Created by SongChai on 2018/3/19.
//
//
#import "TTCommentKitchenConfig.h"
#import <TTGaiaExtension/GAIAEngine+TTBase.h>

@implementation TTKitchenManager (TTComment)

TTRegisterKitchenFunction() {
    TTKitchenRegisterBlock(^{
        TTKConfigFloat(kTTKUGCCommentRepostCheckBoxType, @"评论并转发:1每次选中", 0);
        TTKConfigString(kTTKCommentImageForbidenTips, @"禁止图片评论时点击图片按钮的tips", @"目前仅对少量用户开放");
        TTKConfigBOOL(kTTKCommentImageIconHidden,@"图片评论按钮统一不展示的开关",YES);
        TTKConfigFloat(kTTKCommentRepostSelected, @"评论并转发☑️是否选中", -1); // -1 表示未设置,0表示手点不选，1表示选
        TTKConfigBOOL(kTTCommentReplyListFilterDisable, @"评论排序策略优化开关，为YES时不去重，为NO时去重", NO);
        TTKConfigBOOL(kTTCommentHashTagHidden, @"评论hashtag是否隐藏",NO);
        TTKConfigFloat(kTTCommentPublishRichSpanCountLimit, @"评论发布时的富文本数量的限制", 20);
        TTKConfigFloat(kTTCommentStyle, @"评论样式 0：老样式；1：转评赞样式无转赞文本；2：转评赞样式有转赞文本", 0);
        TTKConfigFloat(kTTCommentWriteInputBoxStyle, @"评论框输入样式是否使用新样式", 0); // 0:老样式；1：扩大输入框的样式
        TTKConfigDictionary(kTTCommentDislike, @"评论区dislike", @{});
        TTKConfigBOOL(kTTCommentFPSMonitorEnable, @"评论区FPS监控是否可用", NO);
        TTKConfigFloat(kTTCommentFPSMonitorInterval, @"评论区FPS监控统计间隔时长", 24 * 60 * 60);
        TTKConfigFloat(kTTCommentFPSMonitorMinCount, @"评论区FPS监控最小统计数", 30);
        TTKConfigFloat(kTTCommentFPSMonitorDuration, @"评论区FPS监控最长统计持续时长（秒）", 30);
        TTKConfigFloat(kTTCommentFPSMonitorCommentDetailLastTime, @"评论区FPS监控评论详情页上次监控时间", 0);
        TTKConfigString(kTTKCommentRepostFirstDetailText, @"文章、帖子评论☑️后文字",@"同时转发");
    });
}
@end

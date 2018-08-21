//
//  WDCommonLogic.h
//  Article
//
//  Created by xuzichao on 16/9/8.
//
//

#import <Foundation/Foundation.h>
#import "WDDefines.h"

typedef NS_ENUM(NSInteger, WDCommentType)  {
    WDCommentTypeArticle,   // 文章类型评论
    WDCommentTypeArticleComment, // 文章评论的评论
    WDCommentTypeMoment,    // 动态类型评论
    WDCommentTypeMomentComment, // 动态评论的评论
};

@interface WDCommonLogic : NSObject

@end

@interface WDCommonLogic (WDCategoryCathedData)

+ (void)setWDCategoryCathedDataJsonString:(NSString *)jsonString;
+ (NSString *)getWDCategoryCathedDataJsonString;
+ (void)clearWDCategoryCathedDataJsonString;

@end


@interface WDCommonLogic (WDDetailSwitch)
+ (void)setWDNewDetailStyleEnabled:(BOOL)enabled;
+ (BOOL)isWDNewDetailStyleEnabled;
+ (void)setWDNewDetailNewPushDisabled:(BOOL)enabled;
+ (BOOL)isWDNewDetailNewPushDisabled;
@end

@interface WDCommonLogic (WDNatantNewStyleEnable)

+ (void)setWDDetailNatantNewStyleEnable:(BOOL)enable;
+ (BOOL)isWDDetailNatantNewStyleEnable;

@end


@interface WDCommonLogic (channelShowAddFristPage)
+ (void)setChannelAddFristPageEnabled:(BOOL)enabled;
+ (BOOL)isChannelAddFristPageEnabled;
@end

@interface WDCommonLogic (hasCloseAddToFirstPageCell)
+ (BOOL)shouldShowAddToFirstPageCell;
+ (void)closeAddToFirstPageCell:(BOOL)close;
@end

@interface WDCommonLogic (WDBrandTransform)

+ (void)setWukongURL:(NSString *)urlString;
+ (NSString *)wukongURL;

@end

@interface WDCommonLogic (WDDetailReportStyle)

+ (void)setRelatedReportStyle:(NSNumber *)style;
+ (WDDetailReportStyle)relatedReportStyle;

@end

@interface WDCommonLogic (WDDetailShowType)

+ (void)setAnswerDetailShowSlideType:(NSInteger)showSlideType;
+ (NSInteger)answerDetailShowSlideType;

@end

@interface WDCommonLogic (WDDetailSlide)
+ (BOOL)noNeedDisplaySlideHelp;
+ (void)setNoNeedDisplaySlideHelp:(BOOL)value;
+ (void)increaseSlideDisplayHelp;
@end

@interface WDCommonLogic (CommentDraft)
+ (void)setDraft:(NSDictionary *)draft forType:(WDCommentType)type;
+ (NSDictionary *)draftForType:(WDCommentType)type;
+ (void)cleanDrafts;
+ (void)setSaveForwordStatusEnabled:(BOOL)enabled;
+ (BOOL)saveForwordStatusEnabled;
+ (NSString *)commentInputViewPlaceHolder;
@end

@interface WDCommonLogic  (ShareTemplate)

+ (NSString *)parseShareContentWithTemplate:(NSString *)templateString title:(NSString *)t shareURLString:(NSString *)urlString;

+ (void)saveShareTemplate:(NSDictionary *)dict;
+ (NSDictionary *)getShareTemplate;
@end

@interface WDCommonLogic (TipGesture)

+ (BOOL)showGestureTip;
+ (void)setShowGestureTip:(BOOL)showGestureTip;

@end

@interface WDCommonLogic (Author)

+ (void)setH5SettingsForAuthor:(NSDictionary *)settings;
+ (NSDictionary *)fetchH5SettingsForAuthor;

@end

@interface WDCommonLogic (TransitonAnimationEnable)
+ (void)setTransitionAnimationEnable:(BOOL)enable;
+ (BOOL)transitionAnimationEnable;
@end


@interface WDCommonLogic (UserVerifyConfig)

+ (void)setUserVerifyConfigs:(NSDictionary *)configs;
+ (NSDictionary *)userVerifyConfigs;
/** 根据认证类型，返回对应的头像图标模型 */
+ (NSDictionary *)userVerifyAvatarIconModelOfType:(NSString *)type;
/** 根据认证类型，返回对应的标签认证模型 */
+ (NSDictionary *)userVerifyLabelIconModelOfType:(NSString *)type;
/** 返回Feed控制应该显示的认证类型数组 */
+ (NSArray<NSString *> *)userVerifyFeedShowArray;
@end

@interface WDCommonLogic (UGCMedals)
+ (void)setUGCMedalsWithDictionay:(NSDictionary *)dictionary;
+ (NSDictionary *)ugcMedals;
@end

@interface WDCommonLogic (PullRefresh)
+ (void)setNewPullRefreshEnabled:(BOOL)enabled;
+ (BOOL)isNewPullRefreshEnabled;
+ (CGFloat)articleNotifyBarHeight;
@end

@interface WDCommonLogic (ImageHost)

+ (NSString *)toutiaoImageHost;
+ (void)setToutiaoImageHost:(NSString *)host;

@end

@interface WDCommonLogic (Answer)

+ (void)setAnswerReadPositionEnable:(BOOL)enable;
+ (BOOL)answerReadPositionEnable;

@end

@interface WDCommonLogic (MessageNewStyle)

+ (void)setWDMessageDislikeNewStyle:(BOOL)enable;
+ (BOOL)isWDMessageDislikeNewStyle;

@end


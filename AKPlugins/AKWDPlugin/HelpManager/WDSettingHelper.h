//
//  WDSettingHelper.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/13.
//
//

#import <Foundation/Foundation.h>
#import "NSObject+TTAdditions.h"
#import "WDDefines.h"

@interface WDSettingHelper : NSObject<Singleton>

+ (void)saveWendaAppInfoDict:(NSDictionary *)dict;
+ (NSDictionary *)savedWendaInfoDict;

#pragma mark -- 服务端可控值

/**
 *  页面统计停留时长
 *
 *  @return 需要开始记录的错误值
 */
- (NSTimeInterval)pageStayErrorTime;

/**
 *  问答列表Cell回答摘要的最大显示行数
 *
 *  @return 问答列表Cell回答摘要的最大显示行数
 */
- (NSInteger)listCellContentMaxLine;

/**
 *  折叠列表Cell中回答的摘要最多显示的行数
 *
 *  @return 客户端默认值：3
 */
- (NSInteger)moreListAnswerTextMaxCount;

/**
 *  回答列表Cell中带图片的回答的摘要最多显示的行数
 *
 *  @return 客户端默认值：3
 */
- (NSInteger)listAnswerHasImgTextMaxCount;

/**
 *  发送回答时的最小字数限制
 *
 *  @return 客户端默认值: 1
 */
- (NSInteger)minAnswerTextLength;

#pragma mark -- 服务端可控文案

/**
 *  回答列表section header 的文案
 *
 *  @return 客户端默认值： 回答
 */
- (NSString *)listSectionTitleText;

/**
 *  回答列表的问题header 的 回答数的文案
 *
 *  @return 客户端默认值：个回答	
 */
- (NSString *)listQuestionHeaderAnswerCountText;

/**
 *  回答框的placeholder
 *
 *  @return 客户端默认值：不认真的回答会被折叠哦~
 */
- (NSString *)postAnswerPlaceholder;

/**
 *  快答回答框的placeholder
 *
 *  @return 客户端默认值：请输入回答
 */
- (NSString *)quickPostAnswerPlaceholder;

/**
 *  回答列表底部进入折叠列表的入口的文案
 *
 *  @return 客户端默认值：个回答被折叠
 */
- (NSString *)listMoreAnswerCountText;

/**
 *  发送回答字数太少的提案
 *
 *  @return 回答字数不能低于xx个字
 */
- (NSString *)minAnswerLengthText;

/**
 *  问答业务的CDN hosts
 *
 *  @return cdn hosts
 */
+ (NSArray *)wendaDetailURLHosts;
+ (NSArray *)defaultWendaDetailURLHosts;

/**
 *  追踪5.6.x开始的crash，控制info重试和预加载下一个
 *
 *  @return 是否打开，默认不打开
 */
- (BOOL)isWenSwithOpen;

#pragma mark - 举报原因选项
/** 问答问题举报选项 */
- (NSArray *)wendaAnswerReportSetting;
/** 问答回答举报选项 */
- (NSArray *)wendaQuestionReportSetting;

#pragma mark - 是否显示分成

- (BOOL)isQuestionRewardUserViewShow;

#pragma mark - 是否显示分享有礼

- (BOOL)isQuestionShareRewardUserViewShow;

#pragma mark - 问答列表页

- (BOOL)isQuestionShowPicture;

#pragma mark - 提问
- (BOOL)isPostAnswerVideo;
- (NSString *)wendaCategoryPlaceHolder;
- (NSArray *)wendaPostFirstHintArray;
- (NSString *)wendaPostQuestionPlaceHolder;
- (NSInteger)maxQuestionTitleCharaterNumber;
- (NSInteger)minQuestionTitleCharaterNumber;
- (NSString *)wendaPostQuestionHintTitle;
- (NSString *)wendaPostQuestionHintSchema;

- (NSString *)postQuestionDescPlaceHolder;
- (NSInteger)maxQuestionDescCharaterNumber;
- (NSInteger)minQuestionDescCharaterNumber;
- (BOOL)isDescRequired;

- (NSString *)postQuestionTagPlaceHolder;

#pragma mark - 详情页逻辑

- (BOOL)wdDetailShowMode;
- (BOOL)wdDetailNewPushDisabled;

- (BOOL)wdDetailStatusBarStyleIsDefault;
- (void)wdSetDetailStatusBarStyleIsDefault:(BOOL)isDefault;

typedef NS_ENUM(NSInteger, AnswerDetailShowSlideType) {
    AnswerDetailShowSlideTypeNoSlide = 0,                 // 详情页旧样式不可横滑
    AnswerDetailShowSlideTypeWhiteHeaderWithoutHint,      // 详情页旧样式可横滑无滑动提示（白色header）
    AnswerDetailShowSlideTypeWhiteHeaderWithHint,         // 详情页旧样式可横滑有滑动提示（白色header）
    AnswerDetailShowSlideTypeBlueHeaderWithHint,          // 详情页新样式可横滑有滑动提示（蓝色header）
};

- (AnswerDetailShowSlideType)wdAnswerDetailShowSlideType;

// 详情页头部样式
- (NSUInteger)wendaDetailHeaderViewStyle;

#pragma mark - Feed露出文字AB

- (BOOL)isFeedHeaderTextType;

@end

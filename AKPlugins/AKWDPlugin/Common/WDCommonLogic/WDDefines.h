//
//  WDDefines.h
//  Article
//
//  Created by 延晋 张 on 16/5/6.
//
//

#pragma once

#import "WDApiModel.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/UIButton+TTAdditions.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/UIImageAdditions.h>
#import <TTBaseLib/UITextView+TTAdditions.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/NSObject+TTAdditions.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTBusinessManager.h>
#import <TTBaseLib/TTBusinessManager+StringUtils.h>

#import <TTNetworkManager/TTNetworkDefine.h>
#import <TTThemed/UIColor+TTThemeExtension.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTThemed/TTThemeConst.h>
#import <TTThemed/TTThemeManager.h>
#import <Masonry.h>

#import <TTTracker/TTTracker.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>

typedef NS_ENUM(NSInteger, WDDetailReportStyle) {
    WDDetailReportStyleNormal = 0,             // 举报在fe端，点赞在bottomBar
    WDDetailReportStyleReportNewStyle = 1,     // 举报在fe，文案新样式，bottom有点赞
    WDDetailReportStyleRelatedReport = 2,      // 点赞举报在related，bottom无点赞
    WDDetailReportStyleDoubleDigg    = 3       // 点赞举报在related，bottom有点赞
};

#ifndef SSMinX
#define SSMinX(view) CGRectGetMinX(view.frame)
#endif

#ifndef SSMinY
#define SSMinY(view) CGRectGetMinY(view.frame)
#endif

#ifndef SSMaxX
#define SSMaxX(view) CGRectGetMaxX(view.frame)
#endif

#ifndef SSMaxY
#define SSMaxY(view) CGRectGetMaxY(view.frame)
#endif

#ifndef SSWidth
#define SSWidth(view) view.frame.size.width
#endif

#ifndef SSHeight
#define SSHeight(view) view.frame.size.height
#endif

#ifndef SSScreenWidth
#define SSScreenWidth [[UIScreen mainScreen] bounds].size.width
#endif

#ifndef SSScreenHeight
#define SSScreenHeight [[UIScreen mainScreen] bounds].size.height
#endif

#ifndef kNavigationBarHeight
#define kNavigationBarHeight (self.view.tt_safeAreaInsets.top ? self.view.tt_safeAreaInsets.top + 44 : ([TTDeviceHelper isIPhoneXDevice] ? 44 : [UIApplication sharedApplication].statusBarFrame.size.height) + 44)
#endif

#ifndef isEmptyString
#define isEmptyString(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif

#ifndef SSIsEmptyArray
#define SSIsEmptyArray(array) (!array || ![array isKindOfClass:[NSArray class]] || array.count == 0)
#endif

#ifndef SSIsEmptyDictionary
#define SSIsEmptyDictionary(dict) (!dict || ![dict isKindOfClass:[NSDictionary class]] || ((NSDictionary *)dict).count == 0)
#endif

NSString * const kWDCategoryId = @"question_and_answer";

extern NSString * const WDCategoryHeaderInfoCellViewRefreshKey;

// 这个涉及到和另一个库交互
extern NSString * const TTWDFollowPublishQASuccessForPushGuideNotification;

extern NSString * const kWDEnterFromKey;
extern NSString * const kWDParentEnterFromKey;

extern NSString * const kWDCategoryId;

extern NSString * const WDInviteRecommendUsersSchema;

extern NSString * const kWDReviewQuestionPageSource;
extern NSString * const kWDDetailViewControllerUMEventName;

extern NSString * const kWDCategoryDislikeCellNotice;

extern NSString * const kWDFetchAnswerDetailFinishedNotification;
extern NSString * const kWDDraftNeedRefreshNotification;
extern NSString * const kWDDeleteDraftNotification;

extern NSString * const kWDServiceHelperQuestionFollowNotification;

extern CGFloat const kInputDescTitleFontSize;
extern CGFloat const kInputDescTitleTopMargin;
extern CGFloat const kWDPostQuestionMargin;
extern CGFloat const kInputDescTopPadding;
extern CGFloat const kInputDescFontSize;
extern CGFloat const kInputDescDescLeftInset;

extern NSString * const kWDDetailNeedReturnKey;

typedef NS_ENUM(NSInteger, WDDiggType) {
    WDDiggTypeDigg   = 0,
    WDDiggTypeUnDigg = 1,
};

typedef NS_ENUM(NSInteger, WDBuryType) {
    WDBuryTypeBury   = 0,
    WDBuryTypeUnBury = 1,
};

// 和主端交互
typedef NS_ENUM(NSInteger, WDPushNoteGuideFireReason) {
    WDPushNoteGuideFireReasonWDFollowQuestion  = 10, // 问答关注问题 /wenda/v1/commit/followquestion
    WDPushNoteGuideFireReasonWDPublishAnswer   = 11, // 问答发表答案 /wenda/v1/commit/postanswer
    WDPushNoteGuideFireReasonWDPublishQuestion = 12, // 问答发表问题 /wenda/v1/commit/postquestion
    WDPushNoteGuideFireReasonWDPublishComment  = 13, // 问答发表评论 /wenda/v1/commit/postcomment
};


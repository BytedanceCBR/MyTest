//
//  SSUserSettingManager.h
//  Article
//
//  Created by Yu Tianhang on 13-2-22.
//
//

#import <Foundation/Foundation.h>

#define kFontSettingKey                 @"kFontSettingKey"

extern NSString * const kHasShownIntroductionKey;

extern NSInteger tt_ssusersettingsManager_fontSettingIndex(void);
extern float tt_ssusersettingsManager_detailRelateReadFontSize(void);
extern float tt_ssusersettingsManager_detailVideoTitleFontSize(void);
extern float tt_ssusersettingsManager_detailVideoContentFontSize(void);

@interface SSUserSettingManager : NSObject

+(id)sharedManager;

// image settings
+ (NSArray*)networkTrafficSettings;

+ (NSInteger)fontSettingIndex;

/*
 *  评论字体差值
 */
+ (float)settedCommentViewFontDeltaSize;

/**
 *  评论字体大小
 */
+ (float)commentFontSize;

/**
 *  评论回复字体大小
 */
+ (float)replyFontSize;

/**
 *  评论行间距
 */
+ (float)commentLineHeight;

/**
 *  详情页相关阅读字体大小
 */
+ (float)detailRelateReadFontSize;
+ (float)newDetailRelateReadFontSize;

/**
 *  视频详情页标题字体大小
 */
+ (float)detailVideoTitleFontSize;
/**
 *  视频详情页标题行间距
 */
+ (float)detailVideoTitleLineHeight;
/**
 *  视频详情页内容字体大小
 */
+ (float)detailVideoContentFontSize;
/**
 *  视频详情页内容行间距
 */
+ (float)detailVideoContentLineHeight;
/*
 * 夜间模式是否已经设置过
 */
+ (BOOL)hasShownNightMode;
+ (void)setHasShownNightMode:(BOOL)shown;

+ (BOOL)shouldShowIntroductionView;
+ (void)setShouldShowIntroductionView:(BOOL)should;

+ (CGFloat)sizeWithFontDefaultSetting:(CGFloat)normalSize;
@end

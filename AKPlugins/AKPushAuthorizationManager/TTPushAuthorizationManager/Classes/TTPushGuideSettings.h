//
//  TTPushGuideSettings.h
//  Article
//
//  Created by liuzuopeng on 11/07/2017.
//
//

#import <Foundation/Foundation.h>
#import <FLAnimatedImage.h>



/**
 *  @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=86351779
 *
 *  读「热」文：
 *      点击带有「热」tag的文章时，在阅读完毕后回到推荐频道时，弹出提示
 *  关注：「关注头条号」后，返回到推荐频道时，弹出提示
 *  互动：当用户发文/发帖、发表评论成功后，弹出提示
 */
@interface TTPushGuideSettingsModel : NSObject
@property (nonatomic,   copy) NSString *titleString;
@property (nonatomic,   copy) NSString *subtitleString;
@property (nonatomic, strong) id image; /* UIImage, FLAnimatedImage */
@property (nonatomic,   copy) NSString *imageURLString;
@property (nonatomic, strong) id nightImage; /* UIImage, FLAnimatedImage */
@property (nonatomic,   copy) NSString *nightImageURLString;
@property (nonatomic,   copy) NSString *buttonTextString;

- (BOOL)containsImage;

+ (NSString *)defaultTitleText;

+ (NSString *)defaultSubtitleText;

+ (NSString *)defaultButtonText;

@end



typedef
NS_ENUM(NSInteger, TTPushGuideDialogCategory) {
    TTPushGuideDialogCategoryReadTopArticle = 0, // 热文
    TTPushGuideDialogCategoryFollow = 1,         // 关注
    TTPushGuideDialogCategoryInteraction = 2,    // 互动 （评论或发帖）
};

/**
 *  频控：之后每次弹窗距上次同类弹窗间隔时间i天。最多弹j次。和其他类型弹窗间隔c天。j=4，c=1 配置，服务端可配置，可支持abtest
 i（距上次同类弹窗间隔时间）a，a+b，a+2b，...，a+jb，可变a=2，b=2，即第一次2天、第二次4天、第三次6天，第四次8天
 每种弹窗最大次数m=1，可配置
 */
@interface TTPushGuideSettings : NSObject

+ (void)parsePushGuideConfigFromSettings:(NSDictionary *)dict;

/** 获取指定类别的数据Model */
+ (TTPushGuideSettingsModel *)pushGuideDialogModelOfCategory:(NSInteger /** TTPushGuideDialogCategory */)category;

/** 日间图是否下载成功 */
+ (BOOL)imageHasDownloadedOfCategory:(NSInteger)category;

/** 夜间图是否下载成功 */
+ (BOOL)nightImageHasDownloadedOfCategory:(NSInteger)category;

/** 某种类型弹窗最多显示次数 
 *  如： 
 *      通过点击`热`文最多显示推送引导次数
 *      通过点击`关注`最多显示推送引导次数
 *      通过点击`互动`最多显示推送引导次数
 **/
+ (NSInteger)maxShowTimesOfCategory:(NSInteger)category;

@end

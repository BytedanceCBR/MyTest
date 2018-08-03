//
//  TTTopBarManager.h
//  Article
//
//  Created by fengyadong on 16/8/25.
//
//

#import <Foundation/Foundation.h>

extern NSString *kTTTopBarZipDownloadSuccess;
extern NSString *kTTTopBarSurfaceValidate;

//正常版本图片名称
extern NSString *const kTTPublishBackgroundImageName;
extern NSString *const kTTPublishSearchImageName;
extern NSString *const kTTPublishLogoImageName;
extern NSString *const kTTPublishLightCameraImageName;
extern NSString *const kTTPublishDarkCamerImageName;

@interface TTTopBarManager : NSObject<Singleton>

@property (nonatomic, assign, readonly) BOOL isSigleConfigValid;//单独的配置是否可以生效
@property (nonatomic, strong, readonly) NSNumber *topBarConfigValid;//整个topBar配置是否有效(考虑和tabBar联动)

//通用
@property (nonatomic, assign, readonly) BOOL isStatusBarLight;
//搜索露出
@property (nonatomic, copy, readonly)   NSArray<NSString *> *selectorViewTextColors;
@property (nonatomic, copy, readonly)   NSArray<NSString *> *selectorViewTextGlowColors;
@property (nonatomic, assign, readonly) CGFloat selectorViewTextGlowSize;
//普通样式
@property (nonatomic, assign, readonly) CGFloat textLeftOffset;
@property (nonatomic, assign, readonly) CGFloat touchAreaLeftOffset;
@property (nonatomic, copy, readonly)   NSArray<NSString *> *searchTextColors;

- (void)setTopBarSettingsDict:(NSDictionary *)dict;
- (UIImage *)getImageForName:(NSString *)imageName;

- (UIImage *)lightPublishImage;//首页和西瓜视频tab topbar发布器入口图标
- (UIImage *)darkPublishImage;//微头条tab topbar发布器入口图标
- (UIImage *)unloginImage;//微头条和小视频tab topbar未登录头像图标

@end

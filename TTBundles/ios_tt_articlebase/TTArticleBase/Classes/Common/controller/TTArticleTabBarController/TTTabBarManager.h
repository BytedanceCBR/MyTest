//
//  TTTabBarManager.h
//  Pods
//
//  Created by fengyadong on 16/7/12.
//
//

#import <Foundation/Foundation.h>
#import <TTThemeManager.h>

@class TTTabBarItem;
@class TTTabBarImageModel;
@class TTTabBarImageList;
@class TTTabbar;
@class SSThemedButton;
@class TTTabBarCustomMiddleModel;

extern NSString *kTTTabBarZipDownloadSuccess;

//服务端下发的tab标题key 且是 服务端下发的tab图片名
extern NSString *kTTTabHomeTabKey; //首页tab 标题key&图片名
extern NSString *kTTTabVideoTabKey; //视频tab 标题key&图片
extern NSString *kTTTabFollowTabKey; //关注tab 标题key&图片
extern NSString *kTTTabMineTabKey; //我的tab 图片&标题key
extern NSString *kTTTabWeitoutiaoTabKey; //微头条tab 图片&标题key
extern NSString *kTTTabHTSTabKey;//火山小视频tab 标题&图片名
extern NSString *kTTTabActivityTabKey; //常驻运营活动tab 标题&图片名
extern NSString *kTTTabUnloginName; //我的tab未登录图片
extern NSString *kTTTabFeedPublishName; //feed发布器图片
extern NSString *kAKTabActivityTabKey;  //爱看任务tab
extern NSString *kFHouseFindTabKey; //房产找房key
extern NSString *kFHouseMessageTabKey; //房产首页key
extern NSString *kFHouseMineTabKey; //房产首页key

@interface TTTabBarManager : NSObject

@property (nonatomic, strong, readonly) NSArray<TTTabBarItem *> *tabItems;
@property (nonatomic, strong, readonly) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, strong, readonly) NSArray<NSString *> *tabTags;
@property (nonatomic, assign, readonly) BOOL isSingleConfigValid;//单独配置是否生效(不考虑和topBar联动)
@property (nonatomic, strong, readonly) NSNumber *tabConfigValid;//整个tab配置是否有效（考虑和topBar联动）
@property (nonatomic, strong, readonly) NSString *followHeaderText; //关注页头部文案
@property (nonatomic, strong, readonly) SSThemedButton *customMiddleButton;
@property (nonatomic, strong, readonly) TTTabBarCustomMiddleModel *middleModel;

+ (TTTabBarManager *)sharedTTTabBarManager;

- (TTTabBarItem *)tabItemWithIdentifier:(NSString *)idenfitier;

- (void)setTabBarSettingsDict:(NSDictionary *)dict;

- (void)reloadThemeForTabbar:(TTTabbar *)tabBar style:(NSString *)style;

- (void)reloadIconAndTitleForItem:(TTTabBarItem *)item;

- (void)setPublishButton:(UIButton *)publishButton themeMode:(TTThemeMode)themeMode;

- (NSString *)getItemTitleForIndex:(NSUInteger)itemIndex;

- (UIImage *)getItemImageForIndex:(NSUInteger)itemIndex isHighlighted:(BOOL)isHighlighted;

- (void)registerTabBarforIndentifier:(NSString *)identifier atIndex:(NSUInteger)index isRegular:(BOOL)isRegular;
- (NSString *)tabKeyForReallyTabIndex:(NSUInteger)tabIndex;

// 更新tabItem隐藏/显示状态。实时更新底tab，但不改变tabManager数据源
- (void)updateItemState:(BOOL)freeze withIdentifier:(NSString *)identifier;

- (void)updateTabTags:(NSArray *)tabTags;

@end

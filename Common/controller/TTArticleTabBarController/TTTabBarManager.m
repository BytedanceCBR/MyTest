//
//  TTTabBarManager.m
//  Pods
//
//  Created by fengyadong on 16/7/12.
//
//

#import "TTTabBarManager.h"
#import "TTTabBarItem.h"
#import "UIColor+TTThemeExtension.h"
#import "NSDictionary+TTAdditions.h"
#import "UIImage+TTThemeExtension.h"
#import "TTPersistence.h"
#import "TTNetworkManager.h"
#import "NSDataAdditions.h"
#import "NSStringAdditions.h"
#import "SSZipArchive.h"
#import <TTAccountBusiness.h>
#import "NetworkUtilities.h"
#import "TTReachability.h"
#import "TTTabbar.h"
#import "TTTopBarManager.h"

#import "TTStringHelper.h"
#import "TTNetworkManager.h"
#import "Singleton.h"

#import "TTKitchenHeader.h"
#import "TTTabBarProvider.h"
#import "TTArticleTabBarController.h"
#import "UITabBarController+TabbarConfig.h"
#import "TTSettingsManager.h"
#import <Lottie/Lottie.h>
#import "TTTabBarCustomMiddleModel.h"

NSString *kTTTabBarZipDownloadSuccess = @"kTTTabBarZipDownloadSuccess";

//服务端下发的tab标题key 且是 服务端下发的tab图片名
NSString *kTTTabHomeTabKey = @"tab_stream"; //首页tab 标题key&图片名
NSString *kTTTabVideoTabKey = @"tab_video"; //视频tab 标题key&图片
NSString *kTTTabFollowTabKey = @"tab_topic"; //关注tab 标题key&图片
NSString *kTTTabMineTabKey = @"tab_mine"; //我的tab 图片&标题key
NSString *kTTTabWeitoutiaoTabKey = @"tab_weitoutiao"; //微头条tab 图片&标题key
NSString *kTTTabHTSTabKey = @"tab_huoshan";//火山小视频tab 标题&图片名
NSString *kTTTabActivityTabKey = @"tab_activity"; //常驻运营活动tab 标题&图片名
NSString *kTTTabUnloginName = @"ak_mine_unlogin_tab"; //我的tab未登录图片
NSString *kTTTabFeedPublishName = @"feed_publish"; //feed发布器图片
NSString *kTTTabBigActivityTabKey = @"tab_redpackage_big"; //春节运营活动大tab 标题&图片名
NSString *kAKTabActivityTabKey = @"tab_ak_activity";//爱看活动tab 标题key&图片名
NSString *kFHouseFindTabKey = @"tab_f_find";//房产找房key
NSString *kFHouseMessageTabKey = @"tab_message";
NSString *kFHouseMineTabKey = @"tab_f_mine"; //房产首页key
//Path
static NSString *kTTTabConfigurationPath = @"tabbar/configuration"; //tab配置信息存储路径
static NSString *kTTTabImagesPath = @"tabbar/images"; //tab图片资源路径
static NSString *kTTTabLottiePath = @"%@_lottie"; //tab图片资源路径

//Key
static NSString *const kTTTabBarConfigKey = @"kTTTabBarConfigKey"; //tabbar配置信息
static NSString *const kTTFollowHeaderTextKey = @"kTTFollowHeaderTextKey"; //关注页标题
static NSString *const kTTTabBarImagesDownloadKey = @"kTTTabBarImagesDownloadKey"; //tabbar图片资源是否已经下载
static NSString *kTTTabConfigurationName = @"tab_configuration.zip"; //tabbar图片资源zip文件

static NSString *kTTTabRefreshName = @"refresh"; //刷新图片
static NSString *kTTTabBackgroundName = @"tab_background"; //tabbar背景图片


static NSString *kTTTabCustomHighlightedSuffix = @"_pressed";
static NSString *kTTTabDefaultHighlightedSuffix = @"_press";
static NSString *kTTTabNightSuffix = @"_night";

@interface TTTabBarImageModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL isDefaultImage;

@end

@implementation TTTabBarImageModel

@end

@interface TTTabBarImageList : NSObject

@property (nonatomic, strong) NSDictionary<NSString *, TTTabBarImageModel *> * normalItems;

@property (nonatomic, strong) TTTabBarImageModel *refreshItem;
@property (nonatomic, strong) TTTabBarImageModel *unloginItem;
@property (nonatomic, strong) TTTabBarImageModel *backgroundItem;
@property (nonatomic, strong) TTTabBarImageModel *publishItem;
@property (nonatomic, strong) TTTabBarImageModel *middleButtonItem;

@end

@implementation TTTabBarImageList

@end

@interface TTTabBarManager ()

@property (nonatomic, strong, readwrite) NSArray<TTTabBarItem *> * tabItems; //tabbar上4个tab的tab items list
@property (nonatomic, strong, readwrite) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, strong, readwrite) NSArray<NSString *> *tabTags;
@property (nonatomic, assign) BOOL isSingleConfigValid; //单独配置是否生效(不考虑和topBar联动)
@property (nonatomic, strong) NSNumber *tabConfigValid; //整个tab配置是否有效(考虑和topBar联动)
@property (nonatomic, strong) NSSet<NSString *> *imageFileNames; //所有资源包里的文件名

@property (nonatomic, strong) NSDictionary *dict; //tabbar配置信息

@property (nonatomic, strong) NSSet <NSString *> * allTabKey; //tabbar所有可能的tab key

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> * defaultItemTitles; //tabbar默认tab标题
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> * defaultImageNames; //tabbar默认tab图片名
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> * itemTitles; //tabbar所有可能用到的tab标题（可能同时包含服务端配置的和本地默认的）
@property (nonatomic, strong) TTTabBarImageList *imageList; //tabbar所有可能用到的图片资源（normalItems中包可能同时包含服务端配置的和本地默认的）

@property (nonatomic, assign) BOOL isUnloginImageInvalid; //未登录图片是否非法
@property (nonatomic, assign) BOOL isRefreshImageInvalid; //刷新图片是否非法
@property (nonatomic, assign) BOOL isBackgroundImageInvalid; //背景图片是否非法
@property (nonatomic, assign) BOOL isFeedPublicImageInvalid; //tab上发布器图片是否非法

@property (nonatomic, strong, readwrite) NSString *followHeaderText; //关注页头部文案

@property (nonatomic, strong, readwrite) TTTabBarCustomMiddleModel *middleModel;
@property (nonatomic, strong, readwrite) SSThemedButton *customMiddleButton;
@property (nonatomic, strong, readwrite) LOTAnimationView *lottieView;

@property (nonatomic, strong, readwrite) dispatch_group_t completionGroup;
@property (nonatomic, strong, readwrite) dispatch_queue_t completionQueue;

@property (atomic, assign) BOOL isFetching;

@end

@implementation TTTabBarManager

#pragma mark - Life cycle

SINGLETON_GCD(TTTabBarManager);

- (instancetype)init {
    if (self = [super init]) {
        [self setupDefaultProperties];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topBarSuccess:) name:kTTTopBarZipDownloadSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        [self retryDonwloadZipFileIfNeed];
        [self cleanExpiredImagesIfNeed];
    }
    return self;
}

- (void)setupDefaultProperties {
    _completionQueue = dispatch_queue_create("com.bytedance.tabbar", DISPATCH_QUEUE_SERIAL);
    _dict = [[TTPersistence persistenceWithName:kTTTabConfigurationPath] valueForKey:kTTTabBarConfigKey];
    if (![_dict isKindOfClass:[NSDictionary class]]) {
        _dict = nil;
    }
    
    _allTabKey = [NSSet setWithObjects:
                  kTTTabHomeTabKey,
//                  kTTTabVideoTabKey,
//                  kTTTabFollowTabKey,
//                  kTTTabMineTabKey,
//                  kTTTabWeitoutiaoTabKey,
//                  kTTTabHTSTabKey,
//                  kTTTabBigActivityTabKey,
//                  kAKTabActivityTabKey,
                  kFHouseMineTabKey,
                  kFHouseMessageTabKey,
                  kFHouseFindTabKey,
                  nil];
    _defaultItemTitles = @{kTTTabHomeTabKey:@"首页",
                           kTTTabVideoTabKey:@"视频",
//                           kAKTabActivityTabKey:@"任务",
                           kTTTabHTSTabKey:@"小视频",
//                           kTTTabFollowTabKey:@"关注",
                           kFHouseMessageTabKey: @"消息",
                           kFHouseMineTabKey:@"我的",
                           kFHouseFindTabKey:@"找房",

//                           kTTTabWeitoutiaoTabKey:[KitchenMgr getString:kKCUGCFeedNamesTab],
                           };
    
    _defaultImageNames = @{kTTTabHomeTabKey:@"tab-home",
//                           kTTTabVideoTabKey:@"video_tabbar",
//                           kTTTabFollowTabKey:@"newcare_tabbar",
//                           kTTTabMineTabKey:@"mine_tabbar",
//                           kTTTabWeitoutiaoTabKey:@"weitoutiao_tabbar",
//                           kAKTabActivityTabKey:@"ak_activity_tab",
                           kFHouseMessageTabKey: @"tab-message",
                           kFHouseMineTabKey: @"tab-mine",
                           kFHouseFindTabKey: @"tab-search",

//                           kTTTabHTSTabKey:@"huoshan_tabbar",
                           };
    
    _isUnloginImageInvalid = NO;
    _isRefreshImageInvalid = NO;
    _isBackgroundImageInvalid = NO;
    _isFeedPublicImageInvalid = NO;
    _isFetching = NO;
    
    [self refreshData];
    [self resetToDefualtIfNeed];
}

- (void)refreshData {
    _itemTitles = [self tabTitles];
    
    [self setupMiddleModel];
    
    _imageList = [self tabBarItemImageList];
    
    _isSingleConfigValid = [self isTabConfigurationValid];
}

- (void)setupMiddleModel {
    //中间已经有第五个tab的时候不更新
    if (self.tabItems.count >= 5 && [TTTabBarProvider hasCustomMiddleButton]) {
        return;
    }

    _middleModel = [[TTTabBarCustomMiddleModel alloc] init];

    NSString *identifier = [TTTabBarProvider priorMiddleTabIdentifier];
    _middleModel.originalIdentifier = identifier;
    _middleModel.text = [[self.dict tt_dictionaryValueForKey:@"text"] tt_stringValueForKey:identifier];
    if (!isEmptyString(identifier)) {
        _middleModel.identifier = !isEmptyString(_middleModel.text) ? identifier : [identifier stringByAppendingString:@"_big"];
    } else {
        _middleModel.identifier = nil;
    }
    _middleModel.schema = [TTTabBarProvider priorMiddleTabSchema];
    
    NSDictionary *tabListConfig = [[TTSettingsManager sharedManager] settingForKey:@"tt_tab_list_config" defaultValue:@{@"middle_tab":@{}} freeze:NO];
    NSDictionary *middleTabConfig = [tabListConfig tt_dictionaryValueForKey:@"middle_tab"];

    _middleModel.isExpand = NO;
    _middleModel.useLottieFirst = [middleTabConfig tt_boolValueForKey:@"use_lottie_first"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Method

- (TTTabBarItem *)tabItemWithIdentifier:(NSString *)idenfitier
{
    for (NSInteger i = 0; i< self.tabItems.count; i += 1) {
        TTTabBarItem *item = self.tabItems[i];
        if ([item.identifier isEqualToString:idenfitier]) {
            return item;
        }
    }
    return nil;
}

- (void)setTabBarSettingsDict:(NSDictionary *)dict {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *cachedDict = [[TTPersistence persistenceWithName:kTTTabConfigurationPath] valueForKey:kTTTabBarConfigKey];
        if (![dict isKindOfClass:[NSDictionary class]]) {
            return;
        }
        if ([dict tt_longlongValueForKey:@"version"] > [cachedDict tt_longlongValueForKey:@"version"]) {
            LOGD(@"TTTabBar 版本号变化，开始更新!!!，当前版本%lld,更新版本%lld",[cachedDict tt_longlongValueForKey:@"version"],[dict tt_longlongValueForKey:@"version"]);
            TTPersistence *persistence = [TTPersistence persistenceWithName:kTTTabConfigurationPath];
            [persistence setValue:dict forKey:kTTTabBarConfigKey];
            if (!isEmptyString([dict tt_stringValueForKey:@"url"])) {
                //需要下载图片资源
                [persistence setValue:@(NO) forKey:kTTTabBarImagesDownloadKey];
                dispatch_async(self.completionQueue, ^{
                    self.completionGroup = dispatch_group_create();
                    dispatch_group_enter(self.completionGroup);
                    if ([SSCommonLogic homepageUIConfigSimultaneouslyValid]) {
                        dispatch_group_enter(self.completionGroup);
                    }
                    dispatch_group_notify(self.completionGroup, dispatch_get_main_queue(), ^{
                        [self immediatelyValidSurfaceWithDict:dict];
                    });
                    [self tryFetchZipFileWithURL:[dict tt_stringValueForKey:@"url"]];
                });
            }else {
                //不需要下载图片资源，则认为图片已经下载好了
                [persistence setValue:@(YES) forKey:kTTTabBarImagesDownloadKey];
                [self immediatelyValidSurfaceWithDict:dict];
            }
            [persistence save];
        } else {
            LOGD(@"TTTabBar 版本号不变，无需更新!!!");
        }
    });
}

- (void)reloadIconAndTitleForItem:(TTTabBarItem *)item {
    //设置标题
    [self setTabTitleForItem:item];
    //设置图片
    [self setTabImageForItem:item];
    //设置动图
    [self setLottieViewForItem:item];
}

- (void)reloadThemeForTabbar:(TTTabbar *)tabBar style:(NSString *)style {
    [tabBar.tabItems enumerateObjectsUsingBlock:^(TTTabBarItem *item, NSUInteger idx, BOOL *stop) {
        //设自定义的文字颜色
        if (self.tabConfigValid.boolValue && self.customTextColorArray.count == 4) {
            item.normalTitleColor = self.customNormalColor;
            item.highlightedTitleColor = self.customHighlightedColor;
            item.ttBadgeView.backgroundColorThemeKey = nil;
            if (self.customHighlightedColor) {
                [item.ttBadgeView setValue:self.customHighlightedColor forKey:@"badgeBackgroundColor"];
            }
        } else {
            item.normalTitleColor = [UIColor tt_themedColorForKey:@"TabBarTitleColor"];
            item.highlightedTitleColor = [UIColor colorWithHexString:@"#299cff"];
//            item.highlightedTitleColor = [UIColor tt_themedColorForKey:@"TabBarTitleHighlightedColor"];
            item.ttBadgeView.backgroundColorThemeKey = kColorBackground7;
        }
        
        //设自定义的小红点位置
        if (self.tabConfigValid.boolValue) {
            item.ttBadgeOffsetV = self.badgeOffset / 2.f;
        }
        
        //设自定义的图片
        [self reloadIconAndTitleForItem:item];
        
    }];
    
    if (!self.imageList.backgroundItem.isDefaultImage) {
        UIImage *bgImage = [self getImageForItem:self.imageList.backgroundItem isHighlighted:NO];
        //直接用tabbar的setBackgroundImage方法会让背景变透明
        [tabBar setCustomBackgroundImage:bgImage];
    } else {
        [tabBar setCustomBackgroundImage:nil];
        //iOS7 后就简单多了 有图用图 没图用颜色
        if ([UIColor tt_themedColorForKey:[NSString stringWithFormat:@"TabBarBackground%@",style]]) {
            
            [tabBar setBarTintColor:[UIColor tt_themedColorForKey:[NSString stringWithFormat:@"TabBarBackground%@",style]]];
            
        }
        else{
            [tabBar setBarTintColor:nil];
            
            if ([UIImage tt_themedImageForKey:[NSString stringWithFormat:@"TabBarBackground%@",style]]) {
                
                [tabBar setBackgroundImage:[UIImage tt_themedImageForKey:[NSString stringWithFormat:@"TabBarBackground%@",style]]];
            }
        }
    }
}

- (void)setPublishButton:(UIButton *)publishButton themeMode:(TTThemeMode)themeMode {
    if (publishButton && [publishButton isKindOfClass:[UIButton class]]) {
        [publishButton setImage:[self getImageForItem:self.imageList.publishItem isHighlighted:NO] forState:UIControlStateNormal];
        [publishButton setImage:[self getImageForItem:self.imageList.publishItem isHighlighted:YES] forState:UIControlStateHighlighted];
    }
}

- (NSString *)getItemTitleForIndex:(NSUInteger)itemIndex {
    if (itemIndex >= self.itemTitles.count) {
        return nil;
    }
    return [_itemTitles tt_stringValueForKey:[self tabKeyForReallyTabIndex:itemIndex]];
}

- (UIImage *)getItemImageForIndex:(NSUInteger)itemIndex isHighlighted:(BOOL)isHighlighted {
    TTTabBarImageModel *imageItem = [self.imageList.normalItems objectForKey:[self tabKeyForReallyTabIndex:itemIndex]];
    UIImage *image = [self getImageForItem:imageItem isHighlighted:isHighlighted];
    return image;
}

- (void)registerTabBarforIndentifier:(NSString *)identifier atIndex:(NSUInteger)index isRegular:(BOOL)isRegular {
    if ([self.tabTags containsObject:identifier]) {
        return;
    }
    
    BOOL needReplace = NO;
    
    if (self.tabTags.count == 5 && index == 2) {
        needReplace = YES;
    }
    
    //tags modify fist because other states denpends on this
    NSMutableArray *tagsArray = [NSMutableArray array];
    [tagsArray addObjectsFromArray:self.tabTags];
    if (!isEmptyString(identifier) && index <= self.tabItems.count) {
        if (needReplace) {
            [tagsArray replaceObjectAtIndex:index withObject:identifier];
        } else {
            [tagsArray insertObject:identifier atIndex:index];
        }
    }
    self.tabTags = [tagsArray copy];
    
    UINavigationController *naviVC = [TTTabBarProvider naviVCForIdentifier:identifier];
    TTTabBarItem *item = [[TTTabBarItem alloc] initWithIdentifier:identifier viewController:naviVC index:index isRegular:isRegular];
    item.titleFont = [UIFont systemFontOfSize:10.f];
    
    NSMutableArray *ItemsArray = [NSMutableArray array];
    NSMutableArray *VCsArray = [NSMutableArray array];
    
    [ItemsArray addObjectsFromArray:self.tabItems];
    [VCsArray addObjectsFromArray:self.viewControllers];
    
    if (item && index <= self.tabItems.count) {
        if (needReplace) {
            [ItemsArray replaceObjectAtIndex:index withObject:item];
            [VCsArray replaceObjectAtIndex:index withObject:item.viewController];
        } else {
            [ItemsArray insertObject:item atIndex:index];
            [VCsArray insertObject:item.viewController atIndex:index];
        }
    }
    
    self.tabItems = [ItemsArray copy];
    self.viewControllers = [VCsArray copy];
    
    //加载文案和图片
    [self reloadIconAndTitleForItem:item];
}

- (void)updateItemState:(BOOL)freeze withIdentifier:(NSString *)identifier
{
    TTTabBarItem *thisItem = nil;
    for (TTTabBarItem *item in [TTTabBarManager sharedTTTabBarManager].tabItems) {
        if ([item.identifier isEqualToString:identifier]) {
            thisItem = item;
            break;
        }
    }
    
    if (freeze) {
        if (!thisItem || (thisItem && thisItem.freezed)) {
            return;
        }
        thisItem.freezed = YES;
    } else {
        if (thisItem && !thisItem.freezed) {
            return;
        }
        thisItem.freezed = NO;
    }
    
    TTArticleTabBarController *rootVC = (TTArticleTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [rootVC updateTabBarControllerWithAutoJump:freeze];
}

- (void)updateTabTags:(NSArray *)tabTags
{
    self.tabTags = [tabTags copy];
}

#pragma mark - Configuration

- (NSNumber *)tabConfigValid {
    if (!_tabConfigValid) {
        [self updateTabConfigValid];
    }
    return _tabConfigValid;
}

- (void)updateTabConfigValid {
    BOOL isValid = NO;
    if (![SSCommonLogic homepageUIConfigSimultaneouslyValid]) {
        isValid = self.isSingleConfigValid;
    } else {
        isValid = self.isSingleConfigValid && [TTTopBarManager sharedInstance_tt].isSigleConfigValid;
    }
    _tabConfigValid = [NSNumber numberWithBool:isValid];
}

- (NSDictionary<NSString *, NSString *> *)tabTitles {
    NSMutableDictionary <NSString *, NSString *> * mutableTabTitles = [NSMutableDictionary dictionary];
    NSDictionary <NSString *, NSString *> * customTabTitles = [self.dict tt_dictionaryValueForKey:@"text"];
    
    [_allTabKey enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString * title = [customTabTitles tt_stringValueForKey:obj];
        if (isEmptyString(title) || title.length > 5) {
            //活动大Tab可以没有文案只有图片，这里特殊处理一下
            if (isEmptyString(title) && [obj isEqualToString:kTTTabActivityTabKey]) {
            } else {
                //标题不符合预期，使用默认标题
                title = [_defaultItemTitles tt_stringValueForKey:obj];
            }
        }
        
        if ([obj isEqualToString:kTTTabWeitoutiaoTabKey]) {
            //微头条的底tab标题由微头条文案下发逻辑控制
            title = [KitchenMgr getString:kKCUGCFeedNamesTab];
        }
        [mutableTabTitles setValue:title forKey:obj];
    }];
    
    return mutableTabTitles.copy;
}

- (TTTabBarImageList *)tabBarItemImageList {
    TTTabBarImageList *imageList = [[TTTabBarImageList alloc] init];
    NSMutableDictionary <NSString *, TTTabBarImageModel *> * imageNames = [NSMutableDictionary dictionary];
    
    NSString * imagePath = [[NSString stringWithFormat:@"%@/%lld",kTTTabImagesPath, [self.dict tt_longlongValueForKey:@"version"]] stringDocumentsPath];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:imagePath];
    
    //构建tab所需要的图片
    NSMutableSet <NSString *> * imageFileNames = [NSMutableSet set];
    for (NSString * fileName in enumerator) {
        NSString *fixedName = [fileName stringByDeletingPathExtension];
        if (!isEmptyString(fixedName)) {
            [imageFileNames addObject:fixedName];
        }
    }
    
    self.imageFileNames = [imageFileNames copy];
    
    [_allTabKey enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        TTTabBarImageModel * model = [[TTTabBarImageModel alloc] init];
        NSString * customNormalImageName = obj; //日间图
        NSString * customNightImageName = [obj stringByAppendingString:kTTTabNightSuffix]; //夜间图
        NSString * customNormalPressImageName = [obj stringByAppendingString:kTTTabCustomHighlightedSuffix]; //日间点击高亮图
        NSString * customNightPressImageName = [obj stringByAppendingString:[NSString stringWithFormat:@"%@%@", kTTTabNightSuffix, kTTTabCustomHighlightedSuffix]]; //夜间点击高亮图
        
        if ([imageFileNames containsObject:customNormalImageName]
            && [imageFileNames containsObject:customNightImageName]
            && [imageFileNames containsObject:customNormalPressImageName]
            && [imageFileNames containsObject:customNightPressImageName]) {
            //服务端下发了该tab的图片并且本地下载好四张配套的图
            model.name = obj;
            model.isDefaultImage = NO;
        }else {
            model.name = [_defaultImageNames tt_stringValueForKey:obj];
            model.isDefaultImage = YES;
        }
        [imageNames setValue:model forKey:obj];
    }];
    
    imageList.normalItems = imageNames;
    
    //未登录第四个tab
    NSString * unloginNormalImageName = kTTTabUnloginName;
    NSString * unloginNightImageName = [kTTTabUnloginName stringByAppendingString:kTTTabNightSuffix];
    NSString * unloginNormalPressImageName = [kTTTabUnloginName stringByAppendingString:kTTTabCustomHighlightedSuffix];
    NSString * unloginNightPressImageName = [kTTTabUnloginName stringByAppendingString:[NSString stringWithFormat:@"%@%@", kTTTabNightSuffix, kTTTabCustomHighlightedSuffix]];
    
    if (![imageFileNames containsObject:unloginNormalImageName]
        || ![imageFileNames containsObject:unloginNightImageName]
        || ![imageFileNames containsObject:unloginNormalPressImageName]
        || ![imageFileNames containsObject:unloginNightPressImageName]) {
        self.isUnloginImageInvalid = YES;
    } else {
        self.isUnloginImageInvalid = NO;
    }
    
    TTTabBarImageModel *unloginImageModel = [[TTTabBarImageModel alloc] init];
    if (!self.isUnloginImageInvalid) {
        unloginImageModel.name = kTTTabUnloginName;
        unloginImageModel.isDefaultImage = NO;
    } else {
        unloginImageModel.name = @"ak_mine_unlogin_tab";
        unloginImageModel.isDefaultImage = YES;
    }
    imageList.unloginItem = unloginImageModel;

    //刷新图
    NSString * refreshNormalImageName = kTTTabRefreshName;
    NSString * refreshNightImageName = [kTTTabRefreshName stringByAppendingString:kTTTabNightSuffix];
    
    if (![imageFileNames containsObject:refreshNormalImageName]
        || ![imageFileNames containsObject:refreshNightImageName]) {
        self.isRefreshImageInvalid = YES;
    } else {
        self.isRefreshImageInvalid = NO;
    }
    
    TTTabBarImageModel *refreshImageModel = [[TTTabBarImageModel alloc] init];
    if (!_isRefreshImageInvalid) {
        refreshImageModel.name = kTTTabRefreshName;
        refreshImageModel.isDefaultImage = NO;
    } else {
        refreshImageModel.name = @"refresh_tabbar_press";
        refreshImageModel.isDefaultImage = YES;
    }
    imageList.refreshItem = refreshImageModel;
    
    //背景图片
    NSString * backgroundNormalImageName = kTTTabBackgroundName;
    NSString * backgroundNightImageName = [kTTTabBackgroundName stringByAppendingString:kTTTabNightSuffix];
    if (![imageFileNames containsObject:backgroundNormalImageName]
        || ![imageFileNames containsObject:backgroundNightImageName]) {
        self.isBackgroundImageInvalid = YES;
    } else {
        self.isBackgroundImageInvalid = NO;
    }
    
    TTTabBarImageModel *backgroundModel = [[TTTabBarImageModel alloc] init];
    if (!_isBackgroundImageInvalid) {
        backgroundModel.name = kTTTabBackgroundName;
        backgroundModel.isDefaultImage = NO;
    } else {
        backgroundModel.name = nil;
        backgroundModel.isDefaultImage = YES;
    }
    imageList.backgroundItem = backgroundModel;
    
    //发布器图片
    NSString * feedPublishNormalImageName = kTTTabFeedPublishName;
    NSString * feedPublishNightImageName = [kTTTabFeedPublishName stringByAppendingString:kTTTabNightSuffix];
    NSString * feedPublishNormalPressImageName = [kTTTabFeedPublishName stringByAppendingString:kTTTabCustomHighlightedSuffix];
    NSString * feedPublishNightPressImageName = [kTTTabFeedPublishName stringByAppendingString:[NSString stringWithFormat:@"%@%@", kTTTabNightSuffix, kTTTabCustomHighlightedSuffix]];
    if (![imageFileNames containsObject:feedPublishNormalImageName]
        || ![imageFileNames containsObject:feedPublishNightImageName]
        || ![imageFileNames containsObject:feedPublishNormalPressImageName]
        || ![imageFileNames containsObject:feedPublishNightPressImageName]) {
        self.isFeedPublicImageInvalid = YES;
    } else {
        self.isFeedPublicImageInvalid = NO;
    }
    
    TTTabBarImageModel *feedPublishModel = [[TTTabBarImageModel alloc] init];
    if (!_isFeedPublicImageInvalid) {
        feedPublishModel.name = kTTTabFeedPublishName;
        feedPublishModel.isDefaultImage = NO;
    }else {
        feedPublishModel.name = @"feed_publish";
        feedPublishModel.isDefaultImage = YES;
    }
    imageList.publishItem = feedPublishModel;
    
    //中间Button
    BOOL isMiddleButtonImageDefault = NO;
    NSString * middleButtonNormalImageName = self.middleModel.identifier;
    NSString * middleButtonNightImageName = [self.middleModel.identifier stringByAppendingString:kTTTabNightSuffix];
    
    if (![imageFileNames containsObject:middleButtonNormalImageName]
        || ![imageFileNames containsObject:middleButtonNightImageName]) {
        isMiddleButtonImageDefault = YES;
    }
    
    TTTabBarImageModel *middleButtonImageModel = [[TTTabBarImageModel alloc] init];
    if (!isMiddleButtonImageDefault) {
        middleButtonImageModel.name = self.middleModel.identifier;
        middleButtonImageModel.isDefaultImage = NO;
    } else {
        middleButtonImageModel.name = @"tab_activity_big";
        middleButtonImageModel.isDefaultImage = YES;
    }
    imageList.middleButtonItem = middleButtonImageModel;
    
    return imageList;
}

- (NSString *)unLoginText {
    return [self.dict tt_stringValueForKey:@"unlogin_text"];
}

- (NSArray<NSString *> *)customTextColorArray {
    return [self.dict tt_arrayValueForKey:@"tab_text_color"];
}

- (NSTimeInterval)startTime {
    return [self.dict tt_doubleValueForKey:@"start_time"];
}

- (NSTimeInterval)endTime {
    return [self.dict tt_doubleValueForKey:@"end_time"];
}

- (CGFloat)badgeOffset {
    return [self.dict floatValueForKey:@"badge_offset" defaultValue:MAXFLOAT];
}

#pragma mark - Private Method

- (void)setTabTitleForItem:(TTTabBarItem *)item {
    if (![[TTTabBarManager sharedTTTabBarManager].tabItems containsObject:item]) {
        return;
    }
    NSString *title = [self.itemTitles tt_stringValueForKey:item.identifier];
    
    if ([item.identifier isEqualToString:kTTTabMineTabKey] && ![TTAccountManager isLogin] && [TTTabBarProvider isMineTabOnTabBar]) {
        if (self.tabConfigValid.boolValue && [self isUnloginTextValid]) {
            title = [self unLoginText];
        } else {
            title = NSLocalizedString(@"未登录", nil);
        }
    }
    
    if (!item.isRegular) {
        NSString *normalImageName = self.middleModel.originalIdentifier;
        NSString *bigImageName = [normalImageName stringByAppendingString:@"_big"];
        BOOL normalIconValid = [self.imageFileNames containsObject:normalImageName] && [self.imageFileNames containsObject:[normalImageName stringByAppendingString:kTTTabNightSuffix]];
        BOOL bigIconValid = [self.imageFileNames containsObject:bigImageName] && [self.imageFileNames containsObject:[bigImageName stringByAppendingString:kTTTabNightSuffix]];
        //中间tab只有在<资源生效且没有大图>的时候有文案（因为默认是大图，不需要文案）
        if (!self.isSingleConfigValid || bigIconValid || !normalIconValid) {
            title = nil;
        }
    }
    
    //设置标题
    [item setTitle:title];
}

- (void)setTabImageForItem:(TTTabBarItem *)item {
    if (![[TTTabBarManager sharedTTTabBarManager].tabItems containsObject:item]) {
        return;
    }
    
    TTTabBarImageList *names = self.imageList;
    
    //不规则tab优先取xxx_big后缀的图片，取不到的话再用无big后缀的图片
    NSString *fixedIdetifier = item.isRegular ? item.identifier : [item.identifier stringByAppendingString:@"_big"];
    
    //正常态图片
    TTTabBarImageModel *normalImageItem = [names.normalItems objectForKey:fixedIdetifier];
    UIImage *normalImage = [self getImageForItem:normalImageItem isHighlighted:NO];
    //高亮图片
    UIImage *highlightedImage = [self getImageForItem:normalImageItem isHighlighted:YES];
    
    if ((!normalImage || !highlightedImage) && !item.isRegular) {
        //正常态图片
        normalImageItem = [names.normalItems objectForKey:item.identifier];
        normalImage = [self getImageForItem:normalImageItem isHighlighted:NO];
        //高亮图片
        highlightedImage = [self getImageForItem:normalImageItem isHighlighted:YES];
    }
    
    //刷新图片
    UIImage *refreshImage = nil;
    if ([item.identifier isEqualToString:kTTTabHomeTabKey]) {
        refreshImage = [self getImageForItem:names.refreshItem isHighlighted:NO];
    }
    
    //第四个tab是否有未登录的特殊图片而且文案和图片配对
    if ([item.identifier isEqualToString:kTTTabMineTabKey] && ![TTAccountManager isLogin] && [TTTabBarProvider isMineTabOnTabBar]) {
        normalImage =  [self getImageForItem:names.unloginItem isHighlighted:NO];
        highlightedImage = [self getImageForItem:names.unloginItem isHighlighted:YES];
    }
    
    [item setNormalImage:normalImage highlightedImage:highlightedImage loadingImage:refreshImage];
}

- (void)setLottieViewForItem:(TTTabBarItem *)item {
    if (!item.isRegular) {
        [self setupMiddleModel];
    }
    
    if (!item.isRegular && self.middleModel.useLottieFirst && !item.animationView) {
        NSString *lottileFolderName = [NSString stringWithFormat:kTTTabLottiePath,self.middleModel.originalIdentifier];
        NSString * lottiePath = [[NSString stringWithFormat:@"%@/%lld/%@",kTTTabImagesPath, [self.dict tt_longlongValueForKey:@"version"], lottileFolderName] stringDocumentsPath];
        
        self.lottieView = [self middleTabAnimatingViewInPath:lottiePath];
        if (self.lottieView) {
            item.animationView = self.lottieView;
            item.animationView.height = self.lottieView.height/3;
            item.animationView.width = self.lottieView.width/3;
        }
    }

    if (!item.isRegular) {
        if (self.lottieView) {
            //只有大图才可以拉伸，是否凸起与图片尺寸绑定
            if (ABS(self.lottieView.height - 64.f) < 4.f) {
                self.middleModel.isExpand = YES;
            } else {
                self.middleModel.isExpand = NO;
            }
        } else {
            TTTabBarImageModel *imageModel = self.imageList.middleButtonItem;
            UIImage *normalImage = [self getImageForItem:imageModel isHighlighted:NO];

            //只有大图才可以拉伸，是否凸起与图片尺寸绑定
            if (ABS(normalImage.size.height - 64.f) < 4.f) {
                self.middleModel.isExpand = YES;
            } else {
                self.middleModel.isExpand = NO;
            }
        }
    }
}

#pragma mark - Validation

- (BOOL)isCustomTextColorValid {
    return SSIsEmptyArray(self.customTextColorArray) || self.customTextColorArray.count == 4;
}

- (BOOL)isUnloginTextValid {
    return !isEmptyString([self unLoginText]) && [self unLoginText].length <=4;
}

//是否在有效时效内
- (BOOL)isCurrentDateValid {
    if (self.startTime <=0 || self.endTime <= 0) {
        return NO;
    }
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.startTime];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:self.endTime];
    NSDate *currentDate = [NSDate date];
    return [startDate compare:currentDate] != NSOrderedDescending && [currentDate compare:endDate] != NSOrderedDescending;
}

//下发配置是否有效
//1.自定义文字颜色有效
//2.在有效期内
//3.资源包下载成功
- (BOOL)isTabConfigurationValid {
    TTPersistence *persistence = [TTPersistence persistenceWithName:kTTTabConfigurationPath];
    BOOL imageDownLoadSuccess = [persistence valueForKey:kTTTabBarImagesDownloadKey] && ((NSNumber *)[persistence valueForKey:kTTTabBarImagesDownloadKey]).boolValue == YES;
    return [self isCustomTextColorValid] && [self isCurrentDateValid] && imageDownLoadSuccess;
}

//如果有任一tab文案和图片不成套则都置为默认
- (void)resetToDefualtIfNeed {
    if (!self.tabConfigValid.boolValue) {
        LOGD(@"TTTabBar 文案与图片资源不匹配！！！改变文案个数：%lu，改变图片个数%lu", (unsigned long)self.customTextKeySet.count, (unsigned long)self.customImageNameSet.count);
        [self.imageList.normalItems enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TTTabBarImageModel * _Nonnull obj, BOOL * _Nonnull stop) {
            if (NO == obj.isDefaultImage) {
                obj.name = [_defaultImageNames tt_stringValueForKey:key];
                obj.isDefaultImage = YES;
            }
        }];
        
        self.itemTitles = _defaultItemTitles;

        //未登录
        self.imageList.unloginItem.isDefaultImage = YES;
        self.imageList.unloginItem.name = @"ak_mine_unlogin_tab";
        //刷新图片
        self.imageList.refreshItem.isDefaultImage = YES;
        self.imageList.refreshItem.name = @"refresh_tabbar_press";
        //背景图片
        self.imageList.backgroundItem.isDefaultImage = YES;
        self.imageList.backgroundItem.name = nil;
        //发布器图片
        self.imageList.publishItem.isDefaultImage = YES;
        self.imageList.publishItem.name = @"feed_publish";
        //关注页头部标题
        self.followHeaderText = nil;
        
    } else {
        LOGD(@"配置成功");
        //只有下发配置有效而且关注tab有改动的时候，关注页头部标题生效
        if (!isEmptyString([self.dict tt_stringValueForKey:@"solicitude_tab_header_text"])) {
            self.followHeaderText = [self.dict tt_stringValueForKey:@"solicitude_tab_header_text"];
        } else {
            self.followHeaderText = nil;
        }
    }
}

#pragma mark - Notification

- (void)connectionChanged:(NSNotification *)notification {
    TTPersistence *persistence = [TTPersistence persistenceWithName:kTTTabConfigurationPath];
    if (((NSNumber *)[persistence valueForKey:kTTTabBarImagesDownloadKey]).boolValue == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
        return;
    }
    [self retryDonwloadZipFileIfNeed];
}

#pragma mark - Helper

- (NSString *)tabKeyForReallyTabIndex:(NSUInteger)tabIndex {
    if (tabIndex >= self.tabItems.count) {
        return nil;
    }
    
    return [self.tabItems objectAtIndex:tabIndex].identifier;
}

- (UIImage *)getImageForItem:(TTTabBarImageModel *)item isHighlighted:(BOOL)isHighlighted{
    UIImage *image = nil;
    if (item.isDefaultImage) {
        if (!isHighlighted) {
            image = [[UIImage themedImageNamed:item.name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else {
            image = [[UIImage themedImageNamed:[item.name stringByAppendingString:kTTTabDefaultHighlightedSuffix]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }
    else {
        NSString *fixedName = [[self class] themeImageNameByName:item.name];
        if (isHighlighted) {
            fixedName = [fixedName stringByAppendingString:kTTTabCustomHighlightedSuffix];
        }
        if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
            fixedName = [fixedName stringByAppendingString:@".png"];
        }
        NSString *fullPath = [[[NSString stringWithFormat:@"%@/%lld",kTTTabImagesPath, [self.dict tt_longlongValueForKey:@"version"]] stringDocumentsPath] stringByAppendingPathComponent:fixedName];
        image = [[UIImage imageWithContentsOfFile:fullPath] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image = [UIImage imageWithCGImage:image.CGImage scale:3 orientation:image.imageOrientation];
    }
    
    return image;
}

+ (NSString *)themeImageNameByName:(NSString *)name {
    NSString *fixedName = name;
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        NSMutableString *resultName = [NSMutableString stringWithString:fixedName];
        NSRange lastPoint = [resultName rangeOfString:@"." options:NSBackwardsSearch];
        if(lastPoint.location != NSNotFound) {
            [resultName insertString:kTTTabNightSuffix atIndex:lastPoint.location];
        } else {
            [resultName appendString:kTTTabNightSuffix];
        }
        fixedName = resultName;
    }
    return fixedName;
}

- (UIColor *)customNormalColor {
    return [UIColor colorWithDayColorName:[self.customTextColorArray objectAtIndex:0] nightColorName:[self.customTextColorArray objectAtIndex:1]];
}

- (UIColor *)customHighlightedColor {
    //f100 暂时去掉云控设置颜色
    return [UIColor colorWithHexString:@"#299cff"];
//    return [UIColor colorWithDayColorName:[self.customTextColorArray objectAtIndex:2] nightColorName:[self.customTextColorArray objectAtIndex:3]];
}

- (SSThemedButton *)customMiddleButton {
    if (isEmptyString(self.middleModel.identifier) || isEmptyString(self.middleModel.schema) ||
        ![self isCustomMiddleButtonValid]) {
        return nil;
    }
    
    if (!_customMiddleButton) {
        _customMiddleButton = [[SSThemedButton alloc] init];
        _customMiddleButton.adjustsImageWhenHighlighted = NO;
    
        [self updateMiddleButton];

        [_customMiddleButton addTarget:self
                                  action:@selector(showCustomMiddleButton:)
                        forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _customMiddleButton;
}

- (LOTAnimationView *)middleTabAnimatingViewInPath:(NSString *)path {
    LOTAnimationView *middleTabAnimatingView;
    NSString *fileName = [self.middleModel.originalIdentifier stringByAppendingString:@".json"];
    NSString *animationFileStr = [path stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:animationFileStr]) {
        return nil;
    }
    
    middleTabAnimatingView = [LOTAnimationView animationWithFilePath:animationFileStr];
    middleTabAnimatingView.loopAnimation = YES;
    middleTabAnimatingView.backgroundColor = [UIColor clearColor];
    [middleTabAnimatingView play];
    middleTabAnimatingView.userInteractionEnabled = NO;
    
    return middleTabAnimatingView;
}

- (BOOL)isCustomMiddleButtonValid {
    BOOL lessThanFive = self.tabItems.count < 5;
    
    return lessThanFive && [TTTabBarProvider hasCustomMiddleButton];
}

- (void)showCustomMiddleButton:(id)sender {
    if ([[TTRoute sharedRoute] canOpenURL:[NSURL URLWithString:self.middleModel.schema]]) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.middleModel.schema] userInfo:nil];
    }
}

# pragma mark - IO

- (void)tryFetchZipFileWithURL:(NSString *)urlString {
    if (isEmptyString(urlString) || self.isFetching) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.isFetching = YES;
        
        [[TTNetworkManager shareInstance] requestForBinaryWithURL:urlString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
            if (!error || error.code == TTNetworkErrorCodeSuccess) {
                if ([obj isKindOfClass:[NSData class]]) {
                    [self saveImageLists:obj];
                }
            } else {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
                });
            }
            
            self.isFetching = NO;
        }];
    });
}

- (void)saveImageLists:(NSData *)fileData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
        TTPersistence *persistence = [TTPersistence persistenceWithName:kTTTabConfigurationPath];
        NSDictionary *dict = [persistence valueForKey:kTTTabBarConfigKey];
        
        if(((NSNumber *)[persistence valueForKey:kTTTabBarImagesDownloadKey]).boolValue == YES) {
            return;
        }
        
        if ([[fileData md5String] isEqualToString:[dict tt_stringValueForKey:@"checksum"]]) {
            NSError *removeZipError = nil;
            
            NSString *unzipPath = [[NSString stringWithFormat:@"%@/%lld",kTTTabImagesPath, [dict tt_longlongValueForKey:@"version"]]stringDocumentsPath];
            NSFileManager *defaultManager = [NSFileManager defaultManager];
            //写入zip文件
            NSString * zipfile = [kTTTabConfigurationName stringDocumentsPath];
            [fileData writeToFile:zipfile atomically:YES];
            //解压文件 此处不能删除历史版本的图片，因为可能当前正在用
            [SSZipArchive unzipFileAtPath:zipfile toDestination:unzipPath];
            //删除zip文件
            if ([defaultManager fileExistsAtPath:zipfile]) {
                [defaultManager removeItemAtPath:zipfile error:&removeZipError];
            }
            
            if (!removeZipError) {
                [persistence setValue:@(YES) forKey:kTTTabBarImagesDownloadKey];
                [persistence save];
                LOGD(@"TTTabBar资源包下载成功");
                [TTSandBoxHelper disableBackupForPath:[kTTTabImagesPath stringDocumentsPath]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTTabBarImagesDownloadKey object:nil];
                
                dispatch_async(self.completionQueue, ^{
                    if (self.completionGroup) {
                        static dispatch_once_t onceToken;
                        dispatch_once(&onceToken, ^{
                            dispatch_group_leave(self.completionGroup);
                        });
                    }
                });
            }
        } else {
            LOGD(@"TTTabBar 资源包md5不匹配!!!");
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
            });
        }
    });
}

- (void)retryDonwloadZipFileIfNeed {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TTPersistence *persistence = [TTPersistence persistenceWithName:kTTTabConfigurationPath];
        if (((NSNumber *)[persistence valueForKey:kTTTabBarImagesDownloadKey]).boolValue == NO && TTNetworkConnected()) {
            NSDictionary *dict = [persistence valueForKey:kTTTabBarConfigKey];
            [self tryFetchZipFileWithURL:[dict tt_stringValueForKey:@"url"]];
        }
    });
}

- (void)cleanExpiredImagesIfNeed {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *folderPath = [kTTTabImagesPath stringDocumentsPath];
        NSArray *folderArray = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
        for (NSString * forderNameStr in folderArray) {
            NSString * sonForderPath = [folderPath stringByAppendingPathComponent:forderNameStr];
            BOOL isDirectory = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:sonForderPath isDirectory:&isDirectory];
            //比内存中版本号还小的文件夹中的图片资源清理
            if (isDirectory && forderNameStr.longLongValue < [self.dict tt_longlongValueForKey:@"version"]) {
                [[NSFileManager defaultManager] removeItemAtPath:sonForderPath error:nil];
            }
        }
    });
}

- (void)themeChanged:(NSNotification *)notification {
    if (self.customMiddleButton) {
        [self updateMiddleButton];
    }
    if (self.lottieView && !self.lottieView.isAnimationPlaying) {
        [self.lottieView play];
    }
}

- (void)updateMiddleButton {
    [self updateMiddleButtonLayout];
    [self updateCustomMiddleButtonPattern];
}

- (void)updateMiddleButtonLayout {
    NSUInteger count = [TTTabBarManager sharedTTTabBarManager].tabItems.count + 1;
    CGFloat buttonWidth = [UIScreen mainScreen].bounds.size.width/count;
    
    if (!self.middleModel.useLottieFirst) {
        [self checkNonLottieExpand];
    } else {
        [self checkLottieExpand];
    }
    
    if (self.middleModel.isExpand) {
        _customMiddleButton.size = CGSizeMake(buttonWidth, 64.f);
    } else {
        [self setupNonExpandLayout];
    }
}

- (void)checkNonLottieExpand {
    TTTabBarImageModel *imageModel = self.imageList.middleButtonItem;
    UIImage *normalImage = [self getImageForItem:imageModel isHighlighted:NO];
    
    //只有大图才可以拉伸，是否凸起与图片尺寸绑定
    if (ABS(normalImage.size.height - 64.f) < 4.f) {
        self.middleModel.isExpand = YES;
    } else {
        self.middleModel.isExpand = NO;
    }
    
    if (self.lottieView) {
        [self.lottieView removeFromSuperview];
        self.lottieView = nil;
    }
}

- (void)checkLottieExpand {
    NSString *lottileFolderName = [NSString stringWithFormat:kTTTabLottiePath,self.middleModel.originalIdentifier];
    NSString * lottiePath = [[NSString stringWithFormat:@"%@/%lld/%@",kTTTabImagesPath, [self.dict tt_longlongValueForKey:@"version"], lottileFolderName] stringDocumentsPath];
    
    if (!self.lottieView) {
        self.lottieView = [self middleTabAnimatingViewInPath:lottiePath];
        if (self.lottieView) {
            self.lottieView.height = self.lottieView.height/3;
            self.lottieView.width = self.lottieView.width/3;
            
            //只有大图才可以拉伸，是否凸起与图片尺寸绑定
            if (ABS(self.lottieView.height - 64.f) < 4.f) {
                self.middleModel.isExpand = YES;
            } else {
                self.middleModel.isExpand = NO;
            }
        } else {
            [self checkNonLottieExpand];
        }
    }
}

- (void)setupNonExpandLayout {
    NSUInteger count = [TTTabBarManager sharedTTTabBarManager].tabItems.count + 1;
    CGFloat buttonWidth = [UIScreen mainScreen].bounds.size.width/count;
    TTTabBarItem *item = [[TTTabBarManager sharedTTTabBarManager].tabItems lastObject];
    
    self.customMiddleButton.size = CGSizeMake(buttonWidth, 44.f);
    
    if (!self.middleModel.useLottieFirst) {
        //用大图就不出文案
        NSString *normalImageName = self.middleModel.originalIdentifier;
        BOOL normalIconValid = [self.imageFileNames containsObject:normalImageName] && [self.imageFileNames containsObject:[normalImageName stringByAppendingString:kTTTabNightSuffix]];
        if (normalIconValid && self.isSingleConfigValid) {
            [_customMiddleButton setTitle:self.middleModel.text forState:UIControlStateNormal];
        }
        [_customMiddleButton setTitleColor:item.normalTitleColor forState:UIControlStateNormal];
        [_customMiddleButton.titleLabel setFont:item.titleFont];
    } else {
        if (self.lottieView) {
            self.lottieView.centerX = CGRectGetWidth(self.customMiddleButton.bounds)/2;
            self.lottieView.centerY = CGRectGetHeight(self.customMiddleButton.bounds)/2;
        }
    }
}

- (void)updateCustomMiddleButtonPattern {
    if (self.middleModel.useLottieFirst) {
        if (self.lottieView) {
            UIView *lottieView = [self.customMiddleButton viewWithTag:20001];
            
            if (lottieView != self.lottieView) {
                [lottieView removeFromSuperview];
                [self.customMiddleButton addSubview:self.lottieView];
                self.lottieView.tag = 20001;
            }
            
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
                self.lottieView.alpha = 1.f;
            } else {
                self.lottieView.alpha = 0.5f;
            }
            [self.customMiddleButton setImage:nil forState:UIControlStateNormal];
            [self.customMiddleButton setImage:nil forState:UIControlStateHighlighted];
        } else {
            //没有lottie用普通默认图
            [self updateCustomMiddleButtonImage];
        }
    } else {
        [self updateCustomMiddleButtonImage];
    }
}

- (void)topBarSuccess:(NSNotification *)notification {
    dispatch_async(self.completionQueue, ^{
        if (![SSCommonLogic homepageUIConfigSimultaneouslyValid]) {
            return;
        }
        
        if (self.completionGroup) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                dispatch_group_leave(self.completionGroup);
            });
        }
    });
}

- (void)enterForeground:(NSNotification *)notification {
    if (!self.lottieView.isAnimationPlaying) {
        [self.lottieView play];
    }
}

- (void)immediatelyValidSurfaceWithDict:(NSDictionary *)dict {
    self.dict = dict;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self refreshData];
        [self updateTabConfigValid];
        [self resetToDefualtIfNeed];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow * mainWindow = [[UIApplication sharedApplication] keyWindow];
            if ([mainWindow.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
                TTArticleTabBarController *tabbarVC = (TTArticleTabBarController *)mainWindow.rootViewController;
                if([tabbarVC.tabBar isKindOfClass:[TTTabbar class]]){
                    //refresh lottieView
                    [self refreshLottieView];
                    
                    [tabbarVC reloadTheme];
                    if (self.customMiddleButton) {
                        [self updateMiddleButton];
                    }
                    
                    TTTabbar *tabbar = (TTTabbar *)tabbarVC.tabBar;
                    tabbar.middleCustomItemView = self.customMiddleButton;
                }
            }
            dispatch_async(self.completionQueue, ^{
                self.completionGroup = NULL;
            });
        });
    });
}

- (void)updateCustomMiddleButtonImage {
    TTTabBarImageModel *imageModel = self.imageList.middleButtonItem;
    
    UIImage *normalImage = [self getImageForItem:imageModel isHighlighted:NO];
    [self.customMiddleButton setImage:normalImage forState:UIControlStateNormal];
    
    UIImage *highlightedImage = [self getImageForItem:imageModel isHighlighted:YES];
    [self.customMiddleButton setImage:highlightedImage ?: normalImage forState:UIControlStateHighlighted];
    
    CGSize imageSize = _customMiddleButton.imageView.frame.size;
    CGSize titleSize = _customMiddleButton.titleLabel.frame.size;
    NSUInteger totalHeight = imageSize.height + titleSize.height;
    
    self.customMiddleButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.customMiddleButton.imageEdgeInsets = UIEdgeInsetsMake( - (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    self.customMiddleButton.titleEdgeInsets = UIEdgeInsetsMake( 0.0, - imageSize.width, - (totalHeight - titleSize.height) + 8, 0.0);
    
    [self refreshLottieView];
}

- (void)refreshLottieView {
    UIView *animatingView = [self.customMiddleButton viewWithTag:20001];
    if (animatingView) {
        [animatingView removeFromSuperview];
    }
    
    if (self.lottieView) {
        [self.lottieView removeFromSuperview];
        self.lottieView = nil;
    }

    for(TTTabBarItem *item in self.tabItems) {
        if (item.animationView) {
            item.animationView = nil;
        }
    }
}

@end

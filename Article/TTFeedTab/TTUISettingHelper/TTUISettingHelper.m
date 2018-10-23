//
//  TTUISettingHelper.m
//  Article
//
//  Created by 王双华 on 16/6/5.
//
//

#import "TTUISettingHelper.h"
#import "NSDictionary+TTAdditions.h"
#import "NewsUserSettingManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"

#define kColorBackground4Array                  @[ [UIColor colorWithHexString:@"ffffff"],[UIColor colorWithHexString:@"252525"] ]
#define kColorBackground4HighlightedArray       @[ [UIColor colorWithHexString:@"e0e0e0"],[UIColor colorWithHexString:@"1b1b1b"] ]
#define kColorText1Array                        @[ [UIColor colorWithHexString:@"222222"],[UIColor colorWithHexString:@"707070"] ]
#define kColorText1HighlightedArray             @[ [UIColor colorWithHexString:@"2222227f"],[UIColor colorWithHexString:@"7070707f"] ]
#define kColorText5Array                        @[ [UIColor colorWithHexString:@"406599"],[UIColor colorWithHexString:@"67778b"] ]
#define kColorBackground3Array                  @[ [UIColor colorWithHexString:@"f4f5f6"],[UIColor colorWithHexString:@"1b1b1b"] ]

NSString *const kCellViewUserDefaultKey = @"kCellViewUserDefaultKey";
NSString *const kDetailViewUserDefaultKey = @"kDetailViewUserDefaultKey";
NSString *const kCategoryViewUserDefaultKey = @"kCategoryViewUserDefaultKey";
NSString *const kTabBarViewUserDefaultKey = @"kTabBarViewUserDefaultKey";

UIColor *tt_ttuisettingHelper_detailViewCommentReplyUserNameColor(void) {
    return [TTUISettingHelper detailViewCommentReplyUserNameColor];
}
UIColor *tt_ttuisettingHelper_detailViewCommentReplyBackgroundColor(void) {
    return [TTUISettingHelper detailViewCommentReplyBackgroundColor];
}
NSArray *tt_ttuisettingHelper_detailViewCommentReplyBackgroundeColors(void) {
    return [TTUISettingHelper detailViewCommentReplyBackgroundeColors];
}
NSArray *tt_ttuisettingHelper_cellViewTitleColors(void) {
    return [TTUISettingHelper cellViewTitleColors];
}
NSArray *tt_ttuisettingHelper_detailViewBackgroundColors(void) {
    return [TTUISettingHelper detailViewBackgroundColors];
}
UIColor *tt_ttuisettingHelper_cellViewBackgroundColor(void) {
    return [TTUISettingHelper cellViewBackgroundColor];
}
UIColor *tt_ttuisettingHelper_cellViewHighlightedBackgroundColor(void) {
    return [TTUISettingHelper cellViewHighlightedBackgroundColor];
}
NSDictionary *tt_ttuisettingHelper_cellViewUISettingsDictionary(void) {
    return [[TTUISettingHelper sharedInstance_tt] cellViewUISettingsDictionary];
}

@interface TTUISettingHelper()
//列表页
@property (nonatomic, strong) NSDictionary *cellViewUISettingsDictionary;
@property (nonatomic, strong) NSArray *cellViewTitleFontSizeArray;
@property (nonatomic, strong) NSArray *cellViewTitleColorHexStringArray;
@property (nonatomic, strong) NSArray *cellViewBackgroundColorHexStringArray;
//详情页
@property (nonatomic, strong) NSDictionary *detailViewUISettingsDictionary;
@property (nonatomic, strong) NSArray *detailViewTitleFontSizeArray;
@property (nonatomic, strong) NSArray *detailViewTitleColorHexStringArray;
@property (nonatomic, strong) NSArray *detailViewBodyFontSizeArray;
@property (nonatomic, strong) NSArray *detailViewBodyColorHexStringArray;
@property (nonatomic, strong) NSArray *detailViewBackgroundColorHexStringArray;
@property (nonatomic, strong) NSArray *detailViewNatantFontSizeArray;
@property (nonatomic, strong) NSArray *detailViewCommentFontSizeArray;
@property (nonatomic, assign) CGFloat detailViewCommentUserFontSize;
@property (nonatomic, strong) NSArray *detailViewCommentUserColorHexStringArray;
@property (nonatomic, strong) NSArray *detailViewCommentContentColorHexStringArray;
@property (nonatomic, strong) NSArray *detailViewCommentReplyContentColorHexStringArray;
@property (nonatomic, strong) NSArray *detailViewCommentReplyUserColorHexStringArray;
@property (nonatomic, assign) CGFloat detailViewCommentReplyUserFontSize;
@property (nonatomic, strong) NSArray *detailViewCommentReplyBackgroundColorHexStringArray;
//频道导航
@property (nonatomic, strong) NSArray *categoryViewBackgroundColorHexStringArray;
@property (nonatomic, strong) NSArray *categoryViewFontSizeArray;
@property (nonatomic, assign) CGFloat categoryViewMargin;
//tabbar
@property (nonatomic, strong) NSArray *tabBarViewTabNameArray;
@property (nonatomic, strong) NSArray *tabBarViewBackgroundColorHexStringArray;
@end
@implementation TTUISettingHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.categoryViewMargin = -1;
        self.detailViewCommentUserFontSize = -1;
        self.detailViewCommentReplyUserFontSize = -1;
    }
    return self;
}

+ (void)enforceServerUISettings
{
    /*
     *  列表页UI设置参数:
     *  font_size               标题字体:小，中，大，特大分别对应的字号
     *  color                   标题字体颜色:日间，夜间，选取态日间，选取态夜间
     *  cell_background_color   cell的背景颜色:日间，夜间，选取态日间，选取态夜间
     */
    NSDictionary *cellViewSettings = [self savedCellViewUISettingInfoDict];
    if (cellViewSettings) {
        [[TTUISettingHelper sharedInstance_tt] setCellViewUISettingsDictionary:cellViewSettings];
        if ([cellViewSettings objectForKey:@"font_size"]) {
            NSArray *fontSize = [cellViewSettings objectForKey:@"font_size"];
            if ([fontSize isKindOfClass:[NSArray class]] && [fontSize count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setCellViewTitleFontSizeArray:fontSize];
            }
        }
        
        if ([cellViewSettings objectForKey:@"color"]) {
            NSArray *textColor = [cellViewSettings objectForKey:@"color"];
            if ([textColor isKindOfClass:[NSArray class]] && [textColor count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setCellViewTitleColorHexStringArray:textColor];
            }
        }
        
        if ([cellViewSettings objectForKey:@"cell_background_color"]) {
            NSArray *backgroundColor = [cellViewSettings objectForKey:@"cell_background_color"];
            if ([backgroundColor isKindOfClass:[NSArray class]] && [backgroundColor count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setCellViewBackgroundColorHexStringArray:backgroundColor];
            }
        }
    }
    
    /*
     *  详情页UI设置参数:
     *  title_font_size         标题字体:小，中，大，特大分别对应的字号
     *  title_color             标题字体颜色:日间，夜间
     *  body_font_size          正文字体:小，中，大，特大分别对应的字号
     *  body_color              正文字体颜色:日间，夜间
     *  detail_background_color 详情页和浮层的背景颜色:日间，夜间
     *  natant_font_size        浮层相关阅读字体:小，中，大，特大分别对应的字号
     *  comment_font_size       评论用户名字号:int
     *  comment_user_color      评论用户名字色:日间，夜间
     *  comment_font_color      评论内容字色:日间，夜间
     *  sub_comment_font_color  回复评论内容字色:日间，夜间
     *  sub_comment_user_font_size     回复评论用户名字号:int
     *  sub_comment_user_color  回复评论用户名字色:日间，夜间
     *  sub_comment_background_color   评论中的回复评论背景色:日间，夜间，日间选取，夜间选取
     */
    NSDictionary *detailViewSettings = [self savedDetailViewUISettingInfoDict];
    if (detailViewSettings){
        [[TTUISettingHelper sharedInstance_tt] setDetailViewUISettingsDictionary:detailViewSettings];
        if ([detailViewSettings objectForKey:@"title_font_size"]) {
            NSArray *fontSize = [detailViewSettings objectForKey:@"title_font_size"];
            if ([fontSize isKindOfClass:[NSArray class]] && [fontSize count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewTitleFontSizeArray:fontSize];
            }
        }
        
        if ([detailViewSettings objectForKey:@"title_color"]) {
            NSArray *textColor = [detailViewSettings objectForKey:@"title_color"];
            if ([textColor isKindOfClass:[NSArray class]] && [textColor count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewTitleColorHexStringArray:textColor];
            }
        }
        
        if ([detailViewSettings objectForKey:@"body_font_size"]) {
            NSArray *fontSize = [detailViewSettings objectForKey:@"body_font_size"];
            if ([fontSize isKindOfClass:[NSArray class]] && [fontSize count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewBodyFontSizeArray:fontSize];
            }
        }
        
        if ([detailViewSettings objectForKey:@"body_color"]) {
            NSArray *textColor = [detailViewSettings objectForKey:@"body_color"];
            if ([textColor isKindOfClass:[NSArray class]] && [textColor count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewBodyColorHexStringArray:textColor];
            }
        }
        
        if ([detailViewSettings objectForKey:@"detail_background_color"]) {
            NSArray *backgroundColor = [detailViewSettings objectForKey:@"detail_background_color"];
            if ([backgroundColor isKindOfClass:[NSArray class]] && [backgroundColor count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewBackgroundColorHexStringArray:backgroundColor];
            }
        }
        
        if ([detailViewSettings objectForKey:@"natant_font_size"]) {
            NSArray *fontSize = [detailViewSettings objectForKey:@"natant_font_size"];
            if ([fontSize isKindOfClass:[NSArray class]] && [fontSize count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewNatantFontSizeArray:fontSize];
            }
        }
        
        if ([detailViewSettings objectForKey:@"comment_font_size"]) {
            NSArray *fontSize = [detailViewSettings objectForKey:@"comment_font_size"];
            if ([fontSize isKindOfClass:[NSArray class]] && [fontSize count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewCommentFontSizeArray:fontSize];
            }
        }
        
        if ([detailViewSettings objectForKey:@"comment_user_font_size"]) {
            NSNumber *fontSize = [detailViewSettings objectForKey:@"comment_user_font_size"];
            if ([fontSize isKindOfClass:[NSNumber class]] && [fontSize intValue] > 0){
                [[TTUISettingHelper sharedInstance_tt] setDetailViewCommentUserFontSize:[fontSize intValue]];
            }
        }
        
        if ([detailViewSettings objectForKey:@"comment_user_color"]) {
            NSArray *textColor = [detailViewSettings objectForKey:@"comment_user_color"];
            if ([textColor isKindOfClass:[NSArray class]] && [textColor count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewCommentUserColorHexStringArray:textColor];
            }
        }
        
        if ([detailViewSettings objectForKey:@"comment_font_color"]) {
            NSArray *textColor = [detailViewSettings objectForKey:@"comment_font_color"];
            if ([textColor isKindOfClass:[NSArray class]] && [textColor count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewCommentContentColorHexStringArray:textColor];
            }
        }
        
        if ([detailViewSettings objectForKey:@"sub_comment_font_color"]){
            NSArray *textColor = [detailViewSettings objectForKey:@"sub_comment_font_color"];
            if ([textColor isKindOfClass:[NSArray class]] && [textColor count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewCommentReplyContentColorHexStringArray:textColor];
            }
        }
        
        if ([detailViewSettings objectForKey:@"sub_comment_font_size"]) {
            NSNumber *fontSize = [detailViewSettings objectForKey:@"sub_comment_font_size"];
            if ([fontSize isKindOfClass:[NSNumber class]] && [fontSize intValue] > 0){
                [[TTUISettingHelper sharedInstance_tt] setDetailViewCommentReplyUserFontSize:[fontSize intValue]];
            }
        }
        
        if ([detailViewSettings objectForKey:@"sub_comment_user_color"]){
            NSArray *textColor = [detailViewSettings objectForKey:@"sub_comment_user_color"];
            if ([textColor isKindOfClass:[NSArray class]] && [textColor count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewCommentReplyUserColorHexStringArray:textColor];
            }
        }
        
        if ([detailViewSettings objectForKey:@"sub_comment_background_color"]){
            NSArray *backgroundColor = [detailViewSettings objectForKey:@"sub_comment_background_color"];
            if ([backgroundColor isKindOfClass:[NSArray class]] && [backgroundColor count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setDetailViewCommentReplyBackgroundColorHexStringArray:backgroundColor];
            }
        }
    }
    
    /*
     *  频道导航UI设置参数:
     *  font_size               频道名称字体大小
     *  margin                  频道名间距
     *  background_color        频道导航背景颜色日间，夜间
     */
    NSDictionary *categoryViewSettings = [self savedCategoryViewUISettingInfoDict];
    if (categoryViewSettings) {
        if ([categoryViewSettings objectForKey:@"font_size"]) {
            NSArray *fontSizeArray = [categoryViewSettings objectForKey:@"font_size"];
            if ([fontSizeArray isKindOfClass:[NSArray class]] && [fontSizeArray count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setCategoryViewFontSizeArray:fontSizeArray];
            }
        }
        
        if ([categoryViewSettings objectForKey:@"margin"]) {
            NSNumber *margin = [categoryViewSettings objectForKey:@"margin"];
            if ([margin intValue] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setCategoryViewMargin:[margin intValue]];
            }
        }
        
        if ([categoryViewSettings objectForKey:@"background_color"]) {
            NSArray *backgroundColor = [categoryViewSettings objectForKey:@"background_color"];
            if ([backgroundColor isKindOfClass:[NSArray class]] && [backgroundColor count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setCategoryViewBackgroundColorHexStringArray:backgroundColor];
            }
        }
    }
    
    /*
     *  tabBar UI设置参数:
     *  tab_name                tab的名称数组
     *  tab_background_color    tab的背景色，日间，夜间
     *
     */
    NSDictionary *tabBarViewSettings = [self savedTabBarViewUISettingInfoDict];
    if (tabBarViewSettings) {
        if ([tabBarViewSettings objectForKey:@"tab_name"]) {
            NSArray *tabName = [tabBarViewSettings objectForKey:@"tab_name"];
            if ([tabName isKindOfClass:[NSArray class]] && [tabName count] > 0) {
                [[TTUISettingHelper sharedInstance_tt] setTabBarViewTabNameArray:tabName];
            }
        }
        
        if ([tabBarViewSettings objectForKey:@"tab_background_color"]) {
            NSArray *backgroundColor = [tabBarViewSettings objectForKey:@"tab_background_color"];
            if ([backgroundColor isKindOfClass:[NSArray class]] && [backgroundColor count] > 0){
                [[TTUISettingHelper sharedInstance_tt] setTabBarViewBackgroundColorHexStringArray:backgroundColor];
            }
        }
    }
}

//保存服务端下发的列表页CellView的UI设置，下次启动生效
+ (void)saveCellViewUISettingInfoDict:(NSDictionary *)dict
{
    if ([dict isKindOfClass:[NSDictionary class]] && [dict count] > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kCellViewUserDefaultKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults]  removeObjectForKey:kCellViewUserDefaultKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)savedCellViewUISettingInfoDict
{
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:kCellViewUserDefaultKey];
    return dict;
}

//保存服务端下发的详情页的UI设置，下次启动生效
+ (void)saveDetailViewUISettingInfoDict:(NSDictionary *)dict
{
    if ([dict isKindOfClass:[NSDictionary class]] && [dict count] > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kDetailViewUserDefaultKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults]  removeObjectForKey:kDetailViewUserDefaultKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)savedDetailViewUISettingInfoDict
{
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:kDetailViewUserDefaultKey];
    return dict;
}

//保存服务端下发的频道导航（即TTCategorySelectorView）的UI设置，下次启动生效
+ (void)saveCategoryViewUISettingInfoDict:(NSDictionary *)dict
{
    if ([dict isKindOfClass:[NSDictionary class]] && [dict count] > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kCategoryViewUserDefaultKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults]  removeObjectForKey:kCategoryViewUserDefaultKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)savedCategoryViewUISettingInfoDict
{
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:kCategoryViewUserDefaultKey];
    return dict;
}

//保存服务端下发的底部tab的UI设置，下次启动生效
+ (void)saveTabBarViewUISettingInfoDict:(NSDictionary *)dict
{
    if ([dict isKindOfClass:[NSDictionary class]] && [dict count] > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kTabBarViewUserDefaultKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults]  removeObjectForKey:kTabBarViewUserDefaultKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)savedTabBarViewUISettingInfoDict
{
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:kTabBarViewUserDefaultKey];
    return dict;
}

#pragma mark --titleSize for cell
+ (BOOL)cellViewTitleFontSizeControllable
{
    NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] cellViewTitleFontSizeArray];
    if (fontSizeArray != nil && [fontSizeArray count] == 4) {
        return YES;
    }
    return NO;
}

+ (CGFloat)cellViewTitleFontSize
{
    NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] cellViewTitleFontSizeArray];
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    return [fontSizeArray[selectedIndex] floatValue];
}

#pragma mark --titleColor for cell
+ (BOOL)cellViewTitleColorControllable
{
    NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] cellViewTitleColorHexStringArray];
    if (titleColorArray != nil && [titleColorArray count] == 4) {
        return YES;
    }
    return NO;
}

+ (UIColor *)cellViewTitleColor
{
    
    if ([self cellViewTitleColorControllable]) {
        NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] cellViewTitleColorHexStringArray];
        NSString *dayColorHexString = [titleColorArray objectAtIndex:0];
        NSString *nightColorHexString = [titleColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)){
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorText1];
}

+ (NSArray *)cellViewTitleColors
{
    if ([self cellViewTitleColorControllable]){
        NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] cellViewTitleColorHexStringArray];
        NSString *dayColorHexString = [titleColorArray objectAtIndex:0];
        NSString *nightColorHexString = [titleColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)){
            return @[ [UIColor colorWithHexString:dayColorHexString],[UIColor colorWithHexString:nightColorHexString] ];
        }
    }
    return kColorText1Array;
}

+ (UIColor *)cellViewHighlightedtTitleColor
{
    if ([self cellViewTitleColorControllable]) {
        NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] cellViewTitleColorHexStringArray];
        NSString *dayColorHexString = [titleColorArray objectAtIndex:2];
        NSString *nightColorHexString = [titleColorArray objectAtIndex:3];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)){
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorText1Highlighted];
}

+ (NSArray *)cellViewHighlightedtTitleColors
{
    if ([self cellViewTitleColorControllable]){
        NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] cellViewTitleColorHexStringArray];
        NSString *dayColorHexString = [titleColorArray objectAtIndex:2];
        NSString *nightColorHexString = [titleColorArray objectAtIndex:3];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)){
            return @[ [UIColor colorWithHexString:dayColorHexString],[UIColor colorWithHexString:nightColorHexString] ];
        }
    }
    return kColorText1HighlightedArray;
}

#pragma mark --backgroundColor for cell
+ (BOOL)cellViewBackgroundColorControllable
{
    NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] cellViewBackgroundColorHexStringArray];
    if (backgroundColorArray != nil && [backgroundColorArray count] == 4) {
        return YES;
    }
    return NO;
}

+ (UIColor *)cellViewBackgroundColor
{
    if ([self cellViewBackgroundColorControllable]) {
        NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] cellViewBackgroundColorHexStringArray];
        NSString *dayColorHexString = [backgroundColorArray objectAtIndex:0];
        NSString *nightColorHexString = [backgroundColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)){
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorBackground4];
}

+ (NSArray *)cellViewBackgroundColors
{
    if ([self cellViewBackgroundColorControllable]) {
        NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] cellViewBackgroundColorHexStringArray];
        NSString *dayColorHexString = [backgroundColorArray objectAtIndex:0];
        NSString *nightColorHexString = [backgroundColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)){
            return @[ [UIColor colorWithHexString:dayColorHexString],[UIColor colorWithHexString:nightColorHexString] ];
        }
    }
    return kColorBackground4Array;
}

+ (UIColor *)cellViewHighlightedBackgroundColor
{
    if ([self cellViewBackgroundColorControllable]) {
        NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] cellViewBackgroundColorHexStringArray];
        NSString *dayColorHexString = [backgroundColorArray objectAtIndex:2];
        NSString *nightColorHexString = [backgroundColorArray objectAtIndex:3];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorBackground4Highlighted];
}

+ (NSArray *)cellViewHighlightedBackgroundColors
{
    if ([self cellViewBackgroundColorControllable]) {
        NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] cellViewBackgroundColorHexStringArray];
        NSString *dayColorHexString = [backgroundColorArray objectAtIndex:2];
        NSString *nightColorHexString = [backgroundColorArray objectAtIndex:3];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)){
            return @[ [UIColor colorWithHexString:dayColorHexString],[UIColor colorWithHexString:nightColorHexString] ];
        }
    }
    return kColorBackground4HighlightedArray;
}

#pragma mark --titleSize for detailView
+ (BOOL)detailViewTitleFontSizeControllable
{
    NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] detailViewTitleFontSizeArray];
    if (fontSizeArray != nil && [fontSizeArray count] == 4) {
        return YES;
    }
    return NO;
}

+ (CGFloat)detailViewTitleFontSize
{
    NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] detailViewTitleFontSizeArray];
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    return [fontSizeArray[selectedIndex] floatValue];
}

#pragma mark --bodySize for detailView
+ (BOOL)detailViewBodyFontSizeControllable
{
    NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] detailViewBodyFontSizeArray];
    if (fontSizeArray != nil && [fontSizeArray count] == 4) {
        return YES;
    }
    return NO;
}

+ (CGFloat)detailViewBodyFontSize
{
    NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] detailViewBodyFontSizeArray];
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    return [fontSizeArray[selectedIndex] floatValue];
}

#pragma mark --titleColor for detailView
+ (BOOL)detailViewTitleColorControllable
{
    NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewTitleColorHexStringArray];
    if (titleColorArray != nil && [titleColorArray count] == 2) {
        return YES;
    }
    return NO;
}

+ (UIColor *)detailViewTitleColor
{
    
    if ([self cellViewTitleColorControllable]) {
        NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewTitleColorHexStringArray];
        NSString *dayColorHexString = [titleColorArray objectAtIndex:0];
        NSString *nightColorHexString = [titleColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorText1];
}

#pragma mark --bodyColor for detailView
+ (BOOL)detailViewBodyColorControllable
{
    NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewBodyColorHexStringArray];
    if (titleColorArray != nil && [titleColorArray count] == 2) {
        return YES;
    }
    return NO;
}
//详情页正文，浮层的颜色
+ (UIColor *)detailViewBodyColor
{
    if ([self detailViewBodyColorControllable]) {
        NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewBodyColorHexStringArray];
        NSString *dayColorHexString = [titleColorArray objectAtIndex:0];
        NSString *nightColorHexString = [titleColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorText1];
}

+ (NSArray *)detailViewBodyColors
{
    if ([self detailViewBodyColorControllable]) {
        NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewBodyColorHexStringArray];
        NSString *dayColorHexString = [titleColorArray objectAtIndex:0];
        NSString *nightColorHexString = [titleColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return @[ [UIColor colorWithHexString:dayColorHexString],[UIColor colorWithHexString:nightColorHexString] ];
        }
    }
    return kColorText1Array;
}

#pragma mark --backgroundColor for detailView
+ (BOOL)detailViewBackgroundColorControllable
{
    NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewBackgroundColorHexStringArray];
    if (backgroundColorArray != nil && [backgroundColorArray count] == 2) {
        NSString *dayColorHexString = [backgroundColorArray objectAtIndex:0];
        NSString *nightColorHexString = [backgroundColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)){
            return YES;
        }
    }
    return NO;
}

+ (UIColor *)detailViewBackgroundColor
{
    if ([self detailViewBackgroundColorControllable]) {
        NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewBackgroundColorHexStringArray];
        NSString *dayColorHexString = [backgroundColorArray objectAtIndex:0];
        NSString *nightColorHexString = [backgroundColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorBackground4];
}

+ (NSArray *)detailViewBackgroundColors
{
    if ([self detailViewBackgroundColorControllable]) {
        NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewBackgroundColorHexStringArray];
        NSString *dayColorHexString = [backgroundColorArray objectAtIndex:0];
        NSString *nightColorHexString = [backgroundColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return @[ [UIColor colorWithHexString:dayColorHexString],[UIColor colorWithHexString:nightColorHexString] ];
        }
    }
    return kColorBackground4Array;
}

#pragma mark --natantFontSize for detailView
+ (BOOL)detailViewNatantFontSizeControllable
{
    NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] detailViewNatantFontSizeArray];
    if (fontSizeArray != nil && [fontSizeArray count] == 4) {
        return YES;
    }
    return NO;
}

+ (CGFloat)detailViewNatantFontSize
{
    NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] detailViewNatantFontSizeArray];
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    return [fontSizeArray[selectedIndex] floatValue];
}

#pragma mark --natantFontSize for detailView
+ (BOOL)detailViewCommentFontSizeControllable
{
    NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentFontSizeArray];
    if (fontSizeArray != nil && [fontSizeArray count] == 4) {
        return YES;
    }
    return NO;
}

+ (CGFloat)detailViewCommentFontSize
{
    NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentFontSizeArray];
    NSInteger selectedIndex = [SSUserSettingManager fontSettingIndex];
    return [fontSizeArray[selectedIndex] floatValue];
}

+ (BOOL)detailViewCommentUserNameFontSizeControllable
{
    CGFloat fontSize = [[TTUISettingHelper sharedInstance_tt] detailViewCommentUserFontSize];
    if (fontSize > 0) {
        return YES;
    }
    return NO;
}

+ (CGFloat)detailViewCommentUserNameFontSize
{
    return [[TTUISettingHelper sharedInstance_tt] detailViewCommentUserFontSize];
}

//详情页评论cell回复评论用户名字号
+ (BOOL)detailViewCommentReplyUserNameFontSizeControllable
{
    CGFloat fontSize = [[TTUISettingHelper sharedInstance_tt] detailViewCommentReplyUserFontSize];
    if (fontSize > 0) {
        return YES;
    }
    return NO;
}

+ (CGFloat)detailViewCommentReplyUserNameFontSize
{
     return [[TTUISettingHelper sharedInstance_tt] detailViewCommentReplyUserFontSize];
}

//详情页评论cell用户名字色
+ (BOOL)detailViewCommentUserNameColorControllable
{
    NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentUserColorHexStringArray];
    if (titleColorArray != nil && [titleColorArray count] == 2) {
        return YES;
    }
    return NO;
}

+ (UIColor *)detailViewCommentUserNameColor
{
    if ([self detailViewCommentUserNameColorControllable]) {
        NSArray *textColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentUserColorHexStringArray];
        NSString *dayColorHexString = [textColorArray objectAtIndex:0];
        NSString *nightColorHexString = [textColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
             return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorText5];
}

+ (NSArray *)detailViewCommentUserNameColors
{
    if ([self detailViewCommentUserNameColorControllable]) {
        NSArray *textColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentUserColorHexStringArray];
        NSString *dayColorHexString = [textColorArray objectAtIndex:0];
        NSString *nightColorHexString = [textColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return @[ [UIColor colorWithHexString:dayColorHexString],[UIColor colorWithHexString:nightColorHexString] ];
        }
    }
    return kColorText5Array;
}
//详情页评论cell评论内容字色
+ (BOOL)detailViewCommentContentLabelColorControllable
{
    NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentContentColorHexStringArray];
    if (titleColorArray != nil && [titleColorArray count] == 2) {
        return YES;
    }
    return NO;
}

+ (UIColor *)detailViewCommentContentLabelColor
{
    if ([self detailViewCommentUserNameColorControllable]) {
        NSArray *textColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentContentColorHexStringArray];
        NSString *dayColorHexString = [textColorArray objectAtIndex:0];
        NSString *nightColorHexString = [textColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorText1];
}

+ (NSArray *)detailViewCommentContentLabelColors
{
    if ([self detailViewCommentUserNameColorControllable]) {
        NSArray *textColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentContentColorHexStringArray];
        NSString *dayColorHexString = [textColorArray objectAtIndex:0];
        NSString *nightColorHexString = [textColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return @[ [UIColor colorWithHexString:dayColorHexString],[UIColor colorWithHexString:nightColorHexString] ];
        }
    }
    return kColorText1Array;
}
//详情页评论cell回复评论内容字色
+ (BOOL)detailViewCommentReplyContentColorControllable
{
    NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentReplyContentColorHexStringArray];
    if (titleColorArray != nil && [titleColorArray count] == 2) {
        return YES;
    }
    return NO;
}

+ (UIColor *)detailViewCommentReplyContentColor
{
    if ([self detailViewCommentUserNameColorControllable]) {
        NSArray *textColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentReplyContentColorHexStringArray];
        NSString *dayColorHexString = [textColorArray objectAtIndex:0];
        NSString *nightColorHexString = [textColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorText1];
}

+ (NSArray *)detailViewCommentReplyContentColors
{
    if ([self detailViewCommentUserNameColorControllable]) {
        NSArray *textColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentReplyContentColorHexStringArray];
        NSString *dayColorHexString = [textColorArray objectAtIndex:0];
        NSString *nightColorHexString = [textColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return @[ [UIColor colorWithHexString:dayColorHexString],[UIColor colorWithHexString:nightColorHexString] ];
        }
    }
    return kColorText1Array;
}
//详情页评论cell回复评论用户名颜色
+ (BOOL)detailViewCommentReplyUserNameColorControllable
{
    NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentReplyUserColorHexStringArray];
    if (titleColorArray != nil && [titleColorArray count] == 2) {
        return YES;
    }
    return NO;
}

+ (UIColor *)detailViewCommentReplyUserNameColor
{
    if ([self detailViewCommentUserNameColorControllable]) {
        NSArray *textColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentReplyUserColorHexStringArray];
        NSString *dayColorHexString = [textColorArray objectAtIndex:0];
        NSString *nightColorHexString = [textColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorText5];
}

+ (NSArray *)detailViewCommentReplyUserNameColors
{
    if ([self detailViewCommentUserNameColorControllable]) {
        NSArray *textColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentReplyUserColorHexStringArray];
        NSString *dayColorHexString = [textColorArray objectAtIndex:0];
        NSString *nightColorHexString = [textColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return @[ [UIColor colorWithHexString:dayColorHexString],[UIColor colorWithHexString:nightColorHexString] ];
        }
    }
    return kColorText5Array;
}
//详情页评论cell回复评论背景颜色
+ (BOOL)detailViewCommentReplyBackgroundColorControllable
{
    NSArray *titleColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentReplyBackgroundColorHexStringArray];
    if (titleColorArray != nil && [titleColorArray count] == 2) {
        return YES;
    }
    return NO;
}

+ (UIColor *)detailViewCommentReplyBackgroundColor
{
    if ([self detailViewCommentUserNameColorControllable]) {
        NSArray *textColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentReplyBackgroundColorHexStringArray];
        NSString *dayColorHexString = [textColorArray objectAtIndex:0];
        NSString *nightColorHexString = [textColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:kColorBackground3];
}

+ (NSArray *)detailViewCommentReplyBackgroundeColors
{
    if ([self detailViewCommentUserNameColorControllable]) {
        NSArray *textColorArray = [[TTUISettingHelper sharedInstance_tt] detailViewCommentReplyBackgroundColorHexStringArray];
        NSString *dayColorHexString = [textColorArray objectAtIndex:0];
        NSString *nightColorHexString = [textColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return @[ [UIColor colorWithHexString:dayColorHexString],[UIColor colorWithHexString:nightColorHexString] ];
        }
    }
    return kColorBackground3Array;
}


#pragma mark --backgroundColor for categoryView
+ (BOOL)categoryViewBackgroundColorControllable
{
    NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] categoryViewBackgroundColorHexStringArray];
    if (backgroundColorArray != nil && [backgroundColorArray count] == 2) {
        return YES;
    }
    return NO;
}

+ (UIColor *)categoryViewBackgroundColor
{
    if ([self categoryViewBackgroundColorControllable]) {
        NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] categoryViewBackgroundColorHexStringArray];
        NSString *dayColorHexString = [backgroundColorArray objectAtIndex:0];
        NSString *nightColorHexString = [backgroundColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)) {
            return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
        }
    }
    return [UIColor tt_themedColorForKey:@"navigationBarBackgroundRed"];
}

#pragma mark --fontSize for categoryView
+ (BOOL)categoryViewFontSizeControllable
{
    NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] categoryViewFontSizeArray];
    if (fontSizeArray != nil && [fontSizeArray count] == 2) {
        return YES;
    }
    return NO;
}

+ (CGFloat)categoryViewFontSize
{
    if ([self categoryViewFontSizeControllable]) {
        NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] categoryViewFontSizeArray];
        NSNumber *fontSize = [fontSizeArray objectAtIndex:0];
        if ([fontSize isKindOfClass:[NSNumber class]] && [fontSize intValue] > 0) {
            return [fontSize intValue];
        }
    }
    return kChannelFontSize;
}

+ (CGFloat)categoryViewSelectedFontSize
{
    if ([self categoryViewFontSizeControllable]) {
        NSArray *fontSizeArray = [[TTUISettingHelper sharedInstance_tt] categoryViewFontSizeArray];
        NSNumber *fontSize = [fontSizeArray objectAtIndex:1];
        if ([fontSize isKindOfClass:[NSNumber class]] && [fontSize intValue] > 0) {
            return [fontSize intValue];
        }
    }
    return kChannelSelectedFontSize;
}

#pragma mark --margin for categoryView
+ (BOOL)categoryViewMarginControllable
{
    if ([[TTUISettingHelper sharedInstance_tt] categoryViewMargin] > 0) {
        return YES;
    }
    return NO;
}

+ (CGFloat)categoryViewMargin
{
    return [[TTUISettingHelper sharedInstance_tt] categoryViewMargin];
}

#pragma mark --tabName for tabbar
+ (BOOL)tabBarViewTabNameArrayControllable
{
    NSArray *tabName = [[TTUISettingHelper sharedInstance_tt] tabBarViewTabNameArray];
    if (tabName != nil && [tabName count] == 4) {
        return YES;
    }
    return NO;
}

+ (NSArray *)tabBarViewTabNameArray
{
    return [[TTUISettingHelper sharedInstance_tt] tabBarViewTabNameArray];
}

#pragma mark --backgroundColor for tabbar
+ (BOOL)tabBarViewBackgroundColorControllable
{
    NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] tabBarViewBackgroundColorHexStringArray];
    if (backgroundColorArray != nil && [backgroundColorArray count] == 2) {
        NSString *dayColorHexString = [backgroundColorArray objectAtIndex:0];
        NSString *nightColorHexString = [backgroundColorArray objectAtIndex:1];
        if (!isEmptyString(dayColorHexString) && !isEmptyString(nightColorHexString)){
            return YES;
        }
    }
    return NO;
}

+ (UIColor *)tabBarViewBackgroundColor
{
    NSArray *backgroundColorArray = [[TTUISettingHelper sharedInstance_tt] tabBarViewBackgroundColorHexStringArray];
    NSString *dayColorHexString = [backgroundColorArray objectAtIndex:0];
    NSString *nightColorHexString = [backgroundColorArray objectAtIndex:1];
    return [UIColor colorWithDayColorName:dayColorHexString nightColorName:nightColorHexString];
}

@end

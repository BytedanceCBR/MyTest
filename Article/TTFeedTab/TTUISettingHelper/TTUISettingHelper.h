//
//  TTUISettingHelper.h
//  Article
//
//  Created by 王双华 on 16/6/5.
//
//

#import <Foundation/Foundation.h>
#import "NSObject+TTAdditions.h"

extern UIColor *tt_ttuisettingHelper_detailViewCommentReplyUserNameColor(void);
extern UIColor *tt_ttuisettingHelper_detailViewCommentReplyBackgroundColor(void);
extern NSArray *tt_ttuisettingHelper_detailViewCommentReplyBackgroundeColors(void);
extern NSArray *tt_ttuisettingHelper_cellViewTitleColors(void);
extern NSArray *tt_ttuisettingHelper_detailViewBackgroundColors(void);
extern UIColor *tt_ttuisettingHelper_cellViewBackgroundColor(void);
extern UIColor *tt_ttuisettingHelper_cellViewHighlightedBackgroundColor(void);
extern NSDictionary *tt_ttuisettingHelper_cellViewUISettingsDictionary(void);

@interface TTUISettingHelper : NSObject<Singleton>
//列表页
@property (nonatomic, strong, readonly) NSDictionary *cellViewUISettingsDictionary;
@property (nonatomic, strong, readonly) NSArray *cellViewTitleFontSizeArray;
@property (nonatomic, strong, readonly) NSArray *cellViewTitleColorHexStringArray;
@property (nonatomic, strong, readonly) NSArray *cellViewBackgroundColorHexStringArray;
//详情页
@property (nonatomic, strong, readonly) NSDictionary *detailViewUISettingsDictionary;
@property (nonatomic, strong, readonly) NSArray *detailViewTitleFontSizeArray;
@property (nonatomic, strong, readonly) NSArray *detailViewTitleColorHexStringArray;
@property (nonatomic, strong, readonly) NSArray *detailViewBodyFontSizeArray;
@property (nonatomic, strong, readonly) NSArray *detailViewBodyColorHexStringArray;
@property (nonatomic, strong, readonly) NSArray *detailViewBackgroundColorHexStringArray;
@property (nonatomic, strong, readonly) NSArray *detailViewNatantFontSizeArray;
@property (nonatomic, strong, readonly) NSArray *detailViewCommentFontSizeArray;
@property (nonatomic, assign, readonly) CGFloat detailViewCommentUserFontSize;
@property (nonatomic, strong, readonly) NSArray *detailViewCommentUserColorHexStringArray;
@property (nonatomic, strong, readonly) NSArray *detailViewCommentContentColorHexStringArray;
@property (nonatomic, strong, readonly) NSArray *detailViewCommentReplyContentColorHexStringArray;
@property (nonatomic, strong, readonly) NSArray *detailViewCommentReplyUserColorHexStringArray;
@property (nonatomic, assign, readonly) CGFloat detailViewCommentReplyUserFontSize;
@property (nonatomic, strong, readonly) NSArray *detailViewCommentReplyBackgroundColorHexStringArray;
//频道导航－－放二期做
@property (nonatomic, strong, readonly) NSArray *categoryViewBackgroundColorHexStringArray;
@property (nonatomic, strong, readonly) NSArray *categoryViewFontSizeArray;
@property (nonatomic, assign, readonly) CGFloat categoryViewMargin;
//tabbar－－放二期做
@property (nonatomic, strong, readonly) NSArray *tabBarViewTabNameArray;
@property (nonatomic, strong, readonly) NSArray *tabBarViewBackgroundColorHexStringArray;
//启动时调用，使上次保存的设置生效
+ (void)enforceServerUISettings;

//保存服务端下发的列表页CellView的UI设置，下次启动生效
+ (void)saveCellViewUISettingInfoDict:(NSDictionary *)dict;
//保存服务端下发的详情页的UI设置，下次启动生效
+ (void)saveDetailViewUISettingInfoDict:(NSDictionary *)dict;
//保存服务端下发的频道导航（即TTCategorySelectorView）的UI设置，下次启动生效
+ (void)saveCategoryViewUISettingInfoDict:(NSDictionary *)dict;
//保存服务端下发的底部tab的UI设置，下次启动生效
+ (void)saveTabBarViewUISettingInfoDict:(NSDictionary *)dict;

//列表页标题字号
+ (BOOL)cellViewTitleFontSizeControllable;
+ (CGFloat)cellViewTitleFontSize;
//列表页标题颜色
+ (BOOL)cellViewTitleColorControllable;
+ (UIColor *)cellViewTitleColor;
+ (NSArray *)cellViewTitleColors;
+ (UIColor *)cellViewHighlightedtTitleColor;
+ (NSArray *)cellViewHighlightedtTitleColors;
//列表页cell背景色
+ (BOOL)cellViewBackgroundColorControllable;
+ (UIColor *)cellViewBackgroundColor;
+ (NSArray *)cellViewBackgroundColors;
+ (UIColor *)cellViewHighlightedBackgroundColor;
+ (NSArray *)cellViewHighlightedBackgroundColors;


//详情页标题字号
+ (BOOL)detailViewTitleFontSizeControllable;
+ (CGFloat)detailViewTitleFontSize;
//详情页正文字号
+ (BOOL)detailViewBodyFontSizeControllable;
+ (CGFloat)detailViewBodyFontSize;
//详情页标题颜色
+ (UIColor *)detailViewTitleColor;
//详情页正文颜色
+ (UIColor *)detailViewBodyColor;
+ (NSArray *)detailViewBodyColors;
//详情页背景色
+ (BOOL)detailViewBackgroundColorControllable;
+ (UIColor *)detailViewBackgroundColor;
+ (NSArray *)detailViewBackgroundColors;
//详情页浮层相关阅读的字号
+ (BOOL)detailViewNatantFontSizeControllable;
+ (CGFloat)detailViewNatantFontSize;
//详情页评论cell评论和回复评论的字号
+ (BOOL)detailViewCommentFontSizeControllable;
+ (CGFloat)detailViewCommentFontSize;
//详情页评论cell用户名字号
+ (BOOL)detailViewCommentUserNameFontSizeControllable;
+ (CGFloat)detailViewCommentUserNameFontSize;
//详情页评论cell回复评论用户名字号
+ (BOOL)detailViewCommentReplyUserNameFontSizeControllable;
+ (CGFloat)detailViewCommentReplyUserNameFontSize;
//详情页评论cell用户名字色
+ (BOOL)detailViewCommentUserNameColorControllable;
+ (UIColor *)detailViewCommentUserNameColor;
+ (NSArray *)detailViewCommentUserNameColors;
//详情页评论cell评论内容字色
+ (BOOL)detailViewCommentContentLabelColorControllable;
+ (UIColor *)detailViewCommentContentLabelColor;
+ (NSArray *)detailViewCommentContentLabelColors;
//详情页评论cell回复评论内容字色
+ (BOOL)detailViewCommentReplyContentColorControllable;
+ (UIColor *)detailViewCommentReplyContentColor;
+ (NSArray *)detailViewCommentReplyContentColors;
//详情页评论cell回复评论用户名颜色
+ (BOOL)detailViewCommentReplyUserNameColorControllable;
+ (UIColor *)detailViewCommentReplyUserNameColor;
+ (NSArray *)detailViewCommentReplyUserNameColors;
//详情页评论cell回复评论背景颜色
+ (BOOL)detailViewCommentReplyBackgroundColorControllable;
+ (UIColor *)detailViewCommentReplyBackgroundColor;
+ (NSArray *)detailViewCommentReplyBackgroundeColors;


//频道导航背景色
+ (BOOL)categoryViewBackgroundColorControllable;
+ (UIColor *)categoryViewBackgroundColor;
//频道导航字号
+ (BOOL)categoryViewFontSizeControllable;
+ (CGFloat)categoryViewFontSize;
+ (CGFloat)categoryViewSelectedFontSize;
//频道导航间距
+ (BOOL)categoryViewMarginControllable;


//tabBar名称
+ (BOOL)tabBarViewTabNameArrayControllable;
+ (NSArray *)tabBarViewTabNameArray;
//tabBar背景色
+ (BOOL)tabBarViewBackgroundColorControllable;
+ (UIColor *)tabBarViewBackgroundColor;
@end

//
//  TTCategorySelectorView.h
//  Article
//
//  Created by Dianwei on 13-6-25.
//
//

#import "SSViewBase.h"
#import "TTCategory.h"
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"

typedef NS_ENUM(NSInteger, TTCategorySelectorViewStyle){
    TTCategorySelectorViewBlackStyle,
    TTCategorySelectorViewWhiteStyle,
    TTCategorySelectorViewVideoStyle,
    TTCategorySelectorViewLightStyle,//5.5.1小版本新增
    TTCategorySelectorViewNewVideoStyle,//用于适配有topBar的video
};

typedef NS_ENUM(NSInteger, TTCategorySelectorViewTabType) {
    TTCategorySelectorViewNewsTab,
    TTCategorySelectorViewVideoTab,
    TTCategorySelectorViewPhotoTab, // iPad图片tab
    TTCategorySelectorViewNewVideoTab, //用于适配有topBar的video
};

@class TTCategorySelectorView;

@protocol TTCategorySelectorViewDelegate <NSObject>

- (void)categorySelectorView:(TTCategorySelectorView *)selectorView selectCategory:(TTCategory*)category;

@optional
- (void)categorySelectorView:(TTCategorySelectorView *)selectorView didClickExpandButton:(UIButton *)expandButton;
- (void)categorySelectorView:(TTCategorySelectorView *)selectorView didClickSearchButton:(UIButton *)searchButton;
- (void)categorySelectorView:(TTCategorySelectorView *)selectorView closeCategoryView:(BOOL)animated;

/**
 *  每一项item字体颜色
 *
 *  @return 颜色数组，第一个是正常颜色日间，第二个是正常颜色夜间，第三个是高亮日间，第四个是高亮夜间
 */
- (NSArray <NSString *> *)categorySelectorTextColors;
/**
 *  每一项item发光颜色
 *
 *  @return 颜色数组，第一个是正常颜色日间，第二个是正常颜色夜间，第三个是高亮日间，第四个是高亮夜间
 */
- (NSArray <NSString *> *)categorySelectorTextGlowColors;
/**
 *  发光范围
 *
 *  @return 每一项文字的发光范围
 */
- (CGFloat)categorySelectorTextGlowSize;

@end

@interface TTCategorySelectorView : SSThemedView

- (instancetype)initWithFrame:(CGRect)frame
                        style:(TTCategorySelectorViewStyle)style
                      tabType:(TTCategorySelectorViewTabType)tabType;

- (void)refreshWithCategories:(NSArray*)categories;
- (void)selectCategory:(TTCategory *)category;
- (void)moveSelectFrameFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex percentage:(CGFloat)percentage;
- (BOOL)isCategoryVisible:(NSString *)categoryID;
- (BOOL)isCategoryInFirstScreen:(NSString*)categoryID;
- (BOOL)isCategoryShowBadge:(NSString *)categoryId;
- (UIView *)categorySelectorButtonByCategoryId:(NSString *)categoryId;
- (void)scrollToCategory:(TTCategory *)category;
- (void)hideExpandButton;
- (NSString *)categoryId;

+ (CGFloat)channelFontSizeWithStyle:(TTCategorySelectorViewStyle)style tabType:(TTCategorySelectorViewTabType)tabType;
+ (CGFloat)channelSelectedFontSizeWithStyle:(TTCategorySelectorViewStyle)style tabType:(TTCategorySelectorViewTabType)tabType;

@property (nonatomic, weak) id<TTCategorySelectorViewDelegate> delegate;
@property (nonatomic, strong, readonly)TTAlphaThemedButton *expandButton;
@property (nonatomic, strong, readonly)TTAlphaThemedButton *searchButton;
@property (nonatomic, strong, readonly) SSThemedImageView *rightBorderIndicatorView;
@property (nonatomic, strong) TTCategory *currentSelectedCategory;

@property (nonatomic, strong) NSArray *categories;

@end



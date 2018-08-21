//
//  ArticleCategorySubscribeCell.h
//  Article
//
//  Created by Dianwei on 14-9-14.
//
//

#import "SSViewBase.h"
#import "SSThemed.h"
#import "TTCategory.h"

@class ArticleCategorySubscribeCell;

static int const kCellNumberPerRow = 4;

@protocol ArticleCategorySubscribeCellDelegate <NSObject>

- (void)categoryCellDidClicked:(ArticleCategorySubscribeCell *)cell;
- (void)closeButtonClicked:(ArticleCategorySubscribeCell *)cell;
@end

@interface ArticleCategorySubscribeCell : SSThemedView

@property(nonatomic, weak)id<ArticleCategorySubscribeCellDelegate>delegate;
@property(nonatomic, strong)SSThemedButton * bgButton;
@property(nonatomic, strong)SSThemedLabel * titleLabel;
@property(nonatomic, strong)TTCategory * model;
@property(nonatomic, strong)SSThemedImageView * tipNewView;
@property(nonatomic, assign, getter=isEditing)BOOL editing;
@property(nonatomic, strong)UIButton *closeButton;
//@property(nonatomic, strong)CAShapeLayer *dashBorderLayer;
@property(nonatomic, assign,getter=isBadgeShown)BOOL showBadge;

- (void)refreshCategoryModel:(TTCategory *)model;
- (void)showTipNewIfNeed;

- (void)refreshDraggingStatus:(BOOL)isDragging;
- (BOOL)isCanNotChangeCell;
//- (BOOL)isDraggingStatus;

+ (CGFloat)articleCategorySubscribeCellWidth;
+ (CGFloat)articleCategorySubscribeCellHeight;
+ (CGFloat)articleCategorySubscribeCellTitleFontSizeWithText:(NSString *)titleText;
+ (CGFloat)articleCategorySubscribeCellTitleFontSizeWithCategory:(TTCategory *)category;

@end

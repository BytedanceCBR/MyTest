//
//  TTTagView.h
//  Article
//
//  Created by 王霖 on 4/19/16.
//
//

#import "SSThemed.h"

@class TTTagItem;
@class TTTagViewConfig;
@class ObjectType;

typedef NS_ENUM(NSUInteger, TTTagViewAlignment) {
    TTTagViewAlignmentJustified,//两端对齐
    TTTagViewAlignmentLeft,//左端对齐
    TTTagViewAlignmentCenter//居中对齐
};

@interface TTTagView : SSThemedView
NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, assign)            NSUInteger rowNumber;/*tag行数限制。0表示无限制*/
@property (nonatomic, copy, readonly)  TTTagViewConfig *config;/*行间距左右边距等位置信息配置*/
@property (nonatomic, strong, readonly)  UICollectionView *tagCollectionView;
@property (nonatomic, strong)            UIView *headerView;/*整个视图的headerView*/
@property (nonatomic, strong)            UIView *footerView;/*整个视图的footerView*/
/**
 *  返回TTTagView的一个实例，并指定样式
 *
 *  @param frame     视图frame
 *  @param config    一些必要的配置信息，如上下左右边距，cell之间的行间距和列间距等
 *  @param alignment 对齐方式
 *
 *  @return 本类实例
 */
- (instancetype)initWithFrame:(CGRect)frame configuration:(TTTagViewConfig *)config alignment:(TTTagViewAlignment)alignment NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
/**
 *  刷新所有cell视图的数据源
 *
 *  @param tagItems 一维数组或者二维数组 一维数组只有一个section 二维数组对应多个section
 */
- (void)refreshWithTagItems:(NSMutableArray <ObjectType *> *)tagItems;
/**
 *  插入部分cell视图的数据源
 *
 *  @param items 一维数组或者二维数组 一维数组对应插入items 二维数组对应插入sections
 *  @param item  哪个视图的数据源被点击了
 */
- (void)insertTagItems:(NSMutableArray <ObjectType *> *)items afterItem:(TTTagItem *)item needScroll:(BOOL)needScroll finishBlock:(void(^)(BOOL autoScroll))finishBlock;

- (void)registerCellButtonClass:(Class)clazz;
NS_ASSUME_NONNULL_END

@end

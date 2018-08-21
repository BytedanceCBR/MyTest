//
//  FRIconView.h
//  Article
//
//  Created by 王霖 on 5/26/16.
//
//

#import "SSThemed.h"

@class TTImageInfosModel;

NS_ASSUME_NONNULL_BEGIN
@interface FRIconView : SSThemedView

/**
 *  icon限高。默认是1.f
 */
@property (nonatomic, assign) CGFloat iconLimitHeight;

/**
 *  icon间距。默认是8.f
 */
@property (nonatomic, assign) CGFloat iconPadding;

/**
 *  指定初始化器
 *
 *  @param frame frame
 *
 *  @return FRIconView实例
 */
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

/**
 *  指定初始化器
 *
 *  @param aDecoder aDecoder
 *
 *  @return FRIconView实例
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 *  使用新的icon models刷新
 *
 *  @param iconModels iconModels
 */
- (void)refreshWithIconModels:(NSArray <TTImageInfosModel *> *)iconModels;

@end
NS_ASSUME_NONNULL_END


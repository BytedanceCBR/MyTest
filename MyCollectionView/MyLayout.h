//
//  MyLayout.h
//  MyCollectionView
//
//  Created by bytedance on 2021/2/7.
//

#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>
NS_ASSUME_NONNULL_BEGIN

@class MyLayout;

@protocol WaterFlowLayoutDelegate <NSObject>

@required
- (CGFloat)waterflowLayout:(MyLayout *)waterflowLayout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth;
@optional
- (CGFloat)columnCountInWaterflowLayout:(MyLayout *)waterflowLayout;
- (CGFloat)columnMarginInWaterflowLayout:(MyLayout *)waterflowLayout;
- (CGFloat)rowMarginInWaterflowLayout:(MyLayout *)waterflowLayout;
- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(MyLayout *)waterflowLayout;

@end
@interface MyLayout : UICollectionViewLayout

@property(nonatomic,weak) id<WaterFlowLayoutDelegate> delegate;
@end

NS_ASSUME_NONNULL_END

//
//  FHIndexSectionView.h
//  FHHouseHome
//
//  Created by 张元科 on 2019/1/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHIndexSectionView;

@protocol FHIndexSectionDelegate <NSObject>

- (void)indexSectionView:(FHIndexSectionView *)view didSelecteedTitle:(NSString *)title atSectoin:(NSInteger)section;
// 用于禁止页面VC的滑动手势
- (void)indexSectionViewTouchesBegin;
- (void)indexSectionViewTouchesEnd;

@end

@interface FHIndexSectionView : UIView

@property (nonatomic, weak) id<FHIndexSectionDelegate> delegate;
@property (nonatomic, assign) NSUInteger numberOfSections;

- (id)initWithTitles:(NSArray *)titles topOffset:(CGFloat)topOffset;

@end

NS_ASSUME_NONNULL_END

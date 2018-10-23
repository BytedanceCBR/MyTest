 //
//  FRPhotoBrowserCell.h
//  Article
//
//  Created by 王霖 on 17/1/18.
//
//

#import <UIKit/UIKit.h>

extern const NSTimeInterval kAnimationDuration;

@class FRPhotoBrowserModel;
@class FRPhotoBrowserCell;

NS_ASSUME_NONNULL_BEGIN

@protocol FRPhotoBrowserCellDelegate <NSObject>

@optional
- (void)showCompleteWithModel:(FRPhotoBrowserModel *)model;
- (void)hideCompleteWithModel:(FRPhotoBrowserModel *)model;

- (void)tapPhotoBrowserCell:(FRPhotoBrowserCell *)cell;

@end

@interface FRPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, weak) id <FRPhotoBrowserCellDelegate> delegate;
@property (nonatomic,readonly)BOOL isGIF;

- (void)refreshWithModel:(FRPhotoBrowserModel *)model;
- (void)showModel;

- (void)show;
- (void)hide;

- (void)savePhoto;

+ (CAMediaTimingFunction *)getAnimationTimingFunction;
- (UIImageView *)getImageView;
- (void)resetImageViews;//用于随手拖动手势，隐藏不必要视图;
@end

NS_ASSUME_NONNULL_END

//
//  AWEVideoContainerAdCollectionViewCell.h
//  Pods
//
//  Created by Zuyang Kou on 19/06/2017.
//
//

#import <UIKit/UIKit.h>

#import "AWEVideoPlayView.h"
#import "TSVControlOverlayViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class TTShortVideoModel;

@interface AWEVideoContainerAdCollectionViewCell : UICollectionViewCell

@property (nonatomic, nullable, readonly) AWEVideoPlayView *videoPlayView;
@property (nonatomic, nullable, strong, readonly) TTShortVideoModel *videoDetail;
@property (nonatomic, assign) CGFloat spacingMargin;
@property (nonatomic, nullable, strong) UIViewController<TSVControlOverlayViewController> *overlayViewController;

@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;
@property (nonatomic, readonly) NSTimeInterval totalPlayTime;

@property (nonatomic, copy, nullable) void (^videoDidStartPlay)(void);
@property (nonatomic, copy, nullable) void (^videoDidPlayOneLoop)(void);

- (void)updateWithModel:(TTShortVideoModel *)videoDetail usingFirstFrameCover:(BOOL)usingFirstFrameCover;
- (void)cellWillDisplay;

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

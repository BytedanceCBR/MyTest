//
//  AWEVideoContainerCollectionViewCell.h
//  Pods
//
//  Created by Zuyang Kou on 19/06/2017.
//
//

#import <UIKit/UIKit.h>

#import "AWEVideoPlayView.h"
#import "TSVControlOverlayViewController.h"

@class TTShortVideoModel, AWEVideoDetailControlOverlayViewController;

@interface AWEVideoContainerCollectionViewCell : UICollectionViewCell

@property (nonatomic, nullable, readonly) AWEVideoPlayView *videoPlayView;
@property (nonatomic, nullable, strong, readonly) TTShortVideoModel *videoDetail;
@property (nonatomic, assign) CGFloat spacingMargin;
@property (nonatomic, nullable, strong) UIViewController<TSVControlOverlayViewController> *overlayViewController;

@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;
@property (nonatomic, readonly) NSTimeInterval totalPlayTime;

@property (nonatomic, copy, nullable) void (^videoDidStartPlay)();
@property (nonatomic, copy, nullable) void (^videoDidPlayOneLoop)();

- (void)updateWithModel:(TTShortVideoModel * _Nonnull)videoDetail usingFirstFrameCover:(BOOL)usingFirstFrameCover;
- (void)cellWillDisplay;

@end

//
//  FHUGCShortVideoFullScreenCell.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/10/13.
//

#import <UIKit/UIKit.h>
#import "TTVCellPlayMovieProtocol.h"
#import "FHFeedUGCCellModel.h"
#import "FHUGCShortVideoView.h"
#import "TSVControlOverlayViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHUGCShortVideoFullScreenCell : UICollectionViewCell
@property (nonatomic, weak) NSObject <TTVCellPlayMovieDelegate> *delegate;
@property (nonatomic, strong) FHUGCShortVideoView *playerView;
@property (nonatomic, strong) FHFeedUGCCellModel *cellModel;
@property (nonatomic, nullable, strong) UIViewController<TSVControlOverlayViewController> *overlayViewController;

@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;
@property (nonatomic, readonly) NSTimeInterval totalPlayTime;

@property (nonatomic, copy, nullable) void (^videoDidStartPlay)(void);
@property (nonatomic, copy, nullable) void (^videoDidPlayOneLoop)(void);

- (void)updateWithModel:(FHFeedUGCCellModel *)videoDetail;
- (void)cellWillDisplay;
- (void)play;
- (void)pause;
- (void)stop;
- (void)reset;
- (void)readyToPlay;
- (void)resetPlayerModel;
@end

NS_ASSUME_NONNULL_END

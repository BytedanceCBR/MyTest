//
//  TTVFullscreeenController.h
//  Article
//
//  Created by panxiang on 2017/5/25.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerProtocol.h"
#import "TTVFullscreenProtocol.h"
#import "TTVPlayerOrientation.h"
#import <UIKit/UIKit.h>

@class TTVPlayerStateStore;
@interface TTVFullscreeenController : NSObject<TTVPlayerContext ,TTVPlayerOrientation ,TTVFullscreenPlayerProtocol,TTVPlayerOrientation>
@property (nonatomic, weak) id<TTVOrientationDelegate> delegate;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, weak) UIView *rotateView;

/**
 非cell上播放的视频使用
 */
@property(nonatomic, weak ,readonly) UIView *movieFatherView;

/**
 cell上播放视频使用
 */
@property(nonatomic, assign ,readonly) BOOL hasMovieFatherCell;
@property(nonatomic, weak ,readonly) UITableView *movieFatherCellTableView;
@property(nonatomic, copy ,readonly) NSIndexPath *movieFatherCellIndexPath;

- (void)forceStoppingMovie;


- (void)enterFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;
- (void)exitFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;

@end

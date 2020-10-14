//
//  TSVControlOverlayViewController.h
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 11/12/2017.
//

#import <Foundation/Foundation.h>
#import "IESVideoPlayerProtocol.h"
#import "ExploreMovieMiniSliderView.h"
@class TSVControlOverlayViewModel;

@protocol TSVControlOverlayViewController <NSObject>

@property (nonatomic, strong, nullable) TSVControlOverlayViewModel *viewModel;
@property (weak, nonatomic, nullable) id<IESVideoPlayerProtocol> playerController;
@property(nonatomic, strong, nullable)ExploreMovieMiniSliderView * miniSlider;
@property (nonatomic, strong) TTVPlayerStateStore * _Nullable playerStateStore;
@end

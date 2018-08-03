//
//  TTVDemandPlayerContextVideo.m
//  Article
//
//  Created by panxiang on 2017/9/18.
//
//

#import "TTVDemandPlayerContextVideo.h"
#import "TTVVideoPlayerStateModel.h"

@interface TTVDemandPlayerContextVideo ()
@property (nonatomic, weak) TTVVideoPlayerStateModel *state;
@end

@implementation TTVDemandPlayerContextVideo

- (void)setPlayerStateModel:(TTVVideoPlayerStateModel *)state
{
    self.state = state;
}

- (BOOL)isCommodityViewShow
{
    return self.state.isCommodityViewShow;
}

- (BOOL)midADIsPlaying
{
    return self.state.midADIsPlaying;
}

@end

//
//  TTVVideoPlayerStateModel.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVVideoPlayerStateModel.h"
@implementation TTVVideoPlayerStateModel
@dynamic playerModel;

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setPasterADIsPlaying:(BOOL)pasterADIsPlaying
{
    _pasterADIsPlaying = pasterADIsPlaying;
    self.disableTrafficAlert = pasterADIsPlaying;
}

- (void)setMidADIsPlaying:(BOOL)midADIsPlaying
{
    _midADIsPlaying = midADIsPlaying;
    self.disableTrafficAlert = midADIsPlaying;
}

- (void)updateDisableExitFullScreenWhenPlayEnd
{
    self.disableExitFullScreenWhenPlayEnd = (self.pasterADPreFetchValid && !self.pasterAdShowed);
}

- (void)setPasterADPreFetchValid:(BOOL)pasterADPreFetchValid
{
    _pasterADPreFetchValid = pasterADPreFetchValid;
    [self updateDisableExitFullScreenWhenPlayEnd];
}

- (void)setPasterAdShowed:(BOOL)pasterAdShowed
{
    _pasterAdShowed = pasterAdShowed;
    [self updateDisableExitFullScreenWhenPlayEnd];
}

- (void)setPastarADEnableRotate:(BOOL)pastarADEnableRotate
{
    _pastarADEnableRotate = pastarADEnableRotate;
    self.enableRotateWhenPlayEnd = pastarADEnableRotate;
}

@end



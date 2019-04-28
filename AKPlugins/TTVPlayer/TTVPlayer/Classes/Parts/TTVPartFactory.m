//
//  TTVPartFactory.m
//  ScreenRotate
//
//  Created by lisa on 2019/3/26.
//  Copyright © 2019 zuiye. All rights reserved.
//

#import "TTVPartFactory.h"
#import "TTVConfiguredControlPart.h"
#import "TTVPlayPart.h"
#import "TTVConfiguredGesturePart.h"
#import "TTVSeekPart.h"
#import "TTVNetworkMonitorSimplePart.h"
#import "TTVPlayerFinishPart.h"
#import "TTVLoadingPart.h"
#import "TTVConfiguredBarPart.h"
#import "TTVBackPart.h"
#import "TTVTitlePart.h"
#import "TTVConfiguredRotateToFullPart.h"
#import "TTVLockPart.h"
#import "TTVSpeedPart.h"

@interface TTVPartFactory ()

@end

@implementation TTVPartFactory

- (NSObject<TTVPlayerPartProtocol> *)createPartForKey:(TTVPlayerPartKey)key{
    NSObject<TTVPlayerPartProtocol>* part;
    if ([self.customPartDelegate respondsToSelector:@selector(customPartForKey:)]) {
        part = [self.customPartDelegate customPartForKey:key];
        if (part && part.key != 0) {
            return part;
        }
        else {
            return [self customPartForKey:key];
        }
    }
    else {
        return [self customPartForKey:key];
    }

    return nil;
}

#pragma mark - TTVPlayerCustomPartDelegate 默认都是带 config 的 part
- (NSObject<TTVPlayerPartProtocol> *)customPartForKey:(TTVPlayerPartKey)key {
    if (key == TTVPlayerPartKey_Play) {
        TTVConfiguredControlPart * part = [[TTVConfiguredControlPart alloc] initWithPart:[[TTVPlayPart alloc] init] controlFactory:self.controlFactory];
        return part;
    }
    else if (key == TTVPlayerPartKey_Gesture) {
        TTVConfiguredGesturePart * part = [[TTVConfiguredGesturePart alloc] init];
        return part;
    }
    else if (key == TTVPlayerPartKey_Seek) {
        TTVConfiguredControlPart * part = [[TTVConfiguredControlPart alloc] initWithPart:[[TTVSeekPart alloc] init] controlFactory:self.controlFactory];
        return part;
    }
    else if (key == TTVPlayerPartKey_PlayerFinish) {
        TTVPlayerFinishPart * part = [[TTVPlayerFinishPart alloc] init];
        return part;
    }
    else if (key == TTVPlayerPartKey_Loading) {
        TTVLoadingPart * part = [[TTVLoadingPart alloc] init];
        return part;
    }
    else if (key == TTVPlayerPartKey_NetworkMonitor) {
        TTVNetworkMonitorSimplePart * part = [[TTVNetworkMonitorSimplePart alloc] init];
        return part;
    }
    else if (key == TTVPlayerPartKey_Bar) {
        TTVConfiguredBarPart * part = [[TTVConfiguredBarPart alloc] init];
        return part;
    }
    else if (key == TTVPlayerPartKey_Back) {
        TTVConfiguredControlPart * part = [[TTVConfiguredControlPart alloc] initWithPart:[[TTVBackPart alloc] init] controlFactory:self.controlFactory];
        return part;
    }
    else if (key == TTVPlayerPartKey_Title) {
        TTVConfiguredControlPart * part = [[TTVConfiguredControlPart alloc] initWithPart:[[TTVTitlePart alloc] init] controlFactory:self.controlFactory];
        return part;
    }
    else if (key == TTVPlayerPartKey_Full) {
        TTVConfiguredRotateToFullPart * part = [[TTVConfiguredRotateToFullPart alloc] initWithControlFactory:self.controlFactory];
        return part;
    }
    else if (key == TTVPlayerPartKey_Lock) {
        TTVConfiguredControlPart * part = [[TTVConfiguredControlPart alloc] initWithPart:[[TTVLockPart alloc] init] controlFactory:self.controlFactory];
        return part;
    }
    if (key == TTVPlayerPartKey_Speed) {
        TTVConfiguredControlPart * part = [[TTVConfiguredControlPart alloc] initWithPart:[[TTVSpeedPart alloc] init]];
        return part;
    }
    return nil;
}

@end

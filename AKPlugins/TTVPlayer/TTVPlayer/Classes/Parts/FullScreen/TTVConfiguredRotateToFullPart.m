//
//  TTVConfiguredRotateToFullPart.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/6.
//

#import "TTVConfiguredRotateToFullPart.h"
#import "TTVFullScreenPart.h"

@implementation TTVConfiguredRotateToFullPart

- (instancetype)initWithConfig:(NSDictionary *)config controlFactory:(TTVPlayerControlViewFactory *)controlFactory {
    TTVFullScreenPart * part = [[TTVFullScreenPart alloc] init];
    self = [super initWithPart:part config:config controlFactory:controlFactory];
    return self;
}

- (instancetype)initWithControlFactory:(TTVPlayerControlViewFactory *)controlFactory {
    TTVFullScreenPart * part = [[TTVFullScreenPart alloc] init];
    self = [super initWithPart:part controlFactory:controlFactory];
    return self;
}

- (void)applyConfigOfPart {
    if (self.configOfPart.count == 0) {
        return;
    }
    // 应用control 的 config
//    AutoRotateEnabled
    [super applyConfigOfPart];
    
    
   
    BOOL autoRatateEnabled = [self.configOfPart[@"AutoRotateEnabled"] boolValue];
    if (!autoRatateEnabled && self.configOfPart[@"AutoRotateEnabled"]) {
        [self.playerStore dispatch:[self.playerAction enableAutoRotate:autoRatateEnabled]];
        
    }
    
}

@end

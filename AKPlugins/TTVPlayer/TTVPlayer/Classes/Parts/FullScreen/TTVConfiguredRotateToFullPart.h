//
//  TTVConfiguredRotateToFullPart.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/6.
//

#import "TTVConfiguredControlPart.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVConfiguredRotateToFullPart : TTVConfiguredControlPart

- (instancetype)initWithConfig:(NSDictionary *)config controlFactory:(TTVPlayerControlViewFactory *)controlFactory;
- (instancetype)initWithControlFactory:(TTVPlayerControlViewFactory *)controlFactory;

@end

NS_ASSUME_NONNULL_END

//
//  TTVConfiguredPart.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/30.
//

#import <UIKit/UIkit.h>
#import "TTVPlayerPartProtocol.h"
#import "TTVReduxKit.h"
#import "TTVPlayerContextNew.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVConfiguredPart : NSObject<TTVConfigedPartProtocol, TTVReduxStateObserver, TTVPlayerContextNew>

- (instancetype)initWithPart:(NSObject <TTVPlayerPartProtocol> *)part config:(NSDictionary *)config;
- (instancetype)initWithPart:(NSObject<TTVPlayerPartProtocol> *)part;

@end

NS_ASSUME_NONNULL_END

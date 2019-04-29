//
//  TTVTipPart.h
//  TTVPlayer
//
//  Created by lisa on 2019/2/11.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContexts.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVPlayerFinishPart : NSObject<TTVPlayerContexts, TTVReduxStateObserver, TTVPlayerPartProtocol>

@end

NS_ASSUME_NONNULL_END

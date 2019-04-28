//
//  TTVTipPart.h
//  TTVPlayer
//
//  Created by lisa on 2019/2/11.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContextNew.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVPlayerFinishPart : NSObject<TTVPlayerContextNew, TTVReduxStateObserver, TTVPlayerPartProtocol>

@end

NS_ASSUME_NONNULL_END

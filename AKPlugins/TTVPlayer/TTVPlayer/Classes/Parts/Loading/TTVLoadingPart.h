//
//  TTVLoadingPart.h
//  TTVPlayer
//
//  Created by lisa on 2019/2/11.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContexts.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerCustomViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVLoadingPart : NSObject<TTVPlayerContexts, TTVReduxStateObserver, TTVPlayerPartProtocol>

@property (nonatomic, strong, readonly) UIView <TTVPlayerLoadingViewProtocol> *loadingView; // loadingView， 如果是空的则返回默认的

@end

NS_ASSUME_NONNULL_END

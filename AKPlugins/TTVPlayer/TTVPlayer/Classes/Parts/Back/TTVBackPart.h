//
//  TTVBackPart.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/1.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContexts.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerCustomViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVBackPart : NSObject<TTVPlayerContexts, TTVReduxStateObserver, TTVPlayerPartProtocol>

@property (nonatomic, strong) UIView<TTVButtonProtocol> * backButton;

@end

NS_ASSUME_NONNULL_END

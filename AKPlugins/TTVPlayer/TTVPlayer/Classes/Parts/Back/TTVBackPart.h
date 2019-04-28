//
//  TTVBackPart.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/1.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContextNew.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerCustomViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVBackPart : NSObject<TTVPlayerContextNew, TTVReduxStateObserver, TTVPlayerPartProtocol>

@property (nonatomic, strong) UIView<TTVButtonProtocol> * backButton;

@end

NS_ASSUME_NONNULL_END

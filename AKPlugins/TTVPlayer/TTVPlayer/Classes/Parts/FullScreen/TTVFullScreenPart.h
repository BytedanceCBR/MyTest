//
//  TTVFullScreenPart.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/11.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContextNew.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerCustomViewDelegate.h"


NS_ASSUME_NONNULL_BEGIN

@interface TTVFullScreenPart : NSObject<TTVPlayerContextNew, TTVReduxStateObserver, TTVPlayerPartProtocol>

/// 全屏button
@property (nonatomic, strong) UIView<TTVToggledButtonProtocol> * fullButton;


@end

NS_ASSUME_NONNULL_END

//
//  TTVTitlePart.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/1.
//

#import <UIKit/UIkit.h>
#import "TTVPlayerContexts.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVTitlePart : NSObject<TTVPlayerContexts, TTVReduxStateObserver, TTVPlayerPartProtocol>

@property (nonatomic, strong) UILabel * titleLabel;
@end

NS_ASSUME_NONNULL_END

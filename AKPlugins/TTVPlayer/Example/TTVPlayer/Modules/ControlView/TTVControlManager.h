//
//  TTVControlManager.h
//  Article
//
//  Created by panxiang on 2018/8/29.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStore.h"
#import "TTVPlayerStateControl.h"

@interface TTVControlManager : NSObject<TTVPlayerContext>
- (void)showControlView:(BOOL)show;

//- (instancetype)initWithControlView:(UIView<TTVPlayerControlViewProtocol> *)controlView;
@end

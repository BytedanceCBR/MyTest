//
//  TTVBackPart.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/1.
//

#import "TTVBackPart.h"
#import "TTVPlayer.h"
#import "TTVPlayerState.h"
#import "TTVPlayer+Engine.h"

@implementation TTVBackPart

@synthesize playerStore, player, playerAction;

- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
}

#pragma mark - TTVPlayerPartProtocol
- (UIView *)viewForKey:(NSUInteger)key {
    if (key == TTVPlayerPartControlKey_BackButton) {
        return self.backButton;
    }
    return nil;
}

- (void)setControlView:(UIView *)controlView forKey:(TTVPlayerPartControlKey)key {
    if (key == TTVPlayerPartControlKey_BackButton) {
        self.backButton = (UIView<TTVButtonProtocol> *)controlView;
        self.backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        
        // 设置默认 action, 但是外界可能没实现这个 action
        BOOL shouldImplementTouchupInsideBlock;
        if (![self.backButton respondsToSelector:@selector(setAction:)]
            && ![self.backButton respondsToSelector:@selector(action)]) {
            shouldImplementTouchupInsideBlock = YES;
        }
        else if (![self.backButton action]){
            shouldImplementTouchupInsideBlock = YES;
        }
        if (shouldImplementTouchupInsideBlock) {
            @weakify(self);
            self.backButton.didButtonTouchUpInside = ^{
                @strongify(self);
                [self.playerStore dispatch:[self.playerAction actionForKey:TTVPlayerActionType_Back]];
            };
        }
    }
}

- (void)removeAllControlView {
    [self.backButton removeFromSuperview];
}

- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_Back;
}

@end

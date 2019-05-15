//
//  TTVBarPart.m
//  TTVPlayer
//
//  Created by lisa on 2019/2/15.
//

#import "TTVConfiguredBarPart.h"
#import "TTVPlayer.h"

@implementation TTVConfiguredBarPart

@synthesize playerStore, player, customBundle;

- (void)applyConfigOfPart {
    // 设置当前状态下的 config，当切换的时候，可以修改 config，改了 config 需要重新加载
    [[self.configOfPart[@"Controls"] allValues] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull control, NSUInteger idx, BOOL * _Nonnull stop) {
        TTVPlayerPartControlKey controlKey = [control[@"Tag"] integerValue];
        if (controlKey > 0) { // 说明有效
            NSString * controlType = control[@"Type"];
            if ([controlType isEqualToString:TTVPlayerPartControlType_BottomToolBar]) {
                [self bar:(TTVPlayerBottomToolBar *)self.player.controlView.bottomBar applyConfig:control];
                [self bar:(TTVPlayerBottomToolBar *)self.player.containerView.playbackControlView_Lock.bottomBar applyConfig:control];
            }
            else if ([controlType isEqualToString:TTVPlayerPartControlType_TopNavBar]) {
                [self bar:(TTVPlayerBottomToolBar *)self.player.controlView.topBar applyConfig:control];
                [self bar:(TTVPlayerBottomToolBar *)self.player.containerView.playbackControlView_Lock.topBar applyConfig:control];
            }  
        }
    }];
}
- (void)bar:(TTVPlayerBottomToolBar *)bar applyConfig:(NSDictionary *)config {
    UIImage * image = [UIImage imageNamed:config[@"BackgroundImage"] inBundle:self.customBundle compatibleWithTraitCollection:nil];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
    // 不提供默认图片了，从外部默认的 plist 来设置
    [bar.backgroundImageView setImage:image];
    
    bar.backgroundColor = [TTVPlayerUtility colorWithHexString:config[@"BackgroundColor"]];
}
#pragma mark - TTVPlayerPartProtocol
- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_Bar;
}

- (void)stateDidChangedToNew:(NSObject<TTVReduxStateProtocol> *)newState lastState:(NSObject<TTVReduxStateProtocol> *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    ;
}

@end



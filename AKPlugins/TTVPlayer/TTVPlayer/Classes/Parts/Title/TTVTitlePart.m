//
//  TTVBackPart.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/1.
//

#import "TTVTitlePart.h"
#import "TTVPlayer.h"
#import "TTVPlayerState.h"
#import "TTVPlayer+Engine.h"

@implementation TTVTitlePart
@synthesize playerStore, player, playerAction;

- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    
    if (!isEmptyString(newState.videoTitle) && ![newState.videoTitle isEqualToString:lastState.videoTitle]) {
    
        [self.titleLabel setText:newState.videoTitle];
//        UIFont * labelFont;
//        if (@available(iOS 8.2, *)) {
//            labelFont = [UIFont systemFontOfSize:[TTVPlayerUtility tt_fontSize:newState.fullScreenState.isFullScreen?self.titleFontSizeOnFull:self.titleFontSizeOnNormal] weight:UIFontWeightMedium];
//        } else {
//            // Fallback on earlier versions
//            labelFont = [UIFont systemFontOfSize:[TTVPlayerUtility tt_fontSize:newState.fullScreenState.isFullScreen?self.titleFontSizeOnFull:self.titleFontSizeOnNormal]];
//        }
//        newState.fullScreenState.isFullScreen ? labelFont : [TTVPlayerUtility ttv_distinctTitleFont];
//
//        if (newState.fullScreenState.isFullScreen) {
//            self.navigationBar.defaultTitleLable.font = labelFont;
//            if (self.navigationBar.defaultTitleHasShadow) {
//                self.navigationBar.defaultTitleLable.attributedText = [[self class] attributedVideoTitleFromString:newState.videoTitle fontSize:self.titleFontSizeOnNormal];
//            }
//            else {
//                self.navigationBar.defaultTitleLable.text = newState.videoTitle;
//            }        self.navigationBar.verticalAlign = self.verticalAlignOnFull;
//            [self.navigationBar.defaultBackButton setImage:[self defaultBackImageOnFull] forState:UIControlStateNormal];
//            self.navigationBar.defaultTitleLable.numberOfLines = self.titleNumberOfLinesOnFull;
//
//        } else {
//            self.navigationBar.defaultTitleLable.text = nil;
//            self.navigationBar.defaultTitleLable.font = labelFont;
//            if (self.navigationBar.defaultTitleHasShadow) {
//                self.navigationBar.defaultTitleLable.attributedText = [[self class] attributedVideoTitleFromString:newState.videoTitle fontSize:self.titleFontSizeOnNormal];
//
//            }
//            else {
//                self.navigationBar.defaultTitleLable.text = newState.videoTitle;
//            }
//            self.navigationBar.verticalAlign = self.verticalAlignOnNormal;
//            [self.navigationBar.defaultBackButton setImage:[self defaultBackImageOnNormal] forState:UIControlStateNormal];
//            self.navigationBar.defaultTitleLable.numberOfLines = self.titleNumberOfLinesOnNormal;
        
        
    }
    
    // 动画
    //    if (self.showAnimationEnabled) {
    //        if (self.controlViewShowed != state.controlViewState.isShowed) {
    //            self.controlViewShowed = state.controlViewState.isShowed;
    //            // 动画
    //            CGFloat newHeight = self.controlViewShowed ? self.bottomToolBarHeightOnNormal : 0;
    //            self.navigationBar.layer.bounds = CGRectMake(self.bottomToolBar.left, self.bottomToolBar.top, self.bottomToolBar.width, newHeight);
    //        }
    //    }

}

- (void)subscribedStoreSuccess:(id<TTVReduxStoreProtocol>)store {
    if (!isEmptyString([self state].videoTitle)) {
        [self.titleLabel setText:[self state].videoTitle];
    }
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}

#pragma mark - TTVPlayerPartProtocol
- (UIView *)viewForKey:(NSUInteger)key {
    if (key == TTVPlayerPartControlKey_TitleLabel) {
        return self.titleLabel;
    }
    return nil;
}

- (void)setControlView:(UIView *)controlView forKey:(TTVPlayerPartControlKey)key {
    if (key == TTVPlayerPartControlKey_TitleLabel) {
        self.titleLabel = (UILabel *)controlView;
        [self.titleLabel sizeToFit];
    }
}

- (void)removeAllControlView {
    [self.titleLabel removeFromSuperview];
}

- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_Title;
}

@end

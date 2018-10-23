//
//  TTVPlayerTipAdFinished.h
//  Article
//
//  Created by panxiang on 2017/5/25.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerTipFinished.h"
@class playerStateStore;
@class TTImageView;
@class SSThemedLabel;
@class TTVPlayerStateModel;
@class TTVPlayerStateAction;
@interface TTVPlayerTipAdFinished : UIView<TTVPlayerTipFinished>
@property (nonatomic, strong) id data;
@property(nonatomic, assign)BOOL isFullScreen;
@property(nonatomic, copy)FinishAction finishAction;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) TTImageView *logoImageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
/**
 call by subclass
 */
- (SSThemedLabel *)placeholderViewWithTitle:(NSString *)title;
/**
 override by subclass
 */
- (void)onLogoImageViewTapped;

/**
 override by subclass
 */
- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state;
/**
 override by subclass
 */
- (UIView *)onGetActionBtn;
@end

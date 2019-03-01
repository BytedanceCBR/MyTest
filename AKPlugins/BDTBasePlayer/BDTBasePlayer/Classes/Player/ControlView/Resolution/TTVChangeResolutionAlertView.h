//
//  TTVChangeResolutionAlertView.h
//  TTVideoEngine
//
//  Created by panxiang on 2017/11/15.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerContext.h"
#import "TTVPlayerControllerProtocol.h"
@class TTVPlayerStateStore;
/**
 清晰度正在切换的提示
 */
@interface TTVChangeResolutionAlertView : UIView<TTVPlayerContext ,TTVViewLayout>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
- (void)layoutWithSuperViewFrame:(CGRect)superViewFrame;
@end


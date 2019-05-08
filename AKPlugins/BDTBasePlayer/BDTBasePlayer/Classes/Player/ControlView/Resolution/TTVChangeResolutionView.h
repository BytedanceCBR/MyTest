//
//  TTVChangeResolutionView.h
//  TTVideoEngine
//
//  Created by panxiang on 2017/11/14.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerContext.h"
#import "TTVPlayerControllerProtocol.h"

@class TTVPlayerStateStore;
@interface TTVChangeResolutionView : UIView<TTVPlayerContext ,TTVViewLayout>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
- (void)layoutWithSuperViewFrame:(CGRect)superViewFrame;
@end







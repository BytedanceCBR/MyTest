//
//  TTFullScreenLoadingView.m
//  Article
//
//  Created by yuxin on 4/20/15.
//
//

#import "TTFullScreenLoadingView.h"
 
@implementation TTFullScreenLoadingView

- (void)startLoadingAnimation {
    
    [self.loadingAnimationView startAnimation];
}
- (void)stopLoadingAnimation {
    
    [self.loadingAnimationView stopAnimation];
}

@end

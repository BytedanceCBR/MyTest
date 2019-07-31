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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

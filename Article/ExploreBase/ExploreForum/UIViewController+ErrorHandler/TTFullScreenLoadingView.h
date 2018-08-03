//
//  TTFullScreenLoadingView.h
//  Article
//
//  Created by yuxin on 4/20/15.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTGradientView.h"

@interface TTFullScreenLoadingView : SSThemedView

@property (nonatomic,weak) IBOutlet TTGradientView * loadingAnimationView;

- (void)startLoadingAnimation;

@end

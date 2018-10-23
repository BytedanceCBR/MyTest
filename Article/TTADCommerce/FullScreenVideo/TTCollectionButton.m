//
//  TTCollectionButton.m
//  Article
//
//  Created by matrixzk on 28/07/2017.
//
//

#import "TTCollectionButton.h"

@implementation TTCollectionButton

+ (instancetype)collectionButtonWithType:(TTCollectionButtonType)type
{
    return [self collectionButtonWithType:type nightModeEnable:YES];
}

+ (instancetype)collectionButtonWithType:(TTCollectionButtonType)type nightModeEnable:(BOOL)nightModeEnable
{
    TTCollectionButton *button = [TTCollectionButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 24, 24);
    button.hitTestEdgeInsets = UIEdgeInsetsMake(-8.f, -10.f, -8.f, -10.f);
    
    NSString *imageName = @"tab_collect";
    NSString *selectedImageName = @"tab_collect_press";
    if (TTCollectionButtonTypeLight == type) {
        imageName = @"icon_details_collect";
        selectedImageName = @"icon_details_collect_press";
    }
    
    if (nightModeEnable) {
        button.imageName = imageName;
        button.selectedImageName = selectedImageName;
    } else {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
    }
    
    [button addTarget:button action:@selector(buttonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)buttonDidPressed:(id)sender
{
    if (self.shouldResponsePressedBlock && !self.shouldResponsePressedBlock()) {
        return;
    }
    
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    self.alpha = 1.f;
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        self.alpha = 0.f;
    } completion:^(BOOL finished){
        self.selected = !self.selected;
        
        !self.didPressedBlock ? : self.didPressedBlock(self.selected);
        
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.alpha = 1.f;
        } completion:^(BOOL finished){
        }];
    }];
}


@end

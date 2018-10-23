//
//  PadActionButton.h
//  Article
//
//  Created by Dianwei on 12-10-12.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"

@interface ActionButton : SSViewBase {
    
    UILabel *titleLabel;
    UIImageView *imageView;
    UIImageView *backgroundImageView;
    UIButton *button;
    
    BOOL _selected;
}
@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, retain)UIImageView *imageView;
@property(nonatomic, retain)UIImageView *backgroundImageView;

- (void)doZoomInAndDisappearMotion;
- (void)addTarget:(id)target action:(SEL)action;
- (void)setTitleColor:(UIColor*)color forState:(UIControlState)state;
- (void)setFont:(UIFont*)font forState:(UIControlState)state;
- (void)setTitle:(NSString*)text;
- (void)setImage:(UIImage*)image forState:(UIControlState)state;
- (void)setBackgroundImage:(UIImage*)image forState:(UIControlState)state;
- (void)setEnabled:(BOOL)enabled selected:(BOOL)selected;
- (BOOL)enabled;
- (void)updateUI;

// protected
- (void)updateThemes;
- (void)updateFrames;

- (UIButton *)innerButton;
@end

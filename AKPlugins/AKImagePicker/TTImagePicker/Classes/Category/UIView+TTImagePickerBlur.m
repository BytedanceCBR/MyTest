//
//  UIView+TTImagePickerBlur.m
//  Article
//
//  Created by SongChai on 2017/4/24.
//
//

#import "UIView+TTImagePickerBlur.h"
#import <objc/runtime.h>
#import "UIViewAdditions.h"

static NSInteger visualEffectViewTag = 102289;

@implementation UIView (TTImagePickerBlur)

-(void) addBlurEffect : (TTBlurEffect) eBlurEffect
{
    if ([self addVisualEfView:eBlurEffect]) {
        return;
    }
    
    static NSString * blurToolViewKey = @"BLUR_TOOL_VIEW" ;
    
    UIToolbar * blurToolbar = [self getAttachedObjectForKey:blurToolViewKey ] ;
    
    if( blurToolbar == nil || ![blurToolbar isKindOfClass:[UIToolbar class]])
    {
        blurToolbar = [[UIToolbar alloc] init];
        blurToolbar.userInteractionEnabled = NO ;
        blurToolbar.translucent = YES ;
    }
    
    if( eBlurEffect == TTBlurEffectWhite || eBlurEffect == TTBlurEffectExtraLight)
    {
        blurToolbar.barStyle = UIBarStyleDefault ;
    }
    else
    {
        blurToolbar.barStyle = UIBarStyleBlack ;
    }
    blurToolbar.frame = self.bounds ;
    blurToolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [ self.layer insertSublayer:blurToolbar.layer atIndex:0 ];
    self.backgroundColor = [ UIColor clearColor] ;
    
    [ self attachObject:blurToolbar forKey:blurToolViewKey  ] ;
}

-(void) addBlurEffect : (TTBlurEffect) eBlurEffect withTintColor:(UIColor*)tintColor
{
    [self addBlurEffect:eBlurEffect];
    UIVisualEffectView* visualEffectView = (UIVisualEffectView*)[self viewWithTag:visualEffectViewTag];
    if (visualEffectView) {
        [visualEffectView.contentView setBackgroundColor:tintColor];
    }
}

-(void) removeBlurEffect
{
    [self removeVisualEfView];
    return;

    static NSString * blurToolViewKey = @"BLUR_TOOL_VIEW" ;
    UIToolbar * blurToolbar = [ self getAttachedObjectForKey:blurToolViewKey ] ;
    if( blurToolbar != nil && [blurToolbar isKindOfClass:[UIToolbar class]])
    {
        [blurToolbar.layer removeFromSuperlayer];
    }
    [self detachObjectForKey:blurToolViewKey];
}

-(void) updateBlurEffect
{
    static NSString * blurToolViewKey = @"BLUR_TOOL_VIEW" ;
    
    UIToolbar * blurToolbar = [ self getAttachedObjectForKey:blurToolViewKey ] ;
    
    if( blurToolbar == nil || ![blurToolbar isKindOfClass:[UIToolbar class]])
    {
        return ;
    }
    
    blurToolbar.frame = self.bounds ;
    [ self.layer insertSublayer:blurToolbar.layer atIndex:0 ];
}


-(BOOL) addVisualEfView : (TTBlurEffect) eBlurEffect
{
    if ([self viewWithTag:visualEffectViewTag]) {
        return YES;
    }
    
    UIBlurEffectStyle style = UIBlurEffectStyleLight;
    if (eBlurEffect== TTBlurEffectExtraLight) {
        style = UIBlurEffectStyleExtraLight;
    }
    else if (eBlurEffect== TTBlurEffectBlack)
    {
        style = UIBlurEffectStyleDark;
    }
    
    UIVisualEffectView *_visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
    _visualEfView.frame = CGRectMake(0, 0, self.width, self.height);
    _visualEfView.alpha = 1.0;
    _visualEfView.tag = visualEffectViewTag;
    [_visualEfView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_visualEfView];
    [self sendSubviewToBack:_visualEfView];
    return YES;
    
    return NO;
}

-(void) removeVisualEfView
{
    UIView* visualEfView = [self viewWithTag:visualEffectViewTag];
    if (visualEfView) {
        [visualEfView removeFromSuperview];
    }
    return;
}

-(void) addVisualEfViewBg : (TTBlurEffect) eBlurEffect
{
    UIVisualEffectView* visualEfView = (UIVisualEffectView*)[self viewWithTag:visualEffectViewTag];
    if (visualEfView.contentView.tag == 101) {
        return;
    }
    if (visualEfView) {
        UIColor *tintColor;
        if( eBlurEffect != TTBlurEffectBlack )
        {
            tintColor =  [UIColor whiteColor];
        }
        else
        {
            tintColor =  [UIColor colorWithWhite:0.11 alpha:0.73];
        }
        [visualEfView setBackgroundColor:tintColor];
    }
}

-(void) removeVisualEfViewBg
{
    UIVisualEffectView* visualEfView = (UIVisualEffectView*)[self viewWithTag:visualEffectViewTag];
    if (visualEfView.contentView.tag == 101) {
        return;
    }
    if (visualEfView) {
        [visualEfView setBackgroundColor:[UIColor clearColor]];
    }
    visualEfView.contentView.tag = 101;
}

-(void) attachObject:(id)obj forKey:(NSString*)nsKey {
    objc_setAssociatedObject(self, &nsKey, obj, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(id) getAttachedObjectForKey:(NSString*)nsKey {
    return objc_getAssociatedObject(self, &nsKey);
}

-(void) detachObjectForKey:(NSString*)nsKey {
    id obj = objc_getAssociatedObject(self, &nsKey);
    if (obj) {
        objc_removeAssociatedObjects(obj);
    }
}
@end

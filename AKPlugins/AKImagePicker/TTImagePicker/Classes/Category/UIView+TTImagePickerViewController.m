//
//  UIView+TTImagePickerViewController.m
//  Article
//
//  Created by tyh on 2017/4/11.
//
//

#import "UIView+TTImagePickerViewController.h"

@implementation UIView (TTImagePickerViewController)

- (UIViewController*)ttImagePickerViewController
{
    UIResponder *topResponder = self;
    while(topResponder &&
          ![topResponder isKindOfClass:[UIViewController class]])
    {
        topResponder = [topResponder nextResponder];
    }
    
    return (UIViewController*)topResponder;
}

@end

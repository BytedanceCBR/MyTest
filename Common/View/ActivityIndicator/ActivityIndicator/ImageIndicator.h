//
//  ImageIndicator.h
//  ActivityIndicator
//
//  Created by Tu Jianfeng on 8/12/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageIndicator : UIView {
}

+ (void)show:(UIImage *)loadingImage withText:(NSString *)text;
+ (void)hide;

@end

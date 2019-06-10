//
//  UIImageView+SimpleWebImage.h
//  Article
//
//  Created by xushuangqing on 2017/6/21.
//
//

#import <UIKit/UIKit.h>

@interface UIImageView (SimpleWebImage)

- (void)simple_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage completed:(void (^)(UIImage *image, BOOL cached, NSURLResponse * response, NSError * error))completed;

@end

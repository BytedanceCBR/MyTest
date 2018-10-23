//
//  UIButton+TTCache.h
//  Forum
//
//  Created by Zhang Leonardo on 15-5-4.
//
//

#import <UIKit/UIKit.h>
#import "UIButton+WebCache.h"

@interface UIButton(TTCache)

- (NSURL *)tt_imageURLForState:(UIControlState)state;
- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state;
- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;
- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;
- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(SDExternalCompletionBlock)completedBlock;
- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(SDExternalCompletionBlock)completedBlock;
- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDExternalCompletionBlock)completedBlock;

- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state;
- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;
- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;
- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(SDExternalCompletionBlock)completedBlock;
- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(SDExternalCompletionBlock)completedBlock;
- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDExternalCompletionBlock)completedBlock;
- (void)tt_cancelImageLoadForState:(UIControlState)state;
- (void)tt_cancelBackgroundImageLoadForState:(UIControlState)state;



@end

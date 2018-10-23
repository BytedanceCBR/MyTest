//
//  UIButton+TTCache.m
//  Forum
//
//  Created by Zhang Leonardo on 15-5-4.
//
//

#import "UIButton+TTCache.h"
#import "UIButton+SDAdapter.h"

@implementation UIButton(TTCache)

- (NSURL *)tt_imageURLForState:(UIControlState)state
{
    return [self sda_imageURLForState:state];
}

- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state
{
    [self tt_setImageWithURL:url forState:state placeholderImage:nil];
}

- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder
{
    [self tt_setImageWithURL:url forState:state placeholderImage:placeholder options:0];
}

- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self tt_setImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(SDExternalCompletionBlock)completedBlock
{
    [self tt_setImageWithURL:url forState:state placeholderImage:nil completed:completedBlock];
}

- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(SDExternalCompletionBlock)completedBlock
{
    [self tt_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)tt_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDExternalCompletionBlock)completedBlock
{
    [self sda_setImageWithURL:url forState:state placeholderImage:placeholder options:options completed:completedBlock];
}

- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state
{
    [self tt_setBackgroundImageWithURL:url forState:state placeholderImage:nil];
}

- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder
{
    [self tt_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0];
}

- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self tt_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(SDExternalCompletionBlock)completedBlock
{
    [self tt_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(SDExternalCompletionBlock)completedBlock
{
    [self tt_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)tt_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDExternalCompletionBlock)completedBlock
{
    [self sda_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options completed:completedBlock];
}

- (void)tt_cancelImageLoadForState:(UIControlState)state
{
    [self sda_cancelImageLoadForState:state];
}

- (void)tt_cancelBackgroundImageLoadForState:(UIControlState)state
{
    [self sda_cancelBackgroundImageLoadForState:state];
}



@end

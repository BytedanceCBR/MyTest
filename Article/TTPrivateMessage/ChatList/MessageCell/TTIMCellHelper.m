//
//  TTIMCellHelper.m
//  EyeU
//
//  Created by matrixzk on 10/22/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMCellHelper.h"
#import "TTIMMessage.h"
#import "TTUGCSimpleRichLabel.h"

@implementation TTIMCellHelper

+ (CGSize)textSizeWithMessage:(TTIMMessage *)message
{
    if (message.cachedTextSize) {
        return message.cachedTextSize.CGSizeValue;
    }
    BOOL isSystemMsg = (TTIMMessageTypeSystem == message.messageType);
    CGFloat fontSize = isSystemMsg ? kFontSizeOfSystemMsgCellText() : kFontSizeOfMsgCellText();
    
    CGSize textSize = [self sizeOfText:message.msgText
                          textRichSpan:message.msgTextContentRichSpans
                          withMaxWidth:(isSystemMsg ? kMaxWidthOfSystemMsgText() : kMaxWidthOfMsgText())
                                  font:[UIFont systemFontOfSize:fontSize]];
    message.cachedTextSize = [NSValue valueWithCGSize:textSize];
    return textSize;
}

+ (CGSize)sizeOfBubbleContainerViewWithMessage:(TTIMMessage *)message
{
    CGSize size = CGSizeZero;
    
    switch (message.messageType) {
        case TTIMMessageTypeText:
            size = [self textSizeWithMessage:message];
            size = CGSizeMake(ceilf(size.width + kMsgTextViewFrameInsets().left + kMsgTextViewFrameInsets().right),
                              ceilf(size.height + kMsgTextViewFrameInsets().top + kMsgTextViewFrameInsets().bottom));
            size = CGSizeMake(MAX(size.width, 40), MAX(size.height, 36));
            break;
            
        case TTIMMessageTypeImage:
            size = [self adjustedImageSizeFromSourceSize:message.imageOriginSize];
            size = CGSizeMake(AdjustedImageSideLength(size.width),
                              AdjustedImageSideLength(size.height));
            size = CGSizeMake(MAX(size.width, 40), MAX(size.height, 36));
            break;
            
        default:
            size = CGSizeMake(MAX(size.width, 40), MAX(size.height, 36));
            break;
    }
    return size;
}

+ (CGFloat)cellHeightWithMessage:(TTIMMessage *)message
{
    CGFloat height;
    if (TTIMMessageTypeSystem == message.messageType) {
        height = [self textSizeWithMessage:message].height + kTopPaddingOfSystemMsgCellTextLabel();
    } else {
        height = kAvatarViewOffset().vertical + [self sizeOfBubbleContainerViewWithMessage:message].height;
    }
    return ceilf(height);
}

+ (SSThemedLabel *)createLabelWithFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor
{
    SSThemedLabel *label = [SSThemedLabel new];
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = textColor;
    return label;
}

#pragma mark - NSString Helper

+ (CGSize)sizeOfText:(NSString *)text textRichSpan:(NSString *)textRichSpan withMaxWidth:(CGFloat)maxWidth font:(UIFont *)font {
    TTRichSpanText *richText = [[TTRichSpanText alloc] initWithText:text richSpansJSONString:textRichSpan];
    return [TTUGCSimpleRichLabel heightWithWidth:maxWidth richSpanText:richText font:font numberOfLines:0];
}

#pragma mark - Image Helper

+ (UIImage *)thumbImageFromSourceImage:(UIImage *)sourceImage
{
    if (!sourceImage || sourceImage.size.width == 0 || sourceImage.size.height == 0) {
        return nil;
    }
    
    CGSize targetSize = [self adjustedImageSizeFromSourceSize:sourceImage.size];
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    [sourceImage drawInRect:(CGRect){CGPointZero, targetSize}];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

+ (CGSize)adjustedImageSizeFromSourceSize:(CGSize)imageSize
{
    CGFloat widthOfImage = imageSize.width;
    CGFloat heightOfImage = imageSize.height;
    
    if (widthOfImage == 0 || heightOfImage == 0) {
        return CGSizeMake(ceilf(kMinSizeOfCellImage()), ceilf(kMinSizeOfCellImage()));
    }
    
    CGFloat width, height;
    if (widthOfImage >= heightOfImage) {
        width = AdjustedImageSideLength(widthOfImage);
        height = width / (widthOfImage / heightOfImage);
        if (height < kMinSizeOfCellImage()) {
            width = (width / height) * kMinSizeOfCellImage();
            height = kMinSizeOfCellImage();
        }
    } else { // 瘦图
        height = AdjustedImageSideLength(heightOfImage);
        width = (widthOfImage / heightOfImage) * height;
        if (width < kMinSizeOfCellImage()) {
            height = kMinSizeOfCellImage() / (width / height);
            width = kMinSizeOfCellImage();
        }
    }
    
    return CGSizeMake(ceilf(width), ceilf(height));
}

NS_INLINE CGFloat kMinSizeOfCellImage() {
    return TTIMPadding(100);
}

NS_INLINE CGFloat kMaxSizeOfCellImage() {
    return TTIMPadding(220);
}

// 控制图片边长在 [100, 220]
NS_INLINE CGFloat AdjustedImageSideLength(CGFloat originLength) {
    return MAX(kMinSizeOfCellImage(), MIN(kMaxSizeOfCellImage(), originLength));
}


#pragma mark -

+ (void)maskMediaView:(UIView *)mediaView
{
    UIImage *image = [[UIImage imageNamed:@"chat_me"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    imgView.frame = mediaView.bounds;
    
    mediaView.layer.mask = imgView.layer;
    mediaView.layer.masksToBounds = YES;
}

@end

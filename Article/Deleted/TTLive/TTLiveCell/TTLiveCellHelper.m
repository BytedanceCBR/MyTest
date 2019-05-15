//
//  TTLiveCellHelper.m
//  Article
//
//  Created by matrixzk on 2/3/16.
//
//

#import "TTLiveCellHelper.h"
#import "TTLiveMessage.h"
#import "NSString-Extension.h"
#import <UIColor+TTThemeExtension.h>

@implementation TTLiveCellHelper

+ (CGSize)sizeOfTextViewWithMessage:(TTLiveMessage *)message
{
    NSValue *sizeValue = message.cachedSizeOfCellText;
    if (sizeValue) {
        return sizeValue.CGSizeValue;
    }
    
    BOOL isReplyedMsg = message.isReplyedMsg;
    // 广告外链样式的cell要求文字右侧有一个箭头，且该箭头与文字间距为OffsetOfTextView4ADType()。
    CGFloat rightOffset = isEmptyString(message.link) ? 0 : OffsetOfTextView4ADType();
    
    NSString *msgText = message.msgText;
    if (message.isTop) {
        NSRange iconRange = [message.msgText rangeOfString:@"\U0000E613\n\n"];
        if (iconRange.location != NSNotFound) {
            msgText = [msgText substringWithRange:NSMakeRange(iconRange.length, msgText.length - iconRange.length)];
        }
    }
    UIFont *font = [UIFont systemFontOfSize:isReplyedMsg ? FontSizeOfReplyedTextMessage() : FontSizeOfTextMessage()];
    CGFloat lineHeight = (isReplyedMsg ? LineHeightOfReplyedTextMessage() : LineHeightOfTextMessage());
    CGFloat maxWidth = (isReplyedMsg ? MaxWidthOfReplyedText(message.cellLayout) : MaxWidthOfText(message.cellLayout)) - rightOffset;
    
    CGSize resultSize = [msgText tt_sizeWithMaxWidth:maxWidth font:font lineHeight:lineHeight numberOfLines:0];

    resultSize.width = resultSize.width + rightOffset;
    resultSize.height += (lineHeight - ceil(font.pointSize));
    
    if (message.cellLayout & TTLiveCellLayoutIsTop) {
        resultSize.height += LineHeightOfTopIconText();
        if (!isEmptyString(msgText)) {
            resultSize.height += topLabelBottomPadding();
        } else {
            resultSize.height = LineHeightOfTopIconText();
        }
        resultSize.width = MAX(resultSize.width, MAXWidthOfTopIconLabel() + rightOffset);
    }
    
    if (message.msgId) {
        message.cachedSizeOfCellText = [NSValue valueWithCGSize:resultSize];
    }
    
    return resultSize;
}

+ (CGSize)adjustedSizeOfSourceMetaImageSize:(CGSize)imageSize cellLayout:(TTLiveCellLayout)layout
{
    return [self adjustedSizeOfSourceMetaImageSize:imageSize isReplyedMsg:NO cellLayout:layout];
}

+ (CGSize)adjustedSizeOfSourceMetaImageSize:(CGSize)imageSize isReplyedMsg:(BOOL)isReplyedMsg cellLayout:(TTLiveCellLayout)layout
{
    CGSize resultSize = CGSizeZero;
    
    CGFloat widthOfImage = imageSize.width;
    CGFloat heightOfImage = imageSize.height;
    
    CGFloat widthOfSquareImage = MIN(TTLivePadding(180), isReplyedMsg ? MaxWidthOfReplyedText(layout) : MaxWidthOfText(layout));
    CGFloat widthOfLandscapeImage = MIN(TTLivePadding(244), isReplyedMsg ? MaxWidthOfReplyedText(layout) : MaxWidthOfText(layout));
    CGFloat widthOfPortraitImage = widthOfSquareImage;
    
    if(widthOfImage == heightOfImage || widthOfImage == 0 || heightOfImage == 0) {
        resultSize = CGSizeMake(widthOfSquareImage, widthOfSquareImage);
    } else if (widthOfImage > heightOfImage) {
        resultSize = CGSizeMake(widthOfLandscapeImage, (widthOfLandscapeImage * heightOfImage) / widthOfImage);
    } else {
        resultSize = CGSizeMake(widthOfPortraitImage,
                                MIN((widthOfPortraitImage * 3) / 2, (widthOfPortraitImage * heightOfImage) / widthOfImage));
    }
    
    return CGSizeMake(ceilf(resultSize.width), ceilf(resultSize.height));
}

+ (CGSize)sizeOfMetaAudioViewWithMessage:(TTLiveMessage *)message
{
    BOOL isReplyedMsg = message.isReplyedMsg;
    CGFloat quarterSection = (isReplyedMsg ? MaxWidthOfReplyedText(message.cellLayout) : MaxWidthOfText(message.cellLayout) - TailLengthAfterAudioBubbleView()) / 4.0;
    
    NSTimeInterval validDuration = MAX(1, MIN(60, message.mediaFileDuration.doubleValue));
    
    CGFloat width = 0;
    if (validDuration <= 10) {
        width = quarterSection + validDuration * (quarterSection / 10);
    } else if (validDuration > 10 && validDuration <= 30) {
        width = quarterSection * 2 + (validDuration - 10) * (quarterSection / 20);
    } else if (validDuration > 30 && validDuration <= 60) {
        width = quarterSection * 3 + (validDuration - 30) * (quarterSection / 30);
    }
    
    return CGSizeMake(ceilf(width + OffsetOfBubbleImageArrow() + TailLengthAfterAudioBubbleView()), TTLivePadding(30));
}

+ (CGSize)sizeOfNormalContentViewWithMessage:(TTLiveMessage *)message
{
    NSValue *sizeValue = message.cachedSizeOfCellContent;
    if (sizeValue) {
        CGSize size = [sizeValue CGSizeValue];
        return size;
    }
    
    BOOL isReplyedMsg = message.isReplyedMsg;
    
    CGSize textViewSize = CGSizeZero;
    CGSize mediaViewSize = CGSizeZero;
    
    BOOL hasMsgText = !isEmptyString(message.msgText);
    if (hasMsgText) {
        textViewSize = [self sizeOfTextViewWithMessage:message];
    }
    
    if (TTLiveMessageTypeText != message.msgType) {
        switch (message.msgType) {
                
            case TTLiveMessageTypeImage:
            case TTLiveMessageTypeVideo:
                mediaViewSize = [self adjustedSizeOfSourceMetaImageSize:message.imageModel ? CGSizeMake(message.imageModel.width, message.imageModel.height)
                                                                                           : message.sizeOfOriginImage
                                                           isReplyedMsg:isReplyedMsg
                                                             cellLayout:message.cellLayout];
                break;
                
            case TTLiveMessageTypeAudio:
                mediaViewSize = [self sizeOfMetaAudioViewWithMessage:message];

                // 音频在非回复、无文字状态下，单独展现
//                if (!hasMsgText && !message.replyedMessage && !message.isReplyedMsg) {
//                    mediaViewSize.height -= (SidePaddingOfContentView() + BottomPaddingOfNicknameLabel());
//                }
                break;
            case TTLiveMessageTypeProfileCard:
            case TTLiveMessageTypeMediaCard:
            case TTLiveMessageTypeArticleCard:
                mediaViewSize = CGSizeMake((isReplyedMsg ? MaxWidthOfReplyedText(message.cellLayout) : MaxWidthOfText(message.cellLayout)), SidePaddingCardImageView() * 2 + SideSizeCardImageView() + SidePaddingCardSourceImageView() * 2 + SideSizeCardSourceImageView());
                break;
            default:
                break;
        }
        
        if (hasMsgText) {
            textViewSize = CGSizeMake(textViewSize.width, textViewSize.height + PaddingOfTextViewAndMediaView());
        }
    }
    
    CGFloat extraWidth = OriginXOfCellContent()*2;
    
    CGSize resultSize = CGSizeMake(
                                   [self adjustedContentViewWidthWithOriginWidth:(MAX(textViewSize.width, mediaViewSize.width) + extraWidth) message:message],
                                   ceilf(textViewSize.height + mediaViewSize.height + (isReplyedMsg ? HeightOfTopInfoViewByReply() : kLivePaddingCellTopInfoViewHeight(message.cellLayout)) + SidePaddingOfContentView()));
    
    resultSize.height += (isReplyedMsg ? 0 : SidePaddingOfContentView());
    
    if (message.msgId) {
        message.cachedSizeOfCellContent = [NSValue valueWithCGSize:resultSize];
    }
    
    return resultSize;
}

+ (CGFloat)heightOfNormalReplyedContentViewWithMessage:(TTLiveMessage *)message
{
    CGSize normalContentSize = [self sizeOfNormalContentViewWithMessage:message];
    CGSize replyedNormalContentSize = [self sizeOfNormalContentViewWithMessage:message.replyedMessage];    
    return ceilf(normalContentSize.height + replyedNormalContentSize.height + BottomPaddingOfRefMessageView());
}

+ (CGFloat)adjustedContentViewWidthWithOriginWidth:(CGFloat)originWidth message:(TTLiveMessage *)message
{
    BOOL isReplyedMsg = message.isReplyedMsg;
    BOOL coverTop = message.cellLayout & TTLiveCellLayoutBubbleCoverTop;
    if (!isReplyedMsg && !coverTop) {
        return originWidth;
    }
    CGFloat resultWidth = originWidth;
        
    CGFloat tempWidthOfTopInfoView = [self labelWidthWithText:message.userDisplayName fontSize:FontSizeOfNicknameLabel()]
                                   + [self labelWidthWithText:message.sendTime fontSize:FontSizeOfSendTimeLabel()]
                                   + (message.isReplyedMsg ? SidePaddingOfNicknameLabel() * 2 : 0)
                                   + LeftPaddingOfMsgSendTimeLabel()
                                   + ([message.userVip boolValue] ? LeftPaddingOfMsgSendTimeLabel() + 11 : 0);
    if (message.cellLayout & TTLiveCellLayoutHiddenName){
        tempWidthOfTopInfoView = [self labelWidthWithText:message.sendTime fontSize:FontSizeOfSendTimeLabel()] + OriginXOfCellContent() * 2;
    }
    
    CGFloat maxWidthOfContentView = MAX((isReplyedMsg ? MaxWidthOfReplyedText(message.cellLayout) : MaxWidthOfText(message.cellLayout)) + OriginXOfCellContent()*2,
                                        originWidth);
    
    if (tempWidthOfTopInfoView > maxWidthOfContentView) {
        resultWidth = maxWidthOfContentView;
    } else if (tempWidthOfTopInfoView > originWidth) {
        resultWidth = tempWidthOfTopInfoView;
    }
    
    return ceilf(resultWidth);
}

+ (CGFloat)labelWidthWithText:(NSString *)text fontSize:(CGFloat)fontSize
{
    CGRect stringRect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                           options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                        attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:fontSize] }
                                           context:nil];
    
    return CGRectGetWidth(stringRect);
}

+ (BOOL)shouldShowCellBottomLoadingProgressViewWithMessage:(TTLiveMessage *)message
{
    return [self supportCellBottomLoadingProgressViewWithMessage:message] &&
           ([message.loadingProgress floatValue] != 1) &&
           (TTLiveMessageNetworkStateFaild != message.networkState);
}

+ (BOOL)supportCellBottomLoadingProgressViewWithMessage:(TTLiveMessage *)message
{
//    return (TTLiveMessageTypeVideo == message.msgType || TTLiveMessageTypeImage == message.msgType);
    return TTLiveMessageTypeVideo == message.msgType;
}

+ (NSString *)formattedSizeWithVideoFileSize:(long long)size
{
    float floatSize = size;
    
    floatSize = floatSize / 1024;
    if (floatSize < 1024) {
        return [NSString stringWithFormat:@"%1.1f KB", floatSize];
    } else {
        floatSize = floatSize / 1024;
        return [NSString stringWithFormat:@"%1.1f MB", floatSize];
    }
}

+ (NSString *)formattedTimeWithVideoDuration:(NSTimeInterval)totalSeconds
{
    long seconds = lroundf(totalSeconds);
    int hour = 0;
    int minute = seconds / 60.0f;
    int second = seconds % 60;
    if (minute > 59) {
        hour = minute / 60;
        minute = minute % 60;
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    } else{
        return [NSString stringWithFormat:@"%02d:%02d", minute, second];
    }
}

+ (UIImage *)thumbImageWithSourceImage:(UIImage *)sourceImage cellLayout:(TTLiveCellLayout)layout
{
    if (!sourceImage || sourceImage.size.width == 0 || sourceImage.size.height == 0) {
        return nil;
    }
    
    UIImage *resultImage;
    CGSize targetSize = [self adjustedSizeOfSourceMetaImageSize:sourceImage.size cellLayout:layout];
    
    CGFloat widthOfSourceImage = sourceImage.size.width * sourceImage.scale;
    CGFloat theMaxWidth = TTLivePadding(180);
    if ((theMaxWidth * sourceImage.size.height) / widthOfSourceImage > (theMaxWidth * 3) / 2) {
        CGImageRef subImageRef = CGImageCreateWithImageInRect(sourceImage.CGImage, (CGRect){CGPointZero, widthOfSourceImage, (widthOfSourceImage * 3) / 2});
        sourceImage = [UIImage imageWithCGImage:subImageRef];
        CGImageRelease(subImageRef);
    }
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    [sourceImage drawInRect:(CGRect){CGPointZero, targetSize}];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

+ (void)dismissCellMenuIfNeeded
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) {
        [menuController setMenuVisible:NO animated:YES];
    }
}

+ (NSAttributedString *)topMessageStrWithMessage:(TTLiveMessage *)message extraAttributeDict:(NSDictionary *)dict
{
    NSRange iconRange = [message.msgText rangeOfString:@"\U0000E613"];
    NSMutableDictionary *msgTextDict = [NSMutableDictionary dictionary];
    [msgTextDict setValue:[UIFont systemFontOfSize:FontSizeOfTextMessage()] forKey:NSFontAttributeName];
    [msgTextDict setValue:[UIColor tt_themedColorForKey:kColorText1] forKey:NSForegroundColorAttributeName];
    
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [msgTextDict addEntriesFromDictionary:dict];
    }
    NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc] initWithString:message.msgText attributes:msgTextDict];
    if (iconRange.location != NSNotFound) {
        UIColor *iconColor = [UIColor colorWithHexString:@"#F85959"];
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight) {
            iconColor = [UIColor colorWithHexString:@"#935656"];
        }
        NSMutableDictionary *iconTextDict = [NSMutableDictionary dictionary];
        [iconTextDict setValue:[UIFont fontWithName:@"new_icon_change" size:FontSizeOfTopTextLabel()] forKey:NSFontAttributeName];
        [iconTextDict setValue:iconColor forKey:NSForegroundColorAttributeName];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSParagraphStyle *style = [dict tt_objectForKey:NSParagraphStyleAttributeName];
            [iconTextDict setValue:style forKey:NSParagraphStyleAttributeName];
        }
        
        //由于自定义字体有向下偏移的问题，这次处理一下只有公告icon的问题
        if ([message.msgText isEqualToString:@"\U0000E613\n\n"]) {
            [iconTextDict setValue:nil forKey:NSParagraphStyleAttributeName];
            [iconTextDict setValue:@(-6) forKey:NSBaselineOffsetAttributeName];
        }
        
        [resultStr setAttributes:iconTextDict range:iconRange];
        NSRange spaceRange = [message.msgText rangeOfString:@"\n\n"];
        if (spaceRange.location != NSNotFound) {
            NSMutableDictionary *spaceDict = [NSMutableDictionary dictionary];
            [spaceDict setValue:[UIFont systemFontOfSize:5] forKey:NSFontAttributeName];
            [resultStr setAttributes:spaceDict range:spaceRange];
        }
    }
    return resultStr;
}

@end

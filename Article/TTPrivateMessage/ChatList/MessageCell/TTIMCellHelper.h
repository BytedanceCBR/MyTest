//
//  TTIMCellHelper.h
//  EyeU
//
//  Created by matrixzk on 10/22/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTUGCSimpleRichLabel.h"

@class TTIMMessage;
@interface TTIMCellHelper : NSObject

+ (CGSize)sizeOfBubbleContainerViewWithMessage:(TTIMMessage *)message;
+ (CGSize)textSizeWithMessage:(TTIMMessage *)message;
+ (CGFloat)cellHeightWithMessage:(TTIMMessage *)message;
+ (UIImage *)thumbImageFromSourceImage:(UIImage *)sourceImage;
+ (void)maskMediaView:(UIView *)mediaView;
+ (SSThemedLabel *)createLabelWithFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor;

@end

NS_INLINE CGFloat TTIMPadding(CGFloat padding) {
    return ceilf(padding);
}

NS_INLINE CGFloat TTIMFontSize(CGFloat fontSize) {
    return fontSize;
}

/**
 * size of AvatarView
 */
NS_INLINE CGSize kSizeOfAvatarView() {
    return CGSizeMake(TTIMPadding(36), TTIMPadding(36));
}

/**
 * size of MsgSendStateImg
 */
NS_INLINE CGSize kSizeOfMsgStateImg() {
    return CGSizeMake(TTIMPadding(22), TTIMPadding(22));
}

/**
 * cell 的 content 距离底部 padding
 */
NS_INLINE CGFloat kBottomPaddingOfCell() {
    return TTIMPadding(10);
}


/**
 * CellTopLabel 相对于 cell 上边缘的边距
 */
NS_INLINE CGFloat kTopPaddingOfCellTopLabel() {
    return TTIMPadding(15);
}

NS_INLINE CGFloat kBottomPaddingOfCellTopLabel() {
    return TTIMPadding(5);
}

NS_INLINE CGFloat kHeightOfCellTopLabel() {
    return TTIMPadding(12);
}

/**
 * AvatarView 距屏幕左(incoming)/右(outgoing)和上边紧挨的view的边距
 */
NS_INLINE UIOffset kAvatarViewOffset() {
    return UIOffsetMake(TTIMPadding(15), TTIMPadding(10)); // TODO: Y
}

/**
 * BubbleTopLabel 相对于屏幕的左(incoming)/右(outgoing)和 cellTopLabel(optional) 或 cell 上边缘的 offset；
 */
NS_INLINE UIOffset kBubbleTopLabelOffset() {
    return UIOffsetMake(TTIMPadding(3), kAvatarViewOffset().vertical); // TODO: Y
}

/**
 * BubbleContainerView 相对于屏幕的左(incoming)/右(outgoing)和 BubbleTopLabel(optional) 或 cellTopLabel(optional) 或 cell 上边缘的 offset；
 */
NS_INLINE UIOffset kBubbleContainerViewOffset() {
    return UIOffsetMake(kAvatarViewOffset().horizontal + kSizeOfAvatarView().width + TTIMPadding(5), TTIMPadding(0)); // TODO: Y
}

/**
 * 文本消息 textView 相对于气泡 bubbleView 的 insets
 */
NS_INLINE UIEdgeInsets kMsgTextViewFrameInsets() {
    return UIEdgeInsetsMake(TTIMPadding(8), TTIMPadding(15), TTIMPadding(8), TTIMPadding(10));
}

/**
 * CellBottomLabel 相对于 BubbleContainerView 的上间距
 */
NS_INLINE CGFloat kTopPaddingOfCellBottomLabel() {
    return TTIMPadding(10);
}

NS_INLINE CGFloat kTopPaddingOfSystemMsgCellTextBg() {
    return TTIMPadding(2);
}

NS_INLINE CGFloat kSideMinPaddingOfSystemMsgCellTextBg() {
    return TTIMPadding(8);
}

NS_INLINE CGFloat kTopPaddingOfSystemMsgCellTextLabel() {
    return TTIMPadding(10);
}

NS_INLINE CGFloat kBottomPaddingOfSystemMsgCellTextLabel() {
    return TTIMPadding(10);
}

NS_INLINE CGFloat kSideMinPaddingOfSystemMsgCellTextLabel() {
    return TTIMPadding(15);
}

NS_INLINE CGFloat kFontSizeOfMsgCellText() {
    return /*[TTDeviceHelper is736Screen] ? TTIMFontSize(17) : */TTIMFontSize(15);
}

NS_INLINE CGFloat kFontSizeOfSystemMsgCellText() {
    return TTIMFontSize(14);
}


///**
// * cell 的底部 padding
// */
//NS_INLINE CGFloat kBottomPaddingOfCell() {
//    return TTIMPadding(5);
//}

///**
// * MsgSendStateImg 和 BubbleContainerView 的间距
// */
//NS_INLINE CGFloat kSidePaddingOfMsgStateImg() {
//    return TTIMPadding(12);
//}

/**
 * MsgSendStateImg 相对于 BubbleContainerView 的 MaxX 和 centerY 的 offset
 */
NS_INLINE UIOffset kMsgStateImgOffset() {
    return UIOffsetMake(TTIMPadding(5), 0);
}

NS_INLINE CGFloat kMaxWidthOfMsgText() {
    return ceilf(CGRectGetWidth([UIScreen mainScreen].bounds) /* - kAvatarViewOffset().horizontal*2 - kSizeOfAvatarView().width/2 */ - kBubbleContainerViewOffset().horizontal - kAvatarViewOffset().horizontal - kSizeOfMsgStateImg().width - kMsgStateImgOffset().horizontal - kMsgTextViewFrameInsets().left - kMsgTextViewFrameInsets().right);
}

NS_INLINE CGFloat kMaxWidthOfSystemMsgText() {
    return ceilf(CGRectGetWidth([UIScreen mainScreen].bounds) - (kSideMinPaddingOfSystemMsgCellTextLabel() + kSideMinPaddingOfSystemMsgCellTextBg()) *2);
}

///**
// * BubbleContainerView 相对于屏幕边缘和 bubbleTopLabel 的 insets；
// * top 和 left 对 incoming 起作用；
// * bottom 和 right 对 outgoing 起作用。
// */
//NS_INLINE UIEdgeInsets kBubbleContainerViewFrameInsets() {
//    return UIEdgeInsetsMake(TTIMPadding(12), TTIMPadding(18), TTIMPadding(12), TTIMPadding(18));
//}

//
//  TTLiveCellHelper.h
//  Article
//
//  Created by matrixzk on 2/3/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTDeviceUIUtils.h"
#import <TTDeviceHelper.h>

typedef NS_ENUM(NSInteger, TTLiveCellLayout) {
    TTLiveCellLayoutHiddenName          = 1 << 0,
    TTLiveCellLayoutHiddenRoleName      = 1 << 1,
    TTLiveCellLayoutBubbleCoverTop      = 1 << 2,
    TTLiveCellLayoutBubbleWidthExtend   = 1 << 3,
    TTLiveCellLayoutIsComming           = 1 << 4,
    TTLiveCellLayoutIsTop               = 1 << 5,
};

#define MaxWidth MaxWidthOfText()

#define TTLiveChatListBGColor [UIColor tt_themedColorForKey:kColorBackground4]

@class TTLiveMessage;

@interface TTLiveCellHelper : NSObject

+ (CGSize)adjustedSizeOfSourceMetaImageSize:(CGSize)imageSize cellLayout:(TTLiveCellLayout)layout;

+ (CGSize)sizeOfNormalContentViewWithMessage:(TTLiveMessage *)message;
+ (CGSize)sizeOfMetaAudioViewWithMessage:(TTLiveMessage *)message;
+ (CGSize)adjustedSizeOfSourceMetaImageSize:(CGSize)imageSize isReplyedMsg:(BOOL)isReplyedMsg cellLayout:(TTLiveCellLayout)layout;
+ (CGSize)sizeOfTextViewWithMessage:(TTLiveMessage *)message;
+ (CGFloat)heightOfNormalReplyedContentViewWithMessage:(TTLiveMessage *)message;

+ (NSString *)formattedSizeWithVideoFileSize:(long long)size;
+ (NSString *)formattedTimeWithVideoDuration:(NSTimeInterval)totalSeconds;

+ (BOOL)supportCellBottomLoadingProgressViewWithMessage:(TTLiveMessage *)message;
+ (BOOL)shouldShowCellBottomLoadingProgressViewWithMessage:(TTLiveMessage *)message;

/// cropped `sourceImage` to a suitable size for using of cell's thumb image.
+ (UIImage *)thumbImageWithSourceImage:(UIImage *)sourceImage cellLayout:(TTLiveCellLayout)layout;

+ (void)dismissCellMenuIfNeeded;
//置顶的消息转化后的富文本文案
+ (NSAttributedString *)topMessageStrWithMessage:(TTLiveMessage *)message extraAttributeDict:(NSDictionary *)dict;

@end


/// 新规则间距适配

NS_INLINE CGFloat TTNewPadding(CGFloat padding) {
    return [TTDeviceUIUtils tt_newPadding:padding];
}

NS_INLINE CGFloat TTNewFontSize(CGFloat fontSize) {
    return [TTDeviceUIUtils tt_newFontSize:fontSize];
}

NS_INLINE CGFloat TTLivePadding(CGFloat padding) {
    return [TTDeviceUIUtils tt_newPadding:padding];
}

NS_INLINE CGFloat TTLiveFontSize(CGFloat fontSize) {
    return [TTDeviceUIUtils tt_newFontSize:fontSize];
}

// UILabel 的安全距离
NS_INLINE CGFloat TTLiveSafePaddingOfLabel(UILabel *label) {
    return label.font.pointSize * 0.1;
}

#pragma mark - Padding
//名字距离气泡的间距
NS_INLINE CGFloat PaddingContentTopAndBottom(){
    return TTLivePadding(8);
}

/** cell内容顶部间距 */
NS_INLINE CGFloat kLivePaddingCellContentTop() {
    return TTNewPadding(10);
}

/** 头像边距 */
NS_INLINE CGFloat kLivePaddingCellAvatarViewSide() {
    return TTNewPadding(12);
}

NS_INLINE CGFloat SidePaddingOfAvatarView() {
    return TTLivePadding(15);
}

NS_INLINE CGFloat PaddingOfContainerAndAvatarView() {
    return TTLivePadding(3);
}

//到cell的距离
NS_INLINE CGFloat PaddingOfContainerAndCell(){
    return TTLivePadding(15);
}

NS_INLINE CGFloat PaddingOfAvatarAndRoleLabel() {
    return TTLivePadding(5);
}

NS_INLINE CGFloat SidePaddingOfNicknameLabel() {
    return TTLivePadding(12);
}

NS_INLINE CGFloat TopPaddingOfReplyNicknameLabel() {
    return TTLivePadding(8);
}

NS_INLINE CGFloat BottomPaddingOfReplyNickNameLabel(){
    return TTLivePadding(4);
}

NS_INLINE CGFloat TopPaddingOfNicknameLabel() {
    return TTLivePadding(3);
}

NS_INLINE CGFloat BottomPaddingOfNicknameLabel() {
    return TTLivePadding(5);
}

NS_INLINE CGFloat LeftPaddingOfMsgSendTimeLabel() {
    return TTLivePadding(4);
}

NS_INLINE CGFloat SidePaddingOfResendView() {
    return TTLivePadding(5);
}

NS_INLINE CGFloat SidePaddingOfVideoSizeLabel() {
    return TTLivePadding(4);
}

//左右边距一致

//置顶样式的cell内容右边距

NS_INLINE CGFloat topLabelBottomPadding() {
    return TTLivePadding(6);
}

NS_INLINE CGFloat topTagCellRightPadding() {
    return TTLivePadding(28);
}

NS_INLINE CGFloat OriginXOfCellContent() {
    return TTLivePadding(10);
}

NS_INLINE CGFloat TopPaddingOfCellBottomView() {
    return TTLivePadding(10);
}

NS_INLINE CGFloat PaddingOfTextViewAndMediaView() {
    return TTLivePadding(12);
}


NS_INLINE CGFloat LeftPaddingOfRefMessageView() {
    return OriginXOfCellContent();
}

NS_INLINE CGFloat BottomPaddingOfMessageContent() {
    return TTLivePadding(12);
}

NS_INLINE CGFloat BottomPaddingOfRefMessageView() {
    return TTLivePadding(12);
}

NS_INLINE CGFloat LeftPaddingOfAudioBubbleView() {
    return TTLivePadding(6);
}

NS_INLINE CGFloat PaddingOfAudioBubbleAndRedPointView() {
    return TTLivePadding(6);
}

NS_INLINE CGFloat TopPaddingOfAudioBubbleAndRedPointView() {
    return TTLivePadding(4);
}

NS_INLINE CGFloat LeftPaddingOfNicknameLabel() {
    return TTLivePadding(6) - PaddingOfAudioBubbleAndRedPointView();
}

NS_INLINE CGFloat OffsetOfBubbleImageArrow() {
    return 5;
}

NS_INLINE CGFloat SideOfAudioTailRedPointView() {
    return 6;
}

NS_INLINE CGFloat TailLengthAfterAudioBubbleView() {
    return ceilf(PaddingOfAudioBubbleAndRedPointView() + SideOfAudioTailRedPointView());
}

NS_INLINE CGFloat SideOfAvatarImage() {
    return TTLivePadding(24);
}

NS_INLINE CGFloat WidthOfRightArrow() {
    return 12;
}

NS_INLINE CGFloat SidePaddingOfContentView() {
    return TTLivePadding(8);
}

NS_INLINE CGFloat OffsetOfTextView4ADType() {
    return TTLivePadding(15) + WidthOfRightArrow();
}

NS_INLINE CGFloat MaxWidthOfContainterWithLayout(TTLiveCellLayout layout){
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    if ([TTDeviceHelper isPadDevice] == NO){
        width = MIN(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    }
    if ((layout & TTLiveCellLayoutBubbleWidthExtend) && (layout & TTLiveCellLayoutIsComming)){
        return ceil(width - kLivePaddingCellAvatarViewSide() - SideOfAvatarImage() - PaddingOfContainerAndAvatarView() - PaddingOfContainerAndCell());
    }
    return ceil(width - kLivePaddingCellAvatarViewSide() - SideOfAvatarImage() - PaddingOfContainerAndAvatarView() - PaddingOfContainerAndCell() - 24 - SidePaddingOfResendView());
}

NS_INLINE CGFloat MaxWidthOfText(TTLiveCellLayout layout) {
    //水平间距
    CGFloat hPadding = OriginXOfCellContent()*2;
    return MaxWidthOfContainterWithLayout(layout) - hPadding; // 这里的24为重发图标的size，给定切图的控件不做通用规则适配。
}

NS_INLINE CGFloat MAXWidthOfTopIconLabel() {
    //置顶icon的最大宽度
    return [TTDeviceUIUtils tt_newPadding:44.f];
}

NS_INLINE CGFloat MaxWidthOfReplyedText(TTLiveCellLayout layout) {
    //水平间距
    CGFloat hPadding = LeftPaddingOfRefMessageView()*2;
    return ceilf(MaxWidthOfText(layout) - hPadding);
}

NS_INLINE CGFloat SideOfLoadingProgressViewCancelButton() {
    return 18;
}

NS_INLINE CGFloat TopPaddingOfLoadingProgressViewCancelButton() {
    return TTLivePadding(3);
}

NS_INLINE CGFloat BottomPaddingOfLoadingProgressViewCancelButton() {
    return TTLivePadding(12);
}

NS_INLINE CGFloat HeightOfLoadingProgressView() {
    return TopPaddingOfLoadingProgressViewCancelButton() + SideOfLoadingProgressViewCancelButton() + BottomPaddingOfLoadingProgressViewCancelButton();
}


/// Font

NS_INLINE CGFloat FontSizeOfTopTextLabel() {
    return TTLiveFontSize(12);
}

NS_INLINE CGFloat FontSizeOfRoleLabel() {
    return TTLiveFontSize(12);
}

NS_INLINE CGFloat FontSizeOfTextMessage() {
    return TTLiveFontSize(15);
}

NS_INLINE CGFloat FontSizeOfReplyedTextMessage() {
    return TTLiveFontSize(14);
}

NS_INLINE CGFloat FontSizeOfNicknameLabel() {
    return TTLiveFontSize(12);
}

NS_INLINE CGFloat FontSizeOfSendTimeLabel() {
    return TTLiveFontSize(12);
}

NS_INLINE CGFloat SidePaddingCardImageView() {
    return TTLiveFontSize(10);
}

NS_INLINE CGFloat SideSizeCardImageView() {
    return TTLivePadding(50);
}

NS_INLINE CGFloat SidePaddingCardSourceImageView() {
    return TTLivePadding(3);
}

NS_INLINE CGFloat SideSizeCardSourceImageView() {
    return TTLivePadding(13);
}

NS_INLINE CGFloat LeftPaddingCardSourceMessage() {
    return TTLivePadding(6);
}

NS_INLINE CGFloat InsidePaddingCardTitleToSubtitle() {
    return TTLivePadding(8);
}

NS_INLINE CGFloat CardTitleFontSize() {
    return [TTDeviceUIUtils tt_newFontSize:16];
}

NS_INLINE CGFloat CardTitleLineHeight() {
    return CardTitleFontSize() * 1.3125;
}

NS_INLINE CGFloat CardSubtitleFontSize() {
    return [TTDeviceUIUtils tt_newFontSize:12];
}

NS_INLINE CGFloat CardSubtitleLineHeight() {
    return CardSubtitleFontSize() * 1.25;
}

NS_INLINE CGFloat CardSourceFontSize() {
    return [TTDeviceUIUtils tt_newFontSize:10];
}

NS_INLINE CGFloat LeftPaddingCardVip() {
    return TTLivePadding(4);
}

/// Line Height
NS_INLINE CGFloat LineHeightOfTextMessage() {
    return ceil(FontSizeOfTextMessage() * 1.3);
}

NS_INLINE CGFloat LineHeightOfReplyedTextMessage() {
    return ceil(FontSizeOfReplyedTextMessage() * 1.4);
}

NS_INLINE CGFloat LineHeightOfTopIconText() {
    return ceil(FontSizeOfTopTextLabel());
}

NS_INLINE CGFloat HeightOfTopInfoViewByReply() {
    return ceil(FontSizeOfNicknameLabel() + TopPaddingOfReplyNicknameLabel() + BottomPaddingOfReplyNickNameLabel());
}

/** 顶部信息栏高度 */
NS_INLINE CGFloat kLivePaddingCellTopInfoViewHeight(TTLiveCellLayout layout) {
    if (layout & TTLiveCellLayoutBubbleCoverTop){
        return ceil(FontSizeOfNicknameLabel() + TopPaddingOfNicknameLabel() + BottomPaddingOfNicknameLabel()) - TTLivePadding(3);
    }
    return ceil(FontSizeOfNicknameLabel() + TopPaddingOfNicknameLabel() + BottomPaddingOfNicknameLabel());
}

NS_INLINE CGFloat TopInfoViewWidth(TTLiveCellLayout layout) {
    return MaxWidthOfText(layout) + SidePaddingOfNicknameLabel() * 2;
}

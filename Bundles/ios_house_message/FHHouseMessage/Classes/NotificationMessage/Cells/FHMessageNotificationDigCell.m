//
//  FHMessageNotificationDigCell.m
//  Article
//
//  Created by zhulijun.2539 on 2019/6/17.
//
//

#import "FHMessageNotificationDigCell.h"
#import "TTMessageNotificationModel.h"
#import "TTImageView.h"
#import "FHMessageNotificationCellHelper.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <UIImage+FIconFont.h>
#import <UIColor+Theme.h>

NS_INLINE CGFloat kDigImageViewWidth() {
    return [FHMessageNotificationCellHelper tt_newPadding:20.f];
}

NS_INLINE CGFloat kDigImageViewHeight() {
    return [FHMessageNotificationCellHelper tt_newPadding:20.f];
}

NS_INLINE CGFloat kDigImageViewTopPadding() {
    return [FHMessageNotificationCellHelper tt_newPadding:6.f];
}

NS_INLINE CGFloat kDigImageViewLeftPadding() {
    return [FHMessageNotificationCellHelper tt_newPadding:66.f];
}

@implementation FHMessageNotificationDigCell

+ (Class)cellViewClass {
    return [FHMessageNotificationDigCellView class];
}

@end

@interface FHMessageNotificationDigCellView ()

@property(nonatomic, strong) SSThemedImageView *digImageView;

@end

@implementation FHMessageNotificationDigCellView

+ (CGFloat)heightForData:(TTMessageNotificationModel *)data cellWidth:(CGFloat)width {
    if ([data.cachedHeight floatValue] > 0) {
        return [data.cachedHeight floatValue];
    }
    CGFloat height = 0.f;

    height += FHMNRoleInfoViewTopPadding();
    height += FHMNRoleInfoViewHeight();
    height += kDigImageViewTopPadding();
    height += kDigImageViewHeight();
    height += FHMNTimeLabelTopPadding();
    height += FHMNTimeLabelHeight();

    if ([data.style integerValue] == TTMessageNotificationStyleDigMerge) {
        height += FHMNMultiTextViewTopPadding();
        height += FHMNMultiTextViewHeight();
    }

    height = MAX(height, FHMNAvatarImageViewSize() + FHMNAvatarImageViewTopPadding());
    //判断右边显示的是图片还是文字
    if (!isEmptyString(data.content.refThumbUrl)) {
        height = MAX(height, FHMNRefTopPadding() + FHMNRefImageViewSize());
    } else {
        height = MAX(height, FHMNRefTopPadding() + [self heightForRefTextLabelWithData:data maxWidth:FHMNRefTextLabelWidth()]);
    }

    height += FHMNTimeLabelBottomPadding();

    data.cachedHeight = @(height);

    return height;
}


- (SSThemedImageView *)digImageView {
    if (!_digImageView) {
        _digImageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _digImageView.contentMode = UIViewContentModeScaleAspectFill;
        _digImageView.image = ICON_FONT_IMG(20, @"\U0000e69c", [UIColor themeGray1]);
        [self addSubview:_digImageView];
    }
    return _digImageView;
}

- (void)refreshWithData:(TTMessageNotificationModel *)data {
    self.messageModel = data;

    if (self.messageModel) {
        [self updateAvatarImageView];

        if (!isEmptyString(self.messageModel.content.refThumbUrl)) {
            [self updateRefImageView];
        } else {
            [self updateRefTextLabel];
        }

        if ([self.messageModel.style integerValue] == TTMessageNotificationStyleDigMerge) {
            [self updateMultiTextView];
        }

        [self updateTimeLabel];
    }
}

- (void)refreshUI {
    [self layoutAvatarImageView];
    [self layoutRoleInfoView];

    self.digImageView.frame = CGRectMake(kDigImageViewLeftPadding(), self.roleInfoView.bottom + kDigImageViewTopPadding(), kDigImageViewWidth(), kDigImageViewHeight());

    [self layoutTimeLabelWithOrigin:CGPointMake(FHMNTimeLabelLeftPadding(), self.digImageView.bottom + FHMNTimeLabelTopPadding()) maxWidth:self.width - FHMNTimeLabelLeftPadding() - FHMNTimeLabelRightPaddingWithRef()];

    if ([self.messageModel.style integerValue] == TTMessageNotificationStyleDigMerge) {
        self.multiTextView.hidden = NO;

        [self layoutMultiTextViewWithOrigin:CGPointMake(FHMNMultiTextViewLeftPadding(), self.timeLabel.bottom + FHMNMultiTextViewTopPadding()) maxWitdh:self.width - FHMNMultiTextViewLeftPadding() - FHMNMultiTextViewRightPaddingWithRef()];
    } else {
        self.multiTextView.hidden = YES;
    }

    if (!isEmptyString(self.messageModel.content.refThumbUrl)) {
        self.refTextLabel.hidden = YES;
        self.refImageView.hidden = NO;
        [self layoutRefImageView];
    } else {
        self.refImageView.hidden = YES;
        self.refTextLabel.hidden = NO;
        [self layoutRefTextLabel];
    }

    [self layoutBottomLine];
}

@end

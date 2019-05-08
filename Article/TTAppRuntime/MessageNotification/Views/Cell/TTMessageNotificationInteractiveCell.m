//
//  TTMessageNotificationInteractiveCell.m
//  Article
//
//  Created by 邱鑫玥 on 2017/4/11.
//
//

#import "TTMessageNotificationInteractiveCell.h"
#import "TTMessageNotificationModel.h"
#import "TTLabelTextHelper.h"
#import "TTUserInfoView.h"
#import "TTImageView.h"
#import "TTMessageNotificationCellHelper.h"


#define ACTION_TEXT_LABEL_LEFT_PADDING [TTMessageNotificationCellHelper tt_newPadding:5.f]

#define ACTION_TEXT_LABEL_FONTSIZE [TTMessageNotificationCellHelper tt_newFontSize:14.f]

@implementation TTMessageNotificationInteractiveCell

+ (Class)cellViewClass{
    return [TTMessageNotificationInteractiveCellView class];
}

@end

@interface TTMessageNotificationInteractiveCellView()
@property (nonatomic, strong) SSThemedLabel *actionTextLabel;
@end

@implementation TTMessageNotificationInteractiveCellView

+ (CGFloat)heightForData:(TTMessageNotificationModel *)data cellWidth:(CGFloat)width{
    if ([data.cachedHeight floatValue] > 0){
        return [data.cachedHeight floatValue];
    }
    CGFloat height = 0.f;
    
    height += TTMNRoleInfoViewTopPadding();
    height += TTMNRoleInfoViewHeight();
    
    if(!isEmptyString(data.user.contactInfo)){
        height += TTMNContactInfoLabelTopPadding();
        height += TTMNContactInfoLabelHeight();
    }
    
    height += TTMNBodyTextLabelTopPadding();
    height += [self heightForBodyTextLabelWithData:data maxWidth:width - TTMNBodyTextLabelLeftPadding() - TTMNBodyTextLabelRightPaddingWithRef()];
    
    height += TTMNTimeLabelTopPadding();
    height += TTMNTimeLabelHeight();
    
    if([data.style integerValue]== TTMessageNotificationStyleInteractiveMerge){
        height += TTMNMultiTextViewTopPadding();
        height += TTMNMultiTextViewHeight();
    }
    
    height = MAX(height, TTMNAvatarImageViewSize() + TTMNAvatarImageViewTopPadding());
    //判断右边显示的是图片还是文字
    if(!isEmptyString(data.content.refThumbUrl)){
        height = MAX(height, TTMNRefTopPadding() + TTMNRefImageViewSize());
    }
    else{
        height = MAX(height, TTMNRefTopPadding() + [self heightForRefTextLabelWithData:data maxWidth:TTMNRefTextLabelWidth()]);
    }
    
    height += TTMNTimeLabelBottomPadding();
    
    data.cachedHeight = @(height);
    
    return height;
}


- (void)refreshWithData:(TTMessageNotificationModel *)data{
    self.messageModel = data;
    
    if(self.messageModel){
        [self updateAvatarImageView];
        
        [self updateActionTextLabel];
        
        if(!isEmptyString(self.messageModel.user.contactInfo)){
            [self updateContactInfoLabel];
        }
        
        [self updateBodyTextLabel];
        
        if(!isEmptyString(self.messageModel.content.refThumbUrl)){
            [self updateRefImageView];
        }
        else{
            [self updateRefTextLabel];
        }
        
        if([self.messageModel.style integerValue] == TTMessageNotificationStyleInteractiveMerge){
            [self updateMultiTextView];
        }
        
        [self updateTimeLabel];
    }
}

- (void)refreshUI{
    [self layoutAvatarImageView];
    CGFloat maxRoleInfoViewWidth = self.width - TTMNRoleInfoViewLeftPadding() - TTMNRoleInfoViewRightPaddingWithRef();
    [self updateRoleInfoViewForMaxWidth:maxRoleInfoViewWidth];
    [self layoutRoleInfoView];
    
    if(!isEmptyString(self.messageModel.user.contactInfo)){
        self.contactInfoLabel.hidden = NO;
        
        [self layoutContactInfoLabelWithOrigin:CGPointMake(TTMNContactInfoLabelLeftPadding(), self.roleInfoView.bottom + TTMNContactInfoLabelTopPadding()) maxWitdh:self.width - TTMNContactInfoLabelLeftPadding() - TTMNContactInfoLabelRightPaddingWithRef()];
        
        [self layoutBodyTextLabelWithOrigin:CGPointMake(TTMNBodyTextLabelLeftPadding(), self.contactInfoLabel.bottom + TTMNBodyTextLabelTopPadding()) maxWidth:self.width - TTMNBodyTextLabelLeftPadding() - TTMNBodyTextLabelRightPaddingWithRef()];
    }
    else{
        self.contactInfoLabel.hidden = YES;
        [self layoutBodyTextLabelWithOrigin:CGPointMake(TTMNBodyTextLabelLeftPadding(), self.roleInfoView.bottom + TTMNBodyTextLabelTopPadding()) maxWidth:self.width - TTMNBodyTextLabelLeftPadding() - TTMNBodyTextLabelRightPaddingWithRef()];
    }
    
    if (!isEmptyString(self.messageModel.content.actionText)) {
        [self.actionTextLabel sizeToFit];
        self.actionTextLabel.width = MIN(maxRoleInfoViewWidth, self.actionTextLabel.width);
        self.roleInfoView.width = maxRoleInfoViewWidth < self.roleInfoView.width + self.actionTextLabel.width + ACTION_TEXT_LABEL_LEFT_PADDING ? maxRoleInfoViewWidth - self.actionTextLabel.width - ACTION_TEXT_LABEL_LEFT_PADDING : self.roleInfoView.width;
        self.actionTextLabel.left = self.roleInfoView.right + ACTION_TEXT_LABEL_LEFT_PADDING;
        self.actionTextLabel.top = self.roleInfoView.top;
    }
    
    [self layoutTimeLabelWithOrigin:CGPointMake(TTMNTimeLabelLeftPadding(), self.bodyTextLabel.bottom + TTMNTimeLabelTopPadding()) maxWidth:self.width - TTMNTimeLabelLeftPadding() - TTMNTimeLabelRightPaddingWithRef()];
    
    if([self.messageModel.style integerValue] == TTMessageNotificationStyleInteractiveMerge){
        self.multiTextView.hidden = NO;
        [self layoutMultiTextViewWithOrigin:CGPointMake(TTMNMultiTextViewLeftPadding(), self.timeLabel.bottom + TTMNMultiTextViewTopPadding()) maxWitdh:self.width - TTMNMultiTextViewLeftPadding() - TTMNMultiTextViewRightPaddingWithRef()];
    }
    else{
        self.multiTextView.hidden = YES;
    }
    
    if(!isEmptyString(self.messageModel.content.refThumbUrl)){
        self.refTextLabel.hidden = YES;
        self.refImageView.hidden = NO;
        [self layoutRefImageView];
    }
    else{
        self.refImageView.hidden = YES;
        self.refTextLabel.hidden = NO;
        [self layoutRefTextLabel];
    }
    
    [self layoutBottomLine];
}

- (SSThemedLabel *)actionTextLabel{
    if(!_actionTextLabel){
        _actionTextLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _actionTextLabel.font = [UIFont systemFontOfSize:ACTION_TEXT_LABEL_FONTSIZE];
        _actionTextLabel.textColorThemeKey = kColorText1;
        _actionTextLabel.numberOfLines = 1;
        _actionTextLabel.textAlignment = NSTextAlignmentLeft;
        _actionTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_actionTextLabel];
    }
    return _actionTextLabel;
}

- (void)updateActionTextLabel{
    if(!isEmptyString(self.messageModel.content.actionText)){
        self.actionTextLabel.text = self.messageModel.content.actionText;
    }
    else{
        self.actionTextLabel.text = nil;
    }
}

@end


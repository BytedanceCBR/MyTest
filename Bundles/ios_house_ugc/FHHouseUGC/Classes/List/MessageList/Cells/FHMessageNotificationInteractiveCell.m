//
//  FHMessageNotificationInteractiveCell.m
//  Article
//
//  Created by zhulijun.2539 on 2019/6/17.
//
//

#import "FHMessageNotificationInteractiveCell.h"
#import "TTMessageNotificationModel.h"
#import "TTImageView.h"
#import "FHMessageNotificationCellHelper.h"
#import <TTBaseLib/UIViewAdditions.h>

#define ACTION_TEXT_LABEL_LEFT_PADDING [FHMessageNotificationCellHelper tt_newPadding:5.f]

#define ACTION_TEXT_LABEL_FONTSIZE [FHMessageNotificationCellHelper tt_newFontSize:14.f]

@implementation FHMessageNotificationInteractiveCell

+ (Class)cellViewClass{
    return [FHMessageNotificationInteractiveCellView class];
}

@end

@interface FHMessageNotificationInteractiveCellView()
@property (nonatomic, strong) SSThemedLabel *actionTextLabel;
@end

@implementation FHMessageNotificationInteractiveCellView

+ (CGFloat)heightForData:(TTMessageNotificationModel *)data cellWidth:(CGFloat)width{
    if ([data.cachedHeight floatValue] > 0){
        return [data.cachedHeight floatValue];
    }
    CGFloat height = 0.f;
    
    height += FHMNRoleInfoViewTopPadding();
    height += FHMNRoleInfoViewHeight();
    
    if(!isEmptyString(data.user.contactInfo)){
        height += FHMNContactInfoLabelTopPadding();
        height += FHMNContactInfoLabelHeight();
    }
    
    height += FHMNBodyTextLabelTopPadding();
    height += [self heightForBodyTextLabelWithData:data maxWidth:width - FHMNBodyTextLabelLeftPadding() - FHMNBodyTextLabelRightPaddingWithRef()];
    
    height += FHMNTimeLabelTopPadding();
    height += FHMNTimeLabelHeight();
    
    if([data.style integerValue]== TTMessageNotificationStyleInteractiveMerge){
        height += FHMNMultiTextViewTopPadding();
        height += FHMNMultiTextViewHeight();
    }
    
    height = MAX(height, FHMNAvatarImageViewSize() + FHMNAvatarImageViewTopPadding());
    //判断右边显示的是图片还是文字
    if(!isEmptyString(data.content.refThumbUrl)){
        height = MAX(height, FHMNRefTopPadding() + FHMNRefImageViewSize());
    }
    else{
        height = MAX(height, FHMNRefTopPadding() + [self heightForRefTextLabelWithData:data maxWidth:FHMNRefTextLabelWidth()]);
    }
    
    height += FHMNTimeLabelBottomPadding();
    
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
    CGFloat maxRoleInfoViewWidth = self.width - FHMNRoleInfoViewLeftPadding() - FHMNRoleInfoViewRightPaddingWithRef();
    [self updateRoleInfoViewForMaxWidth:maxRoleInfoViewWidth];
    [self layoutRoleInfoView];
    
    if(!isEmptyString(self.messageModel.user.contactInfo)){
        self.contactInfoLabel.hidden = NO;
        
        [self layoutContactInfoLabelWithOrigin:CGPointMake(FHMNContactInfoLabelLeftPadding(), self.roleInfoView.bottom + FHMNContactInfoLabelTopPadding()) maxWitdh:self.width - FHMNContactInfoLabelLeftPadding() - FHMNContactInfoLabelRightPaddingWithRef()];
        
        [self layoutBodyTextLabelWithOrigin:CGPointMake(FHMNBodyTextLabelLeftPadding(), self.contactInfoLabel.bottom + FHMNBodyTextLabelTopPadding()) maxWidth:self.width - FHMNBodyTextLabelLeftPadding() - FHMNBodyTextLabelRightPaddingWithRef()];
    }
    else{
        self.contactInfoLabel.hidden = YES;
        [self layoutBodyTextLabelWithOrigin:CGPointMake(FHMNBodyTextLabelLeftPadding(), self.roleInfoView.bottom + FHMNBodyTextLabelTopPadding()) maxWidth:self.width - FHMNBodyTextLabelLeftPadding() - FHMNBodyTextLabelRightPaddingWithRef()];
    }
    
    if (!isEmptyString(self.messageModel.content.actionText)) {
        [self.actionTextLabel sizeToFit];
        self.actionTextLabel.width = MIN(maxRoleInfoViewWidth, self.actionTextLabel.width);
        self.roleInfoView.width = maxRoleInfoViewWidth < self.roleInfoView.width + self.actionTextLabel.width + ACTION_TEXT_LABEL_LEFT_PADDING ? maxRoleInfoViewWidth - self.actionTextLabel.width - ACTION_TEXT_LABEL_LEFT_PADDING : self.roleInfoView.width;
        self.actionTextLabel.left = self.roleInfoView.right + ACTION_TEXT_LABEL_LEFT_PADDING;
        self.actionTextLabel.top = self.roleInfoView.top;
    }
    
    [self layoutTimeLabelWithOrigin:CGPointMake(FHMNTimeLabelLeftPadding(), self.bodyTextLabel.bottom + FHMNTimeLabelTopPadding()) maxWidth:self.width - FHMNTimeLabelLeftPadding() - FHMNTimeLabelRightPaddingWithRef()];
    
    if([self.messageModel.style integerValue] == TTMessageNotificationStyleInteractiveMerge){
        self.multiTextView.hidden = NO;
        [self layoutMultiTextViewWithOrigin:CGPointMake(FHMNMultiTextViewLeftPadding(), self.timeLabel.bottom + FHMNMultiTextViewTopPadding()) maxWitdh:self.width - FHMNMultiTextViewLeftPadding() - FHMNMultiTextViewRightPaddingWithRef()];
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


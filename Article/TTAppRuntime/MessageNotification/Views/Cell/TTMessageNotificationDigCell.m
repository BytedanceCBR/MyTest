//
//  TTMessageNotificationDigCell.m
//  Article
//
//  Created by 邱鑫玥 on 2017/4/11.
//
//

#import "TTMessageNotificationDigCell.h"
#import "TTMessageNotificationModel.h"
#import "TTAsyncCornerImageView.h"
#import "TTUserInfoView.h"
#import "TTLabelTextHelper.h"
#import "TTImageView.h"
#import "TTMessageNotificationCellHelper.h"

NS_INLINE CGFloat kDigImageViewWidth(){
    return [TTMessageNotificationCellHelper tt_newPadding:19.f];
}

NS_INLINE CGFloat kDigImageViewHeight(){
    return [TTMessageNotificationCellHelper tt_newPadding:18.5f];
}

NS_INLINE CGFloat kDigImageViewTopPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:8.f];
}

NS_INLINE CGFloat kDigImageViewLeftPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:63.f];
}

@implementation TTMessageNotificationDigCell

+ (Class)cellViewClass{
    return [TTMessageNotificationDigCellView class];
}

@end

@interface TTMessageNotificationDigCellView()

@property (nonatomic, strong) SSThemedImageView *digImageView;

@end

@implementation TTMessageNotificationDigCellView

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
    
    height += kDigImageViewTopPadding();
    
    height += kDigImageViewHeight();
    
    height += TTMNTimeLabelTopPadding();
    
    height += TTMNTimeLabelHeight();
    
    if([data.style integerValue]== TTMessageNotificationStyleDigMerge){
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


- (SSThemedImageView *)digImageView{
    if(!_digImageView){
        _digImageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _digImageView.contentMode = UIViewContentModeScaleAspectFill;
        _digImageView.imageName = @"noticeicon_like";
        [self addSubview:_digImageView];
    }
    return _digImageView;
}

- (void)refreshWithData:(TTMessageNotificationModel *)data{
    self.messageModel = data;
    
    if(self.messageModel){
        [self updateAvatarImageView];
        
        if(!isEmptyString(self.messageModel.user.contactInfo)){
            [self updateContactInfoLabel];
        }
        
        if(!isEmptyString(self.messageModel.content.refThumbUrl)){
            [self updateRefImageView];
        }
        else{
            [self updateRefTextLabel];
        }
        
        if([self.messageModel.style integerValue] == TTMessageNotificationStyleDigMerge){
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

        self.digImageView.frame = CGRectMake(kDigImageViewLeftPadding(), self.contactInfoLabel.bottom + kDigImageViewTopPadding(), kDigImageViewWidth(), kDigImageViewHeight());
    }
    else{
        self.contactInfoLabel.hidden = YES;
        self.digImageView.frame = CGRectMake(kDigImageViewLeftPadding(), self.roleInfoView.bottom + kDigImageViewTopPadding(), kDigImageViewWidth(), kDigImageViewHeight());
    }
    
    [self layoutTimeLabelWithOrigin:CGPointMake(TTMNTimeLabelLeftPadding(), self.digImageView.bottom + TTMNTimeLabelTopPadding()) maxWidth:self.width - TTMNTimeLabelLeftPadding() - TTMNTimeLabelRightPaddingWithRef()];
    
    if([self.messageModel.style integerValue] == TTMessageNotificationStyleDigMerge){
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

@end

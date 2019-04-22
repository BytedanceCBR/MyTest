//
//  ExploreVideoDetailAppointGroupPicADView.m
//  Article
//
//  Created by yin on 2017/8/31.
//
//

#import "ExploreVideoDetailAppointGroupPicADView.h"
#import "TTLabelTextHelper.h"
#import "NSString-Extension.h"
#import "TTAdDetailViewHelper.h"

@implementation ExploreVideoDetailAppointGroupPicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_appoint_groupPic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.actionButton];
        [self addSubview:self.bottomContainerView];
        [self sendSubviewToBack:self.bottomContainerView];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    
    [super setAdModel:adModel];
    
    self.sourceLabel.text = adModel.sourceString;
    [self.sourceLabel sizeToFit];
    
    [self.actionButton setTitle:adModel.buttonText ? adModel.buttonText : @"立即预约" forState:UIControlStateNormal];
    self.actionButton.size = CGSizeMake(kActionButtonWidth, kActionButtonHeight);
    
    [self layoutVideo:adModel];
}


- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    [super layoutVideo:adModel];
    
    self.dislikeView.center = CGPointMake(self.width - kAppointDislikeImageWidth/2, kAppointDislikeImageTopPadding + kAppointDislikeImageWidth/2);
    CGFloat dislikePadding = self.adModel.showDislike? kAppointDislikeImageWidth + kAppointDislikeImageLeftPadding:0;
    self.titleLabel.width = self.width- 2 * kVideoHoriMargin - dislikePadding;
    
    self.bottomContainerView.frame = CGRectMake(self.groupPicView.left, self.groupPicView.top, self.groupPicView.width, self.groupPicView.height + kActionButtonHeight + 2*kVideoActionButtonPadding);
    
    self.actionButton.top = self.groupPicView.bottom + kVideoActionButtonPadding;
    self.actionButton.right = self.groupPicView.right - 8;
    self.sourceLabel.left = self.groupPicView.left + 10;
    self.sourceLabel.centerY = self.actionButton.centerY;
    CGFloat sourceMaxWidth = self.groupPicView.width - self.sourceLabel.left - 5 - self.adLabel.width - kVideoAdLabelRitghtPadding - kActionButtonWidth - 8;
    self.sourceLabel.width = [self.sourceLabel.text tt_sizeWithMaxWidth:sourceMaxWidth font:self.sourceLabel.font].width;
    self.adLabel.left = self.sourceLabel.right + kVideoAdLabelRitghtPadding;
    self.adLabel.centerY = self.sourceLabel.centerY;
    self.actionButton.hidden = isEmptyString(adModel.buttonText);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat height = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:kDetailAdTitleFontSize forWidth:width - 2 * kVideoHoriMargin forLineHeight:kDetailAdTitleLineHeight constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    height += [ExploreDetailADGroupPicView heightForWidth:width];
    height += kVideoTitleTopPadding + kVideoTitleBottomPadding + kActionButtonHeight + 2*kVideoActionButtonPadding + kVideoAppPhoneBottomPadding;
    return height;
}

#pragma mark - response

- (void)appointActionFired:(id)sender {
    [self appointActionWithADModel:self.adModel];
}

#pragma mark - getter

- (SSThemedLabel*)sourceLabel
{
    SSThemedLabel* sourceLabel = [super sourceLabel];
    sourceLabel.textColorThemeKey = kColorText2;
    sourceLabel.font = [UIFont systemFontOfSize:14];
    return sourceLabel;
}

- (SSThemedButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor clearColor];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _actionButton.layer.cornerRadius = 6;
        _actionButton.layer.borderWidth = 1;
        _actionButton.borderColorThemeKey = kColorLine3;
        _actionButton.clipsToBounds = YES;
        _actionButton.titleColorThemeKey = kColorText6;
        [_actionButton addTarget:self action:@selector(appointActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_details";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

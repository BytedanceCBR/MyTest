//
//  ExploreVideoDetailPhoneGroupPicADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreVideoDetailPhoneGroupPicADView.h"
#import "TTLabelTextHelper.h"
#import "NSString-Extension.h"
#import "TTAdDetailViewHelper.h"

@implementation ExploreVideoDetailPhoneGroupPicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_phone_groupPic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.callButton];
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
    
    [self.callButton setTitle:adModel.buttonText ? adModel.buttonText : @"拨打电话" forState:UIControlStateNormal];
    self.callButton.size = CGSizeMake(kActionButtonWidth, kActionButtonHeight);
    
    [self layoutVideo:adModel];
}


- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    [super layoutVideo:adModel];
    
    self.dislikeView.center = CGPointMake(self.width - kPhoneDislikeImageWidth/2, kPhoneDislikeImageTopPadding + kPhoneDislikeImageWidth/2);
    CGFloat dislikePadding = self.adModel.showDislike? kPhoneDislikeImageWidth + kPhoneDislikeImageLeftPadding:0;
    self.titleLabel.width = self.width- 2 * kVideoHoriMargin - dislikePadding;
    
    self.bottomContainerView.frame = CGRectMake(self.groupPicView.left, self.groupPicView.top, self.groupPicView.width, self.groupPicView.height + kActionButtonHeight + 2*kVideoActionButtonPadding);
    
    self.callButton.top = self.groupPicView.bottom + kVideoActionButtonPadding;
    self.callButton.right = self.groupPicView.right - 8;
    self.sourceLabel.left = self.groupPicView.left + 10;
    self.sourceLabel.centerY = self.callButton.centerY;
    CGFloat sourceMaxWidth = self.groupPicView.width - self.sourceLabel.left - 5 - self.adLabel.width - kVideoAdLabelRitghtPadding - kActionButtonWidth - 8;
    self.sourceLabel.width = [self.sourceLabel.text tt_sizeWithMaxWidth:sourceMaxWidth font:self.sourceLabel.font].width;
    self.adLabel.left = self.sourceLabel.right + kVideoAdLabelRitghtPadding;
    self.adLabel.centerY = self.sourceLabel.centerY;
    self.callButton.hidden = isEmptyString(adModel.buttonText)||isEmptyString(adModel.mobile);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat height = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:kDetailAdTitleFontSize forWidth:width - 2 * kVideoHoriMargin forLineHeight:kDetailAdTitleLineHeight constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    height += [ExploreDetailADGroupPicView heightForWidth:width];
    height += kVideoTitleTopPadding + kVideoTitleBottomPadding + kActionButtonHeight + 2*kVideoActionButtonPadding + kVideoAppPhoneBottomPadding;
    return height;
}

#pragma mark - response

- (void)callActionFired {
    [self callActionWithADModel:self.adModel];
}

#pragma mark - getter

- (SSThemedLabel*)sourceLabel
{
    SSThemedLabel* sourceLabel = [super sourceLabel];
    sourceLabel.textColorThemeKey = kColorText2;
    sourceLabel.font = [UIFont systemFontOfSize:14];
    return sourceLabel;
}

- (SSThemedButton *)callButton
{
    if (!_callButton) {
        _callButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _callButton.backgroundColor = [UIColor clearColor];
        _callButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _callButton.layer.cornerRadius = 6;
        _callButton.layer.borderWidth = 1;
        _callButton.borderColorThemeKey = kColorLine3;
        _callButton.clipsToBounds = YES;
        _callButton.titleColorThemeKey = kColorText6;
        [_callButton addTarget:self action:@selector(callActionFired) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callButton;
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

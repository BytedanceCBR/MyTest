//
//  ExploreVideoDetailPhoneLargePicADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreVideoDetailPhoneLargePicADView.h"
#import "TTLabelTextHelper.h"
#import "NSString-Extension.h"
#import "TTAdDetailViewHelper.h"

#define kAppHorizonPadding 12
#define kCallActionWidth 72
#define kCallActionHeight 28
#define kAppHeight 44
#define kPaddingSourceToTitle 1 //app名称与标题间距(纵向)


@implementation ExploreVideoDetailPhoneLargePicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_phone_largePic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.actionButton];
        [self addSubview:self.bottomContainerView];
        [self sendSubviewToBack:self.bottomContainerView];
        [self addSubview:self.dislikeView];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    
    [super setAdModel:adModel];
    
    self.sourceLabel.text = adModel.sourceString;
    [self.sourceLabel sizeToFit];
    
    self.titleLabel.text = adModel.titleString;
    [self.titleLabel sizeToFit];
    
    [self.actionButton setTitle:adModel.buttonText ? adModel.buttonText : @"拨打电话" forState:UIControlStateNormal];
    self.actionButton.size = CGSizeMake(kCallActionWidth, kCallActionHeight);
    
    [self layoutVideo:adModel];
}

- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    const CGFloat contentMaxWidth = self.width - kVideoTitleLeftPadding - kVideoTitleRightPadding;
    const CGFloat dislikePadding = self.adModel.showDislike? (kPhoneDislikeImageWidth + kPhoneDislikeImageLeftPadding) : 0;
    const CGFloat titleContentMaxWidth = contentMaxWidth - dislikePadding;
    //1
    self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:adModel.titleString fontSize:[TTDeviceUIUtils tt_fontSize:17] lineHeight:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]].pointSize * 1.2];
    const CGFloat titleHeight = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize] forWidth:titleContentMaxWidth forLineHeight:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize]].pointSize * 1.2 constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    self.titleLabel.frame = CGRectMake(kVideoTitleLeftPadding, kVideoTitleTopPadding, titleContentMaxWidth, titleHeight);
    
    self.dislikeView.center = CGPointMake(self.width - kPhoneDislikeImageWidth/2, kPhoneDislikeImageTopPadding + kPhoneDislikeImageWidth/2);
    self.dislikeView.hidden = !self.adModel.showDislike;
    //2
    CGFloat imageHeight = [TTAdDetailViewUtil imageFitHeight:adModel width:contentMaxWidth];
    self.imageView.size = CGSizeMake(contentMaxWidth, imageHeight);
    self.imageView.origin = CGPointMake(self.titleLabel.left, self.titleLabel.bottom + kVideoTitleBottomPadding);
    //3
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    self.bottomContainerView.frame = CGRectMake(self.imageView.left, self.imageView.top, self.imageView.width, self.imageView.height + kCallActionHeight + 2*kVideoActionButtonPadding);
    self.actionButton.top = self.imageView.bottom + kVideoActionButtonPadding;
    self.actionButton.right = self.imageView.right - 8;
    self.sourceLabel.left = self.imageView.left + 10;
    self.sourceLabel.centerY = self.actionButton.centerY;
    CGFloat sourceMaxWidth = self.imageView.width - self.sourceLabel.left - 5 - self.adLabel.width - kVideoAdLabelRitghtPadding - kCallActionWidth - 8;
    self.sourceLabel.width = [self.sourceLabel.text tt_sizeWithMaxWidth:sourceMaxWidth font:self.sourceLabel.font].width;
    self.adLabel.left = self.sourceLabel.right + 5;
    self.adLabel.centerY = self.sourceLabel.centerY;
    self.actionButton.hidden = isEmptyString(adModel.buttonText)||isEmptyString(adModel.mobile);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    const CGFloat conteMaxWidth = width - kVideoTitleLeftPadding - kVideoTitleRightPadding;
    CGFloat height = [TTAdDetailViewUtil imageFitHeight:adModel width:conteMaxWidth];
    if (!isEmptyString(adModel.titleString)) {
        const CGFloat dislikePadding = adModel.showDislike? (kPhoneDislikeImageWidth + kPhoneDislikeImageLeftPadding) : 0;
        const CGFloat titleContentMaxWidth = conteMaxWidth - dislikePadding;
         CGFloat titleHeight = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize] forWidth:titleContentMaxWidth forLineHeight:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize]].pointSize * 1.2 constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
        height += kVideoTitleTopPadding + titleHeight + kVideoTitleBottomPadding + kCallActionHeight + 2*kVideoActionButtonPadding + kVideoAppPhoneBottomPadding;
    }
    
    return height;
}

#pragma mark - response

- (void)callActionFired:(id)sender {
    [self callActionWithADModel:self.adModel];
}

#pragma mark - getter

- (SSThemedLabel *)titleLabel
{
    SSThemedLabel *label = [super titleLabel];
    label.font = [UIFont systemFontOfSize:17];
    return label;
}

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
        [_actionButton addTarget:self action:@selector(callActionFired:) forControlEvents:UIControlEventTouchUpInside];
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

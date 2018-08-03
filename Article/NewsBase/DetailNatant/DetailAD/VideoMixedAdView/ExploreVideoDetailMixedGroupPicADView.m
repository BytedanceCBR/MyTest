//
//  ExploreVideoDetailMixedGroupPicADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreVideoDetailMixedGroupPicADView.h"
#import "TTLabelTextHelper.h"
#import "TTImageInfosModel.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "TTAdDetailViewHelper.h"


#define kVideoTitleBottomPadding 8


@implementation ExploreVideoDetailMixedGroupPicADView

+ (void)load
{
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_mixed_groupPic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        //在ipad的视频详情页不加边框
        self.layer.borderWidth = 0;
        [self addSubview:self.titleLabel];
        [self addSubview:self.groupPicView];
        [self addSubview:self.adLabel];
        [self addSubview:self.sourceLabel];
        [self addSubview:self.dislikeView];
    }
    return self;
}

- (void)setAdModel:(ArticleDetailADModel *)adModel
{
    [super setAdModel:adModel];
    
    [self.groupPicView refreshWithImageList:adModel.imageList];
    
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    self.sourceLabel.text = adModel.sourceString;
    [self.sourceLabel sizeToFit];
    [self layoutVideo:adModel];
    
}

- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:adModel.titleString fontSize:kDetailAdTitleFontSize lineHeight:kDetailAdTitleLineHeight];
    self.titleLabel.height = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:kDetailAdTitleFontSize forWidth:self.width - 2 * kVideoHoriMargin forLineHeight:kDetailAdTitleLineHeight constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    self.titleLabel.width = self.width - 2 * kVideoHoriMargin;
    self.titleLabel.origin = CGPointMake(kVideoTitleLeftPadding, kVideoTitleTopPadding);
    self.groupPicView.origin = CGPointMake(self.titleLabel.left, self.titleLabel.bottom + kVideoTitleBottomPadding);
    self.adLabel.origin = CGPointMake(self.groupPicView.left, self.groupPicView.bottom + kVideoTitleBottomPadding);
    
    self.sourceLabel.origin = CGPointMake(self.adLabel.right + kVideoAdLabelRitghtPadding, self.groupPicView.bottom + kVideoTitleBottomPadding);
    self.sourceLabel.width = self.groupPicView.width - self.sourceLabel.left - kVideoDislikeImageWidth;
    self.adLabel.centerY = self.sourceLabel.centerY;
    
    self.dislikeView.center = CGPointMake(self.groupPicView.right - kVideoDislikeImageWidth/2, self.sourceLabel.centerY);
    self.dislikeView.hidden = !self.adModel.showDislike;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat height = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:kDetailAdTitleFontSize forWidth:width - 2 * kVideoHoriMargin forLineHeight:kDetailAdTitleLineHeight constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    height += [ExploreDetailADGroupPicView heightForWidth:width];
    height += kVideoTitleTopPadding + kVideoTitleBottomPadding + kSourceLabelHeight +kVideoTitleBottomPadding + kVideoTitleTopPadding;
    
    return height;
}

+ (void)updateADLabel:(SSThemedLabel *)adLabel withADModel:(ArticleDetailADModel *)adModel
{
    [ExploreDetailBaseADView updateADLabel:adLabel withADModel:adModel];
    adLabel.textColorThemeKey = kColorText5;
    adLabel.borderColorThemeKey = kColorLine6;
    adLabel.backgroundColorThemeKey = kColorBackground4;
    adLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
}


- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:kDetailAdTitleFontSize];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (ExploreDetailADGroupPicView *)groupPicView
{
    if (!_groupPicView) {
        _groupPicView = [[ExploreDetailADGroupPicView alloc] initWithWidth:self.width - kVideoHoriMargin * 2];
    }
    return _groupPicView;
}

- (SSThemedLabel *)adLabel
{
    if (!_adLabel) {
        _adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    }
    return _adLabel;
}

- (SSThemedLabel *)sourceLabel
{
    if (!_sourceLabel) {
        _sourceLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _sourceLabel.textAlignment = NSTextAlignmentLeft;
        _sourceLabel.font = [UIFont systemFontOfSize:12];
        _sourceLabel.textColorThemeKey = kColorText3;
        _sourceLabel.numberOfLines = 1;
        _sourceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _sourceLabel;
}

- (SSThemedLabel*)bottomContainerView
{
    if (!_bottomContainerView) {
        _bottomContainerView = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _bottomContainerView.backgroundColorThemeKey = kColorBackground3;
        _bottomContainerView.borderColorThemeKey = kColorLine1;
        _bottomContainerView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    }
    return _bottomContainerView;
}

- (NSString*)dislikeImageName
{
    return @"add_textpage";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

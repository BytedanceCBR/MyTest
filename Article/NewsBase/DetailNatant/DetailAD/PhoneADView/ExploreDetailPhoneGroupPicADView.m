//
//  ExploreDetailPhoneGroupPicADView.m
//  Article
//
//  Created by 冯靖君 on 16/7/11.
//
//

#import "ExploreDetailPhoneGroupPicADView.h"
#import "TTAdDetailViewHelper.h"

@implementation ExploreDetailPhoneGroupPicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"phone_groupPic" forArea:TTAdDetailViewAreaArticle];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.callButton];
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
    
    [self layout];
}

- (void)layout
{
    [super layout];
    
    //布局dislike
    self.dislikeView.center = CGPointMake(self.groupPicView.right - kPhoneDislikeImageWidth/2, kPhoneDislikeImageTopPadding + kPhoneDislikeImageWidth/2);
    
    self.callButton.top = [ExploreDetailMixedGroupPicADView heightForADModel:self.adModel constrainedToWidth:self.width];
    self.callButton.right = self.width - kHoriMargin;
    
    self.sourceLabel.left = kHoriMargin;
    self.sourceLabel.centerY = self.callButton.centerY;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat superHeight = [ExploreDetailMixedGroupPicADView heightForADModel:adModel constrainedToWidth:width];
    superHeight += kActionButtonHeight + kActionBottomMargin;
    return superHeight;
}

#pragma mark - response

- (void)callActionFired {
    [self callActionWithADModel:self.adModel];
}

#pragma mark - getter

- (SSThemedLabel*)sourceLabel
{
    SSThemedLabel* sourceLabel = [super sourceLabel];
    sourceLabel.textColorThemeKey = kColorText1;
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

@end

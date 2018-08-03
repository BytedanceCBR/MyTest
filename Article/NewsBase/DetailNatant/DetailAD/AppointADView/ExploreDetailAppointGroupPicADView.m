//
//  ExploreDetailAppointGroupPicADView.m
//  Article
//
//  Created by yin on 16/9/29.
//
//

#import "ExploreDetailAppointGroupPicADView.h"
#import "TTAdDetailViewHelper.h"

@implementation ExploreDetailAppointGroupPicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"appoint_groupPic" forArea:TTAdDetailViewAreaArticle];
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
    
    [self.callButton setTitle:adModel.buttonText ? adModel.buttonText : @"立即预约" forState:UIControlStateNormal];
    self.callButton.size = CGSizeMake(kActionButtonWidth, kActionButtonHeight);
    
    [self layout];
}

- (void)layout
{
    [super layout];
    
    self.dislikeView.center = CGPointMake(self.groupPicView.right - kAppointDislikeImageWidth/2, kAppointDislikeImageTopPadding + kAppointDislikeImageWidth/2);
    
    self.callButton.top = [ExploreDetailMixedGroupPicADView heightForADModel:self.adModel constrainedToWidth:self.width];
    self.callButton.right = self.width - kHoriMargin;
    
    self.sourceLabel.left = kHoriMargin;
    self.sourceLabel.centerY = self.callButton.centerY;
    self.sourceLabel.width = self.groupPicView.width - self.callButton.width;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat superHeight = [ExploreDetailMixedGroupPicADView heightForADModel:adModel constrainedToWidth:width];
    superHeight += kActionButtonHeight + kActionBottomMargin;
    return superHeight;
}

#pragma mark - response

- (void)appointActionFired:(id)sender {
    [self appointActionWithADModel:self.adModel];
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
        [_callButton addTarget:self action:@selector(appointActionFired:) forControlEvents:UIControlEventTouchUpInside];
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

//
//  ExploreDetailAppointVideoADView.m
//  Article
//
//  Created by yin on 2017/8/30.
//
//

#import "ExploreDetailAppointVideoADView.h"
#import "TTAdDetailViewHelper.h"

#define kAppHorizonPadding 8
#define kCallActionWidth 72
#define kCallActionHeight 28
#define kAppHeight 44

@implementation ExploreDetailAppointVideoADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"appoint_video" forArea:TTAdDetailViewAreaArticle];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.actionButton];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    
    [super setAdModel:adModel];
    
    self.sourceLabel.text = adModel.sourceString;
    [self.sourceLabel sizeToFit];
    
    self.actionButton.size = CGSizeMake(kCallActionWidth, kCallActionHeight);
    
    [self layout];
}

- (void)layout
{
    [super layout];
    self.backgroundColorThemeKey = kColorBackground4;
    self.sourceLabel.left = kAppHorizonPadding;
    self.sourceLabel.centerY = self.logo.bottom + kAppHeight / 2;
    self.actionButton.right = self.width - kAppHorizonPadding;
    self.actionButton.centerY = self.logo.bottom + kAppHeight / 2;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat imageHeight = videoFitHeight(adModel, width);
    return imageHeight + kAppHeight;
}

#pragma mark - response

- (void)appointActionFired:(id)sender {
    [self appointActionWithADModel:self.adModel];
    [self.movieView.player pause];
    [self.movieView.player.controlView setToolBarHidden:NO needAutoHide:NO];
}

#pragma mark - getter

- (SSThemedButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor clearColor];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _actionButton.layer.cornerRadius = 6;
        _actionButton.layer.borderWidth = 1;
        _actionButton.borderColorThemeKey = kColorLine3;
        _actionButton.clipsToBounds = YES;
        _actionButton.titleColorThemeKey = kColorText6;
        [_actionButton addTarget:self action:@selector(appointActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  ExploreVideoDetailAppointLeftPicADView.m
//  Article
//
//  Created by yin on 2017/8/30.
//
//

#import "ExploreVideoDetailAppointLeftPicADView.h"
#import "TTAdDetailViewHelper.h"

#define kPaddingRight 10
#define kPaddingBottom 10


@implementation ExploreVideoDetailAppointLeftPicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_appoint_leftPic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.actionButton];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    [super setAdModel:adModel];
    self.titleLabel.text = adModel.titleString;
    self.sourceLabel.text = adModel.sourceString;
    
    CGSize imageSize = [TTAdDetailViewUtil imgSizeForViewWidth:self.width + 30];
    CGFloat containWidth = self.width - imageSize.width - kVideoLeftPadding - kVideoRightPadding - kVideoRightImgLeftPadding;
    
    [self.titleLabel sizeToFit: containWidth];
    [self.sourceLabel sizeToFit];
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    [self.actionButton setTitle:adModel.buttonText ? adModel.buttonText : @"立即预约" forState:UIControlStateNormal];
    [self.actionButton sizeToFit];
    
    [self layoutVideo:adModel];
}


- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    [super layoutVideo:adModel];
    self.actionButton.right = self.imageView.left - kPaddingRight;
    self.actionButton.centerY = self.sourceLabel.centerY;
    CGSize imageSize = [TTAdDetailViewUtil imgSizeForViewWidth:self.width+ 30];
    CGFloat containWidth = self.width - imageSize.width - kVideoLeftPadding - kVideoRightPadding - kVideoRightImgLeftPadding;
    self.sourceLabel.width = containWidth - self.adLabel.width - self.actionButton.width - kVideoAdLabelRitghtPadding;
    self.actionButton.hidden = isEmptyString(adModel.buttonText);
    self.dislikeView.center = CGPointMake(self.imageView.right - kVideoDislikeImageWidth/2 - kVideoDislikeMarginPadding, self.imageView.top + kVideoDislikeImageWidth/2 + kVideoDislikeMarginPadding);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGSize picSize = [TTAdDetailViewUtil imgSizeForViewWidth:width];
    CGFloat height = kVideoTopPadding + picSize.height + kVideoBottomPadding;
    return height;
}

#pragma mark - response

- (void)appointActionFired:(id)sender {
    [self appointActionWithADModel:self.adModel];
}


#pragma mark - getter

- (SSThemedButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor clearColor];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _actionButton.titleColorThemeKey = kColorText5;
        [_actionButton addTarget:self action:@selector(appointActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_ad_details";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

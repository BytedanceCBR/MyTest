//
//  ExploreVideoDetailPhoneLeftPicADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreVideoDetailPhoneLeftPicADView.h"
#import "TTAdDetailViewHelper.h"

#define kPaddingLeft 10
#define kPaddingRight 10
#define kPaddingBottom 10
#define kPaddingTop 10
#define kPaddingTitleToPic 10  //标题与图片(视频)间距(横向)
#define kPaddingTitleBottom 7  //标题与来源文字间距(纵向)


@implementation ExploreVideoDetailPhoneLeftPicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_phone_leftPic" forArea:TTAdDetailViewAreaVideo];
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
    [self.actionButton setTitle:adModel.buttonText ? adModel.buttonText : @"拨打电话" forState:UIControlStateNormal];
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
    self.actionButton.hidden = isEmptyString(adModel.buttonText)||isEmptyString(adModel.mobile);
    self.dislikeView.center = CGPointMake(self.imageView.right - kVideoDislikeImageWidth/2 - kVideoDislikeMarginPadding, self.imageView.top + kVideoDislikeImageWidth/2 + kVideoDislikeMarginPadding);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGSize picSize = [TTAdDetailViewUtil imgSizeForViewWidth:width];
    CGFloat height = kVideoTopPadding + picSize.height + kVideoBottomPadding;
    return height;
}

#pragma mark - response

- (void)callActionFired:(id)sender {
    [self callActionWithADModel:self.adModel];
}

#pragma mark - getter

- (SSThemedButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor clearColor];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _actionButton.titleColorThemeKey = kColorText5;
        [_actionButton addTarget:self action:@selector(callActionFired:) forControlEvents:UIControlEventTouchUpInside];
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

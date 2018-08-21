//
//  ExploreDetailMixedGroupPicADView.m
//  Article
//
//  Created by 冯靖君 on 16/7/11.
//
//

#import "ExploreDetailMixedGroupPicADView.h"
#import "TTAdDetailViewHelper.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "TTImageInfosModel.h"
#import "TTLabelTextHelper.h"

@implementation ExploreDetailADGroupPicView

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        CGFloat picWidth = (width - (kGroupPicViewImagesCount - 1) * kPicSpace) / kGroupPicViewImagesCount;
        CGFloat picHeight = ceilf(picWidth * kPicAspect);
        _picSize = CGSizeMake(picWidth, picHeight);
        self.height = _picSize.height;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)refreshWithImageList:(NSArray<NSDictionary *> *)urlList
{
    CGFloat picLeft = 0;
    for (NSDictionary * infoDict in urlList) {
        if ([infoDict isKindOfClass:[NSDictionary class]]) {
            TTImageView *imageView = [[TTImageView alloc] initWithFrame:CGRectZero];
            imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
            imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
            imageView.borderColorThemeKey = kColorLine1;
            
            imageView.size = _picSize;
            imageView.left = picLeft;
            picLeft += imageView.width + kPicSpace;
            
            TTImageInfosModel *infoModel = [[TTImageInfosModel alloc] initWithDictionary:infoDict];
            [imageView setImageWithModel:infoModel placeholderImage:nil];
            [self addSubview:imageView];
        }
    }
}

+ (CGFloat)heightForWidth:(CGFloat)width
{
    CGFloat picWidth = (width - (kGroupPicViewImagesCount - 1) * kPicSpace) / kGroupPicViewImagesCount;
    CGFloat picHeight = ceilf(picWidth * kPicAspect);
    return picHeight;
}

@end

@interface ExploreDetailMixedGroupPicADView ()

@end

@implementation ExploreDetailMixedGroupPicADView

+ (void)load
{
    [TTAdDetailViewHelper registerViewClass:self withKey:@"mixed_groupPic" forArea:TTAdDetailViewAreaGloabl];
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
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
    CGFloat dislikePadding = self.adModel.showDislike? kMixDislikeImageWidth + kMixDislikeImageLeftPadding:0;
    self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:adModel.titleString fontSize:kDetailAdTitleFontSize lineHeight:kDetailAdTitleLineHeight];
    self.titleLabel.height = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:kDetailAdTitleFontSize forWidth:self.width - 2 * kHoriMargin - dislikePadding forLineHeight:kDetailAdTitleLineHeight constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    self.titleLabel.width = self.width - 2 * kHoriMargin - dislikePadding;
    
    [self.groupPicView refreshWithImageList:adModel.imageList];
    
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    
    [self layout];
    
}

- (void)layout
{
    self.titleLabel.origin = CGPointMake(kHoriMargin, kTopMargin);
    self.groupPicView.origin = CGPointMake(self.titleLabel.left, self.titleLabel.bottom + kPicTopSpace);
    
    self.dislikeView.center = CGPointMake(self.groupPicView.right - kMixDislikeImageWidth/2, kMixDislikeImageTopPadding + kMixDislikeImageWidth/2);
    self.dislikeView.hidden = !self.adModel.showDislike;
    self.adLabel.right = self.width - kADLabelMargin - kHoriMargin;
    self.adLabel.bottom = self.groupPicView.bottom - kADLabelMargin;
    
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat dislikePadding = adModel.showDislike? kMixDislikeImageWidth + kMixDislikeImageLeftPadding:0;
    CGFloat titleHeight = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:kDetailAdTitleFontSize forWidth:width - 2 * kHoriMargin - dislikePadding forLineHeight:kDetailAdTitleLineHeight constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    CGFloat height = titleHeight;
    height += kTopMargin + kPicTopSpace + kBottomMargin;
    height += [ExploreDetailADGroupPicView heightForWidth:width];
    return height;
}

+ (void)updateADLabel:(SSThemedLabel *)adLabel withADModel:(ArticleDetailADModel *)adModel
{
    [ExploreDetailBaseADView updateADLabel:adLabel withADModel:adModel];
    adLabel.backgroundColorThemeKey = kColorBackground15;
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
        _groupPicView = [[ExploreDetailADGroupPicView alloc] initWithWidth:self.width - kHoriMargin * 2];
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
        _sourceLabel.font = [UIFont systemFontOfSize:14];
        _sourceLabel.textColorThemeKey = kColorText3;
        _sourceLabel.numberOfLines = 1;
        _sourceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _sourceLabel;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_details";
}

@end

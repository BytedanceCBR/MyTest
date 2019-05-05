//
//  ExploreDetailMixedADView.m
//  Article
//
//  Created by SunJiangting on 15/7/22.
//
//

#import "ExploreDetailMixedADView.h"
#import "TTAdDetailViewHelper.h"

@implementation ExploreDetailMixedADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"mixed" forArea:TTAdDetailViewAreaGloabl];
}

- (instancetype)initWithWidth:(CGFloat)width {
  self = [super initWithWidth:width];
  if (self) {
    self.imageView = [[TTImageView alloc] initWithFrame:self.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.imageView];

    self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColorThemeKey = kColorText3;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.numberOfLines = 1;
    [self addSubview:self.titleLabel];

    self.adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    [self addSubview:self.adLabel];
  }
  return self;
}

- (void)setAdModel:(ArticleDetailADModel *)adModel {
  [super setAdModel:adModel];
  [self.imageView setImageWithURLString:adModel.imageURLString];

  const CGFloat imageHeight = [TTAdDetailViewUtil imageFitHeight:adModel width:self.width];
  self.imageView.frame = CGRectMake(0, 0, self.width, imageHeight);

  self.titleLabel.text = adModel.titleString;
  self.titleLabel.frame = CGRectMake(9, self.imageView.bottom, self.width - 18, self.height - self.imageView.bottom);

  [[self class] updateADLabel:self.adLabel withADModel:adModel];
  self.adLabel.origin = CGPointMake(self.imageView.right - self.adLabel.width - 6, self.imageView.bottom - self.adLabel.height - 6);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel
         constrainedToWidth:(CGFloat)width {
    CGFloat height = [TTAdDetailViewUtil imageFitHeight:adModel width:width];
    if (!isEmptyString(adModel.titleString)) {
        height += 28;
    }
    return height;
}

@end

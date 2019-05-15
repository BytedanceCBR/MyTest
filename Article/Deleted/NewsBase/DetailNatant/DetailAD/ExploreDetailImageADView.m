//
//  ExploreDetailImageADView.m
//  Article
//
//  Created by SunJiangting on 15/7/21.
//
//

#import "ExploreDetailImageADView.h"
#import "TTDeviceHelper.h"
#import "TTAdDetailViewHelper.h"

@implementation ExploreDetailImageADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"image" forArea:TTAdDetailViewAreaGloabl];
    [TTAdDetailViewHelper registerViewClass:self withKey:@"image" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        self.imageView = [[TTImageView alloc] initWithFrame:self.bounds];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.userInteractionEnabled = NO;
        if ([TTDeviceHelper isPadDevice]) {
            self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
        [self addSubview:self.imageView];
        
        self.adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.adLabel];
    }
    return self;
}

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    [super setAdModel:adModel];
    self.imageView.frame = self.bounds;
    [self.imageView setImageWithURLString:adModel.imageURLString];
    
   
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    self.adLabel.origin = CGPointMake(self.width - self.adLabel.width - 6, self.height - self.adLabel.height - 6);
    
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width {
    return [TTAdDetailViewUtil imageFitHeight:adModel width:width];
}

+ (void)updateADLabel:(SSThemedLabel *)adLabel withADModel:(ArticleDetailADModel *)adModel
{
    [ExploreDetailBaseADView updateADLabel:adLabel withADModel:adModel];
    adLabel.backgroundColorThemeKey = kColorBackground15;
}

@end

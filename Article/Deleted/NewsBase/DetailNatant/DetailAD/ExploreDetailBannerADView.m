//
//  ExploreDetailBannerADView.m
//  Article
//
//  Created by SunJiangting on 15/7/21.
//
//

#import "ExploreDetailBannerADView.h"
#import "TTDeviceHelper.h"
#import "TTAdDetailViewHelper.h"

@implementation ExploreDetailBannerADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"banner" forArea:TTAdDetailViewAreaGloabl];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        
        self.contentView = [[SSThemedView alloc] init];
        [self addSubview:self.contentView];
        
        self.imageView = [[TTImageView alloc] initWithFrame:self.bounds];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.cornerRadius = 2;
        self.imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceHelper isPadDevice]?15:16];
        self.titleLabel.textColors = SSThemedColors(@"454545", @"707070");
        [self.contentView addSubview:self.titleLabel];
        
        self.descLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        self.descLabel.font = [UIFont systemFontOfSize:12];
        self.descLabel.numberOfLines = 2;
        self.descLabel.textColorThemeKey = kColorText2;
        [self.contentView addSubview:self.descLabel];
        
        self.adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.adLabel];
        self.contentView.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    [super setAdModel:adModel];
    
    BOOL isIPad = ([TTDeviceHelper isPadDevice]);
    
    CGFloat contentHeight = (isIPad ?  66 : 80);
    CGRect frame;
    if (isIPad) {
        CGFloat width = 404;
        CGFloat originX = (self.width - width) / 2 ;
        frame = CGRectMake(originX, 15, width, contentHeight);
    } else {
        frame = CGRectMake(0, 0, self.width, contentHeight);
    }
    self.contentView.frame = frame;

    [self.imageView setImageWithURLString:adModel.imageURLString];
    self.imageView.frame = isIPad ? CGRectMake(10, 8, 50, 50) : CGRectMake(12, 15, 50, 50);
    
    self.titleLabel.text = adModel.titleString;
    CGFloat titleLeft = self.imageView.right + (isIPad?13:10);
    self.titleLabel.frame = CGRectMake(titleLeft, self.imageView.top, self.contentView.width - titleLeft - (isIPad?13:10), 18);
    
    self.descLabel.text = adModel.descString;
    self.descLabel.frame = CGRectMake(self.titleLabel.left, self.titleLabel.bottom + 4, self.titleLabel.width, self.imageView.bottom - self.titleLabel.bottom);
    
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    self.adLabel.origin = CGPointMake(self.contentView.width - self.adLabel.width - 6, self.contentView.height - self.adLabel.height - 6);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width {
    if ([TTDeviceHelper isPadDevice]) {
        /// 上下间距15
        return 66 + 30;
    }
    return 80;
}

+ (void)updateADLabel:(SSThemedLabel *)adLabel withADModel:(ArticleDetailADModel *)adModel
{
    [ExploreDetailBaseADView updateADLabel:adLabel withADModel:adModel];
    adLabel.backgroundColorThemeKey = kColorBackground15;
}

@end

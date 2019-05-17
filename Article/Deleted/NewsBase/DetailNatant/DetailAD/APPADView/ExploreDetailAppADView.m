//
//  ExploreDetailAppADView.m
//  Article
//
//  Created by SunJiangting on 15/7/21.
//
//

#import "ExploreDetailAppADView.h"
#import "ExploreCellHelper.h"
#import "TTThemeManager.h"
#import "TTDeviceHelper.h"
#import "TTUIResponderHelper.h"
#import "TTAdDetailViewHelper.h"

@implementation ExploreDetailAppADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"app" forArea:TTAdDetailViewAreaArticle];
    [TTAdDetailViewHelper registerViewClass:self withKey:@"app" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        self.imageView = [[TTImageView alloc] init];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.userInteractionEnabled = NO;
        [self addSubview:self.imageView];
        
        self.nameLabel = [[SSThemedLabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:15.];
        self.nameLabel.textColorThemeKey = kColorText3;
        self.nameLabel.numberOfLines = 1;
        [self addSubview:self.nameLabel];
        
        self.infoLabel = [[SSThemedLabel alloc] init];
        self.infoLabel.font = [UIFont systemFontOfSize:10.];
        self.infoLabel.textColorThemeKey = kColorText3;
        [self addSubview:self.infoLabel];
        
        self.downloadButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.downloadButton.backgroundColor = [UIColor clearColor];

        self.downloadButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        self.downloadButton.titleColors = @[[UIColor colorWithHexString:@"2a90d7"], [UIColor colorWithHexString:@"b7778b"]];
        self.downloadButton.layer.cornerRadius = 6.0f;
        self.downloadButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.downloadButton.borderColors = @[[UIColor colorWithHexString:@"2a90d7"], [UIColor colorWithHexString:@"b7778b"]];
        [self.downloadButton addTarget:self action:@selector(_downloadAppActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.downloadButton];
        
        self.adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        [self.imageView addSubview:self.adLabel];        
    }
    return self;
}

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    [super setAdModel:adModel];
    
    [self.imageView setImageWithURLString:adModel.imageURLString];
    self.nameLabel.text = adModel.appName;
    NSString *appInfo = nil;
    
    if (!isEmptyString(adModel.appSize)) {
        appInfo = adModel.appSize;
    }
    if (!isEmptyString(adModel.downloadCount)) {
        appInfo = [appInfo stringByAppendingFormat:@"  %@", adModel.downloadCount];
    }
    self.infoLabel.text = appInfo;
    self.infoLabel.hidden = isEmptyString(appInfo);
    [self.downloadButton setTitle:adModel.actionButtonText forState:UIControlStateNormal];
    
    CGFloat aspect = adModel.imageHeight == 0?:(adModel.imageWidth / adModel.imageHeight);
    CGFloat imageWidth = self.width * 0.6;   //应用图片宽度占屏幕宽度60%
    self.imageView.frame = CGRectMake(0, 0, imageWidth, (aspect == 0)?:(imageWidth / aspect));

    
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    self.adLabel.origin = CGPointMake(self.imageView.right - self.adLabel.width - 6, self.imageView.bottom - self.adLabel.height - 6);
    
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(self.imageView.right + 10, 16, self.nameLabel.width, self.nameLabel.height);
    if (self.nameLabel.right > self.width) {
        self.nameLabel.width = self.width - self.nameLabel.left - 2;
    }
    [self.infoLabel sizeToFit];
    self.infoLabel.frame = CGRectMake(self.nameLabel.left, self.nameLabel.bottom + 4, self.infoLabel.width, self.infoLabel.height);
    self.downloadButton.frame = CGRectMake(self.nameLabel.left, self.bottom - 28 - 16, 72, 28);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width {
    if (adModel.imageHeight == 0) {
        return 0;
    }
    
    CGFloat imageHeight = [TTUIResponderHelper splitViewFrameForView:[TTUIResponderHelper topmostView]].size.width * 0.6 / (adModel.imageWidth / adModel.imageHeight);
    //右侧展示app信息需要的最低高度
    CGFloat needMinHeight = 15.f;
    if (!isEmptyString(adModel.appSize) || !isEmptyString(adModel.downloadCount)) {
        needMinHeight += 10.f;
    }
    needMinHeight += 16*2 + 4;
    return MAX(imageHeight, needMinHeight);
}

- (void)_downloadAppActionFired:(id)sender {
    [self sendActionForTapEvent];
    [self.adModel trackWithTag:@"detail_download_ad" label:@"click_start" extra:nil];
}

@end

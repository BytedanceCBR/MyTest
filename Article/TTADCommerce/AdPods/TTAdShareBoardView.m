//
//  TTAdShareBoardView.m
//  Article
//
//  Created by yin on 2016/11/14.
//
//

#import "TTAdShareBoardView.h"
#import "TTAdConstant.h"
#import "TTImageInfosModel.h"
#import "TTImageView.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "SSSimpleCache.h"
#import "TTAdShareManager.h"

#define kShareAdLabelLeftPadding 10*kTTAdShareScreenRate
#define kShareAdLabelRightPadding 10*kTTAdShareScreenRate
#define kShareAdLabelTopPadding  5*kTTAdShareScreenRate
#define kShareAdLabelBottomPadding  5*kTTAdShareScreenRate

#define kShareDeleteImageRightPadding 5*kTTAdShareScreenRate
#define kShareDeleteImageLeftPadding 5*kTTAdShareScreenRate

#define kShareLogoSize CGSizeMake(277*kTTAdShareScreenRate, 67*kTTAdShareScreenRate)
#define kShareButtonSize CGSizeMake(40*kTTAdShareScreenRate, 40*kTTAdShareScreenRate)
#define kShareImageSize CGSizeMake(24*kTTAdShareScreenRate, 24*kTTAdShareScreenRate)


@interface TTAdShareBoardView ()

@property (nonatomic, strong) TTAdShareBoardDataModel* model;
@property (nonatomic, strong) TTImageView* logoView;
@property (nonatomic, strong) SSThemedLabel* adLabel;
@property (nonatomic, strong) SSThemedButton* deleteButton;
@property (nonatomic, strong) SSThemedImageView* deleteImage;
@property (nonatomic, strong) SSThemedLabel* bottomLine;

@end

@implementation TTAdShareBoardView

- (void)dealloc
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame model:nil];
}

- (instancetype)initWithFrame:(CGRect)frame model:(TTAdShareBoardDataModel *)model
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColors = SSThemedColors(@"f0f0f0", @"252525");
        self.model = model;
        [self setSubViews];
        [self refreshData];
    }
    return self;
}

- (void)setSubViews
{
    self.deleteButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, kShareButtonSize.width, kShareButtonSize.height)];
    [self.deleteButton addTarget:self action:@selector(deleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    
    
    self.deleteImage = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, kShareImageSize.width, kShareImageSize.height)];
    [self addSubview:self.deleteImage];
    [self.deleteImage setImageName:@"popup_newclose"];
    
    self.adLabel = [[SSThemedLabel alloc] init];
    self.adLabel.font = [UIFont systemFontOfSize:10];
    self.adLabel.textColorThemeKey = kColorText9;
    [self addSubview:self.adLabel];
    self.adLabel.hidden = YES;
    
    self.logoView = [[TTImageView alloc] init];
    self.logoView.enableNightCover = NO;
    self.logoView.userInteractionEnabled = NO;
    [self addSubview:self.logoView];
    
    
    self.bottomLine = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel])];
    self.bottomLine.backgroundColorThemeKey = kColorLine10;
    [self addSubview:self.bottomLine];
}


- (void)refreshData
{
    if (self.model.ad_item&&self.model.ad_item.count>0){
        TTAdShareBoardItemModel* itemModel = self.model.ad_item.firstObject;
        if (itemModel.image_list.count>0) {
            TTImageInfosModel* imageModel = [[TTImageInfosModel alloc] initWithDictionary:[itemModel.image_list.firstObject toDictionary]];
            if ([[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageModel]) {
                self.logoView.imageView.image = [UIImage imageWithData:[[SSSimpleCache sharedCache] dataForImageInfosModel:imageModel]];
                
            }
            NSString* label = itemModel.label;
            if (itemModel.label.length >= 2) {
                label = [itemModel.label substringToIndex:2];
            }
            self.adLabel.text = label;
            [self.adLabel sizeToFit];
            
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        
    }
    
    self.bottomLine.left = 0;
    self.bottomLine.width = self.width;
    
    if (self.model.ad_item&&self.model.ad_item.count>0){
        TTAdShareBoardItemModel* itemModel = self.model.ad_item.firstObject;
        if (self.model.close_button_switch.integerValue == 1) {
            if (itemModel.label_style.integerValue > 0) {
                self.adLabel.hidden = NO;
                self.adLabel.right = self.right - kShareAdLabelRightPadding;
                self.adLabel.bottom = self.bottomLine.top - kShareAdLabelBottomPadding;
                
                self.deleteImage.hidden = NO;
                self.deleteImage.right = self.width - kShareDeleteImageRightPadding;
                self.deleteImage.bottom = self.adLabel.top - kShareAdLabelTopPadding;
                
                self.deleteButton.hidden = NO;
                self.deleteButton.center = self.deleteImage.center;
                
                self.logoView.size = CGSizeMake(kShareLogoSize.width, kShareLogoSize.height);
                self.logoView.bottom = self.bottomLine.top;
                self.logoView.centerX = self.width/2;
            }
            else
            {
                self.adLabel.hidden = YES;
                
                self.deleteImage.hidden = NO;
                self.deleteImage.right = self.width - kShareDeleteImageRightPadding;
                self.deleteImage.centerY = self.height/2;
                
                self.deleteButton.hidden = NO;
                self.deleteButton.center = self.deleteImage.center;
                
                self.logoView.size = CGSizeMake(kShareLogoSize.width, kShareLogoSize.height);
                self.logoView.bottom = self.bottomLine.top;
                self.logoView.centerX = self.width/2;
            }
        }
        else
        {
            if (itemModel.label_style.integerValue > 0) {
                self.adLabel.hidden = NO;
                self.adLabel.right = self.right - kShareAdLabelRightPadding;
                self.adLabel.bottom = self.bottomLine.top - kShareAdLabelBottomPadding;
                
                self.deleteImage.hidden = YES;
                self.deleteButton.hidden = YES;
                
                self.logoView.size = CGSizeMake(kShareLogoSize.width, kShareLogoSize.height);
                self.logoView.bottom = self.bottomLine.top;
                self.logoView.centerX = self.width/2;
            }
            else
            {
                self.adLabel.hidden = YES;
                self.deleteImage.hidden = YES;
                self.deleteButton.hidden = YES;
                self.logoView.size = CGSizeMake(kShareLogoSize.width, kShareLogoSize.height);
                self.logoView.bottom = self.bottomLine.top;
                self.logoView.centerX = self.width/2;
            }
        }
    }
    
}

- (void)deleteButton:(UIButton*)button
{
    [self removeFromSuperview];
    [TTAdShareManager closeShareAd:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

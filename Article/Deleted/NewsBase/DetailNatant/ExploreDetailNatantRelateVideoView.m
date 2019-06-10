//
//  ExploreDetailNatantRelateVideoView.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-9.
//
//  导流视频等单张大图样式

#import "ExploreDetailNatantRelateVideoView.h"
#import "SSImageView.h"
#import "SSAppPageManager.h"
#import "TTStringHelper.h"

#define kLeftPadding 15
#define kRightPadding 15
#define kImgTopPadding 0
#define kImgBottomPadding 15
#define kBottomMarginHeight 15
#define kImgTopCoverViewHeight 40


@interface ExploreDetailNatantRelateVideoView()
@property(nonatomic, retain)NSDictionary * infoDict;
@property(nonatomic, retain)SSImageInfosModel * imgModel;
@property(nonatomic, retain)SSImageView * imgView;
@property(nonatomic, retain)UIButton * actionButton;
@property(nonatomic, retain)UILabel * titleLabel;
@property(nonatomic, retain)CAGradientLayer * imgTopCoverLayer;
@end

@implementation ExploreDetailNatantRelateVideoView

- (void)dealloc
{
    self.imgTopCoverLayer = nil;
}


- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {

    }
    return self;
}

- (void)actionButtonClicked
{
    NSLocalizedString(@"detail", @"click_large_video");
    NSString * outerSchema = [_infoDict objectForKey:@"outer_schema"];
    if ([[UIApplication sharedApplication] canOpenURL:[TTStringHelper URLWithURLString:outerSchema]]) {
        [[UIApplication sharedApplication] openURL:[TTStringHelper URLWithURLString:outerSchema]];
        ssTrackEvent(@"detail", @"enter_youku");
        return;
    }
    NSString * openURL = [_infoDict objectForKey:@"open_page_url"];
    if ([[SSAppPageManager sharedManager] canOpenURL:[TTStringHelper URLWithURLString:openURL]]) {
        [[SSAppPageManager sharedManager] openURL:[TTStringHelper URLWithURLString:openURL]];
        
        return;
    }
    
    NSString * groupID = [_infoDict objectForKey:@"group_id"];
    NSString *itemID = [_infoDict objectForKey:@"item_id"];
    NSObject *aggrType = [_infoDict objectForKey:@"aggr_type"];
    if ([groupID longLongValue] > 0) {
        NSMutableString *URLString = [NSMutableString stringWithFormat:@"sslocal://detail?groupid=%@", groupID];
        if (itemID) {
            [URLString appendFormat:@"&itemid=%@", itemID];
            if (aggrType) {
                [URLString appendFormat:@"&aggrtype=%@", aggrType];
            }
        }
        [[SSAppPageManager sharedManager] openURL:[TTStringHelper URLWithURLString:URLString]];
    }
}

- (void)refreshWithImgModel:(SSImageInfosModel *)model relateVideoDict:(NSDictionary *)dict
{
    self.infoDict = dict;
    self.imgModel = model;
    
    self.height = [ExploreDetailNatantRelateVideoView heightForSSImageInfosModel:model viewWidth:self.width];
    
    if (!_imgView) {
        self.imgView = [[SSImageView alloc] initWithFrame:[self frameForImgView]];
        [self addSubview:_imgView];
    }
    else {
        _imgView.frame = [self frameForImgView];
    }
    [_imgView setImageWithModel:_imgModel];
    
    if (!_actionButton) {
        self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor clearColor];
        _actionButton.frame = _imgView.bounds;
        _actionButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_actionButton addTarget:self action:@selector(actionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_imgView addSubview:_actionButton];
    }
    [self refreshActionButtonImg];
    
    if (!_imgTopCoverLayer) {
        CGColorRef darkColor = [UIColor colorWithHexString:@"00000033"].CGColor;
        CGColorRef lightColor = [UIColor clearColor].CGColor;
        self.imgTopCoverLayer = [[CAGradientLayer alloc] init];
        _imgTopCoverLayer.frame = CGRectMake(0, 0, self.width, kImgTopCoverViewHeight);
        _imgTopCoverLayer.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
        [_imgView.layer addSublayer:_imgTopCoverLayer];
    }
    
    if (!_titleLabel) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, _imgView.width - 20, 15)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 1;
        [_imgView addSubview:_titleLabel];
    }
    [_titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_titleLabel setText:[dict objectForKey:@"title"]];
    
    [self reloadThemeUI];
    
}

- (void)refreshActionButtonImg
{
//    if ([[_infoDict objectForKey:@"show_video_icon"] boolValue]) {
//        [_actionButton setImage:[UIImage themedImageNamed:@"playbutton_related_videos_details"] forState:UIControlStateNormal];
//        [_actionButton setImage:[UIImage themedImageNamed:@"playbutton_related_videos_details_press.png"] forState:UIControlStateHighlighted];
//    }
//    else {
//        [_actionButton setImage:nil forState:UIControlStateNormal];
//        [_actionButton setImage:nil forState:UIControlStateHighlighted];
//    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    _imgView.backgroundColor = [UIColor colorWithDayColorName:@"ebebeb" nightColorName:@"303030"];
    [self refreshActionButtonImg];
    _titleLabel.textColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"fafafa"];
}

- (void)refreshWithWidth:(CGFloat)width
{
    [super refreshWithWidth:width];
    [self refreshUI];
}

- (void)refreshUI
{
    _imgView.frame = [self frameForImgView];
}


- (CGRect)frameForImgView
{
    CGFloat imgHeight = [ExploreDetailNatantRelateVideoView imgHeightForSSImageInfosModel:_imgModel viewWidth:self.width];
    return CGRectMake(kLeftPadding, kImgTopPadding, self.width - kLeftPadding - kRightPadding, imgHeight);
}

+ (float)imgHeightForSSImageInfosModel:(SSImageInfosModel *)model viewWidth:(float)viewWidth
{
    CGFloat height = 0;
    if (model.width == 0) {
        return 0;
    }
    CGFloat imgShowWidth = viewWidth - kLeftPadding - kRightPadding;
    height = (model.height * imgShowWidth) / model.width;
    return height;
}

+ (float)heightForSSImageInfosModel:(SSImageInfosModel *)model viewWidth:(float)viewWidth
{
    
    CGFloat height = 0;
    CGFloat imgHeight = [self imgHeightForSSImageInfosModel:model viewWidth:viewWidth];
    if (imgHeight == 0) {
        return 0;
    }
    height += imgHeight;
    height += kImgTopPadding;
    height += kImgBottomPadding;
    return height;
}

@end

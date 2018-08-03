//
//  TTHTSTabHeaderView.m
//  Article
//
//  Created by 王双华 on 2017/4/13.
//
//

#import "TTHTSTabHeaderView.h"
#import "TTAsyncCornerImageView.h"
#import <TTImage/TTImageView.h>
#import "TTModuleBridge.h"
#import "AWEVideoConstants.h"

static const CGFloat kImageLeftPadding = 15;
static const CGFloat kImageSide = 40;

static const CGFloat kTitleLeftPadding = 10;
static const CGFloat kArrowImageSide = 24;
static const CGFloat kArrowImageRightPadding = 12;
static const CGFloat kArrowImageLeftGap = 30;//箭头左边留白宽度

static const CGFloat kTitleTopPadding = 13;
static const CGFloat kSubTitleBottomPadding = 13;

static const CGFloat kTitleLineHeight = 17;
static const CGFloat kSubTitleLineHeight = 12;

static const CGFloat kTitleFontSize = 14;
static const CGFloat kSubTitleFontSize = 12;

@interface TTHTSTabHeaderView()

@property (nonatomic, strong) SSThemedView *contentView;
@property (nonatomic, strong) TTImageView *leftImage;
@property (nonatomic, strong) SSThemedLabel *title;
@property (nonatomic, strong) SSThemedLabel *subTitle;
@property (nonatomic, strong) SSThemedImageView *arrowImage;
@property (nonatomic, strong) SSThemedView *bottomLine;

@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@end

@implementation TTHTSTabHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.minimumHeaderHeight = 0;
        
        _contentView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.height - kTTHTSHeaderViewHeight, self.width, kTTHTSHeaderViewHeight)];
        _contentView.backgroundColorThemeKey = kColorBackground4;
        [self addSubview:_contentView];
        
        _leftImage = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, kImageSide, kImageSide)];
        _leftImage.left = kImageLeftPadding;
        _leftImage.centerY = _contentView.height / 2;
        _leftImage.layer.cornerRadius = kImageSide / 2;
        _leftImage.clipsToBounds = YES;
        _leftImage.enableNightCover = YES;
        [self.contentView addSubview:_leftImage];
        
        CGFloat titleLeft = kImageLeftPadding + kImageSide + kTitleLeftPadding;
        CGFloat maxLabelWidth = self.width - titleLeft - kArrowImageRightPadding - kArrowImageSide - kArrowImageLeftGap;
        _title = [[SSThemedLabel alloc] initWithFrame:CGRectMake(titleLeft, kTitleTopPadding, maxLabelWidth, kTitleLineHeight)];
        _title.font = [UIFont boldSystemFontOfSize:kTitleFontSize];
        _title.textColorThemeKey = kColorText1;
        _title.backgroundColorThemeKey = kColorBackground4;
        [self.contentView addSubview:_title];
        
        _subTitle = [[SSThemedLabel alloc] initWithFrame:CGRectMake(titleLeft, 0, maxLabelWidth, kSubTitleLineHeight)];
        _subTitle.bottom = _contentView.height - kSubTitleBottomPadding;
        _subTitle.font = [UIFont systemFontOfSize:kSubTitleFontSize];
        _subTitle.textColorThemeKey = kColorText3;
        _subTitle.backgroundColorThemeKey = kColorBackground4;
        [self.contentView addSubview:_subTitle];
        
        _arrowImage = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, kArrowImageSide, kArrowImageSide)];
        _arrowImage.imageName = @"righterbackicon_titlebar";
        _arrowImage.right = self.width - kArrowImageRightPadding;
        _arrowImage.centerY = _contentView.height / 2;
        [self.contentView addSubview:_arrowImage];
        
        _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, _contentView.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel])];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
        [self.contentView addSubview:_bottomLine];
        
        self.backgroundColorThemeKey = kColorBackground4;
        
        [self refreshUI];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        _tapRecognizer = tapRecognizer;
        [self.contentView addGestureRecognizer:_tapRecognizer];
    }
    return self;
}

- (void)refreshUI
{
    NSString *title = nil;
    NSString *subTitle = nil;
    NSString *iconURL = nil;
    NSString *placeholderImageName = nil;
    NSDictionary *infoDict = [SSCommonLogic htsTabBannerInfoDict];
    
    _scheme = [infoDict tt_stringValueForKey:@"installed_schema"];
    if (isEmptyString(_scheme)) {
        _scheme = @"snssdk1112://main?gd_label=click_schema_huoshan2toutiao_banner&source_from=toutiao";
    }
    
    if ([SSCommonLogic isHTSAppInstalled]) {
        if ([infoDict objectForKey:@"installed_title"]) {
            title = [infoDict tt_stringValueForKey:@"installed_title"];
        }
        if (isEmptyString(title)) {
            title = @"已安装火山小视频";
        }
        if ([infoDict objectForKey:@"installed_subtitle"]) {
            subTitle = [infoDict tt_stringValueForKey:@"installed_subtitle"];
        }
        if (isEmptyString(subTitle)) {
            subTitle = @"点击打开火山小视频";
        }
        if ([infoDict objectForKey:@"installed_icon_url"]) {
            iconURL = [infoDict tt_stringValueForKey:@"installed_icon_url"];
        }
        placeholderImageName = @"hs_logo";
    }
    else{
        if ([infoDict objectForKey:@"uninstalled_title"]) {
            title = [infoDict tt_stringValueForKey:@"uninstalled_title"];
        }
        if (isEmptyString(title)) {
            title = @"未安装火山小视频";
        }
        if ([infoDict objectForKey:@"uninstalled_subtitle"]) {
            subTitle = [infoDict tt_stringValueForKey:@"uninstalled_subtitle"];
        }
        if (isEmptyString(subTitle)) {
            subTitle = @"点击下载火山小视频";
        }
        if ([infoDict objectForKey:@"uninstalled_icon_url"]) {
            iconURL = [infoDict tt_stringValueForKey:@"uninstalled_icon_url"];
        }
        placeholderImageName = @"hs_luckyred";
    }
    
    if (!isEmptyString(title)) {
        _title.text = title;
    }
    if (!isEmptyString(subTitle)) {
        _subTitle.text = subTitle;
    }
    [_leftImage setImageWithURLString:iconURL placeholderImage:[UIImage imageNamed:placeholderImageName]];

}

- (void)tap:(id)sender
{
    [TTTrackerWrapper eventV3:@"huoshan_download_banner_click" params:nil];
    if ([SSCommonLogic isHTSAppInstalled] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:_scheme]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_scheme]];
    } else {
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:@"https://d.toutiao.com/Yw8t/" forKey:@"download_track_url"];
        [params setValue:[SSCommonLogic htsAPPAppleID] forKey:@"app_appleid"];
        [[TTModuleBridge sharedInstance_tt] triggerAction:@"TSVDownloadAPP" object:nil withParams:params complete:nil];
    }
}

@end

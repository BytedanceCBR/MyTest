//
//  TTVVideoDetailTextlinkADView.m
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import "TTVVideoDetailTextlinkADView.h"
#import "ArticleInfoManager.h"
#import "TTRoute.h"
#import "TTURLUtils.h"

static const CGFloat ExploreDetailTextlinkADMargin = 10;
static const CGFloat ExploreDetailTextlinkADInteritemSpacing = 9;

@interface TTVVideoDetailTextlinkADView ()

@property(nonatomic, strong) SSThemedLabel *titleLabel;
@property(nonatomic, strong) SSThemedLabel *descLabel;

@property(nonatomic, strong) UIButton *bgButton;

@end

@implementation TTVVideoDetailTextlinkADView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[SSThemedLabel alloc] init];
        self.titleLabel.textColors = SSThemedColors(@"fafafa", @"252525");
        self.titleLabel.backgroundColors = SSThemedColors(@"4073ba", @"57607f");
        self.titleLabel.font = [UIFont systemFontOfSize:12.];
        [self addSubview:self.titleLabel];
        
        self.descLabel = [[SSThemedLabel alloc] init];
        self.descLabel.textColors = SSThemedColors(@"4073ba", @"57607f");
        self.descLabel.backgroundColor = [UIColor clearColor];
        self.descLabel.font = [UIFont systemFontOfSize:13.];
        [self addSubview:self.descLabel];
        
        _bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgButton.frame = self.frame;
        _bgButton.backgroundColor = [UIColor clearColor];
        _bgButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_bgButton addTarget:self action:@selector(bgButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bgButton];
        
        self.clipsToBounds = YES;
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.borderColorThemeKey = kColorLine1;
        [self reloadThemeUI];
    }
    return self;
}

- (void)setViewModel:(id<TTVVideoDetailTextlinkADViewDataProtocol>)viewModel
{
    _viewModel = viewModel;
    
    self.titleLabel.text = viewModel.adminDebug.label;
    [self.titleLabel sizeToFit];
    self.descLabel.text = viewModel.adminDebug.title;
    
    [self refreshUI];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.borderColorThemeKey = kColorLine1;
}

- (void)bgButtonPressed {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.viewModel.adminDebug.webURL forKey:@"url"];
    [params setValue:self.viewModel.adminDebug.webTitle forKey:@"title"];
    NSURL *schema = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:params];
    if ([[TTRoute sharedRoute] canOpenURL:schema]) {
        [[TTRoute sharedRoute] openURLByPushViewController:schema];
    }
}

- (void)refreshUI {
    CGFloat height = 44;
    if (isEmptyString(self.titleLabel.text) && isEmptyString(self.descLabel.text)) {
        height = 0;
    }
    self.height = height;
    
    if (isEmptyString(self.titleLabel.text)) {
        self.titleLabel.frame = CGRectZero;
    } else {
        CGFloat width = MIN(60, MAX(30, self.titleLabel.width));
        self.titleLabel.frame = CGRectMake(ExploreDetailTextlinkADMargin, 15, width, self.height - 30);
    }
    CGFloat left = self.titleLabel.right == 0 ? ExploreDetailTextlinkADMargin : self.titleLabel.right + ExploreDetailTextlinkADInteritemSpacing;
    self.descLabel.frame = CGRectMake(left, 15, self.width - left - ExploreDetailTextlinkADMargin, self.height - 30);
}

@end

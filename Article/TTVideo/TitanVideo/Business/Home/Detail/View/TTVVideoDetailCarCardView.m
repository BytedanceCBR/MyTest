//
//  TTVVideoDetailCarCardView.m
//  Article
//
//  Created by pei yun on 2017/8/25.
//
//

#import "TTVVideoDetailCarCardView.h"
#import "TTImageView.h"
#import <Masonry/Masonry.h>
#import "TTRoute.h"
#import "TTURLUtils.h"
#import <ReactiveObjC/ReactiveObjC.h>

extern NSArray *tt_ttuisettingHelper_detailViewCommentReplyBackgroundeColors(void);
extern NSArray *tt_ttuisettingHelper_cellViewTitleColors(void);

@interface TTVVideoDetailCarCardView ()

@property (nonatomic, strong) SSThemedButton *backButton;
@property (nonatomic, strong) TTImageView *picImageView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *priceLabel;
@property (nonatomic, strong) SSThemedView *maskView;
@property (nonatomic, strong) TTImageView *arrowImageView;

@end

@implementation TTVVideoDetailCarCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backButton = [[SSThemedButton alloc] initWithFrame:self.bounds];
        _backButton.backgroundColors = tt_ttuisettingHelper_detailViewCommentReplyBackgroundeColors();
        [_backButton addTarget:self action:@selector(openWebWithURL:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        _picImageView = [[TTImageView alloc] init];
        _picImageView.imageContentMode = TTImageViewContentModeScaleAspectFit;
        _picImageView.enableNightCover = NO;
        _picImageView.userInteractionEnabled = NO;
        [_backButton addSubview:_picImageView];
        
        self.maskView = [[SSThemedView alloc] init];
        self.maskView.backgroundColors = @[[UIColor clearColor], [UIColor colorWithWhite:0 alpha:0.5]];
        self.maskView.userInteractionEnabled = NO;
        [_picImageView addSubview:self.maskView];
        
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.picImageView);
        }];
        
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont boldSystemFontOfSize:14.f];
        _nameLabel.textColors = tt_ttuisettingHelper_cellViewTitleColors();
        [_backButton addSubview:_nameLabel];
        
        _priceLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont boldSystemFontOfSize:14.f];
        _priceLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"0x222222de" nightColorName:@"0x707070de"]];
        [_backButton addSubview:_priceLabel];
        
        _arrowImageView = [[TTImageView alloc] init];
        _arrowImageView.enableNightCover = NO;
        _arrowImageView.userInteractionEnabled = NO;
        @weakify(self);
        [[[RACSignal return:nil] concat:[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTThemeManagerThemeModeChangedNotification object:nil]] subscribeNext:^(id x) {
            @strongify(self);
            self.priceLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"0x222222de" nightColorName:@"0x707070de"]];
            [self.arrowImageView setImage:[UIImage themedImageNamed:@"arrow_carCard"]];
        }];
        [_backButton addSubview:_arrowImageView];
        
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.top.bottom.equalTo(@0);
            make.right.equalTo(@-15);
        }];
        [_picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@6);
            make.centerY.equalTo(@0);
            make.size.mas_equalTo(CGSizeMake(48, 32));
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_picImageView.mas_right).offset(8);
            make.centerY.equalTo(@0);
        }];
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameLabel.mas_right).offset(14);
            make.centerY.equalTo(@0);
            make.right.lessThanOrEqualTo(_arrowImageView.mas_left).offset(-32);
        }];
        [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-8);
            make.centerY.equalTo(@0);
            make.width.height.equalTo(@12);
        }];
        [_nameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_priceLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

- (void)setCard:(TTVDetailCarCard *)card
{
    _card = card;
    
    [_picImageView setImageWithURLString:card.cover_url];
    _nameLabel.text = card.series_name;
    _priceLabel.text = card.price;
}

- (void)openWebWithURL:(id)sender
{
    if (isEmptyString(_card.open_url)) {
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"page_detail_video_pic" forKey:@"source"];
    [params setValue:self.artileGroupID forKey:@"group_id"];
    [TTTrackerWrapper eventV3:@"clk_autocard" params:params];
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithCapacity:3];
    NSURL *openURL = [TTURLUtils URLWithString:_card.open_url];
    BOOL canOpen = [[TTRoute sharedRoute] canOpenURL:openURL];
    if (canOpen) {
        [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:TTRouteUserInfoWithDict(extraDic)];
    }
    //点击广告图片跳转到广告详情页
    if (!canOpen) {
        [extraDic setValue:_card.open_url forKey:@"url"];
        NSURL *url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:extraDic];
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    }
}

@end

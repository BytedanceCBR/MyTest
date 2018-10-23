//
//  TTVVideoDetailInfoView.m
//  viewModel.infoModel
//
//  Created by lishuangyang on 2017/5/17.
//
//

#import "TTUIResponderHelper.h"
#import "TTRoute.h"
#import "TTVVideoDetailNatantInfoView.h"
#import "TTLabelTextHelper.h"
#import "TTIndicatorView.h"
#import "TTVVideoDetailNatantInfoViewController.h"
#import "ExploreSearchViewController.h"
#import "SSTTTAttributedLabel.h"
#import "ArticleVideoActionButton.h"
#import "TTVideoRecommendView.h"
#import "TTVideoShareThemedButton.h"
#import "TTUserSettingsManager+FontSettings.h"
#import "TTVideoFontSizeManager.h"
#import "TTActivityShareSequenceManager.h"
//#import "TTWeitoutiaoRepostIconDownloadManager.h"
#import "TTMessageCenter.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTKitchenHeader.h"
#import "TTVVideoDetailNatantInfoShareView.h"

#define kVerticalEdgeMargin             (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kTitleLabelLineHeight           [[self class] setTitleLineHeight]
#define kDetailButtonLeftSpace          5.f
#define kDetailButtonRightPadding       (([TTDeviceHelper isPadDevice]) ? 20 : 3)
#define kTitleLabelBottomSpace          (([TTDeviceHelper isPadDevice]) ? 22 : 4)
#define kContentLabelBottomSpace        (([TTDeviceHelper isPadDevice]) ? 30 : 15)
#define kWatchCountLabelBottomSpace     -2.f
#define kWatchCountContentLabelSpace    (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kTitleLabelMaxLines             1
#define kContentLabelMaxLines           0
#define kDigBurrySpaceScreenWidthAspect 0.2f
#define kVideoDirectShareButtonWidth     36


@implementation TTVideoAttributedLabel

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}
@end


extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;
extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;

extern NSString * const TTVVideodetailNatantInfoShareViewDigg;
extern NSString * const TTVVideodetailNatantInfoShareViewExtendLink;
extern NSString * const TTVVideodetailNatantInfoShareViewShareAction;

extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern NSInteger ttvs_isVideoShowDirectShare(void);
extern BOOL ttvs_isShareIndividuatioEnable(void);
extern BOOL ttvs_isVideoDetailCenterStrongShare(void);

extern float tt_ssusersettingsManager_detailVideoTitleFontSize();
extern float tt_ssusersettingsManager_detailVideoContentFontSize();

@interface TTVVideoDetailNatantInfoView ()<TTTAttributedLabelDelegate, TTActivityShareSequenceChangedMessage, TTUGCAttributedLabelDelegate>

@property(nonatomic, assign) BOOL isUnfold;
@property(nonatomic, strong) SSViewBase *bottomLine;
@property (nonatomic, strong) TTVideoAttributedLabel  *titleRichLabel; //富文本标题
@property(nonatomic, strong) SSTTTAttributedLabel *contentLabel;
@property(nonatomic, strong) SSThemedButton *detailButton;
@property(nonatomic, strong) SSThemedButton *titleDetailButton;
@property(nonatomic, strong) UILabel *watchCountLabel;
@property(nonatomic, strong) TTVideoRecommendView *recommendView;
@property(nonatomic, strong) ArticleVideoActionButton *digButton;
@property(nonatomic, strong) ArticleVideoActionButton *buryButton;
@property(nonatomic, strong) ArticleVideoActionButton *videoExtendLinkButton;
@property(nonatomic, strong) ArticleVideoActionButton *shareButton;
@property(nonatomic, strong) SSThemedLabel *directShareLabel;
@property(nonatomic, strong) TTVideoShareThemedButton *weixin;
@property(nonatomic, strong) TTVideoShareThemedButton *weixinMoment;
@property(nonatomic, strong) TTVVideoDetailNatantInfoShareView *shareView;

@end

@implementation TTVVideoDetailNatantInfoView


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    UNREGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
}

- (instancetype)initWithWidth:(CGFloat)width  andinfoModel:(TTVVideoDetailNatantInfoModel *)infoModel
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        REGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontChanged:)
                                                     name:kSettingFontSizeChangedNotification object:nil];
        self.isUnfold = YES;
        [self reloadThemeUI];
        self.viewModel = [[TTVVideoDetailNatantInfoViewModel alloc] initWithInfoModel:infoModel];
    }
    return self;
}

- (void)fontChanged:(NSNotification *)notification {
    [self.viewModel updateAttributeTitle];
    [self updateVideoTextArea];
    [self refreshUI];
}

- (void)setViewModel:(TTVVideoDetailNatantInfoViewModel *)viewModel
{
    _viewModel = viewModel;
    [self buildBaseView];
    [self reloadData];
    [self reloadThemeUI];
}

#pragma mark - buildView
- (void)buildBaseView
{
    if (!_titleRichLabel){
        _titleRichLabel = [[TTVideoAttributedLabel alloc] initWithFrame:CGRectZero];
        _titleRichLabel.delegate = self;
        _titleRichLabel.extendsLinkTouchArea = NO;
        _titleRichLabel.longPressGestureRecognizer.enabled = NO;
        [self addSubview:_titleRichLabel];
    }
    
    if (!_contentLabel) {
        _contentLabel = [[SSTTTAttributedLabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.hidden = YES;
        _contentLabel.delegate = self;
        _contentLabel.extendsLinkTouchArea = NO;
        [self addSubview:_contentLabel];
    }
    
    if (!_titleDetailButton) {
        _titleDetailButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _titleDetailButton.hitTestEdgeInsets = UIEdgeInsetsMake(-kVerticalEdgeMargin, -41, -21, -15);
        [self insertSubview:_titleDetailButton belowSubview:_titleRichLabel];
    }
    
    if (!_detailButton) {
        _detailButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_detailButton sizeToFit];
//        [self addSubview:_detailButton];
    }
    
    if (!_watchCountLabel) {
        _watchCountLabel = [[UILabel alloc] init];
        _watchCountLabel.textAlignment = NSTextAlignmentLeft;
        _watchCountLabel.backgroundColor = [UIColor clearColor];
        _watchCountLabel.font = [UIFont systemFontOfSize:[[self class] watchCountLabelFontSize]];
        _watchCountLabel.numberOfLines = 1;
        [self addSubview:_watchCountLabel];
    }
    
    if (!_recommendView && _viewModel.infoModel.zzComments) {
        _recommendView = [[TTVideoRecommendView alloc] init];
        [self addSubview:_recommendView];
    }
     
}

-(void)buildOptionView
{
    if (ttvs_isVideoDetailCenterStrongShare()){
        self.showShareView = YES;
    }
    
    if (!self.showShareView)
    {
        
        // add by zjing 隐藏了解更多
//        if ([_viewModel showExtendLink]) {
//            if (!_videoExtendLinkButton) {
//                _videoExtendLinkButton = [[ArticleVideoActionButton alloc] init];
//                [_videoExtendLinkButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
//                NSString *title = [_viewModel.infoModel.VExtendLinkDic valueForKey:@"button_text"];
//                title = title.length > 0 ? title : @"查看更多";
//
//                if ([_viewModel.infoModel.VExtendLinkDic valueForKey:@"is_download_app"]) {
//
//                    if (title.length <= 0) {
//                        title = NSLocalizedString(@"立即下载", nil);
//                    }
//                }
//
//                [_videoExtendLinkButton setTitle:title];
//                [_videoExtendLinkButton addTarget:self action:@selector(ExtendLinkAction:)];
//                [self addSubview:_videoExtendLinkButton];
//            }
//        }
        
        if (!_digButton) {
            _digButton = [[ArticleVideoActionButton alloc] init];
            [_digButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
            _digButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -15, -10, -16);
            [_digButton addTarget:self action:@selector(digAction:)];
            [self addSubview:_digButton];
        }
        
        if (!_buryButton) {
            _buryButton = [[ArticleVideoActionButton alloc] init];
            [_buryButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
            _buryButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -16, -10, -16);
            [_buryButton addTarget:self action:@selector(buryAction:)];
            [self addSubview:_buryButton];
        }
        
        if (!self.bottomLine) {
            self.bottomLine = [[SSViewBase alloc] init];
            self.bottomLine.backgroundColorThemeName = kColorLine1;
            [self addSubview:self.bottomLine];
            self.bottomLine.hidden = YES;
        }

        if (isEmptyString(self.viewModel.infoModel.adId))
        {
            if(ttvs_isVideoShowDirectShare() > 1 && !self.videoExtendLinkButton){
                [self addDirectShareButtons];
            }
            else{
                if (ttvs_isVideoShowOptimizeShare() > 0){
                    [self addShareButton];
                }
            }
        }
    }
}

- (void)addShareButton
{
    if (!_shareButton) {
        _shareButton = [[ArticleVideoActionButton alloc] init];
        _shareButton.disableRedHighlight = YES;
        _shareButton.maxWidth = 62.0f;
        [_shareButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
        _shareButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [_shareButton setTitle:@"分享"];
        [self addSubview:_shareButton];
    }
    [_shareButton addTarget:self action:@selector(shareButtonPressed:)];
    [self layoutActionButtons];
}

- (void)addDirectShareButtons
{
    if (ttvs_isVideoShowDirectShare() > 1)
    {
        NSArray *activitySequenceArr;
        if (!ttvs_isShareIndividuatioEnable()) {
            activitySequenceArr = @[@(TTActivityTypeWeixinMoment), @(TTActivityTypeWeixinShare)];
        }else{
            activitySequenceArr = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareServiceSequence];
        }
        
        if (!_directShareLabel) {
            _directShareLabel = [[SSThemedLabel alloc] init];
            _directShareLabel.text = NSLocalizedString(@"分享到", nil);
            _directShareLabel.textColor = SSGetThemedColorWithKey(kColorText1);
            _directShareLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
            [_directShareLabel sizeToFit];
            [self addSubview:_directShareLabel];
        }
        
        int hasbutton = 0;
        for (int i = 0; i < activitySequenceArr.count; i++){
            
            id obj = [activitySequenceArr objectAtIndex:i];
            if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
                NSString *itemType;
                if ([obj isKindOfClass:[NSNumber class]]) {
                    TTActivityType objType = [obj integerValue];
                    itemType = [TTActivityShareSequenceManager activityStringTypeFromActivityType:objType];
                }else{
                    itemType = (NSString *)obj;
                }
                if (/*[itemType isEqualToString:TTActivityContentItemTypeDingTalk] ||*/ [itemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
                    continue;
                }
                UIImage *img = [self activityImageNameWithActivity:itemType];
                NSString *title = [self activityTitleWithActivity:itemType];
                
                if (_weixinMoment && _weixin) {
                    if (img) {
                        if (hasbutton == 0) {
                            _weixinMoment.iconImage.image = img;
                            _weixinMoment.nameLabel.text = title;
                            _weixinMoment.activityType = itemType;
                        }else{
                            _weixin.iconImage.image = img;
                            _weixin.nameLabel.text = title;
                            _weixin.activityType = itemType;

                        }
                    }
                }
                else{
                    TTVideoShareThemedButton *button = [self buttonWithIndex:hasbutton image:img title:title];
                    [self addSubview:button];
                    button.activityType = itemType;
                    if (hasbutton == 0) {
                        _weixinMoment = button;
                    }else{
                        _weixin = button;
                    }
                }
                hasbutton++;
                if (hasbutton == 2) {
                    break;
                }
            }
        }
        [self layoutActionButtons];
    }
}

- (TTVideoShareThemedButton *)buttonWithIndex:(int)index image:(UIImage *)image title:(NSString *)title
{
    CGRect frame;
    TTVideoShareThemedButton *view = nil;
    frame = CGRectMake(index*kVideoDirectShareButtonWidth, 0, kVideoDirectShareButtonWidth, kVideoDirectShareButtonWidth);
    view = [[TTVideoShareThemedButton alloc] initWithFrame:frame index:index image:image title:title needLeaveWhite:NO]; //是否需要显示nameLabel
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    [view addTarget:self action:@selector(directShareActionClicked:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}

- (UIImage *)activityImageNameWithActivity:(NSString *)itemType
{
    UIImage *image = nil;
    if (itemType) {
        if ([itemType isEqualToString:TTActivityContentItemTypeWechat]){
            image = [UIImage imageNamed:@"video_center_share_weChat"];
        }else if ([itemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
            image = [UIImage imageNamed:@"video_center_share_pyq"];
        }else if ([itemType isEqualToString:TTActivityContentItemTypeQQZone]){
            image = [UIImage imageNamed:@"video_center_share_qzone"];
        }else if ([itemType isEqualToString:TTActivityContentItemTypeQQFriend]){
            image = [UIImage imageNamed:@"video_center_share_qq"];
        }
//        else if ([itemType isEqualToString:TTActivityContentItemTypeDingTalk]){
//            image = [UIImage imageNamed:@"video_center_share_ding"];
//        }
//        else {
//            UIImage * dayImage = [[TTWeitoutiaoRepostIconDownloadManager sharedManager] getWeitoutiaoRepostDayIcon];
//            if (nil == dayImage) {
//                //使用本地图片
//                image = [UIImage imageNamed:@"video_center_share_weitoutiao"];
//            }else {
//                //网络图片已下载
//                image = dayImage;
//            }
//        }
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            image = [self imageByApplyingAlpha:0.5 image:image];
        }

    }
    return image;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSString *)activityTitleWithActivity:(NSString *)itemType
{
    if ([itemType isEqualToString:TTActivityContentItemTypeWechat]){
        return @"微信";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        return @"朋友圈";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQZone]){
        return @"QQ空间";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQFriend]){
        return @"QQ";
    }
//    else if ([itemType isEqualToString:TTActivityContentItemTypeDingTalk]){
//        return @"钉钉";
//    }
    else {
        return [KitchenMgr getString:kKCUGCRepostWordingShareIconTitle];
    }
}

- (void)addShareView
{
    if (!_shareView) {
            self.shareView = [[TTVVideoDetailNatantInfoShareView alloc] initWithWidth:self.width andinfoModel:self.viewModel];
        self.shareView.height = [TTDeviceUIUtils tt_newPadding:36];
        self.shareView.backgroundColor = [UIColor clearColor];
            [self addSubview:self.shareView];
        @weakify(self);
        self.shareView.shareActionBlock = ^(NSString *shareAction) {
            @strongify(self);
            if (shareAction)
            {
                if ([shareAction isEqualToString:TTVVideodetailNatantInfoShareViewDigg]) {
                    if ([self.viewModel.infoModel.userBuried boolValue]) {
                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经踩过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
                        return;
                    }
                    if ([self.viewModel.infoModel.userDiged boolValue]) {
                        //取消赞
                        [self.viewModel cancelDiggAction];
                        [self diggBuryactionLog3:@"rt_unlike" isDoublSending:NO];
                    }else{
                        //赞
                        [self.viewModel digAction];
                        [self diggBuryactionLog3:@"rt_like" isDoublSending:NO];
                    }
                    [self.shareView updateDiggButton];
                } //分享按钮
                else if ([shareAction isEqualToString:TTVVideodetailNatantInfoShareViewShareAction])
                {
                    NSInteger shareIconStye = [[[TTSettingsManager sharedManager] settingForKey:@"tt_share_icon_type" defaultValue:@0 freeze:NO] integerValue];
                    [TTTrackerWrapper eventV3:@"share_icon_click" params:@{@"icon_type": @(shareIconStye).stringValue}];
                    if ( self.shareManager && [self.shareManager respondsToSelector:@selector(_detailCentrelShareActionFired)]) {
                        [self.shareManager _detailCentrelShareActionFired];
                    }
                } //了解更多
                else if([shareAction isEqualToString:TTVVideodetailNatantInfoShareViewExtendLink] )
                {
                    if ([self.delegate respondsToSelector:@selector(extendLinkButton:)]) {
                        [self.delegate extendLinkButton:nil];
                    }
                } // 直接分享
                else{
                    if (self.shareManager && [self.shareManager respondsToSelector:@selector(_detailCentrelDirectShareItemAction:)]) {
                        [self.shareManager _detailCentrelDirectShareItemAction:shareAction];
                    }
                }
            }
        };
    }
}
#pragma mark - reloadData

- (void)reloadData{
    [self buildOptionView];
    [self updateVideoInfo];
    [self refreshUI];

}

- (void)updateVideoTextArea
{
    _titleRichLabel.font = [UIFont boldSystemFontOfSize:[[self class] titleLabelFontSize]];
    [_titleRichLabel  setText:_viewModel.titleLabelAttributedStr];
    if (_viewModel.titleLabelLinks){
        for (TTUGCAttributedLabelLink *link in _viewModel.titleLabelLinks){
            WeakSelf;
            link.linkTapBlock = ^(TTUGCAttributedLabel * curLabel, TTUGCAttributedLabelLink * curLink) {
                StrongSelf;
                [self.viewModel linkTap:curLink.linkURL UIView:self];
            };
            [self.titleRichLabel addLink:link];
        }
    }
}

- (void) updateVideoInfo{

    [self updateVideoTextArea];
    
    self.watchCountLabel.text = _viewModel.watchCountStr;
    
    [self updateContentLabel];
    
    if (!_recommendView.viewModel && _viewModel.infoModel.zzComments) {
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:_viewModel.infoModel.zzComments.count];
        NSMutableSet *filterSet = [NSMutableSet set];
        for (NSDictionary *comments in _viewModel.infoModel.zzComments) {
            TTVideoRecommendModel *model = [[TTVideoRecommendModel alloc] initWithDictionary:comments error:nil];
            if (model.userName) {
                if (![filterSet containsObject:model.userName]) {
                    [filterSet addObject:model.userName];
                    [models addObject:model];
                }
            }
        }
        [_viewModel logShowRecommentView:models];
        _recommendView.viewModel = models;
    }
    [self updateActionButtons];
}

- (void)updateContentLabel{
    self.contentLabel.text = _viewModel.attributeString; //contentLabel 的attributes
    self.contentLabel.linkAttributes = [_viewModel contentLabelLinkAttributes];
    self.contentLabel.activeLinkAttributes = [_viewModel contentLabelActiveLinkAttributes];
}

- (void) updateActionButtons{
    if (self.showShareView) {
        [self.shareView updateDiggButton];
        return;
    }
    _digButton.imageSize = CGSizeMake(24.f, 24.f);
    [_digButton setMinWidth:36.f];
    [_digButton setMaxWidth:72.0f];
    [_digButton setTitle:_viewModel.digTitle];
    if ([_viewModel.infoModel.banDig boolValue]) {
        if ([_viewModel.infoModel.userDiged boolValue]) {
            [_digButton setTitle:@"1"];
        }
        else {
            [_digButton setTitle:@"0"];
        }
    }
    _buryButton.imageSize = CGSizeMake(24.f, 24.f);
    [_buryButton setMinWidth:36.f];
    [_buryButton setMaxWidth:72.0f];
    [_buryButton setTitle:_viewModel.buryTitle];
    if ([_viewModel.infoModel.banBury boolValue]) {
        if ([_viewModel.infoModel.userBuried boolValue]) {
            [_buryButton setTitle:@"1"];
        }
        else{
            [_buryButton setTitle:@"0"];
        }
    }
    
    if ([_viewModel.infoModel.userDiged boolValue]) {
        [_digButton setEnabled:YES selected:YES];
        [_buryButton setEnabled:YES selected:NO];
    }
    else if ([_viewModel.infoModel.userBuried boolValue]) {
        [_digButton setEnabled:YES selected:NO];
        [_buryButton setEnabled:YES selected:YES];
    }
    else {
        [_digButton setEnabled:YES selected:NO];
        [_buryButton setEnabled:YES selected:NO];
    }

}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshUI];
}

- (void)refreshUI
{
    _titleRichLabel.numberOfLines = _isUnfold?2:[self curScale];
    [self updateContentLabel];
    [self layoutVideoInfo];
    
    if (!self.showShareView) {
        [self layoutActionButtons];
        if (self.intensifyAuthor) {
            self.height = _digButton.bottom + 10;
        } else {
            self.height = _digButton.bottom;
        }
    }else{
        CGFloat archerPoint;
        if (_contentLabel.hidden) {
            archerPoint = _watchCountLabel.bottom + kWatchCountContentLabelSpace ;
        }
        else {
            archerPoint = _contentLabel.bottom + kContentLabelBottomSpace;
        }
        self.shareView.origin = CGPointMake(0, archerPoint);
        self.height = self.shareView.bottom + [TTDeviceUIUtils tt_newPadding:3];
        if (self.showCardView) {
            self.height += [TTDeviceUIUtils tt_newPadding:12];
        }
    }
    CGFloat h = [TTDeviceHelper ssOnePixel];
    self.bottomLine.frame = CGRectMake(0, self.height-h, self.width, h);
    if ([_delegate respondsToSelector:@selector(reLayOutSubViews:)]) {
        [_delegate reLayOutSubViews:NO];
    }
}

- (void)layoutVideoInfo
{
    CGFloat titleLabelWidth;
    _detailButton.hidden = NO;
    _titleDetailButton.hidden = NO;
    if ([TTDeviceHelper isPadDevice]) {
        _detailButton.size = [_detailButton imageForState:UIControlStateNormal].size;
    }
    _detailButton.origin = CGPointMake(self.width - _detailButton.width - kDetailButtonRightPadding, kVerticalEdgeMargin + (_titleRichLabel.font.pointSize - _detailButton.height)/2);
    if (self.intensifyAuthor) {
        _detailButton.top -= 10;
    }
    titleLabelWidth = self.width - kVideoDetailItemCommonEdgeMargin - kDetailButtonLeftSpace - _detailButton.width - kDetailButtonRightPadding;
    CGFloat contentLabelwidth = self.width - 2 * kVideoDetailItemCommonEdgeMargin;
    
    NSInteger scale = [self curScale];
    
    CGSize titleRichLabelRealSize = [_titleRichLabel sizeThatFits:CGSizeMake(titleLabelWidth, _isUnfold?2*kTitleLabelLineHeight: kTitleLabelLineHeight*scale)];
    if (titleRichLabelRealSize.width > titleLabelWidth) {
        titleRichLabelRealSize.width = titleLabelWidth;
    }
    
    CGFloat contentLabelShowHeight = [self.contentLabel sizeThatFits:CGSizeMake(contentLabelwidth, 0)].height;
    
    CGFloat titleLabelTop = kVerticalEdgeMargin;
    if (self.intensifyAuthor) {
        titleLabelTop -= 10;
    }
    _titleRichLabel.frame = CGRectMake(kVideoDetailItemCommonEdgeMargin, titleLabelTop, titleLabelWidth, ceil(titleRichLabelRealSize.height + 2));
    _titleDetailButton.frame = _titleRichLabel.frame;
    [self bringSubviewToFront:_titleRichLabel];
    [_watchCountLabel sizeToFit];
    _watchCountLabel.origin = CGPointMake(kVideoDetailItemCommonEdgeMargin, _titleRichLabel.bottom + kTitleLabelBottomSpace);
    _recommendView.left = _watchCountLabel.right;
    _recommendView.width = self.width - _recommendView.left - kVideoDetailItemCommonEdgeMargin;
    _recommendView.height = _watchCountLabel.height;
    _recommendView.centerY = _watchCountLabel.centerY;
    
    _contentLabel.frame = CGRectMake(_titleRichLabel.left, _watchCountLabel.bottom + kWatchCountContentLabelSpace, contentLabelwidth, contentLabelShowHeight);
}

- (void)layoutActionButtons
{
    CGFloat archerPoint;
    
    CGFloat commonEdgeMargin = kVideoDetailItemCommonEdgeMargin;
    
    CGFloat digImageHeight = _digButton.imageView.image.size.height;
    CGFloat digTopInset = (_digButton.minHeight - digImageHeight) / 2;
    
    if (_contentLabel.hidden) {
        archerPoint = _watchCountLabel.bottom + kWatchCountContentLabelSpace - digTopInset;
    }
    else {
        archerPoint = _contentLabel.bottom + kContentLabelBottomSpace - digTopInset;
    }
    [_digButton updateFrames];
    [_buryButton updateFrames];
    [_videoExtendLinkButton updateFrames];
    [_shareButton updateFrames];

    _digButton.origin = CGPointMake(commonEdgeMargin, archerPoint);
    CGFloat buryButtonLeft = _digButton.left + ([TTDeviceHelper isPadDevice] ? 114 : (_digButton.width + [[self class] digBurySpace]));
    _buryButton.origin = CGPointMake(buryButtonLeft, _digButton.top);
    
    CGFloat shareButtonLeft = _buryButton.left + ([TTDeviceHelper isPadDevice] ? 114 : (_buryButton.width + 24));
    CGFloat linkButtonLeft = _shareButton.left + ([TTDeviceHelper isPadDevice] ? 114 : (_buryButton.width + 24));
    
    if (_shareButton) {
        _shareButton.origin = CGPointMake(shareButtonLeft, _digButton.top);
        _videoExtendLinkButton.origin = CGPointMake(linkButtonLeft, _digButton.top);
        _weixin.hidden = YES;
        _weixinMoment.hidden = YES;
        _directShareLabel.hidden = YES;
        _shareButton.hidden = NO;
        
    }else{
        _videoExtendLinkButton.origin = CGPointMake(shareButtonLeft, _digButton.top);
        [_videoExtendLinkButton setMaxWidth:72.f];
        if (!_videoExtendLinkButton) {
            _weixin.hidden = NO;
            _weixinMoment.hidden = NO;
            _directShareLabel.hidden = NO;
            _weixin.left = self.width - 9 - kVideoDirectShareButtonWidth;
            _weixin.centerY = _digButton.centerY;
            _weixinMoment.right = _weixin.left - 4;
            _weixinMoment.top = _weixin.top;
            _directShareLabel.right = _weixinMoment.left - 6;
            _directShareLabel.centerY = _weixin.centerY;
        }
    }

    
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self.viewModel updateAttributeTitle];
    _watchCountLabel.textColor = SSGetThemedColorWithKey(kColorText3);
    _directShareLabel.textColor = SSGetThemedColorWithKey(kColorText1);
    [self updateVideoInfo];
    _detailButton.imageName = [TTDeviceHelper isPadDevice] ? @"Triangle" : @"Triangle";
    
    [_digButton setImage:[UIImage themedImageNamed:@"like"] forState:UIControlStateNormal];
    [_digButton setImage:[UIImage themedImageNamed:@"like_press"] forState:UIControlStateHighlighted];
    [_digButton setImage:[UIImage themedImageNamed:@"like_press"] forState:UIControlStateSelected];
    [_digButton setTintColor:SSGetThemedColorWithKey(kColorText1)];
    [_digButton updateThemes];
    
    [_digButton setTitleColor:SSGetThemedColorWithKey(kColorText1) forState:UIControlStateNormal];
    [_digButton setTitleColor:SSGetThemedColorWithKey(kColorText4) forState:UIControlStateHighlighted];
    [_digButton setTitleColor:SSGetThemedColorWithKey(kColorText4) forState:UIControlStateSelected];
    
    [_buryButton setImage:[UIImage themedImageNamed:@"step"] forState:UIControlStateNormal];
    [_buryButton setImage:[UIImage themedImageNamed:@"step_press"] forState:UIControlStateHighlighted];
    [_buryButton setImage:[UIImage themedImageNamed:@"step_press"] forState:UIControlStateSelected];
    [_buryButton updateThemes];
    [_buryButton setTitleColor:SSGetThemedColorWithKey(kColorText1) forState:UIControlStateNormal];
    [_buryButton setTitleColor:SSGetThemedColorWithKey(kColorText4) forState:UIControlStateHighlighted];
    [_buryButton setTitleColor:SSGetThemedColorWithKey(kColorText4) forState:UIControlStateSelected];
    
    [_videoExtendLinkButton setImage:[UIImage themedImageNamed:@"link"] forState:UIControlStateNormal];
    [_videoExtendLinkButton setImage:[UIImage themedImageNamed:@"link_press"] forState:UIControlStateHighlighted];
    [_videoExtendLinkButton updateThemes];
    [_videoExtendLinkButton setTitleColor:SSGetThemedColorWithKey(kColorText1) forState:UIControlStateNormal];
    [_videoExtendLinkButton setTitleColor:[SSGetThemedColorWithKey(kColorText1) colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    [self.shareButton setImage:[UIImage themedImageNamed:[self ttv_shareImageIcon]] forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage themedImageNamed:[self ttv_shareImageIcon]] forState:UIControlStateHighlighted];
    self.shareButton.imageSize = CGSizeMake(20.f, 20.f);
    
    [self.shareButton updateThemes];
    [self.shareButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateHighlighted];
    if (_weixinMoment && _weixin) {
        [self addDirectShareButtons];
    }
    self.bottomLine.backgroundColorThemeName = kColorLine1;
}

#pragma mark - actions

- (void)detailButtonPressed{
    _isUnfold = !_isUnfold;
    [self doRotateDetailButtonAnimation];
    [self refreshUI];
    if (_contentLabel.hidden) {
        wrapperTrackEvent(@"detail", @"detail_fold_content");
    }
    else {
        wrapperTrackEvent(@"detail", @"detail_unfold_content");
    }
}

- (void)digAction:(id)sender
{
    if ([self.viewModel.infoModel.userBuried boolValue]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经踩过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }
    if ([self.viewModel.infoModel.userDiged boolValue]) {
        //取消赞
        [self.viewModel cancelDiggAction];
        [self updateActionButtons];
        [self diggBuryactionLog3:@"rt_unlike" isDoublSending:NO];
        return;
    }else{
        //赞
        [self actionButtonPressed:sender];
    }
}

- (void)buryAction:(id)sender
{
    if ([self.viewModel.infoModel.userDiged boolValue]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经赞过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }
    if ([self.viewModel.infoModel.userBuried boolValue]) {
        [self.viewModel cancelBurryAction];
        [self updateActionButtons];
        [self diggBuryactionLog3:@"rt_unbury" isDoublSending:NO];
        return;
    }else{
        [self actionButtonPressed:sender];
    }
    
}

- (void)ExtendLinkAction:(id)sender
{
    if (sender == _videoExtendLinkButton) {
        if ([_delegate respondsToSelector:@selector(extendLinkButton:)]) {
            [_delegate extendLinkButton:(UIButton *)_videoExtendLinkButton];
        }
    }
}

- (void)actionButtonPressed:(id)sender
{
    
    if (sender == _digButton) {
        [_digButton doZoomInAndDisappearMotion];
        [self.viewModel digAction] ;
        _digButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        _digButton.imageView.contentMode = UIViewContentModeCenter;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _digButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            _digButton.imageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self updateActionButtons];
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                _digButton.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                _digButton.imageView.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }];
        [self diggBuryactionLog3:@"rt_like" isDoublSending:NO];
    }
    else if (sender == _buryButton) {
        [_buryButton doZoomInAndDisappearMotion];
        [self.viewModel buryAction];
        _buryButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        _buryButton.imageView.contentMode = UIViewContentModeCenter;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _buryButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            _buryButton.imageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self updateActionButtons];
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                _buryButton.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                _buryButton.imageView.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }];
        [self diggBuryactionLog3:@"rt_bury" isDoublSending:NO];
    }
}

- (void)shareButtonPressed:(id)sender
{
    if (sender == _shareButton){
        NSInteger shareIconStye = [[[TTSettingsManager sharedManager] settingForKey:@"tt_share_icon_type" defaultValue:@0 freeze:NO] integerValue];
        [TTTrackerWrapper eventV3:@"share_icon_click" params:@{@"icon_type": @(shareIconStye).stringValue}];
        if ( self.shareManager && [self.shareManager respondsToSelector:@selector(_detailCentrelShareActionFired)]) {
            [self.shareManager _detailCentrelShareActionFired];
        }
    }
}

- (void)directShareActionClicked:(id)sender
{
    TTVideoShareThemedButton *btn = (TTVideoShareThemedButton *)sender;
    if (self.shareManager && [self.shareManager respondsToSelector:@selector(_detailCentrelDirectShareItemAction:)]) {
        [self.shareManager _detailCentrelDirectShareItemAction:btn.activityType];
        //评分视图，发个通知就行
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTAppStoreStarManagerShowNotice" object:nil userInfo:@{@"trigger":@"share"}];
    }
}

- (void)doRotateDetailButtonAnimation
{
    [UIView animateWithDuration:0.1 animations:^{
        _detailButton.transform = CGAffineTransformRotate(_detailButton.transform, M_PI);
    } completion:nil];
}

#pragma mark -- TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    NSDictionary *extra;
    NSURLComponents *com = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:nil];
    if ([com.scheme isEqualToString:@"bytedance"] && [com.host isEqualToString:@"keywords"]) { //
        NSDictionary *paras = [TTStringHelper parametersOfURLString:com.query];
        NSString *keyword = [paras stringValueForKey:@"keyword" defaultValue:nil];
        if (!isEmptyString(keyword)) {
            ExploreSearchViewController * searchController = [[ExploreSearchViewController alloc] initWithNavigationBar:YES showBackButton:YES queryStr:keyword fromType:ListDataSearchFromTypeTag];
            searchController.groupID = @([self.viewModel.uniqueID longLongValue]);
            UINavigationController *rootController = [TTUIResponderHelper topNavigationControllerFor:self];
            [rootController pushViewController:searchController animated:YES];
            extra = @{ @"click_keyword" : keyword };
        }
    } else if ([com.scheme isEqualToString:@"sslocal"] && [com.host isEqualToString:@"detail"]) {
        NSDictionary *parameters = [TTStringHelper parametersOfURLString:com.query];
        NSString *groupID = [parameters objectForKey:@"groupid"];
        BOOL hasGroupID = !isEmptyString(groupID);
        BOOL canOpen =  [[TTRoute sharedRoute] canOpenURL:url];
        if (hasGroupID && canOpen) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
        extra = @{ @"click_groupid" : groupID };
    } else {
        return ; //其他情况不做处理
    }
    
    [TTTrackerWrapper category:@"umeng" event:@"video" label:@"detail_abstract_click" dict:extra];
}

#pragma mark - TTBugFixAttributedLabelDelegate



- (void)showBottomLine {
    _bottomLine.hidden = NO;
}

#pragma mark - helper

- (NSString *)ttv_shareImageIcon {
    NSInteger shareIconStye = [[[TTSettingsManager sharedManager] settingForKey:@"tt_share_icon_type" defaultValue:@0 freeze:NO] integerValue];
    switch (shareIconStye) {
        case 1:
            return @"tab_share";
            break;
        case 2:
            return @"tab_share1";
            break;
        case 3:
            return @"tab_share4";
            break;
        case 4:
            return @"tab_share3";
            break;
        default:
            return @"tab_share";
            break;
    }
}

- (NSInteger)curScale {
    return 1;
}

- (BOOL)shouldHideDetailButton
{
    return NO;
}
+ (CGFloat)titleLabelFontSize
{
    return [TTVideoFontSizeManager settedTitleFontSize];
}

+ (CGFloat)contentLabelFontSize
{
    return tt_ssusersettingsManager_detailVideoContentFontSize();
}

+ (CGFloat)watchCountLabelFontSize
{
    return tt_ssusersettingsManager_detailVideoContentFontSize();
}

+ (CGFloat)digBurySpace
{
    return 30;
}

+ (float)setTitleLineHeight{
    float fontHeight = [TTVideoFontSizeManager settedTitleFontSize];
    return fontHeight + 4;
}

#pragma mark - log3.0
- (void)diggBuryactionLog3:(NSString *)eventName isDoublSending:(BOOL) isDouble{
    NSMutableDictionary *pramas = [NSMutableDictionary dictionary];
    [pramas setValue:self.viewModel.infoModel.logPb forKey:@"log_pb"];
    [pramas setValue:self.viewModel.infoModel.enterFrom forKey:@"enter_from"];
    [pramas setValue:[self categoryName] forKey:@"category_name"];
    [pramas setValue:self.viewModel.infoModel.itemId forKey:@"item_id"];
    [pramas setValue:@"detail" forKey:@"position"];
    [pramas setValue:self.viewModel.infoModel.groupId forKey:@"group_id"];
    [pramas setValue:self.viewModel.infoModel.authorId forKey:@"author_id"];
    [pramas setValue:@"video" forKey:@"article_type"];

    [TTTrackerWrapper eventV3:eventName params:pramas isDoubleSending:isDouble];
    
}
- (NSString *)categoryName
{
    NSString *categoryName = self.viewModel.infoModel.categoryId;
    if (isEmptyString(categoryName) || [categoryName isEqualToString:@"xx"]) {
        categoryName = [self.viewModel.infoModel.enterFrom stringByReplacingOccurrencesOfString:@"click_" withString:@""];
    }else {
        if (![self.viewModel.infoModel.enterFrom isEqualToString:@"click_headline"]) {
            if ([categoryName hasPrefix:@"_"]) {
                categoryName = [categoryName substringFromIndex:1];
            }
        }
    }
    return categoryName;
}

#pragma mark - TTActivityShareSequenceChangedMessage

- (void)message_shareActivitySequenceChanged{
    if (!self.showShareView) {
        if (self.weixin && self.weixinMoment){
            [self addDirectShareButtons];
        }
    }
}

#pragma mark - setter

- (void)setShowShareView:(BOOL)showShareView{
    _showShareView = showShareView;
    if (_showShareView) {
        [self addShareView];
    }
}


@end

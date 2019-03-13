//
//  TTDetailNatantVideoInfoView.m
//  Article
//
//  Created by Ray on 16/4/14.
//
//

#import "TTDetailNatantVideoInfoView.h"
#import "ArticleVideoActionButton.h"
#import "SSThemed.h"
#import "Article.h"
#import "ExploreItemActionManager.h"
#import "SSUserSettingManager.h"
#import "TTLabelTextHelper.h"
#import "ArticleInfoManager.h"
#import "TTDetailModel.h"
#import "TTVideoRecommendView.h"
#import "SSTTTAttributedLabel.h"
#import "ExploreSearchViewController.h"

#import "SSCommonLogic.h"
#import "TTDetailModel.h"
#import "TTActionButtonEventDelegate.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"
#import "TTIndicatorView.h"
#import "SDWebImageCompat.h"
#import "UIImage+TTThemeExtension.h"

#import <libextobjc/extobjc.h>
#import "TTMessageCenter.h"
#import "TTVFeedUserOpDataSyncMessage.h"
#import "TTUIResponderHelper.h"
#import "TTRoute.h"
#import "TTVideoFontSizeManager.h"
#import "TTUserSettingsManager+FontSettings.h"
#import "TTVideoShareThemedButton.h"
#import "TTActivity.h"
//#import "TTWeitoutiaoRepostIconDownloadManager.h"
#import "TTActivityShareSequenceManager.h"
#import "TTMessageCenter.h"
#import "NSDictionary+TTGeneratedContent.h"
#import <TTKitchen/TTKitchenHeader.h>

#define kVerticalEdgeMargin             (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kTitleLabelLineHeight             [SSUserSettingManager detailVideoTitleLineHeight]
#define newkTitleLabelLineHeight         [TTDetailNatantVideoInfoView setTitleLineHeight]

#define kContentLabelLineHeight          [SSUserSettingManager detailVideoContentLineHeight]
#define kDetailButtonLeftSpace           5.f
#define kDetailButtonRightPadding        (([TTDeviceHelper isPadDevice]) ? 20 : 3)
#define kTitleLabelBottomSpace           (([TTDeviceHelper isPadDevice]) ? 22 : 4)
#define kContentLabelBottomSpace         (([TTDeviceHelper isPadDevice]) ? 30 : 15)
#define kWatchCountLabelBottomSpace      -2.f
#define kWatchCountContentLabelSpace     (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kTitleLabelMaxLines              1
#define kContentLabelMaxLines            0
#define kDigBurrySpaceScreenWidthAspect  0.2f
#define kVideoDetailItemCommonEdgeMargin (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kVideoDirectShareButtonWidth     36

extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;
extern NSInteger ttvs_isVideoShowDirectShare(void);
extern BOOL ttvs_isShareIndividuatioEnable(void);


@interface TTDetailNatantVideoInfoView () <TTTAttributedLabelDelegate, TTActionButtonEventProtocol, TTActivityShareSequenceChangedMessage>

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) SSTTTAttributedLabel *contentLabel;
@property(nonatomic, copy)   NSString *abstractString;// HTML String,使用的时候要转为AttibutedString

@property(nonatomic, strong) SSThemedButton *detailButton;
@property(nonatomic, strong) SSThemedButton *titleDetailButton;
@property(nonatomic, strong) UILabel *watchCountLabel;
@property(nonatomic, strong) TTVideoRecommendView *recommendView;
@property(nonatomic, strong) ArticleVideoActionButton *digButton;
@property(nonatomic, strong) ArticleVideoActionButton *buryButton;
@property(nonatomic, strong) ArticleVideoActionButton *videoExtendLinkButton;
@property(nonatomic, strong) ArticleVideoActionButton *shareButton;
@property(nonatomic, strong) TTActionButtonEventDelegate *actionButtonDelegate;

@property(nonatomic, strong) Article *article;
@property(nonatomic, strong) TTDetailModel *detailModel;
@property(nonatomic, strong) ExploreItemActionManager *itemActionManager;
@property(nonatomic, strong) NSDictionary *contentLabelTextAttributs;
@property(nonatomic, strong) NSDictionary *contentLabelLinkAttributes;
@property(nonatomic, strong) NSDictionary *contentLabelActiveLinkAttributes;

//外露具体分享渠道
@property(nonatomic, strong) SSThemedLabel *directShareLabel;
@property(nonatomic, strong) TTVideoShareThemedButton *weixin;
@property(nonatomic, strong) TTVideoShareThemedButton *weixinMoment;

@property(nonatomic, strong) SSViewBase *bottomLine;

@property(nonatomic, assign) BOOL isUnfold;

@end


@implementation TTDetailNatantVideoInfoView

- (void)dealloc
{
    _contentLabel.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_article removeObserver:self forKeyPath:@"diggCount"];
    [_article removeObserver:self forKeyPath:@"buryCount"];
    UNREGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        REGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
        _actionButtonDelegate = [[TTActionButtonEventDelegate alloc] initWithTarget:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontChanged:)
                                                     name:kSettingFontSizeChangedNotification object:nil];
        [self reloadThemeUI];
    }
    return self;
}

- (void)fontChanged:(NSNotification *)notification {
    _titleLabel.font = [UIFont boldSystemFontOfSize:[[self class] titleLabelFontSize]];
    [self updateVideoTextArea];
    [self refreshUI];
}


- (void)refreshWithArticle:(Article *)article
{
    self.article = article;
    [self buildView];
    [self reloadThemeUI];
    [self refreshUI];
    [self updatePublishInfoWithArticle:article];
    if (![TTDeviceHelper isPadDevice] && [_article.isOriginal boolValue]) {
        [self refreshUI];
    }
}

- (void)buildView
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
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
        [_titleDetailButton addTarget:self action:@selector(detailButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_titleDetailButton];
    }
    
    if (!_detailButton) {
        _detailButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_detailButton sizeToFit];
        [_detailButton addTarget:self action:@selector(detailButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_detailButton];
    }
    
    if (!_watchCountLabel) {
        _watchCountLabel = [[UILabel alloc] init];
        _watchCountLabel.textAlignment = NSTextAlignmentLeft;
        _watchCountLabel.backgroundColor = [UIColor clearColor];
        _watchCountLabel.font = [UIFont systemFontOfSize:[[self class] watchCountLabelFontSize]];
        _watchCountLabel.numberOfLines = 1;
        [self addSubview:_watchCountLabel];
    }
    
    if (!_recommendView && self.article.zzComments) {
        _recommendView = [[TTVideoRecommendView alloc] init];
        [self addSubview:_recommendView];
    }
    
    if (!_digButton) {
        _digButton = [[ArticleVideoActionButton alloc] init];
        [_digButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
        _digButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -15, -10, -16);
        [_digButton addTarget:self.actionButtonDelegate action:@selector(actionButtonPressed:)];
        [self addSubview:_digButton];
    }
    
    if (!_buryButton) {
        _buryButton = [[ArticleVideoActionButton alloc] init];
        [_buryButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
        _buryButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -16, -10, -16);
        [_buryButton addTarget:self.actionButtonDelegate action:@selector(actionButtonPressed:)];
        [self addSubview:_buryButton];
    }
    
    if ([self.article showExtendLink]) {
        if (!_videoExtendLinkButton) {
            _videoExtendLinkButton = [[ArticleVideoActionButton alloc] init];
            [_videoExtendLinkButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
            NSString *title = [self.article.videoExtendLink valueForKey:@"button_text"];
            title = title.length > 0 ? title : @"查看更多";
            
            if ([self.article.videoExtendLink valueForKey:@"is_download_app"]) {
//                BOOL appInstalled = [[UIApplication sharedApplication] canOpenURL:[TTStringHelper URLWithURLString:[self.article.videoExtendLink valueForKey:@"url"]]] || [TTRoute conformsToRouteWithScheme:[self.article.videoExtendLink valueForKey:@"package_name"]];//
//                if (appInstalled) {
//                    title = NSLocalizedString(@"立即打开", nil);
//                }
//                else
                if (title.length <= 0) {
                    title = NSLocalizedString(@"立即下载", nil);
                }
            }
            
            [_videoExtendLinkButton setTitle:title];
            [_videoExtendLinkButton addTarget:self.actionButtonDelegate action:@selector(actionButtonPressed:)];
            [self addSubview:_videoExtendLinkButton];
        }
    }
    if (ttvs_isVideoShowDirectShare() > 1 && !self.videoExtendLinkButton){
        [self addDirectShareButtons];
    }else{   
        if(_isShowShare){
            [self addShareButton];
        }
    }
    
    if (!self.bottomLine) {
        self.bottomLine = [[SSViewBase alloc] init];
        self.bottomLine.backgroundColorThemeName = kColorLine1;
        [self addSubview:self.bottomLine];
        self.bottomLine.hidden = YES;
    }
    
    [self updateVideoInfo];
    [self updateActionButtonsWithArticle:_article];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshUI];
}

- (NSDictionary *)contentLabelTextAttributs
{
    if (!_contentLabelTextAttributs) {
        UIFont *font = [UIFont systemFontOfSize:[[self class] contentLabelFontSize]];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineHeightMultiple = 1.3;
        style.paragraphSpacing = .3 * font.lineHeight;

        NSMutableDictionary *attributs = [[NSMutableDictionary alloc] initWithCapacity:3];
        [attributs setValue:style forKey:NSParagraphStyleAttributeName];
        [attributs setValue:font forKey:NSFontAttributeName];
        [attributs setValue:SSGetThemedColorWithKey(kColorText3) forKey:NSForegroundColorAttributeName];
        _contentLabelTextAttributs = [attributs copy];
    }
    return _contentLabelTextAttributs;
}

- (NSDictionary *)contentLabelLinkAttributes
{
    if (!_contentLabelLinkAttributes) {
        NSMutableDictionary *linkAttr = [[NSMutableDictionary alloc] initWithCapacity:2];
        [linkAttr setValue:@(NO) forKey:(NSString *)kCTUnderlineStyleAttributeName];
        [linkAttr setValue:SSGetThemedColorWithKey(kColorText5) forKey:NSForegroundColorAttributeName];
        _contentLabelLinkAttributes = [linkAttr copy];
    }
    return _contentLabelLinkAttributes;
}

- (NSDictionary *)contentLabelActiveLinkAttributes
{
    if (!_contentLabelActiveLinkAttributes) {
        NSMutableDictionary *activeLinkAtt = [[NSMutableDictionary alloc] initWithCapacity:2];
        [activeLinkAtt setValue:@(NO) forKey:(NSString *)kCTUnderlineStyleAttributeName];
        [activeLinkAtt setValue:SSGetThemedColorWithKey(kColorText5Highlighted) forKey:NSForegroundColorAttributeName];
        _contentLabelActiveLinkAttributes = [activeLinkAtt copy];
    }
    return _contentLabelActiveLinkAttributes;
}

- (void)showBottomLine {
    _bottomLine.hidden = NO;
}

#pragma mark - update

- (void)updateVideoInfo
{
    [self updateVideoTextArea];
    
    NSString *watchCountText = [TTBusinessManager formatCommentCount:[[_article.videoDetailInfo objectForKey:VideoWatchCountKey] longLongValue]];
    NSString *originText = ![TTDeviceHelper isPadDevice] && _article.isOriginal.boolValue ? @"原创 | " : @"";
    
    _watchCountLabel.text = [NSString stringWithFormat:@"%@%@次播放", originText, watchCountText];

    
    
    NSInteger videoType = 0;
    if ([[_article.videoDetailInfo allKeys] containsObject:@"video_type"]) {
        videoType = ((NSNumber *)[_article.videoDetailInfo objectForKey:@"video_type"]).integerValue;
    }
    
    
    if (videoType == 1) {
        _watchCountLabel.text = [NSString stringWithFormat:@"累计%@人观看",watchCountText];
    }
    
    
    if (_article.detailShowFlags) {
        watchCountText = [TTBusinessManager formatCommentCount:_article.readCount];
        _watchCountLabel.text = [NSString stringWithFormat:@"%@%@次阅读", originText, watchCountText];
    }


    if (!_recommendView.viewModel && self.article.zzComments) {
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:self.article.zzComments.count];
        NSMutableSet *filterSet = [NSMutableSet set];
        for (NSDictionary *comments in self.article.zzComments) {
            TTVideoRecommendModel *model = [[TTVideoRecommendModel alloc] initWithDictionary:comments error:nil];
            if (model.userName) {
                if (![filterSet containsObject:model.userName]) {
                    [filterSet addObject:model.userName];
                    [models addObject:model];                    
                }
            }
        }
        [self logShowRecommentView:models];
        _recommendView.viewModel = models;
    }
}

- (void)updateVideoTextArea
{
    [_titleLabel setAttributedText:[TTLabelTextHelper attributedStringWithString:_article.title fontSize:[[self class] titleLabelFontSize] lineHeight:newkTitleLabelLineHeight lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:YES]];
}

- (void)updateContentLabelWithHTMLString:(NSString *)htmlString
{
    if (isEmptyString(htmlString)) {
        return;
    }
    
    NSString *reg = @"<div\\ class=\"custom-video\"[\\s\\S]*?</div>"; //去掉html中自定义的div块，尝试修复html->attributedString的卡runloop的问题
    NSRange regRange = [htmlString rangeOfString:reg options:NSRegularExpressionSearch];
    if (NSNotFound != regRange.location) {
        htmlString = [htmlString stringByReplacingCharactersInRange:regRange withString:@""];
    }
    
    self.contentLabel.linkAttributes = [self contentLabelLinkAttributes];
    self.contentLabel.activeLinkAttributes = [self contentLabelActiveLinkAttributes];
    __weak typeof(self) wself = self;
    dispatch_block_t block = ^{
        NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
        wrapperTrackEvent(@"video_parse_abstract", @"begin");
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithData:data
                                                                                          options:@{
                                                                                                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                                    NSCharacterEncodingDocumentAttribute :
                                                                                                        @(NSUTF8StringEncoding)
                                                                                                    }
                                                                               documentAttributes:nil
                                                                                            error:nil];
        wrapperTrackEvent(@"video_parse_abstract", @"end");
        
        if (!wself) {
            return ;
        }
        NSRange range = [attributeStr.string  rangeOfString:@"(\\n){2,}" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            [attributeStr.mutableString replaceCharactersInRange:range withString:@"\n"];
            
            range = [attributeStr.string  rangeOfString:@"(\\n){2,}" options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [attributeStr.mutableString replaceCharactersInRange:range withString:@"\n"];
            }
        }
        
        range = NSMakeRange(0, attributeStr.string.length);
        [attributeStr addAttributes:[wself contentLabelTextAttributs] range:range];
        
        dispatch_main_async_safe(^{
            wself.contentLabel.text = attributeStr;
        });
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (block) {
            block();
        }
    });
}

- (void)updatePublishInfoWithArticle:(Article *)article
{
    if (article)
    {
        double time = article.articlePublishTime;
        NSString *publishTime = [NSString stringWithFormat:@"%@发布", [TTBusinessManager wordDateStringSince:time]];
        NSString *abstract = nil;
        if (isEmptyString(self.abstractString)) {
            abstract = publishTime;
        } else {
            abstract = [NSString stringWithFormat:@"%@ <br/> %@", publishTime, self.abstractString];
        }
        [self updateContentLabelWithHTMLString:abstract];
    }
}

- (void)updateActionButtonsWithArticle:(Article *)article
{
    int digCnt = article.diggCount;
    if (article.userDigg && !digCnt) {
        digCnt = 1;
    }
    NSString * diggTitle = digCnt > 0 ? [TTBusinessManager formatCommentCount:digCnt] : NSLocalizedString(@"顶", nil);
    if (digCnt < 10) {
        diggTitle = [diggTitle stringByAppendingString:@" "];
    }
    _digButton.imageSize = CGSizeMake(24.f,24.f);
    [_digButton setMinWidth:36.f];
    [_digButton setMaxWidth:72.0f];
    [_digButton setTitle:diggTitle];
    if ([article.banDigg boolValue]) {
        if (article.userDigg) {
            [_digButton setTitle:@"1"];
        }
        else {
            [_digButton setTitle:@"0"];
        }
    }
    
    int buryCnt = article.buryCount;
    if (article.userBury && !buryCnt) {
        buryCnt = 1;
    }
    NSString * buryTitle = buryCnt > 0 ? [TTBusinessManager formatCommentCount:article.buryCount] : NSLocalizedString(@"踩", nil);
    if (buryCnt < 10) {
        buryTitle = [buryTitle stringByAppendingString:@" "];
    }
    _buryButton.imageSize = CGSizeMake(24.f,24.f);
    [_buryButton setMinWidth:36.f];
    [_buryButton setMaxWidth:72.0f];
    [_buryButton setTitle:buryTitle];
    if ([article.banBury boolValue]) {
        if (article.userBury) {
            [_buryButton setTitle:@"1"];
        }
        else{
            [_buryButton setTitle:@"0"];
        }
    }
    
    if (article.userDigg) {
        [_digButton setEnabled:YES selected:YES];
        [_buryButton setEnabled:YES selected:NO];
    }
    else if (article.userBury) {
        [_digButton setEnabled:YES selected:NO];
        [_buryButton setEnabled:YES selected:YES];
    }
    else {
        [_digButton setEnabled:YES selected:NO];
        [_buryButton setEnabled:YES selected:NO];
    }
}

#pragma mark - layout

- (void)refreshUI
{
    _titleLabel.numberOfLines = _isUnfold?2:[self curScale];
    [self layoutVideoInfo];
    [self layoutActionButtons];
    
    if (self.intensifyAuthor) {
        self.height = _digButton.bottom + 10;
    } else {
        self.height = _digButton.bottom;
    }
    CGFloat h = [TTDeviceHelper ssOnePixel];
    self.bottomLine.frame = CGRectMake(0, self.height-h, self.width, h);
}

- (void)layoutVideoInfo
{
    CGFloat titleLabelWidth;
    if ([self shouldHideDetailButton]) {
        _detailButton.hidden = YES;
        _titleDetailButton.hidden = YES;
        titleLabelWidth = self.width - kVideoDetailItemCommonEdgeMargin * 2;
    }
    else {
        _detailButton.hidden = NO;
        _titleDetailButton.hidden = NO;
        if ([TTDeviceHelper isPadDevice]) {
            _detailButton.size = _detailButton.imageView.size;
        }
        _detailButton.origin = CGPointMake(self.width - _detailButton.width - kDetailButtonRightPadding, kVerticalEdgeMargin + (_titleLabel.font.pointSize - _detailButton.height)/2);
        if (self.intensifyAuthor) {
            _detailButton.top -= 10;
        }
        titleLabelWidth = self.width - kVideoDetailItemCommonEdgeMargin - kDetailButtonLeftSpace - _detailButton.width - kDetailButtonRightPadding;
    }
    
    CGFloat contentLabelwidth = self.width - 2 * kVideoDetailItemCommonEdgeMargin;

    NSInteger scale = [self curScale];
    
    CGSize titleLabelRealSize = [_titleLabel sizeThatFits:CGSizeMake(titleLabelWidth, _isUnfold?2*newkTitleLabelLineHeight: newkTitleLabelLineHeight*scale)];
    if (titleLabelRealSize.width > titleLabelWidth) {
        titleLabelRealSize.width = titleLabelWidth;
    }

    CGFloat contentLabelShowHeight = [self.contentLabel sizeThatFits:CGSizeMake(contentLabelwidth, 0)].height;
    
    CGFloat titleLabelTop = kVerticalEdgeMargin;
    if (self.intensifyAuthor) {
        titleLabelTop -= 10;
    }
    _titleLabel.frame = CGRectMake(kVideoDetailItemCommonEdgeMargin, titleLabelTop, titleLabelWidth, titleLabelRealSize.height);
    _titleDetailButton.frame = _titleLabel.frame;
    [_watchCountLabel sizeToFit];
    _watchCountLabel.origin = CGPointMake(kVideoDetailItemCommonEdgeMargin, _titleLabel.bottom + kTitleLabelBottomSpace);
    _recommendView.left = _watchCountLabel.right;
    _recommendView.width = self.width - _recommendView.left - kVideoDetailItemCommonEdgeMargin;
    _recommendView.height = _watchCountLabel.height;
    _recommendView.centerY = _watchCountLabel.centerY;
    
    _contentLabel.frame = CGRectMake(_titleLabel.left, _watchCountLabel.bottom + kWatchCountContentLabelSpace, contentLabelwidth, contentLabelShowHeight);
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
    CGFloat praiseButtonLeft = _shareButton.left + ([TTDeviceHelper isPadDevice] ? 114 : (_shareButton.width + 24));
    CGFloat linkButtonLeft = _buryButton.left + ([TTDeviceHelper isPadDevice] ? 114 : (_buryButton.width + 24));

    if (_shareButton) {
        _shareButton.origin = CGPointMake(shareButtonLeft, _digButton.top);
        linkButtonLeft = praiseButtonLeft;
        
        _videoExtendLinkButton.origin = CGPointMake(linkButtonLeft, _digButton.top);
        _weixin.hidden = YES;
        _weixinMoment.hidden = YES;
        _directShareLabel.hidden = YES;
        _shareButton.hidden = NO;

    }else{
        _videoExtendLinkButton.origin = CGPointMake(linkButtonLeft, _digButton.top);
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

- (void)doRotateDetailButtonAnimation
{
    [UIView animateWithDuration:0.1 animations:^{
        _detailButton.transform = CGAffineTransformRotate(_detailButton.transform, M_PI);
    } completion:nil];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    _titleLabel.textColor = SSGetThemedColorWithKey(kColorText1);
    _directShareLabel.textColor = SSGetThemedColorWithKey(kColorText1);
    _watchCountLabel.textColor = SSGetThemedColorWithKey(kColorText3);
    [self updatePublishInfoWithArticle:self.article];
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
    
    [self.shareButton setImage:[UIImage themedImageNamed:[self _shareImageIcon]] forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage themedImageNamed:[self _shareImageIcon]] forState:UIControlStateHighlighted];
    self.shareButton.imageSize = CGSizeMake(20.f, 20.f);
    
    [self.shareButton updateThemes];
    [self.shareButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateHighlighted];
    
    if(_weixin && _weixinMoment){
        [self addDirectShareButtons];
    }
    self.bottomLine.backgroundColorThemeName = kColorLine1;
}

#pragma mark - Actions

- (void)detailButtonPressed{
    _isUnfold = !_isUnfold;
    _contentLabel.hidden = !_contentLabel.hidden;
    [self doRotateDetailButtonAnimation];
    [self refreshUI];
    if (self.relayOutBlock) {
        self.relayOutBlock(NO);
    }
    if (_contentLabel.hidden) {
        wrapperTrackEvent(@"detail", @"detail_fold_content");
    }
    else {
        wrapperTrackEvent(@"detail", @"detail_unfold_content");
    }
}

- (void)digButtOnPressed:(id)sender {
    //赞和踩互斥
    if (_article.userBury) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经踩过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    
    if (!_article.userDigg) {
        //赞
        [_digButton doZoomInAndDisappearMotion];
        _article.userDigg = YES;
        _article.diggCount = _article.diggCount + 1;
        [_article save];
        //[[SSModelManager sharedManager] save:nil];
        
        @weakify(self);
        [_itemActionManager sendActionForOriginalData:_article adID:nil actionType:DetailActionTypeDig finishBlock:^(id userInfo, NSError *error) {
            @strongify(self);
            NSString *uniqueIDStr = [NSString stringWithFormat:@"%lld", self.article.uniqueID];
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggChanged:uniqueIDStr:), ttv_message_feedDiggChanged:YES uniqueIDStr:uniqueIDStr);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggCountChanged:uniqueIDStr:), ttv_message_feedDiggCountChanged:self.article.diggCount uniqueIDStr:uniqueIDStr);
        }];
        _digButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        _digButton.imageView.contentMode = UIViewContentModeCenter;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _digButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            _digButton.imageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self updateActionButtonsWithArticle:_article];
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                _digButton.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                _digButton.imageView.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }];
//        wrapperTrackEvent(@"xiangping", @"video_detail_digg");
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];
        
        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_detail_digg",nil,nil,dict);

    } else {
        //取消赞
        _article.userDigg = NO;
        _article.diggCount = MAX(0, _article.diggCount - 1);
        [_article save];
        
        [_itemActionManager sendActionForOriginalData:_article adID:nil actionType:DetailActionTypeUnDig finishBlock:^(id userInfo, NSError *error) {
        }];
        [self updateActionButtonsWithArticle:_article];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        NSString *user_id = [self.detailModel.article.userInfo tt_stringValueForKey:@"user_id"]? :[self.detailModel.article.mediaInfo tt_stringValueForKey:@"user_id"];
        [params setValue:user_id forKey:@"user_id"];
        [params setValue:@"detail" forKey:@"position"];
        [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
        [params setValue:self.detailModel.categoryID forKey:@"category_name"];
        [params setValue:self.detailModel.clickLabel forKey:@"enter_from"];
        [params setValue:[self.detailModel.statParams tt_stringValueForKey:@"card_id"] forKey:@"card_id"];
        [params setValue:[self.detailModel.statParams tt_stringValueForKey:@"card_position"] forKey:@"card_position"];
        [params setValue:self.detailModel.orderedData.groupSource forKey:@"group_source"];
        if (self.detailModel.orderedData.listLocation != 0) {
            [params setValue:@"main_tab" forKey:@"list_entrance"];
        }
        [params setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey: @"author_id"];
        [params setValue:@"video" forKey:@"article_type"];
        [TTTrackerWrapper eventV3:@"rt_unlike" params:params];
    }
}

- (void)buryButtonOnPressed:(id)sender {
    
    //赞和踩互斥
    if (_article.userDigg) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经赞过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    if (!_article.userBury) {
        [_buryButton doZoomInAndDisappearMotion];
        _article.userBury = YES;
        _article.buryCount = _article.buryCount + 1;
        [_article save];
        //[[SSModelManager sharedManager] save:nil];
        
        @weakify(self);
        [_itemActionManager sendActionForOriginalData:_article adID:nil actionType:DetailActionTypeBury finishBlock:^(id userInfo, NSError *error) {
            @strongify(self);
            NSString *uniqueIDStr = [NSString stringWithFormat:@"%lld", self.article.uniqueID];
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryChanged:uniqueIDStr:), ttv_message_feedBuryChanged:YES uniqueIDStr:uniqueIDStr);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryCountChanged:uniqueIDStr:), ttv_message_feedBuryCountChanged:self.article.buryCount uniqueIDStr:uniqueIDStr);
        }];
        _buryButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        _buryButton.imageView.contentMode = UIViewContentModeCenter;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _buryButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            _buryButton.imageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self updateActionButtonsWithArticle:_article];
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                _buryButton.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                _buryButton.imageView.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }];
//        wrapperTrackEvent(@"xiangping", @"video_detail_bury");
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];
        
        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_detail_bury",nil,nil,dict);
    } else {
        _article.userBury = NO;
        _article.buryCount = MAX(0, _article.buryCount - 1);
        [_article save];
        [_itemActionManager sendActionForOriginalData:_article adID:nil actionType:DetailActionTypeUnBury finishBlock:nil];
        [self updateActionButtonsWithArticle:_article];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        NSString *user_id = [self.detailModel.article.userInfo tt_stringValueForKey:@"user_id"]? :[self.detailModel.article.mediaInfo tt_stringValueForKey:@"user_id"];
        [params setValue:user_id forKey:@"user_id"];
        [params setValue:@"detail" forKey:@"position"];
        [params setValue:[self.detailModel.gdExtJsonDict valueForKey:@"log_pb"] forKey:@"log_pb"];
        [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
        [params setValue:self.detailModel.categoryID forKey:@"category_name"];
        [params setValue:self.detailModel.clickLabel forKey:@"enter_from"];
        [params setValue:[self.detailModel.statParams tt_stringValueForKey:@"card_id"] forKey:@"card_id"];
        [params setValue:[self.detailModel.statParams tt_stringValueForKey:@"card_position"] forKey:@"card_position"];
        [params setValue:self.detailModel.orderedData.groupSource forKey:@"group_source"];
        
        if (self.detailModel.orderedData.listLocation != 0) {
            [params setValue:@"main_tab" forKey:@"list_entrance"];
        }
        [params setValue:@"video" forKey:@"article_type"];
        [params setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];

        [TTTrackerWrapper eventV3:@"rt_unbury" params:params];
    }
    
}

- (void)actionButtonPressed:(id)sender
{
    if (_article.managedObjectContext == nil) {
        return;
    }
    
    if (sender == _digButton) {
        [self digButtOnPressed:_digButton];
        return;
    }
    
    if (sender == _buryButton) {
        [self buryButtonOnPressed:_buryButton];
        return;
    }
    
    
   if (sender == _videoExtendLinkButton) {
        if ([self.delegate respondsToSelector:@selector(extendLinkButton:clickedWithArticle:)]) {
            [self.delegate extendLinkButton:(UIButton *)_videoExtendLinkButton clickedWithArticle:self.article];
        }
        [self videoExtentActionlogV3];
    } if (sender == _shareButton){
        [TTTrackerWrapper eventV3:@"share_icon_click" params:@{@"icon_type": @([SSCommonLogic shareIconStye]).stringValue}];
        if ([self.delegate respondsToSelector:@selector(shareButton:clickedWithArticle:)]) {
            [self.delegate shareButton:(UIButton *)_shareButton clickedWithArticle:self.article];
        }
    }
}

- (void)directShareActionClicked:(id)sender
{    
    TTVideoShareThemedButton *btn = (TTVideoShareThemedButton *)sender;
    if ([self.delegate respondsToSelector:@selector(directShareActionClickedWithActivityType:)]) {
        [self.delegate directShareActionClickedWithActivityType:btn.activityType];
    }
}
- (void)logShowRecommentView:(NSArray *)models
{
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:self.article.itemID forKey:@"ext_value"];
    NSMutableArray *mediaIds = [NSMutableArray array];
    for (TTVideoRecommendModel *model in models) {
        [mediaIds addObject:model.mediaID];
    }
    NSString *mediaIdsStr = [mediaIds componentsJoinedByString:@","];
    [extra setValue:mediaIdsStr forKey:@"media_ids"];
    wrapperTrackEventWithCustomKeys(@"video", @"show_zz_comment", @(self.article.uniqueID).stringValue, nil, extra);
}

#pragma mark -- TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    NSDictionary *extra;
    NSURLComponents *com = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:nil];
    if ([com.scheme isEqualToString:@"bytedance"] && [com.host isEqualToString:@"keywords"]) { //
        NSDictionary *paras = [TTStringHelper parametersOfURLString:com.query];
        NSString *keyword = [paras stringValueForKey:@"keyword" defaultValue:nil];
        if (!isEmptyString(keyword)) {
            ExploreSearchViewController * searchController = [[ExploreSearchViewController alloc] initWithNavigationBar:YES showBackButton:YES queryStr:keyword fromType:ListDataSearchFromTypeTag];
            searchController.groupID = @(self.article.uniqueID);
            UINavigationController *rootController = [TTUIResponderHelper topNavigationControllerFor:self];
            [rootController pushViewController:searchController animated:YES];
            extra = @{ @"click_keyword" : keyword };
        }
    } else if ([com.scheme isEqualToString:@"sslocal"] && [com.host isEqualToString:@"detail"]) {
        NSDictionary *parameters = [TTStringHelper parametersOfURLString:com.query];
        NSString *groupID = [parameters objectForKey:@"groupid"];
        BOOL hasGroupID = !isEmptyString(groupID);
        BOOL canOpen = [[TTRoute sharedRoute] canOpenURL:url];
        if (hasGroupID && canOpen) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
        extra = @{ @"click_groupid" : groupID };
    } else {
        return ; //其他情况不做处理
    }
    
    [TTTrackerWrapper category:@"umeng" event:@"video" label:@"detail_abstract_click" dict:extra];
}

- (void)updateShareButtonWithText:(NSString *)shareText
{
    if (!isEmptyString(shareText)) {
        [self.shareButton setTitle:shareText];
    }
}
#pragma mark -- TTDetailNatantViewBase protcol implmenation
- (void)trackEventIfNeeded{
    
}

-(void)reloadData:(id)object{
    if (![object isKindOfClass:[ArticleInfoManager class]]) {
        return;
    }
    ArticleInfoManager * articleInfo = (ArticleInfoManager *)object;
    Article *article = articleInfo.detailModel.article;
    if (_delegate && [_delegate respondsToSelector:@selector(ttv_getSourceArticle)]) {
        article = [_delegate ttv_getSourceArticle];
    }
    NSString *content = article.detail.content;
    self.detailModel = articleInfo.detailModel;

    NSString *videoAbstract = articleInfo.videoAbstract;
    if (isEmptyString(content)) {
        content = @"";
    } else {
        content = [NSString stringWithFormat:@"%@\n", content];
    }
    if (isEmptyString(videoAbstract)) {
        videoAbstract = @"";
    }
    self.abstractString = [NSString stringWithFormat:@"%@%@",content,videoAbstract];
    [self refreshWithArticle:article];
}

#pragma mark - Helper

- (NSInteger)curScale {
    return 2;
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
    return [SSUserSettingManager detailVideoContentFontSize];
}

+ (CGFloat)watchCountLabelFontSize
{
    return [SSUserSettingManager detailVideoContentFontSize];
}

+ (CGFloat)digBurySpace
{
    return 30;
}

+ (float)setTitleLineHeight{
    float fontHeight = [TTVideoFontSizeManager settedTitleFontSize];
    return fontHeight + 4;
}

- (void) setIsShowShare:(BOOL)isShowShare{
    _isShowShare = isShowShare;
}

- (void) addShareButton
{
    if (!_shareButton) {
        _shareButton = [[ArticleVideoActionButton alloc] init];
        _shareButton.disableRedHighlight = YES;
        _shareButton.maxWidth = 62.0f;
        [_shareButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
        _shareButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [self addSubview:_shareButton];
    }
    [self updateShareButtonWithText:@"分享"];
    [_shareButton addTarget:self.actionButtonDelegate action:@selector(actionButtonPressed:)];
    [self layoutActionButtons];
}

- (void)addDirectShareButtons
{
    NSArray *activitySequenceArr;
    if (!ttvs_isShareIndividuatioEnable()) {
        activitySequenceArr = @[@(TTActivityTypeWeixinMoment), @(TTActivityTypeWeixinShare)];
    }else{
        activitySequenceArr = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareActivitySequence];
    }
    
    if (activitySequenceArr.count > 0) {
        
        if (!_directShareLabel) {
            _directShareLabel = [[SSThemedLabel alloc] init];
            _directShareLabel.text = NSLocalizedString(@"分享到", nil);
            _directShareLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
            [_directShareLabel sizeToFit];
            [self addSubview:_directShareLabel];
        }

        int hasbutton = 0;
        for (int i = 0; i < activitySequenceArr.count; i++){
            
            id obj = [activitySequenceArr objectAtIndex:i];
            if ([obj isKindOfClass:[NSNumber class]]) {
                TTActivityType objType = [obj integerValue];
                if (objType == TTActivityTypeDingTalk || objType == TTActivityTypeWeitoutiao) {
                    continue;
                }
                UIImage *img = [self activityImageNameWithActivity:objType];
                NSString *title = [self activityTitleWithActivity:objType];
                if (_weixinMoment && _weixin) {
                    if (hasbutton == 0) {
                        _weixinMoment.iconImage.image = img;
                        _weixinMoment.nameLabel.text = title;
                        _weixinMoment.activityType = [TTActivityShareSequenceManager activityStringTypeFromActivityType:objType];
                    }else{
                        _weixin.iconImage.image = img;
                        _weixin.nameLabel.text = title;
                        _weixin.activityType = [TTActivityShareSequenceManager activityStringTypeFromActivityType:objType];

                    }
                }
                else{
                    TTVideoShareThemedButton *button = [self cellViewWithIndex:hasbutton image:img title:title];
                    [self addSubview:button];
                    button.activityType = [TTActivityShareSequenceManager activityStringTypeFromActivityType:objType];
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

- (TTVideoShareThemedButton *)cellViewWithIndex:(int)index image:(UIImage *)image title:(NSString *)title
{
    CGRect frame;
    TTVideoShareThemedButton *view = nil;
    frame = CGRectMake(index*kVideoDirectShareButtonWidth, 0, kVideoDirectShareButtonWidth, kVideoDirectShareButtonWidth);
    view = [[TTVideoShareThemedButton alloc] initWithFrame:frame index:index image:image title:title needLeaveWhite:NO];//需要显示nameLabel
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    [view addTarget:self action:@selector(directShareActionClicked:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}

- (UIImage *)activityImageNameWithActivity:(TTActivityType)itemType
{
    UIImage *image = nil;
    if (itemType == TTActivityTypeWeixinShare){
        image = [UIImage imageNamed:@"video_center_share_weChat"];
    }else if (itemType == TTActivityTypeWeixinMoment){
        image = [UIImage imageNamed:@"video_center_share_pyq"];
    }else if (itemType == TTActivityTypeQQZone){
        image = [UIImage imageNamed:@"video_center_share_qzone"];
    }else if (itemType == TTActivityTypeQQShare){
        image = [UIImage imageNamed:@"video_center_share_qq"];
    }else if (itemType == TTActivityTypeDingTalk){
        image = [UIImage imageNamed:@"video_center_share_ding"];
    }else {
//        UIImage * dayImage = [[TTWeitoutiaoRepostIconDownloadManager sharedManager] getWeitoutiaoRepostDayIcon];
//        if (nil == dayImage) {
//            //使用本地图片
            image = [UIImage imageNamed:@"video_center_share_weitoutiao"];
//        }else {
//            //网络图片已下载
//            image = dayImage;
//        }
    }

    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        image = [self imageByApplyingAlpha:0.5 image:image];
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

- (NSString *)activityTitleWithActivity:(TTActivityType )itemType
{
    if (itemType == TTActivityTypeWeixinShare){
        return @"微信";
    }else if (itemType == TTActivityTypeWeixinMoment){
        return @"朋友圈";
    }else if (itemType == TTActivityTypeQQZone){
        return @"QQ空间";
    }else if (itemType == TTActivityTypeQQShare){
        return @"QQ";
    }else if (itemType == TTActivityTypeDingTalk){
        return @"钉钉";
    }else {
        return [TTKitchen getString:kKCUGCRepostWordingShareIconTitle];
    }
}


- (void)setArticle:(Article *)article{
    if (_article != article) {
        [_article removeObserver:self forKeyPath:@"diggCount"];
        [_article removeObserver:self forKeyPath:@"buryCount"];
        _article = article;
        [_article addObserver:self forKeyPath:@"diggCount" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        [_article addObserver:self forKeyPath:@"buryCount" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma  mark KVO 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == _article && ( [keyPath isEqualToString:@"diggCount"] || [keyPath isEqualToString:@"buryCount"] )) {
        
        int newNum = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        int oldNum = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
        LOGD(@"CellView KVO: %p %@", object, keyPath);
//        if (!newNum){
//            return;
//        }
        [self updateActionButtonsWithArticle:_article];
    }
}

- (NSString *)_shareImageIcon {
    switch ([SSCommonLogic shareIconStye]) {
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

- (void)videoExtentActionlogV3{
    NSMutableDictionary *event3Dic = [NSMutableDictionary dictionary];
    [event3Dic setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [event3Dic setValue:self.detailModel.article.mediaInfo[@"media_id"] forKey:@"media_id"];
    NSString *enterFrom = self.detailModel.clickLabel;
    NSString *categoryName = self.detailModel.categoryID;
    if (![enterFrom isEqualToString:@"click_headline"]) {
        if (self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat || self.detailModel.fromSource == NewsGoDetailFromSourceCategory)
        {
            enterFrom = @"click_category";
        }
        else if (self.detailModel.fromSource == NewsGoDetailFromSourceClickTodayExtenstion) {
            enterFrom = @"click_widget";
        }
        if ([categoryName hasPrefix:@"_"]) {
            categoryName = [categoryName substringFromIndex:1];
        }
    }
    if (!categoryName || [categoryName isEqualToString:@"xx"]) {
        categoryName = [enterFrom stringByReplacingOccurrencesOfString:@"click_" withString:@""];
    }
    [event3Dic setValue:categoryName forKey:@"category_name"];
    [event3Dic setValue:enterFrom forKey:@"enter_from"];
    if (!self.detailModel.logPb){
        [event3Dic setValue:self.detailModel.logPb forKey:@"log_pb"];
    }else{
        [event3Dic setValue:self.detailModel.gdExtJsonDict[@"log_pb"] forKey:@"log_pb"];
    }
    [TTTrackerWrapper eventV3:@"detail_click_landingpage" params:event3Dic];
}

#pragma mark - TTActivityShareSequenceChangedMessage

- (void)message_shareActivitySequenceChanged{
    if (self.weixinMoment && self.weixin) {
        [self addDirectShareButtons];
    }
}

@end

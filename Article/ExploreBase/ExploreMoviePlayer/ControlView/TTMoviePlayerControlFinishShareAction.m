//
//  TTMoviePlayerControlFinishShareAction.m
//  Article
//
//  Created by lishuangyang on 2017/7/5.
//
//

#import "TTMoviePlayerControlFinishShareAction.h"

#import "TTAlphaThemedButton.h"
#import "TTVideoShareThemedButton.h"
//#import "TTWeitoutiaoRepostIconDownloadManager.h"
#import "TTActivityShareSequenceManager.h"
#import "TTMessageCenter.h"
#import "TTKitchenHeader.h"

static const CGFloat kPrePlayBtnBottom = 11.5;

extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;

#define kFRPanelCellWidth          44
#define kFRPanelSingleCellHeight   65
#define kSCreenSizeWidth fminf([TTUIResponderHelper screenSize].width, [TTUIResponderHelper screenSize].height)
#define KShareItemsPadding (([TTDeviceHelper is736Screen]) ? 24 : (0.053 * (kSCreenSizeWidth)))

#define KshareItemsGroupWith       (3 * KShareItemsPadding + 4 * kFRPanelCellWidth)

extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern BOOL ttvs_isShareIndividuatioEnable(void);

@interface TTMoviePlayerControlFinishShareAction ()<TTActivityShareSequenceChangedMessage>

@property (nonatomic, weak) UIView *baseView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) SSThemedLabel *shareLabel;
@property (nonatomic, strong) SSThemedView *leftLine;
@property (nonatomic, strong) SSThemedView *rightLine;

@property (nonatomic, assign) CGFloat bannerHeight; // 兼容banner出现的情况

@end

@interface TTMoviePlayerControlFinishShareAction ()
{
    CGFloat _cellWidth;
}
@end

@implementation TTMoviePlayerControlFinishShareAction

- (void)dealloc{
    UNREGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
}

- (instancetype)initWithBaseView:(UIView *)baseView {
    self = [super init];
    if (self) {
        REGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
        _cellWidth = kFRPanelCellWidth;
        _baseView = baseView;
        _bannerHeight = 0;
        //背景view
        _backView = [[UIView alloc] initWithFrame:_baseView.bounds];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        [_baseView addSubview:_backView];
        
        _containerView = [[UIView alloc] initWithFrame:_backView.bounds];
        [_backView addSubview:_containerView];
        
        _shareLabel = [[SSThemedLabel alloc] init];
        _shareLabel.text = NSLocalizedString(@"分享到", nil);
        _shareLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _shareLabel.textColor = [UIColor tt_defaultColorForKey:kColorText9];
//        _shareLabel.alpha = 0.8;
        [_shareLabel sizeToFit];
        
        _leftLine = [[SSThemedView alloc] init];
        _leftLine.backgroundColor = [UIColor whiteColor];
        _leftLine.alpha = 0.3;
        _leftLine.size = CGSizeMake(32.f, 1.f);
        
        _rightLine = [[SSThemedView alloc] init];
        _rightLine.backgroundColor = [UIColor whiteColor];
        _rightLine.alpha = 0.3;
        _rightLine.size = CGSizeMake(32.f, 1.f);
        
        [_containerView addSubview:_shareLabel];
        [_containerView addSubview:_leftLine];
        [_containerView addSubview:_rightLine];
        //重播按钮
        [_containerView addSubview:self.replayBtn];
        [_containerView addSubview:self.moreButton];
        [self themeChanged:nil];
        
    }
    return self;
}

- (void)refreshSubViews:(BOOL)hasFinished {
    self.backView.hidden = !hasFinished;
    self.replayBtn.hidden = !hasFinished;
}

- (void)layoutSubviews {
    
    [self refreshShareItemButtons];
    
    _backView.frame = _baseView.bounds;
    _containerView.frame = _backView.frame;
    _containerView.height -= _bannerHeight;
    CGRect frame = _containerView.frame;
    _replayBtn.bottom = CGRectGetHeight(frame) - ((_bannerHeight > 0) ? 8 : kPrePlayBtnBottom);
    _shareLabel.centerX = CGRectGetWidth(frame)/2;
    _leftLine.right = _shareLabel.left - 8;
    _rightLine.left = _shareLabel.right + 8;
    self.moreButton.centerY = 22;
    CGFloat originHeight = _replayBtn.top;
    CGFloat shareLabelY = (originHeight - kFRPanelSingleCellHeight - 12 - _shareLabel.height)/2;
    if (_isIndetail) {
        shareLabelY += self.tt_safeAreaInsets.top;
    }
    CGFloat pointY = shareLabelY + 12 + _shareLabel.height;
    for (TTVideoShareThemedButton *sub in _containerView.subviews) {
        if ([sub isKindOfClass:[TTVideoShareThemedButton class]]) {
            CGFloat pointX = frame.size.width/2 - KshareItemsGroupWith/2 + sub.index*(kFRPanelCellWidth + KShareItemsPadding);
            pointX = ceilf(pointX);
            sub.frame = CGRectMake(pointX, pointY, kFRPanelCellWidth, kFRPanelSingleCellHeight);
            if (_bannerHeight > 0) {
                sub.nameLabel.hidden = YES;
            }
        }
    }
    _shareLabel.top = shareLabelY;
    _leftLine.centerY = _shareLabel.centerY;
    _rightLine.centerY = _leftLine.centerY;
}

- (void)updateFinishActionItemsFrameWithBannerHeight:(CGFloat)height {
    
    _bannerHeight = height;
    
    [self layoutSubviews];
}

- (TTAlphaThemedButton *)replayBtn {
    
    if (!_replayBtn) {
        
        UIImage *img =[UIImage imageNamed: @"replay_small"];
        _replayBtn = [[TTAlphaThemedButton alloc] init];
        _replayBtn.enabled = YES;
        _replayBtn.frame = CGRectMake(12, _containerView.height - kPrePlayBtnBottom - img.size.height, img.size.width, img.size.height);
        _replayBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        UIImage *replayImg = [self imageByApplyingAlpha:0.8 image:img];
        [_replayBtn setImage:replayImg forState:UIControlStateNormal];
        [_replayBtn setTitle:NSLocalizedString(@"重播", nil) forState:UIControlStateNormal];
        _replayBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.f];
        [_replayBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText9] forState:UIControlStateNormal];
        [_replayBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText9Highlighted] forState:UIControlStateHighlighted];
        [_replayBtn layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:2.f];
        [_replayBtn sizeToFit];
    }
    return _replayBtn;
}

- (TTAlphaThemedButton *)moreButton {
    
    if (ttvs_isVideoShowOptimizeShare() == 0) {
        
        return nil;
    }
    
    if (!_moreButton) {
        
        _moreButton = [[TTAlphaThemedButton alloc] init];
        _moreButton.right = self.containerView.width - 36;
        _moreButton.width = 24.f;
        _moreButton.height = 24.f;
        _moreButton.imageView.center = CGPointMake(_moreButton.frame.size.width/2, _moreButton.frame.size.height/2);
        _moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [_moreButton setImage:[UIImage imageNamed:@"new_morewhite_titlebar"] forState:UIControlStateNormal];
        [_moreButton sizeToFit];
    }
    
    return _moreButton;
}

- (void)refreshShareItemButtons
{
    NSArray *activitySequenceArr;
    if (!ttvs_isShareIndividuatioEnable()) {
        activitySequenceArr = @[@(TTActivityTypeWeixinMoment), @(TTActivityTypeWeixinShare), @(TTActivityTypeQQShare), @(TTActivityTypeQQZone)];
    }else{
        activitySequenceArr = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareActivitySequence];
    }
    
    if (activitySequenceArr.count > 0) {
        
        int hasbutton = 0;
        for (int i = 0; i < activitySequenceArr.count; i++){
            
            id obj = [activitySequenceArr objectAtIndex:i];
            if ([obj isKindOfClass:[NSNumber class]]) {
                TTActivityType objType = [obj integerValue];
                if (objType == TTActivityTypeDingTalk || objType == TTActivityTypeWeitoutiao) {
                    continue;
                }
                NSString *activityType = [TTActivityShareSequenceManager activityStringTypeFromActivityType:objType];
                UIImage *img = [self activityImageNameWithActivity:activityType];
                NSString *title = [self activityTitleWithActivity:activityType];
                if ([_shareItemButtons count] > 3) {
                    TTVideoShareThemedButton *button = (TTVideoShareThemedButton *)_shareItemButtons[hasbutton];
                    button.iconImage.image = img;
                    button.nameLabel.text = title;
                    button.activityType = activityType;
                }
                else{
                    TTVideoShareThemedButton *button = [self cellViewWithIndex:hasbutton image:img title:title];
                    [_containerView addSubview:button];
                    [self.shareItemButtons addObject:button];
                    button.activityType = activityType;
                }
                hasbutton++;
                if (hasbutton == 4) {
                    break;
                }
            }

        }
    }
}

- (NSMutableArray *)shareItemButtons{
    if (!_shareItemButtons) {
        _shareItemButtons = [NSMutableArray array];
    }
    return _shareItemButtons;
}

- (TTVideoShareThemedButton *)cellViewWithIndex:(int)index image:(UIImage *)image title:(NSString *)title{
    CGRect frame;
    TTVideoShareThemedButton *view = nil;
    frame = CGRectMake(index*_cellWidth, 0, kFRPanelCellWidth, kFRPanelSingleCellHeight);
    view = [[TTVideoShareThemedButton alloc] initWithFrame:frame index:index image:image title:title needLeaveWhite:YES];//需要显示nameLabel
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}

- (void)buttonClickAction:(TTVideoShareThemedButton *)sender{
    if (self.shareClicked) {
        self.shareClicked(sender.activityType);
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
}

- (NSString *)activityTitleWithActivity:(NSString *)itemType{
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


- (UIImage *)activityImageNameWithActivity:(NSString *)itemType{
    if ([itemType isEqualToString:TTActivityContentItemTypeWechat]){
        return [UIImage imageNamed:@"weixin_allshare"];
    }else if ([itemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        return [UIImage imageNamed:@"pyq_allshare"];
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQZone]){
        return [UIImage imageNamed:@"qqkj_allshare"];
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQFriend]){
        return [UIImage imageNamed:@"qq_allshare"];
    }
//    else if ([itemType isEqualToString:TTActivityContentItemTypeDingTalk]){
//        return [UIImage imageNamed:@"dingding_allshare"];
//    }
    else {
//        UIImage * dayImage = [[TTWeitoutiaoRepostIconDownloadManager sharedManager] getWeitoutiaoRepostDayIcon];
//        if (nil == dayImage) {
//            //使用本地图片
            return [UIImage imageNamed:@"share_toutiaoweibo"];
//        }else {
//            //网络图片已下载
//            return dayImage;
//        }
    }
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


#pragma  mark - TTActivityShareSequenceChangedMessage

- (void)message_shareActivitySequenceChanged{
    [self refreshShareItemButtons];
}

@end

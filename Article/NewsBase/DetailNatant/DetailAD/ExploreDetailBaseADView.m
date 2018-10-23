//
//  ExploreDetailBaseADView.m
//  Article
//
//  Created by SunJiangting on 15/7/21.
//
//

#import "ExploreDetailBaseADView.h"

#import "DetailActionRequestManager.h"
#import "SSThemed.h"
#import "TTAdCallManager.h"
#import "TTAdManager.h"
#import "TTAdManagerProtocol.h"
#import "TTAdMonitorManager.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "TTFeedDislikeView.h"
#import "TTGuideDispatchManager.h"
#import "TTIndicatorView.h"
#import "TTPlatformSwitcher.h"
#import "TTStringHelper.h"
#import "TTThemedAlertController.h"
#import "TTTrackerWrapper.h"
#import "TTUIResponderHelper.h"
#import "UIColor+TTThemeExtension.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTTrackerWrapper.h"
#import "TTURLUtils.h"
#import "TTRoute.h"
#import "TTAdAction.h"
#import "JSONAdditions.h"

@interface ExploreDetailBaseADView ()

@property (nonatomic, strong) UIButton *bgButton;

@end

@implementation ExploreDetailBaseADView

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        [self addSubview:self.bgButton];
        
        self.clipsToBounds = YES;
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.borderColorThemeKey = kColorLine1;
        
        [self reloadThemeUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithWidth:[UIScreen mainScreen].bounds.size.width];
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width {
    return 0;
}

- (void)didSendShowEvent {
    
}

- (void)didSendClickEvent {
    
}

- (void)scrollInOrOutBlock:(BOOL)isVisible {
    
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.borderColorThemeKey = kColorLine1;
}

#pragma mark - Action Route

- (void)sendActionForTapEvent {
    if ([self.delegate respondsToSelector:@selector(detailBaseADView:didClickWithModel:)]) {
        [self.delegate detailBaseADView:self didClickWithModel:self.adModel];
    }
}

- (void)sendAction:(UIControl *)sender {
    if (self.adModel.detailADType == ArticleDetailADModelTypeCounsel) {
        [self actionForCounsel:self.adModel];
    } else if (self.adModel.detailADType == ArticleDetailADModelTypeAppoint) {
        [self appointActionWithADModel:self.adModel];
    } else if (self.adModel.detailADType == ArticleDetailADModelTypePhone) {
        [self callActionWithADModel:self.adModel];
    } else if (self.adModel.detailADType == ArticleDetailADModelTypeApp) {
        [self actionForAppDownload:self.adModel];
    }
}

- (void)bgButtonPressed:(id)sender {
     [self sendActionForTapEvent];
}

- (void)actionForCounsel:(ArticleDetailADModel *)model {
    if (isEmptyString(model.formUrl)) {
        [TTAdMonitorManager trackService:@"ad_article_detail" status:1 extra:model.monitorInfo];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:model.formUrl forKey:@"url"];
    [params setValue:model.webTitle forKey:@"title"];
    [params setValue:model.ad_id forKey:@"ad_id"];
    [params setValue:model.log_extra forKey:@"log_extra"];
    NSURL *schema = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:params];
    if ([[TTRoute sharedRoute] canOpenURL:schema]) {
        [[TTRoute sharedRoute] openURLByPushViewController:schema];
    }
    
    [model sendTrackEventWithLabel:@"click" eventName:@"detail_counsel"];
    [model sendTrackEventWithLabel:@"click_counsel" eventName:@"detail_counsel"];
}

- (void)actionForAppDownload:(ArticleDetailADModel *)model {
    [self sendActionForTapEvent];
    [model trackWithTag:@"detail_download_ad" label:@"click_start" extra:nil];
}

#pragma mark - Property

- (TTAlphaThemedButton*)dislikeView
{
    if (!_dislikeView) {
        _dislikeView = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _dislikeView.imageName = [self dislikeImageName];
        [_dislikeView addTarget:self action:@selector(dislikeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dislikeView;
}

- (UIButton *)bgButton {
    if (!_bgButton) {
        _bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgButton.frame = self.frame;
        _bgButton.backgroundColor = [UIColor clearColor];
        _bgButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_bgButton addTarget:self action:@selector(bgButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgButton;
}

#pragma mark - dislike

- (NSString*)dislikeImageName
{
    return @"";
}

- (void)dislikeButtonClicked:(UIButton*)button
{
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = self.adModel.filterWords;
    viewModel.groupID = self.adModel.ad_id;
    viewModel.logExtra = self.adModel.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = self.dislikeView.center;
    [dislikeView showAtPoint:point
                    fromView:self.dislikeView
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)view];
             }];
    [self.adModel trackWithTag:@"embeded_ad" label:@"dislike" extra:nil];
}

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)view
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(dislikeClick:)]) {
        [self.delegate dislikeClick:self.adModel];
    }
    NSMutableDictionary *extra = [@{} mutableCopy];
    [extra setValue:view.selectedWords forKey:@"filter_words"];
    [self.adModel trackWithTag:@"embeded_ad" label:@"final_dislike" extra:@{@"ad_extra_data": [extra tt_JSONRepresentation]}];
    //详情页广告dislike groupid传广告的adid
    NSString* groupId = self.adModel.ad_id;
    NSString* ad_id = self.adModel.ad_id;
    NSMutableDictionary* adExtra = [NSMutableDictionary dictionary];
    [adExtra setValue:self.adModel.log_extra forKey:@"log_extra"];
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:groupId itemID:self.viewModel.article.groupModel.itemID impressionID:groupId aggrType:0];
    DetailActionRequestManager *actionManager = [[DetailActionRequestManager alloc] init];
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = groupModel;

    if (view.selectedWords.count > 0) {
        context.filterWords = view.selectedWords;
    }
    context.dislikeSource = @"1";
    context.adID = ad_id;
    context.adExtra = adExtra;
    [actionManager setContext:context];
    [actionManager startItemActionByType:DetailActionTypeNewVersionDislike];
}

@end

@implementation ExploreDetailBaseADView (ExploreADLabel)

+ (void)updateADLabel:(SSThemedLabel *)adLabel withADModel:(ArticleDetailADModel *)adModel {
    
    adLabel.textAlignment = NSTextAlignmentCenter;
    adLabel.font = [UIFont systemFontOfSize:10.f];
    adLabel.text = isEmptyString(adModel.labelString) ? NSLocalizedString(@"广告", @"广告") : adModel.labelString;
    adLabel.size = CGSizeMake(26.f, 14.f);
    adLabel.layer.cornerRadius = 3.f;
    adLabel.clipsToBounds = YES;
    adLabel.textColorThemeKey = kColorText12;
    adLabel.backgroundColorThemeKey = kColorBackground15;
}

@end

@implementation ExploreDetailBaseADView (DetailCallAction)

- (void)callActionWithADModel:(ArticleDetailADModel *)adModel {
    NSString *phoneNumber = adModel.mobile;
    [self listenCall:adModel];
    [TTAdCallManager callWithNumber:phoneNumber];
    [self sendPhoneCallClickTrackWithADModel:adModel];
}

//监听电话状态
- (void)listenCall:(ArticleDetailADModel*)adModel
{
    TTAdCallListenModel* callModel = [[TTAdCallListenModel alloc] init];
    callModel.ad_id = adModel.ad_id;
    callModel.log_extra = adModel.log_extra;
    callModel.position = @"detail_call";
    callModel.dailTime = [NSDate date];
    callModel.dailActionType = adModel.dailActionType;
    [TTAdManageInstance call_callAdModel:callModel];
}

- (void)sendPhoneCallClickTrackWithADModel:(ArticleDetailADModel *)adModel
{
    [adModel sendTrackEventWithLabel:@"click" eventName:@"detail_call"];
    [adModel sendTrackEventWithLabel:@"click_call" eventName:@"detail_call"];
}

@end

@implementation ExploreDetailBaseADView (AppointFormAction)

- (void)appointActionWithADModel:(nullable ArticleDetailADModel *)adModel
{
    TTAdAppointAlertModel* model = [[TTAdAppointAlertModel alloc]initWithAdId:adModel.ad_id logExtra:adModel.log_extra formUrl:adModel.formUrl width:adModel.formWidth height:adModel.formHeight sizeValid:adModel.formSizeValid];
    if (isEmptyString(adModel.formUrl)) {
        return;
    }
    [TTAdAction handleFormActionModel:model fromSource:TTAdApointFromSourceDetail completeBlock:^(TTAdApointCompleteType type) {
        if (type == TTAdApointCompleteTypeCloseForm) {
            [adModel sendTrackEventWithLabel:@"click_cancel" eventName:@"detail_form"];
        }
        else if (type == TTAdApointCompleteTypeLoadFail){
            [adModel sendTrackEventWithLabel:@"load_fail" eventName:@"detail_form"];
        }
    }];
    
    [adModel sendTrackEventWithLabel:@"click" eventName:@"detail_form"];
    [adModel sendTrackEventWithLabel:@"click_button" eventName:@"detail_form"];

}

@end

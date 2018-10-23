//
//  TTMessageNotificationWDInviteCell.m
//  Article
//
//  Created by 邱鑫玥 on 2017/4/11.
//
//

#import "TTMessageNotificationWDInviteCell.h"
#import "TTMessageNotificationModel.h"
#import "TTAsyncCornerImageView.h"
#import "TTUserInfoView.h"
#import "TTLabelTextHelper.h"
#import "TTMessageNotificationCellHelper.h"
#import "FRButtonLabel.h"
#import "TTRoute.h"
#import <TTImage/TTImageView.h>
#import "SSWebViewController.h"
#import <WDDislikeView.h>
#import <TTBaseLib/JSONAdditions.h>
#import "TTMessageNotificationMacro.h"
#import <WDSettingHelper.h>
#import <WDFontDefines.h>
#import <WDCommonLogic.h>

NS_INLINE CGFloat kWDInviteBottomViewHeight(){
    return [TTMessageNotificationCellHelper tt_newPadding:16.5f];
}

NS_INLINE CGFloat kWDInviteBottomViewTopPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:7.f];
}

NS_INLINE CGFloat kWDInviteBottomViewLeftPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:61.f];
}

NS_INLINE CGFloat kWDInviteBottomViewRightPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:15.f];
}

NS_INLINE CGFloat kWDInviteBottomViewBottomPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:12.f];
}

NS_INLINE CGFloat kWDInviteLabelFontSize(){
    return [TTMessageNotificationCellHelper tt_newFontSize:12.f];
}

NS_INLINE CGFloat kWDInviteLabelPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:10.f];
}

NS_INLINE CGFloat kActionTextLabelLeftPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:7.f];
}

NS_INLINE CGFloat kDislikeNewStyleTitleFontSize(){
    return [TTMessageNotificationCellHelper tt_newPadding:12.0f];
}

//NS_INLINE CGFloat kActionTextLabelHieght(){
//    return [TTMessageNotificationCellHelper tt_newPadding:16.5f];
//}

NS_INLINE CGFloat kActionTextLabelFontSize(){
    return [TTMessageNotificationCellHelper tt_newFontSize:12.f];
}

NS_INLINE CGFloat kWDRewardIconImageViewHeight(){
    return [TTMessageNotificationCellHelper tt_newPadding:20.0f];
}

NS_INLINE CGFloat kWDRewardLabelFontSize(){
    return [TTMessageNotificationCellHelper tt_newFontSize:14.f];
}

NS_INLINE CGFloat kWDMonwyLabelFontSize(){
    return [TTMessageNotificationCellHelper tt_newFontSize:10.f];
}

NS_INLINE CGFloat kWDRewardBottomViewTopPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:10.f];
}

@implementation TTMessageNotificationWDInviteCell

+ (Class)cellViewClass{
    return [TTMessageNotificationWDInviteCellView class];
}

@end

@interface TTMessageNotificationWDInviteCellView()

@property (nonatomic, strong) SSThemedView  *wdInviteBottomView;
@property (nonatomic, strong) FRButtonLabel *wdInviteLabel;
@property (nonatomic, strong) SSThemedLabel *wdInviteExtraLabel;
@property (nonatomic, strong) SSThemedLabel *actionTextLabel;
@property (nonatomic, strong) SSThemedButton *wdDislikeBtn;
@property (nonatomic, strong) SSThemedButton *wdDislikeTextBtn;

@property (nonatomic, strong) SSThemedView *rewardView;
@property (nonatomic, strong) TTImageView *rewardIconImageView;
@property (nonatomic, strong) SSThemedLabel *rewardLabel;
@property (nonatomic, strong) SSThemedLabel *moneyLabel;

@end

@implementation TTMessageNotificationWDInviteCellView

+ (CGFloat)heightForData:(TTMessageNotificationModel *)data cellWidth:(CGFloat)width{
    if ([data.cachedHeight floatValue] > 0){
        return [data.cachedHeight floatValue];
    }
    CGFloat height = 0.f;
    
    height += TTMNRoleInfoViewTopPadding();
    height += TTMNRoleInfoViewHeight();
    
    if(!isEmptyString(data.user.contactInfo)){
        height += TTMNContactInfoLabelTopPadding();
        height += TTMNContactInfoLabelHeight();
    }
    
    height += TTMNBodyTextLabelTopPadding();
    height += [self heightForBodyTextLabelWithData:data maxWidth:width - TTMNBodyTextLabelLeftPadding() - TTMNBodyTextLabelDefaultRightPadding()];
    
    height += kWDInviteBottomViewTopPadding();
    
    height += kWDInviteBottomViewHeight();
    
    height = MAX(height, TTMNAvatarImageViewSize() + TTMNAvatarImageViewTopPadding());
    
    height += kWDInviteBottomViewBottomPadding();
    
    if (data.content.profit && [[WDSettingHelper sharedInstance_tt] isQuestionRewardUserViewShow]) {
        height += kWDRewardBottomViewTopPadding();
        height += kWDRewardIconImageViewHeight();
    }
    
    data.cachedHeight = @(height);
    
    return height;
}

- (FRButtonLabel *)wdInviteLabel{
    if(!_wdInviteLabel){
        _wdInviteLabel = [[FRButtonLabel alloc] initWithFrame:CGRectZero];
        _wdInviteLabel.font = [UIFont systemFontOfSize:kWDInviteLabelFontSize()];
        _wdInviteLabel.textColorThemeKey = kColorText5;
        _wdInviteLabel.numberOfLines = 1;
        _wdInviteLabel.textAlignment = NSTextAlignmentLeft;
        _wdInviteLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        WeakSelf;
        _wdInviteLabel.tapHandle = ^{
            StrongSelf;
            NSString *schema = self.messageModel.content.gotoUrl;
            NSString *qid = nil;
            NSString *lastString = [[schema componentsSeparatedByString:@"&"] lastObject];
            if ([lastString containsString:@"qid"]) {
                qid = [[lastString componentsSeparatedByString:@"="] lastObject];
            }
            schema = [schema stringByAppendingString:@"&source=notice_invite_write_answer"];
            NSURL *url = [TTStringHelper URLWithURLString:schema];
            NSString *URLString = url.absoluteString;
            if([[TTRoute sharedRoute] canOpenURL:url]){
                [[TTRoute sharedRoute] openURLByViewController:url userInfo:nil];
            }
            else if ([URLString hasPrefix:@"http://"] || [URLString hasPrefix:@"https://"]) {
                UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
                ssOpenWebView(url, @"", topController.navigationController, NO, nil);
            }
            else if([[UIApplication sharedApplication] canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url];
            }
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            if (!isEmptyString(qid)) {
                [params setValue:qid forKey:@"qid"];
            }
            [TTTracker eventV3:@"notice_invite_write_answer" params:params];
        };
    }
    return _wdInviteLabel;
}

- (SSThemedLabel *)wdInviteExtraLabel{
    if(!_wdInviteExtraLabel){
        _wdInviteExtraLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _wdInviteExtraLabel.font = [UIFont systemFontOfSize:kWDInviteLabelFontSize()];
        _wdInviteExtraLabel.textColorThemeKey = kColorText3;
        _wdInviteExtraLabel.numberOfLines = 1;
        _wdInviteExtraLabel.textAlignment = NSTextAlignmentLeft;
        _wdInviteExtraLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _wdInviteExtraLabel;
}

- (SSThemedView *)wdInviteBottomView{
    if(!_wdInviteBottomView){
        _wdInviteBottomView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        [_wdInviteBottomView addSubview:self.wdInviteLabel];
        [_wdInviteBottomView addSubview:self.wdInviteExtraLabel];
        [self addSubview:_wdInviteBottomView];
    }
    return _wdInviteBottomView;
}

- (SSThemedLabel *)actionTextLabel{
    if(!_actionTextLabel){
        _actionTextLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _actionTextLabel.font = [UIFont systemFontOfSize:kActionTextLabelFontSize()];
        _actionTextLabel.textColorThemeKey = kColorText3;
        _actionTextLabel.numberOfLines = 1;
        _actionTextLabel.textAlignment = NSTextAlignmentLeft;
        _actionTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_actionTextLabel];
    }
    return _actionTextLabel;
}

- (SSThemedButton *)wdDislikeBtn {
    if (!_wdDislikeBtn) {
        _wdDislikeBtn = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)]; // 17,12 -> 60,44
        _wdDislikeBtn.titleColorThemeKey = kColorText4;
        _wdDislikeBtn.imageName = @"add_textpage";
        _wdDislikeBtn.accessibilityLabel = @"不感兴趣";
        [_wdDislikeBtn addTarget:self action:@selector(dislikeViewClick:) forControlEvents:UIControlEventTouchUpInside];
        _wdDislikeBtn.hidden = YES;
        [self addSubview:_wdDislikeBtn];
    }
    return _wdDislikeBtn;
}

- (SSThemedButton *)wdDislikeTextBtn
{
    if (!_wdDislikeTextBtn) {
        _wdDislikeTextBtn = [[SSThemedButton alloc] initWithFrame:CGRectZero];
        _wdDislikeTextBtn.titleColorThemeKey = kColorText3;
        [_wdDislikeTextBtn addTarget:self action:@selector(dislikeViewClick:) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *dislikeTitle = [self dislikeAttributeString];
        [_wdDislikeTextBtn setAttributedTitle:dislikeTitle forState:UIControlStateNormal];
        CGSize size = [[dislikeTitle string] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kDislikeNewStyleTitleFontSize()]}];
        _wdDislikeTextBtn.frame = CGRectMake(0.0f, 0.0f, ceilf(size.width), ceilf(size.height));
        _wdDislikeTextBtn.hidden = YES;
        [self addSubview:_wdDislikeTextBtn];
    }
    return _wdDislikeTextBtn;
}

- (NSAttributedString *)dislikeAttributeString
{
    NSString *iconString = [NSString stringWithFormat:@"%@ ", delete];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:iconString
                                                                              attributes:@{NSFontAttributeName : [UIFont fontWithName:wd_iconfont size:kDislikeNewStyleTitleFontSize()],                       NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1], NSKernAttributeName: @(-0.5f)}
                                        ];
    
    NSMutableAttributedString *token = [[NSMutableAttributedString alloc] initWithString:@"不喜欢"
                                                                              attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kDislikeNewStyleTitleFontSize()],                       NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]}
                                        ];
    [title appendAttributedString:token];
    return [title copy];
}

- (SSThemedView *)rewardView {
    if (!_rewardView) {
        _rewardView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _rewardView.backgroundColor = [UIColor clearColor];
        _rewardView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_rewardView addSubview:self.rewardIconImageView];
        [_rewardView addSubview:self.rewardLabel];
        [_rewardView addSubview:self.moneyLabel];
        [self addSubview:_rewardView];
    }
    return _rewardView;
}

- (TTImageView *)rewardIconImageView {
    if (!_rewardIconImageView) {
        _rewardIconImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, kWDRewardIconImageViewHeight(), kWDRewardIconImageViewHeight())];
        _rewardIconImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _rewardIconImageView.imageView.backgroundColor = [UIColor clearColor];
        _rewardIconImageView.backgroundColor = [UIColor clearColor];
        _rewardIconImageView.enableNightCover = NO;
    }
    return _rewardIconImageView;
}

- (SSThemedLabel *)rewardLabel {
    if (!_rewardLabel) {
        _rewardLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _rewardLabel.font = [UIFont systemFontOfSize:kWDRewardLabelFontSize()];
        _rewardLabel.textColorThemeKey = kColorText1;
    }
    return _rewardLabel;
}

- (SSThemedLabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _moneyLabel.font = [UIFont systemFontOfSize:kWDMonwyLabelFontSize()];
        _moneyLabel.textColorThemeKey = kColorText4;
        _moneyLabel.borderColorThemeKey = kColorLine2;
        _moneyLabel.textAlignment  = NSTextAlignmentCenter;
        _moneyLabel.layer.cornerRadius = 3;
        _moneyLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    }
    return _moneyLabel;
}

- (void)updateActionTextLabel{
    if(!isEmptyString(self.messageModel.content.actionText)){
        self.actionTextLabel.text = self.messageModel.content.actionText;
    }
    else{
        self.actionTextLabel.text = nil;
    }
}

- (void)updateWDInviteBottomView{
    if(!isEmptyString(self.messageModel.content.gotoText)){
        self.wdInviteLabel.text = self.messageModel.content.gotoText;
    }
    else{
        self.wdInviteLabel.text = @"回答";
    }
    if(!isEmptyString(self.messageModel.content.extra)){
        self.wdInviteExtraLabel.text = self.messageModel.content.extra;
    }
    else{
        self.wdInviteExtraLabel.text = nil;
    }
}

- (void)updateWDRewardBottomView {
    if (self.messageModel.content.profit && [[WDSettingHelper sharedInstance_tt] isQuestionRewardUserViewShow]) {
        NSString *urlString = (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) ? self.messageModel.content.profit.iconDayUrl : self.messageModel.content.profit.iconNightUrl;
        [self.rewardIconImageView setImageWithURLString:urlString];
        self.rewardLabel.text = self.messageModel.content.profit.text;
        self.moneyLabel.text = self.messageModel.content.profit.amount;
    }
}

- (void)layoutWDInviteBottomViewWithOrigin:(CGPoint)origin maxWidth:(CGFloat)maxWidth{
    self.wdInviteBottomView.origin = origin;
    
    [self.wdInviteLabel sizeToFit];
    self.wdInviteLabel.width = MIN(self.wdInviteLabel.width, maxWidth);
    self.wdInviteLabel.left = 0.f;
    self.wdInviteLabel.centerY = kWDInviteBottomViewHeight() / 2.f;
    
    [self.wdInviteExtraLabel sizeToFit];
    self.wdInviteExtraLabel.width = MIN(self.wdInviteExtraLabel.width, maxWidth - self.wdInviteLabel.width -kWDInviteLabelPadding());
    self.wdInviteExtraLabel.left = self.wdInviteLabel.right + kWDInviteLabelPadding();
    self.wdInviteExtraLabel.centerY = kWDInviteBottomViewHeight() / 2.f;
    
    self.wdInviteBottomView.size = CGSizeMake(self.wdInviteLabel.width + kWDInviteLabelPadding() + self.wdInviteExtraLabel.width, kWDInviteBottomViewHeight());
}

- (void)layoutWDDislikeView {
    if ([WDCommonLogic isWDMessageDislikeNewStyle]) {
        self.wdDislikeTextBtn.hidden = NO;
        self.wdDislikeTextBtn.centerY = ceilf(self.wdInviteBottomView.centerY);
        self.wdDislikeTextBtn.right = self.width - kWDInviteBottomViewRightPadding() + 2.0f;
    } else {
        self.wdDislikeBtn.hidden = NO;
        self.wdDislikeBtn.centerY = ceilf(self.wdInviteBottomView.centerY);
        self.wdDislikeBtn.right = self.width - kWDInviteBottomViewRightPadding() + (60-17)/2;
    }
   
}

- (void)layoutWDRewardViewWithOrigin:(CGPoint)origin {
    if (self.messageModel.content.profit && [[WDSettingHelper sharedInstance_tt] isQuestionRewardUserViewShow]) {
        self.rewardView.hidden = NO;
        self.rewardView.origin = origin;
        self.rewardIconImageView.origin = CGPointMake(0, 0);
        [self.rewardLabel sizeToFit];
        self.rewardLabel.height = self.rewardIconImageView.height;
        self.rewardLabel.origin = CGPointMake(self.rewardIconImageView.right + 4, 0);
        [self.moneyLabel sizeToFit];
        self.moneyLabel.left = self.rewardLabel.right + 6;
        self.moneyLabel.width = self.moneyLabel.width + [TTDeviceUIUtils tt_padding:3] * 2;
        self.moneyLabel.height = self.moneyLabel.height + [TTDeviceUIUtils tt_padding:1] * 2;
        self.moneyLabel.centerY = self.rewardLabel.centerY;
        self.rewardView.size = CGSizeMake(ceilf(self.moneyLabel.right), self.rewardIconImageView.height);
    }
    else {
        self.rewardView.hidden = YES;
    }
}

- (void)refreshWithData:(TTMessageNotificationModel *)data{
    self.messageModel = data;
    
    if(self.messageModel){
        [self updateAvatarImageView];
        
        [self updateActionTextLabel];
        
        if(!isEmptyString(self.messageModel.user.contactInfo)){
            [self updateContactInfoLabel];
        }
        
        [self updateBodyTextLabel];
        
        [self updateWDInviteBottomView];
        
        [self updateWDRewardBottomView];
    }
}

- (void)refreshUI{
    [self layoutAvatarImageView];
    
    self.roleInfoView.hidden = NO;
    if(!isEmptyString(self.actionTextLabel.text)){
        self.actionTextLabel.hidden = NO;
        [self.actionTextLabel sizeToFit];
        self.actionTextLabel.width = MIN(self.actionTextLabel.width, self.width - TTMNRoleInfoViewLeftPadding() - TTMNRoleInfoViewDefaultRightPadding() - kActionTextLabelLeftPadding());
        CGFloat maxRoleInfoViewWidth = self.width - TTMNRoleInfoViewLeftPadding() - TTMNRoleInfoViewDefaultRightPadding() - kActionTextLabelLeftPadding() - self.actionTextLabel.width;
        if(maxRoleInfoViewWidth <= TTMNUserNameLabelMinWidth()){
            self.roleInfoView.hidden = YES;
            self.roleInfoView.width = 0.f;
            self.roleInfoView.height = TTMNRoleInfoViewHeight();
            [self layoutRoleInfoView];
            self.actionTextLabel.centerY = self.roleInfoView.centerY;
            self.actionTextLabel.left = self.roleInfoView.right;
        }
        else{
            [self updateRoleInfoViewForMaxWidth:maxRoleInfoViewWidth];
            [self layoutRoleInfoView];
            self.actionTextLabel.centerY = self.roleInfoView.centerY;
            self.actionTextLabel.left = self.roleInfoView.right + kActionTextLabelLeftPadding();
        }
    }
    else{
        self.actionTextLabel.hidden = YES;
        CGFloat maxRoleInfoViewWidth = self.width - TTMNRoleInfoViewLeftPadding() - TTMNRoleInfoViewDefaultRightPadding();
        [self updateRoleInfoViewForMaxWidth:maxRoleInfoViewWidth];
        [self layoutRoleInfoView];
    }
    
    if(!isEmptyString(self.messageModel.user.contactInfo)){
        self.contactInfoLabel.hidden = NO;
        [self layoutContactInfoLabelWithOrigin:CGPointMake(TTMNContactInfoLabelLeftPadding(), self.roleInfoView.bottom + TTMNContactInfoLabelTopPadding()) maxWitdh:self.width - TTMNContactInfoLabelLeftPadding() - TTMNContactInfoLabelDefaultRightPadding()];
        
        [self layoutBodyTextLabelWithOrigin:CGPointMake(TTMNBodyTextLabelLeftPadding(), self.contactInfoLabel.bottom + TTMNBodyTextLabelTopPadding()) maxWidth:self.width - TTMNBodyTextLabelLeftPadding() - TTMNBodyTextLabelDefaultRightPadding()];
    }
    else{
        self.contactInfoLabel.hidden = YES;
        [self layoutBodyTextLabelWithOrigin:CGPointMake(TTMNBodyTextLabelLeftPadding(), self.roleInfoView.bottom + TTMNBodyTextLabelTopPadding()) maxWidth:self.width - TTMNBodyTextLabelLeftPadding() - TTMNBodyTextLabelDefaultRightPadding()];
    }
    [self layoutWDInviteBottomViewWithOrigin:CGPointMake(kWDInviteBottomViewLeftPadding(),self.bodyTextLabel.bottom + kWDInviteBottomViewTopPadding()) maxWidth:self.width - kWDInviteBottomViewLeftPadding()- kWDInviteBottomViewRightPadding()];
    
    [self layoutWDRewardViewWithOrigin:CGPointMake(self.wdInviteBottomView.left, self.wdInviteBottomView.bottom + kWDRewardBottomViewTopPadding())];
    [self layoutWDDislikeView];
    [self layoutBottomLine];
}

- (void)dislikeViewClick:(UIButton *)dislikeBtn {
    WDDislikeView *wdDislikeView = [[WDDislikeView alloc] init];
    WDDislikeViewModel *wdViewModel = [[WDDislikeViewModel alloc] init];
    NSArray *keywords = self.messageModel.content.filterWords;
    wdViewModel.keywords = keywords;
    wdViewModel.groupID = self.messageModel.ID;
    [wdDislikeView refreshWithModel:wdViewModel];
    CGPoint point = dislikeBtn.center;
    [wdDislikeView showAtPoint:point
                      fromView:dislikeBtn
               didDislikeBlock:^(WDDislikeView *view) {
                   [self exploreDislikeViewOKBtnClicked:view];
               }];
    NSString *answerUrl = self.messageModel.content.gotoUrl;
    NSString *qidString = [[answerUrl componentsSeparatedByString:@"&"] lastObject];
    NSString *qid = [[qidString componentsSeparatedByString:@"="] lastObject];
    NSMutableArray *keywordsName = [NSMutableArray array];
    for (NSDictionary *keyword in keywords) {
        NSString *name = [keyword objectForKey:@"name"];
        if (!isEmptyString(name)) {
            [keywordsName addObject:name];
        }
    }
    NSString *showWords = [keywordsName componentsJoinedByString:@","];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:qid forKey:@"group_id"];
    [dict setValue:showWords forKey:@"show_words"];
    [dict setValue:@"notice" forKey:@"source"];
    [TTTrackerWrapper eventV3:@"dislike_menu_with_reason" params:dict];
}

#pragma mark - WDDislikeView

- (void)exploreDislikeViewOKBtnClicked:(WDDislikeView *)view {
    NSArray <TTFeedDislikeWord *>*filterWords = [view selectedWords];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString *showWords = nil;
    [userInfo setValue:self.messageModel forKey:kTTMessageWDDislikeDataKey];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kTTMessageWDInviteAnswerNotInterestWordsKey];
        NSMutableArray *keywordsName = [NSMutableArray array];
        for (TTFeedDislikeWord *keyword in filterWords) {
            [keywordsName addObject:keyword.name];
        }
        showWords = [keywordsName componentsJoinedByString:@","];
    }
    NSString *answerUrl = self.messageModel.content.gotoUrl;
    NSString *qidString = [[answerUrl componentsSeparatedByString:@"&"] lastObject];
    NSString *qid = [[qidString componentsSeparatedByString:@"="] lastObject];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:qid forKey:@"group_id"];
    if (!isEmptyString(showWords)) {
        [dict setValue:showWords forKey:@"filter_words"];
    }
    [TTTrackerWrapper eventV3:@"rt_dislike" params:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTMessageWDInviteAnswerNotInterestNotification object:self userInfo:userInfo];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    if (self.messageModel.content.profit && [[WDSettingHelper sharedInstance_tt] isQuestionRewardUserViewShow]) {
        NSString *urlString = (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) ? self.messageModel.content.profit.iconDayUrl : self.messageModel.content.profit.iconNightUrl;
        [self.rewardIconImageView setImageWithURLString:urlString];
        self.rewardIconImageView.backgroundColor = [UIColor clearColor];
    }
}

@end

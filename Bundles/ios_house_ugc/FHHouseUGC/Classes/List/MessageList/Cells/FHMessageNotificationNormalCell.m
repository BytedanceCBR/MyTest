//
//  TTMessageNotificationJumpCell.m
//  Article
//
//  Created by zhulijun.2539 on 2019/6/17.
//
//

#import "FHMessageNotificationNormalCell.h"
#import "TTMessageNotificationModel.h"
#import "TTAsyncCornerImageView.h"
#import "TTUserInfoView.h"
#import "TTLabelTextHelper.h"
#import "TTImageView.h"
#import "TTRoute.h"
#import "FHMessageNotificationCellHelper.h"
#import "STLinkLabel.h"
#import "SSWebViewController.h"
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>

NS_INLINE CGFloat kGotoViewLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:61.f];
}

NS_INLINE CGFloat kGotoViewRightPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:15.f];
}

NS_INLINE CGFloat kGotoViewTopPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:5.f];
}

NS_INLINE CGFloat kGotoViewHeight(){
    return [FHMessageNotificationCellHelper tt_newPadding:58.f];
}

NS_INLINE CGFloat kGotoViewImageViewSize(){
    return [FHMessageNotificationCellHelper tt_newPadding:42.f];
}

NS_INLINE CGFloat kGotoViewImageViewLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:8.f];
}

NS_INLINE CGFloat kGotoViewTextLabelLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:10.f];
}

NS_INLINE CGFloat kGotoViewTextLabelRightPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:8.f];
}

NS_INLINE CGFloat kGotoViewTextLabelFontSize(){
    return [FHMessageNotificationCellHelper tt_newFontSize:14.f];
}

NS_INLINE CGFloat kGotoViewTextLabelLineHeight(){
    return [FHMessageNotificationCellHelper tt_newPadding:20.f];
}

NS_INLINE NSInteger kGotoViewTextLabelNumberOfLines(){
    return 2;
}

NS_INLINE CGFloat kSystemMessageLabelTopPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:9.f];
}

NS_INLINE CGFloat kSystemMessageLabelLineSpacing(){
    return [TTDeviceUIUtils tt_newPadding:4.5f];
}

@implementation FHMessageNotificationNormalCell

+ (Class)cellViewClass{
    return [FHMessageNotificationNormalCellView class];
}

@end

@interface FHMessageNotificationNormalCellView ()<STLinkLabelDelegate>

@property (nonatomic, strong) STLinkLabel    *systemMessageLabel;
@property (nonatomic, strong) SSThemedButton *gotoContainerView;
@property (nonatomic, strong) TTImageView    *gotoImageView;
@property (nonatomic, strong) SSThemedLabel  *gotoLabel;

@end

@implementation FHMessageNotificationNormalCellView

+ (CGFloat)heightForSystemMessageLabelWithData:(TTMessageNotificationModel *)data maxWidth:(CGFloat)maxWidth{
    return [STLinkLabel sizeWithText:data.content.bodyText font:[UIFont systemFontOfSize:FHMNBodyTextLabelFontSize()] constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineSpacing:kSystemMessageLabelLineSpacing() paragraphStyle:nil].height;
}

+ (CGFloat)heightForData:(TTMessageNotificationModel *)data cellWidth:(CGFloat)width{
    if([data.cachedHeight floatValue]> 0){
        return [data.cachedHeight floatValue];
    }
    
    CGFloat height = 0.f;
    
    height += FHMNRoleInfoViewTopPadding();
    height += FHMNRoleInfoViewHeight();
    
    if(!isEmptyString(data.user.contactInfo)){
        height += FHMNContactInfoLabelTopPadding();
        height += FHMNContactInfoLabelHeight();
    }
    
    height += kSystemMessageLabelTopPadding();
    height += [self heightForSystemMessageLabelWithData:data maxWidth:width - FHMNBodyTextLabelLeftPadding() - FHMNBodyTextLabelDefaultRightPadding()];
    
    if([data.style integerValue] == TTMessageNotificationStyleJump){
        height += kGotoViewTopPadding();
        height += kGotoViewHeight();
    }
    
    height += FHMNTimeLabelTopPadding();
    height += FHMNTimeLabelHeight();
    
    height = MAX(height, FHMNAvatarImageViewSize() + FHMNAvatarImageViewTopPadding());
    
    height += FHMNTimeLabelBottomPadding();
    
    data.cachedHeight = @(height);
    
    return height;
}

- (STLinkLabel *)systemMessageLabel{
    if(!_systemMessageLabel){
        _systemMessageLabel = [[STLinkLabel alloc] initWithFrame:CGRectZero];
        _systemMessageLabel.backgroundColor = [UIColor clearColor];
        _systemMessageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _systemMessageLabel.numberOfLines = FHMNBodyTextLabelNumberOfLines();
        _systemMessageLabel.textCheckingTypes = NSTextCheckingTypeLink | STTextCheckingTypeCustomLink;
        _systemMessageLabel.userInteractionEnabled = YES;
        _systemMessageLabel.linkColor = [UIColor tt_themedColorForKey:kColorText5];
        _systemMessageLabel.lineSpacing = kSystemMessageLabelLineSpacing();
        _systemMessageLabel.delegate = self;
        _systemMessageLabel.font = [UIFont systemFontOfSize:FHMNBodyTextLabelFontSize()];
        _systemMessageLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _systemMessageLabel.continueTouchEvent = YES;
        
        [self addSubview:_systemMessageLabel];
    }
    return _systemMessageLabel;
}

- (TTImageView *)gotoImageView{
    if(!_gotoImageView){
        _gotoImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _gotoImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
    }
    return _gotoImageView;
}

- (SSThemedLabel *)gotoLabel{
    if(!_gotoLabel){
        _gotoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _gotoLabel.font = [UIFont systemFontOfSize:kGotoViewTextLabelFontSize()];
        _gotoLabel.textColorThemeKey = kColorText1;
        _gotoLabel.numberOfLines = kGotoViewTextLabelNumberOfLines();
        _gotoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _gotoLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _gotoLabel;
}

- (SSThemedButton *)gotoContainerView{
    if(!_gotoContainerView){
        _gotoContainerView = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _gotoContainerView.backgroundColorThemeKey = kColorBackground3;
        [_gotoContainerView addTarget:self action:@selector(gotoContainerViewOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_gotoContainerView addSubview:self.gotoImageView];
        [_gotoContainerView addSubview:self.gotoLabel];
        
        [self addSubview: _gotoContainerView];
    }
    return _gotoContainerView;
}

- (void)gotoContainerViewOnClick:(id)sender{
    if(!isEmptyString(self.messageModel.content.gotoUrl)){
        TTMessageNotificationModel *model = self.messageModel;
        NSString *bodyUrl = model.content.bodyUrl;
        if (!isEmptyString(bodyUrl)) {
            wrapperTrackEventWithCustomKeys(@"message_cell", @"click", model.ID, nil, [FHMessageNotificationCellHelper listCellLogExtraForData:model]);
        }
        
        NSURL *url = [TTStringHelper URLWithURLString:self.messageModel.content.gotoUrl];
        NSString *URLString = url.absoluteString;
        if([[TTRoute sharedRoute] canOpenURL:url]){
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
        else if ([URLString hasPrefix:@"http://"] || [URLString hasPrefix:@"https://"]) {
            UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
            ssOpenWebView(url, @"", topController.navigationController, NO, nil);
        }
        else if([[UIApplication sharedApplication] canOpenURL:url]){
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)updateGotoContainerView{
    if (!isEmptyString(self.messageModel.content.gotoThumbUrl)){
       [self.gotoImageView setImageWithURLString:self.messageModel.content.gotoThumbUrl];
    }
    else{
        self.gotoImageView.imageView.image = nil;
    }
    
    if (!isEmptyString(self.messageModel.content.gotoText)){
        self.gotoLabel.attributedText = [TTLabelTextHelper attributedStringWithString:self.messageModel.content.gotoText fontSize:kGotoViewTextLabelFontSize() lineHeight:kGotoViewTextLabelLineHeight() lineBreakMode:NSLineBreakByTruncatingTail];
    }
    else{
        self.gotoLabel.attributedText = nil;
    }
}

- (void)layoutGotoContainerViewWithOrigin:(CGPoint)origin{
    self.gotoContainerView.origin = origin;
    self.gotoContainerView.size = CGSizeMake(self.width - kGotoViewLeftPadding() - kGotoViewRightPadding(), kGotoViewHeight());
    self.gotoImageView.size = CGSizeMake(kGotoViewImageViewSize(), kGotoViewImageViewSize());
    self.gotoImageView.centerY = kGotoViewHeight() / 2.f;
    self.gotoImageView.left = kGotoViewImageViewLeftPadding();
    
    CGFloat gotoLabelWidth = self.gotoContainerView.width - kGotoViewImageViewLeftPadding() - kGotoViewImageViewSize() - kGotoViewTextLabelLeftPadding() - kGotoViewTextLabelRightPadding();
    CGFloat gotoLabelHeight = [TTLabelTextHelper heightOfText:self.messageModel.content.gotoText fontSize:kGotoViewTextLabelFontSize() forWidth:gotoLabelWidth forLineHeight:kGotoViewTextLabelLineHeight() constraintToMaxNumberOfLines:kGotoViewTextLabelNumberOfLines()];
    self.gotoLabel.size = CGSizeMake(gotoLabelWidth, gotoLabelHeight);
    self.gotoLabel.centerY = kGotoViewHeight() / 2.f - 2.f;
    self.gotoLabel.left = self.gotoImageView.right + kGotoViewTextLabelLeftPadding();
}

- (void)refreshWithData:(TTMessageNotificationModel *)data{
    self.messageModel = data;
    
    if(self.messageModel){
        [self updateAvatarImageView];
        
        if(!isEmptyString(self.messageModel.user.contactInfo)){
            [self updateContactInfoLabel];
        }

        [self updateSystemMessageLabel];
        if([self.messageModel.style integerValue] == TTMessageNotificationStyleJump){
            [self updateGotoContainerView];
        }
        [self updateTimeLabel];
    }
}

- (void)refreshUI{
    [self layoutAvatarImageView];
    
    CGFloat maxRoleInfoViewWidth = self.width - FHMNRoleInfoViewLeftPadding() - FHMNRoleInfoViewDefaultRightPadding();
    [self updateRoleInfoViewForMaxWidth:maxRoleInfoViewWidth];
    [self layoutRoleInfoView];
    
    if(!isEmptyString(self.messageModel.user.contactInfo)){
        self.contactInfoLabel.hidden = NO;
        
        [self layoutContactInfoLabelWithOrigin:CGPointMake(FHMNContactInfoLabelLeftPadding(), self.roleInfoView.bottom + FHMNContactInfoLabelTopPadding()) maxWitdh:self.width - FHMNContactInfoLabelLeftPadding() - FHMNContactInfoLabelDefaultRightPadding()];
        
        [self layoutSystemMessageLabelWithOrigin:CGPointMake(FHMNBodyTextLabelLeftPadding(), self.contactInfoLabel.bottom + kSystemMessageLabelTopPadding()) maxWidth:self.width - FHMNBodyTextLabelLeftPadding() - FHMNBodyTextLabelDefaultRightPadding()];
    }
    else{
        self.contactInfoLabel.hidden = YES;
        
        [self layoutSystemMessageLabelWithOrigin:CGPointMake(FHMNBodyTextLabelLeftPadding(), self.roleInfoView.bottom + kSystemMessageLabelTopPadding()) maxWidth:self.width - FHMNBodyTextLabelLeftPadding() - FHMNBodyTextLabelDefaultRightPadding()];
       
    }
    
    if([self.messageModel.style integerValue] == TTMessageNotificationStyleJump){
        self.gotoContainerView.hidden = NO;
        [self layoutGotoContainerViewWithOrigin:CGPointMake(kGotoViewLeftPadding(), self.systemMessageLabel.bottom + kGotoViewTopPadding())];
        
        [self layoutTimeLabelWithOrigin:CGPointMake(FHMNTimeLabelLeftPadding(), self.gotoContainerView.bottom + FHMNTimeLabelTopPadding()) maxWidth:self.width - FHMNTimeLabelLeftPadding() - FHMNTimeLabelDefaultRightPadding()];
    }
    else{
        self.gotoContainerView.hidden = YES;
        
        [self layoutTimeLabelWithOrigin:CGPointMake(FHMNTimeLabelLeftPadding(), self.systemMessageLabel.bottom + FHMNTimeLabelTopPadding()) maxWidth:self.width - FHMNTimeLabelLeftPadding() - FHMNTimeLabelDefaultRightPadding()];
    }
    
    [self layoutBottomLine];
}

- (void)updateSystemMessageLabel{
    if(!isEmptyString(self.messageModel.content.bodyText)){
        self.systemMessageLabel.text =  self.messageModel.content.bodyText;
    }
    else{
        self.systemMessageLabel.text = nil;
    }
}

- (void)layoutSystemMessageLabelWithOrigin:(CGPoint)origin maxWidth:(CGFloat)maxWidth{
    self.systemMessageLabel.origin = origin;
    
    CGFloat height = [[self class] heightForSystemMessageLabelWithData:self.messageModel maxWidth:maxWidth];
    
    self.systemMessageLabel.size = CGSizeMake(maxWidth, height);
}

#pragma mark - STLinkLabelDelegate
- (void)linkLabel:(STLinkLabel *)linkLabel didSelectLinkObject:(STLinkObject *)linkObject {
    NSURL *URL = linkObject.URL;
    NSString *URLString = URL.absoluteString;
    if([[TTRoute sharedRoute] canOpenURL:URL]){
        [[TTRoute sharedRoute] openURLByPushViewController:URL];
    }
    else if ([URLString hasPrefix:@"http://"] || [URLString hasPrefix:@"https://"]) {
        UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
        ssOpenWebView(URL, @"", topController.navigationController, NO, nil);
    }
    else if([[UIApplication sharedApplication] canOpenURL:URL]){
        [[UIApplication sharedApplication] openURL:URL];
    }
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
    self.systemMessageLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.systemMessageLabel.linkColor = [UIColor tt_themedColorForKey:kColorText5];
    [self.systemMessageLabel setNeedsDisplay];
}

@end

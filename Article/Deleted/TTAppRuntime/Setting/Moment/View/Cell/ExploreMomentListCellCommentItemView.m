
//
//  ExploreMomentListCellCommentItemView.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-14.
//
//

#import "ExploreMomentListCellCommentItemView.h"
#import "ArticleMomentHelper.h"
#import "TTTAttributedLabel.h"
#import "SSUserSettingManager.h"
#import "SSWebViewController.h"
//#import "FRRouteHelper.h"

#import "UIColor+TTThemeExtension.h"
#import "TTDeviceUIUtils.h"
#import "TTThemeManager.h"
#import "TTRoute.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTNetworkUtil.h"
#import "NewsUserSettingManager.h"
#import "TTTabBarProvider.h"

#define kTopPadding     0
#define kBottomPadding  [TTDeviceUIUtils tt_paddingForMoment:3]
//#define kKerningValue 0.4f

#define kArrowStr @".. >>"

@interface ExploreMomentListCellCommentItemView()<TTTAttributedLabelDelegate>

@property(nonatomic, strong)NSArray * menuItems;

@end

@implementation ExploreMomentListCellCommentItemView

- (void)dealloc {
    _commentLabel.delegate = nil;
}

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    self = [super initWithWidth:cellWidth userInfo:uInfo];
    if (self) {
        self.commentLabel = [[SSTTTAttributedLabel alloc] initWithFrame:CGRectZero];
        CGFloat size = [NewsUserSettingManager fontSizeFromNormalSize:17.f isWidescreen:NO];
        _commentLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSizeForMoment:size]];
        _commentLabel.backgroundColor = [UIColor clearColor];
        _commentLabel.numberOfLines = [ExploreMomentListCellCommentItemView maxLineOfTextForCommentForUserInfo:uInfo];
        _commentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        _commentLabel.delegate = self;
        UIGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
        [_commentLabel addGestureRecognizer:longPress];
        [self addSubview:_commentLabel];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    NSDictionary *trunDict = @{NSFontAttributeName : [UIFont systemFontOfSize:[ExploreMomentListCellCommentItemView commentLabelFontSize]],
                               NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]};
    NSAttributedString * trunStr = [[NSAttributedString alloc] initWithString:kArrowStr attributes:trunDict];
    _commentLabel.attributedTruncationToken = trunStr;
    _commentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    _commentLabel.linkAttributes = @{NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]};
    _commentLabel.activeLinkAttributes = @{NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5Highlighted]};
    _commentLabel.backgroundHighlightColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"d4d4d4" nightColorName:@"353535"]];
    if (self.momentModel) {
        [self refreshForMomentModel:self.momentModel];
    }
}

- (CGRect)_commentLabelFrame
{
    return CGRectMake(kMomentCellItemViewLeftPadding, kTopPadding, CGRectGetWidth(self.frame) - kMomentCellItemViewLeftPadding - kMomentCellItemViewRightPadding, CGRectGetHeight(self.frame) - kTopPadding - kBottomPadding);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.commentLabel.frame = [self _commentLabelFrame];
}

- (void)refreshForMomentModel:(ArticleMomentModel *)model
{
    [super refreshForMomentModel:model];
    CGFloat size = [NewsUserSettingManager fontSizeFromNormalSize:17.f isWidescreen:NO];
    _commentLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSizeForMoment:size]];
    _commentLabel.frame = CGRectMake(kMomentCellItemViewLeftPadding, kTopPadding, self.width - kMomentCellItemViewLeftPadding - kMomentCellItemViewRightPadding, self.height - kTopPadding - kBottomPadding);
    
    NSString * forumName = nil;
    NSString * content = nil;
    SSTTTAttributedLink *forumNameLink = nil;
    if (!isEmptyString(model.forumName)) {
        forumName = [NSString stringWithFormat:@"%@ ",model.forumName];
        content = [forumName stringByAppendingString:model.content];
    }
    else{
        content = [NSString stringWithFormat:@"%@",model.content];
    }
     SSTTTAttributedModel *attributedModel = [SSTTTAttributedLabel attributeModelByReplaceLinkInString:content];
    _commentLabel.text = [ExploreMomentListCellCommentItemView attributeStrForContent:attributedModel.content withForumName:forumName];
    if (!isEmptyString(forumName)) {
        forumNameLink = [[SSTTTAttributedLink alloc] init];
        forumNameLink.url = [NSURL URLWithString:@"forumNameUrl"];
        forumNameLink.range = NSMakeRange(0, forumName.length);
        [_commentLabel addAttributedLink:forumNameLink];
    }
    for (SSTTTAttributedLink *link in attributedModel.linkArray) {
        [_commentLabel addAttributedLink:link];
    }
}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    return [ExploreMomentListCellCommentItemView heightForMomentModel:model cellWidth:cellWidth userInfo:self.userInfo];
}

+ (NSAttributedString *)attributeStrForContent:(NSString *)content withForumName:(NSString *)forumName
{
    if (isEmptyString(content)) {
        return nil;
    }
    
    CGFloat fontSize = [self commentLabelFontSize];
    CGFloat lineHeight = [self lineHeight];
    CGFloat lineHeightMultiple = lineHeight / fontSize;
    
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = lineHeightMultiple;
    //style.lineSpacing = kLineSpacing;
    style.minimumLineHeight = fontSize * lineHeightMultiple;
    style.maximumLineHeight = fontSize * lineHeightMultiple;
    
    NSDictionary * dict1 = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                            NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5],
                            NSParagraphStyleAttributeName: style};
    NSDictionary * dict2 = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                            NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1],
                            NSParagraphStyleAttributeName: style};
    NSMutableAttributedString * result = nil;
    if(isEmptyString(forumName)){
        result =[[NSMutableAttributedString alloc] initWithString:content attributes:dict2];
    }
    else{
        result = [[NSMutableAttributedString alloc] initWithString:content];
        [result addAttributes:dict1 range:NSMakeRange(0, forumName.length)];
        if (content.length - forumName.length > 0) {
            [result addAttributes:dict2 range:NSMakeRange(forumName.length, content.length - forumName.length)];
        }
    }
    return [result copy];
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    if (![self needShowForModel:model userInfo:uInfo]) {
        return 0;
    }
    
    NSString * forumName = nil;
    NSString * content = nil;
    if (!isEmptyString(model.forumName)) {
        forumName = [NSString stringWithFormat:@"%@ ",model.forumName];
        content = [forumName stringByAppendingString:model.content];
    }
    else{
        content = [NSString stringWithFormat:@"%@",model.content];
    }
    SSTTTAttributedModel *attributedModel = [SSTTTAttributedLabel attributeModelByReplaceLinkInString:content];
    CGFloat height = [SSTTTAttributedLabel sizeThatFitsAttributedString:[self attributeStrForContent:attributedModel.content withForumName:forumName]
                                                      withConstraints:CGSizeMake(cellWidth - kMomentCellItemViewLeftPadding - kMomentCellItemViewRightPadding, 9999)
                                               limitedToNumberOfLines:[self maxLineOfTextForCommentForUserInfo:uInfo]].height;
    if (height > 0) {
        height += (kTopPadding + kBottomPadding);
    }
    return height;
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo
{
    if (isEmptyString([model.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        return NO;
    }
    return YES;
}

+ (NSUInteger)commentLabelFontSize
{
    CGFloat size = [NewsUserSettingManager fontSizeFromNormalSize:17.f isWidescreen:NO];
    return [TTDeviceUIUtils tt_fontSizeForMoment:size];
}

+ (CGFloat)lineHeight
{
    return [TTDeviceUIUtils tt_lineHeight:[self commentLabelFontSize] * 1.5];
}

+ (NSUInteger)maxLineOfTextForCommentForUserInfo:(NSDictionary *)uInfo
{
    BOOL isDetail = [[uInfo objectForKey:kMomentListCellItemBaseIsDetailViewTypeKey] boolValue];
    if (isDetail) {
        return 9999;
    }
    return [ArticleMomentHelper maxLineOfCommentInMomentList];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    if (label == self.commentLabel) {
        NSString *label = nil;
        
        switch (self.sourceType) {
            case ArticleMomentSourceTypeForum:
            {
                label = @"topic";
            }
                break;
                
            case ArticleMomentSourceTypeMoment:
            {
                label = @"update";
            }
                break;
                
            default:
                break;
        }
        
        if (!isEmptyString(label)) {
            if (!self.isDetailView) {
                label = [label stringByAppendingString:@"_list"];
            }
            
            wrapperTrackEvent(@"web_view", label);
        }
        if([url.absoluteString isEqualToString:@"forumNameUrl"]){
            if (!isEmptyString(self.momentModel.openURL)) {
                NSMutableDictionary * gdExtJson = @{}.mutableCopy;
                if (self.sourceType == ArticleMomentSourceTypeProfile) {
                    [gdExtJson setValue:@"profile" forKey:@"enter_from"];
                }else {
                    [gdExtJson setValue:@"click_update" forKey:@"enter_from"];
                }
                [gdExtJson setValue:self.momentModel.ID forKey:@"update_id"];
                NSString * gdExtJsonStr = [gdExtJson tt_JSONRepresentation];
                NSDictionary * params = nil;
                if (!isEmptyString(gdExtJsonStr)) {
                    params = @{@"gd_ext_json":gdExtJsonStr};
                }
                NSURL * resultURL = [TTNetworkUtil URLWithURLString:[TTNetworkUtil URLString:self.momentModel.openURL appendCommonParams:params]];
                [[TTRoute sharedRoute] openURLByPushViewController:resultURL];
            }
        }
        else{
            
            if (self.sourceType == ArticleMomentSourceTypeMoment) {
                if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
                    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                    [extra setValue:self.momentModel.ID forKey:@"item_id"];
                    [extra setValue:self.momentModel.group.ID forKey:@"value"];
                    [TTTrackerWrapper event:@"micronews_tab" label:@"quote" value:nil extValue:nil extValue2:nil dict:[extra copy]];
                }
            }
            
            ssOpenWebView(url, nil, [TTUIResponderHelper topNavigationControllerFor: self], NO, nil);
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (@selector(customCopy:) == action) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)handleLongPress:(UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        wrapperTrackEvent(@"update_detail", @"longpress");
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"复制", nil) action:@selector(customCopy:)];
        if (copyItem) {
            self.menuItems = menu.menuItems;
            menu.menuItems = @[copyItem];
        }
        [menu setTargetRect:self.commentLabel.frame inView:self.commentLabel.superview];
        [menu setMenuVisible:YES animated:YES];
        [self changeCommentLabelBackgroundColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenu) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
}

- (void)willHideMenu {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    [self resetCommentLabelBackgroundColor];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = self.menuItems;
}

- (void)changeCommentLabelBackgroundColor
{
    self.commentLabel.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"d4d4d4" nightColorName:@"353535"]];
}

- (void)resetCommentLabelBackgroundColor
{
    self.commentLabel.backgroundColor = self.backgroundColor;
}

- (void)customCopy:(__unused id)sender {
    wrapperTrackEvent(@"update_detail", @"longpress_copy");
    [[UIPasteboard generalPasteboard] setString:self.commentLabel.text];
}

@end

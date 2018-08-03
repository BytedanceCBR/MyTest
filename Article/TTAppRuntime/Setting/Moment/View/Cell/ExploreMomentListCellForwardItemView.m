//
//  ExploreMomentListCellForwardItemView.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-18.
//
//  

#import "ExploreMomentListCellForwardItemView.h"

#import "SSThemed.h"
#import "ExploreMomentImageAlbum.h"
#import "TTPhotoScrollViewController.h"
#import "SSUserModel.h"
#import "ExploreMomentListCellOriginArticleItemView.h"
#import "SSUserSettingManager.h"
#import "ArticleMomentDetailViewController.h"
#import "TTIndicatorView.h"
#import "ExploreMomentListCellForumItemView.h"
#import "SSTTTAttributedLabel.h"
#import "ArticleMomentHelper.h"
#import "SSWebViewController.h"
#import "TTIndicatorView.h"
////#import "FRRouteHelper.h"
#import "NewsUserSettingManager.h"
#import "TTDeviceUIUtils.h"
#import "UIImage+TTThemeExtension.h"
#import "TTRoute.h"
#import "TTNetworkUtil.h"
#import <TTBaseLib/JSONAdditions.h>

#import <TTInteractExitHelper.h>

#define kArrowStr @".. >>"

#define kTitleLeftPadding   [TTDeviceUIUtils tt_paddingForMoment:12]
#define kTitleRightPadding  [TTDeviceUIUtils tt_paddingForMoment:12]
#define kTitleTopPadding    [TTDeviceUIUtils tt_paddingForMoment:8]
#define kBottomPadding      [TTDeviceUIUtils tt_paddingForMoment:12]
#define kAlbumTopPadding    kBottomPadding
#define kAlbumBottomPadding [TTDeviceUIUtils tt_paddingForMoment:12]
#define kArticleTopPadding  [TTDeviceUIUtils tt_paddingForMoment:10]
#define kLineHeightMultiple 1.5f
//#define kKerningValue 0.4f

@interface ExploreMomentListCellForwardItemView()<ExploreMomentImageAlbumDelegate,TTTAttributedLabelDelegate>
@property(nonatomic, strong)UIButton * bgButton;
@property(nonatomic, strong)SSThemedView    *contentView;
//@property(nonatomic, strong)SSThemedLabel * titleLabel;
@property(nonatomic, strong)ExploreMomentImageAlbum *imageAlbum;
@property(nonatomic, strong)ExploreMomentListCellOriginArticleItemView * articleItemView;
@end

@implementation ExploreMomentListCellForwardItemView

- (void)dealloc
{
    _imageAlbum.delegate = nil;
    _imageAlbum = nil;
    _commentLabel.delegate = nil;
}

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    self = [super initWithWidth:cellWidth userInfo:uInfo];
    if (self) {
        self.contentView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        self.contentView.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:self.contentView];
        
        self.bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _bgButton.frame = _contentView.bounds;
        _bgButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_contentView addSubview:_bgButton];
        
        self.commentLabel = [[SSTTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _commentLabel.font = [UIFont systemFontOfSize:[ExploreMomentListCellForwardItemView preferredTitleSize]];
        _commentLabel.backgroundColor = [UIColor clearColor];
        _commentLabel.numberOfLines = [ExploreMomentListCellForwardItemView maxLineOfTextForCommentForUserInfo:uInfo];
        _commentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        _commentLabel.delegate = self;
        [self addSubview:_commentLabel];
        
        self.imageAlbum = [[ExploreMomentImageAlbum alloc] init];
        _imageAlbum.albumStyle = ExploreMomentImageAlbumUIStyleForward;
        _imageAlbum.delegate = self;
        self.imageAlbum.margin = 2;
        self.imageAlbum.clipsToBounds = YES;
        [self.contentView addSubview:self.imageAlbum];
        
        self.articleItemView = [[ExploreMomentListCellOriginArticleItemView alloc] initWithWidth:cellWidth - kMomentCellItemViewRightPadding - kMomentCellItemViewLeftPadding - kTitleLeftPadding - kTitleRightPadding userInfo:uInfo  itemViewType:ExploreMomentListCellOriginArticleItemViewTypeForward];
        _articleItemView.hidden = YES;
        [self.contentView addSubview:self.articleItemView];
        
        [self reloadThemeUI];
    }
    return self;
}

- (BOOL)isForumItemViewShown
{
    return !isEmptyString(self.momentModel.originItem.forumName);
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    NSDictionary *trunDict = @{NSFontAttributeName : [UIFont systemFontOfSize:[ExploreMomentListCellForwardItemView preferredTitleSize]],
                               NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]};
    NSAttributedString * trunStr = [[NSAttributedString alloc] initWithString:kArrowStr attributes:trunDict];
    _commentLabel.attributedTruncationToken = trunStr;
    _commentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    _commentLabel.linkAttributes = @{NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]};
    _commentLabel.activeLinkAttributes = @{NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5Highlighted]};
    
    _commentLabel.backgroundHighlightColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"d4d4d4" nightColorName:@"353535"]];
}

+ (NSAttributedString *)attributeStrForContent:(NSString *)content withOriginalUserName:(NSString *)originalUserName andOriginalForumName:(NSString *)forumName
{
    if (isEmptyString(content)) {
        return nil;
    }
    
    CGFloat fontSize = [self preferredTitleSize];
    CGFloat lineHeight = [self lineHeight];
    CGFloat lineHeightMultiple = lineHeight / fontSize;
    
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = lineHeightMultiple;
    //style.lineSpacing = 3;
    style.minimumLineHeight = fontSize * lineHeightMultiple;
    style.maximumLineHeight = fontSize * lineHeightMultiple;

    NSDictionary * dict1 = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                            NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5],
                            NSParagraphStyleAttributeName: style};
    NSDictionary * dict2 = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                            NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1],
                            NSParagraphStyleAttributeName: style};
    NSMutableAttributedString * result = [[NSMutableAttributedString alloc] initWithString:content];
    if (!isEmptyString(originalUserName) || !isEmptyString(forumName)) {
        NSUInteger length = 0;
        if (!isEmptyString(originalUserName)) {
            length += originalUserName.length;
        }
        if (!isEmptyString(forumName)) {
            length += forumName.length;
        }
        if (length > 0 && length <= [result length]) {
            [result addAttributes:dict1 range:NSMakeRange(0, length)];
        }
        if (content.length - length > 0) {
            [result addAttributes:dict2 range:NSMakeRange(length, content.length - length)];
        }
    }
    else{
        [result addAttributes:dict2 range:NSMakeRange(0, content.length)];
    }
    return [result copy];
}


- (void)bgButtonClicked
{
    if (self.momentModel.originItem.isDeleted) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:kArticleMomentModelContentDeletedTip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    if ([self.momentModel.originItem.ID longLongValue] == 0) {
        return;
    }
    ArticleMomentDetailViewController * controller = [[ArticleMomentDetailViewController alloc] initWithMomentModel:self.momentModel.originItem momentManager:nil sourceType:self.sourceType];
    [[TTUIResponderHelper topNavigationControllerFor: self] pushViewController:controller animated:YES];
}
- (void)refreshForMomentModel:(ArticleMomentModel *)model
{
    [super refreshForMomentModel:model];
    self.contentView.frame = CGRectMake(kMomentCellItemViewLeftPadding , kExploreMomentListForwardItemTopPadding, self.width - kMomentCellItemViewRightPadding - kMomentCellItemViewLeftPadding, self.height - kExploreMomentListForwardItemTopPadding);
    
    CGFloat originY = kTitleTopPadding + kExploreMomentListForwardItemTopPadding;
    CGFloat commentLabelHeight = [ExploreMomentListCellForwardItemView heightForTitleLabel:model cellWidth:self.width userInfo:self.userInfo];
    _commentLabel.font = [UIFont systemFontOfSize:[ExploreMomentListCellForwardItemView preferredTitleSize]];
    _commentLabel.frame = CGRectMake(kMomentCellItemViewLeftPadding + kTitleLeftPadding, originY, self.width - kMomentCellItemViewLeftPadding - kMomentCellItemViewRightPadding - kTitleLeftPadding - kTitleRightPadding, commentLabelHeight);
    
    NSString *title = [ExploreMomentListCellForwardItemView titleForMomentModel:self.momentModel];
    SSTTTAttributedModel *attributedModel = [SSTTTAttributedLabel attributeModelByReplaceLinkInString:title];
    NSString * originalUserName = [ExploreMomentListCellForwardItemView originalUserNameForMomentModel:self.momentModel];
    NSString * forumName = [ExploreMomentListCellForwardItemView originalForumNameForMomentModel:self.momentModel];
    SSTTTAttributedLink *forumNameLink = nil;
    SSTTTAttributedLink *originalUserNameLink = nil;
    _commentLabel.text = [ExploreMomentListCellForwardItemView attributeStrForContent:attributedModel.content withOriginalUserName:originalUserName andOriginalForumName:forumName];
    if (!isEmptyString(originalUserName)) {
        originalUserNameLink = [[SSTTTAttributedLink alloc] init];
        originalUserNameLink.url = [NSURL URLWithString:@"originalUserNameUrl"];
        originalUserNameLink.range = NSMakeRange(0, originalUserName.length);
        [_commentLabel addAttributedLink:originalUserNameLink];
    }
    if (!isEmptyString(forumName)) {
        forumNameLink = [[SSTTTAttributedLink alloc] init];
        forumNameLink.url = [NSURL URLWithString:@"forumNameUrl"];
        forumNameLink.range = NSMakeRange(originalUserName.length, forumName.length);
        [_commentLabel addAttributedLink:forumNameLink];
    }
    for (SSTTTAttributedLink *link in attributedModel.linkArray) {
        [_commentLabel addAttributedLink:link];
    }
    
    originY = (_commentLabel.bottom) - kExploreMomentListForwardItemTopPadding;

    self.imageAlbum.frame = CGRectMake(kTitleLeftPadding, originY + kAlbumTopPadding , (self.contentView.width) - kTitleLeftPadding - kTitleRightPadding, self.height - (self.commentLabel.bottom) - kAlbumTopPadding - kAlbumBottomPadding);
    self.imageAlbum.images = model.originItem.thumbImageList;
    
    BOOL needShowArticleItem = [ExploreMomentListCellOriginArticleItemView needShowForModel:model userInfo:self.userInfo itemViewType:ExploreMomentListCellOriginArticleItemViewTypeForward];
    if (needShowArticleItem) {
        _articleItemView.frame = CGRectMake(kTitleLeftPadding, originY + kArticleTopPadding, (self.contentView.width) - kTitleLeftPadding - kTitleRightPadding, self.height - (self.commentLabel.bottom) - kArticleTopPadding - kBottomPadding);
        [_articleItemView refreshForMomentModel:model];
        _articleItemView.hidden = NO;
    }
    else {
        _articleItemView.hidden = YES;
    }
}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    return [ExploreMomentListCellForwardItemView heightForMomentModel:model cellWidth:cellWidth userInfo:self.userInfo];
}

+ (NSString *)titleForMomentModel:(ArticleMomentModel *)model
{
    if (model == nil) {
        return nil;
    }
    if (model.originItem.isDeleted) {
        return kArticleMomentModelContentDeletedTip;
    }
    NSMutableString * resultStr = [NSMutableString stringWithCapacity:100];
    [resultStr appendString:[self originalUserNameForMomentModel:model]];
    [resultStr appendString:[self originalForumNameForMomentModel:model]];
    
    if (!isEmptyString(model.originItem.content)) {
        [resultStr appendFormat:@"%@", model.originItem.content];
    }
    else if (!isEmptyString(model.originItem.actionDescription)){
        [resultStr appendFormat:@"%@", model.originItem.actionDescription];
    }
    return resultStr;
}

+ (NSString *)originalUserNameForMomentModel:(ArticleMomentModel *)model
{
    if (model == nil) {
        return nil;
    }
    if (model.originItem.isDeleted) {
        return nil;
    }
    NSMutableString * originalUserName = [NSMutableString stringWithCapacity:100];
    if (!isEmptyString(model.originItem.user.name)) {
        [originalUserName appendFormat:@"@%@ ", model.originItem.user.name];
    }
    return originalUserName;
}

+ (NSString *)originalForumNameForMomentModel:(ArticleMomentModel *)model
{
    if (model == nil) {
        return nil;
    }
    if (model.originItem.isDeleted) {
        return nil;
    }
    NSMutableString * originalForumName = [NSMutableString stringWithCapacity:100];
    if (!isEmptyString(model.originItem.forumName)) {
        [originalForumName appendFormat:@"%@ ", model.originItem.forumName];
    }
    return originalForumName;
}

+ (CGFloat)heightForTitleLabel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    if (model == nil) {
        return 0;
    }
    CGFloat width = cellWidth - kMomentCellItemViewLeftPadding - kMomentCellItemViewRightPadding - kTitleRightPadding - kTitleLeftPadding;
    
    NSString *title = [self titleForMomentModel:model];
    SSTTTAttributedModel *attributedModel = [SSTTTAttributedLabel attributeModelByReplaceLinkInString:title];
    NSString * originalUserName = [ExploreMomentListCellForwardItemView originalUserNameForMomentModel:model];
    NSString * forumName = [ExploreMomentListCellForwardItemView originalForumNameForMomentModel:model];
    CGFloat textHeight = [SSTTTAttributedLabel sizeThatFitsAttributedString:[self attributeStrForContent:attributedModel.content withOriginalUserName:originalUserName andOriginalForumName:forumName]
                                                          withConstraints:CGSizeMake(width, 9999)
                                                   limitedToNumberOfLines:[self maxLineOfTextForCommentForUserInfo:uInfo]].height;
    return textHeight;
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    if (![self needShowForModel:model userInfo:uInfo]) {
        return 0;
    }
    ArticleMomentModel *momentModel = model.originItem;
    
    CGFloat textHeight = [self heightForTitleLabel:model cellWidth:cellWidth userInfo:uInfo];
    
//    CGFloat textHeight = sizeOfContent([self titleForMomentModel:model], width, [UIFont systemFontOfSize:[self preferredTitleSize]]).height;
    
    CGFloat width = cellWidth - kMomentCellItemViewLeftPadding - kMomentCellItemViewRightPadding - kTitleRightPadding - kTitleLeftPadding;
    
    CGFloat albumHeight = 0;
    if (!momentModel.isDeleted) {
        albumHeight = [ExploreMomentImageAlbum heightForImages:momentModel.thumbImageList constrainedToWidth:width margin:2];
    }
    
    CGFloat articleItemViewHeight = 0;
    if (!momentModel.isDeleted) {
        articleItemViewHeight = [ExploreMomentListCellOriginArticleItemView heightForMomentModel:model cellWidth:cellWidth userInfo:uInfo itemViewType:ExploreMomentListCellOriginArticleItemViewTypeForward];
    }
    
    CGFloat height = textHeight + albumHeight + articleItemViewHeight;
    if (height > 0) {
        // 上下间距
        height += kTitleTopPadding + kBottomPadding;
    }
    if (albumHeight > 0) {
        // 图文间距
        height += kAlbumTopPadding;
    }
    if (articleItemViewHeight > 0) {
        // 原文间距
        height += kArticleTopPadding;
    }
    height += kExploreMomentListForwardItemTopPadding;
    return height;
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo
{
    if ([model.originItem.ID longLongValue] > 0) {
        return YES;
    }
    return NO;
}

+ (CGFloat)preferredTitleSize {
    CGFloat size = [NewsUserSettingManager fontSizeFromNormalSize:17.f isWidescreen:NO];
    return [TTDeviceUIUtils tt_fontSizeForMoment:size];
}

+ (CGFloat)lineHeight
{
    return [self preferredTitleSize] * kLineHeightMultiple;
}

#pragma mark -- ExploreMomentImageAlbumDelegate

- (void)imageAlbum:(ExploreMomentImageAlbum *)imageAlbum didClickImageAtIndex:(NSInteger)index
{
    [self openPhotoForIndex:index];
}

- (void)openPhotoForIndex:(NSUInteger)index
{
    if ([self.momentModel.originItem.largeImageList count] == 0) {
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.momentModel.ID forKey:@"id"];
    
    if (self.sourceType == ArticleMomentSourceTypeForum) {
        [TTTrackerWrapper category:@"umeng" event:@"image" label:@"enter_topic" dict:dict];
    } else if (self.sourceType == ArticleMomentSourceTypeMoment
               || self.sourceType == ArticleMomentSourceTypeProfile) {
        [TTTrackerWrapper category:@"umeng" event:@"image" label:@"enter_update" dict:dict];
    }
    
    TTPhotoScrollViewController * showImageViewController = [[TTPhotoScrollViewController alloc] init];
    showImageViewController.targetView = self;
    showImageViewController.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    NSArray *infoModels = self.momentModel.originItem.largeImageList;
    showImageViewController.imageInfosModels = infoModels;
    showImageViewController.placeholders = self.imageAlbum.displayImages;
    showImageViewController.placeholderSourceViewFrames = self.imageAlbum.displayImageViewFrames;
    [showImageViewController setStartWithIndex:index];
    [showImageViewController presentPhotoScrollView];
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
        if ([url.absoluteString isEqualToString:@"originalUserNameUrl"]) {
            [ArticleMomentHelper openMomentProfileView:self.momentModel.originItem.user navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromFeedItem];
        }
        else if ([url.absoluteString isEqualToString:@"forumNameUrl"]){
            if (!isEmptyString(self.momentModel.originItem.openURL)) {
                NSMutableDictionary * gdExtJson = @{}.mutableCopy;
                if (self.sourceType == ArticleMomentSourceTypeProfile) {
                    [gdExtJson setValue:@"profile" forKey:@"enter_from"];
                }else {
                    [gdExtJson setValue:@"click_update" forKey:@"enter_from"];
                }
                [gdExtJson setValue:self.momentModel.originItem.ID forKey:@"update_id"];
                NSString * gdExtJsonStr = [gdExtJson tt_JSONRepresentation];
                NSDictionary * params = nil;
                if (!isEmptyString(gdExtJsonStr)) {
                    params = @{@"gd_ext_json":gdExtJsonStr};
                }
                NSURL * resultURL = [TTNetworkUtil URLWithURLString:[TTNetworkUtil URLString:self.momentModel.originItem.openURL appendCommonParams:params]];
                [[TTRoute sharedRoute] openURLByPushViewController:resultURL];
            }
        }
        else{
            ssOpenWebView(url, nil, [TTUIResponderHelper topNavigationControllerFor: self], NO, nil);
        }
    }
}

@end

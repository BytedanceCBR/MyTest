//
//  TTMessageNotificationBaseCellView.m
//  Article
//
//  Created by 邱鑫玥 on 2017/4/7.
//
//

#import <TTBaseLib/NSString-Extension.h>
#import "FHMessageNotificationBaseCellView.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "FHMessageNotificationCellHelper.h"
#import "TTMessageNotificationModel.h"
#import "TTImageView.h"
#import "TTIMDateFormatter.h"
#import "TTDeviceHelper.h"
#import "TTRoute.h"
#import "ArticleMomentProfileViewController.h"
#import "SSWebViewController.h"
#import "TTUIResponderHelper.h"
#import "TTUGCEmojiParser.h"
#import "TTTAttributedLabel.h"
#import "TTAsyncCornerImageView.h"
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>

#define kAvatarImageWidth 36.f

inline CGFloat FHMNAvatarImageViewSize(){
    return [FHMessageNotificationCellHelper tt_newPadding:36.f];
}

inline CGFloat FHMNAvatarImageViewLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat FHMNAvatarImageViewTopPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:12.f];
}

inline CGFloat FHMNRefTextLabelFontSize(){
    return [FHMessageNotificationCellHelper tt_newFontSize:12.f];
}

inline CGFloat FHMNRefTextLabelLineHeight(){
    return [FHMessageNotificationCellHelper tt_newPadding:17.f];
}

inline NSInteger FHMNRefTextLabelNumberOfLines(){
    return 3;
}

inline CGFloat FHMNRefTextLabelWidth(){
    return [FHMessageNotificationCellHelper tt_newPadding:72.f];
}

inline CGFloat FHMNRefImageViewSize(){
    return [FHMessageNotificationCellHelper tt_newPadding:72.f];
}

inline CGFloat FHMNRefTopPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:12.f];
}

inline CGFloat FHMNRefRightPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat FHMNBodyTextLabelFontSize(){
    return [TTDeviceUIUtils tt_newFontSize:17.f];
}

inline CGFloat FHMNBodyTextLabelTopPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:5.f];
}

inline CGFloat FHMNBodyTextLabelLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:61.f];
}

inline CGFloat FHMNBodyTextLabelDefaultRightPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat FHMNBodyTextLabelRightPaddingWithRef(){
    return [FHMessageNotificationCellHelper tt_newPadding:111.f];
}

inline CGFloat FHMNBodyTextLabelLineHeight(){
    return [TTDeviceUIUtils tt_newPadding:26.f];
}

inline NSInteger FHMNBodyTextLabelNumberOfLines(){
    return 0;
}

inline CGFloat FHMNTimeLabelFontSize(){
    return [FHMessageNotificationCellHelper tt_newFontSize:12.f];
}

inline CGFloat FHMNTimeLabelTopPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:7.f];
}

inline CGFloat FHMNTimeLabelLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:61.f];
}

inline CGFloat FHMNTimeLabelDefaultRightPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat FHMNTimeLabelRightPaddingWithRef(){
    return [FHMessageNotificationCellHelper tt_newPadding:111.f];
}

inline CGFloat FHMNTimeLabelBottomPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:12.f];
}

inline CGFloat FHMNTimeLabelHeight(){
    return [FHMessageNotificationCellHelper tt_newPadding:16.5f];
}

inline CGFloat FHMNMultiTextViewTopPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:12.f];
}

inline CGFloat FHMNMultiTextViewLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:51.f];
}

inline CGFloat FHMNMultiTextViewDefaultRightPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat FHMNMultiTextViewRightPaddingWithRef(){
    return [FHMessageNotificationCellHelper tt_newPadding:111.f];
}

inline CGFloat FHMNMultiTextViewHeight(){
    return [FHMessageNotificationCellHelper tt_newPadding:30.f];
}

inline CGFloat FHMNContactInfoLabelFontSize(){
    return [FHMessageNotificationCellHelper tt_newFontSize:12.f];
}

inline CGFloat FHMNContactInfoLabelTopPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:0.f];
}

inline CGFloat FHMNContactInfoLabelLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:61.f];
}

inline CGFloat FHMNContactInfoLabelDefaultRightPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat FHMNContactInfoLabelRightPaddingWithRef(){
    return [FHMessageNotificationCellHelper tt_newPadding:111.f];
}

inline CGFloat FHMNContactInfoLabelHeight(){
    return [FHMessageNotificationCellHelper tt_newPadding:16.5f];
}

inline CGFloat FHMNRoleInfoViewLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:61.f];
}

inline CGFloat FHMNRoleInfoViewDefaultRightPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat FHMNRoleInfoViewRightPaddingWithRef(){
    return [FHMessageNotificationCellHelper tt_newPadding:111.f];
}

inline CGFloat FHMNRoleInfoViewTopPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:12.f];
}

inline CGFloat FHMNRoleInfoViewFontSize(){
    return [FHMessageNotificationCellHelper tt_newFontSize:14.f];
}

inline CGFloat FHMNRoleInfoViewHeight(){
    if(![TTDeviceHelper isPadDevice]){
        return 17.f;
    }
    else{
        return 23.f;
    }
}

//保护用，避免一个字都显示不全的情况
inline CGFloat FHMNUserNameLabelMinWidth() {
    static CGFloat minWidth = 0.f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *minStr = @"一";
        CGSize minSize = [minStr sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FHMNRoleInfoViewFontSize()]}];
        minWidth = ceil(minSize.width);
    });
    return minWidth;
}

//NS_INLINE CGFloat kAvatarImageViewBorderWidth(){
//    return 0.5f;
//}

NS_INLINE CGFloat kRefImageViewBorderWidth(){
    return 0.5f;
}

NS_INLINE CGFloat kMultiTextLabelLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:11.f];
}

NS_INLINE CGFloat kMultiTextArrowLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:5.f];
}

NS_INLINE CGFloat kMultiTextArrowRightPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:11.f];
}

NS_INLINE CGFloat kMultiTextArrowWidth(){
    return [FHMessageNotificationCellHelper tt_newPadding:5.f];
}

NS_INLINE CGFloat kMultiTextArrowHeight(){
    return [FHMessageNotificationCellHelper tt_newPadding:8.f];
}

NS_INLINE CGFloat kMultiTextLabelFontSize(){
    return [FHMessageNotificationCellHelper tt_newFontSize:14.f];
}

NS_INLINE CGFloat kBottomLineViewLeftPadding(){
    return 0.f;
}

NS_INLINE CGFloat kBottomLineViewRightPadding(){
    return 0.f;
}

NS_INLINE CGFloat kBottomLineViewHeight(){
    return [TTDeviceHelper ssOnePixel];
}

NS_INLINE CGFloat kIconLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:2.f];
}

NS_INLINE CGFloat kIconSpacing(){
    return [FHMessageNotificationCellHelper tt_newPadding:3.f];
}

NS_INLINE CGFloat kRefPlayIconSize(){
    return [FHMessageNotificationCellHelper tt_newPadding:30.f];
}

@interface FHMessageNotificationBaseCellView()

@property (nonatomic, strong) SSThemedImageView       *multiTextArrow;  //展示聚合消息的箭头
@property (nonatomic, strong) SSThemedLabel           *multiTextLabel;  //展示聚合消息的内容

@end

@implementation FHMessageNotificationBaseCellView

+ (CGFloat)heightForData:(nullable TTMessageNotificationModel *)data cellWidth:(CGFloat)width{
    //subView implements....
    return 0;
}

+ (CGFloat)heightForBodyTextLabelWithData:(TTMessageNotificationModel *)data maxWidth:(CGFloat)maxWidth{
    NSMutableAttributedString *attributedString = [[TTUGCEmojiParser parseInCoreTextContext:data.content.bodyText
                                                                                   fontSize:FHMNBodyTextLabelFontSize()] mutableCopy];
    NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:FHMNBodyTextLabelFontSize()]
                                                    lineHeight:FHMNBodyTextLabelLineHeight()
                                                 lineBreakMode:NSLineBreakByWordWrapping
                                               firstLineIndent:0
                                                     alignment:NSTextAlignmentLeft];
    [attributedString addAttributes:attributes range:NSMakeRange(0, attributedString.length)];

    return [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                            withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                     limitedToNumberOfLines:0].height;
}

+ (CGFloat)heightForRefTextLabelWithData:(nullable TTMessageNotificationModel *)data maxWidth:(CGFloat)maxWidth{
    NSMutableAttributedString *refAttrString = [[TTUGCEmojiParser parseInCoreTextContext:data.content.refText
                                                                                fontSize:FHMNRefTextLabelFontSize()] mutableCopy];
    NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:FHMNRefTextLabelFontSize()]
                                                    lineHeight:FHMNRefTextLabelLineHeight()
                                                 lineBreakMode:NSLineBreakByWordWrapping
                                               firstLineIndent:0
                                                     alignment:NSTextAlignmentLeft];
    [refAttrString addAttributes:attributes range:NSMakeRange(0, refAttrString.length)];

    return [TTTAttributedLabel sizeThatFitsAttributedString:[refAttrString copy]
                                            withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                     limitedToNumberOfLines:FHMNRefTextLabelNumberOfLines()].height;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)refreshUI
{
    // subView implements.........
}

- (void)refreshWithData:(TTMessageNotificationModel *)data
{
    // subView implements.........
}

- (TTMessageNotificationModel *)cellData
{
    return self.messageModel;
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    // subView implements.........
    // 不实现点击态
}

- (TTAsyncCornerImageView *)avatarImageView{
    if(!_avatarImageView){
        _avatarImageView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0, FHMNAvatarImageViewSize(), FHMNAvatarImageViewSize()) allowCorner:YES];
        _avatarImageView.cornerRadius = FHMNAvatarImageViewSize() / 2;
        _avatarImageView.borderWidth = 0;
        _avatarImageView.borderColor = [UIColor clearColor];
        _avatarImageView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_avatarImageView addTouchTarget:self action:@selector(avatarImageViewOnClick)];
        [_avatarImageView setupVerifyViewForLength:kAvatarImageWidth adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [FHMessageNotificationCellHelper tt_newSize:standardSize];
        }];
        [self addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (void)avatarImageViewOnClick{
    [self showProfileIfNeeded];
}

- (TTIconLabel *)roleInfoView
{
    if (!_roleInfoView) {
        _roleInfoView = [[TTIconLabel alloc] init];
        _roleInfoView.font = [UIFont boldSystemFontOfSize:FHMNRoleInfoViewFontSize()];
        _roleInfoView.textColorThemeKey = kColorText1;
        _roleInfoView.iconLeftPadding = kIconLeftPadding();
        _roleInfoView.iconSpacing = kIconSpacing();
        [_roleInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewOnClick)]];
        [self addSubview:_roleInfoView];
    }

    return _roleInfoView;
}

- (void)roleInfoViewOnClick{
    [self showProfileIfNeeded];
}

- (void)showProfileIfNeeded{
    if([self.messageModel.user.userID longLongValue] > 0){
        ArticleMomentProfileViewController * controller = [[ArticleMomentProfileViewController alloc] initWithUserID:self.messageModel.user.userID];
        controller.fromPage = @"mine_msg_list";
        controller.categoryName = @"mine_tab";
        UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
        [topController.navigationController pushViewController:controller animated:YES];
    }
}

//- (TTUserInfoView *)roleInfoView{
//    if(!_roleInfoView){
//        _roleInfoView = [[TTUserInfoView alloc] initWithBaselineOrigin:CGPointZero
//                                                              maxWidth:0
//                                                           limitHeight:TTMNRoleInfoViewHeight()
//                                                                 title:nil
//                                                              fontSize:TTMNRoleInfoViewFontSize()
//                                                          verifiedInfo:nil
//                                                   appendLogoInfoArray:nil];
//        _roleInfoView.textColorThemedKey = kColorText5;
//        [self addSubview:_roleInfoView];
//    }
//    return _roleInfoView;
//
//}

- (SSThemedLabel *)refTextLabel{
    if(!_refTextLabel){
        _refTextLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _refTextLabel.font = [UIFont systemFontOfSize:FHMNRefTextLabelFontSize()];
        _refTextLabel.textColorThemeKey = kColorText1;
        _refTextLabel.numberOfLines = FHMNRefTextLabelNumberOfLines();
        _refTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _refTextLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_refTextLabel];
    }
    return _refTextLabel;
}

- (TTImageView *)refImageView{
    if(!_refImageView){
        _refImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _refImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _refImageView.borderColorThemeKey = kColorLine1;
        _refImageView.layer.borderWidth = kRefImageViewBorderWidth();
        [_refImageView addSubview:self.refPalyIcon];
        [self addSubview:_refImageView];
    }
    return _refImageView;
}

- (SSThemedImageView *)refPalyIcon{
    if(!_refPalyIcon){
        _refPalyIcon = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _refPalyIcon.contentMode = UIViewContentModeScaleAspectFill;
        _refPalyIcon.imageName = @"Play";
    }
    return _refPalyIcon;
}

- (SSThemedLabel *)bodyTextLabel{
    if(!_bodyTextLabel){
        _bodyTextLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _bodyTextLabel.font = [UIFont systemFontOfSize:FHMNBodyTextLabelFontSize()];
        _bodyTextLabel.textColorThemeKey = kColorText1;
        _bodyTextLabel.numberOfLines = FHMNBodyTextLabelNumberOfLines();
        _bodyTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _bodyTextLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_bodyTextLabel];
    }
    return _bodyTextLabel;
}

- (SSThemedLabel *)timeLabel{
    if(!_timeLabel){
        _timeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:FHMNTimeLabelFontSize()];
        _timeLabel.textColorThemeKey = kColorText3;
        _timeLabel.numberOfLines = 1;
        _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (SSThemedButton *)multiTextView{
    if(!_multiTextView){
        _multiTextView = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        //夜间模式的颜色
        _multiTextView.backgroundColorThemeKey = kColorBackground3;
        [_multiTextView addTarget:self action:@selector(multiTextViewOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_multiTextView addSubview:self.multiTextLabel];
        [_multiTextView addSubview:self.multiTextArrow];
        [self addSubview:_multiTextView];
    }
    return _multiTextView;
}

- (void)multiTextViewOnClick:(id)sender{
    if(!isEmptyString(self.messageModel.content.multiUrl)){
        wrapperTrackEventWithCustomKeys(@"message_cell", @"more", self.messageModel.ID, nil, [FHMessageNotificationCellHelper listCellLogExtraForData:self.messageModel]);
        NSURL *url = [TTStringHelper URLWithURLString:self.messageModel.content.multiUrl];
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

- (SSThemedImageView *)multiTextArrow{
    if(!_multiTextArrow){
        _multiTextArrow = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _multiTextArrow.contentMode = UIViewContentModeScaleAspectFill;
        _multiTextArrow.imageName = @"message_arrow";
    }
    return _multiTextArrow;
}

- (SSThemedLabel *)multiTextLabel{
    if(!_multiTextLabel){
        _multiTextLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _multiTextLabel.font = [UIFont systemFontOfSize:kMultiTextLabelFontSize()];
        _multiTextLabel.textColorThemeKey = kColorText5;
        _multiTextLabel.numberOfLines = 1;
        _multiTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _multiTextLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _multiTextLabel;
}

- (SSThemedLabel *)contactInfoLabel{
    if(!_contactInfoLabel){
        _contactInfoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _contactInfoLabel.font = [UIFont systemFontOfSize:FHMNContactInfoLabelFontSize()];
        _contactInfoLabel.textColorThemeKey = kColorText3;
        _contactInfoLabel.numberOfLines = 1;
        _contactInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contactInfoLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_contactInfoLabel];
    }
    return _contactInfoLabel;
}

- (SSThemedView *)bottomLineView{
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_bottomLineView];
    }
    return _bottomLineView;
}

- (void)updateAvatarImageView{
    self.avatarImageView.image = [UIImage themedImageNamed:@"defaulthead_message"];
    [self.avatarImageView tt_setImageWithURLString:self.messageModel.user.avatarUrl];
    [self.avatarImageView showOrHideVerifyViewWithVerifyInfo:self.messageModel.user.userAuthInfo decoratorInfo:self.messageModel.user.userDecoration sureQueryWithID:YES userID:nil];
}

- (void)updateRefTextLabel{
    if(!isEmptyString(self.messageModel.content.refText)){
        NSMutableAttributedString *refAttrString = [[TTUGCEmojiParser parseInTextKitContext:self.messageModel.content.refText fontSize:FHMNRefTextLabelFontSize()] mutableCopy];
        NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:FHMNRefTextLabelFontSize()]
                                                        lineHeight:FHMNRefTextLabelLineHeight()
                                                     lineBreakMode:NSLineBreakByTruncatingTail
                                                   firstLineIndent:0
                                                         alignment:NSTextAlignmentLeft];
        [refAttrString addAttributes:attributes range:NSMakeRange(0, refAttrString.length)];
        self.refTextLabel.attributedText = [refAttrString copy];
    }
    else{
        self.refTextLabel.attributedText = nil;
    }
}

- (void)updateRefImageView{
    if(!isEmptyString(self.messageModel.content.refThumbUrl)){
        [self.refImageView setImageWithURLString:self.messageModel.content.refThumbUrl];
    }
    else{
        self.refImageView.imageView.image = nil;
    }
}

- (void)updateBodyTextLabel{
    if(!isEmptyString(self.messageModel.content.bodyText)){
        NSMutableAttributedString *bodyAttrString = [[TTUGCEmojiParser parseInTextKitContext:self.messageModel.content.bodyText fontSize:FHMNBodyTextLabelFontSize()] mutableCopy];
        NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:FHMNBodyTextLabelFontSize()]
                                                        lineHeight:FHMNBodyTextLabelLineHeight()
                                                     lineBreakMode:NSLineBreakByWordWrapping
                                                   firstLineIndent:0
                                                         alignment:NSTextAlignmentLeft];
        [bodyAttrString addAttributes:attributes range:NSMakeRange(0, bodyAttrString.length)];
        self.bodyTextLabel.attributedText = [bodyAttrString copy];
    }
    else{
        self.bodyTextLabel.attributedText = nil;
    }
}

- (void)updateContactInfoLabel{
    if(!isEmptyString(self.messageModel.user.contactInfo)){
        self.contactInfoLabel.text = self.messageModel.user.contactInfo;
    }
    else{
        self.contactInfoLabel.text = nil;
    }
}

- (void)updateTimeLabel{
    if(!isEmptyString(self.messageModel.createTime)){
        self.timeLabel.text = [[TTIMDateFormatter sharedInstance] formattedDateWithSourceDate:[NSDate dateWithTimeIntervalSince1970:[self.messageModel.createTime integerValue]] showTime:NO];
    }
    else{
        self.timeLabel.text = nil;
    }
}

- (void)updateMultiTextView{
    if(!isEmptyString(self.messageModel.content.multiText)){
        self.multiTextLabel.text = self.messageModel.content.multiText;
        self.multiTextLabel.hidden = NO;
    }
    else{
        self.multiTextLabel.hidden = YES;
        self.multiTextLabel.text = nil;
    }
}

- (void)updateRoleInfoViewForMaxWidth:(CGFloat)maxWidth{
    self.roleInfoView.text = self.messageModel.user.screenName;
    [self.roleInfoView removeAllIcons];
    [self.messageModel.user.relationInfo enumerateObjectsUsingBlock:^(TTMessageNotificationIconModel *  _Nonnull iconModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.roleInfoView addIconWithDayIconURL:[NSURL URLWithString:iconModel.url] nightIconURL:nil size:CGSizeMake(iconModel.width.doubleValue, iconModel.height.doubleValue)];
        //加保护，避免icon过长，文字连一个都显示不下来
        if(self.roleInfoView.iconContainerWidth >= maxWidth - FHMNUserNameLabelMinWidth()){
            [self.roleInfoView removeIconAtIndex:idx];
            *stop = YES;
        }
    }];

    self.roleInfoView.labelMaxWidth = maxWidth - self.roleInfoView.iconContainerWidth;
    [self.roleInfoView refreshIconView];
}

//- (void)updateRoleInfoViewForMaxWidth:(CGFloat)maxWidth{
//    [self.roleInfoView refreshWithTitle:self.messageModel.user.screenName relation:nil verifiedInfo:nil verified:NO owner:NO maxWidth:maxWidth appendLogoInfoArray:self.messageModel.user.relationInfo];
//}

- (void)layoutAvatarImageView{
    self.avatarImageView.origin = CGPointMake(FHMNAvatarImageViewLeftPadding(), FHMNAvatarImageViewTopPadding());
}

- (void)layoutRoleInfoView{
    self.roleInfoView.left = FHMNRoleInfoViewLeftPadding();
    self.roleInfoView.top = FHMNRoleInfoViewTopPadding();
}

- (void)layoutContactInfoLabelWithOrigin:(CGPoint)origin maxWitdh:(CGFloat)maxWidh{
    [self.contactInfoLabel sizeToFit];
    self.contactInfoLabel.origin = origin;
    self.contactInfoLabel.size = CGSizeMake(MIN(self.contactInfoLabel.width, maxWidh), FHMNContactInfoLabelHeight());
}

- (void)layoutBodyTextLabelWithOrigin:(CGPoint)origin maxWidth:(CGFloat)maxWidth{
    self.bodyTextLabel.origin = origin;

    CGFloat height = [[self class] heightForBodyTextLabelWithData:self.messageModel maxWidth:maxWidth];
    self.bodyTextLabel.size = CGSizeMake(maxWidth, height);
}

- (void)layoutMultiTextViewWithOrigin:(CGPoint)origin maxWitdh:(CGFloat)maxWidth{
    self.multiTextView.origin = origin;

    [self.multiTextLabel sizeToFit];
    self.multiTextLabel.width = MIN(self.multiTextLabel.width, maxWidth - kMultiTextLabelLeftPadding() - kMultiTextArrowLeftPadding() - kMultiTextArrowWidth() - kMultiTextArrowRightPadding());

    self.multiTextView.size = CGSizeMake(kMultiTextLabelLeftPadding() + self.multiTextLabel.width + kMultiTextArrowLeftPadding() + kMultiTextArrowWidth() + kMultiTextArrowRightPadding(), FHMNMultiTextViewHeight());
    self.multiTextView.layer.cornerRadius = FHMNMultiTextViewHeight() / 2.f;

    self.multiTextLabel.left = kMultiTextLabelLeftPadding();
    self.multiTextLabel.centerY = FHMNMultiTextViewHeight() / 2.f;

    self.multiTextArrow.size = CGSizeMake(kMultiTextArrowWidth(), kMultiTextArrowHeight());
    self.multiTextArrow.left = self.multiTextLabel.right + kMultiTextArrowLeftPadding();
    self.multiTextArrow.centerY = FHMNMultiTextViewHeight() / 2.f;
}

- (void)layoutTimeLabelWithOrigin:(CGPoint)origin maxWidth:(CGFloat)maxWidth{
    self.timeLabel.origin = origin;

    [self.timeLabel sizeToFit];
    self.timeLabel.size = CGSizeMake(MIN(self.timeLabel.width, maxWidth), FHMNTimeLabelHeight());
}

- (void)layoutRefTextLabel{
    CGFloat refTextLabelHeight = [[self class] heightForRefTextLabelWithData:self.messageModel maxWidth:FHMNRefTextLabelWidth()];
    self.refTextLabel.frame = CGRectMake(self.width - FHMNRefTextLabelWidth() - FHMNRefRightPadding(), FHMNRefTopPadding(), FHMNRefTextLabelWidth(), refTextLabelHeight);
}

- (void)layoutRefImageView{
    self.refImageView.frame = CGRectMake(self.width - FHMNRefImageViewSize() - FHMNRefRightPadding(), FHMNRefTopPadding(), FHMNRefImageViewSize(), FHMNRefImageViewSize());
    if([self.messageModel.content.refImageType isEqualToString:@"video"]){
        self.refPalyIcon.hidden = NO;
        self.refPalyIcon.size = CGSizeMake(kRefPlayIconSize(), kRefPlayIconSize());
        self.refPalyIcon.center = CGPointMake(FHMNRefImageViewSize() / 2.f, FHMNRefImageViewSize() / 2.f);
    }
    else{
        self.refPalyIcon.hidden = YES;
    }
}

- (void)layoutBottomLine
{
    self.bottomLineView.frame = CGRectMake(kBottomLineViewLeftPadding(),  self.height - kBottomLineViewHeight(), self.width - kBottomLineViewLeftPadding() - kBottomLineViewRightPadding(), kBottomLineViewHeight());
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
    self.avatarImageView.image = [UIImage themedImageNamed:@"defaulthead_message"];
}

@end

//
//  TTMessageNotificationBaseCellView.m
//  Article
//
//  Created by 邱鑫玥 on 2017/4/7.
//
//

#import <TTBaseLib/NSString-Extension.h>
#import "TTMessageNotificationBaseCellView.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "TTMessageNotificationCellHelper.h"
#import "UIColor+TTThemeExtension.h"
#import "SSThemed.h" 
#import "TTMessageNotificationModel.h"
#import "TTIconLabel+TTImageInfosModel.h"
#import "TTImageView.h"
#import "TTIMDateFormatter.h"
#import "TTLabelTextHelper.h"
#import "TTMessageNotificationCellHelper.h"
#import "TTDeviceHelper.h"
#import "TTRoute.h"
#import "TTMessageNotificationMacro.h"
#import "ArticleMomentProfileViewController.h"
#import "SSWebViewController.h"
#import "TTUIResponderHelper.h"
#import "TTUGCEmojiParser.h"
#import "TTTAttributedLabel.h"
#import <TTInstallJSONHelper.h>

#define kAvatarImageWidth 36.f

inline CGFloat TTMNAvatarImageViewSize(){
    return [TTMessageNotificationCellHelper tt_newPadding:36.f];
}

inline CGFloat TTMNAvatarImageViewLeftPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat TTMNAvatarImageViewTopPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:12.f];
}

inline CGFloat TTMNRefTextLabelFontSize(){
    return [TTMessageNotificationCellHelper tt_newFontSize:12.f];
}

inline CGFloat TTMNRefTextLabelLineHeight(){
    return [TTMessageNotificationCellHelper tt_newPadding:17.f];
}

inline NSInteger TTMNRefTextLabelNumberOfLines(){
    return 3;
}

inline CGFloat TTMNRefTextLabelWidth(){
    return [TTMessageNotificationCellHelper tt_newPadding:72.f];
}

inline CGFloat TTMNRefImageViewSize(){
    return [TTMessageNotificationCellHelper tt_newPadding:72.f];
}

inline CGFloat TTMNRefTopPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:12.f];
}

inline CGFloat TTMNRefRightPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat TTMNBodyTextLabelFontSize(){
    return [TTDeviceUIUtils tt_newFontSize:17.f];
}

inline CGFloat TTMNBodyTextLabelTopPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:5.f];
}

inline CGFloat TTMNBodyTextLabelLeftPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:61.f];
}

inline CGFloat TTMNBodyTextLabelDefaultRightPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat TTMNBodyTextLabelRightPaddingWithRef(){
    return [TTMessageNotificationCellHelper tt_newPadding:111.f];
}

inline CGFloat TTMNBodyTextLabelLineHeight(){
    return [TTDeviceUIUtils tt_newPadding:26.f];
}

inline NSInteger TTMNBodyTextLabelNumberOfLines(){
    return 0;
}

inline CGFloat TTMNTimeLabelFontSize(){
    return [TTMessageNotificationCellHelper tt_newFontSize:12.f];
}

inline CGFloat TTMNTimeLabelTopPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:7.f];
}

inline CGFloat TTMNTimeLabelLeftPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:61.f];
}

inline CGFloat TTMNTimeLabelDefaultRightPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat TTMNTimeLabelRightPaddingWithRef(){
    return [TTMessageNotificationCellHelper tt_newPadding:111.f];
}

inline CGFloat TTMNTimeLabelBottomPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:12.f];
}

inline CGFloat TTMNTimeLabelHeight(){
    return [TTMessageNotificationCellHelper tt_newPadding:16.5f];
}

inline CGFloat TTMNMultiTextViewTopPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:12.f];
}

inline CGFloat TTMNMultiTextViewLeftPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:51.f];
}

inline CGFloat TTMNMultiTextViewDefaultRightPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat TTMNMultiTextViewRightPaddingWithRef(){
    return [TTMessageNotificationCellHelper tt_newPadding:111.f];
}

inline CGFloat TTMNMultiTextViewHeight(){
    return [TTMessageNotificationCellHelper tt_newPadding:30.f];
}

inline CGFloat TTMNContactInfoLabelFontSize(){
    return [TTMessageNotificationCellHelper tt_newFontSize:12.f];
}

inline CGFloat TTMNContactInfoLabelTopPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:0.f];
}

inline CGFloat TTMNContactInfoLabelLeftPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:61.f];
}

inline CGFloat TTMNContactInfoLabelDefaultRightPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat TTMNContactInfoLabelRightPaddingWithRef(){
    return [TTMessageNotificationCellHelper tt_newPadding:111.f];
}

inline CGFloat TTMNContactInfoLabelHeight(){
    return [TTMessageNotificationCellHelper tt_newPadding:16.5f];
}

inline CGFloat TTMNRoleInfoViewLeftPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:61.f];
}

inline CGFloat TTMNRoleInfoViewDefaultRightPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:15.f];
}

inline CGFloat TTMNRoleInfoViewRightPaddingWithRef(){
    return [TTMessageNotificationCellHelper tt_newPadding:111.f];
}

inline CGFloat TTMNRoleInfoViewTopPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:12.f];
}

inline CGFloat TTMNRoleInfoViewFontSize(){
    return [TTMessageNotificationCellHelper tt_newFontSize:14.f];
}

inline CGFloat TTMNRoleInfoViewHeight(){
    if(![TTDeviceHelper isPadDevice]){
        return 17.f;
    }
    else{
        return 23.f;
    }
}

//保护用，避免一个字都显示不全的情况
inline CGFloat TTMNUserNameLabelMinWidth() {
    static CGFloat minWidth = 0.f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *minStr = @"一";
        CGSize minSize = [minStr sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:TTMNRoleInfoViewFontSize()]}];
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
    return [TTMessageNotificationCellHelper tt_newPadding:11.f];
}

NS_INLINE CGFloat kMultiTextArrowLeftPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:5.f];
}

NS_INLINE CGFloat kMultiTextArrowRightPadding(){
    return [TTMessageNotificationCellHelper tt_newPadding:11.f];
}

NS_INLINE CGFloat kMultiTextArrowWidth(){
    return [TTMessageNotificationCellHelper tt_newPadding:5.f];
}

NS_INLINE CGFloat kMultiTextArrowHeight(){
    return [TTMessageNotificationCellHelper tt_newPadding:8.f];
}

NS_INLINE CGFloat kMultiTextLabelFontSize(){
    return [TTMessageNotificationCellHelper tt_newFontSize:14.f];
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
    return [TTMessageNotificationCellHelper tt_newPadding:2.f];
}

NS_INLINE CGFloat kIconSpacing(){
    return [TTMessageNotificationCellHelper tt_newPadding:3.f];
}

NS_INLINE CGFloat kRefPlayIconSize(){
    return [TTMessageNotificationCellHelper tt_newPadding:30.f];
}

@interface TTMessageNotificationBaseCellView()

@property (nonatomic, strong) SSThemedImageView       *multiTextArrow;  //展示聚合消息的箭头
@property (nonatomic, strong) SSThemedLabel           *multiTextLabel;  //展示聚合消息的内容

@end

@implementation TTMessageNotificationBaseCellView

+ (CGFloat)heightForData:(nullable TTMessageNotificationModel *)data cellWidth:(CGFloat)width{
    //subView implements....
    return 0;
}

+ (CGFloat)heightForBodyTextLabelWithData:(TTMessageNotificationModel *)data maxWidth:(CGFloat)maxWidth{
    NSMutableAttributedString *attributedString = [[TTUGCEmojiParser parseInCoreTextContext:data.content.bodyText
                                                                                   fontSize:TTMNBodyTextLabelFontSize()] mutableCopy];
    NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:TTMNBodyTextLabelFontSize()]
                                                    lineHeight:TTMNBodyTextLabelLineHeight()
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
                                                                                fontSize:TTMNRefTextLabelFontSize()] mutableCopy];
    NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:TTMNRefTextLabelFontSize()]
                                                    lineHeight:TTMNRefTextLabelLineHeight()
                                                 lineBreakMode:NSLineBreakByWordWrapping
                                               firstLineIndent:0
                                                     alignment:NSTextAlignmentLeft];
    [refAttrString addAttributes:attributes range:NSMakeRange(0, refAttrString.length)];

    return [TTTAttributedLabel sizeThatFitsAttributedString:[refAttrString copy]
                                            withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                     limitedToNumberOfLines:TTMNRefTextLabelNumberOfLines()].height;
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
        _avatarImageView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0, TTMNAvatarImageViewSize(), TTMNAvatarImageViewSize()) allowCorner:YES];
        _avatarImageView.cornerRadius = TTMNAvatarImageViewSize() / 2;
        _avatarImageView.borderWidth = 0;
        _avatarImageView.borderColor = [UIColor clearColor];
        _avatarImageView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_avatarImageView addTouchTarget:self action:@selector(avatarImageViewOnClick)];
        [_avatarImageView setupVerifyViewForLength:kAvatarImageWidth adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTMessageNotificationCellHelper tt_newSize:standardSize];
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
        _roleInfoView.font = [UIFont boldSystemFontOfSize:TTMNRoleInfoViewFontSize()];
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
        _refTextLabel.font = [UIFont systemFontOfSize:TTMNRefTextLabelFontSize()];
        _refTextLabel.textColorThemeKey = kColorText1;
        _refTextLabel.numberOfLines = TTMNRefTextLabelNumberOfLines();
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
        _bodyTextLabel.font = [UIFont systemFontOfSize:TTMNBodyTextLabelFontSize()];
        _bodyTextLabel.textColorThemeKey = kColorText1;
        _bodyTextLabel.numberOfLines = TTMNBodyTextLabelNumberOfLines();
        _bodyTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _bodyTextLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_bodyTextLabel];
    }
    return _bodyTextLabel;
}

- (SSThemedLabel *)timeLabel{
    if(!_timeLabel){
        _timeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:TTMNTimeLabelFontSize()];
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
        wrapperTrackEventWithCustomKeys(@"message_cell", @"more", self.messageModel.ID, nil, [TTMessageNotificationCellHelper listCellLogExtraForData:self.messageModel]);
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
        _contactInfoLabel.font = [UIFont systemFontOfSize:TTMNContactInfoLabelFontSize()];
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
        NSMutableAttributedString *refAttrString = [[TTUGCEmojiParser parseInTextKitContext:self.messageModel.content.refText fontSize:TTMNRefTextLabelFontSize()] mutableCopy];
        NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:TTMNRefTextLabelFontSize()]
                                                        lineHeight:TTMNRefTextLabelLineHeight()
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
        NSMutableAttributedString *bodyAttrString = [[TTUGCEmojiParser parseInTextKitContext:self.messageModel.content.bodyText fontSize:TTMNBodyTextLabelFontSize()] mutableCopy];
        NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:TTMNBodyTextLabelFontSize()]
                                                        lineHeight:TTMNBodyTextLabelLineHeight()
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
        if(self.roleInfoView.iconContainerWidth >= maxWidth - TTMNUserNameLabelMinWidth()){
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
    self.avatarImageView.origin = CGPointMake(TTMNAvatarImageViewLeftPadding(), TTMNAvatarImageViewTopPadding());
}

- (void)layoutRoleInfoView{
    self.roleInfoView.left = TTMNRoleInfoViewLeftPadding();
    self.roleInfoView.top = TTMNRoleInfoViewTopPadding();
}

- (void)layoutContactInfoLabelWithOrigin:(CGPoint)origin maxWitdh:(CGFloat)maxWidh{
    [self.contactInfoLabel sizeToFit];
    self.contactInfoLabel.origin = origin;
    self.contactInfoLabel.size = CGSizeMake(MIN(self.contactInfoLabel.width, maxWidh), TTMNContactInfoLabelHeight());
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
    
    self.multiTextView.size = CGSizeMake(kMultiTextLabelLeftPadding() + self.multiTextLabel.width + kMultiTextArrowLeftPadding() + kMultiTextArrowWidth() + kMultiTextArrowRightPadding(), TTMNMultiTextViewHeight());
    self.multiTextView.layer.cornerRadius = TTMNMultiTextViewHeight() / 2.f;
    
    self.multiTextLabel.left = kMultiTextLabelLeftPadding();
    self.multiTextLabel.centerY = TTMNMultiTextViewHeight() / 2.f;
    
    self.multiTextArrow.size = CGSizeMake(kMultiTextArrowWidth(), kMultiTextArrowHeight());
    self.multiTextArrow.left = self.multiTextLabel.right + kMultiTextArrowLeftPadding();
    self.multiTextArrow.centerY = TTMNMultiTextViewHeight() / 2.f;    
}

- (void)layoutTimeLabelWithOrigin:(CGPoint)origin maxWidth:(CGFloat)maxWidth{
    self.timeLabel.origin = origin;
    
    [self.timeLabel sizeToFit];
    self.timeLabel.size = CGSizeMake(MIN(self.timeLabel.width, maxWidth), TTMNTimeLabelHeight());
}

- (void)layoutRefTextLabel{
    CGFloat refTextLabelHeight = [[self class] heightForRefTextLabelWithData:self.messageModel maxWidth:TTMNRefTextLabelWidth()];
    self.refTextLabel.frame = CGRectMake(self.width - TTMNRefTextLabelWidth() - TTMNRefRightPadding(), TTMNRefTopPadding(), TTMNRefTextLabelWidth(), refTextLabelHeight);
}

- (void)layoutRefImageView{
    self.refImageView.frame = CGRectMake(self.width - TTMNRefImageViewSize() - TTMNRefRightPadding(), TTMNRefTopPadding(), TTMNRefImageViewSize(), TTMNRefImageViewSize());
    if([self.messageModel.content.refImageType isEqualToString:@"video"]){
        self.refPalyIcon.hidden = NO;
        self.refPalyIcon.size = CGSizeMake(kRefPlayIconSize(), kRefPlayIconSize());
        self.refPalyIcon.center = CGPointMake(TTMNRefImageViewSize() / 2.f, TTMNRefImageViewSize() / 2.f);
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

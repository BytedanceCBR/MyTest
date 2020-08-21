//
//  TTMessageNotificationBaseCellView.m
//  Article
//
//  Created by zhulijun.2539 on 2019/6/17.
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
#import <BDWebImage/BDWebImage.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/UIImage+FIconFont.h>

#define kAvatarImageWidth 36.f

inline CGFloat FHMNAvatarImageViewSize() {
    return 36.0f;
}

inline CGFloat FHMNAvatarImageViewLeftPadding() {
    return 20.f;
}

inline CGFloat FHMNAvatarImageViewTopPadding() {
    return 16.f;
}

inline CGFloat FHMNRefTextLabelFontSize() {
    return 12.f;
}

inline CGFloat FHMNRefTextLabelLineHeight() {
    return 17.f;
}

inline NSInteger FHMNRefTextLabelNumberOfLines() {
    return 4;
}

inline CGFloat FHMNRefTextLabelWidth() {
    return 72.f;
}

inline CGFloat FHMNRefImageViewSize() {
    return 72.f;
}

inline CGFloat FHMNRefImageViewCornerRadius() {
    return 4.0f;
}

inline CGFloat FHMNRefTopPadding() {
    return 16.f;
}

inline CGFloat FHMNRefRightPadding() {
    return 20.f;
}

inline CGFloat FHMNBodyTextLabelFontSize() {
    return 16.f;
}

inline CGFloat FHMNBodyTextLabelTopPadding() {
    return 6.f;
}

inline CGFloat FHMNBodyTextLabelLeftPadding() {
    return 66.f;
}

inline CGFloat FHMNBodyTextLabelRightPaddingWithRef() {
    return 112.f;
}

inline CGFloat FHMNBodyTextLabelLineHeight() {
    return 26.f;
}

inline NSInteger FHMNBodyTextLabelNumberOfLines() {
    return 3;
}

inline CGFloat FHMNTimeLabelFontSize() {
    return 12.f;
}

inline CGFloat FHMNTimeLabelTopPadding() {
    return 6.f;
}

inline CGFloat FHMNTimeLabelLeftPadding() {
    return 66.f;
}

inline CGFloat FHMNTimeLabelRightPaddingWithRef() {
    return 112.f;
}

inline CGFloat FHMNTimeLabelBottomPadding() {
    return 15.f;
}

inline CGFloat FHMNTimeLabelHeight() {
    return 17.f;
}

inline CGFloat FHMNMultiTextViewTopPadding() {
    return 10.f;
}

inline CGFloat FHMNMultiTextViewLeftPadding() {
    return 66.f;
}

inline CGFloat FHMNMultiTextViewRightPaddingWithRef() {
    return 112.f;
}

inline CGFloat FHMNMultiTextViewHeight() {
    return 32.f;
}

inline CGFloat FHMNRoleInfoViewLeftPadding() {
    return 66.f;
}

inline CGFloat FHMNRoleInfoViewRightPaddingWithRef() {
    return 112.f;
}

inline CGFloat FHMNRoleInfoViewTopPadding() {
    return 16.f;
}

inline CGFloat FHMNRoleInfoViewFontSize() {
    return 14.f;
}

inline CGFloat FHMNRoleInfoViewHeight() {
    return 20.f;
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

NS_INLINE CGFloat kRefImageViewBorderWidth() {
    return 0.5f;
}

NS_INLINE CGFloat kMultiTextLabelLeftPadding() {
    return 10.f;
}

NS_INLINE CGFloat kMultiTextArrowLeftPadding() {
    return 4.f;
}

NS_INLINE CGFloat kMultiTextArrowRightPadding() {
    return 10.f;
}

NS_INLINE CGFloat kMultiTextArrowWidth() {
    return 12.f;
}

NS_INLINE CGFloat kMultiTextArrowHeight() {
    return 12.f;
}

NS_INLINE CGFloat kMultiTextLabelFontSize() {
    return 14.f;
}

NS_INLINE CGFloat kBottomLineViewLeftPadding() {
    return 20.f;
}

NS_INLINE CGFloat kBottomLineViewRightPadding() {
    return 0.f;
}

NS_INLINE CGFloat kBottomLineViewHeight() {
    return [TTDeviceHelper ssOnePixel];
}

@implementation FHMessageNotificationBaseCellView

+ (CGFloat)heightForData:(nullable TTMessageNotificationModel *)data cellWidth:(CGFloat)width {
    //subView implements....
    return 0;
}

+ (CGFloat)heightForBodyTextLabelWithData:(TTMessageNotificationModel *)data maxWidth:(CGFloat)maxWidth {
    NSMutableAttributedString *attributedString = [[TTUGCEmojiParser parseInCoreTextContext:data.content.bodyText
                                                                                   fontSize:FHMNBodyTextLabelFontSize()] mutableCopy];
    NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:FHMNBodyTextLabelFontSize()]
                                                    lineHeight:FHMNBodyTextLabelLineHeight()
                                                 lineBreakMode:NSLineBreakByWordWrapping
                                               firstLineIndent:0
                                                     alignment:NSTextAlignmentLeft];
    [attributedString addAttributes:attributes range:NSMakeRange(0, attributedString.length)];

    return [TTUGCAsyncAttributedLabel sizeThatFitsAttributedString:attributedString
                                            withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                     limitedToNumberOfLines:FHMNBodyTextLabelNumberOfLines()].height;
}

+ (CGFloat)heightForRefTextLabelWithData:(nullable TTMessageNotificationModel *)data maxWidth:(CGFloat)maxWidth {
    NSMutableAttributedString *refAttrString = [[TTUGCEmojiParser parseInCoreTextContext:data.content.refText
                                                                                fontSize:FHMNRefTextLabelFontSize()] mutableCopy];
    NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:FHMNRefTextLabelFontSize()]
                                                    lineHeight:FHMNRefTextLabelLineHeight()
                                                 lineBreakMode:NSLineBreakByWordWrapping
                                               firstLineIndent:0
                                                     alignment:NSTextAlignmentLeft];
    [refAttrString addAttributes:attributes range:NSMakeRange(0, refAttrString.length)];

    return [TTUGCAsyncAttributedLabel sizeThatFitsAttributedString:[refAttrString copy]
                                            withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                     limitedToNumberOfLines:FHMNRefTextLabelNumberOfLines()].height;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)refreshUI {
    // subView implements.........
}

- (void)refreshWithData:(TTMessageNotificationModel *)data {
    // subView implements.........
}

- (TTMessageNotificationModel *)cellData {
    return self.messageModel;
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    // subView implements.........
    // 不实现点击态
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, FHMNAvatarImageViewSize(), FHMNAvatarImageViewSize())];
        _avatarImageView.layer.cornerRadius = FHMNAvatarImageViewSize() / 2;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_avatarImageView];
        
        _avatarImageView.userInteractionEnabled = YES;
         UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPersonalHomePage)];
        [_avatarImageView addGestureRecognizer:tap];
    }
    return _avatarImageView;
}

- (UILabel *)roleInfoView {
    if (!_roleInfoView) {
        _roleInfoView = [[UILabel alloc] init];
        _roleInfoView.font = [UIFont systemFontOfSize:FHMNRoleInfoViewFontSize()];
        _roleInfoView.textColor = [UIColor themeGray1];
        [self addSubview:_roleInfoView];
        
        _roleInfoView.userInteractionEnabled = YES;
         UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPersonalHomePage)];
        [_roleInfoView addGestureRecognizer:tap];
    }
    return _roleInfoView;
}

- (UILabel *)refTextLabel {
    if (!_refTextLabel) {
        _refTextLabel = [[TTUGCAsyncAttributedLabel alloc] initWithFrame:CGRectZero];
        _refTextLabel.font = [UIFont systemFontOfSize:FHMNRefTextLabelFontSize()];
        _refTextLabel.textColor = [UIColor themeGray2];
        _refTextLabel.numberOfLines = FHMNRefTextLabelNumberOfLines();
        [self addSubview:_refTextLabel];
    }
    return _refTextLabel;
}

- (UIImageView *)refImageView {
    if (!_refImageView) {
        _refImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _refImageView.contentMode = UIViewContentModeScaleAspectFill;
        _refImageView.layer.borderColor = [UIColor themeGray6].CGColor;
        _refImageView.layer.borderWidth = kRefImageViewBorderWidth();
        _refImageView.layer.cornerRadius = FHMNRefImageViewCornerRadius();
        _refImageView.clipsToBounds = YES;
        [self addSubview:_refImageView];
    }
    return _refImageView;
}

- (UILabel *)bodyTextLabel {
    if (!_bodyTextLabel) {
        _bodyTextLabel = [[TTUGCAsyncAttributedLabel alloc] initWithFrame:CGRectZero];
        _bodyTextLabel.font = [UIFont systemFontOfSize:FHMNBodyTextLabelFontSize()];
        _bodyTextLabel.textColor = [UIColor themeGray1];
        _bodyTextLabel.numberOfLines = FHMNBodyTextLabelNumberOfLines();
        [self addSubview:_bodyTextLabel];
    }
    return _bodyTextLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:FHMNTimeLabelFontSize()];
        _timeLabel.textColor = [UIColor themeGray2];
        _timeLabel.numberOfLines = 1;
        _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UIButton *)multiTextView {
    if (!_multiTextView) {
        _multiTextView = [[UIView alloc] initWithFrame:CGRectZero];
        //夜间模式的颜色
        _multiTextView.backgroundColor = [UIColor themeRed2];
//        [_multiTextView addTarget:self action:@selector(multiTextViewOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_multiTextView addSubview:self.multiTextLabel];
        [_multiTextView addSubview:self.multiTextArrow];
        [self addSubview:_multiTextView];
    }
    return _multiTextView;
}

- (void)multiTextViewOnClick:(id)sender {
    if (!isEmptyString(self.messageModel.content.multiUrl)) {
        wrapperTrackEventWithCustomKeys(@"message_cell", @"more", self.messageModel.ID, nil, [FHMessageNotificationCellHelper listCellLogExtraForData:self.messageModel]);
        NSURL *url = [TTStringHelper URLWithURLString:self.messageModel.content.multiUrl];
        NSString *URLString = url.absoluteString;
        
        NSMutableDictionary *dict = @{}.mutableCopy;
        if([URLString containsString:@"comment_detail"]){
            //dict[@"hidePost"] = @(1);
        }
        NSMutableDictionary *traceParam = [NSMutableDictionary dictionary];
        traceParam[@"enter_from"] = @"feed_message_list";
        traceParam[@"enter_type"] = @"feed_message_card";
        traceParam[@"rank"] = self.messageModel.index;
        traceParam[@"log_pb"] = self.messageModel.logPb;
        dict[@"tracer"] = traceParam;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        } else if ([URLString hasPrefix:@"http://"] || [URLString hasPrefix:@"https://"]) {
            UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
            ssOpenWebView(url, @"", topController.navigationController, NO, nil);
        } else if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (UIImageView *)multiTextArrow {
    if (!_multiTextArrow) {
        _multiTextArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
        _multiTextArrow.contentMode = UIViewContentModeCenter;
        _multiTextArrow.image =  ICON_FONT_IMG(12, @"\U0000e670", [UIColor themeRed1]);//@"message_merge_arrow"
    }
    return _multiTextArrow;
}

- (UILabel *)multiTextLabel {
    if (!_multiTextLabel) {
        _multiTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _multiTextLabel.font = [UIFont systemFontOfSize:kMultiTextLabelFontSize()];
        _multiTextLabel.textColor = [UIColor themeRed3];
        _multiTextLabel.numberOfLines = 1;
        _multiTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _multiTextLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _multiTextLabel;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = [UIColor themeGray6];
        [self addSubview:_bottomLineView];
    }
    return _bottomLineView;
}

- (void)updateAvatarImageView {
    self.avatarImageView.image = [UIImage themedImageNamed:@"defaulthead_message"];
    [self.avatarImageView bd_setImageWithURL:[NSURL URLWithString:self.messageModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"big_defaulthead_head"]];
}

- (void)updateRefTextLabel {
    if (!isEmptyString(self.messageModel.content.refText)) {
        NSMutableAttributedString *refAttrString = [[TTUGCEmojiParser parseInCoreTextContext:self.messageModel.content.refText fontSize:FHMNRefTextLabelFontSize()] mutableCopy];
        NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:FHMNRefTextLabelFontSize()]
                                                        lineHeight:FHMNRefTextLabelLineHeight()
                                                     lineBreakMode:NSLineBreakByWordWrapping
                                                   firstLineIndent:0
                                                         alignment:NSTextAlignmentLeft];
        [refAttrString addAttributes:attributes range:NSMakeRange(0, refAttrString.length)];
        [refAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor themeGray2] range:NSMakeRange(0, refAttrString.length)];
        
        [self.refTextLabel setText: [refAttrString copy]];
    } else {
        [self.refTextLabel setText: nil];
    }
}

- (void)updateRefImageView {
    if (!isEmptyString(self.messageModel.content.refThumbUrl)) {
        [self.refImageView bd_setImageWithURL:[NSURL URLWithString:self.messageModel.content.refThumbUrl]];
    } else {
        self.refImageView.image = nil;
    }
}

- (void)updateBodyTextLabel {
    if (!isEmptyString(self.messageModel.content.bodyText)) {
        NSMutableAttributedString *bodyAttrString = [[TTUGCEmojiParser parseInCoreTextContext:self.messageModel.content.bodyText fontSize:FHMNBodyTextLabelFontSize()] mutableCopy];
        NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:FHMNBodyTextLabelFontSize()]
                                                        lineHeight:FHMNBodyTextLabelLineHeight()
                                                     lineBreakMode:NSLineBreakByWordWrapping
                                                   firstLineIndent:0
                                                         alignment:NSTextAlignmentLeft];
        [bodyAttrString addAttributes:attributes range:NSMakeRange(0, bodyAttrString.length)];
        [bodyAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor themeGray1] range:NSMakeRange(0, bodyAttrString.length)];
        [self.bodyTextLabel setText:[bodyAttrString copy]];
    } else {
        [self.bodyTextLabel setText:nil];
    }
}

- (void)updateTimeLabel {
    if (!isEmptyString(self.messageModel.createTime)) {
        self.timeLabel.text = [[TTIMDateFormatter sharedInstance] formattedDateWithSourceDate:[NSDate dateWithTimeIntervalSince1970:[self.messageModel.createTime integerValue]] showTime:NO];
    } else {
        self.timeLabel.text = nil;
    }
}

- (void)updateMultiTextView {
    if (!isEmptyString(self.messageModel.content.multiText)) {
        self.multiTextLabel.text = self.messageModel.content.multiText;
        self.multiTextLabel.hidden = NO;
    } else {
        self.multiTextLabel.hidden = YES;
        self.multiTextLabel.text = nil;
    }
}

- (void)layoutAvatarImageView {
    self.avatarImageView.origin = CGPointMake(FHMNAvatarImageViewLeftPadding(), FHMNAvatarImageViewTopPadding());
}

- (void)layoutRoleInfoView {
    self.roleInfoView.text = self.messageModel.user.screenName;
    self.roleInfoView.left = FHMNRoleInfoViewLeftPadding();
    self.roleInfoView.top = FHMNRoleInfoViewTopPadding();
    self.roleInfoView.height = FHMNRoleInfoViewHeight();

    CGSize size = [_roleInfoView sizeThatFits:CGSizeMake(self.width - FHMNRoleInfoViewLeftPadding() - FHMNRefImageViewSize() - FHMNRefRightPadding() - 15 , FHMNRoleInfoViewHeight())];
    if(size.width < self.width - FHMNRoleInfoViewLeftPadding() - FHMNRefImageViewSize() - FHMNRefRightPadding() - 15){
        self.roleInfoView.width = size.width;
    }else{
        self.roleInfoView.width = self.width - FHMNRoleInfoViewLeftPadding() - FHMNRefImageViewSize() - FHMNRefRightPadding() - 15;
    }
}

- (void)layoutBodyTextLabelWithOrigin:(CGPoint)origin maxWidth:(CGFloat)maxWidth {
    self.bodyTextLabel.origin = origin;

    CGFloat height = [[self class] heightForBodyTextLabelWithData:self.messageModel maxWidth:maxWidth];
    self.bodyTextLabel.size = CGSizeMake(maxWidth, height);
}

- (void)layoutMultiTextViewWithOrigin:(CGPoint)origin maxWitdh:(CGFloat)maxWidth {
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

- (void)layoutTimeLabelWithOrigin:(CGPoint)origin maxWidth:(CGFloat)maxWidth {
    self.timeLabel.origin = origin;

    [self.timeLabel sizeToFit];
    self.timeLabel.size = CGSizeMake(MIN(self.timeLabel.width, maxWidth), FHMNTimeLabelHeight());
}

- (void)layoutRefTextLabel {
    CGFloat refTextLabelHeight = [[self class] heightForRefTextLabelWithData:self.messageModel maxWidth:FHMNRefTextLabelWidth()];
    self.refTextLabel.frame = CGRectMake(self.width - FHMNRefTextLabelWidth() - FHMNRefRightPadding(), FHMNRefTopPadding(), FHMNRefTextLabelWidth(), refTextLabelHeight);
}

- (void)layoutRefImageView {
    self.refImageView.frame = CGRectMake(self.width - FHMNRefImageViewSize() - FHMNRefRightPadding(), FHMNRefTopPadding(), FHMNRefImageViewSize(), FHMNRefImageViewSize());
}

- (void)layoutBottomLine {
    self.bottomLineView.frame = CGRectMake(kBottomLineViewLeftPadding(), self.height - kBottomLineViewHeight(), self.width - kBottomLineViewLeftPadding() - kBottomLineViewRightPadding(), kBottomLineViewHeight());
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.avatarImageView.image = [UIImage themedImageNamed:@"defaulthead_message"];
}

- (void)goToPersonalHomePage {
    if(self.messageModel.user.userID && ![self.messageModel.user.userID isEqualToString:@"0"]){
        NSString *url = [NSString stringWithFormat:@"sslocal://profile?uid=%@&from_page=feed_message_list",self.messageModel.user.userID];
        NSURL *openUrl = [NSURL URLWithString:url];
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:self.tracerDict];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

@end

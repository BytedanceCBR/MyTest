//
//  ArticleMessageCell.m
//  Article
//
//  Created by SunJiangting on 14-5-25.
//
//

#import "ArticleMessageCell.h"
#import "ArticleMessageModel.h"
#import "SSUserModel.h"
#import "SSThemed.h"
#import "ArticleMomentGroupModel.h"
#import "NewsUserSettingManager.h"
#import "ExploreAvatarView+VerifyIcon.h"
#import "ArticleMomentHelper.h"
#import "FRBorderLabel.h"
#import "TTIconLabel.h"
#import "TTLabelTextHelper.h"
#import "TTDeviceUIUtils.h"
#import "TTBusinessManager+StringUtils.h"



#define MessageAdjustPadding(offset) (CGFloat)([TTDeviceUIUtils tt_padding:offset])
#define MessageAdjustFontSize(size) (CGFloat)([TTDeviceUIUtils tt_fontSize:size])

const CGSize ArticleMessageDefaultSize = {320, 80};
static CGFloat ArticleMessageNameLabelSize = 16.f;
static CGFloat ArticleMessageTimeLabelSize = 12.f;
static CGFloat ArticleMessageQuoteLabelSize = 12.f;
static CGFloat ArticleMessageBaseContextTextSize = 17.f;
static CGFloat ArticleMessageAvatarTopMargin = 15.f;
static CGFloat ArticleMessageAvatarHorizontalOffset = 9.f;
static CGFloat ArticleMessageAvatarViewHeight = 36.f;
static CGFloat ArticleMessageNameButtonTopMargin = 20.f;
static CGFloat ArticleMessageContentLabelTopOffset = 3.f;//fixed
static CGFloat ArticleMessageContentLabelRightOffset = 11.f;//fixed
static CGFloat ArticleMessageContentLabelLineHeight = 6.f;
static CGFloat ArticleMessageTimeLabelNormalTopOffset = 10.f;//fixed
static CGFloat ArticleMessageTimeLabelBottomOffset = 14.f;
static CGFloat ArticleMessageQouteViewTopOffset = 23.f;
static CGFloat ArticleMessageQouteLabelLineHeight = 4;
static CGFloat ArticleMessageQouteViewWidth = 70.f;
static CGFloat ArticleMessageTimeLabelDiggTopOffset = 13.f;
static CGFloat ArticleMessageQuoteLabelRightMargin = 9.f;
static CGFloat ArticleMessageDiggViewTopOffset = 8.f;//fixed
static CGFloat ArticleMessageDiggViewWidth = 16.f;

@interface ArticleMessageCell ()
@property (nonatomic, retain) ExploreAvatarView   *avatarView;
@property (nonatomic, retain) TTIconLabel         *nameLabel;
@property (nonatomic, retain) FRBorderLabel       *titleLabel;
@property (nonatomic, retain) SSThemedLabel       *contentLabel;
@property (nonatomic, retain) SSThemedImageView   *digView;

@property (nonatomic, retain) TTImageView          *quoteView;
@property (nonatomic, retain) SSThemedImageView    *placeHolderView;
@property (nonatomic, retain) SSThemedLabel        *quoteLabel;

@property (nonatomic, retain) SSThemedLabel        *timeLabel;
@property (nonatomic, retain) SSThemedView         *separatorView;

@end

@implementation ArticleMessageCell

+ (CGFloat) heightForMessageModel:(ArticleMessageModel *) messageModel constrainedToWidth:(CGFloat) width {
    CGFloat height = 0;
    if (messageModel.type < 110) {
        CGFloat contentHeight = [TTLabelTextHelper heightOfText:messageModel.content fontSize:[[self class] preferredContentTextSize] forWidth:width - [[self class] blankWidth] forLineHeight:[[self class] preferredContentTextSize] + MessageAdjustPadding(ArticleMessageContentLabelLineHeight) constraintToMaxNumberOfLines:0 firstLineIndent:0 textAlignment:NSTextAlignmentLeft] - 4.f;
        height = MAX(contentHeight + [[self class] normalCellHeightExceptContentLabel], ArticleMessageDefaultSize.height);
    }
    else {
         height = [[self class] diggCellHeightExceptContentLabel];
    }
    return height;
}

+ (CGFloat)blankWidth {
    return 3 * MessageAdjustPadding(ArticleMessageAvatarHorizontalOffset) + MessageAdjustPadding(ArticleMessageContentLabelRightOffset) + MessageAdjustPadding(ArticleMessageAvatarViewHeight) + MessageAdjustPadding(ArticleMessageQouteViewWidth);
}

- (void)dealloc {
    self.avatarView = nil;
    self.nameLabel = nil;
    self.titleLabel = nil;
    self.contentLabel = nil;
    self.quoteLabel = nil;
    self.quoteView = nil;
    self.timeLabel = nil;
    self.digView = nil;
    self.messageModel = nil;
}

- (void)setMessageModel:(ArticleMessageModel *)messageModel {
    self.nameLabel.text = messageModel.user.name;
    
    [self.avatarView setImageWithURLString:messageModel.user.avatarURLString];
    [self.nameLabel removeAllIcons];
    BOOL isVerified = [TTVerifyIconHelper isVerifiedOfVerifyInfo:messageModel.user.userAuthInfo];
    if (isVerified) {
        [self.avatarView showVerifyViewWithVerifyInfo:messageModel.user.userAuthInfo];
    }
    else{
        [self.avatarView hideVerifyView];
    }
    [self.nameLabel refreshIconView];
    if (messageModel.user.userRole.roleDisplayType > 0) {
        CGSize size = [self.nameLabel sizeThatFits:CGSizeMake(150, 16)];
        [self.titleLabel refreshWithRoleDisplayType:messageModel.user.userRole.roleDisplayType title:messageModel.user.userRole.roleName];
        [self.titleLabel sizeToFit];
        self.titleLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame) + size.width + [TTDeviceUIUtils tt_padding:4] , CGRectGetMinY(self.nameLabel.frame) + [TTDeviceUIUtils tt_padding:2.5], CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
        self.titleLabel.hidden = NO;
    }else{
        self.titleLabel.hidden = YES;
    }
    
    self.timeLabel.text = (messageModel.createTime > 0) ? [TTBusinessManager customtimeStringSince1970:messageModel.createTime] : @" ";
    // 100 - 110 均为回复，110-119 为顶
    if (messageModel.type < 110) {
        ///
        self.digView.hidden = YES;
        self.contentLabel.hidden = NO;
        [self.contentLabel setAttributedText:[TTLabelTextHelper attributedStringWithString:messageModel.content fontSize:[[self class] preferredContentTextSize] lineHeight:[[self class] preferredContentTextSize] + MessageAdjustPadding(ArticleMessageContentLabelLineHeight) lineBreakMode:NSLineBreakByTruncatingTail]];
        
    } else {
        self.digView.hidden = NO;
        self.contentLabel.hidden = YES;
    }
    
    // 引用部分，如果有图片，就显示图片，否则，显示title
    if (messageModel.group.thumbnailURLString.length > 0) {
        /// 显示图片
        self.quoteView.hidden = NO;
        self.quoteLabel.hidden = YES;
        [self.quoteView setImageWithURLString:messageModel.group.thumbnailURLString];
    } else {
        self.quoteLabel.hidden = NO;
        self.quoteView.hidden = YES;
        self.quoteLabel.text = messageModel.group.title;
        [self.quoteLabel setAttributedText:[TTLabelTextHelper attributedStringWithString:messageModel.group.title fontSize:MessageAdjustFontSize(ArticleMessageQuoteLabelSize) lineHeight:MessageAdjustFontSize(ArticleMessageQuoteLabelSize) + MessageAdjustPadding(ArticleMessageQouteLabelLineHeight) lineBreakMode:NSLineBreakByTruncatingTail]];
        [self.quoteLabel sizeToFit];
    }
    _messageModel = messageModel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.needMargin = YES;
        
        self.backgroundView = nil;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.frame = CGRectMake(0, 0, ArticleMessageDefaultSize.width, ArticleMessageDefaultSize.height);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.avatarView = [[ExploreAvatarView alloc] initWithFrame:CGRectMake(MessageAdjustPadding(ArticleMessageAvatarHorizontalOffset), MessageAdjustPadding(ArticleMessageAvatarTopMargin), MessageAdjustPadding(ArticleMessageAvatarViewHeight), MessageAdjustPadding(ArticleMessageAvatarViewHeight))];
        self.avatarView.enableRoundedCorner = YES;
        self.avatarView.imageView.layer.borderWidth = 1.f;
        UIColor *borderColor = SSGetThemedColorInArray(@[[UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:0.5], [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:0.5]]);
        self.avatarView.imageView.layer.borderColor = borderColor.CGColor;
        self.avatarView.placeholder = @"big_defaulthead_head";
        [self.avatarView addTouchTarget:self action:@selector(avatarButtonClicked)];
        
        [self.avatarView setupVerifyViewForLength:ArticleMessageAvatarViewHeight adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_size:standardSize];
        }];
        
        [self.contentView addSubview:self.avatarView];
        
        self.nameLabel = [[TTIconLabel alloc] initWithFrame:CGRectMake(MessageAdjustPadding(ArticleMessageAvatarViewHeight) + 2 * MessageAdjustPadding(ArticleMessageAvatarHorizontalOffset), MessageAdjustFontSize(ArticleMessageNameButtonTopMargin), [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth], MessageAdjustFontSize(ArticleMessageNameLabelSize))];
        self.nameLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont systemFontOfSize:MessageAdjustFontSize(ArticleMessageNameLabelSize)];
        self.nameLabel.textColorThemeKey = kColorText5;
        self.nameLabel.numberOfLines = 1;
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.nameLabel];
        
        self.titleLabel = [FRBorderLabel roleLabelWith:FRRoleDisplayTypeBlue title:@""];
        self.titleLabel.hidden = YES;
        [self.contentView addSubview:_titleLabel];
        
        self.timeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(MessageAdjustPadding(ArticleMessageAvatarViewHeight) + 2 * MessageAdjustPadding(ArticleMessageAvatarHorizontalOffset), 0, 100, MessageAdjustFontSize(ArticleMessageTimeLabelSize))];
        self.timeLabel.verticalAlignment = ArticleVerticalAlignmentBottom;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont systemFontOfSize:MessageAdjustFontSize(ArticleMessageTimeLabelSize)];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.timeLabel.textColorThemeKey = kColorText13;
        [self.contentView addSubview:self.timeLabel];
        
        self.digView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(MessageAdjustPadding(ArticleMessageAvatarViewHeight) + 2 * MessageAdjustPadding(ArticleMessageAvatarHorizontalOffset), MessageAdjustFontSize(ArticleMessageNameButtonTopMargin) + MessageAdjustFontSize(ArticleMessageNameLabelSize) + MessageAdjustPadding(ArticleMessageDiggViewTopOffset), MessageAdjustPadding(ArticleMessageDiggViewWidth), MessageAdjustPadding(ArticleMessageDiggViewWidth))];
        self.digView.imageName = @"comment_like_icon";
        self.digView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.digView];
        
        self.contentLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(MessageAdjustPadding(ArticleMessageAvatarViewHeight) + 2 * MessageAdjustPadding(ArticleMessageAvatarHorizontalOffset), MessageAdjustFontSize(ArticleMessageNameButtonTopMargin) + MessageAdjustFontSize(ArticleMessageNameLabelSize) + MessageAdjustPadding(ArticleMessageContentLabelTopOffset), [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth], [[self class] preferredContentTextSize])];
        self.contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.font = [UIFont systemFontOfSize:[[self class] preferredContentTextSize]];
        self.contentLabel.textColorThemeKey = kColorText1;
        [self.contentView addSubview:self.contentLabel];
        
        
        NSUInteger quoteAutoresingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.quoteView = [[TTImageView alloc] initWithFrame:CGRectMake(0, MessageAdjustPadding(10), MessageAdjustPadding(60), MessageAdjustPadding(60))];
        self.quoteView.autoresizingMask = quoteAutoresingMask;
        self.quoteView.userInteractionEnabled = NO;
        self.quoteView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        self.quoteView.clipsToBounds = YES;
        [self.contentView addSubview:self.quoteView];
        
        self.quoteLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, MessageAdjustPadding(ArticleMessageQouteViewWidth), 0.f)];
        self.quoteLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        self.quoteLabel.userInteractionEnabled = NO;
        self.quoteLabel.autoresizingMask = quoteAutoresingMask;
        self.quoteLabel.backgroundColor = [UIColor clearColor];
        self.quoteLabel.numberOfLines = 3;
        self.quoteLabel.textColorThemeKey = kColorText3;
        [self.contentView addSubview:self.quoteLabel];
        
        self.separatorView = [[SSThemedView alloc] init];
        self.separatorView.backgroundColorThemeKey = kColorLine1;
        [self.contentView addSubview:self.separatorView];
        
        [self themeChanged:nil];
    }
    return self;
}

- (void)setBgHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"eeeeee" nightColorName:@"303030"]];
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];    
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self setBgHighlighted:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setBgHighlighted:selected];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.separatorView.frame = CGRectMake(0, frame.size.height - [TTDeviceHelper ssOnePixel], frame.size.width, [TTDeviceHelper ssOnePixel]);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat contentHeight = [TTLabelTextHelper heightOfText:self.contentLabel.attributedText.string fontSize:[[self class] preferredContentTextSize] forWidth:CGRectGetWidth(self.contentView.frame) - [[self class] blankWidth] forLineHeight:[[self class] preferredContentTextSize] + MessageAdjustPadding(ArticleMessageContentLabelLineHeight) constraintToMaxNumberOfLines:0 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    CGRect contentRect = self.contentLabel.frame;
    contentRect.size.width = CGRectGetWidth(self.contentView.frame) - [[self class] blankWidth];
    contentRect.size.height = contentHeight;
    self.contentLabel.frame = contentRect;
    
    self.nameLabel.width = CGRectGetWidth(self.contentView.frame) - [[self class] blankWidth];
    self.timeLabel.bottom = self.contentView.bottom - [TTDeviceUIUtils tt_padding:ArticleMessageTimeLabelBottomOffset];
    self.quoteLabel.width = MessageAdjustPadding(ArticleMessageQouteViewWidth);
    self.quoteLabel.right = self.contentView.right - [TTDeviceUIUtils tt_padding:ArticleMessageQuoteLabelRightMargin];
    self.quoteLabel.top = MessageAdjustPadding(ArticleMessageQouteViewTopOffset);
    self.quoteView.top = self.quoteLabel.top;
    self.quoteView.right = self.contentView.right - [TTDeviceUIUtils tt_padding:ArticleMessageQuoteLabelRightMargin];
}

+ (CGFloat)preferredContentTextSize {
    return MessageAdjustFontSize(ArticleMessageBaseContextTextSize);
}

+ (CGFloat)normalCellHeightExceptContentLabel {
    return [TTDeviceUIUtils tt_padding:ArticleMessageNameButtonTopMargin] + [TTDeviceUIUtils tt_fontSize:ArticleMessageNameLabelSize] + [TTDeviceUIUtils tt_padding:ArticleMessageContentLabelTopOffset] + [TTDeviceUIUtils tt_padding:ArticleMessageTimeLabelNormalTopOffset]
    + [TTDeviceUIUtils tt_fontSize:ArticleMessageTimeLabelSize] + [TTDeviceUIUtils tt_padding:ArticleMessageTimeLabelBottomOffset];
}

+ (CGFloat)diggCellHeightExceptContentLabel {
    return [[self class] normalCellHeightExceptContentLabel] - [TTDeviceUIUtils tt_padding:ArticleMessageTimeLabelNormalTopOffset] + [TTDeviceUIUtils tt_padding:ArticleMessageDiggViewWidth] + [TTDeviceUIUtils tt_padding:ArticleMessageTimeLabelDiggTopOffset];
}

- (void)avatarButtonClicked
{
    [self goToUserProfileView];
}

- (void)goToUserProfileView
{
    [ArticleMomentHelper openMomentProfileView:self.messageModel.user navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromMyMsg];
}

@end

NSString * const ArticleMessageCellIdentifier = @"article.message.Identifier";

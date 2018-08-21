//
//  SSFeedbackCell.m
//  Article
//
//  Created by Zhang Leonardo on 13-1-6.
//
//

#import "SSFeedbackCell.h"
#import "SSAvatarView.h"
#import "TTImageView.h"
#import "SSFeedbackViewController.h"
 
#import "UIImage+TTThemeExtension.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTProjectLogicManager.h"
#import "TTLabelTextHelper.h"
#import "UILabel+Tapping.h"
#import "TTURLUtils.h"
#import "TTRoute.h"

#define AvatarViewWidth 30.f
#define SSContentViewSeverTypeLeftPadding   43.f
#define SSContentViewSeverTypeRightPadding  39.f
#define SSContentViewUserTypeLeftPadding    38.f
#define SSContentViewUserTypeRightPadding   44.f

#define SSContentViewTopPadding             8.f
#define SSContentViewBottomPadding          9.f

#define SSContentViewLeftMargin             12.f
#define SSContentViewRightMargin            12.f
#define SSContentViewTopMargin              12.f
#define SSContentViewBottomMargin           7.f

#define FeedbackImageViewTopPadding         10.f
#define CreateTimeLabelTopPadding           5.f
#define ContentLabelFontSize                  15.f
#define CreateTimeLabelFontSize             10.f
#define FeedbackImgViewRightPadding         66.f

@interface SSFeedbackCell ()<TTLabelTappingDelegate>

@property(nonatomic, retain)SSFeedbackModel * model;
@property(nonatomic, retain)UIView * ssContentView;
@property(nonatomic, retain)UILabel * contentLabel;
@property(nonatomic, retain)UILabel * timeLabel;
@property(nonatomic, retain)UIImageView * contentBgImgView;
@property(nonatomic, retain)SSAvatarView * avatarView;
@property(nonatomic, retain)TTImageView * feedbackImageView;
@property(nonatomic, retain)UIButton * feedbackImageBgButton;
@end

@implementation SSFeedbackCell

- (void)dealloc
{
    self.delegate = nil;
    self.feedbackImageBgButton = nil;
    self.feedbackImageView = nil;
    self.avatarView = nil;
    self.contentBgImgView = nil;
    self.ssContentView = nil;
    self.contentLabel = nil;
    self.timeLabel = nil;
    self.model = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIView * bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = bgView;
        self.backgroundColor = [UIColor clearColor];
        
        self.avatarView = [[SSAvatarView alloc] initWithFrame:CGRectMake(0, 0, AvatarViewWidth, AvatarViewWidth)];
        if ([SSCommonLogic isZoneVersion]) {
            self.avatarView.frame = CGRectMake(0, 0, 25, 25);
            _avatarView.avatarStyle = SSAvatarViewStyleRectangle;
            _avatarView.defaultHeadImgName = @"default-avatar-icons";
            _avatarView.avatarStyle = SSAvatarViewStyleRectangle;
            _avatarView.rectangleAvatarImgRadius = 2;
            _avatarView.avatarImgPadding = 0;
            _avatarView.marginEdgeInsets = UIEdgeInsetsZero;
        }else{
            _avatarView.avatarStyle = SSAvatarViewStyleRound;
            _avatarView.avatarImgPadding = 2.f;
        }
        
        [self.contentView addSubview:_avatarView];
        
        self.ssContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _ssContentView.backgroundColor = [UIColor clearColor];
        _ssContentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:_ssContentView];
        
        self.contentBgImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        //_contentBgImgView.contentStretch = CGRectMake(0.49, 0.49, 0.02, 0.02);
        _contentBgImgView.backgroundColor = [UIColor clearColor];
        [self.ssContentView addSubview:_contentBgImgView];
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines = 0;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.labelInactiveLinkAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor]};
        _contentLabel.labelActiveLinkAttributes = @{NSForegroundColorAttributeName:[UIColor tt_themedColorForKey:kColorText5Highlighted]};
        _contentLabel.labelTappingDelegate = self;
        [_ssContentView addSubview:_contentLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [_timeLabel setFont:[UIFont systemFontOfSize:CreateTimeLabelFontSize]];
        [_ssContentView addSubview:_timeLabel];
        
        self.feedbackImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        [_ssContentView addSubview:_feedbackImageView];
        
        self.feedbackImageBgButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_feedbackImageBgButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_ssContentView addSubview:_feedbackImageBgButton];
        
        [self themeChanged:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint avatarPoint = [self originForAvatarView];
    _avatarView.origin = CGPointMake(avatarPoint.x, avatarPoint.y);
    
    _ssContentView.frame = [self frameForSSContentView];
    _contentBgImgView.frame = _ssContentView.bounds;
    [self refreshContentBgImgView];
    
    _contentLabel.frame = [self frameForContentLabel];
    _timeLabel.frame = [self frameForCreateLabel];
    _feedbackImageView.frame = [self frameForImageView];
    _feedbackImageBgButton.frame = [self frameForImageView];    
}

- (void)buttonClicked:(id)sender
{
    if (sender == _feedbackImageBgButton) {
        if (_model && [SSFeedbackCell hasFeedbackImageForModel:_model]  &&
            _delegate && [_delegate respondsToSelector:@selector(feedbackCellImgButtonClicked:)]) {
            
            //[_delegate feedbackCellImgButtonClicked:_model];
        }
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [_contentLabel setTextColor:[UIColor tt_themedColorForKey:kColorText1]];
    [_timeLabel setTextColor:[UIColor tt_themedColorForKey:kColorText3]];
    [self refreshContentBgImgView];
    _avatarView.backgroundNormalImage = [UIImage themedImageNamed:@"headbg_comment.png"];
    _avatarView.backgroundHightlightImage = [UIImage themedImageNamed:@"headbg_comment.png"];
}

- (void)refreshContentBgImgView
{
    NSString * resourceImage = nil;
    if ([_model.feedbackType intValue] == feedbackTypeUser) {
        resourceImage = @"right_dialog.png";
    }
    else if ([_model.feedbackType intValue] == feedbackTypeServer) {
        resourceImage = @"left_dialog.png";
    }
    
    if (resourceImage) {
        UIImage * image = [UIImage themedImageNamed:resourceImage];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5f - 1, image.size.width * 0.5f - 1, image.size.height * 0.5f, image.size.width * 0.5f)];
        _contentBgImgView.image = image;
    }
}

- (void)refreshFeedbackModel:(SSFeedbackModel *)model
{
    SSLog(@"model content %@", model.content);
    self.model = model;
    if (!isEmptyString(model.avatarURLStr)) {
        [_avatarView showAvatarByURL:model.avatarURLStr];
    }
    else {
        [_avatarView showAvatarByURL:nil];
        if ([model.feedbackType intValue] == feedbackTypeServer) {
            [_avatarView setLocalAvatarImage:[UIImage imageNamed:@"Icon.png"]];
        }
    }
    
    NSString * timeStr = [TTBusinessManager noTimeStringSince1970:[model.pubDate doubleValue]];
    [_timeLabel setText:timeStr];
    
    if ([SSFeedbackCell hasFeedbackImageForModel:model]) {
        [_feedbackImageView setImageWithURLString:model.imageURLStr];
    }
    else {
        [_feedbackImageView setImageWithURLString:nil];
    }
    
    if ([_model.feedbackType intValue]== feedbackTypeServer) {
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
    }
    else {
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _contentLabel.textAlignment = NSTextAlignmentRight;
    }
    
    if (isEmptyString(model.content)) {
        _contentLabel.attributedText = nil;
        return;
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:model.content];
    [attrString setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ContentLabelFontSize]} range:NSMakeRange(0, attrString.length)];
    _contentLabel.attributedText = attrString;
    [_contentLabel removeAllLinkAttributes];
    
    [_contentLabel detectAndAddLinkToLabel];
    if (!SSIsEmptyArray(model.links)) {
        NSArray * linkAry = model.links;
        for (NSDictionary * dict in linkAry) {
            if (SSIsEmptyDictionary(dict)) continue;
            NSUInteger start = [dict tt_unsignedIntegerValueForKey:@"start"];
            NSUInteger length = [dict tt_unsignedIntegerValueForKey:@"length"];
            NSString *actionURLString = [dict tt_stringValueForKey:@"url"];
            NSURL *linkURL = [NSURL URLWithString:actionURLString];
            NSRange linkRange = NSMakeRange(start, length);
            
            if (NSMaxRange(linkRange) <= attrString.length) {
                [_contentLabel addLinkToLabelWithURL:linkURL range:linkRange];
            }
        }
    }
}

- (CGRect)frameForSSContentView
{
    CGRect frame = CGRectZero;
    frame.size.width = [SSFeedbackCell widthForSSContentViewByModel:_model listViewWidth:[self widthForCell]];
    if ([_model.feedbackType intValue] == feedbackTypeUser) {
        frame.origin.x = [self widthForCell] - frame.size.width - SSContentViewSeverTypeRightPadding;
    }
    else if ([_model.feedbackType intValue] == feedbackTypeServer) {
        
        frame.origin.x = SSContentViewUserTypeLeftPadding;
    }
    frame.origin.y = SSContentViewTopPadding;
    
    frame.size.height = [SSFeedbackCell heightForSSContentViewByModel:_model listViewWidth:[self widthForCell]];
    return frame;
}

- (CGRect)frameForContentLabel
{
    CGRect frame = CGRectZero;

    frame.origin.x = SSContentViewLeftMargin;
    
    frame.origin.y = SSContentViewRightMargin;
    frame.size.width = [SSFeedbackCell availableWidthForSSContentViewByModel:_model listViewWidth:[self widthForCell]];
    frame.size.height = [SSFeedbackCell heightForContentLabel:_model listViewWidth:[self widthForCell]];
    return frame;
}

- (CGRect)frameForCreateLabel
{
    CGRect frame = CGRectZero;
    frame.size.width = 70.f;
    frame.size.height = [SSFeedbackCell heightForCreateTimeLabelByModel:_model listViewWidth:[self widthForCell]];
    
    if ([_model.feedbackType intValue] == feedbackTypeServer) {
        frame.origin.x = SSContentViewLeftMargin;
    }
    else {
        frame.origin.x = ([self frameForSSContentView].size.width - frame.size.width) - SSContentViewRightMargin;
    }
    
    frame.origin.y = ([self frameForSSContentView].size.height - frame.size.height) - SSContentViewBottomMargin;
    return frame;
}

- (CGRect)frameForImageView
{
    CGRect frame = CGRectZero;
    if ([SSFeedbackCell hasFeedbackImageForModel:_model]) {
        frame.size.width = [SSFeedbackCell widthForFeedbackImageByModel:_model listViewWidth:[self widthForCell]];
        frame.size.height = [SSFeedbackCell heightForFeedbackImageByModel:_model listViewWidth:[self widthForCell]];
        frame.origin.y = CGRectGetMaxY([self frameForContentLabel]) + FeedbackImageViewTopPadding;
        frame.origin.x = SSContentViewLeftMargin;
        return frame;
    }
    else {
        return CGRectZero;
    }
}

- (CGPoint)originForAvatarView
{
    CGPoint point = CGPointZero;
    if ([_model.feedbackType intValue] == feedbackTypeUser) {
        point.x = [self widthForCell] - AvatarViewWidth - 8;
    }
    else if ([_model.feedbackType intValue] == feedbackTypeServer) {
        point.x = 8;
    }
    point.y = 5.f;
    return point;
}

- (CGFloat)widthForCell
{
    return self.frame.size.width;
}

+ (CGFloat)widthForContentLabel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    float contentWidth = [TTLabelTextHelper sizeOfText:model.content fontSize:ContentLabelFontSize forWidth:9999.0 forLineHeight:[UIFont systemFontOfSize:ContentLabelFontSize].lineHeight constraintToMaxNumberOfLines:0 firstLineIndent:0 textAlignment:NSTextAlignmentLeft].width;
    if (contentWidth > [self maxAvailableWidthForSSContentViewByModel:model listViewWidth:width]) {
        return [self maxAvailableWidthForSSContentViewByModel:model listViewWidth:width];
    }
    else if (contentWidth < [self minAvailableWidthForSSContentViewByModel:model listViewWidth:width]) {
        return [self minAvailableWidthForSSContentViewByModel:model listViewWidth:width];
    }
    return contentWidth;
}

+ (CGFloat)heightForContentLabel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    CGFloat titleLabelWidth = [self widthForContentLabel:model listViewWidth:width];
    
    CGFloat height = [TTLabelTextHelper heightOfText:model.content fontSize:ContentLabelFontSize forWidth:titleLabelWidth];
    
    return height;
}

+ (CGFloat)heightForCreateTimeLabelByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    return [TTLabelTextHelper heightOfText:@"  " fontSize:CreateTimeLabelFontSize forWidth:70];
}

+ (CGFloat)heightForFeedbackImageByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    float imgWidth = [self widthForFeedbackImageByModel:model listViewWidth:width];
    if (imgWidth > 0 && [model.imageWidth floatValue]> 0) {
        return ([model.imageHeight floatValue] * imgWidth ) / [model.imageWidth floatValue];
    }
    else {
        return 0;
    }
}

+ (CGFloat)widthForFeedbackImageByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    if ([self hasFeedbackImageForModel:model]) {
        CGFloat imgWidth = [self maxAvailableWidthForSSContentViewByModel:model listViewWidth:width] - FeedbackImgViewRightPadding;
        return imgWidth;
    }
    else {
        return 0;
    }
}

+ (BOOL)hasFeedbackImageForModel:(SSFeedbackModel *)model
{
    if (!isEmptyString(model.imageURLStr) && [model.imageHeight floatValue] > 0 && [model.imageWidth floatValue] > 0) {
        return YES;
    }
    return NO;
}

+ (CGFloat)minAvailableWidthForSSContentViewByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    return ([self minWidthForSSContentViewByModel:model listViewWidth:width] - SSContentViewLeftMargin - SSContentViewRightMargin);
}

+ (CGFloat)minWidthForSSContentViewByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    return 70.f;
}

+ (CGFloat)maxAvailableWidthForSSContentViewByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    return ([self maxWidthForSSContentViewByModel:model listViewWidth:width] - SSContentViewLeftMargin - SSContentViewRightMargin);
}

+ (CGFloat)maxWidthForSSContentViewByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    CGFloat titleLabelWidth = width;
    if ([model.feedbackType intValue] == feedbackTypeUser) {
        titleLabelWidth -= (SSContentViewSeverTypeLeftPadding + SSContentViewSeverTypeRightPadding);
    }
    else if ([model.feedbackType intValue] == feedbackTypeServer) {
        titleLabelWidth -= (SSContentViewUserTypeRightPadding + SSContentViewUserTypeLeftPadding);
    }
    return titleLabelWidth;
}

+ (CGFloat)availableWidthForSSContentViewByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    float contentWidth = [self widthForContentLabel:model listViewWidth:width] + 16;
    if (!isEmptyString(model.imageURLStr)) {
        float imgWidth = [self widthForFeedbackImageByModel:model listViewWidth:width];
        return MAX(imgWidth, contentWidth);
    }
    return contentWidth;
}

+ (CGFloat)widthForSSContentViewByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    CGFloat w = [self availableWidthForSSContentViewByModel:model listViewWidth:width];
    w += (SSContentViewLeftMargin + SSContentViewRightMargin);
    return w;
}

+ (CGFloat)heightForSSContentViewByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    float height = SSContentViewTopMargin;
    float contentLabelHeight = [self heightForContentLabel:model listViewWidth:width];
    height += contentLabelHeight;
    float imageViewHeight = [self heightForFeedbackImageByModel:model listViewWidth:width];
    
    
    if (imageViewHeight > 0) {
        height += (FeedbackImageViewTopPadding + imageViewHeight);
    }
    
    float timeLHeight = [self heightForCreateTimeLabelByModel:model listViewWidth:width];
    height += (CreateTimeLabelTopPadding + timeLHeight);
    
    height += SSContentViewBottomMargin;
    return height;
}

+ (CGFloat)heightForRowByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width
{
    float ssContentViewHeight = [self heightForSSContentViewByModel:model listViewWidth:width];
    ssContentViewHeight += (SSContentViewTopPadding + SSContentViewBottomPadding);
    return ssContentViewHeight;
}

#pragma mark - TTLabelTappingDelegate
- (void)label:(UILabel *)label didSelectLinkWithURL:(NSURL *)URL
{
    if (!URL) {
        return;
    }
    if ([[TTRoute sharedRoute] canOpenURL:URL]) {
        [[TTRoute sharedRoute] openURLByPushViewController:URL];
    } else {
        NSString *urlString = URL.absoluteString;
        NSURL *webURL = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:@{@"url":urlString}];
        [[TTRoute sharedRoute] openURLByPushViewController:webURL];
    }
}

@end

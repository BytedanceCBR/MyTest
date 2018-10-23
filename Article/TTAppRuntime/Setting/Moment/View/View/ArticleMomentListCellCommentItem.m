//
//  ArticleMomentListCellCommentItem.m
//  Article
//
//  Created by Zhang Leonardo on 14-5-23.
//
//

#import "ArticleMomentListCellCommentItem.h"
#import "SSAttributeLabel.h"
#import <TTAccountBusiness.h>
#import "NewsUserSettingManager.h"
#import "ArticleAvatarView.h"
#import "ArticleMomentHelper.h"
#import "ExploreMomentListCellItemBase.h"
#import "ArticleMomentCommentManager.h"
#import "NetworkUtilities.h"
#import "SSMotionRender.h"

#import "ExploreMomentDefine.h"

#import "TTStringHelper.h"

#define kLeftMargin (9 + kMomentCellItemViewLeftPadding)
#define kRightMargin (9 + kMomentCellItemViewRightPadding)
#define kTopMargin 0
#define kBottomMargin 0

#define kColonText @": "
#define kReplyText NSLocalizedString(@" 回复 ", nil)

#define kCommentUserNameIndex 1
#define kToReplyUserNameIndex 2
#define kCommentIndex 3

#define kAvatarViewWidth 22
#define kAvatarViewHeight 22

#define kNameLabelLeftPadding 6
//#define kNameLabelWidth 140
#define kNameLabelRightPadding 18
//#define kNameLabelFontSize 14

#define kDiggButtonTitleFontSize 10

#define kCommentLabelTopPadding 4

@interface ArticleMomentListCellCommentItem()<UIGestureRecognizerDelegate, SSAttributeLabelModelDelegate>
@property(nonatomic, strong)NSString * nameAndCommentStr;
@property(nonatomic, strong)SSAttributeLabel * attributeCommentLabel;
//@property(nonatomic, strong)ArticleAvatarView * avatarView;
//@property(nonatomic, strong)TTLabelWithTouchHighlight * nameLabel;
//@property(nonatomic, strong)UIButton * diggButton;

@property(nonatomic, strong)ArticleMomentCommentModel * commentModel;
@end

@implementation ArticleMomentListCellCommentItem

- (void)dealloc
{
    //[self.attributeCommentLabel removeObserver:self forKeyPath:@"backgroundColor"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _orderIndex = -1;
        
        self.backgroundColor = [UIColor clearColor];
        self.attributeCommentLabel = [[SSAttributeLabel alloc] initWithFrame:CGRectZero supportCopy:YES];
        _attributeCommentLabel.delegate = self;
        _attributeCommentLabel.backgroundColor = [UIColor clearColor];
        _attributeCommentLabel.ssDataDetectorTypes = UIDataDetectorTypeNone;
        _attributeCommentLabel.numberOfLines = 10;
        _attributeCommentLabel.font = [UIFont systemFontOfSize:[NewsUserSettingManager settedMomentDiggCommentFontSize]];
        _attributeCommentLabel.backgroundHighlightColorName = kColorBackground500;
        [self addSubview:_attributeCommentLabel];
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    _attributeCommentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    _attributeCommentLabel.selectTextForegroundColorName = kColorText300;
    [self refreshCommentLabel];
}

- (void)refreshCommentLabel
{
    [_attributeCommentLabel setText:_nameAndCommentStr];
    
    NSMutableArray * attributeModels = [NSMutableArray arrayWithCapacity:10];
    
    NSString * nameStr = _commentModel.user.name;
    NSString * replyNameStr = _commentModel.replyUser.name;
    
    if (!isEmptyString(nameStr)) {
        SSAttributeLabelModel * model = [[SSAttributeLabelModel alloc] init];
        model.linkURLString = [NSString stringWithFormat:@"ArticleMomentListCellCommentItem://profile?index=%i", kCommentUserNameIndex];
        model.textColor = [UIColor tt_themedColorForKey:kColorText5];
        model.attributeRange = NSMakeRange(0, [nameStr length]);
        [attributeModels addObject:model];
    }
    
    if (!isEmptyString(replyNameStr)) {
        SSAttributeLabelModel * model = [[SSAttributeLabelModel alloc] init];
        model.linkURLString = [NSString stringWithFormat:@"ArticleMomentListCellCommentItem://profile?index=%i", kToReplyUserNameIndex];
        model.textColor = [UIColor tt_themedColorForKey:kColorText5];
        model.attributeRange = NSMakeRange([nameStr length] + [kReplyText length], [replyNameStr length]);
        [attributeModels addObject:model];

    }
    
    CGFloat fontSize = [NewsUserSettingManager settedMomentDiggCommentFontSize];
    CGFloat lineHeight = fontSize + 3.0f;
    CGFloat lineHeightMultiple = lineHeight / fontSize;
    _attributeCommentLabel.lineSpacingMultiple = lineHeightMultiple - 1;
    
    [_attributeCommentLabel refreshAttributeModels:attributeModels];
}

- (void)refreshWithCommentModel:(ArticleMomentCommentModel *)commentModel cellWidth:(CGFloat)width
{
    if (commentModel) {
        self.commentModel = commentModel;

        self.nameAndCommentStr = [ArticleMomentListCellCommentItem stringForUserName:commentModel.user.name replyUserName:commentModel.replyUser.name commentContent:commentModel.content];
        
        CGRect frame = self.frame;
        frame.size.width = width;
        frame.size.height = [ArticleMomentListCellCommentItem heightForCommentModel:commentModel cellWidth:width];
        self.frame = frame;

        _attributeCommentLabel.frame = CGRectMake(kLeftMargin, kTopMargin, width - kLeftMargin - kRightMargin, frame.size.height - kTopMargin - kBottomMargin);
        
        [self refreshCommentLabel];
    }
}

+ (NSString *)stringForUserName:(NSString *)userName replyUserName:(NSString *)replyUserName commentContent:(NSString *)comment
{
    NSString * str = nil;
    if (isEmptyString(replyUserName)) {
        str = [NSString stringWithFormat:@"%@%@%@", userName == nil ? @"" : userName, kColonText, comment == nil ? @"" : comment];
    }
    else {
        str = [NSString stringWithFormat:@"%@%@%@%@%@",userName == nil ? @"" : userName, kReplyText, replyUserName, kColonText, comment == nil ? @"" : comment];
    }
    return str;
}

#pragma mark -- height

+ (CGFloat)heightForCommentModel:(ArticleMomentCommentModel *)commentModel cellWidth:(CGFloat)width
{
    if (!commentModel) {
        return 0;
    }
    
    NSString * str = [self stringForUserName:commentModel.user.name replyUserName:commentModel.replyUser.name commentContent:commentModel.content];
    
    CGFloat commentHeight = [self heightOfCommentString:str fontSize:[NewsUserSettingManager settedMomentDiggCommentFontSize] width:width - kLeftMargin - kRightMargin];
    
    return (kTopMargin + commentHeight + kBottomMargin);
}

+ (CGFloat)heightOfCommentString:(NSString *)str fontSize:(CGFloat)fontSize width:(CGFloat)fixedWidth
{
    CGFloat lineHeight = fontSize + 3.0f;
    CGFloat lineHeightMultiple = lineHeight / fontSize;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;

    UIFont *font = [UIFont systemFontOfSize:fontSize];
    style.lineSpacing = font.lineHeight * (lineHeightMultiple - 1);
    
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:style};
    
    // https://jira.bytedance.com/browse/XWTT-3478
    if ([TTDeviceHelper OSVersionNumber] < 9.0) {
        CGSize size = [SSTTTAttributedLabel sizeThatFitsString:str withConstraints:CGSizeMake(fixedWidth, 9999) attributes:attributes limitedToNumberOfLines:10];
        
        return size.height;
    }
    else {
        return [SSAttributeLabel sizeWithText:str font:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(fixedWidth, 9999) lineSpacingMultiple:lineHeightMultiple-1].height - 3.0f;
    }
}


#pragma mark -- SSAttributeLabelModelDelegate

- (void)attributeLabel:(SSAttributeLabel *)label didClickLink:(NSString *)linkURLString
{
    if (isEmptyString(linkURLString)) {
        return;
    }
    NSURL * url = [TTStringHelper URLWithURLString:linkURLString];
    NSDictionary *parameters = [TTStringHelper parametersOfURLString:url.query];
    if([parameters count] > 0)
    {
        int index = [[parameters objectForKey:@"index"] intValue];
        if (index == kCommentIndex) {
            if (_delegate && [_delegate respondsToSelector:@selector(commentItemDidSeletedCommentButton:)]) {
                [_delegate commentItemDidSeletedCommentButton:self];
            }
        }
        else if (index == kCommentUserNameIndex) {
            if (_delegate && [_delegate respondsToSelector:@selector(commentItemDidSeletedNameButton:)]) {
                [_delegate commentItemDidSeletedNameButton:self];
            }
            
            if (![TTAccountManager isLogin]) {
                wrapperTrackEvent(@"update_tab", @"logoff_click_replier");
            }
            else {
                wrapperTrackEvent(@"update_tab", @"click_replier");
            }
        }
        else if (index == kToReplyUserNameIndex) {
            if (_delegate && [_delegate respondsToSelector:@selector(commentItemDidSeletedReplyNameButton:)]) {
                [_delegate commentItemDidSeletedReplyNameButton:self];
            }

            if (![TTAccountManager isLogin]) {
                wrapperTrackEvent(@"update_tab", @"logoff_click_replier");
            }
            else {
                wrapperTrackEvent(@"update_tab", @"click_replier");
            }
        }
    }
}

- (void)attributeLabelClickedUntackArea:(SSAttributeLabel *)label
{
    if (label == _attributeCommentLabel) {
        if (_delegate && [_delegate respondsToSelector:@selector(commentItemDidSeletedCommentButton:)]) {
            [_delegate commentItemDidSeletedCommentButton:self];
        }
    }
}
@end

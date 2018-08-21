//
//  ExploreArticleEssayCellCommentItemView.m
//  Article
//
//  Created by Chen Hong on 14-10-23.
//
//

#import "ExploreArticleEssayCellCommentItemView.h"
#import "SSAttributeLabel.h"
#import <TTAccountBusiness.h>

#import "NewsUserSettingManager.h"
#import "ExploreCellHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTStringHelper.h"

#define kLeftMargin 8
#define kRightMargin 8
#define kTopMargin 8
#define kBottomMargin 3
#define kLineSpacingMultiple 0.2f

#define kColonText @"："
//#define kReplyText NSLocalizedString(@"回复", nil)

#define kCommentUserNameIndex 1
#define kCommentIndex 2

@interface ExploreArticleEssayCellCommentItemView()<UIGestureRecognizerDelegate, SSAttributeLabelModelDelegate>

@property(nonatomic, retain)NSString * nameStr;
@property(nonatomic, retain)NSString * nameAndCommentStr;
@property(nonatomic, retain)NSString * commentStr;
@property(nonatomic, retain)SSAttributeLabel * attributeCommentLabel;
//@property(nonatomic, retain)UIView *bottomLine;
@end


@implementation ExploreArticleEssayCellCommentItemView

- (void)dealloc
{
    _attributeCommentLabel.delegate = nil;
    self.attributeCommentLabel = nil;
    self.delegate = nil;
    self.nameAndCommentStr = nil;
    self.commentStr = nil;
    self.nameStr = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _orderIndex = -1;
        
        self.clipsToBounds = YES;
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
//        tap.delegate = self;
//        [self addGestureRecognizer:tap];
        
        self.attributeCommentLabel = [[SSAttributeLabel alloc] initWithFrame:CGRectZero];
        _attributeCommentLabel.delegate = self;
        _attributeCommentLabel.backgroundColor = [UIColor clearColor];
        _attributeCommentLabel.ssDataDetectorTypes = UIDataDetectorTypeNone;
        _attributeCommentLabel.numberOfLines = 0;
        _attributeCommentLabel.font = [UIFont systemFontOfSize:kCellCommentViewFontSize];
        _attributeCommentLabel.lineSpacingMultiple = kLineSpacingMultiple;
        //_attributeCommentLabel.backgroundHighlightColorName = @"ArticleCommentListCellCommentItemLabelBgHighlightColor";
        [self addSubview:_attributeCommentLabel];
        
        //bottom line
//        self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - [TTDeviceHelper ssOnePixel], frame.size.width, [TTDeviceHelper ssOnePixel])];
//        [self addSubview:self.bottomLine];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)reset {
    _orderIndex = -1;
    _attributeCommentLabel.font = [UIFont systemFontOfSize:kCellCommentViewFontSize];
}

- (void)themeChanged:(NSNotification *)notification
{
    _attributeCommentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    [self refreshCommentLabel];
    
    [self updateContentWithNormalColor];
}

- (void)setHideBottomLine:(BOOL)hideBottomLine {
    _hideBottomLine = hideBottomLine;
//    _bottomLine.hidden = _hideBottomLine;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
//    self.bottomLine.frame = CGRectMake(0, frame.size.height - [TTDeviceHelper ssOnePixel], frame.size.width, [TTDeviceHelper ssOnePixel]);
}

- (void)refreshCommentLabel
{
    [_attributeCommentLabel setText:_nameAndCommentStr];
    
    NSMutableArray * attributeModels = [NSMutableArray arrayWithCapacity:10];
    
    if (!isEmptyString(_nameStr)) {
        SSAttributeLabelModel * model = [[SSAttributeLabelModel alloc] init];
        model.linkURLString = [NSString stringWithFormat:@"ExploreArticleEssayCellCommentItemView://profile?index=%i", kCommentUserNameIndex];
        model.textColor = [UIColor tt_themedColorForKey:kColorText5];
        model.attributeRange = NSMakeRange(0, [_nameStr length]);
        [attributeModels addObject:model];
    }

    [_attributeCommentLabel refreshAttributeModels:attributeModels];
}

- (void)refreshWithUserName:(NSString *)userName userComment:(NSString *)commentStr cellWidth:(CGFloat)width
{
    self.nameStr = userName;
    self.commentStr = commentStr;
    self.nameAndCommentStr = [ExploreArticleEssayCellCommentItemView stringForUserName:userName commentContent:commentStr];
    
    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = [ExploreArticleEssayCellCommentItemView heightForUserName:userName userComment:commentStr cellWidth:width];
    self.frame = frame;
    
    _attributeCommentLabel.frame = CGRectMake(kLeftMargin, kTopMargin, width - kLeftMargin - kRightMargin, frame.size.height - kTopMargin - kBottomMargin);
    
    [self refreshCommentLabel];
}

+ (NSString *)stringForUserName:(NSString *)userName commentContent:(NSString *)comment
{
    NSString * str = [NSString stringWithFormat:@"%@%@%@", userName == nil ? @"" : userName, kColonText, comment == nil ? @"" : comment];
    return str;
}

#pragma mark -- height

+ (CGFloat)heightForUserName:(NSString *)userName userComment:(NSString *)commentStr cellWidth:(CGFloat)width
{
    NSString * str = [self stringForUserName:userName commentContent:commentStr];
    
//    CGFloat height = [ExploreCellHelper heightOfText:str fontSize:[NewsUserSettingManager settedFeedCommentFontSize] forWidth:(width - kLeftMargin - kRightMargin) forLineHeight:[NewsUserSettingManager settedFeedCommentLineHeight] constraintToMaxNumberOfLines:0];
    
    CGSize size = [SSAttributeLabel sizeWithText:str font:[UIFont systemFontOfSize:kCellCommentViewFontSize] constrainedToSize:CGSizeMake(width - kLeftMargin - kRightMargin, 999.0f) lineSpacingMultiple:kLineSpacingMultiple];
    
    return ceilf(size.height + kBottomMargin + kTopMargin);
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
                [self handleTapGestureRecognizer:nil];
                [_delegate commentItemDidSeletedCommentButton:self];
            }
        }
        else if (index == kCommentUserNameIndex) {
            if (_delegate && [_delegate respondsToSelector:@selector(commentItemDidSeletedNameButton:)]) {
                [self handleTapGestureRecognizer:nil];
                [_delegate commentItemDidSeletedNameButton:self];
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
            [self handleTapGestureRecognizer:nil];
            [_delegate commentItemDidSeletedCommentButton:self];
        }
    }
}

#pragma mark - background highlight
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentItemDidTouchBegan:)]) {
        [_delegate commentItemDidTouchBegan:self];
    }
    [self updateContentWithHighlightColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentItemDidTouchEnded:)]) {
        [_delegate commentItemDidTouchEnded:self];
    }
    [self updateContentWithNormalColor];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentItemDidTouchCancelled:)]) {
        [_delegate commentItemDidTouchCancelled:self];
    }
    [self updateContentWithNormalColor];
}

- (void)handleTapGestureRecognizer:(id)sender
{
    [self updateContentWithHighlightColor];
    [self performSelector:@selector(updateContentWithNormalColor) withObject:nil afterDelay:0.25];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)updateContentWithHighlightColor
{
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3Highlighted];
}

- (void)updateContentWithNormalColor
{
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];;
}

@end

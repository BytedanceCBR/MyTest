//
//  ExploreDetailNatantWenDaView.m
//  Article
//
//  Created by 冯靖君 on 15/12/21.
//
//

#import "ExploreDetailNatantWenDaView.h"
#import "TTLabelTextHelper.h"
#import "SSAppPageManager.h"

#import "SSThemed.h"
#import "TTDeviceHelper.h"

#define kQLabelMaxLineNum   2
#define kALabelMaxLineNum   3
#define kHMargin            15.f
#define kTopMargin          16.f
#define kBottomMargin       20.f
#define kQLabelBottomMargin 6.f

@interface ExploreDetailNatantWenDaView () <TTTAttributedLabelDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) TTTAttributedLabel *questionLabel;
@property (nonatomic, strong) TTTAttributedLabel *answerLabel;
@property (nonatomic, strong) TTTAttributedLabel *accessoryLabel;
@property (nonatomic, strong) SSThemedButton *bgButton;
@property (nonatomic, strong) SSThemedView * bottomLineView;
@property (nonatomic, strong) NSDictionary *wendaDict;

@end

@implementation ExploreDetailNatantWenDaView

- (void)dealloc
{
    _questionLabel.delegate = nil;
    _accessoryLabel.delegate = nil;
    _answerLabel.delegate = nil;
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        [self buildSubViews];
    }
    return self;
}

- (void)buildSubViews
{
    _bgButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    _bgButton.frame = CGRectMake(0, 0, self.width, 0);
    _bgButton.backgroundColor = [UIColor clearColor];
    _bgButton.highlightedBackgroundColorThemeKey = kColorBackground2Highlighted;
    [_bgButton addTarget:self action:@selector(showAnswer) forControlEvents:UIControlEventTouchUpInside];
    
    _questionLabel = [TTTAttributedLabel new];
    _questionLabel.backgroundColor = [UIColor clearColor];
    _questionLabel.textAlignment = NSTextAlignmentLeft;
    _questionLabel.numberOfLines = kQLabelMaxLineNum;
    _questionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _questionLabel.font = [UIFont boldSystemFontOfSize:[self.class questionLabelFontSize]];
    _questionLabel.delegate = self;
    _questionLabel.extendsLinkTouchArea = NO;
    //点击label文字以外，同行区域的gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showQuestion)];
    [_questionLabel addGestureRecognizer:tap];
    
    _accessoryLabel = [TTTAttributedLabel new];
    _accessoryLabel.backgroundColor = [UIColor clearColor];
    _accessoryLabel.textAlignment = NSTextAlignmentLeft;
    _accessoryLabel.numberOfLines = 1;
    _accessoryLabel.font = [UIFont systemFontOfSize:[self.class questionLabelFontSize]];
    _accessoryLabel.delegate = self;
    _accessoryLabel.extendsLinkTouchArea = NO;
    
    _answerLabel = [TTTAttributedLabel new];
    _answerLabel.backgroundColor = [UIColor clearColor];
    _answerLabel.textAlignment = NSTextAlignmentLeft;
    _answerLabel.numberOfLines = kALabelMaxLineNum;
    _answerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _answerLabel.font = [UIFont systemFontOfSize:[self.class answerLabelFontSize]];
    _answerLabel.delegate = self;
    _answerLabel.extendsLinkTouchArea = NO;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAnswer)];
    tap.delegate = self;
    [_answerLabel addGestureRecognizer:tap];
    
    self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectZero];
    _bottomLineView.backgroundColorThemeKey = kColorLine10;
    
    [self addSubview:_bgButton];
    [self addSubview:_questionLabel];
    [self addSubview:_answerLabel];
    [self addSubview:_bottomLineView];
    
    _wendaDict = [NSMutableDictionary dictionary];
}

- (void)updateLabelsWithDict:(NSDictionary *)dict
{
    NSString *question = [dict[@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *answerUserName = [dict[@"answer_user_name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *answerAbstract = [dict[@"answer_abstract"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *answer = [NSString stringWithFormat:@"%@: %@", answerUserName, answerAbstract];
    NSString *questionUrl = dict[@"question_open_url"];
    NSString *answerUrl = dict[@"answer_open_url"];
    NSString *accessoryText = [dict[@"reply_count"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *userUrl = [NSString stringWithFormat:@"sslocal://profile?uid=%@", dict[@"answer_user_id"]];
    
    //问题
    NSMutableAttributedString *qText = [TTLabelTextHelper attributedStringWithString:question fontSize:[self.class questionLabelFontSize] lineHeight:[self.class questionLabelLineHeight] lineBreakMode:NSLineBreakByWordWrapping isBoldFontStyle:YES firstLineIndent:0 textAlignment:NSTextAlignmentLeft];;
    [qText addAttribute:NSForegroundColorAttributeName value:SSGetThemedColorWithKey(kColorText1) range:NSMakeRange(0, question.length)];
    NSDictionary *lineAttr = @{NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText1)};
    NSDictionary *activeLineAttr = @{NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText1Highlighted)};
    _questionLabel.linkAttributes = lineAttr;
    _questionLabel.activeLinkAttributes = activeLineAttr;
    _questionLabel.attributedText = qText;
    [_questionLabel addLinkToURL:[NSURL URLWithString:questionUrl] withRange:NSMakeRange(0, question.length)];
    
    //回答
    NSMutableAttributedString *aText = [TTLabelTextHelper attributedStringWithString:answer fontSize:[self.class answerLabelFontSize] lineHeight:[self.class answerLabelLineHeight]];
    
    NSRange nameRange = [answer rangeOfString:[answerUserName stringByAppendingString:@":"]];
    NSRange abstractRange = [answer rangeOfString:answerAbstract];
    [aText addAttribute:NSForegroundColorAttributeName value:SSGetThemedColorWithKey(kColorText2) range:abstractRange];
    [aText addAttribute:NSForegroundColorAttributeName value:SSGetThemedColorWithKey(kColorText5) range:nameRange];
    lineAttr = @{NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText5)};
    activeLineAttr = @{NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText5Highlighted)};
    _answerLabel.attributedText = aText;
    
    _answerLabel.linkAttributes = lineAttr;
    _answerLabel.activeLinkAttributes = activeLineAttr;
    [_answerLabel addLinkToURL:[NSURL URLWithString:userUrl] withRange:nameRange];
    lineAttr = @{NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText2)};
    activeLineAttr = @{NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText2Highlighted)};
    _answerLabel.linkAttributes = lineAttr;
    _answerLabel.activeLinkAttributes = activeLineAttr;
    [_answerLabel addLinkToURL:[NSURL URLWithString:answerUrl] withRange:abstractRange];
    
    //回帖数、阅读数等
    if (!isEmptyString(accessoryText)) {
        NSMutableAttributedString *sText = [TTLabelTextHelper attributedStringWithString:accessoryText fontSize:[self.class accessoryLabelFontSize] lineHeight:[UIFont systemFontOfSize:[self.class accessoryLabelFontSize]].lineHeight];
        NSRange accessoryRange = NSMakeRange(0, sText.length);
        [sText addAttribute:NSForegroundColorAttributeName value:SSGetThemedColorWithKey(kColorText2) range:accessoryRange];
        lineAttr = @{NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText2)};
        _accessoryLabel.attributedText = sText;
        _accessoryLabel.linkAttributes = lineAttr;
        _accessoryLabel.activeLinkAttributes = lineAttr;
        [_accessoryLabel addLinkToURL:[NSURL URLWithString:questionUrl] withRange:accessoryRange];
        [_questionLabel addSubview:_accessoryLabel];
    }
}

- (void)layoutLabels
{
    CGFloat labelWidth = self.width - kHMargin*2;
    CGFloat qLabelHeight = [TTLabelTextHelper heightOfText:_questionLabel.attributedText.string fontSize:[self.class questionLabelFontSize] forWidth:labelWidth forLineHeight:[self.class questionLabelLineHeight] constraintToMaxNumberOfLines:kQLabelMaxLineNum firstLineIndent:0 textAlignment:NSTextAlignmentLeft] + 1;
    CGFloat aLabelHeight = [TTLabelTextHelper heightOfText:_answerLabel.attributedText.string fontSize:[self.class answerLabelFontSize] forWidth:labelWidth forLineHeight:[self.class answerLabelLineHeight] constraintToMaxNumberOfLines:kALabelMaxLineNum firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    _questionLabel.frame = CGRectMake(kHMargin, kTopMargin, labelWidth, qLabelHeight);
    _accessoryLabel.frame = [self frameForAccessoryLabel];
    
    _answerLabel.frame = CGRectMake(kHMargin, _questionLabel.bottom + kQLabelBottomMargin, labelWidth, aLabelHeight);
    _bottomLineView.frame = CGRectMake(kHMargin, _answerLabel.bottom + kBottomMargin, labelWidth, [TTDeviceHelper ssOnePixel]);
    
    self.height = _bottomLineView.bottom;
    _bgButton.height = self.height;
}

- (CGRect)frameForAccessoryLabel
{
    if (isEmptyString(_accessoryLabel.attributedText.string)) {
        return CGRectZero;
    }
    CGSize accessoryLabelSize = [_accessoryLabel.attributedText.string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[self.class accessoryLabelFontSize]]}];
    CGSize questionLabelSizeAsSingleLine = [_questionLabel.attributedText.string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[self.class questionLabelFontSize]]}];
    CGFloat accesoryLableTop = _questionLabel.height - (accessoryLabelSize.height + questionLabelSizeAsSingleLine.height)/2 + 1.5f;
    CGFloat singleLineMaxWidth = self.width - kHMargin*2;
    CGFloat lastLineWidth = questionLabelSizeAsSingleLine.width < singleLineMaxWidth ? questionLabelSizeAsSingleLine.width : [self.class lastLineStringWidthFromLabel:_questionLabel maxWidth:singleLineMaxWidth];
    
    if (lastLineWidth + accessoryLabelSize.width > singleLineMaxWidth) {
        CGFloat qLabelLastLineMaxWidth = singleLineMaxWidth - accessoryLabelSize.width;
        CGFloat exceedWidth = lastLineWidth - qLabelLastLineMaxWidth;
        CGFloat charWidth = [UIFont systemFontOfSize:[self.class questionLabelFontSize]].pointSize;
        int shouldWrapCharNumber = exceedWidth/charWidth + 2;   //考虑...的宽度
        NSMutableAttributedString *mutAttString = [_questionLabel.attributedText mutableCopy];
        [mutAttString replaceCharactersInRange:NSMakeRange(mutAttString.string.length - shouldWrapCharNumber, shouldWrapCharNumber) withString:@"..."];
        _questionLabel.attributedText = mutAttString;
        lastLineWidth = [self.class lastLineStringWidthFromLabel:_questionLabel maxWidth:singleLineMaxWidth];
    }
    return CGRectMake(lastLineWidth, accesoryLableTop, accessoryLabelSize.width, accessoryLabelSize.height);
}

- (void)themeChanged:(NSNotification *)notification
{
    [self updateLabelsWithDict:_wendaDict];
    _accessoryLabel.frame = [self frameForAccessoryLabel];
}

- (void)refreshWithWendaInfo:(NSDictionary *)dict
{
    _wendaDict = dict;
    [self updateLabelsWithDict:dict];
    [self layoutLabels];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if ([[SSAppPageManager sharedManager] canOpenURL:url]) {
        [[SSAppPageManager sharedManager] openURL:url];
    }
}

- (void)showQuestion
{
    NSString *questionUrl = _wendaDict[@"question_open_url"];
    if (!isEmptyString(questionUrl)) {
        NSURL *openUrl = [NSURL URLWithString:questionUrl];
        if ([[SSAppPageManager sharedManager] canOpenURL:openUrl]) {
            [[SSAppPageManager sharedManager] openURL:openUrl];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    NSString *answerUserName = [[_wendaDict[@"answer_user_name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAppendingString:@": "];
    NSDictionary *nameLabelAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:[self.class answerLabelFontSize]]};
    CGSize nameSize = [answerUserName sizeWithAttributes:nameLabelAttr];
    CGFloat nameLabelHeight = [TTLabelTextHelper heightOfText:answerUserName fontSize:[self.class answerLabelFontSize] forWidth:nameSize.width forLineHeight:[self.class answerLabelLineHeight] constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    CGRect nameRect = CGRectMake(0, 0, nameSize.width, nameLabelHeight);
    return !CGRectContainsPoint(nameRect, touchPoint);
}

- (void)showAnswer
{
    NSString *answerUrl = _wendaDict[@"answer_open_url"];
    if (!isEmptyString(answerUrl)) {
        NSURL *openUrl = [NSURL URLWithString:answerUrl];
        if ([[SSAppPageManager sharedManager] canOpenURL:openUrl]) {
            [[SSAppPageManager sharedManager] openURL:openUrl];
        }
    }
}

- (void)hideBottomLine:(BOOL)hide
{
    self.bottomLineView.hidden = hide;
}

+ (CGFloat)questionLabelFontSize
{
    return 17.f;
}

+ (CGFloat)answerLabelFontSize
{
    return 16.f;
}

+ (CGFloat)questionLabelLineHeight
{
    return 24.f;
}

+ (CGFloat)answerLabelLineHeight
{
    return 23.f;
}

+ (CGFloat)accessoryLabelFontSize
{
    return 12.f;
}

+ (NSArray *)linesFromLabel:(UILabel *)label maxWidth:(CGFloat)maxWidth
{
    NSString *text = [self removeSurplusSpace:[[label attributedText] string]];
    UIFont   *font = [label font];
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,maxWidth,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);

    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    
    CFRelease(myFont);
    CFRelease(frameSetter);
    CFRelease(frame);
    CGPathRelease(path);
    
    return lines;
}

+ (CGFloat)lastLineStringWidthFromLabel:(UILabel *)label maxWidth:(CGFloat)maxWidth
{
    NSString *text = [self removeSurplusSpace:[[label attributedText] string]];
    NSArray *lines = [self linesFromLabel:label maxWidth:maxWidth];
    if (lines.count) {
        NSInteger maxLines = 2;
        CGFloat exceedLinesWidth = 0;
        if (lines.count > maxLines) {
            for (NSInteger idx = maxLines; idx < lines.count; idx++) {
                exceedLinesWidth += [self singleLineWidthForLine:lines[idx] inLabel:label forText:text];
            }
            //要算上第二行高度
            exceedLinesWidth += maxWidth;
        }
        else {
            exceedLinesWidth = [self singleLineWidthForLine:[lines lastObject] inLabel:label forText:text];
        }
        return exceedLinesWidth;
    }
    else {
        return 0;
    }
}

+ (CGFloat)singleLineWidthForLine:(id)line inLabel:(UILabel *)label forText:(NSString *)text
{
    CGFloat lineWidth = 0;
    CTLineRef lineRef = (__bridge CTLineRef )line;
    CFRange lineRange = CTLineGetStringRange(lineRef);
    NSRange range = NSMakeRange(lineRange.location, lineRange.length);
    
    NSString *lineString = [text substringWithRange:range];
    lineWidth = [lineString sizeWithAttributes:@{NSFontAttributeName:label.font}].width;
    return lineWidth;
}

+ (NSString *)removeSurplusSpace:(NSString *)string {
    NSString *newString = [string stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    BOOL flag = true;
    for (int i = (int)(newString.length - 1); i >= 0; i--) {
        char ch = [newString characterAtIndex:i];
        if (flag || ch != ' ') {
            flag = true;
            if (ch == ' ') {
                flag = false;
            }
        } else {
            [newString stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:@""];
        }
    }
    return newString;
}

@end

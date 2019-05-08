//
//  SSAttributeLabel.m
//  Article
//
//  Created by Zhang Leonardo on 13-6-17.
//
//

#import "SSAttributeLabel.h"
#import <CoreText/CoreText.h>
#import "TTIndicatorView.h"
#import "TTRoute.h"
#import "TTIndicatorView.h"
#import "TTStringHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "UIColor+TTThemeExtension.h"

#define kCallAlertTag 1

@implementation SSAttributeLabelModel

- (void)dealloc
{
    self.textColor = nil;
    self.linkURLString = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.textUnderLineStyle = SSAttributeLabelTextUnderLineStyleNotSet;
        self.textColor = nil;
    }
    return self;
}

#pragma mark -- setter

- (void)setLinkURLString:(NSString *)linkURLString
{
    _linkURLString = linkURLString;
    
    if (_textColor == nil) {
        self.textColor = [UIColor blueColor];
    }
    
    if (_textUnderLineStyle == SSAttributeLabelTextUnderLineStyleNotSet) {
        _textUnderLineStyle = SSAttributeLabelTextUnderLineStyleSingle;
    }
    
}


@end

@interface SSAttributeLabel()<UIActionSheetDelegate>

@property(readwrite, nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, retain)NSMutableAttributedString * ssAttributeString;
@property(nonatomic, retain)NSMutableArray * ssTextCheckingResults;
@property(nonatomic, retain)NSMutableArray * ssTextAutoDetectedResults;//监测出来的link等。。。
@property(nonatomic, retain)NSArray * attributeModels;                  //SSAttributeLabelModels
@property(nonatomic, retain)NSString * callPhoneNumber;//用户保存当前正要呼叫的电话
@property(nonatomic, assign)NSRange backgroundHighlightRange;
@property(nonatomic, retain)UIColor * previousHighlightColor;
@property(nonatomic, retain)UIColor * priviousBackgroundColor;
@property(nonatomic, retain)UIFont * fixFont;//为了修复ios6 bug
@property(nonatomic, assign)BOOL supportCopy;
@end

@implementation SSAttributeLabel

static inline NSTextCheckingTypes NSTextCheckingTypeFromUIDataDetectorType(UIDataDetectorTypes dataDetectorType) {
    NSTextCheckingTypes textCheckingType = 0;
    if (dataDetectorType & UIDataDetectorTypeAddress) {
        textCheckingType |= NSTextCheckingTypeAddress;
    }
    
    if (dataDetectorType & UIDataDetectorTypeCalendarEvent) {
        textCheckingType |= NSTextCheckingTypeDate;
    }
    
    if (dataDetectorType & UIDataDetectorTypeLink) {
        textCheckingType |= NSTextCheckingTypeLink;
    }
    
    if (dataDetectorType & UIDataDetectorTypePhoneNumber) {
        textCheckingType |= NSTextCheckingTypePhoneNumber;
    }
    
    return textCheckingType;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.selectTextForegroundColorName = nil;
    self.fixFont = nil;
    self.priviousBackgroundColor = nil;
    self.backgroundHighlightColorName = nil;
    self.previousHighlightColor = nil;
    self.callPhoneNumber = nil;
    self.ssTextAutoDetectedResults = nil;
    self.detectedTextColor = nil;
    self.delegate = nil;
    self.ssTextCheckingResults = nil;
    self.ssAttributeString = nil;
    self.attributeModels = nil;
    [self removeGestureRecognizer:_tapGestureRecognizer];
    self.tapGestureRecognizer = nil;
}

+ (NSDictionary *) defaultAttributes {
    static NSDictionary * _defaultAttributes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
        CTParagraphStyleSetting paraStyles[1] = {
            {.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void*)&lineBreakMode}
        };
        CTParagraphStyleRef aStyle = CTParagraphStyleCreate(paraStyles, 1);
        
        _defaultAttributes = @{(NSString *) kCTParagraphStyleAttributeName:(__bridge id) aStyle};
        CFRelease(aStyle);
    });
    return _defaultAttributes;
}

+ (CGSize) sizeWithText:(NSString *) text
                   font:(UIFont *) font
      constrainedToSize:(CGSize) constrainedSize {

    return [self sizeWithText:text font:font constrainedToSize:constrainedSize lineSpacingMultiple:0];
}

+ (CGSize) sizeWithText:(NSString *) text
                   font:(UIFont *) font
      constrainedToSize:(CGSize) constrainedSize
     lineSpacingMultiple:(CGFloat)lineSpacingMultiple
{
    if (!text) {
        return CGSizeZero;
    }
    id fontName = CFBridgingRelease(CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL));
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:[self defaultAttributes]];
    
    if (fontName) {
        [attributedString addAttribute:(NSString *)kCTFontAttributeName value:fontName range:NSMakeRange(0, attributedString.length)];
    }

    if (lineSpacingMultiple > 0) {
        [attributedString removeAttribute:(NSString *)kCTParagraphStyleAttributeName range:NSMakeRange(0, attributedString.length)];
//            if ([TTDeviceHelper isScreenWidthLarge320]) {
//                lineSpacingMultiple = 0.15;
//            } //屏幕宽度越大，需要将行间距的系数变大，才能使得评论都显示出来。
        CGFloat lineSpacing = font.lineHeight * lineSpacingMultiple;
        CTParagraphStyleSetting paraStyles[] = {
            {.spec = kCTParagraphStyleSpecifierLineSpacing, .valueSize = sizeof(CGFloat), .value = (const void*)&lineSpacing}
        };
        CTParagraphStyleRef aStyle = CTParagraphStyleCreate(paraStyles, sizeof(paraStyles)/sizeof(CTParagraphStyleSetting));
        
        if (aStyle) {
            [attributedString addAttribute:(NSString *)kCTParagraphStyleAttributeName value:(__bridge id)aStyle range:NSMakeRange(0, attributedString.length)];
        }
        CFRelease(aStyle);
    }
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedString.length), NULL, constrainedSize, NULL);
    CFRelease(framesetter);
    size.height += 5;
    return size;
}

- (id)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame supportCopy:NO];
    return self;
}

- (id)initWithFrame:(CGRect)frame supportCopy:(BOOL)supportCopy
{
    self = [super initWithFrame:frame];
    if (self) {
        self.supportCopy = supportCopy;
        self.backgroundHighlightRange = NSMakeRange(NSNotFound, 0);
        self.userInteractionEnabled = YES;
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:self.tapGestureRecognizer];
        
        if (_supportCopy) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            [self addGestureRecognizer:longPress];
        }
        
        self.detectedTextUnderLineStyle = SSAttributeLabelTextUnderLineStyleSingle;
        self.detectedTextColor = [UIColor blueColor];
        self.ssDataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
        
        self.fixFont = self.font;
    }
    return self;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    self.fixFont = [UIFont fontWithName:font.fontName size:font.pointSize];
}

- (NSUInteger)textIndexAtTouchPoint:(CGPoint)clickedPoint
{
    CGRect textRect;
    @try {
        textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    }
    @catch (NSException *exception) {
        textRect = self.bounds;
    }
    @finally {
        
    }
    
    if (!CGRectContainsPoint(textRect, clickedPoint)) {
        return NSNotFound;
    }
    //转换坐标系
    CGPoint p = CGPointMake(clickedPoint.x, textRect.size.height - clickedPoint.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    if (_fixFont) {
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:_fixFont range:NSMakeRange(0, attStr.length)];
    }
    
    if (self.lineSpacingMultiple > 0) {
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = _fixFont.lineHeight * self.lineSpacingMultiple;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        
        if (style) {
            [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attStr.length)];
        }
    }
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attStr);
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [self.text length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(frameSetter);
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSUInteger numberOfLines = CFArrayGetCount(lines);
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(frameSetter);
        CFRelease(path);
        return NSNotFound;
    }
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    NSUInteger lineIndex;
    for (lineIndex = 0; lineIndex < (numberOfLines - 1); lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        if (lineOrigin.y < p.y) {
            break;
        }
    }
    
    if (lineIndex >= numberOfLines) {
        CFRelease(frame);
        CFRelease(frameSetter);
        CFRelease(path);
        return NSNotFound;
    }
    
    CGPoint lineOrigin = lineOrigins[lineIndex];
    CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
    // Convert CT coordinates to line-relative coordinates
    CGPoint relativePoint = CGPointMake(p.x - lineOrigin.x, p.y - lineOrigin.y);
    CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
    
    // We should check if we are outside the string range
    CFIndex glyphCount = CTLineGetGlyphCount(line);
    CFRange stringRange = CTLineGetStringRange(line);
    CFIndex stringRelativeStart = stringRange.location;
    if ((idx - stringRelativeStart) == glyphCount) {
        CFRelease(frame);
        CFRelease(frameSetter);
        CFRelease(path);
        return NSNotFound;
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
    return idx;

}

- (void)updateDataDetectorResults
{
    [_ssTextAutoDetectedResults removeAllObjects];
    if (isEmptyString(self.text) || _ssDataDetectorTypes == UIDataDetectorTypeNone) {
        return;
    }
    NSError *error = NULL;
    NSDataDetector * detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeFromUIDataDetectorType(_ssDataDetectorTypes) error:&error];
    if (error) {
        return;
    }
    NSArray *matches = [detector matchesInString:self.text options:0 range:NSMakeRange(0, [self.text length])];
    for (NSTextCheckingResult *result in matches) {
        
        if (result != nil) {
            if (!_ssTextAutoDetectedResults) {
                self.ssTextAutoDetectedResults = [NSMutableArray arrayWithCapacity:10];
            }
            [_ssTextAutoDetectedResults addObject:result];
            
            if (!_ssTextAutoDetectedResults) {
                self.ssTextAutoDetectedResults = [NSMutableArray arrayWithCapacity:10];
            }
            [_ssTextCheckingResults insertObject:result atIndex:0];
        }
    }
}

- (void)updateSSAttributeString
{
    self.ssAttributeString = nil;
    if(isEmptyString(self.text))
    {
        self.ssAttributeString = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    else
    {
        self.ssAttributeString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    
    if (_fixFont) {
        [_ssAttributeString addAttribute:(NSString *)kCTFontAttributeName value:_fixFont range:NSMakeRange(0, _ssAttributeString.length)];
    }
    
    if (self.textColor) {
        [_ssAttributeString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)self.textColor.CGColor range:NSMakeRange(0, _ssAttributeString.length)];
    }

    
    // line spacing
    if (self.lineSpacingMultiple > 0) {
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = _fixFont.lineHeight * self.lineSpacingMultiple;
        
        if (style) {
            [_ssAttributeString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, _ssAttributeString.length)];
        }
    }

    // auto detected text
    for (NSTextCheckingResult * result in _ssTextAutoDetectedResults) {
        if ([self isRangeAvailabel:result.range]) {
            if (self.detectedTextColor) {
                [_ssAttributeString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)self.detectedTextColor.CGColor range:result.range];
            }
            
            if ((_detectedTextUnderLineStyle & SSAttributeLabelTextUnderLineStyleSingle) > 1 && _detectedTextUnderLineStyle > 0) {
                    [_ssAttributeString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:result.range];
            }
            
            if ((_detectedTextUnderLineStyle & SSAttributeLabelTextUnderLineStyleDouble) > 1 && _detectedTextUnderLineStyle > 0) {
                [_ssAttributeString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleDouble] range:result.range];
            }
            
            if ((_detectedTextUnderLineStyle & SSAttributeLabelTextUnderLineStyleItalic) > 1 && _detectedTextUnderLineStyle > 0) {
                UIFont *font = [UIFont italicSystemFontOfSize:self.font.pointSize];
                CTFontRef italicFontRe = CTFontCreateWithName ((CFStringRef)[font fontName], [font pointSize], NULL);
                CFAttributedStringSetAttribute((CFMutableAttributedStringRef)_ssAttributeString, CFRangeMake(result.range.location, result.range.location), kCTFontAttributeName, italicFontRe);
                CFRelease(italicFontRe);
            }
        }
    }
    
    for (SSAttributeLabelModel * model in _attributeModels) {
        if ([self isRangeAvailabel:model.attributeRange]) {
//color
            if (model.textColor) {
                [_ssAttributeString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)model.textColor.CGColor range:model.attributeRange];
            }
//underLine
            if ((model.textUnderLineStyle & SSAttributeLabelTextUnderLineStyleSingle) > 1 && model.textUnderLineStyle > 0) {
                [_ssAttributeString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:model.attributeRange];
            }
            if ((model.textUnderLineStyle & SSAttributeLabelTextUnderLineStyleDouble) > 1 && model.textUnderLineStyle > 0) {
                [_ssAttributeString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleDouble] range:model.attributeRange];
            }
            if ((model.textUnderLineStyle & SSAttributeLabelTextUnderLineStyleItalic) > 0 && model.textUnderLineStyle > 0) {
                UIFont *font = [UIFont italicSystemFontOfSize:self.font.pointSize];
                CTFontRef italicFontRe = CTFontCreateWithName ((CFStringRef)[font fontName], [font pointSize], NULL);
                CFAttributedStringSetAttribute((CFMutableAttributedStringRef)_ssAttributeString, CFRangeMake(model.attributeRange.location, model.attributeRange.location), kCTFontAttributeName, italicFontRe);
                CFRelease(italicFontRe);
            }
        }
    }
}



- (void)updateSSTextCheckingResults
{
    if (!_ssTextCheckingResults) {
        self.ssTextCheckingResults = [NSMutableArray arrayWithCapacity:10];
    }
    [_ssTextCheckingResults removeAllObjects];
    for (SSAttributeLabelModel * model in _attributeModels) {
        if ([self isRangeAvailabel:model.attributeRange] && !isEmptyString(model.linkURLString)) {
            
            NSURL * url = [TTStringHelper URLWithURLString:model.linkURLString];
            [_ssTextCheckingResults addObject:[NSTextCheckingResult linkCheckingResultWithRange:model.attributeRange URL:url]];
        }
    }
    
    [self updateDataDetectorResults];
}

- (BOOL)isRangeAvailabel:(NSRange)range
{
    if (range.location == NSNotFound || range.location > [self.text length] || range.location + range.length > [self.text length]) {
        return NO;
    }
    return YES;
}
/*
    返回YES:动作已处理
    返回NO:动作未处理
 */
- (BOOL)linkAtTextIndex:(CFIndex)index
{
    for (NSTextCheckingResult * result in _ssTextCheckingResults) {
        
        if ((CFIndex)result.range.location <= index && index <= (CFIndex)(result.range.location + result.range.length - 1)) {
            BOOL returnValue = NO;
            switch (result.resultType) {
                case NSTextCheckingTypeLink:
                {
                    NSString * actionURLString = [result.URL absoluteString];

                    if (_delegate && [_delegate respondsToSelector:@selector(attributeLabel:didClickLink:)]) {
                        [_delegate attributeLabel:self didClickLink:actionURLString];
                    }
                    else {
                        
                        NSURL * url = [TTStringHelper URLWithURLString:actionURLString];
                        if ([actionURLString hasPrefix:TTLocalScheme] || [actionURLString hasPrefix:@"snssdk35"]) {
                            [[TTRoute sharedRoute] openURLByPushViewController:url];
                        }
                        else {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }
                    returnValue = YES;
                }
                    break;
                case NSTextCheckingTypeAddress:
                {
                    //not support now
                }
                    break;
                case NSTextCheckingTypePhoneNumber:
                {

                    self.callPhoneNumber = [NSString stringWithFormat:@"%@", result.phoneNumber];

                    NSString * tipTitle = [NSString stringWithFormat:NSLocalizedString(@"呼叫%@", nil), result.phoneNumber];
                    
                    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:tipTitle
                                                                              delegate:self
                                                                     cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                                                destructiveButtonTitle:nil
                                                                     otherButtonTitles:NSLocalizedString(@"呼叫", nil), NSLocalizedString(@"复制", nil), nil];
                    [actionSheet showInView:self];
                    actionSheet.tag = kCallAlertTag;
                    
                    returnValue = YES;
                }
                    break;
                case NSTextCheckingTypeDate:
                {
                    // not support now
                }
                    break;
                default:
                {
                    //not support now
                }
                    break;
            }
            
            return returnValue;
        }
    }
    return NO;
}

#pragma mark -- setter

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    if (!isEmptyString(text)) {
        [self updateSSTextCheckingResults];
        [self updateSSAttributeString];
    }
}

- (void)refreshAttributeModels:(NSArray *)attributeModels
{
    if ([attributeModels count] == 0) {
        self.attributeModels = nil;
    }
    else {
        self.attributeModels = attributeModels;
        [self updateSSTextCheckingResults];
    }
    [self updateSSAttributeString];
}

#pragma mark -- protected

- (void)drawTextInRect:(CGRect)rect
{
    if (!_ssAttributeString) {
        [super drawTextInRect:rect];
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, rect.size.height), 1.f, -1.f));
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_ssAttributeString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    CFRelease(framesetter);
    
    CTFrameDraw(frame, ctx);
    CFRelease(frame);
}



#pragma mark - UIGestureRecognizer

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] != UIGestureRecognizerStateEnded) {
        return;
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
        return;
    }
    CGPoint clickedPoint = [gestureRecognizer locationInView:self];
    CFIndex clickIndex = [self textIndexAtTouchPoint:clickedPoint];
    BOOL actionDealed = NO;
    if (clickIndex != NSNotFound) {
        actionDealed = [self linkAtTextIndex:clickIndex];
    }

    if (!actionDealed) {
        if (_delegate && [_delegate respondsToSelector:@selector(attributeLabelClickedUntackArea:)]) {
            [_delegate attributeLabelClickedUntackArea:self];
            
            [self changeBackgroundColorResetLater];
        }
    }
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)handleLongPress:(UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"复制", nil) action:@selector(customCopy:)];
        if (copyItem) {
            menu.menuItems = @[copyItem];
        }
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
        [self changeBackgroundColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenu) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
}

- (void)willHideMenu {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    [self resetSelectedBackgroundHighlight];
    [self resetBackgroundColor];
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(__unused id)sender
{
    return (action == @selector(customCopy:));
}

#pragma mark - UIResponderStandardEditActions

- (void)customCopy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:self.text];
}

#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kCallAlertTag) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            //do nothing
        }
        else {
            if (buttonIndex == 0) {
                if (!isEmptyString(_callPhoneNumber)) {
                    NSString *escapedPhoneNumber = [NSString stringWithFormat:@"%@", _callPhoneNumber];
                    NSURL *telURL = [TTStringHelper URLWithURLString:[NSString stringWithFormat:@"tel://%@", escapedPhoneNumber]];
                    [[UIApplication sharedApplication] openURL:telURL];
                }
            }
            else if (buttonIndex == 1) {
                if (!isEmptyString(_callPhoneNumber)) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    [pasteboard setString:_callPhoneNumber];
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"复制成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                }
            }
        }
        self.callPhoneNumber = nil;
    }
}
#pragma mark -- action

- (void)addSelectedBackgroundColor:(NSRange)range
{
    if ([self respondsToSelector:@selector(attributedText)]) {
        UIColor * selectColor = nil;
        if ([[TTThemeManager sharedInstance_tt] rgbaValueForKey:_selectTextForegroundColorName]) {
            selectColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] rgbaValueForKey:_selectTextForegroundColorName]];
        }
        else {
            selectColor = [UIColor grayColor];
        }
        
        if (selectColor) {
            [_ssAttributeString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)selectColor.CGColor range:range];
        }
        self.attributedText = _ssAttributeString;
    }
}

- (void)removeBackgroundRangeColor:(NSRange)range
{
    if ([self respondsToSelector:@selector(attributedText)]) {
        if (_previousHighlightColor) {
            [_ssAttributeString addAttribute:(NSString *)kCTForegroundColorAttributeName value:_previousHighlightColor range:range];
        }
        self.attributedText = _ssAttributeString;
    }
}

- (void)resetSelectedBackgroundHighlight
{
    if (_backgroundHighlightRange.location != NSNotFound) {
        [self removeBackgroundRangeColor:_backgroundHighlightRange];
        _backgroundHighlightRange = NSMakeRange(NSNotFound, 0);
    }
}

#pragma mark -- touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    CGPoint clickedPoint = [[touches anyObject] locationInView:self];
    NSInteger clickIndex = [self textIndexAtTouchPoint:clickedPoint];
    for (SSAttributeLabelModel * model in _attributeModels) {
        NSRange range = model.attributeRange;
        if (NSLocationInRange(clickIndex, range)) {
            self.backgroundHighlightRange = range;
            self.previousHighlightColor = model.textColor;
            if (_previousHighlightColor == nil) {
                self.previousHighlightColor = self.detectedTextColor;
            }
            break;
        }
    }
    if (_backgroundHighlightRange.location != NSNotFound) {
        [self addSelectedBackgroundColor:_backgroundHighlightRange];
    }
    else {
        [self changeBackgroundColor];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self resetSelectedBackgroundHighlight];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        return;
    }
    [self resetBackgroundColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self resetSelectedBackgroundHighlight];
    [self resetBackgroundColor];
}


#pragma mark -- backgroundColor

- (void)changeBackgroundColorResetLater
{
    [self changeBackgroundColor];
    [self performSelector:@selector(resetBackgroundColor) withObject:nil afterDelay:0.25];
}

- (void)changeBackgroundColor
{
    if (!isEmptyString(_backgroundHighlightColorName) && !isEmptyString([[TTThemeManager sharedInstance_tt] rgbaValueForKey:_backgroundHighlightColorName])) {
        
        //    self.previousHighlightColor = self.backgroundColor;
        self.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] rgbaValueForKey:_backgroundHighlightColorName]];
        
        return;
    }

    if (_supportCopy) {
        self.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] rgbaValueForKey:_backgroundHighlightColorName]];
    }
}

- (void)resetBackgroundColor
{
    if ((!isEmptyString(_backgroundHighlightColorName) && !isEmptyString([[TTThemeManager sharedInstance_tt] rgbaValueForKey:_backgroundHighlightColorName])) || _supportCopy) {
        self.backgroundColor = [UIColor clearColor];
        if ([self respondsToSelector:@selector(attributedText)]) {
            self.attributedText = _ssAttributeString;
        }

        return;
    }
}

@end

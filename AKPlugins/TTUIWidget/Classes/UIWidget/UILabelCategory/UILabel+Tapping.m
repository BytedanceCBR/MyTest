//
//  UILabel+Tapping.m
//  Article
//
//  Created by lizhuoli on 17/2/16.
//
//

#import "UILabel+Tapping.h"
#import "SSThemed.h"
#import <objc/runtime.h>

@interface UILabel () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *tt_longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tt_tapGestureRecognizer;
@property (nonatomic, strong) NSMutableDictionary<NSValue *,NSURL *> *tt_linkAttrStringDict;
@property (nonatomic, strong) NSDataDetector *tt_dataDetector;
@property (nonatomic, strong) NSValue *tt_currentRange;
@property (nonatomic, assign) BOOL tt_isLinkInLocation;

@end

@implementation UILabel (Tapping)

- (UILongPressGestureRecognizer *)tt_longPressGestureRecognizer
{
    UILongPressGestureRecognizer *longPressGestureRecognizer = objc_getAssociatedObject(self, @selector(tt_longPressGestureRecognizer));
    if (!longPressGestureRecognizer) {
        longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLabelLongPressed:)];
        longPressGestureRecognizer.minimumPressDuration = 0;
        [self setTt_longPressGestureRecognizer:longPressGestureRecognizer];
    }
    
    return longPressGestureRecognizer;
}

- (void)setTt_longPressGestureRecognizer:(UILongPressGestureRecognizer *)tt_longPressGestureRecognizer
{
    objc_setAssociatedObject(self, @selector(tt_longPressGestureRecognizer), tt_longPressGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITapGestureRecognizer *)tt_tapGestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = objc_getAssociatedObject(self, @selector(tt_tapGestureRecognizer));
    if (!tapGestureRecognizer) {
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didLabelTapped:)];
        [self setTt_tapGestureRecognizer:tapGestureRecognizer];
    }
    
    return tapGestureRecognizer;
}

- (void)setTt_tapGestureRecognizer:(UITapGestureRecognizer *)tt_tapGestureRecognizer
{
    objc_setAssociatedObject(self, @selector(tt_tapGestureRecognizer), tt_tapGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSMutableDictionary<NSValue *,NSURL *> *)tt_linkAttrStringDict
{
    NSMutableDictionary *linkAttrStringDict = objc_getAssociatedObject(self, @selector(tt_linkAttrStringDict));
    if (!linkAttrStringDict) {
        linkAttrStringDict = [NSMutableDictionary dictionaryWithCapacity:1];
        [self setTt_linkAttrStringDict:linkAttrStringDict];
    }
    
    return linkAttrStringDict;
}

- (void)setTt_linkAttrStringDict:(NSMutableDictionary<NSValue *,NSURL *> *)tt_linkAttrStringDict
{
    objc_setAssociatedObject(self, @selector(tt_linkAttrStringDict), tt_linkAttrStringDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDataDetector *)tt_dataDetector
{
    NSDataDetector *tt_dataDetector = objc_getAssociatedObject(self, @selector(tt_dataDetector));
    if (!tt_dataDetector) {
        tt_dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        [self setTt_dataDetector:tt_dataDetector];
    }
    
    return tt_dataDetector;
}

- (void)setTt_dataDetector:(NSDataDetector *)tt_dataDetector
{
    objc_setAssociatedObject(self, @selector(tt_dataDetector), tt_dataDetector, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSValue *)tt_currentRange
{
    return objc_getAssociatedObject(self, @selector(tt_currentRange));
}

- (void)setTt_currentRange:(NSValue *)tt_currentRange
{
    objc_setAssociatedObject(self, @selector(tt_currentRange), tt_currentRange, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tt_isLinkInLocation
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(tt_isLinkInLocation));
    return [value boolValue];
}

- (void)setTt_isLinkInLocation:(BOOL)tt_isLinkInLocation
{
    objc_setAssociatedObject(self, @selector(tt_isLinkInLocation), @(tt_isLinkInLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary<NSString *,id> *)labelLinkAttributes
{
    return objc_getAssociatedObject(self, @selector(labelLinkAttributes));
}

- (void)setLabelLinkAttributes:(NSDictionary<NSString *,id> *)labelLinkAttributes
{
    objc_setAssociatedObject(self, @selector(labelLinkAttributes), labelLinkAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary<NSString *,id> *)labelActiveLinkAttributes
{
    return objc_getAssociatedObject(self, @selector(labelActiveLinkAttributes));
}

- (void)setLabelActiveLinkAttributes:(NSDictionary<NSString *,id> *)labelActiveLinkAttributes
{
    objc_setAssociatedObject(self, @selector(labelActiveLinkAttributes), labelActiveLinkAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self refreshLinkAttributes];
}

- (NSDictionary<NSString *,id> *)labelInactiveLinkAttributes
{
    return objc_getAssociatedObject(self, @selector(labelInactiveLinkAttributes));
}

- (void)setLabelInactiveLinkAttributes:(NSDictionary<NSString *,id> *)labelInactiveLinkAttributes
{
    objc_setAssociatedObject(self, @selector(labelInactiveLinkAttributes), labelInactiveLinkAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self refreshLinkAttributes];
}

- (id<TTLabelTappingDelegate>)labelTappingDelegate
{
    return objc_getAssociatedObject(self, @selector(labelTappingDelegate));
}

- (void)setNeedSimultaneouslyScrollGesture:(BOOL)needSimultaneouslyScrollGesture {
    objc_setAssociatedObject(self, @selector(needSimultaneouslyScrollGesture), @(needSimultaneouslyScrollGesture), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)needSimultaneouslyScrollGesture {
    NSNumber *value = objc_getAssociatedObject(self, @selector(needSimultaneouslyScrollGesture));
    return [value boolValue];
}

- (void)setLabelTappingDelegate:(id<TTLabelTappingDelegate>)labelTappingDelegate
{
    if (labelTappingDelegate) {
        self.userInteractionEnabled = YES;
        self.tt_tapGestureRecognizer.delegate = self;
        self.tt_longPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.tt_tapGestureRecognizer];
        [self addGestureRecognizer:self.tt_longPressGestureRecognizer];
    } else {
        self.userInteractionEnabled = NO;
        self.tt_tapGestureRecognizer.delegate = nil;
        self.tt_longPressGestureRecognizer.delegate = nil;
        [self removeGestureRecognizer:self.tt_tapGestureRecognizer];
        [self removeGestureRecognizer:self.tt_longPressGestureRecognizer];
    }
    objc_setAssociatedObject(self, @selector(labelTappingDelegate), labelTappingDelegate, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - Public API
- (void)addLinkToLabelWithURL:(NSURL *)URL range:(NSRange)range
{
    if (!URL) return;
    NSValue *targetRange = [NSValue valueWithRange:range];
    if (!targetRange) {
        return;
    }
    
    NSMutableAttributedString *mutableAttrString = [self.attributedText mutableCopy];
    [mutableAttrString addAttributes:self.labelInactiveLinkAttributes range:range];
    self.attributedText = mutableAttrString;
    
    [self.tt_linkAttrStringDict setObject:URL forKey:targetRange];
}

- (void)detectAndAddLinkToLabel
{
    NSString *attrString = self.attributedText.string;
    if (isEmptyString(attrString)) {
        return;
    }
    
    NSArray *matches = [self.tt_dataDetector matchesInString:attrString options:0 range:NSMakeRange(0, attrString.length)];
    if (matches.count > 0) {
        for (NSTextCheckingResult *result in matches) {
            NSRange linkRange = result.range;
            NSURL *linkURL = result.URL;
            if (NSMaxRange(linkRange) <= attrString.length) {
                [self addLinkToLabelWithURL:linkURL range:linkRange];
            }
        }
    }
}

- (void)refreshLinkAttributes
{
    [self.tt_linkAttrStringDict.allKeys enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [obj rangeValue];
        [self tt_refreshLinkAttributesWithRange:range];
    }];
}

- (void)removeAllLinkAttributes
{
    [self.tt_linkAttrStringDict removeAllObjects];
}

#pragma mark - UIGestureRecognizerDelegate

// 避免阻断响应链
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self];
    [self tt_checkIslinkInTouchLocation:location];
    if (self.tt_isLinkInLocation) {
        [self tt_refreshLinkAttributesWithRange:self.tt_currentRange.rangeValue];
    }
    
    return self.tt_isLinkInLocation;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    /* 方案一：Tap手势需要依赖LongPress手势完成，如果LongPress成功，不走Tap；如果LongPress失败，走Tap
    优势：可以自定义LongPress的时长
    问题：如果LongPress未触发，不会有任何流程处理，这样无法做到在点击后更改Link Attributes，然后取消点击恢复
    解决方式：Swizzle touchesEnded，在shouldReceiveTouch里面更改Attributes，touchesEnded里面恢复 */
//    if (gestureRecognizer == self.tt_tapGestureRecognizer && otherGestureRecognizer == self.tt_longPressGestureRecognizer) {
//        return YES;
//    }
    
    /* 方案二：LongPress手势需要依赖Tap手势完成，把LongPress的等待时长设置为0（因为Tap自带了一个超时时间）
    优势：可以点击后更改Link Attributes且在Tap或者LongPress里面恢复
    问题：无法自定义LongPress时长，LongPress触发依赖Tap超时，但这个超时时间为UIKit内部控制 */
    if (gestureRecognizer == self.tt_longPressGestureRecognizer && otherGestureRecognizer == self.tt_tapGestureRecognizer) {
        return YES;
    }
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (!self.needSimultaneouslyScrollGesture) {
        return NO;
    }
    
    NSString *otherGesClsStr = NSStringFromClass(otherGestureRecognizer.class);
    if ([otherGesClsStr isEqualToString:@"UIScrollViewPanGestureRecognizer"] || [otherGesClsStr isEqualToString:@"UIScrollViewDelayedTouchesBeganGestureRecognizer"]) {
        return YES;
    }
    return NO;
}

- (void)didLabelTapped:(UIGestureRecognizer*)sender
{
    NSURL *linkURL = [self.tt_linkAttrStringDict objectForKey:self.tt_currentRange];
    if (self.tt_isLinkInLocation && self.labelTappingDelegate && [self.labelTappingDelegate respondsToSelector:@selector(label:didSelectLinkWithURL:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.labelTappingDelegate label:self didSelectLinkWithURL:linkURL];
        });
    }
    self.tt_isLinkInLocation = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self tt_refreshLinkAttributesWithRange:self.tt_currentRange.rangeValue];
    });
}

// 由于实现了UIGestureRecognizerDelegate预先判断了点击区域，这里Began一定为点击到Link区域内
- (void)didLabelLongPressed:(UIGestureRecognizer*)sender;
{
    switch (sender.state) {
    case UIGestureRecognizerStateBegan: {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tt_refreshLinkAttributesWithRange:self.tt_currentRange.rangeValue];
        });
    }
        break;
    case UIGestureRecognizerStateChanged: {
        CGPoint location = [sender locationInView:self];
        [self tt_checkIslinkInTouchLocation:location];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tt_refreshLinkAttributesWithRange:self.tt_currentRange.rangeValue];
        });
    }
        break;
    case UIGestureRecognizerStateEnded: {
        NSURL *linkURL = [self.tt_linkAttrStringDict objectForKey:self.tt_currentRange];
        if (self.tt_isLinkInLocation && self.labelTappingDelegate && [self.labelTappingDelegate respondsToSelector:@selector(label:didLongPressLinkWithURL:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.labelTappingDelegate label:self didLongPressLinkWithURL:linkURL];
            });
        }
        self.tt_isLinkInLocation = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tt_refreshLinkAttributesWithRange:self.tt_currentRange.rangeValue];
        });
    }
        break;
    case UIGestureRecognizerStateCancelled: // fall through
    case UIGestureRecognizerStateFailed: {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tt_isLinkInLocation = NO;
            [self tt_refreshLinkAttributesWithRange:self.tt_currentRange.rangeValue];
        });
    }
        break;
    default:
        break;
    }
}

#pragma mark - Helper

- (void)tt_checkIslinkInTouchLocation:(CGPoint)location;
{
    self.tt_isLinkInLocation = NO;
    CGSize labelSize = self.bounds.size;
    NSUInteger length = self.attributedText.length;
    CGFloat offsetXMultiply = 0;
    switch (self.textAlignment) {
        case NSTextAlignmentLeft: // fall through
        case NSTextAlignmentNatural:
        case NSTextAlignmentJustified:
            offsetXMultiply = 0;
            break;
        case NSTextAlignmentCenter:
            offsetXMultiply = 0.5;
            break;
        case NSTextAlignmentRight:
            offsetXMultiply = 1;
    }
    
    // configure textContainer for the label
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:labelSize];
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = self.lineBreakMode;
    textContainer.maximumNumberOfLines = self.numberOfLines;
    
    // check if there are NSParagraphStyle.linebreakMode not compatible, save NSParagraphStyle to temp dictionary
    NSMutableDictionary<NSValue *,NSParagraphStyle *> *attributes = [NSMutableDictionary dictionary];
    [textStorage enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[NSParagraphStyle class]]) {
            NSParagraphStyle *style = (NSParagraphStyle *)value;
            NSLineBreakMode linebreakMode = style.lineBreakMode;
//            NSAssert(linebreakMode == NSLineBreakByWordWrapping || linebreakMode == NSLineBreakByCharWrapping, @"NSParagraphStyle.linebreakMode must be WordWrapping or CharWrapping for TextKit");
            if (linebreakMode != NSLineBreakByWordWrapping && linebreakMode != NSLineBreakByCharWrapping) {
                NSValue *rangeValue = [NSValue valueWithRange:range];
                [attributes setObject:style forKey:rangeValue];
            }
        }
    }];
    
    if (attributes.count > 0) {
        // hack to change the linebreakMode
        [attributes enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull rangeValue, NSParagraphStyle * _Nonnull style, BOOL * _Nonnull stop) {
            NSRange range = rangeValue.rangeValue;
            NSMutableParagraphStyle *mutableStyle = [style mutableCopy];
            mutableStyle.lineBreakMode = NSLineBreakByWordWrapping;
            [textStorage addAttribute:NSParagraphStyleAttributeName value:[mutableStyle copy] range:range];
        }];
    }
    
    // configure layoutManager and textStorage
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    // ensure layout for text container
    [layoutManager ensureLayoutForTextContainer:textContainer];
    
    // find the tapped character location and compare it to the specified range
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * offsetXMultiply - textBoundingBox.origin.x, (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(location.x - textContainerOffset.x, location.y - textContainerOffset.y);
    
    NSInteger indexOfCharacter;
    // check if location is out of text container
    if (locationOfTouchInTextContainer.x < 0 || locationOfTouchInTextContainer.y < 0 || locationOfTouchInTextContainer.x > textContainer.size.width || locationOfTouchInTextContainer.y > textContainer.size.height) {
        indexOfCharacter = length;
    } else {
        indexOfCharacter = [layoutManager characterIndexForPoint: locationOfTouchInTextContainer inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    }
    
    // check if character is in target range
    [self.tt_linkAttrStringDict enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull targetRange, NSURL * _Nonnull URL, BOOL * _Nonnull stop) {
        if (NSLocationInRange(indexOfCharacter, targetRange.rangeValue)) {
            self.tt_currentRange = targetRange;
            self.tt_isLinkInLocation = YES;
            *stop = YES;
        }
    }];
}

- (void)tt_refreshLinkAttributesWithRange:(NSRange)range
{
    if (range.location == NSNotFound || NSMaxRange(range) == 0) {
        return;
    }
    NSDictionary *attributesToRemove = self.tt_isLinkInLocation ? self.labelInactiveLinkAttributes : self.labelActiveLinkAttributes;
    NSDictionary *attributesToAdd = self.tt_isLinkInLocation ? self.labelActiveLinkAttributes : self.labelInactiveLinkAttributes;
    
    NSMutableAttributedString *mutableAttributedString = [self.attributedText mutableCopy];
    [attributesToRemove enumerateKeysAndObjectsUsingBlock:^(NSString *name, __unused id value, __unused BOOL *stop) {
        if (NSMaxRange(range) <= mutableAttributedString.length) {
            [mutableAttributedString removeAttribute:name range:range];
        }
    }];
    
    if (attributesToAdd) {
        if (NSMaxRange(range) <= mutableAttributedString.length) {
            [mutableAttributedString addAttributes:attributesToAdd range:range];
        }
    }
    
    self.attributedText = mutableAttributedString;
    
    [self setNeedsDisplay];
}

@end

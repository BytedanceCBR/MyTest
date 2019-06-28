//
//  UITextView+TTUGCTapping.m
//  TTUGCFoundation
//
//  Created by SongChai on 2018/6/12.
//

#import "UITextView+TTUGCTapping.h"
#import <objc/runtime.h>

@interface _TTTextViewTapLink : NSObject
@property (nonatomic, copy) TTTextViewTapBlock tapBlock;
@property (nonatomic, strong) NSURL *linkURL;
@end

@implementation _TTTextViewTapLink
@end

@interface _TTTextViewGestureRecognizerDelegateObject : NSObject<UIGestureRecognizerDelegate>
@property (nonatomic, weak) UITextView *ttTextView;
- (instancetype)initWithTextView:(UITextView *)textView;
- (void)didTextViewTapped:(UIGestureRecognizer*)sender;
@end


@interface UITextView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tt_tapGestureRecognizer;
@property (nonatomic, strong) NSMutableDictionary<NSValue *,_TTTextViewTapLink *> *tt_linkAttrStringDict;
@property (nonatomic, strong) NSDataDetector *tt_dataDetector;
@property (nonatomic, strong) NSValue *tt_currentRange;
@property (nonatomic, assign) BOOL tt_isLinkInLocation;

@property (nonatomic, strong) _TTTextViewGestureRecognizerDelegateObject *tt_GestureRecognizerDelegateObject;
@end

@implementation UITextView (TTUGCTapping)

- (UITapGestureRecognizer *)tt_tapGestureRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = objc_getAssociatedObject(self, @selector(tt_tapGestureRecognizer));
    if (!tapGestureRecognizer) {
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.tt_GestureRecognizerDelegateObject action:@selector(didTextViewTapped:)];
        [self setTt_tapGestureRecognizer:tapGestureRecognizer];
    }
    
    return tapGestureRecognizer;
}

- (void)setTt_tapGestureRecognizer:(UITapGestureRecognizer *)tt_tapGestureRecognizer {
    objc_setAssociatedObject(self, @selector(tt_tapGestureRecognizer), tt_tapGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSMutableDictionary<NSValue *,_TTTextViewTapLink *> *)tt_linkAttrStringDict {
    NSMutableDictionary *linkAttrStringDict = objc_getAssociatedObject(self, @selector(tt_linkAttrStringDict));
    if (!linkAttrStringDict) {
        linkAttrStringDict = [NSMutableDictionary dictionaryWithCapacity:1];
        [self setTt_linkAttrStringDict:linkAttrStringDict];
    }
    
    return linkAttrStringDict;
}

- (void)setTt_linkAttrStringDict:(NSMutableDictionary<NSValue *,_TTTextViewTapLink *> *)tt_linkAttrStringDict {
    objc_setAssociatedObject(self, @selector(tt_linkAttrStringDict), tt_linkAttrStringDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDataDetector *)tt_dataDetector {
    NSDataDetector *tt_dataDetector = objc_getAssociatedObject(self, @selector(tt_dataDetector));
    if (!tt_dataDetector) {
        tt_dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        [self setTt_dataDetector:tt_dataDetector];
    }
    
    return tt_dataDetector;
}

- (void)setTt_dataDetector:(NSDataDetector *)tt_dataDetector {
    objc_setAssociatedObject(self, @selector(tt_dataDetector), tt_dataDetector, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSValue *)tt_currentRange {
    return objc_getAssociatedObject(self, @selector(tt_currentRange));
}

- (void)setTt_currentRange:(NSValue *)tt_currentRange {
    objc_setAssociatedObject(self, @selector(tt_currentRange), tt_currentRange, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tt_isLinkInLocation {
    NSNumber *value = objc_getAssociatedObject(self, @selector(tt_isLinkInLocation));
    return [value boolValue];
}

- (void)setTt_isLinkInLocation:(BOOL)tt_isLinkInLocation {
    objc_setAssociatedObject(self, @selector(tt_isLinkInLocation), @(tt_isLinkInLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary<NSString *,id> *)textViewLinkAttributes {
    return objc_getAssociatedObject(self, @selector(textViewLinkAttributes));
}

- (void)setTextViewLinkAttributes:(NSDictionary<NSString *,id> *)textViewLinkAttributes {
    objc_setAssociatedObject(self, @selector(textViewLinkAttributes), textViewLinkAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary<NSString *,id> *)textViewActiveLinkAttributes {
    return objc_getAssociatedObject(self, @selector(textViewActiveLinkAttributes));
}

- (void)setTextViewActiveLinkAttributes:(NSDictionary<NSString *,id> *)textViewActiveLinkAttributes {
    objc_setAssociatedObject(self, @selector(textViewActiveLinkAttributes), textViewActiveLinkAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self refreshLinkAttributes];
}

- (NSDictionary<NSString *,id> *)textViewInactiveLinkAttributes {
    return objc_getAssociatedObject(self, @selector(textViewInactiveLinkAttributes));
}

- (void)setTextViewInactiveLinkAttributes:(NSDictionary<NSString *,id> *)textViewInactiveLinkAttributes {
    objc_setAssociatedObject(self, @selector(textViewInactiveLinkAttributes), textViewInactiveLinkAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self refreshLinkAttributes];
}

- (id<TTTextViewTappingDelegate>)textViewTappingDelegate {
    return objc_getAssociatedObject(self, @selector(textViewTappingDelegate));
}

- (void)setNeedSimultaneouslyScrollGesture:(BOOL)needSimultaneouslyScrollGesture {
    objc_setAssociatedObject(self, @selector(needSimultaneouslyScrollGesture), @(needSimultaneouslyScrollGesture), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)needSimultaneouslyScrollGesture {
    NSNumber *value = objc_getAssociatedObject(self, @selector(needSimultaneouslyScrollGesture));
    return [value boolValue];
}

- (void)setTextViewTappingDelegate:(id<TTTextViewTappingDelegate>)textViewTappingDelegate {
    if (textViewTappingDelegate) {
        self.userInteractionEnabled = YES;
        self.tt_tapGestureRecognizer.delegate = self.tt_GestureRecognizerDelegateObject;
        [self addGestureRecognizer:self.tt_tapGestureRecognizer];
    } else {
        self.userInteractionEnabled = NO;
        self.tt_tapGestureRecognizer.delegate = nil;
        [self removeGestureRecognizer:self.tt_tapGestureRecognizer];
    }
    objc_setAssociatedObject(self, @selector(textViewTappingDelegate), textViewTappingDelegate, OBJC_ASSOCIATION_ASSIGN);
}


- (_TTTextViewGestureRecognizerDelegateObject *)tt_GestureRecognizerDelegateObject {
    _TTTextViewGestureRecognizerDelegateObject *obj = objc_getAssociatedObject(self, @selector(tt_GestureRecognizerDelegateObject));
    if (obj == nil) {
        obj = [[_TTTextViewGestureRecognizerDelegateObject alloc] initWithTextView:self];
        objc_setAssociatedObject(self, @selector(tt_GestureRecognizerDelegateObject), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obj;
}

- (void)setTt_GestureRecognizerDelegateObject:(_TTTextViewGestureRecognizerDelegateObject *)tt_GestureRecognizerDelegateObject {
    objc_setAssociatedObject(self, @selector(tt_GestureRecognizerDelegateObject), tt_GestureRecognizerDelegateObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Public API
- (void)addLink:(NSURL *)URL range:(NSRange)range tapBlock:(TTTextViewTapBlock)tapBlock {
    if (!URL) return;
    NSValue *targetRange = [NSValue valueWithRange:range];
    if (!targetRange) {
        return;
    }
    
    NSMutableAttributedString *mutableAttrString = [self.attributedText mutableCopy];
    [mutableAttrString addAttributes:self.textViewInactiveLinkAttributes range:range];
    self.attributedText = mutableAttrString;
    
    _TTTextViewTapLink *link = [[_TTTextViewTapLink alloc] init];
    link.linkURL = URL;
    link.tapBlock = tapBlock;
    
    [self.tt_linkAttrStringDict setObject:link forKey:targetRange];
}

- (void)detectAndAddLink {
    NSString *attrString = self.attributedText.string;
    if (attrString.length == 0) {
        return;
    }
    
    NSArray *matches = [self.tt_dataDetector matchesInString:attrString options:0 range:NSMakeRange(0, attrString.length)];
    if (matches.count > 0) {
        for (NSTextCheckingResult *result in matches) {
            NSRange linkRange = result.range;
            NSURL *linkURL = result.URL;
            if (NSMaxRange(linkRange) <= attrString.length) {
                [self addLink:linkURL range:linkRange tapBlock:nil];
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

#pragma mark - Helper

- (void)tt_checkIslinkInTouchLocation:(CGPoint)location {
    self.tt_isLinkInLocation = NO;
    
    CGPoint locationOfTouchInTextContainer = location;
    
    locationOfTouchInTextContainer.x -= self.textContainerInset.left;
    locationOfTouchInTextContainer.y -= self.textContainerInset.top;
    
    NSInteger indexOfCharacter;
    CGFloat fraction = 1.0;
    // check if location is out of text container
    if (locationOfTouchInTextContainer.x < 0 || locationOfTouchInTextContainer.y < 0 || locationOfTouchInTextContainer.x > self.textContainer.size.width || locationOfTouchInTextContainer.y > self.textContainer.size.height) {
        indexOfCharacter = self.attributedText.length;
    } else {
        indexOfCharacter = [self.layoutManager characterIndexForPoint:locationOfTouchInTextContainer inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:&fraction];
    }
    if (fraction < 1) {
        // check if character is in target range
        [self.tt_linkAttrStringDict enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull targetRange, _TTTextViewTapLink * _Nonnull link, BOOL * _Nonnull stop) {
            if (NSLocationInRange(indexOfCharacter, targetRange.rangeValue)) {
                self.tt_currentRange = targetRange;
                self.tt_isLinkInLocation = YES;
                *stop = YES;
            }
        }];
    }
}

- (void)tt_refreshLinkAttributesWithRange:(NSRange)range {
    if (range.location == NSNotFound || NSMaxRange(range) == 0) {
        return;
    }
    NSDictionary *attributesToRemove = self.tt_isLinkInLocation ? self.textViewInactiveLinkAttributes : self.textViewActiveLinkAttributes;
    NSDictionary *attributesToAdd = self.tt_isLinkInLocation ? self.textViewActiveLinkAttributes : self.textViewInactiveLinkAttributes;
    
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


@implementation _TTTextViewGestureRecognizerDelegateObject

- (instancetype)initWithTextView:(UITextView *)textView {
    if (self = [super init]) {
        self.ttTextView = textView;
    }
    return self;
}

#pragma mark - UIGestureRecognizerDelegate

// 避免阻断响应链
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:self.ttTextView];
    [self.ttTextView tt_checkIslinkInTouchLocation:location];
    if (self.ttTextView.tt_isLinkInLocation) {
        [self.ttTextView tt_refreshLinkAttributesWithRange:self.ttTextView.tt_currentRange.rangeValue];
    }
    
    return self.ttTextView.tt_isLinkInLocation;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (!self.ttTextView.needSimultaneouslyScrollGesture) {
        return NO;
    }
    
    NSString *otherGesClsStr = NSStringFromClass(otherGestureRecognizer.class);
    if ([otherGesClsStr isEqualToString:@"UIScrollViewPanGestureRecognizer"] || [otherGesClsStr isEqualToString:@"UIScrollViewDelayedTouchesBeganGestureRecognizer"]) {
        return YES;
    }
    return NO;
}

- (void)didTextViewTapped:(UIGestureRecognizer*)sender {
    _TTTextViewTapLink *link = [self.ttTextView.tt_linkAttrStringDict objectForKey:self.ttTextView.tt_currentRange];
    if (self.ttTextView.tt_isLinkInLocation) {
        if (link.tapBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                link.tapBlock([self.ttTextView.tt_currentRange rangeValue]);
            });
        } else if (self.ttTextView.textViewTappingDelegate && [self.ttTextView.textViewTappingDelegate respondsToSelector:@selector(textView:didSelectLinkWithURL:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.ttTextView.textViewTappingDelegate textView:self.ttTextView didSelectLinkWithURL:link.linkURL];
            });
        }
    }
    self.ttTextView.tt_isLinkInLocation = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.ttTextView tt_refreshLinkAttributesWithRange:self.ttTextView.tt_currentRange.rangeValue];
    });
}

@end

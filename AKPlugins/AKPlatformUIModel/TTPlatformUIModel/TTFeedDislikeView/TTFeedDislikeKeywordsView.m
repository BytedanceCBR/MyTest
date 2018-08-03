//
//  ExploreDislikeKeywordsView.m
//  Article
//
//  Created by Chen Hong on 14/11/19.
//
//

#import "TTFeedDislikeKeywordsView.h"

#import "TTFeedDislikeTag.h"
#import "TTFeedDislikeWord.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"
#import "TTBaseMacro.h"
#import "TTFeedDislikeView.h"

#pragma mark - TTFeedDislikeKeywordsView

@interface TTFeedDislikeKeywordsView ()

@property(nonatomic,strong)NSMutableArray *tags;
@property(nonatomic,strong)NSMutableArray *tagButtonArray;

@end

@implementation TTFeedDislikeKeywordsView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tagButtonArray = [NSMutableArray array];
    }
    return self;
}

- (void)refreshWithData:(NSArray *)keywords {
    for (UIView *tag in self.tags) {
        [tag removeFromSuperview];
    }
    
    if (keywords.count == 0) {
        self.height = 0;
        return;
    }
    
    CGFloat x = [self leftPadding], y = 0;
    CGFloat tagWidth = (self.width - [self leftPadding] * 2 - [self paddingX]) / 2;
    
    for (TTFeedDislikeWord *word in keywords) {
        NSString *str = word.name;
        if (!isEmptyString(str)) {
            TTFeedDislikeTag *tag;
            tag = [[TTFeedDislikeTag alloc] initWithFrame:CGRectMake(x, y, tagWidth, [self tagHeight])];
            tag.backgroundColor = [UIColor clearColor];
            [self.tagButtonArray addObject:tag];
            
            tag.dislikeWord = word;
            [self addSubview:tag];
            [tag addTarget:self action:@selector(toggleSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            x += tagWidth + [self paddingX];
            if (x + tagWidth > self.width) { // Not precise
                x = [self leftPadding];
                y += [self tagHeight] + [self paddingY];
            }
        }
    }
    
    self.height = ((TTFeedDislikeTag *)[self.tagButtonArray lastObject]).bottom;
}

- (void)toggleSelected:(id)sender {
    TTFeedDislikeTag *tag = (TTFeedDislikeTag *)sender;
    tag.selected = !tag.selected;
    tag.dislikeWord.isSelected = tag.isSelected;
    
    if (_delegate && [_delegate respondsToSelector:@selector(dislikeKeywordsSelectionChanged)]) {
        [_delegate dislikeKeywordsSelectionChanged];
    }
}

- (NSArray *)selectedKeywords {
    NSMutableArray *array = [NSMutableArray array];
    for (TTFeedDislikeTag *tag in self.tagButtonArray) {
        if (tag.isSelected) {
            [array addObject:tag.titleLabel.text];
        }
    }
    return array;
}

- (BOOL)hasKeywordSelected {
    for (TTFeedDislikeTag *tag in self.tagButtonArray) {
        if (tag.dislikeWord.isSelected) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - size & padding

- (CGFloat)leftPadding {
    static CGFloat padding = 0;
    if (padding == 0) {
        if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
            if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
                padding = 20.f;
            } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
                padding = 20.f;
            } else {
                padding = 14.f;
            }
        }
        else {
            if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
                padding = 14.f;
            } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
                padding = 14.f;
            } else {
                padding = 12.f;
            }
        }
        
    }
    return padding;
}

- (CGFloat)paddingY {
    static CGFloat padding = 0;
    if (padding == 0) {
        if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
            if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
                padding = 10.f;
            } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
                padding = 10.f;
            } else {
                padding = 8.f;
            }
        }
        else {
            if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
                padding = 8.f;
            } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
                padding = 8.f;
            } else {
                padding = 6.f;
            }
        }
    }
    return padding;
}

- (CGFloat)paddingX {
    static CGFloat padding = 0;
    if (padding == 0) {
        if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
            if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
                padding = 14.f;
            } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
                padding = 14.f;
            } else {
                padding = 8.f;
            }
        }
        else {
            if (padding == 0) {
                if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
                    padding = 8.f;
                } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
                    padding = 8.f;
                } else {
                    padding = 6.f;
                }
            }
        }
    }
    return padding;
}

- (CGFloat)tagHeight {
    static CGFloat h = 0;
    if (h == 0) {
        if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
            if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
                h = 40.f;
            } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
                h = 40.f;
            } else {
                h = 38.f;
            }
        }
        else {
            if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
                h = 32.f;
            } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
                h = 32.f;
            } else {
                h = 30.f;
            }
        }
    }
    return h;
}


@end

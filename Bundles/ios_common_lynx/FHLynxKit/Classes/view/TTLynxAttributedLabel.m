//
//  TTLynxAttributedLabel.m
//  TTLynxAdapter
//
//  Created by ranny_90 on 2020/5/13.
//

#import "TTLynxAttributedLabel.h"

@implementation TTLynxAttributedLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];

    }
    return self;
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.activeLink = [self linkAtPoint:[gesture locationInView:self]];
        if (!self.activeLink) {

        }

    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (self.activeLink) {
            if (self.activeLink != [self linkAtPoint:[gesture locationInView:self]]) {
                self.activeLink = nil;
            }
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.activeLink) {
            if (self.activeLink.linkTapBlock) {
                self.activeLink.linkTapBlock(self, self.activeLink);
                self.activeLink = nil;
                return;
            }

            NSTextCheckingResult *result = self.activeLink.result;
            self.activeLink = nil;

            switch (result.resultType) {
                case NSTextCheckingTypeLink:
                    if ([self.delegate respondsToSelector:@selector(attributedLabel:didSelectLinkWithURL:)]) {
                        [self.delegate attributedLabel:self didSelectLinkWithURL:result.URL];
                        return;
                    }
                    break;
                default:
                    break;
            }

            // Fallback to `attributedLabel:didSelectLinkWithTextCheckingResult:` if no other delegate method matched.
            if ([self.delegate respondsToSelector:@selector(attributedLabel:didSelectLinkWithTextCheckingResult:)]) {
                [self.delegate attributedLabel:self didSelectLinkWithTextCheckingResult:result];
            }
        }

    } else if (gesture.state == UIGestureRecognizerStateCancelled || UIGestureRecognizerStateFailed) {
        if (self.activeLink) {
            self.activeLink = nil;
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    self.activeLink = [self linkAtPoint:[gestureRecognizer locationInView:self]];
    if (!self.activeLink) {
        return NO;
    }
    return YES;
}

@end

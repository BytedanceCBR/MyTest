//
//  TTThreadRateView.m
//  Article
//
//  Created by 王霖 on 4/27/16.
//
//

#import "TTThreadRateView.h"

static const CGFloat kStarWidth = 12.0;
static const CGFloat kStarPadding = 3.0;

typedef NS_ENUM(NSUInteger, _TTThreadRateStarState) {
    _TTThreadRateStarStateEmpty,
    _TTThreadRateStarStateHalf,
    _TTThreadRateStarStateFull
};

#pragma mark - _TTThreadRateStar

@interface _TTThreadRateStar : SSThemedImageView

@property(nonatomic, assign) _TTThreadRateStarState state;

@end

@implementation _TTThreadRateStar

- (void)setState:(_TTThreadRateStarState)state {
    _state = state;
    switch (_state) {
        case _TTThreadRateStarStateEmpty:
            self.imageName = @"film_star_edge";
            break;
        case _TTThreadRateStarStateHalf:
            self.imageName = @"film_star_half";
            break;
        case _TTThreadRateStarStateFull:
            self.imageName = @"film_stars";
        default:
            break;
    }
}

@end

#pragma mark - TTThreadRateView

@interface TTThreadRateView ()

@property (nonatomic, strong) NSArray <_TTThreadRateStar *> * rateStars;

@end

@implementation TTThreadRateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (void)createComponent {
    NSMutableArray <_TTThreadRateStar *> * stars = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i<5; i++) {
        _TTThreadRateStar * star = [[_TTThreadRateStar alloc] init];
        star.state = _TTThreadRateStarStateEmpty;
        star.translatesAutoresizingMaskIntoConstraints = NO;
        [stars addObject:star];
        CGFloat sign = abs(i-2) == i-2? 1 : -1;
        CGFloat offsetX = abs(i-2)*(kStarWidth + kStarPadding);
        [self addSubview:star];
        NSLayoutConstraint * centerY = [NSLayoutConstraint constraintWithItem:star attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint * centerX = [NSLayoutConstraint constraintWithItem:star attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:sign*offsetX];
        [self addConstraints:@[centerY, centerX]];
    }
    self.rateStars = stars.copy;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(5*kStarWidth + 4*kStarPadding, kStarWidth);
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(5*kStarWidth + 4*kStarPadding, kStarWidth);
}

- (void)setRate:(CGFloat)rate {
    if (rate < 0) {
        rate = 0;
    }else if (rate > 10) {
        rate = 10;
    }
    _rate = rate;
    NSUInteger numberOfFullStar = rate/2;
    [self.rateStars enumerateObjectsUsingBlock:^(_TTThreadRateStar * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx + 1 <= numberOfFullStar) {
            obj.state = _TTThreadRateStarStateFull;
        }else if ((idx + 1 == numberOfFullStar + 1) && numberOfFullStar < rate/2) {
            obj.state = _TTThreadRateStarStateHalf;
        }else {
            obj.state = _TTThreadRateStarStateEmpty;
        }
    }];
}

@end

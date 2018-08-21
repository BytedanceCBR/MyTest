//
//  TTRateMovieView.m
//  Article
//
//  Created by 王霖 on 4/27/16.
//
//

#import "TTRateMovieView.h"

static const CGFloat kStarWidth = 28.0;
static const CGFloat kStarPadding = 8.0;
static const CGFloat kStarTopPadding = 24.0;
static const CGFloat kDescribeLabelTopPadding = 16.0;
static const CGFloat kIntegerLabelLeftPadding = 16.0;

#pragma mark - TTRateStar

typedef NS_ENUM(NSUInteger, TTRateStarState) {
    TTRateStarStateEmpty,
    TTRateStarStateHalf,
    TTRateStarStateFull
};

@interface TTRateStar : SSThemedImageView

@property(nonatomic, assign) TTRateStarState state;

@end

@implementation TTRateStar

- (void)setState:(TTRateStarState)state {
    _state = state;
    switch (_state) {
        case TTRateStarStateEmpty:
            self.imageName = @"b_film_star_edge";
            break;
        case TTRateStarStateHalf:
            self.imageName = @"b_film_star_half";
            break;
        case TTRateStarStateFull:
            self.imageName = @"b_film_stars";
        default:
            break;
    }
}

@end

#pragma mark - TTRateMovieView

@interface TTRateMovieView ()<UIGestureRecognizerDelegate>

@property(nonatomic, strong) NSArray <TTRateStar *> * rateStars;
@property(nonatomic, strong) SSThemedLabel * rateIntegerLabel;
@property(nonatomic, strong) SSThemedLabel * rateDecimalLabel;
@property(nonatomic, strong) SSThemedLabel * describeLabel;

@end

@implementation TTRateMovieView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
        [self createGesture];
        self.rate = 0;
    }
    return self;
}

- (void)createComponent {
    NSMutableArray <TTRateStar *> * stars = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i<5; i++) {
        TTRateStar * star = [[TTRateStar alloc] init];
        star.state = TTRateStarStateEmpty;
        star.translatesAutoresizingMaskIntoConstraints = NO;
        [stars addObject:star];
        CGFloat sign = abs(i-2) == i-2? 1 : -1;
        CGFloat offsetX = abs(i-2)*(kStarWidth + kStarPadding);
        [self addSubview:star];
        NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:star attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:kStarTopPadding];
        NSLayoutConstraint * centerX = [NSLayoutConstraint constraintWithItem:star attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:sign*offsetX];
        [self addConstraints:@[top, centerX]];
    }
    self.rateStars = stars.copy;
    
    [self addSubview:self.describeLabel];
    NSLayoutConstraint * describeLabelTop = [NSLayoutConstraint constraintWithItem:self.describeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:kStarTopPadding + kStarWidth + kDescribeLabelTopPadding];
    NSLayoutConstraint * describeLabelCenterX = [NSLayoutConstraint constraintWithItem:self.describeLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self addConstraints:@[describeLabelTop, describeLabelCenterX]];
    
    [self addSubview:self.rateIntegerLabel];
    NSLayoutConstraint * rateIntegerLabelTop = [NSLayoutConstraint constraintWithItem:self.rateIntegerLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:kStarTopPadding];
    NSLayoutConstraint * rateIntegerLabelLeft = [NSLayoutConstraint constraintWithItem:self.rateIntegerLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:kIntegerLabelLeftPadding + 2.5*kStarWidth + 2*kStarPadding];
    [self addConstraints:@[rateIntegerLabelTop, rateIntegerLabelLeft]];
    
    [self addSubview:self.rateDecimalLabel];
    NSLayoutConstraint * rateDecimalLabelTop = [NSLayoutConstraint constraintWithItem:self.rateDecimalLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:kStarTopPadding];
    NSLayoutConstraint * rateDecimalLabelLeft = [NSLayoutConstraint constraintWithItem:self.rateDecimalLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.rateIntegerLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self addConstraints:@[rateDecimalLabelTop, rateDecimalLabelLeft]];
}

- (SSThemedLabel *)rateIntegerLabel {
    if (_rateIntegerLabel == nil) {
        _rateIntegerLabel = [[SSThemedLabel alloc] init];
        _rateIntegerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _rateIntegerLabel.font = [UIFont systemFontOfSize:24];
        _rateIntegerLabel.textColors = SSThemedColors(@"ffc345", @"927435");
        NSLayoutConstraint * height = [NSLayoutConstraint constraintWithItem:_rateIntegerLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:24];
        [_rateIntegerLabel addConstraint:height];
    }
    return _rateIntegerLabel;
}

- (SSThemedLabel *)rateDecimalLabel {
    if (_rateDecimalLabel == nil) {
        _rateDecimalLabel = [[SSThemedLabel alloc] init];
        _rateDecimalLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _rateDecimalLabel.font = [UIFont systemFontOfSize:14];
        _rateDecimalLabel.textColors = SSThemedColors(@"ffc345", @"927435");
        _rateDecimalLabel.text = @".0";
    }
    return _rateDecimalLabel;
}

- (SSThemedLabel *)describeLabel {
    if (_describeLabel == nil) {
        _describeLabel = [[SSThemedLabel alloc] init];
        _describeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _describeLabel.textColorThemeKey = kColorText3;
        _describeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _describeLabel;
}

- (void)createGesture {
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
}

- (void)pan:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGFloat locationX = [panGestureRecognizer locationInView:self].x;
    [self currentLocationX:locationX];
}

- (void)tap:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGFloat locationX = [tapGestureRecognizer locationInView:self].x;
    [self currentLocationX:locationX];
}

- (void)currentLocationX:(CGFloat)locationX {
    CGFloat centerX = self.bounds.size.width / 2;
    CGFloat offsetX = (locationX - centerX)/(kStarWidth/2 + kStarPadding/2);
    CGFloat rate = 0;
    if (offsetX >=0) {
        offsetX = ceil(offsetX);
        rate = offsetX + 5;
        if (rate > 10) {
            rate = 10;
        }
    }else {
        offsetX = floor(fabs(offsetX));
        rate = 5 - offsetX;
        if (rate < 0) {
            rate = 0;
        }
    }
    self.rate = rate;
}

- (void)setRate:(CGFloat)rate {
    if (rate < 0) {
        rate = 0;
    }else if (rate > 10) {
        rate = 10;
    }
    _rate = rate;
    NSUInteger numberOfFullStar = rate/2;
    [self.rateStars enumerateObjectsUsingBlock:^(TTRateStar * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx + 1 <= numberOfFullStar) {
            obj.state = TTRateStarStateFull;
        }else if ((idx + 1 == numberOfFullStar + 1) && numberOfFullStar < rate/2) {
            obj.state = TTRateStarStateHalf;
        }else {
            obj.state = TTRateStarStateEmpty;
        }
    }];
    if (rate <= 0) {
        self.describeLabel.text = NSLocalizedString(@"请评分", nil);
    }else if (rate <= 2) {
        self.describeLabel.text = NSLocalizedString(@"糟透了，彻彻底底的烂片", nil);
    }else if (rate <= 4) {
        self.describeLabel.text = NSLocalizedString(@"比较差，低于预期水准", nil);
    }else if (rate <= 6) {
        self.describeLabel.text = NSLocalizedString(@"一般般，勉强说得过去", nil);
    }else if (rate <= 8) {
        self.describeLabel.text = NSLocalizedString(@"很好看，强烈推荐", nil);
    }else if (rate <= 9) {
        self.describeLabel.text = NSLocalizedString(@"棒极了，绝对不容错过", nil);
    }else {
        self.describeLabel.text = NSLocalizedString(@"非常完美，肯定可以", nil);
    }
    self.rateIntegerLabel.text = [NSString stringWithFormat:@"%d",(int)rate];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

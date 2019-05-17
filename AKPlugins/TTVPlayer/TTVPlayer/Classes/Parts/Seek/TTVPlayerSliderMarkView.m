//
//  TTVPlayerSliderMarkView.m
//  Article
//
//  Created by liufeng on 2017/8/22.
//
//

#import "TTVPlayerSliderMarkView.h"

@interface TTVPlayerSliderPointView : UIView

@property (nonatomic, assign) CGFloat point;

@end

@implementation TTVPlayerSliderPointView

@end

@interface TTVPlayerSliderMarkView ()

@property (nonatomic, strong) NSMutableArray <TTVPlayerSliderPointView *>*pointViews;
@property (nonatomic, strong) NSMutableArray <TTVPlayerSliderPointView *>*openingPointViews;

@end

@implementation TTVPlayerSliderMarkView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _pointViews = [NSMutableArray array];
        _openingPointViews = [NSMutableArray array];
    }
    return self;
}

- (void)setMarkPoints:(NSArray<NSNumber *> *)markPoints
{
    _markPoints = markPoints;
    
    [self _buildPointViews];
}

- (void)setOpeningPoints:(NSArray<NSNumber *> *)openingPoints
{
    _openingPoints = openingPoints;
    [self _buildOpeningPointViews];
}

- (void)updateMarkColorWithProgress:(CGFloat)progress
{
    NSInteger pointsCount = _markPoints.count;
    NSInteger pointViewsCount = _pointViews.count;
    if (pointsCount == pointViewsCount) {
        for (int i = 0; i < pointsCount; i++) {
            UIView *pointView = _pointViews[i];
            if (_markPoints[i].floatValue >= progress) {
                pointView.backgroundColor = [UIColor redColor];
            } else {
                pointView.backgroundColor = [UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f];
            }
        }
    }
}

- (void)_buildOpeningPointViews
{
    [_openingPointViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_openingPointViews removeAllObjects];
    
    for (NSNumber *point in _openingPoints) {
        TTVPlayerSliderPointView *pointView = [[TTVPlayerSliderPointView alloc] init];
        pointView.backgroundColor = [UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f];;
        pointView.point = point.floatValue;
        [self addSubview:pointView];
        [_openingPointViews addObject:pointView];
    }
}

- (void)_buildPointViews
{
    [_pointViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_pointViews removeAllObjects];
    
    for (NSNumber *point in _markPoints) {
        TTVPlayerSliderPointView *pointView = [[TTVPlayerSliderPointView alloc] init];
        pointView.backgroundColor = [UIColor yellowColor];
        pointView.point = point.floatValue;
        [self addSubview:pointView];
        [_pointViews addObject:pointView];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (TTVPlayerSliderPointView *view in _pointViews) {
        view.frame = CGRectMake(view.point * self.width, 0, self.height * 2, self.height);
        view.layer.cornerRadius = self.height / 2.f;
    }
    for (TTVPlayerSliderPointView *view in _openingPointViews) {
        view.frame = CGRectMake(view.point * self.width, 0, self.height * 2, self.height);
        view.layer.cornerRadius = self.height / 2.f;
    }
}

@end

//
//  TTMovieResolutionSelectView.m
//  Article
//
//  Created by xiangwu on 2016/12/2.
//
//

#import "TTMovieResolutionSelectView.h"
#import "TTAlphaThemedButton.h"
#import "TTVideoDefinationTracker.h"

static const CGFloat kBtnW = 80;
static const CGFloat kBtnH = 24;
static const CGFloat kBottomH = 7;
static const CGFloat kPadding = 12;
static const CGFloat kTotalW = 80;

@interface TTMovieResolutionSelectView ()

@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) CAShapeLayer *backLayer;

@end

@implementation TTMovieResolutionSelectView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        _btnArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = [self viewSize];
    _backLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [_btnArray enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.top = (idx + 1) * kPadding + idx * obj.height;
        obj.centerX = self.width / 2;
    }];
}

- (void)setSupportTypes:(NSArray *)types currentType:(ExploreVideoDefinitionType)currentType {
    for (UIButton *btn in _btnArray) {
        [btn removeFromSuperview];
    }
    [_btnArray removeAllObjects];
    [_backLayer removeFromSuperlayer];
    _backLayer = [CAShapeLayer layer];
    CGSize size = [self viewSize];
    _backLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [self.layer addSublayer:_backLayer];
    [types enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSNumber *type, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAlphaThemedButton *btn = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, kBtnW, kBtnH)];
        btn.tag = [type integerValue];
        btn.backgroundColor = [UIColor clearColor];
        NSString *title = [TTMovieResolutionSelectView typeStringForType:[type integerValue]];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        NSString *btnColorStr = currentType == [type integerValue] ? kColorText4 : kColorText12;
        [btn setTitleColor:[UIColor tt_defaultColorForKey:btnColorStr] forState:UIControlStateNormal];
        CGFloat top = (idx == 0 ? kPadding : kPadding / 2);
        CGFloat bottom = (idx == types.count -1 ? kPadding : kPadding / 2);
        CGFloat left = 0;
        CGFloat right = left;
        
        btn.hitTestEdgeInsets = UIEdgeInsetsMake(-top, -left, -bottom, -right);
        [btn addTarget:self action:@selector(p_btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_btnArray addObject:btn];
        [self addSubview:btn];
    }];
    _backLayer.path = [self backLayerPath].CGPath;
}

- (void)p_btnClicked:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectWithType:)]) {
        [_delegate didSelectWithType:sender.tag];
        [TTVideoDefinationTracker sharedTTVideoDefinationTracker].lastDefination = sender.tag;
    }
}

+ (NSString *)typeStringForType:(ExploreVideoDefinitionType)type {
    if (type < [self typeStrings].count) {
        return [self typeStrings][type];
    }
    return [[self typeStrings] firstObject];
}

+ (NSArray *)typeStrings {
    return @[@"标清", @"高清", @"超清"];
}

- (CGSize)viewSize {
    if (!_btnArray.count) {
        return CGSizeMake(kTotalW, 0);
    }
    CGFloat height = kBtnH * _btnArray.count + kPadding * (_btnArray.count + 1) + kBottomH;
    return CGSizeMake(kTotalW, height);
}

- (UIBezierPath *)backLayerPath {
    if (!_btnArray.count) {
        return nil;
    }
    CGSize size = [self viewSize];
    UIColor *color = [UIColor tt_defaultColorForKey:kColorBackground11];
    [color setFill];
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height - 6.5) cornerRadius:6.5];
    [path1 fill];
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(size.width / 2 - 7, size.height - 6.5)];
    [path2 addLineToPoint:CGPointMake(size.width / 2 + 7, size.height - 6.5)];
    [path2 addLineToPoint:CGPointMake(size.width / 2, size.height)];
    [path2 closePath];
    [path2 fill];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path appendPath:path1];
    [path appendPath:path2];
    return path;
}

@end

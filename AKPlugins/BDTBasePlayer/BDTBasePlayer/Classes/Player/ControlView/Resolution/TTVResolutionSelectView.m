//
//  TTVResolutionSelectView.m
//  Article
//
//  Created by panxiang on 2017/5/24.
//
//

#import "TTVResolutionSelectView.h"
#import "TTVResolutionStore.h"
#import "TTVPlayerStateModel.h"

static const CGFloat kBtnW = 80;
static const CGFloat kBtnH = 24;
static const CGFloat kBottomH = 7;
static const CGFloat kPadding = 12;
static const CGFloat kTotalW = 80;

@interface TTVResolutionSelectView ()

@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) CAShapeLayer *backLayer;

@end

@implementation TTVResolutionSelectView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        _btnArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        _playerStateStore = playerStateStore;
        [self ttv_kvo];
    }
}

- (void)ttv_kvo
{

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

- (void)setSupportTypes:(NSArray *)types{
    
    if (self.playerStateStore.state.resolutionState == TTVResolutionStateChanging) {
        return;
    }
    for (UIButton *btn in _btnArray) {
        [btn removeFromSuperview];
    }
    [_btnArray removeAllObjects];
    [_backLayer removeFromSuperlayer];
    _backLayer = [CAShapeLayer layer];
    CGSize size = [self viewSize];
    _backLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [self.layer addSublayer:_backLayer];
    NSMutableArray *typesCopy = [types mutableCopy];
    [typesCopy addObject:@(TTVPlayerResolutionTypeAuto)];
    [typesCopy enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSNumber *type, NSUInteger idx, BOOL * _Nonnull stop) {
        SSThemedButton *btn = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, kBtnW, kBtnH)];
        btn.tag = [type integerValue];
        btn.backgroundColor = [UIColor clearColor];
        NSString *title = @"";
        NSString *btnColorStr = nil;

        if ([[TTVResolutionStore sharedInstance] forceSelected] || [TTVResolutionStore sharedInstance].resolutionAlertClick) {
            if ([type integerValue] == TTVPlayerResolutionTypeAuto) {
                title = [NSString stringWithFormat:@"自动(%@)",[TTVPlayerStateModel typeStringForType:[TTVResolutionStore sharedInstance].autoResolution]];
            }else{
                title = [TTVPlayerStateModel typeStringForType:[type integerValue]];
            }
            btnColorStr = [type integerValue] == TTVPlayerResolutionTypeAuto ? kColorText4 : kColorText12;
        }else{
            if ([type integerValue] == TTVPlayerResolutionTypeAuto) {
                if([[TTVResolutionStore sharedInstance] userSelected]){
                    title = [NSString stringWithFormat:@"自动"];
                }else{
                    title = [NSString stringWithFormat:@"自动(%@)",[TTVPlayerStateModel typeStringForType:[TTVResolutionStore sharedInstance].autoResolution]];
                }
            }else{
                title = [TTVPlayerStateModel typeStringForType:[type integerValue]];
            }
            
            if ([[TTVResolutionStore sharedInstance] userSelected]) {
                btnColorStr = self.playerStateStore.state.currentResolution == [type integerValue] ? kColorText4 : kColorText12;
            }else{
                btnColorStr = [type integerValue] == TTVPlayerResolutionTypeAuto ? kColorText4 : kColorText12;
            }
        }

        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
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
        [TTVResolutionStore sharedInstance].lastResolution = sender.tag;
    }
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


//
//  TTVPlayerPlaybackSpeedView.m
//  Article
//
//  Created by Chen Hong on 2018/11/26.
//

#import "TTVPlayerPlaybackSpeedView.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>

#define kButtonH 64.f

@interface TTVPlayerPlaybackSpeedView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, copy) NSArray<NSNumber *> *presetSpeedArray;
@property (nonatomic, copy) NSArray<NSString *> *presetSpeedTitleArray;
@property (nonatomic, assign) BOOL hasChangedSpeed;
@end

@implementation TTVPlayerPlaybackSpeedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.87f];
//        NSDictionary *dic = [[TTSettingsManager sharedManager] settingForKey:@"video_lvideo_config" defaultValue:@{} freeze:NO];
//        NSInteger maxSpeed = [dic integerValueForKey:@"video_max_speed_ratio" defaultValue:200];
//        maxSpeed = MAX(150, MIN(maxSpeed, 200));
        NSInteger maxSpeed = 150;
        
        NSMutableArray <NSNumber *> *speedArray = [NSMutableArray arrayWithObjects:@0.75, @1.0, @1.25, @1.5, nil];
        NSMutableArray *titleArray = [NSMutableArray arrayWithObjects:@"0.75X", @"1.0X", @"1.25X", @"1.5X", nil];
                                      
        if (maxSpeed > 150 && maxSpeed <= 200) {
            [speedArray addObject:@(maxSpeed/100.0)];
            
            NSString *title = @"";
            if (maxSpeed % 10 == 0) {
                title = [NSString stringWithFormat:@"%.1fX", maxSpeed/100.0];
            } else {
                title = [NSString stringWithFormat:@"%.2fX", maxSpeed/100.0];
            }
            [titleArray addObject:title];
        }
        
        _presetSpeedArray = [speedArray copy];
        _presetSpeedTitleArray = [titleArray copy];
        NSAssert(_presetSpeedArray.count == _presetSpeedTitleArray.count, @"数量不一致");
        _currentSpeed = 1.0;
    }
    
    return self;
}

- (void)showContainerViewIsPortrait:(BOOL)isPortrait {
    if (self.containerView) {
        [self.containerView removeFromSuperview];
        self.containerView = nil;
    }
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([TTVPlayerUtility tt_padding:kButtonH] * self.presetSpeedArray.count);
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(self);
    }];
    
    [self.presetSpeedArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat speed = [obj floatValue];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.tag = idx;
        
        if (self.currentSpeed == speed) {
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:[UIColor colorWithWhite:250.0f / 255.0f alpha:0.9f] forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:[TTVPlayerUtility tt_fontSize:17.f]];
        [button setTitle:self.presetSpeedTitleArray[idx] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(speedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        // TODO
        [self.containerView addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView.mas_top).offset(idx * [TTVPlayerUtility tt_padding:kButtonH]);
            make.height.mas_equalTo([TTVPlayerUtility tt_padding:kButtonH]);
            make.left.mas_equalTo(self.containerView);
            make.right.mas_equalTo(self.containerView);
        }];
    }];
}

- (void)showInView:(UIView *)view {
    self.isShowing = YES;
    [view addSubview:self];
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        [self showContainerViewIsPortrait:YES];
        self.frame = CGRectMake(0, CGRectGetMaxY(view.frame), view.bounds.size.width, [TTVPlayerUtility tt_padding:kButtonH] * self.presetSpeedArray.count + 20);
        [UIView animateWithDuration:.15f animations:^{
            CGRect frame = self.frame;
            frame.origin.y = view.size.height - frame.size.height;
            self.frame = frame;
        }];
    } else {
        [self showContainerViewIsPortrait:NO];
        self.frame = CGRectMake(view.bounds.size.width, 0, view.bounds.size.height * 240.f / 375.f, view.bounds.size.height);
        [UIView animateWithDuration:.15f animations:^{
            self.frame = CGRectMake(view.bounds.size.width - view.bounds.size.height * 240.f / 375.f, 0, view.bounds.size.height * 240.f / 375.f, view.bounds.size.height);
        }];
    }
}

- (void)dismiss {
    if (self.isShowing) {
        [self removeFromSuperview];
        self.isShowing = NO;
    }
}

- (void)speedButtonClicked:(UIButton *)sender {
    [self dismiss];
    NSInteger idx = sender.tag;
    if (idx < self.presetSpeedArray.count) {
        CGFloat speed = [self.presetSpeedArray[idx] floatValue];
        if (self.currentSpeed != speed) {
            self.currentSpeed = speed;
            self.hasChangedSpeed = YES;
        
            if (self.didPlaybackSpeedChanged) {
                self.didPlaybackSpeedChanged(speed);
            }
        }
    }
}

- (void)setCurrentSpeed:(CGFloat)speed {
    if (speed <= 0) {
        speed = 1.0f;
    }
    _currentSpeed = speed;
}

- (NSString *)titleForPlaybackSpeed:(CGFloat)speed {
    NSString *ret = @"";
    if (!self.hasChangedSpeed && speed == 1.0) {
        ret = @"倍速";
    } else {
        NSUInteger idx = [self.presetSpeedArray indexOfObject:@(speed)];
        if (idx != NSNotFound && idx < self.presetSpeedTitleArray.count) {
            ret = self.presetSpeedTitleArray[idx];
        }
    }
    return ret;
}

- (NSString *)tipForPlaybackSpeed:(CGFloat)speed {
    NSString *ret = @"";
    NSUInteger idx = [self.presetSpeedArray indexOfObject:@(speed)];
    if (idx != NSNotFound && idx < self.presetSpeedTitleArray.count) {
        ret = [self.presetSpeedTitleArray[idx] stringByReplacingOccurrencesOfString:@"X" withString:@"倍速"];
    }
    return ret;
}

- (void)reset {
    self.hasChangedSpeed = NO;
    self.currentSpeed = 1.0;
}

@end

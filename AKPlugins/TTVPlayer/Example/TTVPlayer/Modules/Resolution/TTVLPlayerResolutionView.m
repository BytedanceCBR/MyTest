//
//  TTVLPlayerResolutionView.m
//  Article
//
//  Created by 戚宽 on 2018/3/19.
//

#import "TTVLPlayerResolutionView.h"
#import "TTVideoResolutionService.h"
#import <AFNetworking/AFNetworking.h>
#import <ReactiveObjC/ReactiveObjC.h>
//#import "TTVLongVideoHeaders.h"

@interface TTVLPlayerResolutionView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSArray <NSNumber *> *supportedTypes;
@property (nonatomic, assign) TTVideoEngineResolutionType currentType;
@end

@implementation TTVLPlayerResolutionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.87f];
    }
    
    return self;
}

- (void)showContainerViewIsPortrait:(BOOL)isPortrait
{
    if (_containerView) {
        [_containerView removeFromSuperview];
        _containerView = nil;
    }
    _containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:_containerView];
    
    if (isPortrait) {
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }else{
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
        }];
    }

    
    NSUInteger count = self.supportedTypes.count;
    [self.supportedTypes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger type = [obj unsignedIntegerValue];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        if (self.currentType == type) {
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:[TTVPlayerUtility tt_fontSize:17.f]];
        [button setTitle:[self buttonTitleForResolution:type] forState:UIControlStateNormal];
        button.hitTestEdgeInsets = UIEdgeInsetsMake(-12, -12, -12, -12);
        WeakSelf;
        [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            StrongSelf;
            if (type != TTVideoEngineResolutionTypeUnknown && self.didResolutionChanged) {
                self.didResolutionChanged(type);
            }
            if (type != TTVideoEngineResolutionTypeUnknown) {
                [TTVideoResolutionService setDefaultResolutionType:type];
                [TTVideoResolutionService setAutoModeEnable:NO];
            }
        }];
        [button sizeToFit];
        [_containerView addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (isPortrait) {
                make.top.mas_equalTo(_containerView).offset((idx + 1) * [TTVPlayerUtility tt_fontSize:32.f] + idx * [TTVPlayerUtility tt_fontSize:24.f]);
            }else{
                make.top.mas_equalTo(_containerView).offset((count - idx - 1) * [TTVPlayerUtility tt_fontSize:65.f]);
            }
            make.centerX.mas_equalTo(_containerView);
            make.left.mas_greaterThanOrEqualTo(_containerView);
            make.right.mas_lessThanOrEqualTo(_containerView);
            make.bottom.mas_lessThanOrEqualTo(_containerView);
        }];
    }];
}

- (void)setSupportedTypes:(NSArray <NSNumber *> *)supportedTypes
              currentType:(TTVideoEngineResolutionType)currentType {
    self.supportedTypes = supportedTypes;
    self.currentType = currentType;
}

- (NSString *)buttonTitleForResolution:(TTVideoEngineResolutionType)resolution {
    NSMutableString *ret = [NSMutableString string];
    if (resolution == TTVideoEngineResolutionTypeSD) {
        [ret appendString:@"标清 360P"];
    } else if (resolution == TTVideoEngineResolutionTypeHD) {
        [ret appendString:@"高清 480P"];
    } else if (resolution == TTVideoEngineResolutionTypeFullHD) {
        [ret appendString:@"超清 720P"];
    } else if (resolution == TTVideoEngineResolutionType1080P) {
        [ret appendString:@"蓝光 1080P"];
    } else if (resolution == TTVideoEngineResolutionType4K) {
        [ret appendString:@"4K"];
    } else if (resolution == TTVideoEngineResolutionTypeAuto) {
        [ret appendString:@"自动"];
    } else {
        [ret appendString:@"未知"];
    }
    if (![[AFNetworkReachabilityManager sharedManager] isReachable] || [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
        return ret;
    }
    if (!self.sizeForClarityDictionary) {
        return ret;
    } else {
        NSNumber *size = self.sizeForClarityDictionary[@(resolution)];
        if (!size) {
            return ret;
        }
        [ret appendFormat:@" (%@)", [self transformByteToDestination:[size unsignedLongLongValue]]];
        return ret;
    }
}

- (NSString *)transformByteToDestination:(size_t)size {
    size_t mb = size / 1024 / 1024;
    if (mb < 1024) {
        return [NSString stringWithFormat:@"%lldM", (uint64_t)mb];
    } else {
        return [NSString stringWithFormat:@"%.1fG", roundf(mb / 102.4f) / 10.f];//四舍五入保留一位小数位
    }
}

- (NSString *)titleForResolution:(TTVideoEngineResolutionType)resolution {
    if (resolution == TTVideoEngineResolutionTypeSD) {
        return @"标清";
    } else if (resolution == TTVideoEngineResolutionTypeHD) {
        return @"高清";
    } else if (resolution == TTVideoEngineResolutionTypeFullHD) {
        return @"超清";
    } else if (resolution == TTVideoEngineResolutionType1080P) {
        return @"蓝光";
    } else if (resolution == TTVideoEngineResolutionType4K) {
        return @"4K";
    } else if (resolution == TTVideoEngineResolutionTypeAuto) {
        return @"自动";
    } else {
        return @"未知";
    }
}

- (void)showInView:(UIView *)view atTargetPoint:(CGPoint)point {
    self.isShowing = YES;
    [view addSubview:self];
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        [self showContainerViewIsPortrait:YES];
        self.frame = CGRectMake(0, CGRectGetMaxY(view.frame), view.bounds.size.width, [TTVPlayerUtility tt_fontSize:32.f] * (self.supportedTypes.count + 1) + self.supportedTypes.count * [TTVPlayerUtility tt_fontSize:24.f]);
        [UIView animateWithDuration:.15f animations:^{
            CGRect frame = self.frame;
            frame.origin.y = view.size.height - frame.size.height;
            self.frame = frame;
//            self.frame = CGRectMake(0, 0, self.width, self.height);
        }];
    } else {
        [self showContainerViewIsPortrait:NO];
        self.frame = CGRectMake(view.bounds.size.width, 0, view.bounds.size.height * 240.f / 375.f, view.bounds.size.height);
        [UIView animateWithDuration:.15f animations:^{
            self.frame = CGRectMake(view.bounds.size.width - view.bounds.size.height * 240.f / 375.f, 0, view.bounds.size.height * 240.f / 375.f, view.bounds.size.height);
//            self.frame = CGRectMake(0, 0, self.width, self.height);

        }];
    }
    
    // frame error
}

- (void)dismiss {
    [self removeFromSuperview];
    self.isShowing = NO;
}

@end

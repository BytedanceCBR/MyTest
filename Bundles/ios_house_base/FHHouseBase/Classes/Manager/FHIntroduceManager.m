//
//  FHIntroduceManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import "FHIntroduceManager.h"
#import <FHIntroduceView.h>
#import "FHIntroduceModel.h"

@interface FHIntroduceManager ()

@property(nonatomic ,strong) FHIntroduceView *view;
@property(nonatomic ,strong) FHIntroduceModel *model;
@property (nonatomic , assign) BOOL isShowing;

@end

@implementation FHIntroduceManager

+ (instancetype)sharedInstance {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isShowing = NO;
        [self generateModel];
        
        [[UIApplication sharedApplication] addObserver:self forKeyPath:@"statusBarHidden" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)showIntroduceView:(UIView *)keyWindow {
    self.isShowing = YES;
    self.view = [[FHIntroduceView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) model:self.model];
    [keyWindow addSubview:_view];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)hideIntroduceView {
    self.isShowing = NO;
    [self.view removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)generateModel {
    self.model = [[FHIntroduceModel alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    FHIntroduceItemModel *model = nil;
    
    model = [[FHIntroduceItemModel alloc] init];
    model.showJumpBtn = YES;
    model.showEnterBtn = NO;
    model.lottieJsonStr = @"introduce_1";
    model.indicatorImageName = @"fh_introduce_indicator_1";
    [items addObject:model];
    
    model = [[FHIntroduceItemModel alloc] init];
    model.showJumpBtn = YES;
    model.showEnterBtn = NO;
    model.lottieJsonStr = @"introduce_2";
    model.indicatorImageName = @"fh_introduce_indicator_2";
    [items addObject:model];
    
    model = [[FHIntroduceItemModel alloc] init];
    model.showJumpBtn = NO;
    model.showEnterBtn = YES;
    model.lottieJsonStr = @"introduce_3";
    model.indicatorImageName = nil;
    [items addObject:model];
    
    self.model.items = items;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"statusBarHidden"]) {
        if([change[@"new"] boolValue]){
            NSLog(@"1");
        }
    }
}

@end

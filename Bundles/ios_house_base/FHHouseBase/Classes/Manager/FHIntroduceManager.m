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
        [self generateModel];
    }
    return self;
}

- (void)showIntroduceView:(UIView *)keyWindow {
    self.view = [[FHIntroduceView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) model:self.model];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [keyWindow addSubview:_view];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)generateModel {
    self.model = [[FHIntroduceModel alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    FHIntroduceItemModel *model = nil;
    
    model = [[FHIntroduceItemModel alloc] init];
    model.title = @"精准购房";
    model.subTitle = @"个性推选 动态选房";
    model.showJumpBtn = YES;
    model.showEnterBtn = NO;
    [items addObject:model];
    
    model = [[FHIntroduceItemModel alloc] init];
    model.title = @"资讯盘点";
    model.subTitle = @"楼市行情 专业测评";
    model.showJumpBtn = YES;
    model.showEnterBtn = NO;
    [items addObject:model];
    
    model = [[FHIntroduceItemModel alloc] init];
    model.title = @"买房社区";
    model.subTitle = @"想买好房 全凭“经验”";
    model.showJumpBtn = NO;
    model.showEnterBtn = YES;
    [items addObject:model];
    
    self.model.items = items;
}

@end

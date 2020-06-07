//
//  FHUGCEncyclopediaListCell.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/21.
//

#import "FHUGCEncyclopediaListCell.h"
#import "FHEncyclopediaListViewController.h"

@interface FHUGCEncyclopediaListCell ()

@property(nonatomic, strong) FHEncyclopediaListViewController *vc;

@end
@implementation FHUGCEncyclopediaListCell


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.contentView.backgroundColor = [UIColor clearColor];
        [self initUI];
    }
    
    return self;
}
- (UIViewController *)contentViewController {
    return _vc;
}

- (void)initUI {
    if(self.vc){
        [self.vc.view removeFromSuperview];
        [self.vc removeFromParentViewController];
        self.vc = nil;
    }
    FHEncyclopediaListViewController *vc = [[FHEncyclopediaListViewController alloc] init];
    self.vc = vc;
    if(self.vc){
        self.vc.view.frame = self.bounds;
        [self.contentView addSubview:self.vc.view];
    }
}

- (void)setHeaderConfigData:(NSDictionary *)headerConfigData {
    _headerConfigData = headerConfigData;
    if ([_headerConfigData.allKeys containsObject: @"channel_id"]) {
        self.vc.channel_id = _headerConfigData[@"channel_id"];
    }
    [self.vc startLoadData];
}
- (void)setTracerModel:(FHTracerModel *)tracerModel {
    _tracerModel = tracerModel;
    if (_tracerModel) {
        self.vc.tracerModel = tracerModel;
    }else {
        self.vc.tracerModel = [FHTracerModel makerTracerModelWithDic:@{}];
    }
}
@end

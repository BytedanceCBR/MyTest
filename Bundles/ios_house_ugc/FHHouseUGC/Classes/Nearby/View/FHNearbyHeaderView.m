//
//  FHNearbyHeaderView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/1/7.
//

#import "FHNearbyHeaderView.h"

@implementation FHNearbyHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor themeGray7];
    self.progressView = [FHPostUGCProgressView sharedInstance];
    [self addSubview:self.progressView];
}

@end

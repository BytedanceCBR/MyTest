//
//  FHPostUGCProgressView.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/20.
//

#import "FHPostUGCProgressView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"

@interface FHPostUGCProgressView ()

@property (nonatomic, assign)   CGFloat       ugc_viewHeight;

@end

@implementation FHPostUGCProgressView

+ (instancetype)sharedInstance {
    static FHPostUGCProgressView *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[FHPostUGCProgressView alloc] initWithFrame:CGRectZero];
    }
    return _sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        [self setupData];
    }
    return self;
}

- (CGFloat)viewHeight {
    return _ugc_viewHeight;
}

- (void)setupData {
    _ugc_viewHeight = 40;
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.ugc_viewHeight);
}

@end

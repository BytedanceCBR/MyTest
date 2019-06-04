//
//  FHPostDetailViewController
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHPostDetailViewController.h"

@implementation FHPostDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 帖子
        self.postType = FHUGCPostTypePost;
    }
    return self;
}

@end

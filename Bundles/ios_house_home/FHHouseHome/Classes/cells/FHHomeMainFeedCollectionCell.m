//
//  FHHomeMainFeedCollectionCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/22.
//

#import "FHHomeMainFeedCollectionCell.h"
#import "FHCommunityViewController.h"
#import "FHEnvContext.h"

@implementation FHHomeMainFeedCollectionCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.contentView.backgroundColor = [UIColor clearColor];
        [self addCommunityVC];
    }
    return self;
}

- (void)addCommunityVC {
    FHCommunityViewController *vc = [[FHCommunityViewController alloc] init];
    vc.isInHomePage = YES;
    vc.tracerDict = @{
        @"origin_from":@"discover_stream",
        @"enter_from":@"maintab",
        @"category_name":@"discover_stream"
    }.mutableCopy;
    
    self.contentVC = vc;
    vc.view.frame = self.bounds;
    [self.contentView addSubview:vc.view];
}

@end

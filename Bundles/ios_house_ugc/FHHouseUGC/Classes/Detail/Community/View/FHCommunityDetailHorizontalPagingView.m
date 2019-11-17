//
//  FHCommunityDetailHorizontalPagingView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/11/11.
//

#import "FHCommunityDetailHorizontalPagingView.h"
#import <TTBaseLib/UIViewAdditions.h>
#import "TTHorizontalPagingSegmentView.h"

@implementation FHCommunityDetailHorizontalPagingView

- (void)reloadHeaderViewHeight:(CGFloat)height {
    if(self.headerViewHeight == height) return;
    CGFloat delta = self.headerViewHeight - height;
    CGFloat offsetY = self.currentContentView.contentOffset.y + delta;
    [self setValue:@(height) forKeyPath:@"headerViewHeight"];
    self.headerView.height = height;
    self.currentContentView.contentOffset = CGPointMake(0,offsetY);
    self.currentContentView.contentInset = UIEdgeInsetsMake(self.headerViewHeight + self.segmentViewHeight, 0, self.currentContentView.contentInset.bottom, 0);
    self.movingView.frame = CGRectMake(0, - self.currentContentViewTopInset, self.width, self.currentContentViewTopInset);
    self.segmentView.frame = CGRectMake(0, self.headerView.bottom, self.width, self.segmentViewHeight);
}

@end

//
//  FHRentMainPageDataSource.m
//  Demo
//
//  Created by 谷春晖 on 2018/11/22.
//  Copyright © 2018年 com.haoduofangs. All rights reserved.
//

#import "FHRentMainPageDataSource.h"

@implementation FHRentMainPageDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [super numberOfSectionsInTableView:tableView];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        return nil;
    }
    
    if (self.headerViewBlock) {
        return self.headerViewBlock();
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _headerViewHeight;
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{     
    if (velocity.y > 0.5) {
        //向下滑动
        if (scrollView.contentOffset.y < _topViewHeight ) {
             *targetContentOffset = CGPointMake(0, _topViewHeight);
        }
    }else if (velocity.y < -0.5){
        //向上滑动
        if (scrollView.contentOffset.y > _topViewHeight && scrollView.contentOffset.y < 2*fabs(velocity.y)*CGRectGetHeight(scrollView.frame)) {
            *targetContentOffset = CGPointMake(0, _topViewHeight);
        }else if(scrollView.contentOffset.y < _topBounceThreshhold  ){
            *targetContentOffset = CGPointZero;
        }
    }
}

@end

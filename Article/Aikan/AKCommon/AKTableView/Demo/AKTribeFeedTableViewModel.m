//
//  AKTribeFeedTableViewModel.m
//  Article
//
//  Created by 冯靖君 on 2018/4/16.
//

#import "AKTribeFeedTableViewModel.h"
#import <TTRoute.h>

@implementation AKTestTableViewCellModel

@synthesize cacheHeight;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.value = @(arc4random() % 10);
    }
    return self;
}

- (CGFloat)caculateHeight
{
    CGFloat cacHeight = self.value.integerValue * 10;
    self.cacheHeight = cacHeight;
    return cacHeight;
}

@end

@implementation AKTribeFeedTableViewModel

- (void)dealloc
{
    LOGD(@"-----[AKTribeFeedTableViewModel] instance deallocated-----");
}

- (void)registerIMP
{
    LOGD(@"服务的tableView是%@", self.tableView);
    LOGD(@"数据源是%@", self.datasourceArray);
    LOGD(@"额外业务上下文参数是%@", self.extra);
    
    [super registerIMP];
    
    [self.tableView registerCellClass:nil];

    // 考虑numberOfSectionsBlock和numberOfRowsBlock较为通用的实现放到基类
    
    self.tableView.cellForRowBlock = ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithClass:nil forIndexPath:indexPath];
        cell.textLabel.text = ((AKTestTableViewCellModel *)[[self.datasourceArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]).value.stringValue;
        cell.textLabel.font = [UIFont systemFontOfSize:15.f];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor colorWithRed:(arc4random() % 255)/255.f green:(arc4random() % 255)/255.f blue:(arc4random() % 255)/255.f alpha:1];
        return cell;
    };
    self.tableView.didSelectBlock = ^(UITableView *tableView, NSIndexPath *indexPath) {
        NSURL *url = [NSURL URLWithString:@"sslocal://detail?groupid=6544936961159725571"];
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    };
}

@end

//
//  FHPostDetailViewController
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHPostDetailViewController.h"
#import "FHFeedUGCCellModel.h"
#import "FHPostDetailViewModel.h"
#import "FHDetailCommentAllFooter.h"

@interface FHPostDetailViewController ()

@property (nonatomic, strong)   FHFeedUGCCellModel       *detailData;
@property (nonatomic, strong)   FHDetailCommentAllFooter       *commentAllFooter;

@end

@implementation FHPostDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 帖子
        self.postType = FHUGCPostTypePost;
        NSDictionary *params = paramObj.allParams;
        self.detailData = params[@"data"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.detailData) {
        [self.viewModel.items addObject:self.detailData];
    }
    // 全部评论
    NSString *commentStr = @"全部评论";
    if ([self.detailData.commentCount integerValue] > 0) {
        commentStr = [NSString stringWithFormat:@"全部评论(%@)",self.detailData.commentCount];
    } else {
        commentStr = [NSString stringWithFormat:@"全部评论(0)"];
    }
    self.commentAllFooter = [[FHDetailCommentAllFooter alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 52)];
    self.commentAllFooter.allCommentLabel.text = commentStr;
    self.tableView.tableFooterView = self.commentAllFooter;
    // 刷新数据
    [self.viewModel reloadData];
}

@end

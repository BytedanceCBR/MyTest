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

@property (nonatomic, assign) int64_t tid; //帖子ID
@property (nonatomic, assign) int64_t fid; //话题ID
@property (nonatomic, copy) NSString *cid; //关心ID

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
        int64_t tid = [[paramObj.allParams objectForKey:@"tid"] longLongValue];
        int64_t fid = [[paramObj.allParams objectForKey:@"fid"] longLongValue];
        self.detailData = params[@"data"];// 列表页数据
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

/*
 - (FRThreadSmartDetailViewModel *)viewModel {
 if (_viewModel == nil) {
 _viewModel = [[FRThreadSmartDetailViewModel alloc] initWithThreadID:self.tid forumID:self.fid];
 if ([self isAdContent]) {
 [_viewModel setupAdInfoWithAdId:self.adId logExtra:self.logExtra];
 }
 _viewModel.dataSource = self;
 _viewModel.threadDetailController = self;
 _viewModel.category = [self.extraTracks tt_stringValueForKey:@"category_id"];
 _viewModel.thread.gComposition = self.personalHomeGroupComposition;
 _viewModel.thread.gSource = self.personalHomeGroupSource;
 _viewModel.thread.personalHomeGroupId = self.personalHomeGroupId;
 }
 
 return _viewModel;
 }

 */

@end

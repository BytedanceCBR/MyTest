//
//  FHMyJoinViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import "FHMyJoinViewModel.h"
#import <TTHttpTask.h>
#import "FHMyJoinNeighbourhoodCell.h"

#define cellId @"cellId"

@interface FHMyJoinViewModel ()<UICollectionViewDelegate,UICollectionViewDataSource,FHMyJoinNeighbourhoodViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, weak) FHMyJoinViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, assign) BOOL isShowMessage;

@end

@implementation FHMyJoinViewModel

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(FHMyJoinViewController *)viewController {
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc] init];
        _viewController = viewController;
        _collectionView = collectionView;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[FHMyJoinNeighbourhoodCell class] forCellWithReuseIdentifier:cellId];
    }
    
    return self;
}

- (void)requestData {
    for (NSInteger i = 0; i < 10; i++) {
        [self.dataList addObject:[NSString stringWithFormat:@"小区%li",(long)i]];
    }
    [self.collectionView reloadData];
}

- (void)refreshMessage {
    [self.viewController.neighbourhoodView.messageView refreshWithUrl:@"http://p1.pstatp.com/thumb/fea7000014edee1159ac" messageCount:2];
}

- (void)showMessageView {
    self.isShowMessage = YES;
    self.viewController.neighbourhoodView.messageView.hidden = NO;
    
    CGRect frame = self.viewController.neighbourhoodView.frame;
    frame.size.height = 258;
    self.viewController.neighbourhoodView.frame = frame;
    
    self.viewController.feedListVC.tableHeaderView = self.viewController.neighbourhoodView;
    
    [self refreshMessage];
}

- (void)hideMessageView {
    self.isShowMessage = NO;
    self.viewController.neighbourhoodView.messageView.hidden = YES;
    
    CGRect frame = self.viewController.neighbourhoodView.frame;
    frame.size.height = 200;
    self.viewController.neighbourhoodView.frame = frame;
    
    self.viewController.feedListVC.tableHeaderView = self.viewController.neighbourhoodView;
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHMyJoinNeighbourhoodCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    if (indexPath.row < self.dataList.count) {
        [cell refreshWithData:self.dataList[indexPath.row]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    //跳转到圈子详情页
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_post_community_detail"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
}

//埋点
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
//    if ([self.houseShowCache valueForKey:tempKey]) {
//        return;
//    }
//    [self.houseShowCache setValue:@(YES) forKey:tempKey];
//    // 添加埋点
//    if (self.displayCellBlk) {
//        self.displayCellBlk(indexPath.row);
//    }
}

#pragma mark - FHMyJoinNeighbourhoodViewDelegate

- (void)gotoMore {
//    if(self.isShowMessage){
//        [self hideMessageView];
//    }else{
//        [self showMessageView];
//    }
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_follow_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
}

@end

//
//  FHHouseRealtorDetailRGCCell.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/12.
//

#import "FHHouseRealtorDetailRGCCell.h"
#import "FHHouseRealtorDetailBaseCellModel.h"
#import "Masonry.h"
#import "FHHouseRealtorDetailStatusModel.h"

#import "FHHouseRealtorDetailHouseCollectionCell.h"
#import "FHHouseRealtorDetailRgcCollectionCell.h"
#import "FHHouseRealtorDetailInfoModel.h"
@interface FHHouseRealtorDetailRGCCell()
@property (nonatomic, weak)UIView *containerView;

@end
@implementation FHHouseRealtorDetailRGCCell

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHHouseRealtorDetailRGCCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHHouseRealtorDetailRGCCellModel *model = (FHHouseRealtorDetailRGCCellModel *)data;
    
    if (model) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        NSMutableArray *dataArr = [[NSMutableArray alloc]init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if (model.tabDataArray.count>0) {
            for (FHHouseRealtorDetailRgcTabModel *tabModel in model.tabDataArray) {
                if ([tabModel.showName isEqualToString:@"房源"]) {
                    FHHouseRealtorDetailHouseCollectionModel *model = [[FHHouseRealtorDetailHouseCollectionModel alloc]init];
                    model.showName = tabModel.showName;
                    model.name = tabModel.tabName;
                    model.count = tabModel.count;
                    [dataArr addObject:model];
                }else {
                    FHHouseRealtorDetailRgcCollectionModel *model = [[FHHouseRealtorDetailRgcCollectionModel alloc]init];
                    model.showName = tabModel.showName;
                    model.name = tabModel.tabName;
                    model.count = tabModel.count;
                    [dataArr addObject:model];
                }
            }
        };
        _collection = [[FHHouseRealtorDetailitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:200 datas:dataArr];
        __weak typeof(self)ws = self;
        _collection.cellRefreshComplete = ^{
            if (ws.cellRefreshComplete) {
                ws.cellRefreshComplete();
                [ws layoutcollection];
            }
        };
        [self.containerView addSubview:_collection];
        __weak typeof(self) wSelf = self;
        _collection.clickBlk = ^(NSInteger index) {
            //                    if (index == model.sameNeighborhoodHouseData.items.count) {
            //                        [wSelf moreButtonClick];
            //                    }else {
            //                        [wSelf collectionCellClick:index];
            //                    }
        };
        _collection.displayCellBlk = ^(NSInteger index) {
            //                    [wSelf collectionDisplayCell:index];
        };
        [_collection mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.containerView);
        }];
        [_collection reloadData];
    }
}

- (void)layoutcollection {
    NSInteger index = [FHHouseRealtorDetailStatusModel sharedInstance].currentIndex;
    CGFloat f = [FHHouseRealtorDetailStatusModel sharedInstance].currentCellHeight;
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
           [_collection mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.containerView);
            make.height.mas_offset( [FHHouseRealtorDetailStatusModel sharedInstance].currentCellHeight);
        }];
    });

}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.contentView);
    }];
    
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [[UIView alloc]init];
        containerView.clipsToBounds = YES;
        containerView.backgroundColor = [UIColor colorWithHexStr:@"#f8f8f8"];
        [self.contentView addSubview:containerView];
        _containerView = containerView;
    }
    return _containerView;
}
- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    [self.collection requestData:isHead first:isFirst];
}

@end

//
//  FHHouseDetailUserEvaluationCell.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/12.
//

#import "FHHouseDetailUserEvaluationCell.h"
#import <YYText/YYLabel.h>
@implementation FHHouseDetailUserEvaluationCell

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHHouseRealtorDetailUserEvaluationModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.contentView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHHouseRealtorDetailUserEvaluationModel *model = (FHHouseRealtorDetailUserEvaluationModel *)data;
    if (model) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        NSMutableArray *dataArr = [[NSMutableArray alloc]initWithArray:model.sameNeighborhoodHouseData.items];
        if (model.sameNeighborhoodHouseData.hasMore && dataArr.count>3) {
            FHDetailMoreItemModel *moreItem = [[FHDetailMoreItemModel alloc]init];
            [dataArr addObject:moreItem];
        }
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHSearchHouseDataItemsModel class]);
        NSString *moreIdentifier = NSStringFromClass([FHDetailMoreItemModel class]);
//        FHDetailMultitemCollectionView *colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:210 cellIdentifier:identifier cellCls:[FHDetailSameNeighborhoodHouseCollectionCell class] datas:model.sameNeighborhoodHouseData.items];
        FHOldDetailMultitemCollectionView *colView = [[FHOldDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:210 datas:dataArr];
        [colView registerCell:[FHDetailSameNeighborhoodHouseCollectionCell class] forIdentifier:identifier];
        [colView registerCell:[FHDetailMoreItemCollectionCell class] forIdentifier:moreIdentifier];
        [self.containerView addSubview:colView];
        __weak typeof(self) wSelf = self;
        colView.clickBlk = ^(NSInteger index) {
            if (index == model.sameNeighborhoodHouseData.items.count) {
                [wSelf moreButtonClick];
            }else {
                [wSelf collectionCellClick:index];
            }
        };
        colView.displayCellBlk = ^(NSInteger index) {
            [wSelf collectionDisplayCell:index];
        };
        [colView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
            make.left.mas_equalTo(self.containerView).offset(15);
            make.right.mas_equalTo(self.containerView).offset(-15);
            make.bottom.mas_equalTo(self.containerView).offset(-10);
        }];
        [colView reloadData];
    }
    
    [self layoutIfNeeded];
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

@end

@interface FHHouseDetailUserEvaluationCollectionCell ()
@property (nonatomic, strong) UIImageView *userImage;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) YYLabel *tabLab;
@property (nonatomic, strong) UILabel *contentLab;
@property (nonatomic, strong) UIView *starView;
@property (nonatomic, strong) UILabel *starNumLab;
@end
@implementation FHHouseDetailUserEvaluationCollectionCell
@end

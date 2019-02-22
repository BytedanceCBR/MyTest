//
//  FHDetailNeighborhoodTransationHistoryCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/2/20.
//

#import "FHDetailNeighborhoodTransationHistoryCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "FHDetailFoldViewButton.h"
#import "UILabel+House.h"
#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHDetailBottomOpenAllView.h"
#import "FHTransactionHistoryCell.h"

@interface FHDetailNeighborhoodTransationHistoryCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;

@end

@implementation FHDetailNeighborhoodTransationHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodTransationHistoryModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHDetailNeighborhoodTransationHistoryModel *model = (FHDetailNeighborhoodTransationHistoryModel *)data;
    if (model) {
        _headerView.isShowLoadMore = model.totalSales.hasMore;
        if(model.totalSalesCount > 0){
            _headerView.label.text = [NSString stringWithFormat:@"小区成交历史(%@) ",model.totalSalesCount];
        }else{
            _headerView.label.text = @"小区成交历史";
        }
        NSArray *list = model.totalSales.list;
        UIView *lastView = _headerView;
        
        for (NSInteger i = 0; i < list.count; i++) {
            FHDetailNeighborhoodDataTotalSalesListModel *itemModel = list[i];
            FHTransactionHistoryCell *cell = [[FHTransactionHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [cell updateWithModel:itemModel];
            [self.containerView addSubview:cell];
            
            [cell mas_makeConstraints:^(MASConstraintMaker *make) {
                if(i == 0){
                    make.top.mas_equalTo(lastView.mas_bottom).offset(10);
                }else{
                    make.top.mas_equalTo(lastView.mas_bottom);
                }
                make.height.mas_equalTo(65);
                make.width.mas_equalTo(UIScreen.mainScreen.bounds.size.width);
                if(i == list.count - 1){
                    make.bottom.mas_equalTo(self.containerView);
                }
            }];
            lastView = cell;
        }
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

- (void)setupUI {
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"小区成交历史";
    [_headerView addTarget:self action:@selector(loadMoreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
    }];
}

- (void)loadMoreButtonClick:(UIButton *)btn {
    FHDetailNeighborhoodTransationHistoryModel *model = (FHDetailNeighborhoodTransationHistoryModel *)self.currentData;
    
    if (model && model.totalSales.hasMore) {
        NSURL* url = [NSURL URLWithString:@"snssdk1370://transaction_history"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict addEntriesFromDictionary:[self.baseViewModel subPageParams]];
        dict[@"neighborhood_id"] = model.neighborhoodId;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"neighborhood_trade";
}

@end

@implementation FHDetailNeighborhoodTransationHistoryModel

@end

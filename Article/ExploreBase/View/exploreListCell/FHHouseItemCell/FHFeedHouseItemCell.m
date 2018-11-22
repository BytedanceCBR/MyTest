//
//  FHFeedHouseItemCell.m
//  Article
//
//  Created by 张静 on 2018/11/20.
//

#import "FHFeedHouseItemCell.h"
#import "FHExploreHouseItemData.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "FHFeedHouseItemViewModel.h"
#import "FHFeedHouseFooterView.h"
#import "UIColor+Theme.h"

@implementation FHFeedHouseItemCell

+ (Class)cellViewClass {
    return [FHFeedHouseItemCellView class];
}

- (void)willDisplay {
    [self.cellView willAppear];
}

- (void)didEndDisplaying {
    [self.cellView didDisappear];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@interface FHFeedHouseItemCellView ()

@property (nonatomic, strong) UITableView *houseTableView;
@property(nonatomic , strong) FHFeedHouseHeaderView *headerView;
@property(nonatomic , strong) FHFeedHouseFooterView *footerView;
@property (nonatomic, strong) FHFeedHouseItemViewModel *viewModel;

@end


@implementation FHFeedHouseItemCellView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildupView];
        [self configViewModel];
    }
    return self;
}

- (void)buildupView {

    [self addSubview:self.houseTableView];
    self.tableView.frame = self.bounds;
    self.headerView = [[FHFeedHouseHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.width, 45 + 6)];
    self.footerView = [[FHFeedHouseFooterView alloc]initWithFrame:CGRectMake(0, 0, self.width, 68 + 6)];
}

- (void)configViewModel {

    self.viewModel = [[FHFeedHouseItemViewModel alloc]initWithTableView:self.houseTableView];
    self.viewModel.headerView = self.headerView;
    self.viewModel.footerView = self.footerView;
    
}
- (void)refreshWithData:(ExploreOrderedData *)data {
    NSParameterAssert([data isKindOfClass:[ExploreOrderedData class]]);
    
    self.orderedData = data;
    if (self.orderedData.houseItemsData.items.count > 0) {
        
        self.houseTableView.frame = CGRectMake(0, 0, self.width, 51.0f + 105 * self.orderedData.houseItemsData.items.count + 74.f);
    }
    [self.viewModel updateWithHouseData:self.orderedData.houseItemsData];
    
}

- (void)willAppear {

}

- (void)didDisappear {
    
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    
//    TTExploreLoadMoreTipData *model = self.orderedData.loadmoreTipData;
//    if (model == nil || ![model isKindOfClass:[TTExploreLoadMoreTipData class]]) {
//        return;
//    }
//    NSURL *openURL = [NSURL URLWithString:model.openURL];
//    [[TTRoute sharedRoute] openURLByViewController:openURL userInfo:nil];
    

}


+ (CGFloat)heightForData:(ExploreOrderedData *)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    
    if(data.houseItemsData.items.count < 1) {
        return 0;
    }
    return 51.0f + 105 * data.houseItemsData.items.count + 74.f;
}



#pragma mark - lazy load

-(UITableView *)houseTableView {
    
    if (!_houseTableView) {
        
        _houseTableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _houseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _houseTableView.scrollEnabled = false;
    }
    return _houseTableView;
}

@end


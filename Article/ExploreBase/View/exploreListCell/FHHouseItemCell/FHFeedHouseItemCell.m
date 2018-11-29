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
    
    
    CGPoint tablePoint = [self convertPoint:CGPointZero toView:self.tableView];
    if (tablePoint.y < [UIScreen mainScreen].bounds.size.height) {
        
        [self addHouseShowLog];
    }
    
}

- (void)didEndDisplaying {
    [self.cellView didDisappear];
    
}

-(void)addHouseShowLog {
    
    FHFeedHouseItemCellView *cellView = (FHFeedHouseItemCellView *)self.cellView;
    if (cellView) {
        
        [cellView addHouseShowLog];
    }
}


//-(void)refreshUI {
//
//    [self.cellView refreshUI];
//}
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

@property(nonatomic, strong)UIView *topView;
@property(nonatomic, strong)UIView *topLine;
@property(nonatomic , strong) FHFeedHouseHeaderView *headerView;
@property (nonatomic, strong) UITableView *houseTableView;
@property(nonatomic , strong) FHFeedHouseFooterView *footerView;
@property(nonatomic, strong)UIView *bottomLine;
@property(nonatomic, strong)UIView *bottomView;

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

    [self addSubview:self.topView];
    [self addSubview:self.topLine];
    self.topLine.frame = CGRectMake(0, 0, self.width, 6);
    self.headerView = [[FHFeedHouseHeaderView alloc]initWithFrame:CGRectMake(0, self.topLine.bottom, self.width, 50)];
    [self addSubview:self.headerView];
    
    [self addSubview:self.houseTableView];

    self.footerView = [[FHFeedHouseFooterView alloc]initWithFrame:CGRectMake(0, self.tableView.bottom, self.width, 68)];
    [self addSubview:self.footerView];

    [self addSubview:self.bottomLine];
    self.bottomLine.frame = CGRectMake(0, self.footerView.bottom, self.width, 6);
    [self addSubview:self.bottomView];

}

- (void)configViewModel {

    self.viewModel = [[FHFeedHouseItemViewModel alloc]initWithTableView:self.houseTableView];
    self.viewModel.headerView = self.headerView;
    self.viewModel.footerView = self.footerView;
    
}
- (void)refreshWithData:(ExploreOrderedData *)data {
    NSParameterAssert([data isKindOfClass:[ExploreOrderedData class]]);
    
    self.orderedData = data;
    [self.viewModel updateWithHouseData:self.orderedData.houseItemsData];

}

- (void)addHouseShowLog {
    
    [self.viewModel addHouseShowLog];
}


- (id)cellData {
    return [self orderedData];
}

-(void)refreshUI {

    [super refreshUI];

    if (self.orderedData.preCellType == ExploreOrderedDataCellTypeFHHouse || self.orderedData.preCellType == ExploreOrderedDataCellTypeNull) {
        
        self.topView.frame = CGRectMake(0, 0, self.width, 0);
        self.topLine.frame = CGRectMake(0, self.topView.bottom, self.width, 6);

    }
//    else if (self.orderedData.preCellType == ExploreOrderedDataCellTypeNull) {
//
//
//    }
    else if (self.orderedData.preCellHasBottomPadding) {

        self.topLine.frame = CGRectMake(0, 0, self.width, 0);
        self.topView.frame = CGRectMake(0, 0, self.width, 0);

    }else {
        self.topView.frame = CGRectMake(0, 0, self.width, 10);
        self.topLine.frame = CGRectMake(0, self.topView.bottom, self.width, 6);

    }
    self.headerView.frame = CGRectMake(0, self.topLine.bottom, self.width, 50);

    if (self.orderedData.houseItemsData.items.count > 0) {

        self.houseTableView.frame = CGRectMake(0, self.headerView.bottom, self.width, 105 * self.orderedData.houseItemsData.items.count - 20.f);
        self.footerView.frame = CGRectMake(0, self.houseTableView.bottom, self.width, 68);
    }

    if (self.orderedData.nextCellType == ExploreOrderedDataCellTypeFHHouse || self.orderedData.nextCellType == ExploreOrderedDataCellTypeLastRead) {

        self.bottomLine.frame = CGRectMake(0, self.footerView.bottom, self.width, 0);
        self.bottomView.frame = CGRectMake(0, self.bottomLine.bottom, self.width, 0);
        
    }else if (self.orderedData.nextCellHasTopPadding) {

        self.bottomLine.frame = CGRectMake(0, self.footerView.bottom, self.width, 0);
        self.bottomView.frame = CGRectMake(0, self.bottomLine.bottom, self.width, 10);

    }else {
        self.bottomLine.frame = CGRectMake(0, self.footerView.bottom, self.width, 6);
        self.bottomView.frame = CGRectMake(0, self.bottomLine.bottom, self.width, 10);

    }

}

- (void)willAppear {

}

- (void)didDisappear {
    
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    
}


+ (CGFloat)heightForData:(ExploreOrderedData *)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    
    if(data.houseItemsData.items.count < 1) {
        return 0;
    }
    CGFloat height = 50.0f + 105 * data.houseItemsData.items.count - 20.f + 68.f;
    if (data.preCellType == ExploreOrderedDataCellTypeFHHouse || data.preCellType == ExploreOrderedDataCellTypeNull) {
        
        height += 6;

    }else if (data.preCellHasBottomPadding) {

    }else {
        height += 16;
    }
    
    if (data.nextCellType == ExploreOrderedDataCellTypeFHHouse || data.nextCellType == ExploreOrderedDataCellTypeLastRead) {
        
        
    }else if (data.nextCellHasTopPadding) {
        height += 10;

    }else {
        height += 16;
    }

    return height;
}



#pragma mark - lazy load
-(UIView *)topView{
    
    if (!_topView) {
        
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

-(UIView *)topLine{
    
    if (!_topLine) {
        
        _topLine = [[UIView alloc]init];
        _topLine.backgroundColor = [UIColor themeGray7];
    }
    return _topLine;
}

-(UITableView *)houseTableView {
    
    if (!_houseTableView) {
        
        _houseTableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _houseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _houseTableView.scrollEnabled = false;
        _houseTableView.estimatedRowHeight = 0;
        _houseTableView.estimatedSectionHeaderHeight = 0;
        _houseTableView.estimatedSectionFooterHeight = 0;
        if (@available(iOS 11.0, *)) {
            _houseTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _houseTableView;
}

-(UIView *)bottomLine {
    
    if (!_bottomLine) {
        
        _bottomLine = [[UIView alloc]init];
        _bottomLine.backgroundColor = [UIColor themeGray7];
    }
    return _bottomLine;
}

-(UIView *)bottomView{
    
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

@end


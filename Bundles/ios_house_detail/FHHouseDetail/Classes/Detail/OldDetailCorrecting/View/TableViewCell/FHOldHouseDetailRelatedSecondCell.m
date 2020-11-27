//
//  FHOldHouseDetailRelatedSecondCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/11/9.
//

#import "FHOldHouseDetailRelatedSecondCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHHouseSecondCardView.h"
#import "FHHouseSecondCardViewModel.h"

@interface FHOldHouseDetailRelatedSecondCell()

@property (nonatomic, strong) FHHouseSecondCardView *cardView;

@property (nonatomic, strong) UIView *line;

@end

@implementation FHOldHouseDetailRelatedSecondCell

+ (CGFloat)heightForData:(id)data {
    if (![data isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        return 0;
    }
    FHHouseSecondCardViewModel *viewModel = [[FHHouseSecondCardViewModel alloc] initWithModel:data];
    return [FHHouseSecondCardView calculateViewHeight:viewModel];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self setupConstraints];
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    }
    return self;
}

- (void)setupUI {
    self.cardView = [[FHHouseSecondCardView alloc] init];
    self.cardView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.cardView];
    
    self.line = [[UIView alloc] init];
    self.line.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:self.line];
}

- (void)setupConstraints {
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHSingleImageInfoCellModel class]]) {
        return;
    }
    FHSingleImageInfoCellModel *cellModel  = (FHSingleImageInfoCellModel *)data;
    FHSearchHouseDataItemsModel *model  = cellModel.secondModel;
    FHHouseSecondCardViewModel *viewModel = [[FHHouseSecondCardViewModel alloc] initWithModel:model];
    self.cardView.viewModel = viewModel;
}

@end

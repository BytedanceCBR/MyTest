//
//  FHNewHouseDetailNewHouseNewsCollectionCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/9/8.
//

#import "FHNewHouseDetailTimeLineCollectionCell.h"
#import "FHUtils.h"

@interface FHNewHouseDetailTimeLineCollectionCell()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIControl *contentBtn;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIView *leftGradientView;
@property (nonatomic, strong) UIView *rightGradientView;
@property (nonatomic, assign) NSInteger selectedRow;

@end

@implementation FHNewHouseDetailTimeLineCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNewHouseDetailTimeLineCellModel class]]) {
        return CGSizeMake(width, 133);
    }
    return CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        self.selectedRow = 0;
    }
    return self;
}

- (void)setupUI {
    self.containerView = [[UIView alloc] init];
    [self.contentView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];

    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.itemSize = CGSizeMake(99, 56);
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.containerView addSubview:self.collectionView];
    [self.collectionView registerClass:[FHNewHouseDetailTimeLineItemCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHNewHouseDetailTimeLineItemCollectionCell class])];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(56);
    }];

    self.leftGradientView = [[UIView alloc] init];
    [self.containerView addSubview:self.leftGradientView];
    [self.leftGradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(56);
        make.width.mas_equalTo(22);
    }];
    CAGradientLayer *leftGradientLayer = [CAGradientLayer layer];
    leftGradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0].CGColor, (__bridge id)[UIColor colorWithHexStr:@"#ffffff"].CGColor];
    leftGradientLayer.startPoint = CGPointMake(1, 0.5);
    leftGradientLayer.endPoint = CGPointMake(0, 0.5);
    leftGradientLayer.frame = CGRectMake(0, 0, 22, 56);
    [_leftGradientView.layer addSublayer:leftGradientLayer];
    
    self.rightGradientView = [[UIView alloc] init];
    [self.containerView addSubview:self.rightGradientView];
    [self.rightGradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(56);
        make.width.mas_equalTo(22);
    }];
    CAGradientLayer *rightGradientLayer = [CAGradientLayer layer];
    rightGradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0].CGColor, (__bridge id)[UIColor colorWithHexStr:@"#ffffff"].CGColor];
    rightGradientLayer.startPoint = CGPointMake(0, 0.5);
    rightGradientLayer.endPoint = CGPointMake(1, 0.5);
    rightGradientLayer.frame = CGRectMake(0, 0, 22, 56);
    [_rightGradientView.layer addSublayer:rightGradientLayer];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont themeFontRegular:16];
    self.contentLabel.numberOfLines = 2;
    [self.containerView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(12);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    self.contentBtn = [[UIControl alloc] init];
    [self.containerView addSubview:self.contentBtn];
    [self.contentBtn addTarget:self action:@selector(clickContent) forControlEvents:UIControlEventTouchUpInside];
    [self.contentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentLabel);
    }];
}

- (void)clickContent {
    if (self.clickContentBlock) {
        self.clickContentBlock();
    }
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailTimeLineCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNewDataTimelineModel *model = [(FHNewHouseDetailTimeLineCellModel *)data timeLineModel];
    if (model.list && model.list.count > 0) {
        self.contentLabel.hidden = NO;
        self.collectionView.hidden = NO;
        FHDetailNewDataTimelineListModel *item = model.list.firstObject;
        self.contentLabel.text = item.desc;
        [self.collectionView reloadData];
    } else {
        self.contentLabel.hidden = YES;
        self.collectionView.hidden = YES;
    }
    [self layoutIfNeeded];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [(FHNewHouseDetailTimeLineCellModel *)self.currentData timeLineModel].list.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHNewHouseDetailTimeLineCellModel *model = self.currentData;
    FHNewHouseDetailTimeLineItemCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHNewHouseDetailTimeLineItemCollectionCell class]) forIndexPath:indexPath];
    if (indexPath.row < model.timeLineModel.list.count) {
        if (indexPath.row == self.selectedRow) {
            [cell updateTitleColor:[UIColor themeOrange1] timeColor:[UIColor themeOrange1] dotColor:[UIColor themeOrange1] backgroundColor:[UIColor colorWithHexStr:@"#fefaf4"]];
        } else {
            [cell updateTitleColor:[UIColor themeGray1] timeColor:[UIColor themeGray3] dotColor:[UIColor themeGray2] backgroundColor:[UIColor themeGray7]];
        }
        bool isLast = NO;
        if (indexPath.row == model.timeLineModel.list.count - 1) {
            isLast = YES;
        }
        [cell refreshWithData:model.timeLineModel.list[indexPath.row] isLast:isLast];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FHDetailNewDataTimelineModel *model = [(FHNewHouseDetailTimeLineCellModel *)self.currentData timeLineModel];
    if (indexPath.row >= model.list.count) {
        return;
    }
    self.selectedRow = indexPath.row;
    if (self.selectedIndexChange) {
        self.selectedIndexChange(indexPath.row);
    }
    FHDetailNewDataTimelineListModel *item = model.list[indexPath.row];
    self.contentLabel.text = item.desc;
    [self.collectionView reloadData];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (NSString *)elementType
{
    return @"house_history";
}

@end

@interface FHNewHouseDetailTimeLineItemCollectionCell()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UIView *dotView;

@end

@implementation FHNewHouseDetailTimeLineItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.containerView = [[UIView alloc] init];
    self.containerView.layer.cornerRadius = 4;
    self.containerView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(84);
        make.height.mas_equalTo(52);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont themeFontMedium:16];
    self.titleLabel.textColor = [UIColor themeGray1];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.containerView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(6);
        make.height.mas_equalTo(22);
    }];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont themeFontRegular:12];
    self.timeLabel.textColor = [UIColor themeGray3];
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    [self.containerView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(1);
        make.height.mas_equalTo(17);
    }];
    
    self.bottomLineView = [[UIView alloc] init];
    self.bottomLineView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:self.bottomLineView];
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-4);
        make.height.mas_equalTo(1);
    }];
    
    self.dotView = [[UIView alloc] init];
    self.dotView.layer.cornerRadius = 3;
    self.dotView.backgroundColor = [UIColor themeGray2];
    [self.contentView addSubview:self.dotView];
    [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.height.width.mas_equalTo(6);
    }];
}

- (void)updateTitleColor:(UIColor *)titleColor timeColor:(UIColor *)timeColor dotColor:(UIColor *)dotColor backgroundColor:(UIColor *)backgroundColor {
    self.titleLabel.textColor = titleColor;
    self.timeLabel.textColor = timeColor;
    self.dotView.backgroundColor = dotColor;
    self.containerView.backgroundColor = backgroundColor;
}

- (void)refreshWithData:(id)data isLast:(bool)isLast {
    FHDetailNewDataTimelineListModel *item = (FHDetailNewDataTimelineListModel *)data;
    self.titleLabel.text = item.title;
    if (item.createdTime.length) {
        self.timeLabel.text = [FHUtils ConvertStrToTimeForm:item.createdTime];
    } else {
        self.timeLabel.text = @"未知";
    }
    if (isLast) {
        [self.bottomLineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-17);
        }];
    } else {
        [self.bottomLineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
        }];
    }
}

@end

@implementation FHNewHouseDetailTimeLineCellModel

@end

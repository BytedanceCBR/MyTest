//
//  FHNewHouseDetailNewHouseNewsCollectionCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/9/8.
//

#import "FHNewHouseDetailNewHouseNewsCollectionCell.h"
#import "FHUtils.h"

@interface FHNewHouseDetailNewHouseNewsCollectionCell()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIView *leftGradientView;
@property (nonatomic, strong) UIView *rightGradientView;
@property (nonatomic, assign) NSInteger selectedRow;

@end

@implementation FHNewHouseDetailNewHouseNewsCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNewHouseDetailNewHouseNewsCellModel class]]) {
        return CGSizeMake(width, 152);
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
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.containerView addSubview:self.collectionView];
    [self.collectionView registerClass:[FHNewHouseDetailNewHouseNewsItemCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHNewHouseDetailNewHouseNewsItemCollectionCell class])];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(16);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(56);
    }];

    self.leftGradientView = [[UIView alloc] init];
    [self.containerView addSubview:self.leftGradientView];
    [self.leftGradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(16);
        make.height.mas_equalTo(52);
        make.width.mas_equalTo(22);
    }];
    CAGradientLayer *leftGradientLayer = [CAGradientLayer layer];
    leftGradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0].CGColor, (__bridge id)[UIColor colorWithHexStr:@"#ffffff"].CGColor];
    leftGradientLayer.startPoint = CGPointMake(1, 0.5);
    leftGradientLayer.endPoint = CGPointMake(0, 0.5);
    leftGradientLayer.frame = CGRectMake(0, 0, 22, 52);
    [_leftGradientView.layer addSublayer:leftGradientLayer];
    
    self.rightGradientView = [[UIView alloc] init];
    [self.containerView addSubview:self.rightGradientView];
    [self.rightGradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(16);
        make.height.mas_equalTo(52);
        make.width.mas_equalTo(22);
    }];
    CAGradientLayer *rightGradientLayer = [CAGradientLayer layer];
    rightGradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0].CGColor, (__bridge id)[UIColor colorWithHexStr:@"#ffffff"].CGColor];
    rightGradientLayer.startPoint = CGPointMake(0, 0.5);
    rightGradientLayer.endPoint = CGPointMake(1, 0.5);
    rightGradientLayer.frame = CGRectMake(0, 0, 22, 52);
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
    
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailNewHouseNewsCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNewDataTimelineModel *model = [(FHNewHouseDetailNewHouseNewsCellModel *)data timeLineModel];
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
    return [(FHNewHouseDetailNewHouseNewsCellModel *)self.currentData timeLineModel].list.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHNewHouseDetailNewHouseNewsCellModel *model = self.currentData;
    FHNewHouseDetailNewHouseNewsItemCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHNewHouseDetailNewHouseNewsItemCollectionCell class]) forIndexPath:indexPath];
    if (indexPath.row < model.timeLineModel.list.count) {
        if (indexPath.row == self.selectedRow) {
            [cell updateTitleColor:[UIColor themeOrange1] timeColor:[UIColor themeOrange1] dotColor:[UIColor themeOrange1]];
        } else {
            [cell updateTitleColor:[UIColor themeGray1] timeColor:[UIColor themeGray3] dotColor:[UIColor themeGray2]];
        }
        [cell refreshWithData:model.timeLineModel.list[indexPath.row]];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FHDetailNewDataTimelineModel *model = [(FHNewHouseDetailNewHouseNewsCellModel *)self.currentData timeLineModel];
    if (indexPath.row >= model.list.count) {
        return;
    }
    self.selectedRow = indexPath.row;
    FHDetailNewDataTimelineListModel *item = model.list[indexPath.row];
    self.contentLabel.text = item.desc;
    [self.collectionView reloadData];
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

@end

@interface FHNewHouseDetailNewHouseNewsItemCollectionCell()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UIView *dotView;

@end

@implementation FHNewHouseDetailNewHouseNewsItemCollectionCell

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
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(7);
        make.right.mas_equalTo(-7);
        make.top.mas_equalTo(6);
        make.height.mas_equalTo(22);
    }];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont themeFontRegular:12];
    self.timeLabel.textColor = [UIColor themeGray3];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(7);
        make.right.mas_equalTo(-7);
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
    self.dotView.layer.cornerRadius = 4;
    self.dotView.backgroundColor = [UIColor themeGray2];
    [self.contentView addSubview:self.dotView];
    [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.height.width.mas_equalTo(8);
    }];
}

- (void)updateTitleColor:(UIColor *)titleColor timeColor:(UIColor *)timeColor dotColor:(UIColor *)dotColor {
    self.titleLabel.textColor = titleColor;
    self.timeLabel.textColor = timeColor;
    self.dotView.backgroundColor = dotColor;
}

- (void)refreshWithData:(id)data {
    FHDetailNewDataTimelineListModel *item = (FHDetailNewDataTimelineListModel *)data;
    self.titleLabel.text = item.title;
    if (item.createdTime.length) {
        self.timeLabel.text = [FHUtils ConvertStrToTimeForm:item.createdTime];
    } else {
        self.timeLabel.text = @"未知";
    }
}

@end

@implementation FHNewHouseDetailNewHouseNewsCellModel

@end

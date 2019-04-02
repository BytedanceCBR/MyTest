//
//  FHCityMarketTrendChatView.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import "FHCityMarketTrendChatView.h"
#import <PNChart.h>
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "RXCollection.h"
#import "ReactiveObjC.h"
#import "extobjc.h"

@implementation FHCityMarketTrendChatViewInfoItem

@end

@interface LineLabelItem : UIView
@property (nonatomic, strong) UIView* dotIconView;
@property (nonatomic, strong) UILabel* nameLabel;
@end

@implementation LineLabelItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.dotIconView = [[UIView alloc] init];
    _dotIconView.layer.cornerRadius = 4;
    [self addSubview:_dotIconView];
    [_dotIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(8);
        make.left.mas_equalTo(5);
        make.centerY.mas_equalTo(self);
    }];

    self.nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont themeFontRegular:14];
    _nameLabel.textColor = [UIColor themeGray1];
    [self addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_dotIconView.mas_left).mas_offset(10);
        make.top.bottom.mas_equalTo(self);
        make.height.mas_equalTo(18);
        make.right.mas_equalTo(self);
    }];
}

@end

@interface FHCityMarketTrendChatViewInfoBanner ()
@property (nonatomic, strong) NSArray<LineLabelItem*>* itemViews;
@end

@implementation FHCityMarketTrendChatViewInfoBanner

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.unitLabel = [[UILabel alloc] init];
    _unitLabel.font = [UIFont themeFontRegular:14];
    _unitLabel.textColor = [UIColor themeGray3];
    [self addSubview:_unitLabel];
    [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.bottom.mas_equalTo(self);
        make.height.mas_offset(20);
    }];
    @weakify(self);
    [RACObserve(self, items) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self resetItems:x];
    }];
}

-(void)resetItems:(NSArray<FHCityMarketTrendChatViewInfoItem*>*)items {
    [_itemViews enumerateObjectsUsingBlock:^(LineLabelItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    _itemViews = [items rx_mapWithBlock:^id(id each) {
        FHCityMarketTrendChatViewInfoItem* it = each;
        LineLabelItem* itemView = [[LineLabelItem alloc] init];
        itemView.nameLabel.text = it.name;
        itemView.dotIconView.backgroundColor = [UIColor colorWithHexString:it.color];
        return itemView;
    }];
    [_itemViews enumerateObjectsUsingBlock:^(LineLabelItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSubview:obj];
    }];

    __block UIView* currentView = nil;
    [_itemViews enumerateObjectsUsingBlock:^(LineLabelItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            if (currentView == nil) {
                make.right.mas_equalTo(self).mas_offset(-20);
            } else {
                make.right.mas_equalTo(currentView.mas_left).mas_offset(-20);
            }
            make.centerY.mas_equalTo(self);
//            if (idx == [itemViews count] - 1) {
//                make.left.mas_greaterThanOrEqualTo(_unitLabel.mas_right);
//            }
        }];
        currentView = obj;
    }];
}


@end

@interface FHCityMarketSelectItemCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) UILabel* nameLabel;
@property (nonatomic, assign, setter=setItemSelected:) BOOL isSelected;
-(void)setItemSelected:(BOOL)isSelected;
@end

@implementation FHCityMarketSelectItemCollectionViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.contentView.layer.cornerRadius = 4;
    _nameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel setTextAlignment:NSTextAlignmentCenter];
    [_nameLabel setFont:[UIFont themeFontRegular:12]];
    [_nameLabel setTextColor:HEXRGBA(@"333333")];
    [_nameLabel setHighlightedTextColor:HEXRGBA(@"ffffff")];
    _nameLabel.adjustsFontSizeToFitWidth = true;
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
//        make.width.mas_greaterThanOrEqualTo(65);
    }];
    [self configSelectedStyle:NO];
}

-(void)configSelectedStyle:(BOOL)isSelected {
    if (isSelected) {
        _nameLabel.textColor = HEXRGBA(@"ffffff");
        self.contentView.backgroundColor = HEXRGBA(@"ff5869");
    } else {
        _nameLabel.textColor = HEXRGBA(@"333333");
        self.contentView.backgroundColor = HEXRGBA(@"f4f5f6");
    }
}

-(void)setItemSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    [self configSelectedStyle:_isSelected];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _isSelected = false;
    self.contentView.layer.masksToBounds = false;
    self.contentView.layer.borderColor = [HEXRGBA(@"f4f5f6") CGColor];
}
@end


@interface FHCityMarketTrendChatView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView* selectorCollectionView;
@end

@implementation FHCityMarketTrendChatView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)initUI {
    self.titleLable = [[UILabel alloc] init];
    _titleLable.font = [UIFont themeFontSemibold:18];
    _titleLable.textColor = [UIColor themeGray1];
    [self addSubview:_titleLable];
    [_titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(30);
        make.height.mas_equalTo(25);
    }];

    [self setupCollectionView];

    self.banner = [[FHCityMarketTrendChatViewInfoBanner alloc] init];
    [self addSubview:_banner];
    [_banner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(_selectorCollectionView.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(20);
    }];

    [self setupChartView];

    self.sourceLabel = [[UILabel alloc] init];
    _sourceLabel.font = [UIFont themeFontRegular:11];
    _sourceLabel.textColor = [UIColor themeGray1];
    _sourceLabel.alpha = 0.5;
    [self addSubview:_sourceLabel];
    [_sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.lineChart.mas_bottom).mas_offset(13);
        make.height.mas_equalTo(16);
        make.bottom.mas_equalTo(self);
    }];
//    @weakify(self);
//    [RACObserve(self, categorys) subscribeNext:^(id  _Nullable x) {
//        @strongify(self);
//        [_selectorCollectionView reloadData];
//    }];

}

- (void)setCategorys:(NSArray<NSString *> *)categorys {
    [self willChangeValueForKey:@"categorys"];
    _categorys = categorys;
    [_selectorCollectionView reloadData];
    [self didChangeValueForKey:@"categorys"];
}

-(void)setupCollectionView {
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.selectorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_selectorCollectionView registerClass:[FHCityMarketSelectItemCollectionViewCell class] forCellWithReuseIdentifier:@"item"];
    [self addSubview:_selectorCollectionView];
    [_selectorCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLable.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(28);
        make.left.right.mas_equalTo(self);
    }];
    _selectorCollectionView.showsHorizontalScrollIndicator = NO;
    _selectorCollectionView.backgroundColor = [UIColor whiteColor];
    _selectorCollectionView.dataSource = self;
    _selectorCollectionView.delegate = self;
    _selectorCollectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 0);
}

-(void)resetChatView {
    [_lineChart removeFromSuperview];
    [self setupChartView];
}

-(void)setupChartView {
    self.lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 207.0)];
    self.lineChart.yLabelNum = 4; // 4 lines
    self.lineChart.chartMarginLeft = 20;
    self.lineChart.chartMarginRight = 20;
    self.lineChart.backgroundColor = [UIColor whiteColor];
    self.lineChart.yGridLinesColor = [UIColor themeGray6];
    self.lineChart.showYGridLines = YES; // 横着的虚线
    [self.lineChart.chartData enumerateObjectsUsingBlock:^(PNLineChartData *obj, NSUInteger idx, BOOL *stop) {
        obj.pointLabelColor = [UIColor blackColor];
    }];
    self.lineChart.showCoordinateAxis = YES;// 坐标轴的线
    self.lineChart.yLabelColor = [UIColor themeGray3];
    self.lineChart.yLabelFormat = @"%.2f";
    self.lineChart.yLabelFont = [UIFont themeFontRegular:12];
    self.lineChart.yLabelHeight = 17;
    self.lineChart.showGenYLabels = YES; // 竖轴的label值
    self.lineChart.xLabelColor = [UIColor themeGray3];
    self.lineChart.xLabelFont = [UIFont themeFontRegular:12];
    self.lineChart.yHighlightedColor = [UIColor themeRed1];
    self.lineChart.axisColor = [UIColor themeGray6]; // x轴和y轴
    [self.lineChart setXLabels:@[@"", @"", @"", @"", @"", @""]];
    [self addSubview:_lineChart];
    [_lineChart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(self.banner.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(207);
    }];
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_categorys count] > indexPath.row) {
        self.selectCategory = _categorys[indexPath.row];
    }
    [_selectorCollectionView reloadData];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_categorys count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHCityMarketSelectItemCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    cell.nameLabel.text = _categorys[indexPath.row];
    if ([_categorys[indexPath.row] isEqualToString:_selectCategory]) {
        [cell setItemSelected:YES];
    } else {
        [cell setItemSelected:NO];
    }
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* content = _categorys[indexPath.row];
    UIFont* font = [UIFont themeFontRegular:12];
    CGSize titleSize = [content sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
    return CGSizeMake(titleSize.width + 20, 28);
}

@end

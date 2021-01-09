//
//  FHNewHouseDetailMultiFloorpanCollectionCell.m
//  Pods
//
//  Created by bytedance on 2020/9/7.
//

#import "FHNewHouseDetailMultiFloorpanCollectionCell.h"
#import "FHDetailHeaderView.h"
#import <FHHouseBase/FHHouseIMClueHelper.h>
#import <BDWebImage/BDWebImage.h>
#import "FHDetailTagBackgroundView.h"
#import <ByteDanceKit/ByteDanceKit.h>
// 楼盘item
@interface FHDetailNewMutiFloorPanCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong)   UIView        *iconView;
@property (nonatomic, strong)   UIImageView   *icon;
@property (nonatomic, strong)   UILabel       *titleLabel;
@property (nonatomic, strong)   FHDetailTagBackgroundView        *tagBacView;
@property (nonatomic, strong)   UILabel       *priceLabel;
@property (nonatomic, strong)   UILabel       *spaceLabel;
@property (nonatomic, strong)   UIButton      *consultDetailButton;
@property (nonatomic, strong)   UIImageView        *vrImageView;

@end

@implementation FHDetailNewMutiFloorPanCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNewDataFloorpanListListModel *model = (FHDetailNewDataFloorpanListListModel *)data;
    [self.tagBacView removeAllTag];
    if (model) {
        if (model.images.count > 0) {
            FHImageModel *imageModel = model.images.firstObject;
            NSString *urlStr = imageModel.url;
            if ([urlStr length] > 0) {
                __weak typeof(self) weakSelf = self;
//                [self.icon bd_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:@"detail_new_floorpan_default"]];
                [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:urlStr] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (!error && image) {
                        strongSelf.icon.image = image;
                        strongSelf.icon.contentMode = UIViewContentModeScaleAspectFit;
                    }
                }];
            }
        }
        self.consultDetailButton.hidden = model.imOpenUrl.length > 0 ? NO : YES;
//        self.spaceLabel.text = [NSString stringWithFormat:@"%@ %@",model.squaremeter,model.facingDirection];
        
//        NSMutableArray *tagArr = [NSMutableArray array];
//        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",model.title,model.squaremeter];;
        self.titleLabel.text = model.title;
        self.spaceLabel.text = model.squaremeter;
        
        self.priceLabel.text = model.pricing;
        [self.priceLabel sizeToFit];
        CGSize itemSize = [self.priceLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIFont themeFontSemibold:16].lineHeight)];
        CGFloat width = itemSize.width;
        
//        [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(width);
//        }];
        //1.0.2 需求缩小户型图大小，横屏查看2.5个左右，不能显示更多tag
        [self.tagBacView refreshWithTags:model.tags withNum:model.tags.count withMaxLen:120 - width - 4];
        if (model.vrInfo.hasVr) {
            self.vrImageView.hidden = NO;
        } else {
            self.vrImageView.hidden = YES;
        }
    }
    [self layoutIfNeeded];
}

- (void)setupUI {
    
    _iconView = [[UIView alloc]init];
    _iconView.layer.borderWidth = [UIDevice btd_onePixel];
    _iconView.layer.borderColor = [[UIColor themeGray6] CGColor];
    _iconView.layer.cornerRadius = 1.0;
    _iconView.layer.masksToBounds = YES;
    self.iconView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.right.equalTo(self.contentView);
        make.width.height.mas_equalTo(120);
    }];
    
    _icon = [[UIImageView alloc] init];
    _icon.image = [UIImage imageNamed:@"detail_new_floorpan_default"];
    [_iconView addSubview:_icon];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.iconView);
        make.width.height.equalTo(self.iconView);
    }];
    
    _vrImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_vr_movie_icon"]];
    _vrImageView.hidden = YES;
    [self.iconView addSubview:_vrImageView];
    [self.vrImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(6);
        make.bottom.mas_equalTo(-6);
        make.width.height.mas_equalTo(22);
    }];
    
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont themeFontMedium:14];
    self.titleLabel.textColor = [UIColor themeGray1];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconView.mas_bottom).mas_offset(8);
        make.left.equalTo(self.contentView);
        make.height.mas_equalTo(19);
//        make.width.mas_equalTo(0);
    }];
    
    _spaceLabel = [[UILabel alloc] init];;
    _spaceLabel.font = [UIFont themeFontMedium:14];
    _spaceLabel.textColor = [UIColor themeGray1];
    [_spaceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:_spaceLabel];
    
    [self.spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_top);
        make.left.equalTo(self.titleLabel.mas_right).mas_offset(2);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(self.titleLabel.mas_height);
    }];
    
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.textColor = [UIColor themeOrange1];
    _priceLabel.font = [UIFont themeFontRegular:14];
    [self addSubview:_priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6);
        make.left.equalTo(self.contentView);
        make.height.mas_equalTo(16);
    }];
    
    _tagBacView = [[FHDetailTagBackgroundView alloc] initWithLabelHeight:16.0 withCornerRadius:2.0];
    [_tagBacView setMarginWithTagMargin:4.0 withInsideMargin:4.0];
    _tagBacView.textFont = [UIFont themeFontMedium:10.0];
    [self addSubview:_tagBacView];
    [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.priceLabel.mas_right).offset(4);
        make.right.mas_equalTo(self.iconView);
        make.centerY.mas_equalTo(self.priceLabel);
        make.height.mas_equalTo(16);
    }];
    
    _consultDetailButton = [[UIButton alloc] init];
    [_consultDetailButton setTitle:@"咨询户型" forState:UIControlStateNormal];
    [_consultDetailButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    _consultDetailButton.titleLabel.font = [UIFont themeFontMedium:14];
    _consultDetailButton.backgroundColor = [UIColor colorWithHexString:@"#f7f7f7"];
    _consultDetailButton.layer.masksToBounds = YES;
    _consultDetailButton.layer.cornerRadius = 1;
    [_consultDetailButton addTarget:self action:@selector(consultDetailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_consultDetailButton];
    _consultDetailButton.hidden = YES;
    [self.consultDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.priceLabel.mas_bottom).offset(12);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(32);
    }];
}

- (void)consultDetailButtonAction:(UIButton *)sender {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickCellItem:onCell:)]) {
        [self.delegate clickCellItem:sender onCell:self];
    }
}
@end

@interface FHNewHouseDetailMultiFloorpanCollectionCell ()<UICollectionViewDelegate,UICollectionViewDataSource,FHDetailBaseCollectionCellDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@end

@implementation FHNewHouseDetailMultiFloorpanCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNewHouseDetailMultiFloorpanCellModel class]]) {
        CGFloat height = 120 + 60;
        FHNewHouseDetailMultiFloorpanCellModel *model = (FHNewHouseDetailMultiFloorpanCellModel *)data;
        BOOL hasIM = NO;
        for (NSInteger i = 0; i < model.floorPanList.list.count; i++) {
            FHDetailNewDataFloorpanListListModel *listItemModel = model.floorPanList.list[i];
            listItemModel.index = i;
            if (listItemModel.imOpenUrl.length > 0) {
                hasIM = YES;
                break;
            }
        }
        if (hasIM) {
            height += 44;
        }
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"house_model";
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        self.flowLayout.itemSize = CGSizeMake(120, 120 + 105);
        self.flowLayout.minimumLineSpacing = 12;
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds)) collectionViewLayout:self.flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.contentView addSubview:self.collectionView];
        [self.collectionView registerClass:[FHDetailNewMutiFloorPanCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHDetailNewMutiFloorPanCollectionCell class])];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.right.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(0);
        }];
        
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailMultiFloorpanCellModel class]]) {
        return;
    }
    self.currentData = data;
    
    FHNewHouseDetailMultiFloorpanCellModel *currentModel = (FHNewHouseDetailMultiFloorpanCellModel *)data;

    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;
    if (model.list) {
        BOOL hasIM = NO;
        for (NSInteger i = 0; i < model.list.count; i++) {
            FHDetailNewDataFloorpanListListModel *listItemModel = model.list[i];
            listItemModel.index = i;
            if (listItemModel.imOpenUrl.length > 0) {
                hasIM = YES;
            }
        }

        CGFloat itemHeight = 190;
        if (hasIM) {
            itemHeight = 190 + 30;
        }
        self.flowLayout.itemSize = CGSizeMake(120, itemHeight);
        
        [self.collectionView reloadData];
    }
    
    [self layoutIfNeeded];
}

- (void)clickCellItem:(UIView *)itemView onCell:(FHDetailBaseCollectionCell*)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if(self.imItemClick) {
        self.imItemClick(indexPath.row);
    }
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [(FHNewHouseDetailMultiFloorpanCellModel *)self.currentData floorPanList].list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHNewHouseDetailMultiFloorpanCellModel *model = (FHNewHouseDetailMultiFloorpanCellModel *)self.currentData;
    FHDetailNewMutiFloorPanCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHDetailNewMutiFloorPanCollectionCell class]) forIndexPath:indexPath];
    if (indexPath.row < model.floorPanList.list.count) {
        [cell refreshWithData:model.floorPanList.list[indexPath.row]];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.didSelectItem) {
        self.didSelectItem(indexPath.row);
    }
}

// 不重复调用

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.willShowItem) {
        self.willShowItem(indexPath);
    }
}

- (NSString *)elementType {
    return @"house_model";
}
@end

@implementation FHNewHouseDetailMultiFloorpanCellModel

@end

//
//  FHDetailNewMutiFloorPanCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHDetailNewMutiFloorPanCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import "FHDetailHeaderView.h"
#import "FHDetailMultitemCollectionView.h"

@interface FHDetailNewMutiFloorPanCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;

@end

@implementation FHDetailNewMutiFloorPanCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHDetailNewDataFloorpanListModel *model = (FHDetailNewDataFloorpanListModel *)data;
    if (model.list) {
        self.headerView.label.text = @"楼盘户型";
        self.headerView.isShowLoadMore = model.hasMore;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        flowLayout.itemSize = CGSizeMake(156, 170);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHDetailNewMutiFloorPanCollectionCell class]);
        FHDetailMultitemCollectionView *colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:170 cellIdentifier:identifier cellCls:[FHDetailNewMutiFloorPanCollectionCell class] datas:model.list];
        [self.containerView addSubview:colView];
        __weak typeof(self) wSelf = self;
        colView.clickBlk = ^(NSInteger index) {
            [wSelf collectionCellClick:index];
        };
        [colView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
            make.left.right.mas_equalTo(self.containerView);
            make.bottom.mas_equalTo(self.containerView);
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

- (void)setupUI {
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"楼盘户型";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];
    [self.headerView addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).offset(-20);
    }];
}

// 查看更多
- (void)moreButtonClick:(UIButton *)button {
    
    if ([self.currentData isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
        TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:@{@"floorlist":((FHDetailNewDataFloorpanListModel *)self.currentData).list}];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_pan_list"] userInfo:info];
    }

}
// cell 点击
- (void)collectionCellClick:(NSInteger)index {
//    FHDetailRelatedNeighborhoodModel *model = (FHDetailRelatedNeighborhoodModel *)self.currentData;
//    if (model.relatedNeighborhoodData && model.relatedNeighborhoodData.items.count > 0 && index >= 0 && index < model.relatedNeighborhoodData.items.count) {
//        // 点击cell处理
//        FHDetailRelatedNeighborhoodResponseDataItemsModel *itemModel = model.relatedNeighborhoodData.items[index];
//
//    }
}

@end

@interface FHDetailNewMutiFloorPanCollectionCell ()

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
    if (model) {
        if (model.images.count > 0) {
            FHDetailNewDataFloorpanListListImagesModel *imageModel = model.images.firstObject;
            NSString *urlStr = imageModel.url;
            if ([urlStr length] > 0) {
                [self.icon bd_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:@"default_image"]];
            } else {
                self.icon.image = [UIImage imageNamed:@"default_image"];
            }
        } else {
            self.icon.image = [UIImage imageNamed:@"default_image"];
        }
        
        NSMutableAttributedString *textAttrStr = [NSMutableAttributedString new];
        NSMutableAttributedString *titleAttrStr = [[NSMutableAttributedString alloc] initWithString:model.title ? [NSString stringWithFormat:@"%@ ",model.title] : @""];
        NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont themeFontRegular:16],NSFontAttributeName,
                                         [UIColor themeBlue1],NSForegroundColorAttributeName,nil];
        [titleAttrStr addAttributes:attributeSelect range:NSMakeRange(0, titleAttrStr.length)];
        
        [textAttrStr appendAttributedString:titleAttrStr];
        
        if (model.saleStatus) {
            
            NSMutableAttributedString *tagStr = [[NSMutableAttributedString alloc] initWithString:model.saleStatus.content ? [NSString stringWithFormat:@" %@ ",model.saleStatus.content]: @""];
                NSDictionary *attributeTag = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIFont themeFontRegular:12],NSFontAttributeName,@(2),NSBaselineOffsetAttributeName,
                                                 model.saleStatus.textColor ? [UIColor colorWithHexString:model.saleStatus.textColor] : [UIColor whiteColor],NSForegroundColorAttributeName,model.saleStatus.textColor ? [UIColor colorWithHexString:model.saleStatus.backgroundColor] : [UIColor themeGray2],NSBackgroundColorAttributeName,nil];
       
            [tagStr addAttributes:attributeTag range:NSMakeRange(0, tagStr.length)];
          
            [textAttrStr appendAttributedString:tagStr];
            
        }
        self.descLabel.attributedText = textAttrStr;
        self.priceLabel.text = model.pricingPerSqm;
        self.spaceLabel.text = [NSString stringWithFormat:@"建面 %@",model.squaremeter];;
    }
    [self layoutIfNeeded];
}

- (void)setupUI {
    _icon = [[UIImageView alloc] init];
    _icon.layer.cornerRadius = 4.0;
    _icon.layer.masksToBounds = YES;
    _icon.layer.borderWidth = 0.5;
    _icon.layer.borderColor = [[UIColor colorWithHexString:@"#e8eaeb"] CGColor];
    [self addSubview:_icon];
    
    _descLabel = [UILabel createLabel:@"" textColor:@"#081f33" fontSize:16];
    [self addSubview:_descLabel];
    
    _priceLabel = [UILabel createLabel:@"" textColor:@"#f85959" fontSize:16];
    [self addSubview:_priceLabel];
    
    _spaceLabel = [UILabel createLabel:@"" textColor:@"#ffffff" fontSize:12];
    _spaceLabel.textColor = [UIColor themeGray2];
    [self addSubview:_spaceLabel];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.width.mas_equalTo(156);
        make.height.mas_equalTo(116);
        make.top.mas_equalTo(self);
    }];
    
    UIColor *topColor = RGBA(255, 255, 255, 0);
    UIColor *bottomColor = RGBA(0, 0, 0, 0.5);
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)(topColor.CGColor), (id)(bottomColor.CGColor), nil];
    NSArray *gradientLocations = @[@(0),@(1)];
    CAGradientLayer *gradientlayer = [[CAGradientLayer alloc] init];
    gradientlayer.colors = gradientColors;
    gradientlayer.locations = gradientLocations;
    gradientlayer.frame = CGRectMake(0, 0, 156, 120);
    gradientlayer.cornerRadius = 4.0;
    [self.icon.layer addSublayer:gradientlayer];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.icon.mas_bottom).offset(10);
    }];
    
    
    [self.priceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.priceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(3);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.priceLabel.mas_right).offset(6);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(22);
        make.centerY.equalTo(self.priceLabel.mas_centerY);
        make.bottom.equalTo(self);
    }];
}

@end


//
//  FHDetailAveragePriceComparisonCell.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/4/9.
//

#import "FHDetailAveragePriceComparisonCell.h"
#import "UILabel+House.h"
#import "FHDetailHeaderView.h"
#import "TTRoute.h"
#import "FHUserTracker.h"

@interface FHDetailAveragePriceComparisonCell()

@property(nonatomic, strong) FHDetailHeaderView *headerView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIImageView *bgView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property(nonatomic, strong) UIImageView *lineView;
@property(nonatomic, strong) UIImageView *leftPointView;
@property(nonatomic, strong) UIImageView *rightPointView;
@property(nonatomic, strong) UIImageView *currentPointView;
@property(nonatomic, strong) UILabel *minLabel;
@property(nonatomic, strong) UILabel *maxLabel;
@property(nonatomic, strong) UILabel *curPriceLabel;
@property(nonatomic, strong) UILabel *curDescLabel;
@property(nonatomic, strong) UIImageView *tipView;

@end

@implementation FHDetailAveragePriceComparisonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"price_analysis";
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailAveragePriceComparisonModel class]]) {
        return;
    }
    self.currentData = data;
    
    FHDetailAveragePriceComparisonModel *model = (FHDetailAveragePriceComparisonModel *)data;
    self.shadowImage.image = model.shadowImage;
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    NSString *curPrice = [NSString stringWithFormat:@"%0.0f",[model.rangeModel.curPricePsm floatValue]];
    NSString *minPrice = [NSString stringWithFormat:@"%0.0f",[model.rangeModel.minPricePsm floatValue]];
    NSString *maxPrice = [NSString stringWithFormat:@"%0.0f",[model.rangeModel.maxPricePsm floatValue]];
    NSString *unit = model.rangeModel.unit ?: @"";
    
    NSString *minPriceStr = [NSString stringWithFormat:@"%@%@",minPrice,unit];
    NSString *maxPriceStr = [NSString stringWithFormat:@"%@%@",maxPrice,unit];
    NSString *curPriceStr = [NSString stringWithFormat:@"%@%@",curPrice,unit];
    
    self.headerView.label.text = model.rangeModel.title;
    self.minLabel.attributedText = [self getAtributeStr:@"最低参考价 " content:minPriceStr];
    self.maxLabel.attributedText = [self getAtributeStr:@"最高参考价 " content:maxPriceStr];
    self.curPriceLabel.text = curPriceStr;
    [self updateCurPricePosition:[curPrice floatValue] minPrice:[minPrice floatValue] maxPrice:[maxPrice floatValue]];
}

- (NSAttributedString *)getAtributeStr:(NSString *)title content:(NSString *)content {
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:title];
    if(content){
        NSAttributedString *contentAstr = [[NSAttributedString alloc] initWithString:content attributes:@{NSForegroundColorAttributeName:[UIColor themeGray1]}];
        [aStr appendAttributedString:contentAstr];
    }
    return aStr;
}

- (void)updateCurPricePosition:(CGFloat)curPrice minPrice:(CGFloat)minPrice maxPrice:(CGFloat)maxPrice {
    if(curPrice >= minPrice && curPrice <= maxPrice && minPrice < maxPrice){
        CGFloat diff = (curPrice - minPrice)/(maxPrice - minPrice);
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 150) * diff;
        [_currentPointView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.leftPointView).offset(width);
        }];
        self.tipView.hidden = NO;
        self.currentPointView.hidden = NO;
    }
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

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)setupUI {
    
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-14);
        make.bottom.equalTo(self.contentView).offset(14);
    }];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.isShowLoadMore = YES;
    _headerView.loadMore.text = @"";
    _headerView.label.font = [UIFont themeFontMedium:18];
    [_headerView addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(-8);
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(46);
    }];
    
    _containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.bottom.mas_equalTo(self.shadowImage).offset(-40);
    }];
    
    _bgView = [[UIImageView alloc] init];
    _bgView.image = [UIImage imageNamed:@"old_detail_price_bg"];
    [self.containerView addSubview:_bgView];
    
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(20);
        make.left.mas_equalTo(self.containerView).offset(60);
        make.right.mas_equalTo(self.containerView).offset(-60);
        make.height.mas_equalTo(80);
    }];
    
    _lineView = [[UIImageView alloc] init];
    _lineView.image = [UIImage imageNamed:@"old_detail_price_line"];
    [self.containerView addSubview:_lineView];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_bottom);
        make.left.mas_equalTo(self.containerView).offset(20);
        make.right.mas_equalTo(self.containerView).offset(-20);
        make.height.mas_equalTo(2);
    }];
    
    _leftPointView = [[UIImageView alloc] init];
    _leftPointView.image = [UIImage imageNamed:@"old_detail_price_point"];
    [self.containerView addSubview:_leftPointView];
    
    [_leftPointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.lineView);
        make.left.mas_equalTo(self.bgView).offset(-4);
        make.width.height.mas_equalTo(8);
    }];
    
    _rightPointView = [[UIImageView alloc] init];
    _rightPointView.image = [UIImage imageNamed:@"old_detail_price_point"];
    [self.containerView addSubview:_rightPointView];
    
    [_rightPointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.lineView);
        make.right.mas_equalTo(self.bgView).offset(4);
        make.width.height.mas_equalTo(8);
    }];
    
    _currentPointView = [[UIImageView alloc] init];
    _currentPointView.image = [UIImage imageNamed:@"old_detail_price_point_big"];
    _currentPointView.hidden = YES;
    [self.containerView addSubview:_currentPointView];
    
    [_currentPointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.lineView);
        make.centerX.mas_equalTo(self.leftPointView);
        make.width.height.mas_equalTo(20);
    }];

    _minLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _minLabel.textColor = [UIColor themeGray3];
    _minLabel.font = [UIFont themeFontRegular:12];
    [self.containerView addSubview:_minLabel];
    
    [self.minLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(16);
        make.left.mas_equalTo(self.lineView);
        make.height.mas_equalTo(16);
    }];
    
    _maxLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _maxLabel.textColor = [UIColor themeGray3];
    _maxLabel.font = [UIFont themeFontRegular:12];
    [self.containerView addSubview:_maxLabel];

    [self.maxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(16);
        make.right.mas_equalTo(self.lineView);
        make.height.mas_equalTo(16);
        make.bottom.mas_equalTo(self.containerView.mas_bottom);
    }];
    
    _tipView = [[UIImageView alloc] init];
    _tipView.image = [UIImage imageNamed:@"old_detail_price_tip_bg"];
    _tipView.contentMode = UIViewContentModeScaleAspectFit;
    _tipView.hidden = YES;
    [self.containerView addSubview:_tipView];
    
    [_tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.currentPointView.mas_top).offset(20);
        make.centerX.mas_equalTo(self.currentPointView);
        make.width.mas_equalTo(128);
        make.height.mas_equalTo(92);
    }];
    
    _curPriceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _curPriceLabel.textColor = [UIColor themeGray1];
//    _curPriceLabel.textAlignment = NSTextAlignmentCenter;
    _curPriceLabel.font = [UIFont themeFontMedium:12];
    [self.tipView addSubview:_curPriceLabel];
    
    [self.curPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipView).offset(25);
//        make.left.mas_equalTo(self.tipView).offset(13);
//        make.right.mas_equalTo(self.tipView).offset(-13);
        make.centerX.mas_equalTo(self.tipView);
        make.width.mas_lessThanOrEqualTo(80);
        make.height.mas_equalTo(17);
    }];
    
    _curDescLabel = [UILabel createLabel:@"本房源单价" textColor:@"" fontSize:11];
    _curDescLabel.textColor = [UIColor themeGray3];
//    _curDescLabel.textAlignment = NSTextAlignmentCenter;
    _curDescLabel.font = [UIFont themeFontRegular:11];
    [self.tipView addSubview:_curDescLabel];
    
    [self.curDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.curPriceLabel.mas_bottom);
//        make.left.mas_equalTo(self.tipView).offset(13);
//        make.right.mas_equalTo(self.tipView).offset(-13);
        make.left.mas_equalTo(self.curPriceLabel);
        make.width.mas_lessThanOrEqualTo(64);
        make.height.mas_equalTo(16);
    }];
}

// 查看更多
- (void)moreButtonClick:(UIButton *)button {
    
    [self addClickLoadMoreTracer];
    
    FHDetailAveragePriceComparisonModel *model = (FHDetailAveragePriceComparisonModel *)self.currentData;
    
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    tracerDic[@"element_from"] = [self elementTypeString:FHHouseTypeSecondHandHouse];
    
    NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
//    userDic[@"neighborhood_id"] = model.neighborhoodId;
//    userDic[@"neighborhood_name"] = model.neighborhoodName;
//    userDic[@"houseRoomType"] = model.analyzeModel.houseType;
    userDic[@"tracer"] = tracerDic;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userDic];
//    NSString * urlStr = [NSString stringWithFormat:@"sslocal://old_price_comparison_list"];
    NSString * urlStr = model.rangeModel.sameNeighborhoodRoomsSchema;

    NSURL *url = [NSURL URLWithString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)addClickLoadMoreTracer {
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    tracer[@"page_type"] = tracerDic[@"page_type"];
    tracer[@"element_from"] = [self elementTypeString:FHHouseTypeSecondHandHouse];
   
    TRACK_EVENT(@"click_loadmore", tracer);
}

@end

// FHDetailAveragePriceComparisonModel
@implementation FHDetailAveragePriceComparisonModel

@end

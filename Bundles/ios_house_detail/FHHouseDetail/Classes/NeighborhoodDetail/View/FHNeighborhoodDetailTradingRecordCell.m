//
//  FHNeighborhoodDetailTradingRecordCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/12/10.
//

#import "FHNeighborhoodDetailTradingRecordCell.h"

@interface FHNeighborhoodDetailTradingRecordCell ()
@property (nonatomic, strong) UIView *sepLine;
@property (nonatomic, strong) UIView *midLine;
@property (nonatomic, strong) UILabel *soldTitleLab;
@property (nonatomic, strong) UILabel *onSaleTitleLab;
@property (nonatomic, strong) UILabel *soldValue;
@property (nonatomic, strong) UILabel *onSaleValue;
@property (nonatomic, strong) UILabel *soldUnit;
@property (nonatomic, strong) UILabel *onSaleUnit;
@property (nonatomic, strong) UIImageView *arrowOnSaleImageView;
@property (nonatomic, strong) UIImageView *arrowSoldImageView;
@end

@implementation FHNeighborhoodDetailTradingRecordCell


- (UIView *)midLine{
    if(!_midLine){
        UIView *midLine = [[UIView alloc] init];
        midLine.backgroundColor = [UIColor themeGray6];
        [self addSubview:midLine];
        _midLine = midLine;
    }
    return _midLine;
}

- (UIView *)sepLine{
    if(!_sepLine){
        UIView *sepLine = [[UIView alloc] init];
        sepLine.backgroundColor = [UIColor themeGray6];
        [self addSubview:sepLine];
        _sepLine = sepLine;
    }
    return _sepLine;
}

- (UIImageView *)arrowOnSaleImageView{
    if(!_arrowOnSaleImageView){
        UIImageView *iamgeView = [[UIImageView alloc]init];
        iamgeView.image = [UIImage imageNamed:@"arrow_right"];
        _arrowOnSaleImageView = iamgeView;
        [self.contentView addSubview:_arrowOnSaleImageView];
    }
    return _arrowOnSaleImageView;
}

- (UIImageView *)arrowSoldImageView{
    if(!_arrowSoldImageView){
        UIImageView *iamgeView = [[UIImageView alloc]init];
        iamgeView.image = [UIImage imageNamed:@"arrow_right"];
        _arrowSoldImageView = iamgeView;
        [self.contentView addSubview:_arrowSoldImageView];
    }
    return _arrowSoldImageView;
}

- (UILabel *)onSaleUnit{
    if(!_onSaleUnit){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:soldTitleLab];
        _onSaleUnit = soldTitleLab;
    }
    return _onSaleUnit;
}

- (UILabel *)soldUnit{
    if(!_soldUnit){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:soldTitleLab];
        _soldUnit = soldTitleLab;
    }
    return _soldUnit;
}

- (UILabel *)onSaleValue{
    if(!_onSaleValue){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontMedium:20];
        [self.contentView addSubview:soldTitleLab];
        _onSaleValue = soldTitleLab;
    }
    return _onSaleValue;
}

- (UILabel *)soldValue{
    if(!_soldValue){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontMedium:20];
        [self.contentView addSubview:soldTitleLab];
        _soldValue = soldTitleLab;
    }
    return _soldValue;
}

- (UILabel *)soldTitleLab{
    if(!_soldTitleLab){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:soldTitleLab];
        _soldTitleLab = soldTitleLab;
    }
    return _soldTitleLab;
}

- (UILabel *)onSaleTitleLab{
    if(!_onSaleTitleLab){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:soldTitleLab];
        _onSaleTitleLab = soldTitleLab;
    }
    return _onSaleTitleLab;
}

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNeighborhoodDetailTradingRecordModel class]]) {
        return CGSizeMake(width, 52);
    }
    return CGSizeZero;
}

- (void)bindViewModel:(id)viewModel {
    [self refreshWithData:viewModel];
}
- (void)refreshWithData:(id)data{
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailTradingRecordModel class]]) {
        return;
    }
    self.currentData = data;
    FHNeighborhoodDetailTradingRecordModel *model = (FHNeighborhoodDetailTradingRecordModel *)data;
    if(model){
        self.onSaleTitleLab.text = @"在售房源";
        self.soldTitleLab.text = @"成交房源";
        self.soldUnit.text = @"套";
        self.onSaleUnit.text = @"套";
        if([model.sold isEqualToString:@"暂无数据"]){
            self.soldValue.font =  [UIFont themeFontMedium:14];
            self.soldUnit.text = @"";
            self.soldUnit.hidden = YES;
        }
        if([model.onSale isEqualToString:@"暂无数据"]){
            self.onSaleValue.font =  [UIFont themeFontMedium:14];
            self.onSaleUnit.text = @"";
            self.onSaleUnit.hidden = YES;
        }
        self.soldValue.text = model.sold;
        self.onSaleValue.text = model.onSale;
    }
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.left.mas_equalTo(self.contentView).offset(12);
            make.right.mas_equalTo(self.contentView).offset(-12);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.midLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(16);
            make.bottom.mas_equalTo(self.contentView).offset(-16);
            make.centerX.mas_equalTo(self.contentView);
            make.width.mas_equalTo(0.5);
        }];
        
        [self.soldTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).offset(12);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.soldValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.soldTitleLab.mas_right).offset(8);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.soldUnit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.soldValue.mas_right).offset(8);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.onSaleUnit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).offset(-30);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.onSaleValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.onSaleUnit.mas_left).offset(-8);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.onSaleTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.onSaleValue.mas_left).offset(-8);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.arrowOnSaleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.left.mas_equalTo(self.soldUnit.mas_right).offset(8);
        }];
        
        [self.arrowSoldImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.right.mas_equalTo(self.contentView).offset(-12);
        }];
        
    }
    return self;
}

@end

@implementation FHNeighborhoodDetailTradingRecordModel

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}


@end

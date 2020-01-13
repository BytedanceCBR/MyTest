//
//  FHDetailPriceChangeHistoryCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailPriceChangeHistoryCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"

@interface FHDetailPriceChangeHistoryCell ()

@property (nonatomic, weak)  UIImageView *shadowImage;
@property (nonatomic, weak)  UIView *bgView;
@property (nonatomic, weak)   UIImageView       *leftIconImageView;
@property (nonatomic, weak)   UIImageView       *rightArrowImageView;
@property (nonatomic, weak)   UILabel       *infoLabel;

@end

@implementation FHDetailPriceChangeHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailPriceChangeHistoryModel class]]) {
        return;
    }
    self.currentData = data;
    //
    FHDetailPriceChangeHistoryModel *model = (FHDetailPriceChangeHistoryModel *)data;
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
    self.infoLabel.text = model.priceChangeHistory.priceChangeDesc;
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

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"price_variation";
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIView *)bgView {
    if (!_bgView) {
        UIView *bgView = [[UIView alloc]init];
        bgView.backgroundColor = [UIColor colorWithHexStr:@"#fffaf0"];
        bgView.layer.masksToBounds = YES;
        bgView.layer.cornerRadius = 20;
        [self.contentView addSubview:bgView];
        _bgView = bgView;
    }
    return _bgView;
}

- (UIImageView *)leftIconImageView {
    if (!_leftIconImageView) {
        UIImageView *leftIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"price_routing"]];
        [self.bgView addSubview:leftIconImageView];
        _leftIconImageView = leftIconImageView;
    }
    return _leftIconImageView;
}

- (UIImageView *)rightArrowImageView {
    if (!_rightArrowImageView) {
        UIImageView *rightArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"price_routing_right_arrow"]];
        [self.bgView addSubview:rightArrowImageView];
        _rightArrowImageView = rightArrowImageView;
    }
    return _rightArrowImageView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        UILabel *infoLabel = [UILabel createLabel:@"" textColor:@"#9c6d43" fontSize:14];
        [self.bgView addSubview:infoLabel];
        _infoLabel = infoLabel;
    }
    return _infoLabel;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(31);
        make.right.mas_equalTo(self.contentView).offset(-31);
        make.top.equalTo(self.shadowImage).offset(27);
        make.height.mas_offset(40);
        make.centerY.equalTo(self.shadowImage);
    }];
    [self.leftIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).offset(15);
        make.centerY.mas_equalTo(self.bgView);
        make.width.height.mas_equalTo(16);
    }];
    [self.rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.right.mas_equalTo(self.bgView).offset(-13);
        make.width.height.mas_equalTo(16);
    }];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftIconImageView.mas_right).offset(7);
        make.right.mas_equalTo(self.rightArrowImageView.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.bgView);
    }];
    __weak typeof(self) wSelf = self;
    self.didClickCellBlk = ^{
        [wSelf clickCell];
    };
}

- (void)clickCell {
    if (self.currentData) {
        FHDetailPriceChangeHistoryModel *model = (FHDetailPriceChangeHistoryModel *)self.currentData;
        NSString *pushUrl = model.priceChangeHistory.detailUrl;
        NSArray *historyData = model.priceChangeHistory.history;
        NSString *houseId = model.baseViewModel.houseId;
        if (pushUrl.length > 0 && historyData && houseId.length > 0) {

            // 点击埋点
            FHDetailOldModel *oldDetail = self.baseViewModel.detailData;
            NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
            tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
            [tracerDic removeObjectsForKeys:@[@"card_type",@"enter_from",@"element_from"]];
            [FHUserTracker writeEvent:@"click_price_variation" params:tracerDic];
            
            NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
            NSString* url = [[NSString stringWithFormat:@"%@%@",host,pushUrl] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
            NSDictionary *history = @{@"history":historyData};
            NSDictionary *jsData = @{@"data":history,@"house_id":houseId};
            NSDictionary *jsParams = @{@"requestPageData":jsData};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"url":url,@"title":@"价格变动",@"fhJSParams":jsParams}];
            NSString *jumpUrl = @"sslocal://webview";
            [[TTRoute sharedRoute] openURLByPushViewController:[[NSURL alloc] initWithString:jumpUrl] userInfo:userInfo];
            
        }
    }
}

@end

// FHDetailPriceChangeHistoryModel
@implementation FHDetailPriceChangeHistoryModel


@end

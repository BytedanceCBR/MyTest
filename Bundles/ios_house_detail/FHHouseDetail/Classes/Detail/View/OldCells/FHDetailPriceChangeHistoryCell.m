//
//  FHDetailPriceChangeHistoryCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailPriceChangeHistoryCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"

@interface FHDetailPriceChangeHistoryCell ()

@property (nonatomic, strong)   UIImageView       *leftIconImageView;
@property (nonatomic, strong)   UIImageView       *rightArrowImageView;
@property (nonatomic, strong)   UILabel       *infoLabel;
@property (nonatomic, strong)   UIView       *sepLine;

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

- (void)setupUI {
    _leftIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ershou_price_tips_22"]];
    [self.contentView addSubview:_leftIconImageView];
    _rightArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-1"]];
    [self.contentView addSubview:_rightArrowImageView];
    _infoLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _infoLabel.textColor = [UIColor themeGray3];
    [self.contentView addSubview:_infoLabel];
    
    [self.leftIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.centerY.mas_equalTo(self.infoLabel);
        make.width.height.mas_equalTo(14);
    }];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftIconImageView.mas_right).offset(6);
        make.right.mas_equalTo(self.contentView).offset(-32);
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
    }];
    [self.rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.infoLabel);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.height.mas_equalTo(12);
    }];
    [self.sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(self.contentView);
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

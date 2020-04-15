//
//  FHDetailPriceChangeNoticeCell.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/4/10.
//

#import "FHDetailPriceChangeNoticeCell.h"
#import "UILabel+House.h"
#import "FHURLSettings.h"
#import "FHHouseFillFormHelper.h"
#import "FHHouseFollowUpConfigModel.h"
#import "FHHouseFollowUpHelper.h"
@interface FHDetailPriceChangeNoticeCell()
@property (nonatomic, weak)  UIImageView *shadowImage;
@property (nonatomic, weak)   UIImageView       *rightArrowImageView;
@property (nonatomic, weak)  FHDetailPriceChangeNoticeItem *leftNoticeItem;
@property (nonatomic, weak)  FHDetailPriceChangeNoticeItem *rightNoticeItem;
@property (nonatomic, weak)  UIView *bgView;
@property (nonatomic, weak)  UIView *lineView;
@end
@implementation FHDetailPriceChangeNoticeCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"price_notice";
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailPriceNoticeModel class]]) {
        return;
    }
    self.currentData = data;
    //
    FHDetailPriceNoticeModel *model = (FHDetailPriceNoticeModel *)data;
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
    FHDetailPriceChangeNoticeModel *priceChangeNotice = model.priceChangeNotice;
    if (priceChangeNotice.showType == 1) {
        [self.leftNoticeItem mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self.bgView);
            make.right.equalTo(self.bgView.mas_right).offset(-30);
        }];
        self.lineView.hidden = YES;
        self.rightNoticeItem.hidden = YES;
    }else {
        self.rightArrowImageView.hidden = YES;
    }
    
    self.leftNoticeItem.content = priceChangeNotice.changeTitle;
    self.rightNoticeItem.content = priceChangeNotice.analysisTitle;
    
//    FHDetailPriceNoticeModel
    
//    self.infoLabel.text = model.priceChangeHistory.priceChangeDesc;
    [self layoutIfNeeded];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
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
    [self.rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.right.mas_equalTo(self.bgView).offset(-13);
        make.width.height.mas_equalTo(16);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.top.bottom.equalTo(self.bgView);
        make.width.mas_offset(1);
    }];
    [self.leftNoticeItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.bgView);
        make.right.equalTo(self.lineView.mas_left);
    }];
    [self.rightNoticeItem mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.top.bottom.equalTo(self.bgView);
          make.left.equalTo(self.lineView.mas_right);
      }];
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

- (UIImageView *)rightArrowImageView {
    if (!_rightArrowImageView) {
        UIImageView *rightArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"price_routing_right_arrow"]];
        [self.bgView addSubview:rightArrowImageView];
        _rightArrowImageView = rightArrowImageView;
    }
    return _rightArrowImageView;
}

- (FHDetailPriceChangeNoticeItem *)leftNoticeItem {
    if (!_leftNoticeItem) {
        FHDetailPriceChangeNoticeItem *leftNoticeItem = [[FHDetailPriceChangeNoticeItem alloc]init];
        leftNoticeItem.imageName = @"price_notice";
        [leftNoticeItem addTarget:self action:@selector(writeMessage:) forControlEvents:UIControlEventTouchDown];
        [self.bgView addSubview:leftNoticeItem];
        _leftNoticeItem = leftNoticeItem;
    }
    return _leftNoticeItem;
}

- (FHDetailPriceChangeNoticeItem *)rightNoticeItem {
    if (!_rightNoticeItem) {
        FHDetailPriceChangeNoticeItem *rightNoticeItem = [[FHDetailPriceChangeNoticeItem alloc]init];
         rightNoticeItem.imageName = @"price_routing";
         [rightNoticeItem addTarget:self action:@selector(jumpTo:) forControlEvents:UIControlEventTouchDown];
        [self.bgView addSubview:rightNoticeItem];
        _rightNoticeItem = rightNoticeItem;
    }
    return _rightNoticeItem;
}

- (UIView *)lineView
{
    if (!_lineView) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor colorWithHexStr:@"#ffe7d2"];
        [self.contentView addSubview:lineView];
        _lineView = lineView;
    }
    return _lineView;
}

- (void)writeMessage:(id)sender {
    FHDetailPriceNoticeModel *model = (FHDetailPriceNoticeModel *)self.currentData;
    if ([model.contactModel isKindOfClass:[FHHouseDetailContactViewModel class]]) {
        FHHouseDetailContactViewModel *contactViewModel = (FHHouseDetailContactViewModel *)model.contactModel;
        if ([contactViewModel respondsToSelector:@selector(fillFormActionWithExtraDict:)]) {
            NSDictionary *infoDic =  @{kFHCluePage:@(FHClueFormPageTypeCOldPriceChangeNotice),
                                       @"title":@"变价通知",
                                       @"subtitle":@"订阅变价通知，房源变价信息会及时发送到您的手机",
                                       @"position":@"change_price",
                                       @"btn_title":@"提交"
            };
            [contactViewModel fillFormActionWithExtraDict:infoDic];
            __weak typeof(self)ws = self;
            contactViewModel.fillFormSubmitBlock = ^{
                  // 静默关注功能
                           NSMutableDictionary *params = @{}.mutableCopy;
                           if (ws.baseViewModel.detailTracerDic) {
                               [params addEntriesFromDictionary:ws.baseViewModel.detailTracerDic];
                           }
                           FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:params error:nil];
                           configModel.houseType = ws.baseViewModel.houseType;
                           configModel.followId = ws.baseViewModel.houseId;
                           configModel.actionType = ws.baseViewModel.houseType;
                           [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel];
            };
        }
    }

}

- (void)jumpTo:(id)sender {
    if (self.currentData) {
        FHDetailPriceNoticeModel *model = (FHDetailPriceNoticeModel *)self.currentData;
        NSString *pushUrl = model.priceChangeNotice.priceAnalysisUrl;
        NSArray *historyData = model.priceChangeNotice.history;
        NSString *houseId = model.baseViewModel.houseId;
        if (pushUrl.length > 0 && historyData.count>0 && houseId.length > 0) {
            NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
            tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
            [tracerDic removeObjectsForKeys:@[@"card_type",@"enter_from",@"element_from"]];
            [FHUserTracker writeEvent:@"click_price_variation" params:tracerDic];
            
            NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
            NSString* url = [[NSString stringWithFormat:@"%@%@",host,pushUrl] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
            NSDictionary *history = @{@"history":historyData};
            NSDictionary *jsData = @{@"data":history,@"house_id":houseId};
            NSDictionary *jsParams = @{@"requestPageData":jsData};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"url":url,@"title":@"价格解析",@"fhJSParams":jsParams}];
            NSString *jumpUrl = @"sslocal://webview";
            [[TTRoute sharedRoute] openURLByPushViewController:[[NSURL alloc] initWithString:jumpUrl] userInfo:userInfo];
            [self addGoDetailLog];
        }
    }
}

- (void)addGoDetailLog
{
    FHDetailPriceNoticeModel *model = (FHDetailPriceNoticeModel *)self.currentData;
    //    1. event_type ：house_app2c_v2
    //    2. page_type（详情页类型）：rent_detail（租房详情页），old_detail（二手房详情页）
    //    3. card_type（房源展现时的卡片样式）：left_pic（左图）
    //    4. enter_from（详情页入口）：search_related_list（搜索结果推荐）
    //    5. element_from ：search_related
    //    6. rank
    //    7. origin_from
    //    8. origin_search_id
    //    9.log_pb
    NSMutableDictionary *params = @{}.mutableCopy;
    if (model.baseViewModel.detailTracerDic) {
        [params addEntriesFromDictionary:model.baseViewModel.detailTracerDic];
    }
    [params setValue:@"price_analysis" forKey:@"page_type"];
    [params setValue:@"old_detail" forKey:@"enter_from"];
    [FHUserTracker writeEvent:@"go_detail" params:params];
    
}
@end

@implementation FHDetailPriceNoticeModel

@end



@interface FHDetailPriceChangeNoticeItem()
@property (nonatomic, weak) UIImageView*leftIconImageView;
@property (nonatomic, weak) UILabel *infoLabel;
@end

@implementation FHDetailPriceChangeNoticeItem
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.leftIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(30);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(16);
    }];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftIconImageView.mas_right).offset(7);
        make.right.mas_equalTo(self).offset(-10);
        make.centerY.mas_equalTo(self);
    }];
}

- (UIImageView *)leftIconImageView {
    if (!_leftIconImageView) {
        UIImageView *leftIconImageView = [[UIImageView alloc] init];
        [self addSubview:leftIconImageView];
        _leftIconImageView = leftIconImageView;
    }
    return _leftIconImageView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        UILabel *infoLabel = [UILabel createLabel:@"" textColor:@"#9c6d43" fontSize:14];
        [self addSubview:infoLabel];
        _infoLabel = infoLabel;
    }
    return _infoLabel;
}

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    self.leftIconImageView.image = [UIImage imageNamed:imageName];
}

- (void)setContent:(NSString *)content {
    _content = content;
    self.infoLabel.text = content;
}
@end

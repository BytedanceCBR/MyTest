//
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHDetailNewHouseCoreInfoCell.h"
#import "TTRoute.h"
#import "FHDetailNewModel.h"
#import "FHHouseDetailContactViewModel.h"
#import <FHEnvContext.h>

static const CGFloat kLabelKeyFontSize = 12;

static const CGFloat kLabelKeyLeftPandding = 20;

static const CGFloat kLabelKeyRightPandding = -20;

@interface FHDetailNewHouseCoreInfoCell()

@property (nonatomic, strong) UILabel *pricingPerSqmKeyLabel;
@property (nonatomic, strong) UILabel *pricingPerSqmLabel;
@property (nonatomic, strong) UILabel *openDateKey;
@property (nonatomic, strong) UILabel *openDataLabel;
@property (nonatomic, strong) UILabel *courtAddressKey;
@property (nonatomic, strong) UILabel *courtAddressLabel;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIButton *priceChangedNotify;
@property (nonatomic, strong) UIView *verticalLineView;
@property (nonatomic, strong) UIButton *openNotify;
@property (nonatomic, strong) UIImageView *locationIcon;
@property (nonatomic, strong) UIButton *openMapBtn;
//@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) FHDetailNewHouseCoreInfoModel *infoModel;

@end

@implementation FHDetailNewHouseCoreInfoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpCollection];
    }
    return self;
}

- (void)setUpCollection
{
    _pricingPerSqmKeyLabel = [UILabel new];
    _pricingPerSqmKeyLabel.text = @"均价";
    _pricingPerSqmKeyLabel.font = [UIFont themeFontRegular:kLabelKeyFontSize];
    _pricingPerSqmKeyLabel.textColor = [UIColor themeGray3];
    [_pricingPerSqmKeyLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_pricingPerSqmKeyLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_pricingPerSqmKeyLabel];
    [_pricingPerSqmKeyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(19);
        make.left.mas_equalTo(kLabelKeyLeftPandding);
        make.height.mas_equalTo(17);
        make.width.mas_lessThanOrEqualTo(24);
    }];
    
    
    _pricingPerSqmLabel = [UILabel new];
    _pricingPerSqmLabel.font = [UIFont themeFontMedium:16];
    _pricingPerSqmLabel.textColor = [UIColor colorWithHexString:@"#ff5b4c"];
    _pricingPerSqmLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_pricingPerSqmLabel];
    [_pricingPerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pricingPerSqmKeyLabel.mas_centerY);
        make.left.equalTo(self.pricingPerSqmKeyLabel.mas_right).offset(10);
        make.right.mas_equalTo(kLabelKeyRightPandding);
        make.height.mas_lessThanOrEqualTo(22);
    }];
    
    
    _openDateKey = [UILabel new];
    _openDateKey.text = @"开盘";
    _openDateKey.font = [UIFont themeFontRegular:kLabelKeyFontSize];
    _openDateKey.textColor = [UIColor themeGray3];
    _openDateKey.textAlignment = NSTextAlignmentLeft;
    [_openDateKey setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_openDateKey setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_openDateKey];
    [_openDateKey mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pricingPerSqmKeyLabel.mas_bottom).offset(18);
        make.left.mas_equalTo(kLabelKeyLeftPandding);
        make.height.mas_lessThanOrEqualTo(17);
    }];
    
    
    _openDataLabel = [UILabel new];
    _openDataLabel.font = [UIFont themeFontRegular:15];
    _openDataLabel.textColor = [UIColor colorWithHexString:@"#081f33"];
    _openDataLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_openDataLabel];
    [_openDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.openDateKey.mas_centerY);
        make.left.equalTo(self.openDateKey.mas_right).offset(10);
        make.right.mas_equalTo(kLabelKeyRightPandding);
        make.height.mas_lessThanOrEqualTo(22);
    }];
    
    
    
    _courtAddressKey = [UILabel new];
    _courtAddressKey.text = @"地址";
    _courtAddressKey.font = [UIFont themeFontRegular:kLabelKeyFontSize];
    _courtAddressKey.textColor = [UIColor themeGray3];
    _courtAddressKey.textAlignment = NSTextAlignmentLeft;
    [_courtAddressKey setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_courtAddressKey setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_courtAddressKey];
    [_courtAddressKey mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.openDateKey.mas_bottom).offset(18);
        make.left.mas_equalTo(kLabelKeyLeftPandding);
        make.height.mas_lessThanOrEqualTo(17);
    }];
    
    
    _locationIcon = [UIImageView new];
    _locationIcon.image = [UIImage imageNamed:@"arrowicon-feed-1"];
    [self.contentView addSubview:_locationIcon];
    [_locationIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.courtAddressKey.mas_centerY);
        make.right.mas_equalTo(kLabelKeyRightPandding);
        make.height.mas_lessThanOrEqualTo(20);
    }];
    
    
    _courtAddressLabel = [UILabel new];
    _courtAddressLabel.font = [UIFont themeFontRegular:15];
    _courtAddressLabel.textColor = [UIColor colorWithHexString:@"#3d6e99"];
    _courtAddressLabel.textAlignment = NSTextAlignmentLeft;
    _courtAddressLabel.numberOfLines = 0;
    [self.contentView addSubview:_courtAddressLabel];
    [_courtAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.courtAddressKey.mas_centerY);
        make.left.equalTo(self.courtAddressKey.mas_right).offset(10);
        make.right.mas_equalTo(kLabelKeyRightPandding - 10);
        make.height.mas_lessThanOrEqualTo(22);
    }];
    
    
    _openMapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_openMapBtn addTarget:self action:@selector(openMapDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_openMapBtn];
    [_openMapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.courtAddressLabel);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.locationIcon.mas_top).offset(-2);
        make.height.mas_equalTo(24);
    }];
    
    _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:@"更多楼盘信息" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:14.f],NSForegroundColorAttributeName:[UIColor themeGray2]}];
    [_moreBtn setAttributedTitle:attributeString forState:UIControlStateNormal];
    _moreBtn.backgroundColor = [UIColor colorWithHexString:@"#f6f7f8"];
    _moreBtn.layer.cornerRadius = 5;
    [_moreBtn addTarget:self action:@selector(moreInfoButClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_moreBtn];
    [_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.courtAddressKey.mas_bottom).offset(16);
        make.left.mas_equalTo(kLabelKeyLeftPandding);
        make.right.mas_equalTo(kLabelKeyRightPandding);
        make.height.mas_equalTo(36);
    }];
    
    
//    _bottomLine = [UIView new];
//    _bottomLine.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
//    [self.contentView addSubview:_bottomLine];
//    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(self.contentView);
//        make.height.mas_equalTo(6);
//    }];


    _priceChangedNotify = [UIButton buttonWithType:UIButtonTypeCustom];
    [_priceChangedNotify setImage:[UIImage imageNamed:@"ic-new-house-price-change-notice"] forState:UIControlStateNormal];
    [_priceChangedNotify setImage:[UIImage imageNamed:@"ic-new-house-price-change-notice"] forState:UIControlStateHighlighted];
    [_priceChangedNotify setTitle:@"变价通知" forState:UIControlStateNormal];
    NSAttributedString *stringAttriChange = [[NSAttributedString alloc] initWithString:@"变价通知" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:16.f],NSForegroundColorAttributeName:[UIColor themeGray2]}];
    [_priceChangedNotify setAttributedTitle:stringAttriChange forState:UIControlStateNormal];
    _priceChangedNotify.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [self.contentView addSubview:_priceChangedNotify];
    [_priceChangedNotify addTarget:self action:@selector(priceChangedNotifyActionClick) forControlEvents:UIControlEventTouchUpInside];
    [_priceChangedNotify mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.moreBtn.mas_bottom);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_centerX);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(54);
    }];


    _verticalLineView = [UIView new];
    _verticalLineView.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_verticalLineView];
    [_verticalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.priceChangedNotify).offset(12);
        make.bottom.equalTo(self.priceChangedNotify).offset(-12);
        make.left.equalTo(self.priceChangedNotify.mas_right);
        make.width.mas_equalTo(1);
    }];


    _openNotify = [UIButton buttonWithType:UIButtonTypeCustom];
    [_openNotify setImage:[UIImage imageNamed:@"ic-new-house-opening-notice"] forState:UIControlStateNormal];
    [_openNotify setImage:[UIImage imageNamed:@"ic-new-house-opening-notice"] forState:UIControlStateHighlighted];
    [_openNotify setTitle:@"开盘通知" forState:UIControlStateNormal];
    NSAttributedString *stringAttriOpen = [[NSAttributedString alloc] initWithString:@"开盘通知" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:16.f],NSForegroundColorAttributeName:[UIColor themeGray2]}];
    [_openNotify setAttributedTitle:stringAttriOpen forState:UIControlStateNormal];
    _openNotify.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [_openNotify addTarget:self action:@selector(openNotifyActionClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_openNotify];
    [_openNotify mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.priceChangedNotify);
        make.left.equalTo(self.contentView.mas_centerX);
        make.right.equalTo(self.contentView);
    }];
}

- (void)openNotifyActionClick
{
    FHDetailNewHouseCoreInfoModel *model = (FHDetailNewHouseCoreInfoModel *)self.currentData;
    if ([model.contactModel isKindOfClass:[FHHouseDetailContactViewModel class]]) {
        FHHouseDetailContactViewModel *contactViewModel = (FHHouseDetailContactViewModel *)model.contactModel;
        if ([model.contactModel respondsToSelector:@selector(fillFormActionWithTitle:subtitle:btnTitle:)]) {
            [contactViewModel fillFormActionWithTitle:@"开盘通知" subtitle:@"订阅开盘通知，楼盘开盘信息会及时发送到您的手机" btnTitle:@"提交"];
        }
    }
}
- (void)priceChangedNotifyActionClick
{
    FHDetailNewHouseCoreInfoModel *model = (FHDetailNewHouseCoreInfoModel *)self.currentData;
    if ([model.contactModel isKindOfClass:[FHHouseDetailContactViewModel class]]) {
        FHHouseDetailContactViewModel *contactViewModel = (FHHouseDetailContactViewModel *)model.contactModel;
        if ([model.contactModel respondsToSelector:@selector(fillFormActionWithTitle:subtitle:btnTitle:)]) {
            [contactViewModel fillFormActionWithTitle:@"变价通知" subtitle:@"订阅变价通知，楼盘变价信息会及时发送到您的手机" btnTitle:@"提交"];
        }
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"house_info";
}

- (NSArray *)elementTypeStringArray:(FHHouseType)houseType
{
    return @[@"price_notice",@"openning_notice"];
}

- (void)moreInfoButClick
{
    NSString *courtId = ((FHDetailNewHouseCoreInfoModel *)self.currentData).courtId;
    if (courtId) {
        NSDictionary *dictTrace = self.baseViewModel.detailTracerDic;
        
        NSMutableDictionary *mutableDict = [NSMutableDictionary new];
        [mutableDict setValue:dictTrace[@"page_type"] forKey:@"page_type"];
        [mutableDict setValue:dictTrace[@"rank"] forKey:@"rank"];
        [mutableDict setValue:dictTrace[@"origin_from"] forKey:@"origin_from"];
        [mutableDict setValue:dictTrace[@"origin_search_id"] forKey:@"origin_search_id"];
        [mutableDict setValue:dictTrace[@"log_pb"] forKey:@"log_pb"];
        
        [FHEnvContext recordEvent:mutableDict andEventKey:@"click_house_info"];
        
        FHDetailNewHouseCoreInfoModel *houseNameModel = (FHDetailNewHouseCoreInfoModel *)self.currentData;
        NSMutableDictionary *infoDict = [NSMutableDictionary new];
        [infoDict addEntriesFromDictionary:[self.baseViewModel subPageParams]];
        [infoDict setValue:houseNameModel.houseName forKey:@"courtInfo"];
        [infoDict setValue:houseNameModel.disclaimerModel forKey:@"disclaimerInfo"];
        
        TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://floor_coreinfo_detail?court_id=%@",courtId]] userInfo:info];
    }
}

- (void)openMapDetail
{
    //地图页调用示例
    double longitude = [_infoModel.gaodeLng doubleValue] ? [_infoModel.gaodeLng doubleValue] : 0;
    double latitude = [_infoModel.gaodeLat doubleValue] ? [_infoModel.gaodeLat doubleValue] : 0;
    NSNumber *latitudeNum = @(latitude);
    NSNumber *longitudeNum = @(longitude);
    
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    [infoDict setValue:@"公交" forKey:@"category"];
    [infoDict setValue:latitudeNum forKey:@"latitude"];
    [infoDict setValue:longitudeNum forKey:@"longitude"];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionaryWithDictionary:self.baseViewModel.detailTracerDic];
    [tracer setValue:@"address" forKey:@"click_type"];
    [tracer setValue:@"house_info" forKey:@"element_from"];
    [tracer setObject:tracer[@"page_type"] forKey:@"enter_from"];
    [infoDict setValue:tracer forKey:@"tracer"];
    
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fh_map_detail"] userInfo:info];
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHDetailNewHouseCoreInfoModel class]]) {
        self.currentData = data;
        
        FHDetailNewHouseCoreInfoModel *model = (FHDetailNewHouseCoreInfoModel *)data;
        _infoModel = model;
        self.pricingPerSqmLabel.text = model.pricingPerSqm;
        self.openDataLabel.text = model.constructionOpendate;
        self.courtAddressLabel.text = model.courtAddress;

//        if (model.pricingSubStauts != 0) {
//            NSAttributedString *stringAttriChange = [[NSAttributedString alloc] initWithString:@"变价通知" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:16.f],NSForegroundColorAttributeName:[UIColor themeGray2]}];
//            [_priceChangedNotify setAttributedTitle:stringAttriChange forState:UIControlStateNormal];
//
//            NSAttributedString *stringAttriOpen = [[NSAttributedString alloc] initWithString:@"开盘通知" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:16.f],NSForegroundColorAttributeName:[UIColor themeGray2]}];
//            [_openNotify setAttributedTitle:stringAttriOpen forState:UIControlStateNormal];
//        }else
//        {
            NSAttributedString *stringAttriChange = [[NSAttributedString alloc] initWithString:@"变价通知" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:16.f],NSForegroundColorAttributeName:[UIColor themeGray2]}];
            [_priceChangedNotify setAttributedTitle:stringAttriChange forState:UIControlStateNormal];
            
            NSAttributedString *stringAttriOpen = [[NSAttributedString alloc] initWithString:@"开盘通知" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:16.f],NSForegroundColorAttributeName:[UIColor themeGray2]}];
            [_openNotify setAttributedTitle:stringAttriOpen forState:UIControlStateNormal];
//        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

@implementation FHDetailNewHouseCoreInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end

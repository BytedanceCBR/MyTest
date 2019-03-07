//
//  FHDetailListEntranceCell.m
//  Pods
//
//  Created by 张静 on 2019/3/7.
//

#import "FHDetailListEntranceCell.h"
#import "FHDetailOldModel.h"
#import <TTRoute/TTRoute.h>

@implementation FHDetailListEntranceItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.icon];
    [self addSubview:self.nameLabel];
    [self addSubview:self.rightArrow];

    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.width.height.mas_equalTo(18);
        make.centerY.mas_equalTo(self);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).mas_equalTo(11);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.rightArrow.mas_left).mas_equalTo(-11);
    }];
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(self);
    }];
}

- (UIImageView *)icon
{
    if (!_icon) {
        _icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"detail_entrance_icon"]];
    }
    return _icon;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textColor = [UIColor themeGray1];
        _nameLabel.font = [UIFont themeFontRegular:14];
    }
    return _nameLabel;
}

- (UIImageView *)rightArrow
{
    if (!_rightArrow) {
        _rightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"detail_entrance_arrow"]];
    }
    return _rightArrow;
}

@end

@interface FHDetailListEntranceCell ()

@property (nonatomic, strong) UIView *containerView;

@end

@implementation FHDetailListEntranceCell


- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailListEntranceModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailListEntranceModel *model = (FHDetailListEntranceModel *)data;
    if (model.listEntrance.count < 1) {
        return;
    }
    CGFloat bottomY = 0;
    for (NSInteger index = 0;index < model.listEntrance.count;index++) {
        FHDetailDataListEntranceItemModel *item = model.listEntrance[index];
        FHDetailListEntranceItemView *itemView = [[FHDetailListEntranceItemView alloc]initWithFrame:CGRectZero];
        itemView.nameLabel.text = item.listName;
        itemView.tag = 100 + index;
        [self.containerView addSubview:itemView];
        [itemView addTarget:self action:@selector(entranceDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(bottomY);
            make.height.mas_equalTo(34);
            if (index == model.listEntrance.count - 1) {
                make.bottom.mas_equalTo(self.containerView);
            }
        }];
        bottomY += 34;
    }
    if (model.listEntrance.count == 1) {
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(7);
            make.bottom.mas_equalTo(-7);
            
        }];
    }else {
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(13);
            make.bottom.mas_equalTo(-13);
            
        }];
    }
}

- (void)entranceDidClick:(UIControl *)btn
{
    NSInteger index = btn.tag - 100;
    FHDetailListEntranceModel *model = (FHDetailListEntranceModel *)self.currentData;
    if (index >= model.listEntrance.count) {
        return;
    }
    FHDetailDataListEntranceItemModel *item = model.listEntrance[index];
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:item.entranceUrl]];
    NSMutableDictionary *queryP = [NSMutableDictionary new];
    [queryP addEntriesFromDictionary:paramObj.allParams];
    NSDictionary *baseParams = [self.baseViewModel detailTracerDic];
    NSMutableDictionary *dict = @{}.mutableCopy;
    if (baseParams) {
        [dict addEntriesFromDictionary:baseParams];
    }
    dict[@"enter_from"] = @"old_detail";
    dict[@"element_from"] = @"ranking_list";

    NSString *reportParams = [self getEvaluateWebParams:dict];
    NSString *jumpUrl = @"sslocal://webview";
    NSMutableString *urlS = [[NSMutableString alloc] init];
    [urlS appendString:queryP[@"url"]];
    [urlS appendFormat:@"&report_params=%@",reportParams];
    queryP[@"url"] = urlS;
    
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:queryP];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:jumpUrl] userInfo:info];
}

- (NSString *)getEvaluateWebParams:(NSDictionary *)dic
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONReadingAllowFragments error:&error];
    if (data && !error) {
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        temp = [temp stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        return temp;
    }
    return nil;
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

- (void)setupUI
{
    _containerView = [[UIView alloc]init];
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(13);
        make.bottom.mas_equalTo(-13);

    }];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"ranking_list";
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

@implementation FHDetailListEntranceModel


@end


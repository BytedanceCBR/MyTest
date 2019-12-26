//
//  FHDetailListEntranceCell.m
//  Pods
//
//  Created by 张静 on 2019/3/7.
//

#import "FHDetailListEntranceCell.h"
#import "FHDetailOldModel.h"
#import <TTRoute/TTRoute.h>
#import <UIImageView+BDWebImage.h>
#import <FHHouseBase/UIImage+FIconFont.h>


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
        make.left.mas_equalTo(self).offset(19);
        make.width.height.mas_equalTo(24);
        make.centerY.mas_equalTo(self);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).mas_equalTo(6.5);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.rightArrow.mas_left).mas_equalTo(-11);
    }];
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-12);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self);
    }];
}

- (UIImageView *)icon
{
    if (!_icon) {
        _icon = [[UIImageView alloc]init];
    }
    return _icon;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
        _nameLabel.font = [UIFont themeFontMedium:16];
    }
    return _nameLabel;
}

- (UIImageView *)rightArrow
{
    if (!_rightArrow) {
        UIImage *img = ICON_FONT_IMG(16, @"\U0000e670", [UIColor themeGray3]); //@"detail_entrance_arrow"
        _rightArrow = [[UIImageView alloc]initWithImage:img];
    }
    return _rightArrow;
}

@end

@interface FHDetailListEntranceCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) UIImageView *shadowImage;
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
    for (NSInteger index = 0;index < model.listEntrance.count;index++) {
        FHDetailDataListEntranceItemModel *item = model.listEntrance[index];
        FHDetailListEntranceItemView *itemView = [[FHDetailListEntranceItemView alloc]initWithFrame:CGRectZero];
        itemView.nameLabel.text = item.listName;
        [itemView.icon bd_setImageWithURL:[NSURL URLWithString:item.icon] placeholder:[UIImage imageNamed:@"detail_entrance_icon"]];
        itemView.tag = 100 + index;
        [self.containerView addSubview:itemView];
        [itemView addTarget:self action:@selector(entranceDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(bottomY);
            make.height.mas_equalTo(62);
            if (index == model.listEntrance.count - 1) {
                make.bottom.mas_equalTo(self.containerView);
            }
        }];
        bottomY += 47;
    }
    if (model.listEntrance.count == 1) {
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.shadowImage).offset(25);
            make.bottom.mas_equalTo(self.shadowImage).offset(-25);
        }];
    }else {
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.shadowImage).offset(30);
            make.bottom.mas_equalTo(self.shadowImage).offset(-30);
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
    queryP[@"hide_nav_bottom_line"] = @(YES);
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
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _containerView = [[UIView alloc]init];
//    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.top.mas_equalTo(self.shadowImage).offset(25);
        make.bottom.mas_equalTo(self.shadowImage).offset(-25);
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


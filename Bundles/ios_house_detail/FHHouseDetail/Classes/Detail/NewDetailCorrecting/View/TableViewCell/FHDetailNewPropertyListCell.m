//
//  FHDetailNewPropertyListCell.m
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/9.
//

#import "FHDetailNewPropertyListCell.h"
#import "FHPropertyListCorrectingRowView.h"
#import "FHDetailBaseModel.h"
#import "FHHouseBaseInfoModel.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHUIAdaptation.h"

@interface FHDetailNewPropertyListCell ()

@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) UIButton *detailBtn;

@end

@implementation FHDetailNewPropertyListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _itemArray = [[NSMutableArray alloc]init];
        [self setupUI];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewPropertyListCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNewPropertyListCellModel *model = (FHDetailNewPropertyListCellModel *)data;
    adjustImageScopeType(model)
    __block UIView *lastView = nil; // 最后一个视图
    NSInteger count = model.baseInfo.count;
    if (count > 0) {
        NSMutableArray *singles = [NSMutableArray new];
        __block NSInteger doubleCount = 0;// 两列计数
        __block CGFloat topOffset = model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll?18:6;// 高度
        __block CGFloat listRowHeight = 29;// 30
        __block CGFloat lastViewLeftOffset = 20;
        __block CGFloat lastTopOffset = 20;
        CGFloat viewWidth = (UIScreen.mainScreen.bounds.size.width - 60 - 24) / 2;
        
        WeakSelf;
        [model.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            StrongSelf;
            if (obj.isSingle) {
                obj.realIndex = idx;
                [singles addObject:obj];
            } else {
                // 两列
                if (doubleCount % 2 == 0) {
                    // 第1列
                    FHPropertyListCorrectingRowView *v = [[FHPropertyListCorrectingRowView alloc] init];
                    v.tag = 100+idx;
                    [v addTarget:self action:@selector(openUrlDidClick:) forControlEvents:UIControlEventTouchUpInside];
                    [self.contentView addSubview:v];
                    [self.itemArray addObject:v];
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(topOffset);
                        make.left.mas_equalTo(31);
                        make.width.mas_equalTo(viewWidth);
                        make.height.mas_equalTo(listRowHeight);
                    }];
                    v.keyLabel.text = obj.attr;
                    v.valueLabel.text = obj.value;
                    v.keyLabel.font = [UIFont themeFontRegular:14];
                    v.valueLabel.font = [UIFont themeFontMedium:14];
                    v.valueLabel.textColor = obj.color.length > 0 ? [UIColor colorWithHexString:obj.color] : [UIColor themeGray1];
                    lastView = v;
                    lastViewLeftOffset = 20;
                    lastTopOffset = topOffset;
                } else {
                    // 第2列
                    FHPropertyListCorrectingRowView *v = [[FHPropertyListCorrectingRowView alloc] init];
                    v.tag = 100+idx;
                    [v addTarget:self action:@selector(openUrlDidClick:) forControlEvents:UIControlEventTouchUpInside];
                    [self.contentView addSubview:v];
                    [self.itemArray addObject:v];
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(topOffset);
                        make.left.mas_equalTo(31 + viewWidth);
                        make.width.mas_equalTo(viewWidth);
                        make.height.mas_equalTo(listRowHeight);
                    }];
                    v.keyLabel.text = obj.attr;
                    v.valueLabel.text = obj.value;
                    v.keyLabel.font = [UIFont themeFontRegular:14];
                    v.valueLabel.font = [UIFont themeFontMedium:14];
                    v.valueLabel.textColor = obj.color.length > 0 ? [UIColor colorWithHexString:obj.color] : [UIColor themeGray1];
                    lastView = v;
                    lastViewLeftOffset = 20 + viewWidth;
                    lastTopOffset = topOffset;
                    //
                    topOffset += listRowHeight;
                }
                doubleCount += 1;
            }
        }];
        // 添加单列数据
        if (singles.count > 0) {
            // 重新计算topOffset
            StrongSelf;
            topOffset = 6 + (doubleCount / 2 + doubleCount % 2) * listRowHeight;
            [singles enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHPropertyListCorrectingRowView *v = [[FHPropertyListCorrectingRowView alloc] init];
                v.tag = 100+obj.realIndex;
                [v addTarget:self action:@selector(openUrlDidClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:v];
                [self.itemArray addObject:v];
                [v mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(topOffset);
                    make.left.mas_equalTo(31);
                    make.width.mas_equalTo(viewWidth * 2);
                    make.height.mas_equalTo(listRowHeight);
                }];
                v.keyLabel.text = obj.attr;
                v.valueLabel.text = obj.value;
                v.keyLabel.font = [UIFont themeFontRegular:14];
                v.valueLabel.font = [UIFont themeFontMedium:14];
                v.valueLabel.textColor = obj.color.length > 0 ? [UIColor colorWithHexString:obj.color] : [UIColor themeGray1];
                lastView = v;
                lastViewLeftOffset = 20;
                lastTopOffset = topOffset;
                
                topOffset += listRowHeight;
            }];
        }
        CGFloat btnTop = model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll?18:6;
        [self.detailBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(btnTop + 14);
        }];
    }
//    [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.shadowImage.mas_bottom).offset(-42);
//    }];

}

- (void)openUrlDidClick:(UIControl *)btn
{
    NSInteger index = btn.tag - 100;
    FHDetailNewPropertyListCellModel *model = (FHDetailNewPropertyListCellModel *)self.currentData;

    if (index < 0 || index >= model.baseInfo.count) {
        return;
    }
    FHHouseBaseInfoModel *obj = model.baseInfo[index];
    if (obj.openUrl.length > 0) {
        NSURL *url = [NSURL URLWithString:obj.openUrl];
        [[TTRoute sharedRoute]openURLByPushViewController:url];
    }
}

- (void)setupUI
{
    [self.contentView addSubview:self.shadowImage];
    [self.contentView addSubview:self.detailBtn];

    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.detailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(67);
        make.width.mas_equalTo(21);
        make.bottom.mas_equalTo(self.shadowImage.mas_bottom).offset(-42);
    }];
    [self.detailBtn addTarget:self action:@selector(detailBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)detailBtnDidClick:(UIButton *)btn
{
    FHDetailNewPropertyListCellModel *model = (FHDetailNewPropertyListCellModel *)self.currentData;

    NSString *courtId = model.courtId;
    if (courtId) {
        NSDictionary *dictTrace = self.baseViewModel.detailTracerDic;
        
        NSMutableDictionary *mutableDict = [NSMutableDictionary new];
        [mutableDict setValue:dictTrace[@"page_type"] forKey:@"page_type"];
        [mutableDict setValue:dictTrace[@"rank"] forKey:@"rank"];
        [mutableDict setValue:dictTrace[@"origin_from"] forKey:@"origin_from"];
        [mutableDict setValue:dictTrace[@"origin_search_id"] forKey:@"origin_search_id"];
        [mutableDict setValue:dictTrace[@"log_pb"] forKey:@"log_pb"];
        
        [FHUserTracker writeEvent:@"click_house_info" params:mutableDict];
        
        NSMutableDictionary *infoDict = [NSMutableDictionary new];
        [infoDict addEntriesFromDictionary:[self.baseViewModel subPageParams]];
        [infoDict setValue:model.houseName forKey:@"courtInfo"];
        if (model.disclaimerModel) {
            [infoDict setValue:model.disclaimerModel forKey:@"disclaimerInfo"];
        }
        
        TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://floor_coreinfo_detail?court_id=%@",courtId]] userInfo:info];
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"house_info";
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIButton *)detailBtn {
    if (!_detailBtn) {
        _detailBtn = [[UIButton alloc]init];
        UIImage *img = ICON_FONT_IMG(16, @"\U0000e670", [UIColor themeGray3]);
        [_detailBtn setImage:img forState:UIControlStateNormal];
        _detailBtn.backgroundColor = [UIColor colorWithHexString:@"#f7f7f7"];
        _detailBtn.layer.cornerRadius = 4;
        _detailBtn.layer.masksToBounds = YES;
    }
    return _detailBtn;
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

@implementation FHDetailNewPropertyListCellModel



@end

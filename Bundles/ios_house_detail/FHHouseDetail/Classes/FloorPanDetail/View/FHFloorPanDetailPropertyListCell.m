//
//  FHFloorPanDetailPropertyListCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/4/12.
//

#import "FHFloorPanDetailPropertyListCell.h"
#import "FHDetailPropertyListCorrectingCell.h"
#import "FHPropertyListCorrectingRowView.h"
#import "FHDetailBaseModel.h"
#import "FHHouseBaseInfoModel.h"
#import <TTBaseLib/TTBaseMacro.h>
#import "FHCommonDefines.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHUIAdaptation.h"

#define kGrayLineX 19
@interface FHFloorPanDetailPropertyListCell ()

@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) UIView *grayLineView;


@end
@implementation FHFloorPanDetailPropertyListCell


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

- (void)refreshWithData:(id)data{
    if (self.currentData == data || ![data isKindOfClass:[FHFloorPanDetailPropertyListModel class]]) {
        return;
    }
    self.currentData = data;
    FHFloorPanDetailPropertyListModel *model = (FHFloorPanDetailPropertyListModel *)data;
    adjustImageScopeType(model)
    __block UIView *lastView = nil; // 最后一个视图
     NSInteger count = model.baseInfo.count;
    for (UIView *v in self.itemArray) {
        [v removeFromSuperview];
    }
     if (count > 0) {
         NSMutableArray *singles = [NSMutableArray new];
         __block NSInteger doubleCount = 0;// 两列计数
         __block CGFloat topOffset = kGrayLineX + 10;// 高度
         __block CGFloat listRowHeight = 29;// 30
         CGFloat viewWidth = (UIScreen.mainScreen.bounds.size.width - 40) / 2;
         [model.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             if (obj.isSingle) {
                 [singles addObject:obj];
             } else {
                 // 两列
                 FHPropertyListCorrectingRowView *rowView = [[FHPropertyListCorrectingRowView alloc] init];
                 rowView.keyLabel.text = obj.attr;
                 rowView.valueLabel.text = obj.value;
                 rowView.keyLabel.font = [UIFont themeFontRegular:14];
                 rowView.valueLabel.font = [UIFont themeFontMedium:14];
                 rowView.keyLabel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
                 rowView.valueLabel.textColor = [UIColor themeGray2];
                 [self.contentView addSubview:rowView];
                 [self.itemArray addObject:rowView];
                 lastView = rowView;
                 if (doubleCount % 2 == 0) {
                     // 第1列
                     [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
                         make.top.mas_equalTo(topOffset);
                         make.left.mas_equalTo(31);
                         make.width.mas_equalTo(viewWidth);
                         make.height.mas_equalTo(listRowHeight);
                     }];
                 } else {
                     // 第2列
                     [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
                         make.top.mas_equalTo(topOffset);
                         make.left.mas_equalTo(31 + viewWidth);
                         make.width.mas_equalTo(viewWidth);
                         make.height.mas_equalTo(listRowHeight);
                     }];
                     topOffset += listRowHeight;
                 }
                 doubleCount += 1;
             }
         }];
         // 添加单列数据
         if (singles.count > 0) {
             // 重新计算topOffset
             topOffset = kGrayLineX + 10 + (doubleCount / 2 + doubleCount % 2) * listRowHeight;
             [singles enumerateObjectsUsingBlock:^(FHHouseCoreInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 FHPropertyListCorrectingRowView *v = [[FHPropertyListCorrectingRowView alloc] init];
                 [self.contentView addSubview:v];
                 [self.itemArray addObject:v];
                 v.keyLabel.text = obj.attr;
                 v.valueLabel.text = obj.value;
                 v.keyLabel.font = [UIFont themeFontRegular:14];
                 v.valueLabel.font = [UIFont themeFontMedium:14];
                 v.keyLabel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
                 v.valueLabel.textColor = [UIColor themeGray2];
                 [v.keyLabel sizeToFit];
                 CGFloat keyWidth = ceil([v.keyLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 31 * 2, v.keyLabel.font.lineHeight)].width);
                 
                 [v.keyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.left.mas_equalTo(0);
                     make.top.mas_equalTo(10);
                     make.width.mas_equalTo(keyWidth);
                     make.height.mas_equalTo(20);
                 }];
                 v.valueLabel.numberOfLines = 0;
                 NSDictionary *attributes = @{NSFontAttributeName: [UIFont themeFontMedium:14]};
                 CGRect rect = [obj.value boundingRectWithSize:CGSizeMake(SCREEN_WIDTH- 31*2 - 10 - keyWidth, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:attributes
                                                       context:nil];
                 CGFloat valueHeight = ceil(rect.size.height);
                 //number lins > 1
                 if (valueHeight <= 21) {
                     valueHeight = listRowHeight - 10;
                 }
                 [v.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.left.mas_equalTo(v.keyLabel.mas_right).offset(10);
                     make.top.mas_equalTo(10);
                     make.height.mas_equalTo(valueHeight);
                     make.width.mas_equalTo(ceil(rect.size.width));
                     make.bottom.mas_equalTo(v);
                 }];
                 
                 [v mas_makeConstraints:^(MASConstraintMaker *make) {
                     make.top.mas_equalTo(topOffset);
                     make.left.mas_equalTo(31);
                     make.right.mas_equalTo(-31);
                     make.height.mas_equalTo(valueHeight + 10);
                 }];
                 lastView = v;
                 
                 topOffset += valueHeight + 10;
             }];
         }
         
         if (model.baseExtra) {
             //所属楼盘信息
             if (model.baseExtra.court) {
                 FHDetailExtarInfoCorrectingRowView *rowView = [[FHDetailExtarInfoCorrectingRowView alloc] initWithFrame:CGRectMake(31, topOffset, CGRectGetWidth(self.contentView.bounds) - 31 * 2, listRowHeight)];
                 rowView.logoImageView.hidden = YES;
                 rowView.indicatorLabel.hidden = YES;
                 [rowView.nameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
                 rowView.nameLabel.font = [UIFont themeFontRegular:14];
                 rowView.nameLabel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
                 rowView.nameLabel.text = model.baseExtra.court.title;
                 rowView.infoLabel.font = [UIFont themeFontMedium:14];
                 rowView.infoLabel.textColor = [UIColor themeGray2];
                 rowView.infoLabel.text = model.baseExtra.court.content;
                 [rowView addTarget:self action:@selector(jumpToDetailNewPage:) forControlEvents:UIControlEventTouchUpInside];
                 [self.contentView addSubview:rowView];
                 [self.itemArray addObject:rowView];
                 [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
                     make.top.mas_equalTo(topOffset);
                     make.left.mas_equalTo(31);
                     make.right.mas_equalTo(-31);
                     make.height.mas_equalTo(listRowHeight);
                 }];
                 [rowView.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.left.mas_equalTo(0);
                     make.top.mas_equalTo(10);
                     make.bottom.mas_equalTo(0);
                 }];
                 [rowView.indicator mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.right.mas_equalTo(0);
                     make.size.mas_equalTo(CGSizeMake(20, 20));
                     make.centerY.mas_equalTo(rowView.nameLabel);
                 }];
                 [rowView.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.left.mas_equalTo(rowView.nameLabel.mas_right).offset(10);
                     make.top.mas_equalTo(10);
                     make.bottom.mas_equalTo(0);
                     make.right.mas_lessThanOrEqualTo(rowView.indicator.mas_left).offset(-10);
                 }];
                 
                 topOffset += listRowHeight;
                 lastView = rowView;
             }
             //楼盘地址
             if (model.baseExtra.address) {
                 FHDetailExtarInfoCorrectingRowView *rowView = [[FHDetailExtarInfoCorrectingRowView alloc] initWithFrame:CGRectMake(31, topOffset, CGRectGetWidth(self.contentView.bounds) - 31 * 2, listRowHeight)];
                 rowView.logoImageView.hidden = YES;
                 rowView.indicatorLabel.hidden = YES;
                 [rowView.nameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
                 rowView.nameLabel.font = [UIFont themeFontRegular:14];
                 rowView.nameLabel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
                 rowView.nameLabel.text = model.baseExtra.address.title;
                 rowView.infoLabel.font = [UIFont themeFontMedium:14];
                 rowView.infoLabel.textColor = [UIColor themeGray2];
                 rowView.infoLabel.text = model.baseExtra.address.content;
                 [rowView addTarget:self action:@selector(jumpToDetailNewAddressPage:) forControlEvents:UIControlEventTouchUpInside];
                 [self.contentView addSubview:rowView];
                 [self.itemArray addObject:rowView];
                 [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
                     make.top.mas_equalTo(topOffset);
                     make.left.mas_equalTo(31);
                     make.right.mas_equalTo(-31);
                     make.height.mas_equalTo(listRowHeight);
                 }];
                 [rowView.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.left.mas_equalTo(0);
                     make.top.mas_equalTo(10);
                     make.bottom.mas_equalTo(0);
                 }];
                 
                 [rowView.indicator mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.right.mas_equalTo(0);
                     make.size.mas_equalTo(CGSizeMake(20, 20));
                     make.centerY.mas_equalTo(rowView.nameLabel);
                 }];
                 
                 [rowView.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.left.mas_equalTo(rowView.nameLabel.mas_right).offset(10);
                     make.top.mas_equalTo(10);
                     make.bottom.mas_equalTo(0);
                     make.right.mas_lessThanOrEqualTo(rowView.indicator.mas_left).offset(-10);
                 }];
                 topOffset += listRowHeight;
                 lastView = rowView;
             }
         }
     }
    [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.shadowImage.mas_bottom).offset(-50);
    }];
    [self layoutIfNeeded];
}

- (void)setupUI
{
    [self.contentView addSubview:self.shadowImage];
    self.grayLineView = [[UIView alloc]init];
   // self.grayLineView.backgroundColor = [UIColor colorWithHexStr:@"#e7e7e7"];
    self.grayLineView.layer.borderColor = [[UIColor colorWithHexStr:@"#e7e7e7"] CGColor];
    self.grayLineView.layer.borderWidth = 0.5;
    [self.contentView addSubview:self.grayLineView];
    
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.grayLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(34);
        make.right.mas_equalTo(self.contentView).offset(- 34);
        make.top.mas_equalTo(self.contentView).offset(kGrayLineX);
        make.height.mas_equalTo(0.5);
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
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//跳转新房详情页，如果是从详情页来的，则回到房源详情页，否则跳转详情页
- (void)jumpToDetailNewPage:(id)sender {
    FHFloorPanDetailPropertyListModel *model = (FHFloorPanDetailPropertyListModel *)self.currentData;
    NSMutableDictionary *traceParam = self.baseViewModel.detailTracerDic;
    traceParam[@"enter_from"] = @"house_model_detail";
    traceParam[@"element_from"] = @"house_info";
//    traceParam[@"card_type"] = @"left_pic";
//    traceParam[@"enter_from"] = [self categoryName];
//    traceParam[@"log_pb"] = [cellModel logPb];
//    traceParam[@"rank"] = @(rank);
    NSDictionary *dict = @{
        @"house_type":@(FHHouseTypeNewHouse),
        @"court_id":model.courtId?:@"",
        @"tracer": traceParam.copy};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail"];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:urlStr] userInfo:userInfo];
}

//跳转
- (void)jumpToDetailNewAddressPage:(id)sender {
    FHFloorPanDetailPropertyListModel *model = (FHFloorPanDetailPropertyListModel *)self.currentData;
    //地图页调用示例
    NSString *longitude = model.baseExtra.address.gaodeLng;
    NSString *latitude = model.baseExtra.address.gaodeLat;
    
//    NSString *selectCategory = [self.curCategory isEqualToString:@"交通"] ? @"公交" : self.curCategory;
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    [infoDict setValue:@"公交" forKey:@"category"];
    [infoDict setValue:latitude?:@"" forKey:@"latitude"];
    [infoDict setValue:longitude?:@"" forKey:@"longitude"];
//    [infoDict setValue:dataModel.mapCentertitle forKey:@"title"];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionaryWithDictionary:self.baseViewModel.detailTracerDic];
    [tracer setValue:@"map" forKey:@"click_type"];
    [tracer setValue:@"house_info" forKey:@"element_from"];
    [tracer setObject:tracer[@"page_type"] forKey:@"enter_from"];
    [infoDict setValue:tracer forKey:@"tracer"];
    
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fh_map_detail"] userInfo:info];
}


@end
@implementation FHFloorPanDetailPropertyListModel



@end

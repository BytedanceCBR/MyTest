//
//  FHNewHouseDetailPropertyListCollectionCell.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailPropertyListCollectionCell.h"
#import <FHHouseBase/FHHouseBaseInfoModel.h>
#import "FHPropertyListCorrectingRowView.h"

@interface FHNewHouseDetailPropertyListCollectionCell ()

@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) UIButton *detailBtn;

@end

@implementation FHNewHouseDetailPropertyListCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNewHouseDetailPropertyListCellModel class]]) {
        FHNewHouseDetailPropertyListCellModel *model = (FHNewHouseDetailPropertyListCellModel *)data;
        NSMutableArray *singles = [NSMutableArray new];
        __block NSInteger doubleCount = 0;// 两列计数
        [model.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isSingle) {
                obj.realIndex = idx;
                [singles addObject:obj];
            } else {
                doubleCount += 1;
            }}];
        CGFloat height = 0;
        height += singles.count * 28;
        height += ceilf(doubleCount/2.0) * 28;
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.detailBtn = [[UIButton alloc] init];
//        UIImage *img = ICON_FONT_IMG(16, @"\U0000e670", [UIColor themeGray3]);
//        [_detailBtn setImage:img forState:UIControlStateNormal];
        self.detailBtn.backgroundColor = [UIColor colorWithHexString:@"#f7f7f7"];
        self.detailBtn.layer.cornerRadius = 4;
        self.detailBtn.layer.masksToBounds = YES;
        [self.detailBtn setTitle:@"详\n情" forState:UIControlStateNormal];
        self.detailBtn.titleLabel.numberOfLines = 0;
        [self.detailBtn setTitleColor:[UIColor themeGray2] forState:UIControlStateNormal];
        self.detailBtn.titleLabel.font = [UIFont themeFontRegular:12];
        [self.contentView addSubview:self.detailBtn];
        [self.detailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(48);
            make.width.mas_equalTo(22);
            make.centerY.mas_equalTo(self.contentView);
        }];
        [self.detailBtn addTarget:self action:@selector(detailBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailPropertyListCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHNewHouseDetailPropertyListCellModel *model = (FHNewHouseDetailPropertyListCellModel *)data;
    __block UIView *lastView = nil; // 最后一个视图
    NSInteger count = model.baseInfo.count;
    if (count > 0) {
        NSMutableArray *singles = [NSMutableArray new];
        __block NSInteger doubleCount = 0;// 两列计数
        __block CGFloat topOffset = 2;// 高度
        __block CGFloat listRowHeight = 28;//  原来间距是10 现在调整为8,文字距离item的顶部10,文字高20
        __block CGFloat lastViewLeftOffset = 20;
        __block CGFloat lastTopOffset = 20;
        CGFloat viewWidth = (self.contentView.bounds.size.width - 30 - 24) / 2;
        
//        __weak typeof(self) weakSelf = self;
        [model.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
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
                        make.left.mas_equalTo(15);
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
                        make.left.mas_equalTo(15 + viewWidth);
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
            topOffset = 6 + (doubleCount / 2 + doubleCount % 2) * listRowHeight;
            [singles enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHPropertyListCorrectingRowView *v = [[FHPropertyListCorrectingRowView alloc] init];
                v.tag = 100+obj.realIndex;
                [v addTarget:self action:@selector(openUrlDidClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:v];
                [self.itemArray addObject:v];
                [v mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(topOffset);
                    make.left.mas_equalTo(15);
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
        CGFloat btnTop = 6;
        [self.detailBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(btnTop + 14);
        }];
    }
//    [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self).offset(-16);
//    }];

}

- (void)openUrlDidClick:(UIControl *)btn
{
    NSInteger index = btn.tag - 100;
    FHNewHouseDetailPropertyListCellModel *model = (FHNewHouseDetailPropertyListCellModel *)self.currentData;

    if (index < 0 || index >= model.baseInfo.count) {
        return;
    }
    FHHouseBaseInfoModel *obj = model.baseInfo[index];
    if (obj.openUrl.length > 0) {
        NSURL *url = [NSURL URLWithString:obj.openUrl];
        [[TTRoute sharedRoute]openURLByPushViewController:url];
    }
}

- (void)detailBtnDidClick:(UIButton *)btn
{
    if (self.detailActionBlock) {
        self.detailActionBlock();
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"house_info";
}

@end

@implementation FHNewHouseDetailPropertyListCellModel

@end

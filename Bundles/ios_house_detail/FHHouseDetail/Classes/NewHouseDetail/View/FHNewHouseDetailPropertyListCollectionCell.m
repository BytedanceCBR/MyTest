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
        height += 10;
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
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
        __block CGFloat lastTopOffset = 20;
        CGFloat viewWidth = (self.contentView.bounds.size.width - 30 - 24) / 2;
        
//        __weak typeof(self) weakSelf = self;
        [model.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (obj.isSingle) {
                obj.realIndex = idx;
                [singles addObject:obj];
            } else {
                // 两列
                FHPropertyListCorrectingRowView *rowView = [[FHPropertyListCorrectingRowView alloc] init];
                rowView.tag = 100+idx;
                [rowView addTarget:self action:@selector(openUrlDidClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:rowView];
                [self.itemArray addObject:rowView];
                rowView.keyLabel.text = obj.attr;
                rowView.valueLabel.text = obj.value;
                rowView.keyLabel.font = [UIFont themeFontRegular:14];
                rowView.valueLabel.font = [UIFont themeFontMedium:14];
                rowView.valueLabel.textColor = obj.color.length > 0 ? [UIColor colorWithHexString:obj.color] : [UIColor themeGray1];
                lastView = rowView;
                lastTopOffset = topOffset;
                if (doubleCount % 2 == 0) {
                    // 第1列
                    [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(topOffset);
                        make.left.mas_equalTo(15);
                        make.width.mas_equalTo(viewWidth);
                        make.height.mas_equalTo(listRowHeight);
                    }];
                } else {
                    // 第2列
                    [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(topOffset);
                        make.left.mas_equalTo(15 + viewWidth);
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
            topOffset = 6 + (doubleCount / 2 + doubleCount % 2) * listRowHeight;
            [singles enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHPropertyListCorrectingRowView *rowView = [[FHPropertyListCorrectingRowView alloc] init];
                rowView.tag = 100+obj.realIndex;
                [rowView addTarget:self action:@selector(openUrlDidClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:rowView];
                [self.itemArray addObject:rowView];
                [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(topOffset);
                    make.left.mas_equalTo(15);
                    make.width.mas_equalTo(viewWidth * 2);
                    make.height.mas_equalTo(listRowHeight);
                }];
                rowView.keyLabel.text = obj.attr;
                rowView.valueLabel.text = obj.value;
                rowView.keyLabel.font = [UIFont themeFontRegular:14];
                rowView.valueLabel.font = [UIFont themeFontMedium:14];
                rowView.valueLabel.textColor = obj.color.length > 0 ? [UIColor colorWithHexString:obj.color] : [UIColor themeGray1];
                lastView = rowView;
                lastTopOffset = topOffset;
                topOffset += listRowHeight;
            }];
        }
    }
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

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"house_info";
}

@end

@implementation FHNewHouseDetailPropertyListCellModel

@end

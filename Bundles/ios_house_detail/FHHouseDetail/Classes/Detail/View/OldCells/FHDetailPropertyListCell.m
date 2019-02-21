//
//  FHDetailPropertyListCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/13.
//

#import "FHDetailPropertyListCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "UILabel+House.h"

@implementation FHDetailPropertyListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailPropertyListModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.contentView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailPropertyListModel *model = (FHDetailPropertyListModel *)data;
    NSInteger count = model.baseInfo.count;
    if (count > 0) {
        NSMutableArray *singles = [NSMutableArray new];
        __block NSInteger doubleCount = 0;// 两列计数
        __block CGFloat topOffset = 6;// 高度
        __block CGFloat listRowHeight = 29;// 30
        __block UIView *lastView = nil; // 最后一个视图
        __block CGFloat lastViewLeftOffset = 20;
        __block CGFloat lastTopOffset = 20;
        CGFloat viewWidth = (UIScreen.mainScreen.bounds.size.width - 40) / 2;
        [model.baseInfo enumerateObjectsUsingBlock:^(FHDetailDataBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isSingle) {
                [singles addObject:obj];
            } else {
                // 两列
                if (doubleCount % 2 == 0) {
                    // 第1列
                    FHPropertyListRowView *v = [[FHPropertyListRowView alloc] init];
                    [self.contentView addSubview:v];
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(topOffset);
                        make.left.mas_equalTo(20);
                        make.width.mas_equalTo(viewWidth);
                        make.height.mas_equalTo(listRowHeight);
                    }];
                    v.keyLabel.text = obj.attr;
                    v.valueLabel.text = obj.value;
                    lastView = v;
                    lastViewLeftOffset = 20;
                    lastTopOffset = topOffset;
                } else {
                    // 第2列
                    FHPropertyListRowView *v = [[FHPropertyListRowView alloc] init];
                    [self.contentView addSubview:v];
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(topOffset);
                        make.left.mas_equalTo(20 + viewWidth);
                        make.width.mas_equalTo(viewWidth);
                        make.height.mas_equalTo(listRowHeight);
                    }];
                    v.keyLabel.text = obj.attr;
                    v.valueLabel.text = obj.value;
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
            [singles enumerateObjectsUsingBlock:^(FHDetailDataBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHPropertyListRowView *v = [[FHPropertyListRowView alloc] init];
                [self.contentView addSubview:v];
                [v mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(topOffset);
                    make.left.mas_equalTo(20);
                    make.width.mas_equalTo(viewWidth * 2);
                    make.height.mas_equalTo(listRowHeight);
                }];
                v.keyLabel.text = obj.attr;
                v.valueLabel.text = obj.value;
                lastView = v;
                lastViewLeftOffset = 20;
                lastTopOffset = topOffset;
                
                topOffset += listRowHeight;
            }];
        }
        // 父视图布局
        if (lastView) {
            CGFloat vWidTemp = viewWidth;
            if (lastViewLeftOffset < 30) {
                // 单行
                vWidTemp = viewWidth * 2;
            }
            [lastView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(lastTopOffset);
                make.left.mas_equalTo(lastViewLeftOffset);
                make.width.mas_equalTo(vWidTemp);
                make.height.mas_equalTo(listRowHeight);
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-20);
            }];
        }
    }
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

- (void)setupUI {
    
}

@end


@implementation FHPropertyListRowView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = UIColor.whiteColor;
    _keyLabel = [UILabel createLabel:@"" textColor:@"#8a9299" fontSize:14];
    [self addSubview:_keyLabel];
    [_keyLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_keyLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    _valueLabel = [UILabel createLabel:@"" textColor:@"#081f33" fontSize:14];
    [self addSubview:_valueLabel];
    _valueLabel.textAlignment = NSTextAlignmentLeft;
    
    // 布局
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.keyLabel.mas_right).offset(10);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self.keyLabel);
    }];
}


@end


@implementation FHDetailPropertyListModel


@end

//
//  FHRowsView.m
//  FHHouseRent
//
//  Created by leo on 2018/11/20.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FHRowsView.h"
#import "FHSpringboardView.h"
#import <Masonry/Masonry.h>

@implementation FHRowsView

- (instancetype)initWithRowCount:(NSInteger)rowCount {
    self = [self initWithRowCount:rowCount withRowHight:70];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithRowCount:(NSInteger)rowCount withRowHight:(NSInteger) rowHight {
    self = [super init];
    if (self) {
        _rowCount = rowCount;
        _rowHight = rowHight;
    }
    return self;
}

-(void)addRowItemViews:(NSArray<id<RowItemView>>*)rows {
    if ([rows count] > 1) {
        [rows enumerateObjectsUsingBlock:^(id<RowItemView>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addSubview:obj];
        }];
        
        [rows mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        [rows mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self);
            //            make.height.mas_equalTo(_rowHight);
        }];
    } else {
        id<RowItemView> view = rows.firstObject;
        [rows enumerateObjectsUsingBlock:^(id<RowItemView>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addSubview:obj];
        }];
        if ([view isKindOfClass:[UIView class]]) {
            UIView* theView = (UIView*)view;
            [theView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.mas_equalTo(self);
            }];
        }
    }
}

-(void)addItemViews:(NSArray<id<FHSpringboardItemView>>*)items {
    NSMutableArray* rows = [[NSMutableArray alloc] init];
    NSMutableArray* rowViews = [[NSMutableArray alloc] init];
    __block FHSpringboardView* rowView = [[FHSpringboardView alloc] initWithRowCount:_rowCount];
    [items enumerateObjectsUsingBlock:^(id<FHSpringboardItemView>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        FHSpringboardIconItemView *objV = (FHSpringboardIconItemView *)obj;
        [objV addGestureRecognizer:tapGes];
        
        if ((idx + 1) % self->_rowCount != 0 && idx != ([items count] - 1)) {
            [rows addObject:obj];
        } else {
            [rows addObject:obj];
            [rowView addItems:[rows copy]];
            [rows removeAllObjects];
            [rowViews addObject:rowView];
            rowView = [[FHSpringboardView alloc] initWithRowCount:self->_rowCount];
        }
    }];
    self.currentItems = items;
    [self addRowItemViews:rowViews];
}

- (void)tapClick:(UITapGestureRecognizer *)tap
{
    UIView *tapView = tap.view;
    if (self.clickedCallBack) {
        self.clickedCallBack(tapView.tag);
    }
}


@end

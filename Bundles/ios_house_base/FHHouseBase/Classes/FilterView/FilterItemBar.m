//
//  FilterItemBar.m
//  HouseRent
//
//  Created by leo on 2018/11/15.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FilterItemBar.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
@interface FilterItemWrapper : UIControl
@property (nonatomic, weak) UIView<FHFilterItem>* contentView;
@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, assign) BOOL isSelected;
+(instancetype)instanceWithItemView:(UIView<FHFilterItem>*)itemView;
-(instancetype)initWithItemView:(UIView<FHFilterItem>*)itemView;

@end

@implementation FilterItemWrapper

+(instancetype)instanceWithItemView:(UIView<FHFilterItem>*)itemView {
    FilterItemWrapper* instance = [[FilterItemWrapper alloc] initWithItemView:itemView];
    return instance;
}

-(instancetype)initWithItemView:(UIView<FHFilterItem>*)itemView {
    self = [super init];
    if (self) {
        self.contentView = itemView;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

@end


@interface FilterItemBar ()
@property (nonatomic, strong) NSMutableArray<FilterItemWrapper*>* items;
@end

@implementation FilterItemBar

+ (instancetype)instanceWithItems:(UIView<FHFilterItem> *)items {
    FilterItemBar* result = [[FilterItemBar alloc] initWithItems:items];
    return result;
}

- (instancetype)initWithItems:(NSArray<UIView<FHFilterItem>*> *) items {
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        __weak typeof(self) weakRef = self;
        [items enumerateObjectsUsingBlock:^(UIView<FHFilterItem> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.userInteractionEnabled = false;
            FilterItemWrapper* wrapper = [FilterItemWrapper instanceWithItemView:obj];
            wrapper.idx = idx;
            [weakRef addSubview:wrapper];
            [self->_items addObject:wrapper];
            [wrapper addTarget:self action:@selector(onItemClick:) forControlEvents:UIControlEventTouchUpInside];
        }];
        [self setItemsLayout];
    }
    return self;
}

-(void)setItemsLayout {
    [_items mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                        withFixedSpacing:0
                             leadSpacing:0
                             tailSpacing:0];
    [_items enumerateObjectsUsingBlock:^(UIView<FHFilterItem> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self);
        }];
    }];
}

-(void)onItemClick:(id)sender {
    NSLog(@"onItemClick %@", sender);
    if ([sender isKindOfClass:[FilterItemWrapper class]]) {
        FilterItemWrapper* wrapper = (FilterItemWrapper*)sender;
        NSInteger theIdx = wrapper.idx;
        __block BOOL isExpand = NO;
        [_items enumerateObjectsUsingBlock:^(FilterItemWrapper * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx != theIdx) {
                if (obj.isSelected) {
                    [obj.contentView onSelected:NO];
                    obj.isSelected = NO;
                }
            } else {
                if (obj.isSelected) {
                    [obj.contentView onSelected:NO];
                    obj.isSelected = NO;
                } else {
                    [obj.contentView onSelected:YES];
                    obj.isSelected = YES;
                    isExpand = YES;
                }
            }
        }];
        [_stateChangedDelegate onPanelExpand:isExpand];
    }
}

- (void)packUp {
    [_items enumerateObjectsUsingBlock:^(FilterItemWrapper * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelected) {
            obj.isSelected = NO;
            [obj.contentView onSelected:NO];
        }
    }];
    [_stateChangedDelegate onPanelExpand:NO];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

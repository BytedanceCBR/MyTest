//
//  FHHomeBannerView.m
//  Article
//
//  Created by 谢飞 on 2018/11/20.
//

#import "FHHomeBannerView.h"
#import <Masonry/Masonry.h>
#import "TTDeviceHelper.h"

@implementation FHHomeBannerView

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

-(void)addRowItemViews:(NSArray *)rows {
    if ([rows count] > 1) {
        [rows enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addSubview:obj];
        }];
        
        [rows mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        [rows mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(_rowHight);
        }];
    } else {
        UIView * view = rows.firstObject;
        [rows enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

-(void)addItemViews:(NSArray<FHHomeBannerItem *> *)items {
    NSMutableArray* rows = [[NSMutableArray alloc] init];
    NSMutableArray* rowViewArray = [[NSMutableArray alloc] init];
    __block FHHomeBannerBoardView* rowView = [[FHHomeBannerBoardView alloc] initWithRowCount:_rowCount];
    [items enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        FHHomeBannerItem *objV = (FHHomeBannerItem *)obj;
        [objV addGestureRecognizer:tapGes];

        if ((idx + 1) % self->_rowCount != 0 && idx != ([items count] - 1)) {
            [rows addObject:obj];
        } else {
            [rows addObject:obj];
            [rowView addItems:[rows copy]];
            [rows removeAllObjects];
            [rowViewArray addObject:rowView];
            rowView = [[FHHomeBannerBoardView alloc] initWithRowCount:self->_rowCount];
        }
    }];
    self.currentItems = items;
    [self addRowItemViews:rowViewArray];
}

- (void)tapClick:(UITapGestureRecognizer *)tap
{
    UIView *tapView = tap.view;
    if (self.clickedCallBack) {
        self.clickedCallBack(tapView.tag);
    }
}


@end

@implementation FHHomeBannerItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.iconView = [[UIImageView alloc] init];
    [self addSubview:_iconView];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(60 * [TTDeviceHelper scaleToScreen375]);
        make.top.mas_equalTo(self).offset(10);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    _iconView.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [[UILabel alloc] init];
    [_iconView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconView).offset(12);
        make.top.mas_equalTo(12);
    }];
    
    self.subTitleLabel = [[UILabel alloc] init];
    [_iconView addSubview:_subTitleLabel];
    [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_titleLabel);
        make.bottom.mas_equalTo(-13);
    }];
    
}

@end

@implementation FHHomeBannerBoardView

- (instancetype)init
{
    self = [self initWithRowCount:2];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithRowCount:(NSInteger)count
{
    self = [super init];
    if (self) {
        self.count = count;
    }
    return self;
}

-(void)addItems:(NSArray<FHHomeBannerItem*>*)items {
    NSParameterAssert(items);
    NSAssert([items count] <= _count, @"此控件限制一行只能显示4个icon");
    if ([items count] > _count) {
        return;
    }
    [[self subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    __weak typeof(self) weakRef = self;
    [items enumerateObjectsUsingBlock:^(FHHomeBannerItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakRef addSubview:obj];
    }];
    self.currentItems = items;
    [self layoutItems:items];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutItems:_currentItems];
}

-(void)layoutItems:(NSArray<FHHomeBannerItem*>*)items {
    CGFloat itemWidth = [[UIScreen mainScreen] bounds].size.width / _count;
    [items enumerateObjectsUsingBlock:^(FHHomeBannerItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(idx * itemWidth);
            make.width.mas_equalTo(itemWidth);
            make.top.bottom.mas_equalTo(self);
        }];
        obj.backgroundColor = [UIColor whiteColor];
    }];
}


@end



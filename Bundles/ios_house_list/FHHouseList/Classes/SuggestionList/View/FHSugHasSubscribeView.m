//
//  FHSugHasSubscribeView.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/20.
//

#import "FHSugHasSubscribeView.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import "FHUserTracker.h"

@interface FHSugHasSubscribeView ()

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, strong)   UIButton       *rightButton;
@property (nonatomic, strong)   UIButton       *headerButton;
@property (nonatomic, strong)   NSMutableArray       *tempViews;
@property (nonatomic, strong)   NSMutableDictionary *tracerCacheDic;// 埋点
@property (nonatomic, strong)   UIView *redView;
@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic, strong) NSMutableDictionary *isTractedDict;

@end

@implementation FHSugHasSubscribeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dict = [NSMutableDictionary new];
        _isTractedDict = [NSMutableDictionary new];
        self.backgroundColor = [UIColor whiteColor];
        self.totalCount = 0;
        self.tempViews = [NSMutableArray new];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 埋点cache
    self.tracerCacheDic = [NSMutableDictionary new];
    
    // headerButton
    _headerButton = [[UIButton alloc] init];
    _headerButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:_headerButton];
    
    // label
    _label = [[UILabel alloc] init];
    _label.text = @"已订阅搜索";
    _label.font = [UIFont themeFontMedium:16];
    _label.textColor = [UIColor themeGray1];
    [_label sizeToFit];
    [self addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(22);
        make.height.mas_equalTo(19);
    }];
    // rightButton
    _rightButton = [[UIButton alloc] init];
    [_rightButton setImage:[UIImage imageNamed:@"arrowicon-feed"] forState:UIControlStateNormal];
    [_rightButton setImage:[UIImage imageNamed:@"arrowicon-feed"] forState:UIControlStateHighlighted];
    [_rightButton sizeToFit];
    [self addSubview:_rightButton];
    [_rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-16);
        make.centerY.mas_equalTo(_label);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
    }];
    _rightButton.userInteractionEnabled = NO;
    // headerButton
    
    [_headerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(42);
    }];
    [_headerButton addTarget:self action:@selector(headerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)headerButtonClick:(UIButton *)button {
    if (self.clickHeader) {
        self.clickHeader();
    }
}

// 先设置totalCount
- (void)setSubscribeItems:(NSArray<FHSugSubscribeDataDataItemsModel> *)subscribeItems {
    _subscribeItems = subscribeItems;
     [self reAddViews];
    if (self.vc.isCanTrack) {
        [self.dict enumerateKeysAndObjectsUsingBlock:^(NSString  *key, NSDictionary *obj, BOOL * _Nonnull stop) {
            if (!_isTractedDict[key] && [obj isKindOfClass:[NSDictionary class]]) {
                _isTractedDict[key] = @1;
                [FHUserTracker writeEvent:@"subscribe_card_show" params:obj];
            }
        }];
    }
}

- (void)reAddViews {
    for (UIView *v in self.tempViews) {
        [v removeFromSuperview];
    }
    [self.tempViews removeAllObjects];
    if (self.subscribeItems.count <= 0) {
        self.hasSubscribeViewHeight = CGFLOAT_MIN;
        return;
    }
    if (self.subscribeItems.count == 1) {
        self.hasSubscribeViewHeight = 102;
    } else {
        self.hasSubscribeViewHeight = 142;
    }
    // 显示右边箭头 可点击
    self.rightButton.hidden = NO;
    self.headerButton.hidden = NO;
    // 添加Views
    CGFloat topOffset = 52;
    [self.subscribeItems enumerateObjectsUsingBlock:^(FHSugSubscribeDataDataItemsModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        FHSubscribeView *itemView = [[FHSubscribeView alloc] initWithFrame:CGRectMake(0, topOffset + idx * 40, [[UIScreen mainScreen] bounds].size.width, 40)];
        itemView.sugLabel.text = [NSString stringWithFormat:@"%@/%@", obj.title, obj.text];
        itemView.tag = idx;
        [self addSubview:itemView];
         [itemView addTarget:self action:@selector(subscribeViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.tempViews addObject:itemView];
        [self addItemShowTracer:obj index:idx];
        if (idx >= 1) {
            *stop = YES;
        }
    }];
}

- (NSString *)wordType {
    NSString *word_type = @"be_null";
    switch (self.houseType) {
        case FHHouseTypeSecondHandHouse:
            word_type = @"old";
            break;
        case FHHouseTypeNewHouse:
            word_type = @"new";
            break;
        case FHHouseTypeRentHouse:
            word_type = @"rent";
            break;
        case FHHouseTypeNeighborhood:
            word_type = @"neighborhood";
            break;
        default:
            break;
    }
    return word_type;
}

- (void)addItemShowTracer:(FHSugSubscribeDataDataItemsModel* )item index:(NSInteger)index {
    if (item) {
        NSString *subscribe_id = item.subscribeId;
        if (subscribe_id.length > 0) {
            if (self.tracerCacheDic[subscribe_id]) {
                return;
            }
            NSString *key = [NSString stringWithFormat:@"%p", item];
            self.tracerCacheDic[subscribe_id] = @"1";
            NSMutableDictionary *tracerDic = @{@"subscribe_id":subscribe_id}.mutableCopy;
            tracerDic[@"title"] = item.title.length > 0 ? item.title : @"be_null";
            tracerDic[@"text"] = item.text.length > 0 ? item.text : @"be_null";
            tracerDic[@"word_type"] = [self wordType];
            tracerDic[@"page_type"] = @"search_detail";
            tracerDic[@"rank"] = @(index);
            _dict[key] = tracerDic;
        }
    }
}

- (void)subscribeViewClick:(FHSubscribeView *)v {
    NSInteger idx = v.tag;
    if (idx >= 0 && idx < self.subscribeItems.count) {
        FHSugSubscribeDataDataItemsModel*  obj = self.subscribeItems[idx];
        if (self.clickBlk) {
            self.clickBlk(obj);
            [self addItemClickTracer:obj index:idx];
        }
    }
}

- (void)addItemClickTracer:(FHSugSubscribeDataDataItemsModel* )item index:(NSInteger)index {
    if (item) {
        NSString *subscribe_id = item.subscribeId;
        if (subscribe_id.length > 0) {
            NSMutableDictionary *tracerDic = @{@"subscribe_id":subscribe_id}.mutableCopy;
            tracerDic[@"title"] = item.title.length > 0 ? item.title : @"be_null";
            tracerDic[@"text"] = item.text.length > 0 ? item.text : @"be_null";
            tracerDic[@"word_type"] = [self wordType];
            tracerDic[@"page_type"] = @"search_detail";
            tracerDic[@"rank"] = @(index);
            [FHUserTracker writeEvent:@"subscribe_card_click" params:tracerDic];
        }
    }
}

@end


@interface FHSubscribeView ()

@property (nonatomic, strong)   UILabel       *unValidLabel; // 已失效

@end

@implementation FHSubscribeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // sugLabel
    _sugLabel = [[UILabel alloc] init];
    _sugLabel.text = @"";
    _sugLabel.font = [UIFont themeFontRegular:14];
    _sugLabel.textColor = [UIColor blackColor];
    [_sugLabel sizeToFit];
    [self addSubview:_sugLabel];
    [_sugLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
}

@end

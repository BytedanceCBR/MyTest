//
//  FHPriceValuationMoreInfoView.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/27.
//

#import "FHPriceValuationMoreInfoView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>

@interface FHPriceValuationMoreInfoView()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIView *inputView;
@property(nonatomic, strong) FHPriceValuationSelectionView *decorateTypeView;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, assign) CGFloat naviBarHeight;
@property(nonatomic, strong) UIView *bottomView;
@property(nonatomic, strong) UIButton *bottomBtn;

@end

@implementation FHPriceValuationMoreInfoView

- (instancetype)initWithFrame:(CGRect)frame naviBarHeight:(CGFloat)naviBarHeight {
    self = [super initWithFrame:frame];
    
    if(self){
        self.backgroundColor = [UIColor themeGray7];
        self.naviBarHeight = naviBarHeight;
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    __weak typeof(self) wself = self;
    
    self.scrollView = [[UIScrollView alloc] init];
    [self addSubview:_scrollView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:24] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"补全信息 精确估价";
    [self.scrollView addSubview:_titleLabel];
    
    self.inputView = [[UIView alloc] init];
    _inputView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:_inputView];

    self.buildYearItemView = [[FHPriceValuationItemView alloc] initWithFrame:CGRectZero type:FHPriceValuationItemViewTypeNormal];
    _buildYearItemView.titleLabel.text = @"建筑年代";
    _buildYearItemView.contentLabel.textAlignment = NSTextAlignmentRight;
    _buildYearItemView.titleWidth = 70.0f;
    _buildYearItemView.tapBlock = ^{
        [wself chooseBuildYear];
    };
    [self.inputView addSubview:_buildYearItemView];

    self.orientationsItemView = [[FHPriceValuationItemView alloc] initWithFrame:CGRectZero type:FHPriceValuationItemViewTypeNormal];
    _orientationsItemView.titleLabel.text = @"朝向";
    _orientationsItemView.contentLabel.textAlignment = NSTextAlignmentRight;
    _orientationsItemView.tapBlock = ^{
        [wself chooseOrientations];
    };
    [self.inputView addSubview:_orientationsItemView];

    self.floorItemView = [[FHPriceValuationItemView alloc] initWithFrame:CGRectZero type:FHPriceValuationItemViewTypeNormal];
    _floorItemView.titleLabel.text = @"楼层";
    _floorItemView.contentLabel.textAlignment = NSTextAlignmentRight;
    _floorItemView.bottomLine.hidden = YES;
    
    _floorItemView.tapBlock = ^{
        [wself chooseFloor];
    };
    [self.inputView addSubview:_floorItemView];

    self.buildTypeLabel = [self LabelWithFont:[UIFont themeFontMedium:18] textColor:[UIColor themeGray1]];
    _buildTypeLabel.text = @"建筑类型";
    [self.scrollView addSubview:_buildTypeLabel];
    
    self.buildTypeView = [[FHPriceValuationSelectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 0)];
    _buildTypeView.titleArray = @[@"板楼",@"塔楼",@"板塔结合",@"平房"];
    _buildTypeView.valueArray = @[@"1",@"2",@"3",@"4"];
    _buildTypeView.selectedBlock = ^(NSInteger index, NSString * _Nonnull name, NSString *value) {
        [wself selectBuildType:value];
    };
    [self.scrollView addSubview:_buildTypeView];
    
    self.decorateTypeLabel = [self LabelWithFont:[UIFont themeFontMedium:18] textColor:[UIColor themeGray1]];
    _decorateTypeLabel.text = @"装修类型";
    [self.scrollView addSubview:_decorateTypeLabel];
    
    self.decorateTypeView = [[FHPriceValuationSelectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 0)];
    _decorateTypeView.titleArray = @[@"豪华装",@"精装",@"简装",@"毛坯"];
    _decorateTypeView.valueArray = @[@"5",@"2",@"1",@"3"];
    _decorateTypeView.selectedBlock = ^(NSInteger index, NSString * _Nonnull name, NSString *value) {
        [wself selectDecorateType:value];
    };
    [self.scrollView addSubview:_decorateTypeView];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:11] textColor:[UIColor themeGray4]];
    _descLabel.textAlignment = NSTextAlignmentCenter;
    _descLabel.numberOfLines = 0;
    _descLabel.text = @"基于幸福里APP海量二手房挂牌和成交大数据，综合市场行情和房屋信息，预估房屋市场价值，仅供参考";
    [self.scrollView addSubview:_descLabel];
    
    self.bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bottomView];
    
    self.bottomBtn = [[UIButton alloc] init];
    _bottomBtn.backgroundColor = [UIColor themeRed1];
    [_bottomBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _bottomBtn.titleLabel.font = [UIFont themeFontRegular:18];
    _bottomBtn.layer.cornerRadius = 4;
    _bottomBtn.layer.masksToBounds = YES;
    [_bottomBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:_bottomBtn];
    
}

- (void)initConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(30);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(33);
    }];
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(self.scrollView).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.bottom.mas_equalTo(self.floorItemView);
    }];

    [self.buildYearItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.inputView);
        make.height.mas_equalTo(50);
    }];

    [self.orientationsItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.buildYearItemView.mas_bottom);
        make.left.right.mas_equalTo(self.buildYearItemView);
        make.height.mas_equalTo(50);
    }];

    [self.floorItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orientationsItemView.mas_bottom);
        make.left.right.mas_equalTo(self.orientationsItemView);
        make.height.mas_equalTo(50);
    }];

    [self.buildTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.inputView.mas_bottom).offset(30);
        make.left.right.mas_equalTo(self.inputView);
        make.height.mas_equalTo(25);
    }];
    
    [self.buildTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.buildTypeLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(self.scrollView).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(self.buildTypeView.viewHeight);
    }];
    
    [self.decorateTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.buildTypeView.mas_bottom).offset(30);
        make.left.right.mas_equalTo(self.inputView);
        make.height.mas_equalTo(25);
    }];
    
    [self.decorateTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.decorateTypeLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(self.scrollView).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(self.decorateTypeView.viewHeight);
    }];

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.decorateTypeView.mas_bottom).offset(56);
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.bottom.mas_equalTo(self.scrollView).offset(-10);
    }];
    
    CGFloat bottom = 64;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(bottom);
    }];
    
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView).offset(10);
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(44);
    }];

    [self layoutIfNeeded];
    //当内容高度不足时，让描述文字贴近底部按钮
    CGFloat height = self.scrollView.contentSize.height;
    CGFloat scrollViewHeight = self.scrollView.frame.size.height - self.naviBarHeight;
    if(scrollViewHeight > height){
        CGFloat diff = scrollViewHeight - height;
        [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.decorateTypeView.mas_bottom).offset(56 + diff);
        }];
    }
    
    [self addShadowToView:self.inputView withOpacity:0.1 shadowRadius:8 andCornerRadius:4];
}

- (void)updateView:(FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *)infoModel {
    self.buildYearItemView.contentLabel.text = infoModel.builtYear;
    self.orientationsItemView.contentLabel.text = [self getOrientations:infoModel.facingType];
    if(infoModel.floor && infoModel.totalFloor && ![infoModel.floor isEqualToString:@"0"] && ![infoModel.totalFloor isEqualToString:@"0"]){
        self.floorItemView.contentLabel.text = [NSString stringWithFormat:@"%@层/共%@层",infoModel.floor,infoModel.totalFloor];
    }
    [self.buildTypeView selectedItem:[self getBuildType:infoModel.buildingType]];
    [self.decorateTypeView selectedItem:[self getDecorationType:infoModel.decorationType]];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

/*
 周边加阴影，并且同时圆角，注意这个方法必须在view已经布局完成能够获得frame的情况下使用
 */
- (void)addShadowToView:(UIView *)view
            withOpacity:(float)shadowOpacity
           shadowRadius:(CGFloat)shadowRadius
        andCornerRadius:(CGFloat)cornerRadius {
    //////// shadow /////////
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.frame = view.layer.frame;
    
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    shadowLayer.shadowOffset = CGSizeMake(2, 6);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    shadowLayer.shadowOpacity = shadowOpacity;//0.8;//阴影透明度，默认0
    shadowLayer.shadowRadius = shadowRadius;//8;//阴影半径，默认3
    
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float width = shadowLayer.bounds.size.width;
    float height = shadowLayer.bounds.size.height;
    float x = shadowLayer.bounds.origin.x;
    float y = shadowLayer.bounds.origin.y;
    
    CGPoint topLeft      = shadowLayer.bounds.origin;
    CGPoint topRight     = CGPointMake(x + width, y);
    CGPoint bottomRight  = CGPointMake(x + width, y + height);
    CGPoint bottomLeft   = CGPointMake(x, y + height);
    
    CGFloat offset = -1.f;
    [path moveToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    [path addArcWithCenter:CGPointMake(topLeft.x + cornerRadius, topLeft.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(topRight.x - cornerRadius, topRight.y - offset)];
    [path addArcWithCenter:CGPointMake(topRight.x - cornerRadius, topRight.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 * 3 endAngle:M_PI * 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomRight.x + offset, bottomRight.y - cornerRadius)];
    [path addArcWithCenter:CGPointMake(bottomRight.x - cornerRadius, bottomRight.y - cornerRadius) radius:(cornerRadius + offset) startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y + offset)];
    [path addArcWithCenter:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y - cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    
    //设置阴影路径
    shadowLayer.shadowPath = path.CGPath;
    
    //////// cornerRadius /////////
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [view.superview.layer insertSublayer:shadowLayer below:view.layer];
}

- (void)confirm {
    if(self.delegate && [self.delegate respondsToSelector:@selector(confirm)]){
        [self.delegate confirm];
    }
}

- (void)chooseBuildYear {
    if(self.delegate && [self.delegate respondsToSelector:@selector(chooseBuildYear)]){
        [self.delegate chooseBuildYear];
    }
}

- (void)chooseFloor {
    if(self.delegate && [self.delegate respondsToSelector:@selector(chooseFloor)]){
        [self.delegate chooseFloor];
    }
}

- (void)chooseOrientations {
    if(self.delegate && [self.delegate respondsToSelector:@selector(chooseOrientations)]){
        [self.delegate chooseOrientations];
    }
}

- (void)selectBuildType:(NSString *)type {
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectBuildType:)]){
        [self.delegate selectBuildType:type];
    }
}

- (void)selectDecorateType:(NSString *)type {
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectDecorateType:)]){
        [self.delegate selectDecorateType:type];
    }
}

- (NSString *)getBuildType:(NSString *)type {
    NSString *name = nil;
    NSInteger index = [type integerValue];
    switch (index) {
        case 1:
            name = @"板楼";
            break;
        case 2:
            name = @"塔楼";
            break;
        case 3:
            name = @"板塔结合";
            break;
        case 4:
            name = @"平房";
            break;
            
        default:
            break;
    }
    return name;
}

- (NSString *)getDecorationType:(NSString *)type {
    NSString *name = nil;
    NSInteger index = [type integerValue];
    switch (index) {
        case 1:
            name = @"简装";
            break;
        case 2:
            name = @"精装";
            break;
        case 3:
            name = @"毛坯";
            break;
        case 5:
            name = @"豪华装";
            break;
            
        default:
            break;
    }
    return name;
}

- (NSString *)getOrientations:(NSString *)type {
    NSString *name = nil;
    NSInteger index = [type integerValue];
    switch (index) {
        case 1:
            name = @"东";
            break;
        case 2:
            name = @"西";
            break;
        case 3:
            name = @"南";
            break;
        case 4:
            name = @"北";
            break;
        case 5:
            name = @"东南";
            break;
        case 6:
            name = @"西南";
            break;
        case 7:
            name = @"东北";
            break;
        case 8:
            name = @"西北";
            break;
        case 9:
            name = @"南北";
            break;
        case 10:
            name = @"东西";
            break;
            
        default:
            break;
    }
    return name;
}


@end

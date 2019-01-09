//
//  FHCityListCell.m
//  FHHouseHome
//
//  Created by 张元科 on 2019/1/6.
//

#import "FHCityListCell.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHCommonDefines.h"

@interface FHCityItemCell()

@end

@implementation FHCityItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    // descLabel
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.text = @"未开通";
    self.descLabel.textColor = [UIColor colorWithHexString:@"#e1e3e6"];
    self.descLabel.font = [UIFont themeFontRegular:12];
    [self.contentView addSubview:self.descLabel];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(17);
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-40);
    }];
    // cityNameLabel
    self.cityNameLabel = [[UILabel alloc] init];
    self.cityNameLabel.textColor = [UIColor themeBlue1];
    self.cityNameLabel.font = [UIFont themeFontRegular:15];
    [self.contentView addSubview:self.cityNameLabel];
    [self.cityNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(21);
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-60);
    }];
    self.enabled = NO;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.descLabel.hidden = enabled;
}

@end

// FHCityHotItemCell
@interface FHCityHotItemCell ()

@property (nonatomic, strong)   NSMutableArray       *rowViews;

@end

@implementation FHCityHotItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
        self.rowViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setCityList:(NSArray *)cityList {
    _cityList = cityList;
    [self reAddViews];
}

- (void)reAddViews {
    for (UIView *v in self.rowViews) {
        [v removeFromSuperview];
    }
    [self.rowViews removeAllObjects];
    CGFloat top = 12.0;
    CGFloat left = 20.0;
    CGFloat offset = 9.0;
    CGFloat right = 28.0;
    CGFloat width = (SCREEN_WIDTH - left - right - 3 * offset) / 4.0;
    CGFloat height = 28.0;
    
    NSInteger index = 0;
    for (NSString *cityName in self.cityList) {
        FHCityHotItemButton *btn = [[FHCityHotItemButton alloc] initWithFrame:CGRectMake(left, top, width, height)];
        btn.tag = index;
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.label.text = cityName;
        [self addSubview:btn];
        [self.rowViews addObject:btn];
        index += 1;
        if (index % 4 == 0) {
            top += (28 + 12);
            left = 20;
        } else {
            left += (width + offset);
        }
    }
}

- (void)buttonClick:(UIControl *)control {
    NSInteger index = control.tag;
    if (self.itemClickBlk) {
        self.itemClickBlk(index);
    }
}

@end


// FHCityItemHeaderView

@interface FHCityItemHeaderView ()

@end

@implementation FHCityItemHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    self.label = [[UILabel alloc] init];
    self.label.textColor = [UIColor themeGray4];
    self.label.font = [UIFont themeFontRegular:16];
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self).offset(6);
        make.right.mas_equalTo(self).offset(-20);
    }];
}

@end


// FHCityHotItemButton

@interface FHCityHotItemButton ()

@end

@implementation FHCityHotItemButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 4.0;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    self.label = [[UILabel alloc] init];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor colorWithHexString:@"#45494d"];
    self.label.font = [UIFont themeFontRegular:14 * UIScreen.mainScreen.bounds.size.width / 375.0];
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(self).offset(-5);
        make.height.mas_equalTo(24);
        make.top.mas_equalTo(self).offset(7);
        make.bottom.mas_equalTo(self).offset(-7);
    }];
}

@end
/*
 fileprivate class BubbleBtn: UIControl {
 
 lazy var label: UILabel = {
 let result = UILabel()
 result.textAlignment = .center
 result.font = CommonUIStyle.Font.pingFangRegular(14 * CommonUIStyle.Screen.widthScale)
 result.textColor = hexStringToUIColor(hex: "#505050")
 return result
 }()
 
 init() {
 super.init(frame: CGRect.zero)
 self.layer.cornerRadius = 4
 self.backgroundColor = UIColor.white
 addSubview(label)
 label.snp.makeConstraints { maker in
 maker.centerY.equalToSuperview()
 maker.left.equalTo(5)
 maker.right.equalToSuperview().offset(-5)
 maker.height.equalTo(14)
 maker.top.equalTo(7)
 maker.bottom.equalToSuperview().offset(-7)
 }
 }
 
 required init?(coder aDecoder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 
 }
 */

//
//  FHMainOldTopTagsView.m
//  FHHouseList
//
//  Created by 张元科 on 2019/9/23.
//

#import "FHMainOldTopTagsView.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIColor+Theme.h>
#import "FHMainOldTopCell.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import "FHEnvContext.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHUserTracker.h"

@interface FHMainOldTopTagsView ()

@property (nonatomic, weak)     FHConfigDataModel       *wConfigData;
@property (nonatomic, weak)     FHSearchFilterConfigOption       *tagsFilterData;

@end

@implementation FHMainOldTopTagsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.wConfigData = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (self.wConfigData) {
        // 二手房大类页过滤器
        if ([self.wConfigData.filter isKindOfClass:[NSArray class]]) {
            [self.wConfigData.filter enumerateObjectsUsingBlock:^(FHSearchFilterConfigItem *  _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                if ([obj1.tabId integerValue] == 4) {// 更多
                    [obj1.options enumerateObjectsUsingBlock:^(FHSearchFilterConfigOption*  _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop2) {
                        if ([obj2.type isEqualToString:@"tags"]) {
                            self.tagsFilterData = obj2;
                            *stop2 = YES;
                        }
                    }];
                    *stop1 = YES;
                }
            }];
        }
    }
    // 判断标签数据
    if (self.tagsFilterData) {
        CGFloat itemWidth = (SCREEN_WIDTH - 40 - 13 * 3) / 4.0;
        CGFloat top = 14;
        CGFloat itemMargin = 13;
        __block CGFloat leftOffset = 20;
        if ([self.tagsFilterData.options isKindOfClass:[NSArray class]]) {
            NSArray *tempArray = nil;
            if (self.tagsFilterData.options.count >= 4) {
                // 取前四个
                tempArray = [self.tagsFilterData.options subarrayWithRange:NSMakeRange(0, 4)];
            } else {
                // 直接显示
                tempArray = self.tagsFilterData.options;
            }
            if (tempArray) {
                [tempArray enumerateObjectsUsingBlock:^(FHSearchFilterConfigOption *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    FHMainOldTagsView *tagView = [[FHMainOldTagsView alloc] initWithFrame:CGRectMake(leftOffset, top, itemWidth, 30)];
                    [self addSubview:tagView];
                    leftOffset += (itemMargin + itemWidth);
                    tagView.optionData = obj;
                    tagView.tag = [obj.value integerValue];
                    [tagView addTarget:self action:@selector(tagsViewClick:) forControlEvents:UIControlEventTouchUpInside];
                }];
            }
        }
    }
}

// 点击
- (void)tagsViewClick:(FHMainOldTagsView *)tagView {
    tagView.isSelected = !tagView.isSelected;
}

@end

// FHMainOldTagsView
@interface FHMainOldTagsView ()
@property (nonatomic, strong)   UILabel       *label;
@end

@implementation FHMainOldTagsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor themeGray7];
        self.layer.cornerRadius = 4.0;
        [self setupUI];
        self.isSelected = NO;
    }
    return self;
}

- (void)setupUI {
    _label = [[UILabel alloc] init];
    _label.textColor = [UIColor colorWithHexStr:@"#45494d"];
    _label.font = [UIFont themeFontRegular:12];
    _label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)setOptionData:(FHSearchFilterConfigOption *)optionData {
    _optionData = optionData;
    if (optionData) {
        self.label.text = optionData.text;
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        self.backgroundColor = [UIColor colorWithHexStr:@"ffeef0"];
        _label.textColor = [UIColor colorWithHexStr:@"#ff5969"];
    } else {
        self.backgroundColor = [UIColor themeGray7];
        _label.textColor = [UIColor colorWithHexStr:@"#45494d"];
    }
}

@end

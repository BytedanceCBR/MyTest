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
            if (self.tagsFilterData.options.count >= 4) {
                // 取前四个
                for (int i = 0; i < 4; i++) {
                    FHMainOldTagsView *tagView = [[FHMainOldTagsView alloc] initWithFrame:CGRectMake(leftOffset, top, itemWidth, 30)];
                    [self addSubview:tagView];
                    leftOffset += (itemMargin + itemWidth);
                    tagView.optionData = self.tagsFilterData.options[i];
                }
            } else {
                // 直接显示
                [self.tagsFilterData.options enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    FHMainOldTagsView *tagView = [[FHMainOldTagsView alloc] initWithFrame:CGRectMake(leftOffset, top, itemWidth, 30)];
                    [self addSubview:tagView];
                    leftOffset += (itemMargin + itemWidth);
                    tagView.optionData = obj;
                }];
            }
        }
    }
}

@end

@implementation FHMainOldTagsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor themeGray7];
        self.layer.cornerRadius = 4.0;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
}

@end

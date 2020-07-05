//
//  FHBuildingDetailEmptyFloorCollectionViewCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/3.
//

#import "FHBuildingDetailEmptyFloorCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>

@interface FHBuildingDetailEmptyFloorCollectionViewCell ()

@end

@implementation FHBuildingDetailEmptyFloorCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        //house_detail_building_empty
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"house_detail_building_empty"]];
        [self.contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView);
            make.top.mas_equalTo(40);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont themeFontRegular:14];
        label.textColor = [UIColor themeGray3];
        label.text = @"该楼栋户型信息暂无";
        [self.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView);
            make.top.mas_equalTo(imageView.mas_bottom).mas_offset(10);
        }];
    }
    return self;
}

@end

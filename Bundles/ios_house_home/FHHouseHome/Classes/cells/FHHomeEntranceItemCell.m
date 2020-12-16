//
//  FHEntranceItemCell.m
//  FHHouseHome
//
//  Created by CYY RICH on 2020/11/9.
//

#import "FHHomeEntranceItemCell.h"
#import "FHConfigModel.h"
#import "FHCommonDefines.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <UIDevice+BTDAdditions.h>

@interface FHHomeEntranceItemCell()

@property(nonatomic , strong) UIImageView *iconView;
@property(nonatomic , strong) UILabel *nameLabel;

@end

@implementation FHHomeEntranceItemCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH - 30)/5, (SCREEN_WIDTH - 30)/5)];
        [self addSubview:self.iconView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
        _nameLabel.textColor = [UIColor themeGray2];
        _nameLabel.font = [TTDeviceHelper isScreenWidthLarge320] ? [UIFont themeFontRegular:12] : [UIFont themeFontRegular:12];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_nameLabel];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)bindModel:(FHConfigDataOpDataItemsModel *)model {
    FHConfigDataOpDataItemsImageModel *imgModel = model.image.firstObject;
    [self.iconView bd_setImageWithURL:[NSURL URLWithString:imgModel.url] placeholder:[UIImage imageNamed:@"icon_placeholder"]];
    self.nameLabel.text = model.title;
//    [self.nameLabel sizeToFit];
    self.nameLabel.centerX = self.width/2;
}

@end

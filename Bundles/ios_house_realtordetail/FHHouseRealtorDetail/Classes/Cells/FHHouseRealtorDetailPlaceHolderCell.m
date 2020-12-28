//
//  FHHouseRealtorDetailPlaceHolderCell.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/12/28.
//

#import "FHHouseRealtorDetailPlaceHolderCell.h"
#import "UIColor+Theme.h"
@interface FHHouseRealtorDetailPlaceHolderCell()
@property (weak, nonatomic) UIImageView *placeHolderImage;
@end

@implementation FHHouseRealtorDetailPlaceHolderCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor themeGray7];
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.placeHolderImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView);
    }];
}

- (UIImageView *)placeHolderImage {
    if (!_placeHolderImage) {
        UIImageView *placeHolderImage = [[UIImageView alloc]init];
        placeHolderImage.image= [UIImage imageNamed:@"realtor_cell_place"];
        [self.contentView addSubview:placeHolderImage];
        _placeHolderImage = placeHolderImage;
    }
    return _placeHolderImage;;
}

- (void)setPlaceHolderImageName:(NSString *)placeHolderImageName {
    _placeHolderImageName = placeHolderImageName;
    self.placeHolderImage.image= [UIImage imageNamed:placeHolderImageName];
}

- (void)setPersolanPage {
    [self.placeHolderImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}
@end

//
//  TTMomentMomoCell.m
//  Article
//
//  Created by SunJiangting on 15-6-15.
//
//

#import "TTMomentMomoCell.h"

#import "UIImageView+WebCache.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import <BDWebImage/SDWebImageAdapter.h>

@implementation TTMomentMomoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.promoteLabel.layer.cornerRadius = 2.0;
    self.promoteLabel.layer.masksToBounds = YES;
    self.promoteLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMomentModel:(ArticleMomentModel *)momentModel {
    _momentModel = momentModel;
    [self.avatarView sda_setImageWithURL:[TTStringHelper URLWithURLString:momentModel.avatar]];
    NSMutableString *description = [NSMutableString stringWithCapacity:30];
    if (momentModel.sname) {
        [description appendFormat:@"%@ ", momentModel.sname];
    }
    if (momentModel.distance) {
        [description appendString:momentModel.distance];
    }
    self.addressLabel.text = description;
    self.nameLabel.text = momentModel.name;
    self.descLabel.text = momentModel.sign;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

@end

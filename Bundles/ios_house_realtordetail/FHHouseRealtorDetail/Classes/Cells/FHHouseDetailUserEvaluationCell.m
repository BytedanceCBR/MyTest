//
//  FHHouseDetailUserEvaluationCell.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/12.
//

#import "FHHouseDetailUserEvaluationCell.h"
#import <YYText/YYLabel.h>
@implementation FHHouseDetailUserEvaluationCell

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHHouseRealtorDetailUserEvaluationModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.contentView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHHouseRealtorDetailUserEvaluationModel *model = (FHHouseRealtorDetailUserEvaluationModel *)data;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
}
@end

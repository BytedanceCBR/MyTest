//
//  FHUGCReplyCell.m
//  Pods
//
//  Created by 张元科 on 2019/7/18.
//

#import "FHUGCReplyCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"
#import "FHUGCFollowButton.h"
#import "FHUGCConfig.h"
#import "TTRoute.h"

@implementation FHUGCReplyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
//    if (![data isKindOfClass:[FHPostDetailHeaderModel class]]) {
//        return;
//    }
//    self.currentData = data;
//
//    FHPostDetailHeaderModel *headerModel = (FHPostDetailHeaderModel *)self.currentData;
//
//    _titleLabel.text = headerModel.socialGroupModel.socialGroupName;
//    _descLabel.text = headerModel.socialGroupModel.countText;
//    [self.icon bd_setImageWithURL:[NSURL URLWithString:headerModel.socialGroupModel.avatar] placeholder:nil];
//    BOOL isFollowed = [headerModel.socialGroupModel.hasFollow boolValue];
//    self.joinBtn.followed = isFollowed;
//    self.joinBtn.tracerDic = headerModel.tracerDict;
//    self.joinBtn.groupId = headerModel.socialGroupModel.socialGroupId;
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

// FHUGCReplyCellModel
@implementation FHUGCReplyCellModel



@end

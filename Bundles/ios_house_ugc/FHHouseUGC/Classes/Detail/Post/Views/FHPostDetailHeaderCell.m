//
//  FHPostDetailHeaderCell.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/13.
//

#import "FHPostDetailHeaderCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"
#import "FHUGCFollowButton.h"
#import "FHUGCConfig.h"
#import "TTRoute.h"

@interface FHPostDetailHeaderCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) FHUGCFollowButton *joinBtn;

@end

@implementation FHPostDetailHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForData:(id)data {
    return 78;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHPostDetailHeaderModel class]]) {
        return;
    }
    self.currentData = data;

    FHPostDetailHeaderModel *headerModel = (FHPostDetailHeaderModel *)self.currentData;
    
    _titleLabel.text = headerModel.socialGroupModel.socialGroupName;
    _descLabel.text = headerModel.socialGroupModel.countText;
    [self.icon bd_setImageWithURL:[NSURL URLWithString:headerModel.socialGroupModel.avatar] placeholder:nil];
    BOOL isFollowed = [headerModel.socialGroupModel.hasFollow boolValue];
    self.joinBtn.followed = isFollowed;
    self.joinBtn.tracerDic = headerModel.tracerDict;
    self.joinBtn.groupId = headerModel.socialGroupModel.socialGroupId;
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
    self.icon = [[UIImageView alloc] init];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = 4;
    _icon.backgroundColor = [UIColor themeGray7];
    _icon.layer.borderWidth = 0.5;
    _icon.layer.borderColor = [[UIColor themeGray6] CGColor];
    [self.contentView addSubview:_icon];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:15] textColor:[UIColor themeGray1]];
    [self.contentView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self.contentView addSubview:_descLabel];
    
    self.joinBtn = [[FHUGCFollowButton alloc] init];
    [self addSubview:_joinBtn];
    
    [self setupConstraints];
    
    __weak typeof(self) wSelf = self;
    self.didClickCellBlk = ^{
        [wSelf gotoCommunityDetail];
    };
}

- (void)gotoCommunityDetail {
     FHPostDetailHeaderModel *headerModel = (FHPostDetailHeaderModel *)self.currentData;
    if (headerModel) {
        FHUGCScialGroupDataModel *data = headerModel.socialGroupModel;
        NSMutableDictionary *dict = @{}.mutableCopy;
        NSDictionary *log_pb = data.logPb;
        dict[@"community_id"] = data.socialGroupId;
        NSString *enter_from = headerModel.tracerDict[@"page_type"] ?: @"be_null";
        dict[@"tracer"] = @{@"enter_from":enter_from,
                            @"enter_type":@"click",
                            @"log_pb":log_pb ?: @"be_null"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        // 跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)setupConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.bottom.mas_equalTo(self.contentView).offset(-15);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.height.mas_equalTo(50);
    }];
    
    [self.joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.mas_equalTo(58);
        make.height.mas_equalTo(24);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(21);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.joinBtn.mas_left).offset(-10);
        make.height.mas_equalTo(21);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(1);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(17);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end


// FHPostDetailHeaderModel

@implementation FHPostDetailHeaderModel


@end

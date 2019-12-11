//
// Created by fengbo on 2019-08-29.
//

#import <FHCommonUI/UILabel+House.h>
#import "FHDetailUserHouseCommentCell.h"
#import "FHDetailOldModel.h"
#import "FHDetailHeaderView.h"
#import "BDWebImage.h"


@interface FHDetailUserHouseCommentItemView : UIControl

@property(nonatomic, strong) UIImageView *userAvatar;
@property(nonatomic, strong) UILabel *userName;
@property(nonatomic, strong) UILabel *userContent;
@property(nonatomic, strong) UILabel *commentData;

@end

@interface FHDetailUserHouseCommentCell ()

@property(nonatomic, strong) FHDetailHeaderView *headerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property(nonatomic, strong) UIView *containerView;

@end

@implementation FHDetailUserHouseCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"他们都在看";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(30);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.left.mas_equalTo(self.contentView).offset(15);
        make.height.mas_equalTo(46);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(15);
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.bottom.mas_equalTo(self.shadowImage).offset(-35);
    }];
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"neighborhood_evaluation";
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailUserHouseCommentModel class]]) {
        return;
    }
    self.currentData = data;

    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }

    FHDetailUserHouseCommentModel *model = (FHDetailUserHouseCommentModel *) data;
    self.shadowImage.image = model.shadowImage;
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    if (model.userComments && model.userComments.count > 0) {
        __block FHDetailUserHouseCommentItemView *lastItemView = nil;
        [model.userComments enumerateObjectsUsingBlock:^(FHUserHouseCommentModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            FHDetailUserHouseCommentItemView *itemView = [[FHDetailUserHouseCommentItemView alloc] init];
            itemView.tag = idx;
            [self.containerView addSubview:itemView];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastItemView != nil) {
                    make.top.mas_equalTo(lastItemView.mas_bottom);
                } else {
                    make.top.mas_equalTo(self.containerView);
                }
                make.left.right.mas_equalTo(self.containerView);
            }];
            itemView.userName.text = obj.userName;
            itemView.userContent.text = obj.userContent;
            itemView.commentData.text = obj.evaluationData;
            if (obj.userAvatar.length > 0) {
                [itemView.userAvatar bd_setImageWithURL:[NSURL URLWithString:obj.userAvatar] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
            }
            lastItemView = itemView;
        }];
        [lastItemView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.containerView).offset(-20);
        }];

        lastItemView = nil;
    }
}
@end

@implementation FHDetailUserHouseCommentItemView {


}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _userAvatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_default_avatar"]];
        _userAvatar.layer.cornerRadius = 21;
        _userAvatar.contentMode = UIViewContentModeScaleAspectFill;
        _userAvatar.clipsToBounds = YES;

        [self addSubview:_userAvatar];

        _userName = [UILabel createLabel:@"" textColor:@"" fontSize:16];
        _userName.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16] ? : [UIFont systemFontOfSize:16];
        _userName.textColor = [UIColor themeGray1];
        _userName.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_userName];

        _userContent = [UILabel createLabel:@"" textColor:@"" fontSize:10];
        _userContent.textColor = [UIColor themeGray3];
        _userContent.textAlignment = NSTextAlignmentLeft;
        _userContent.numberOfLines = 0;
        [self addSubview:_userContent];

        _commentData = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        _commentData.textColor = [UIColor themeGray2];
        _commentData.textAlignment = NSTextAlignmentLeft;
        _commentData.numberOfLines = 0;
        [_commentData sizeToFit];
        [self addSubview:_commentData];

        [self.userAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(40);
            make.left.mas_equalTo(20);
            make.top.mas_equalTo(22);
        }];

        [self.userName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.userAvatar.mas_right).offset(10);
            make.top.mas_equalTo(self.userAvatar).offset(0);
            make.height.mas_equalTo(22);
        }];

        [self.userContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.userAvatar.mas_right).offset(10);
            make.top.mas_equalTo(self.userName.mas_bottom).offset(1);
            make.height.mas_equalTo(17);
        }];

        [self.commentData mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.top.mas_equalTo(self.userAvatar.mas_bottom).offset(10);
            make.bottom.equalTo(self);
        }];
    }
    return self;
}

@end

@implementation FHDetailUserHouseCommentModel

@end

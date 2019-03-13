//
//  TTFollowingDetailCell.m
//  Article
//
//  Created by it-test on 8/9/16.
//
//

#import "TTFollowingDetailCell.h"
#import "TTProfileThemeConstants.h"
#import <TTKitchen/TTKitchenHeader.h>

@implementation TTFollowingDetailCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    
    return self;
}

- (void)setupSubviews
{
    self.avatarView.borderColorName = nil;
    self.avatarView.avatarImgPadding = 0.f;
    UIView *maskView = [UIView new];
    maskView.backgroundColor = [UIColor colorWithHexString:@"000000"];
    maskView.alpha = 0.05;
    maskView.size = self.avatarView.size;
    maskView.layer.cornerRadius = self.avatarView.height / 2;
    maskView.clipsToBounds = YES;
    [self.avatarView insertSubview:maskView belowSubview:self.avatarView.verifyView];
}

- (void)reloadWithFollowingModel:(TTFollowingModel *)model {
    [self reloadWithModel:model];
    [self setTipsCount:model.tipsCount];
}

+ (TTFollowButtonStatusType)friendRelationTypeOfModel:(TTFriendModel *)aModel {
    TTFollowButtonStatusType type = FriendListCellUnitRelationButtonHide;
    if ([aModel isAccountUserOfVisitor]
        && ![TTKitchen getBOOL:kKCShowFollowButtonInMyFollowList]) {//可以内部打开，用于自己批量取消关注方便
        // 自己访问自己的关注时，不显示关注按钮
        type = FriendListCellUnitRelationButtonHide;
    } else if ([aModel isAccountUser]) {
        // 自己不能关注自己
        type = FriendListCellUnitRelationButtonHide;
    } else {
        if (aModel.isFollowed && aModel.isFollowing) {
            type = FriendListCellUnitRelationButtonFollowingFollowed;
        } else if (aModel.isFollowing) {
            type = FriendListCellUnitRelationButtonCancelFollow;
        } else {
            type = FriendListCellUnitRelationButtonFollow;
        }
    }
    return type;
}

- (void)setTipsCount:(NSString *)tipsCount
{
    if (!tipsCount) return;
    _tipsCount = tipsCount;
    if (isEmptyString(self.subtitle2Label.text)) { // 如果当前为空，则不修改
        return;
    }
    NSString *subtitle2String = [self.currentFriend subtitle2String];
    //只有tipsCount不为nil且不为@"0"，才显示条数
    if (!isEmptyString(tipsCount) && ![tipsCount isEqualToString:@"0"]) {
        subtitle2String = [NSString stringWithFormat:@"[%@条] %@", tipsCount, subtitle2String];
    }
    
    self.subtitle2Label.text = subtitle2String;
    [self layoutIfNeeded];
}

+ (CGFloat)imageNormalSize{
    return 50.f;
}

+ (CGFloat)imageSize {
    return [TTDeviceUIUtils tt_padding:100.f/2];
}

+ (CGFloat)spacingOfTitle {
    return [TTDeviceUIUtils tt_padding:20.f/2];
}

+ (CGFloat)titleFontSize {
    return [TTDeviceUIUtils tt_fontSize:32.f/2];
}

+ (CGFloat)subtitle1FontSize {
    return [TTDeviceUIUtils tt_fontSize:26.f/2];
}

+ (CGFloat)subtitle2FontSize {
    return [TTDeviceUIUtils tt_fontSize:26.f/2];
}

+ (CGFloat)extraInsetTop
{
    return 0;
}

+ (CGFloat)cellHeightOfModel:(TTFriendModel *)aModel {
    if (!aModel) {
        return 0.f;
    }
    if (isEmptyString([aModel subtitle1String]) || [aModel isAccountUser])
        return [TTDeviceUIUtils tt_padding:160.f/2] + [self extraInsetTop];
    return [TTDeviceUIUtils tt_padding:195.f/2] + [self extraInsetTop];
}

@end

//
//  TTFollowingMergeCell.m
//  Article
//
//  Created by lizhuoli on 17/1/8.
//
//

#import "TTFollowingMergeCell.h"

@interface TTFollowTipsView : SSThemedView

@end

@implementation TTFollowTipsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground7;
        self.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground4].CGColor;
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = self.width / 2;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground4].CGColor;
}

@end

@interface TTFollowingMergeCell ()

@property (nonatomic, strong) TTFollowTipsView *tipsView;

@end

@implementation TTFollowingMergeCell

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
    self.tipsView = [TTFollowTipsView new];
    [self.contentView addSubview:self.tipsView];
    
    [self.tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(9);
        make.width.mas_equalTo(9);
        make.top.equalTo(self.avatarView.mas_top).with.offset(2);
        make.right.equalTo(self.avatarView.mas_right).with.offset(-4);
    }];
    
    self.tipsView.hidden = YES;
    UIView *maskView = [UIView new];
    maskView.backgroundColor = [UIColor colorWithHexString:@"000000"];
    maskView.alpha = 0.05;
    maskView.size = self.avatarView.size;
    maskView.layer.cornerRadius = self.avatarView.height / 2;
    maskView.clipsToBounds = YES;
    [self.avatarView insertSubview:maskView belowSubview:self.avatarView.verifyView];
}

- (void)reloadWithFollowingModel:(TTFollowingMergeResponseModel *)model
{
    TTFriendModel *friendModel = [TTFriendModel new];
    friendModel.name = model.name;
    friendModel.userDescription = model.userDescription;
    friendModel.avatarURLString = model.avatarURLString;
    friendModel.visitorUID = model.visitorUID;
    
    [self reloadWithModel:friendModel];
    if (isEmptyString(model.userDescription)) {
        self.subtitle2Label.text = nil;
    }
    [self setTipsCount:model.tipsCount];
    [self setTips:[model.tips boolValue]];
}

+ (TTFollowButtonStatusType)friendRelationTypeOfModel:(TTFriendModel *)aModel
{
    return FriendListCellUnitRelationButtonHide;
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

- (void)setTips:(BOOL)tips
{
    self.tipsView.hidden = !tips;
}

+ (CGFloat)cellHeight
{
    return [TTDeviceUIUtils tt_padding:160.f/2];
}

+ (CGFloat)extraInsetTop
{
    return 0;
}

+ (CGFloat)imageNormalSize {
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

@end

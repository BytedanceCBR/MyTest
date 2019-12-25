//
// Created by zhulijun on 2019-07-18.
//

#import "FHUGCCommunityCell.h"
#import "FHUGCScialGroupModel.h"
#import "BDWebImage.h"
#import "UIViewAdditions.h"

@interface FHUGCCommunityCell ()

@property(nonatomic, strong) UILabel *titleLabel; //名字
@property(nonatomic, strong) UILabel *descLabel; //帖子数与关注数
@property(nonatomic, strong) UIImageView *icon; //头像
@property(nonatomic, strong) UILabel *suggestionLabel; //推荐列表下推荐理由
@property(nonatomic, strong) UIButton *chooseButton;//选择模式下选择button

@property(nonatomic, strong) UIView *infoContainer;//名字，帖子数，推荐理由等view的父view 用于辅助布局
@property(nonatomic, strong) UIView *buttonContainer;//两种button的container 用于辅助布局

@end

@implementation FHUGCCommunityCell

+ (Class)cellViewClass {
    return [self class];
}

+ (CGFloat)heightForData:(id)data {
    if (![data isKindOfClass:[FHUGCScialGroupDataModel class]]) {
        return 0.0f;
    }
    FHUGCScialGroupDataModel *itemModel = (FHUGCScialGroupDataModel *) data;
    if (isEmptyString(itemModel.suggestReason)) {
        return 68;
    }
    return 78;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)refreshWithData:(id)data type:(FHUGCCommunityCellType)type {
    if (![data isKindOfClass:[FHUGCScialGroupDataModel class]]) {
        return;
    }
    self.currentData = data;

    FHUGCScialGroupDataModel *model = self.currentData;
    [self updateConstraints:type hasSuggestion:!isEmptyString(model.suggestReason)];
    if (type == FHUGCCommunityCellTypeFollow) {
        self.buttonContainer.hidden = NO;
        self.chooseButton.hidden = YES;
        self.followButton.hidden = NO;
    } else if (type == FHUGCCommunityCellTypeChoose) {
        self.buttonContainer.hidden = NO;
        self.chooseButton.hidden = NO;
        self.followButton.hidden = YES;
    } else {
        self.buttonContainer.hidden = YES;
    }
    self.followButton.groupId = model.socialGroupId;
    self.followButton.followed = [model.hasFollow boolValue];
    self.titleLabel.text = model.socialGroupName;
    self.descLabel.text = model.countText;
    if (isEmptyString(model.suggestReason)) {
        self.suggestionLabel.hidden = YES;
    } else {
        self.suggestionLabel.hidden = NO;
        self.suggestionLabel.text = model.suggestReason;
    }
    [self.icon bd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:nil];
}

- (void)setupUI {
    self.icon = [[UIImageView alloc] init];
    self.icon.contentMode = UIViewContentModeScaleAspectFill;
    self.icon.layer.masksToBounds = YES;
    self.icon.layer.cornerRadius = 4;
    self.icon.backgroundColor = [UIColor themeGray7];
    self.icon.layer.borderWidth = 0.5;
    self.icon.layer.borderColor = [[UIColor themeGray6] CGColor];
    [self.contentView addSubview:self.icon];

    self.infoContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.titleLabel = [self labelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    self.descLabel = [self labelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];

    self.suggestionLabel = [self labelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self.infoContainer addSubview:self.titleLabel];
    [self.infoContainer addSubview:self.descLabel];
    [self.infoContainer addSubview:self.suggestionLabel];
    [self.contentView addSubview:self.infoContainer];

    self.buttonContainer = [[UIView alloc] initWithFrame:CGRectZero];
    [self.buttonContainer addSubview:self.followButton];
    [self.buttonContainer addSubview:self.chooseButton];
    [self.contentView addSubview:self.buttonContainer];
}

- (void)setupConstraints {
    self.icon.centerY = self.contentView.centerY;

    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(10);
        make.width.height.mas_equalTo(50);
    }];

    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.centerY.mas_equalTo(self.contentView);
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(58);
    }];

    [self.infoContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.lessThanOrEqualTo(self.buttonContainer.mas_left).offset(-14);
        make.height.mas_equalTo(self.contentView).offset(-20);
        make.centerY.mas_equalTo(self.contentView);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.infoContainer);
        make.height.mas_equalTo(22);
    }];

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.infoContainer);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(1);
        make.height.mas_equalTo(19);
    }];

    [self.suggestionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.infoContainer);
        make.height.mas_equalTo(17);
    }];

    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.buttonContainer);
    }];

    [self.chooseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.buttonContainer);
    }];
}

- (void)updateConstraints:(FHUGCCommunityCellType)type hasSuggestion:(BOOL)hasSuggestion {
    [self.infoContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.centerY.mas_equalTo(self.contentView);
        if (type == FHUGCCommunityCellTypeChoose || type == FHUGCCommunityCellTypeFollow) {
            make.right.lessThanOrEqualTo(self.buttonContainer.mas_left).offset(-14);
        } else {
            make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-20);
        }
        make.height.mas_equalTo(hasSuggestion ? 60 : 42);
    }];
}


- (FHUGCFollowButton *)followButton {
    if (!_followButton) {
        _followButton = [[FHUGCFollowButton alloc] initWithFrame:CGRectZero style:FHUGCFollowButtonStyleBorder];
    }
    return _followButton;
}

- (UIButton *)chooseButton {
    if (!_chooseButton) {
        _chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseButton.layer.cornerRadius = 4;
        _chooseButton.layer.borderColor = [UIColor themeOrange1].CGColor;
        _chooseButton.layer.borderWidth = 0.5;
        _chooseButton.titleLabel.font = [UIFont themeFontRegular:12];
        [_chooseButton setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
        [_chooseButton setTitle:@"选择" forState:UIControlStateNormal];
        _chooseButton.userInteractionEnabled = NO;
    }
    return _chooseButton;
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end

//
//  FHUGCSearchListCell.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import "FHUGCSearchListCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"
#import "FHUGCFollowButton.h"
#import "FHUGCModel.h"
#import "FHUGCFollowButton.h"
#import "FHUGCScialGroupModel.h"
#import "FHUGCConfig.h"
#import "FHUGCSearchListController.h"

@interface FHUGCSearchListCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) FHUGCFollowButton *followButton;
@property(nonatomic, strong) UIButton *chooseButton;//选择模式下选择button
@property(nonatomic, strong) UIView *bottomSepView;
@property(nonatomic, assign) FHCommunityListType currentListType;

@end

@implementation FHUGCSearchListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 关注状态改变
- (void)followStateChanged:(NSNotification *)notification {
    if (notification) {
        FHUGCScialGroupDataModel *model = self.currentData;
        NSDictionary *userInfo = notification.userInfo;
        BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
        NSString *groupId = notification.userInfo[@"social_group_id"];
        NSString *currentGroupId = model.socialGroupId;
        if(groupId.length > 0 && currentGroupId.length > 0) {
            if (model) {
                // 有头部信息
                if ([groupId isEqualToString:currentGroupId]) {
                    // 替换关注人数 AA关注BB热帖 替换：AA
                    [[FHUGCConfig sharedInstance] updateScialGroupDataModel:model byFollowed:followed];
                    [self refreshWithData:model];
                }
            }
        }
    }
}

- (void)socialGroupDataChange:(NSNotification *)notification {
    if (notification) {
        FHUGCScialGroupDataModel *tempModel = self.currentData;
        if (tempModel && [tempModel isKindOfClass:[FHUGCScialGroupDataModel class]]) {
            NSString *socialGroupId = tempModel.socialGroupId;
            FHUGCScialGroupDataModel *model = [[FHUGCConfig sharedInstance] socialGroupData:socialGroupId];
            if (model && (![model.countText isEqualToString:tempModel.countText] || ![model.hasFollow isEqualToString:tempModel.hasFollow])) {
                tempModel.contentCount = model.contentCount;
                tempModel.countText = model.countText;
                tempModel.hasFollow = model.hasFollow;
                tempModel.followerCount = model.followerCount;
                FHUGCSearchCommunityItemData* wrapData = [[FHUGCSearchCommunityItemData alloc] init];
                wrapData.model = tempModel;
                wrapData.listType = self.currentListType;
                [self refreshWithData:wrapData];
            }
        }
    }
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHUGCSearchCommunityItemData class]]) {
        return;
    }
    FHUGCSearchCommunityItemData* wrapData = (FHUGCSearchCommunityItemData*)data;
    self.currentListType = wrapData.listType;
    self.currentData = wrapData.model;
    if(wrapData.listType == FHCommunityListTypeFollow){
        self.chooseButton.hidden = YES;
        self.followButton.hidden = NO;
    }
    if(wrapData.listType == FHCommunityListTypeChoose){
        self.chooseButton.hidden = NO;
        self.followButton.hidden = YES;
    }
    FHUGCScialGroupDataModel *model = self.currentData;
    if ([model isKindOfClass:[FHUGCScialGroupDataModel class]]) {
        NSAttributedString *text1 = [self processHighlightedDefault:model.socialGroupName textColor:[UIColor themeGray1] fontSize:15.0];
        self.titleLabel.attributedText = [self processHighlighted:text1 originText:model.socialGroupName textColor:[UIColor themeRed1] fontSize:15.0];
        // self.titleLabel.text = model.socialGroupName;
        self.descLabel.text = model.countText;
        self.followButton.followed = [model.hasFollow boolValue];
        self.followButton.groupId = model.socialGroupId;
        self.followButton.tracerDic = self.tracerDic;
        [self.icon bd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:nil];
    }
}

// 1、默认
- (NSAttributedString *)processHighlightedDefault:(NSString *)text textColor:(UIColor *)textColor fontSize:(CGFloat)fontSize {
    NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:fontSize],NSForegroundColorAttributeName:textColor};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:attr];

    return attrStr;
}

// 2、高亮
- (NSAttributedString *)processHighlighted:(NSAttributedString *)text originText:(NSString *)originText textColor:(UIColor *)textColor fontSize:(CGFloat)fontSize {
    if (self.highlightedText.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:fontSize],NSForegroundColorAttributeName:textColor};
        NSMutableAttributedString * tempAttr = [[NSMutableAttributedString alloc] initWithAttributedString:text];

        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@",self.highlightedText] options:NSRegularExpressionCaseInsensitive error:nil];

        [regex enumerateMatchesInString:originText options:NSMatchingReportProgress range:NSMakeRange(0, originText.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            [tempAttr addAttributes:attr range:result.range];
        }];
        return tempAttr;
    } else {
        return text;
    }
    return text;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socialGroupDataChange:) name:@"kFHUGCSicialGroupDataChangeKey" object:nil];
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

    self.titleLabel = [self labelWithFont:[UIFont themeFontRegular:15] textColor:[UIColor themeGray1]];
    self.titleLabel.numberOfLines = 1;
    [self.contentView addSubview:_titleLabel];

    self.descLabel = [self labelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    self.descLabel.numberOfLines = 1;
    [self.contentView addSubview:_descLabel];

    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_bottomSepView];

    self.followButton = [[FHUGCFollowButton alloc] init];

    [self.contentView addSubview:_followButton];
    [self.contentView addSubview:self.chooseButton];

    [self setupConstraints];
}

- (void)setupConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.height.mas_equalTo(50);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.followButton.mas_left).offset(-10);
        make.height.mas_equalTo(21);
    }];

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(17);
    }];

    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.bottom.mas_equalTo(self.contentView).offset(0);
        make.height.mas_equalTo(0.5);
    }];

    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(58);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(24);
        make.centerY.mas_equalTo(self.contentView);
    }];

    [self.chooseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(58);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(24);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}


- (UIButton *)chooseButton {
    if (!_chooseButton) {
        _chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseButton.layer.cornerRadius = 4;
        _chooseButton.layer.borderColor = [UIColor themeRed1].CGColor;
        _chooseButton.layer.borderWidth = 0.5;
        _chooseButton.titleLabel.font = [UIFont themeFontRegular:12];
        [_chooseButton setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
        [_chooseButton setTitle:@"选择" forState:UIControlStateNormal];
        _chooseButton.userInteractionEnabled = NO;
    }
    return _chooseButton;
}

@end

@implementation FHUGCSuggectionTableView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.handleTouch) {
        self.handleTouch();
    }
}

@end

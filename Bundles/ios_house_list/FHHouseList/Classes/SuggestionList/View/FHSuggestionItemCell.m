//
//  FHSuggestionItemCell.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/23.
//

#import "FHSuggestionItemCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import "FHExtendHotAreaButton.h"
#import "FHSuggestionListModel.h"

@interface FHSuggestionItemCell ()

@end

@implementation FHSuggestionItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    _label = [[UILabel alloc] init];
    _label.font = [UIFont themeFontRegular:15];
    _label.textColor = [UIColor themeGray1];
    _label.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(21);
        make.bottom.mas_equalTo(self.contentView);
    }];
    // secondaryLabel
    _secondaryLabel = [[UILabel alloc] init];
    _secondaryLabel.font = [UIFont themeFontRegular:13];
    _secondaryLabel.textColor = [UIColor themeGray3];
    _secondaryLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_secondaryLabel];
    [_secondaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.label.mas_right).offset(6);
        make.centerY.mas_equalTo(self.label);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.mas_greaterThanOrEqualTo(63);
    }];
    [_secondaryLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_secondaryLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

@end

@interface FHGuessYouWantCell()

@property(nonatomic, strong) UILabel *recommendTypeLabel;
@property(nonatomic, strong) UILabel *displayPriceLabel;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *recommendResonLabel;



@end

@implementation FHGuessYouWantCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.recommendTypeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_recommendTypeLabel];
    self.recommendTypeLabel.font = [UIFont themeFontRegular:12];
    self.recommendTypeLabel.textAlignment = NSTextAlignmentCenter;
    self.recommendTypeLabel.backgroundColor = [UIColor themeGray7];
    self.recommendTypeLabel.layer.cornerRadius = 9;
    self.recommendTypeLabel.layer.masksToBounds = YES;
    self.recommendTypeLabel.hidden = YES;
    [self.recommendTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(17);
        make.height.mas_equalTo(18);
        make.width.mas_equalTo(36);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_titleLabel];
    self.titleLabel.font = [UIFont themeFontSemibold:16];
    [self.titleLabel sizeToFit];
    
    self.recommendResonLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_recommendResonLabel];
    self.recommendResonLabel.font = [UIFont themeFontRegular:14];
    self.recommendResonLabel.hidden = YES;
    [self.recommendResonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_titleLabel);
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(3);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(20);
    }];
    
    self.displayPriceLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_displayPriceLabel];
    self.displayPriceLabel.font = [UIFont themeFontSemibold:16];
    self.displayPriceLabel.textColor = [UIColor themeOrange1];
    self.displayPriceLabel.textAlignment = NSTextAlignmentRight;
}

- (void)refreshData:(id)data
{
    if ([data isKindOfClass:[FHGuessYouWantResponseDataDataModel class]]) {
        FHGuessYouWantResponseDataDataModel *model = data;
        self.displayPriceLabel.text = model.displayPrice;
        [self.displayPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.top.mas_equalTo(14);
            make.height.mas_equalTo(22);
        }];
        if (model.recommendType.content.length > 0) {
            self.recommendTypeLabel.hidden = NO;
            self.recommendTypeLabel.backgroundColor = [UIColor colorWithHexString:model.recommendType.backgroundColor];
            self.recommendTypeLabel.textColor = [UIColor colorWithHexString:model.recommendType.textColor];
            self.recommendTypeLabel.text = model.recommendType.content;
            [self.recommendTypeLabel sizeToFit];
            CGSize size = [self.recommendTypeLabel sizeThatFits:CGSizeMake(100, 18)];
            [self.recommendTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(size.width + 12);
            }];
        }
        self.titleLabel.text = model.text;
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.recommendTypeLabel.mas_right).offset(15);
            make.right.mas_equalTo(self.displayPriceLabel.mas_left).offset(-15);
            make.top.mas_equalTo(15);
            make.height.mas_equalTo(22);
        }];
        if (model.recommendReason.content > 0) {
            self.recommendResonLabel.hidden = NO;
            self.recommendResonLabel.text = model.recommendReason.content;
            self.recommendResonLabel.textColor = [UIColor themeGray3];
        }
    }
    
}

@end

// --
@interface FHSuggestionNewHouseItemCell ()

@property (nonatomic, strong)   UIView       *sepLine;

@end

@implementation FHSuggestionNewHouseItemCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    _label = [[UILabel alloc] init];
    _label.font = [UIFont themeFontRegular:15];
    _label.textColor = [UIColor themeGray1];
    _label.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(11);
        make.width.mas_greaterThanOrEqualTo(250);
    }];
    // secondaryLabel
    _secondaryLabel = [[UILabel alloc] init];
    _secondaryLabel.font = [UIFont themeFontRegular:13];
    _secondaryLabel.textColor = [UIColor themeGray3];
    _secondaryLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_secondaryLabel];
    [_secondaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.label.mas_right).offset(5);
        make.top.mas_equalTo(12);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.mas_greaterThanOrEqualTo(63).priorityHigh();
    }];
    [_secondaryLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_secondaryLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    // subLabel
    _subLabel = [[UILabel alloc] init];
    _subLabel.font = [UIFont themeFontRegular:12];
    _subLabel.textColor = [UIColor themeGray3];
    _subLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_subLabel];
    [_subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.label.mas_bottom).offset(6);
        make.height.mas_equalTo(17);
        make.bottom.mas_equalTo(-13);
    }];
    
    [_subLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_subLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    // _secondarySubLabel
    _secondarySubLabel = [[UILabel alloc] init];
    _secondarySubLabel.font = [UIFont themeFontRegular:13];
    _secondarySubLabel.textColor = [UIColor themeGray3];
    _secondarySubLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_secondarySubLabel];
    [_secondarySubLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.subLabel.mas_right).offset(5);
        make.centerY.mas_equalTo(self.subLabel);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    
    // sepLine
    _sepLine = [[UIView alloc] init];
    _sepLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_sepLine];
    CGFloat lineH = UIScreen.mainScreen.scale > 2.5 ? 0.35 : 0.5;
    [_sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(lineH);
    }];
}

@end

// --

@implementation FHSuggestHeaderViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    _label = [[UILabel alloc] init];
    _label.text = @"猜你想搜";
    _label.font = [UIFont themeFontMedium:16];
    _label.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(16);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

@end

// --

@implementation FHSuggectionTableView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.handleTouch) {
        self.handleTouch();
    }
}

@end

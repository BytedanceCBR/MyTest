//
//  FHFindHouseHelperCell.m
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/6/16.
//

#import "FHFindHouseHelperCell.h"
#import "UIColor+Theme.h"
#import "Masonry.h"
#import "FHSearchHouseModel.h"
#import "FHSuggestionListModel.h"

@interface FHFindHouseHelperCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, copy) NSString *openUrl;

@end

@implementation FHFindHouseHelperCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    
    return self;
}

- (void)initViews {
    self.contentView.backgroundColor = [UIColor whiteColor];
  
    _containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor themeWhite];
    _containerView.layer.cornerRadius = 10;
    _containerView.layer.borderWidth = 0.5;
    _containerView.layer.borderColor = [UIColor themeGray6].CGColor;
    _containerView.layer.shadowColor = [UIColor themeBlack].CGColor;
    _containerView.layer.shadowOpacity = 0.1;
    _containerView.layer.shadowOffset = CGSizeMake(0, 4);
    _containerView.layer.shadowRadius = 3;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapAction:)];
    [_containerView addGestureRecognizer:tap];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
    _titleLabel.textColor = [UIColor themeGray1];
    [self.containerView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(15);
        make.top.equalTo(self.containerView).offset(16);
    }];
    
    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    _subTitleLabel.textColor = [UIColor themeGray3];
    [self.containerView addSubview:_subTitleLabel];
    [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(15);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(2);
    }];
    
    _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmButton.layer.cornerRadius = 4;
    _confirmButton.layer.borderWidth = 0.5;
    _confirmButton.layer.borderColor = [UIColor themeOrange1].CGColor;
    [_confirmButton setBackgroundColor:[UIColor whiteColor]];
    [_confirmButton setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
    [_confirmButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:12]];
    _confirmButton.userInteractionEnabled = NO;
    [self.containerView addSubview:_confirmButton];
    [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(64, 28));
    }];
}

- (void)refreshWithData:(id)data {
    if (!data || ![data isKindOfClass:[FHSearchFindHouseHelperModel class]]) {
        return;
    }
    
    FHSearchFindHouseHelperModel *model = (FHSearchFindHouseHelperModel *)data;
    
    _titleLabel.text = model.title ?: @"";
    _subTitleLabel.text = model.text ?: @"";
    NSString *buttonTitle = model.buttonText ?: @"";
    [_confirmButton setTitle:buttonTitle forState:UIControlStateNormal];
    _openUrl = model.openUrl;
}

//Sug页面使用（model类型不同）
- (void)updateWithData:(id)data {
    if (!data || ![data isKindOfClass:[FHSuggestionResponseDataModel class]]) {
        return;
    }
    
    FHSuggestionResponseDataModel *model = (FHSuggestionResponseDataModel *)data;
    
    _titleLabel.text = model.title ?: @"";
    _subTitleLabel.text = model.text ?: @"";
    NSString *buttonTitle = model.buttonText ?: @"";
    [_confirmButton setTitle:buttonTitle forState:UIControlStateNormal];
    _openUrl = model.openUrl;
}

+ (CGFloat)heightForData:(id)data {
    return 73;
}

#pragma mark - Action

- (void)cellTapAction:(UITapGestureRecognizer *)sender {
    if (self.cellTapAction) {
        self.cellTapAction(self.openUrl);
    }
}

@end

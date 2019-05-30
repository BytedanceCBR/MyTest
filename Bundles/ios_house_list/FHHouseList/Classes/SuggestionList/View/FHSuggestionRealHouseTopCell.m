//
//  FHSuggestionRealHouseTopCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/29.
//

#import "FHSuggestionRealHouseTopCell.h"
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import <Masonry.h>
#import "FHSugSubscribeModel.h"
#import <FHEnvContext.h>
#import <ToastManager.h>
#import <NSDictionary+TTAdditions.h>
#import <TTRoute.h>

@interface FHSuggestionRealHouseTopCell()
@property (nonatomic, strong)FHSugSubscribeDataDataSubscribeInfoModel *currentModel;
@end

@implementation FHSuggestionRealHouseTopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _backImageView = [UIImageView new];
    [self.contentView addSubview:_backImageView];
    [self.contentView setBackgroundColor:[UIColor themeGray7]];
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 28) / 3;
    
    [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.height.mas_equalTo(101);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontMedium:14];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(14);
        make.height.mas_equalTo(20);
    }];
    
    UIView *segementContentView = [UIView new];
    segementContentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:segementContentView];
    
    [segementContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.bottom.mas_equalTo(-10);
        make.height.mas_equalTo(16);
    }];
    
    _realHouseLabel = [[UILabel alloc] init];
    _realHouseLabel.font = [UIFont themeFontRegular:11];
    _realHouseLabel.textColor = [UIColor themeGray3];
    _realHouseLabel.textAlignment = NSTextAlignmentLeft;
    [segementContentView addSubview:_realHouseLabel];
    
    [_realHouseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(segementContentView).offset(0);
        make.centerY.equalTo(segementContentView);
        make.height.equalTo(segementContentView);
    }];
    
    _realHouseNumLabel = [[UILabel alloc] init];
    _realHouseNumLabel.font = [UIFont themeFontDINAlternateBold:16];
    _realHouseNumLabel.textColor = [UIColor themeRed3];
    _realHouseNumLabel.textAlignment = NSTextAlignmentLeft;
    [segementContentView addSubview:_realHouseNumLabel];
    
    [_realHouseNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_realHouseLabel.mas_right).offset(0);
        make.centerY.equalTo(segementContentView);
        make.height.equalTo(segementContentView);
    }];
    
    _segementLine = [UIView new];
    [_segementLine setBackgroundColor:[UIColor themeGray3]];
    [segementContentView addSubview:_segementLine];
    [_segementLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(segementContentView);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(12);
    }];
    
    
    _falseHouseLabel = [[UILabel alloc] init];
    _falseHouseLabel.font = [UIFont themeFontRegular:11];
    _falseHouseLabel.textColor = [UIColor themeGray3];
    _falseHouseLabel.textAlignment = NSTextAlignmentLeft;
    [segementContentView addSubview:_falseHouseLabel];
    [_falseHouseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_segementLine).offset(18);
        make.centerY.equalTo(segementContentView);
    }];
    
    _falseHouseNumLabel = [[UILabel alloc] init];
    _falseHouseNumLabel.font = [UIFont themeFontDINAlternateBold:16];
    _falseHouseNumLabel.textColor = [UIColor themeRed3];
    _falseHouseNumLabel.textAlignment = NSTextAlignmentLeft;
    [segementContentView addSubview:_falseHouseNumLabel];
    
    [_falseHouseNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_falseHouseLabel.mas_right).offset(0);
        make.centerY.equalTo(segementContentView);
        make.height.equalTo(segementContentView);
    }];
    
    
    _allWebHouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _allWebHouseBtn.titleLabel.font = [UIFont themeFontRegular:12];
    [_allWebHouseBtn setImage:[UIImage imageNamed:@"house_list_real_info"] forState:UIControlStateNormal];
    [_allWebHouseBtn addTarget:self action:@selector(allWebHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_allWebHouseBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    [self.contentView addSubview:_allWebHouseBtn];
    

    [_allWebHouseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(10);
        make.centerY.equalTo(self.titleLabel);
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(14);
    }];
    
    
    _allFalseHouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_allFalseHouseBtn setImage:[UIImage imageNamed:@"house_list_real_arrow"] forState:UIControlStateNormal];
    [_allFalseHouseBtn addTarget:self action:@selector(allFalseHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_allFalseHouseBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    [segementContentView addSubview:_allFalseHouseBtn];
    
    [_allFalseHouseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(segementContentView).offset(0);
        make.centerY.equalTo(_falseHouseLabel);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(12);
    }];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)allWebHouseBtnClick:(UIButton *)button
{
    if (![FHEnvContext isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    FHSugListRealHouseTopInfoModel *model = (FHSugListRealHouseTopInfoModel *)self.currentModel;
    if ([model.openUrl isKindOfClass:[NSString class]]) {
        NSDictionary *info = @{@"url":model.openUrl,@"fhJSParams":@{},@"title":@""};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://webview"] userInfo:userInfo];
    }
}

- (void)allFalseHouseBtnClick:(UIButton *)button
{
    [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:@"sslocal://house_fake_list"] userInfo:nil];
}

#pragma mark -
- (void)subscribeStatusChanged:(NSNotification *)notification {

}

- (void)enabelSubscribBtn
{
    _allWebHouseBtn.userInteractionEnabled = YES;
}

- (void)refreshUI:(JSONModel *)data
{
    if ([data isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) {
        FHSugListRealHouseTopInfoModel *model = (FHSugListRealHouseTopInfoModel *)data;
        self.currentModel = model;
        
        _titleLabel.text = model.totalTitle;
        _realHouseLabel.text = model.trueTitle;
        _realHouseNumLabel.text = [NSString stringWithFormat:@"  %@套",model.trueHouseTotal ? : @"0"];
        _falseHouseLabel.text = model.fakeTitle;
        _falseHouseNumLabel.text = [NSString stringWithFormat:@"  %@套",model.fakeHouseTotal ? : @"0"];;
    }

}

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

@end

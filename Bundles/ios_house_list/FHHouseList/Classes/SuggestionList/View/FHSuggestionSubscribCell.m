//
//  FHSuggestionSubscribCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/20.
//

#import "FHSuggestionSubscribCell.h"
#import <UIFont+House.h>
#import "UIColor+Theme.h"
#import "Masonry.h"
#import "FHSugSubscribeModel.h"
#import <FHEnvContext.h>
#import <ToastManager.h>
#import "NSDictionary+TTAdditions.h"
#import <FHHouseBase/FHShadowView.h>

@interface FHSuggestionSubscribCell()

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) FHShadowView *shadowView;

@property (nonatomic, strong)FHSugSubscribeDataDataSubscribeInfoModel *currentModel;
@end

@implementation FHSuggestionSubscribCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _shadowView = [[FHShadowView alloc] initWithFrame:CGRectZero];
    [_shadowView setCornerRadius:10];
    [_shadowView setShadowColor:[UIColor colorWithRed:110.f/255.f green:110.f/255.f blue:110.f/255.f alpha:1]];
    [_shadowView setShadowOffset:CGSizeMake(0, 2)];
    [self.contentView addSubview:_shadowView];
    
    _containerView = [[UIView alloc] init];
    CALayer *layer = _containerView.layer;
    layer.cornerRadius = 10;
    layer.masksToBounds = YES;
    layer.borderColor =  [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
    layer.borderWidth = 0.5f;
    [self.contentView addSubview:_containerView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontSemibold:16];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.top.mas_equalTo(25);
        make.height.mas_equalTo(22);
    }];

    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.font = [UIFont themeFontRegular:12];
    _subTitleLabel.textColor = [UIColor themeGray3];
    _subTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_subTitleLabel];
    
    [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel).offset(0);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(1);
        make.height.mas_equalTo(16);
    }];
    
    _bottomContentLabel = [[UILabel alloc] init];
    _bottomContentLabel.font = [UIFont themeFontRegular:12];
    _bottomContentLabel.textColor = [UIColor themeGray1];
    _bottomContentLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_bottomContentLabel];
    [_bottomContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30);
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(20);
        make.right.equalTo(self.contentView).offset(-30);
    }];
    
    _subscribeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_subscribeBtn setTitle:@"订阅" forState:UIControlStateNormal];
    _subscribeBtn.layer.masksToBounds = YES;
    _subscribeBtn.titleLabel.font = [UIFont themeFontRegular:12];
    _subscribeBtn.layer.borderColor = [UIColor themeOrange1].CGColor;
    _subscribeBtn.layer.borderWidth = 0.5;
    _subscribeBtn.layer.cornerRadius = 4;
    [_subscribeBtn addTarget:self action:@selector(subscribeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_subscribeBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
    [self.contentView addSubview:_subscribeBtn];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(15);
        make.right.mas_equalTo(self).mas_offset(-15);
        make.top.mas_equalTo(self).offset(10);
        make.bottom.mas_equalTo(self).offset(-10);
    }];
    
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    
    [_subscribeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-30);
        make.top.equalTo(self.titleLabel);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(28);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeStatusChanged:) name:kFHSuggestionSubscribeNotificationKey object:nil];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)subscribeBtnClick:(UIButton *)button
{
    
    if (![FHEnvContext isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    _subscribeBtn.userInteractionEnabled = NO;
    if ([_subscribeBtn.titleLabel.text isEqualToString:@"订阅"]) {
//        [_subscribeBtn setTitle:@"已订阅" forState:UIControlStateNormal];
        if(self.addSubscribeAction)
        {

            self.addSubscribeAction(self.currentModel.text);
        }
    }else
    {
        if(self.deleteSubscribeAction)
        {
            self.deleteSubscribeAction(self.currentModel.subscribeId);
        }
//        [_subscribeBtn setTitle:@"订阅" forState:UIControlStateNormal];
    }
    [self performSelector:@selector(enabelSubscribBtn) withObject:nil afterDelay:1];
}

#pragma mark -
- (void)subscribeStatusChanged:(NSNotification *)notification {
    NSString *text = [notification.userInfo tt_stringValueForKey:@"text"];
    NSString *subId = [notification.userInfo tt_stringValueForKey:@"subId"];
    NSString *status = [notification.userInfo tt_stringValueForKey:@"status"];
    if (subId) {
        self.currentModel.subscribeId = subId;
    }
    //如果是同一个订阅条件
    if (text && [text isEqualToString:_currentModel.text]) {
        if (status && [status isEqualToString:@"1"]) {
            self.currentModel.isSubscribe = YES;
            _subscribeBtn.layer.borderColor = [UIColor themeGray6].CGColor;
            [_subscribeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
            [_subscribeBtn setTitle:@"已订阅" forState:UIControlStateNormal];
        }else if (status && [status isEqualToString:@"0"])
        {
            self.currentModel.isSubscribe = NO;
            _subscribeBtn.layer.borderColor = [UIColor themeOrange1].CGColor;
            [_subscribeBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
            [_subscribeBtn setTitle:@"订阅" forState:UIControlStateNormal];
        }
    }
    
    [self enabelSubscribBtn];
}

- (void)enabelSubscribBtn
{
    _subscribeBtn.userInteractionEnabled = YES;
}

- (void)refreshWithData:(id)data
{
    [self refreshUI:data];
}

+ (CGFloat)heightForData:(id)data
{
    return 127;
}

- (void)refreshUI:(JSONModel *)data
{
    if ([data isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
        FHSugSubscribeDataDataSubscribeInfoModel *model = (FHSugSubscribeDataDataSubscribeInfoModel *)data;
        self.currentModel = model;
        _titleLabel.text = @"订阅当前搜索条件";
        _subTitleLabel.text = @"新上房源立刻通知";
        _bottomContentLabel.text = model.text ? : @"暂无";
        if (model.isSubscribe) {
            _subscribeBtn.layer.borderColor = [UIColor themeGray6].CGColor;
            [_subscribeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
            [_subscribeBtn setTitle:@"已订阅" forState:UIControlStateNormal];
        }else
        {
            _subscribeBtn.layer.borderColor = [UIColor themeOrange1].CGColor;
            [_subscribeBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
            [_subscribeBtn setTitle:@"订阅" forState:UIControlStateNormal];
        }
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

//
//  FHSuggestionSubscribCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/20.
//

#import "FHSuggestionSubscribCell.h"
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import <Masonry.h>
#import "FHSugSubscribeModel.h"
#import <FHEnvContext.h>
#import <ToastManager.h>
#import <NSDictionary+TTAdditions.h>

@interface FHSuggestionSubscribCell()
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
    
    _backImageView = [UIImageView new];
    [self.contentView addSubview:_backImageView];
    [_backImageView setImage:[UIImage imageNamed:@"suglist_subscribe_mask"]];
    
    [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(6);
        make.left.mas_equalTo(9);
        make.right.mas_equalTo(-9);
        make.height.mas_equalTo(101);
        make.bottom.mas_equalTo(self.contentView);
    }];

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
    return 121;
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
            [_subscribeBtn setBackgroundColor:[UIColor themeOrange1]];
            [_subscribeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_subscribeBtn setTitle:@"已订阅" forState:UIControlStateNormal];
        }else
        {
            [_subscribeBtn setBackgroundColor:[UIColor whiteColor]];
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

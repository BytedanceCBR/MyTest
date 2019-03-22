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
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.height.mas_equalTo(101);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    UIImageView *imageRight = [[UIImageView alloc] init];
    [imageRight setImage:[UIImage imageNamed:@"suglist_subscribe_right"]];
    [_backImageView addSubview:imageRight];
    [imageRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.height.mas_equalTo(61);
        make.width.mas_equalTo(166);
        make.bottom.equalTo(self.backImageView).offset(-8);
    }];


    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontMedium:14];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(36);
        make.top.mas_equalTo(40);
        make.height.mas_equalTo(20);
    }];


    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.font = [UIFont themeFontRegular:11];
    _subTitleLabel.textColor = [UIColor themeGray3];
    _subTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_subTitleLabel];
    
    
    [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel).offset(0);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(1);
        make.height.mas_equalTo(16);
    }];
    
    _bottomContentLabel = [[UILabel alloc] init];
    _bottomContentLabel.font = [UIFont themeFontRegular:12];
    _bottomContentLabel.textColor = [UIColor themeGray2];
    _bottomContentLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_bottomContentLabel];
    [_bottomContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(36);
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(6);
        make.right.equalTo(self.contentView).offset(-36);
    }];
    
    _subscribeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_subscribeBtn setTitle:@"订阅" forState:UIControlStateNormal];
    _subscribeBtn.layer.masksToBounds = YES;
    _subscribeBtn.titleLabel.font = [UIFont themeFontRegular:12];
    _subscribeBtn.layer.borderColor = [UIColor themeRed1].CGColor;
    _subscribeBtn.layer.borderWidth = 0.5;
    _subscribeBtn.layer.cornerRadius = 8;
    [_subscribeBtn addTarget:self action:@selector(subscribeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_subscribeBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    [self.contentView addSubview:_subscribeBtn];
    
    
    [_subscribeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-40);
        make.top.equalTo(self.titleLabel);
        make.width.mas_equalTo(52);
        make.height.mas_equalTo(21);
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
            [_subscribeBtn setTitle:@"已订阅" forState:UIControlStateNormal];
        }else if (status && [status isEqualToString:@"0"])
        {
            [_subscribeBtn setTitle:@"订阅" forState:UIControlStateNormal];
        }
    }
}

- (void)enabelSubscribBtn
{
    _subscribeBtn.userInteractionEnabled = YES;
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
            [_subscribeBtn setTitle:@"已订阅" forState:UIControlStateNormal];
        }else
        {
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

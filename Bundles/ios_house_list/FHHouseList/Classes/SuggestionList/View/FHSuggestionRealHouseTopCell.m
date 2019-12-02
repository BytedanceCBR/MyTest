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
#import "FHExtendHotAreaButton.h"
#import <TTDeviceHelper.h>
#import <FHUtils.h>
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHSuggestionRealHouseTopCell()
@property (nonatomic, strong)FHSugSubscribeDataDataSubscribeInfoModel *currentModel;
@property (nonatomic, strong)FHExtendHotAreaButton      *allFalseHouseBtn;
@property (nonatomic, strong)UIView *segementContentView;
@property (nonatomic, strong)UIButton *maskBtn;
@property (nonatomic, strong)UIButton *maskWebBtn;

@property (nonatomic, strong)   NSDictionary   *tracerDict;
@property (nonatomic, strong)  NSString *searchQuery;

@end

@implementation FHSuggestionRealHouseTopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUITypeBottom];
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
    
    _segementContentView = [UIView new];
    _segementContentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_segementContentView];
    
    [_segementContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.bottom.mas_equalTo(-10);
        make.height.mas_equalTo(16);
    }];
    
    _realHouseLabel = [[UILabel alloc] init];
    _realHouseLabel.font = [UIFont themeFontRegular:[TTDeviceHelper isScreenWidthLarge320] ? 12 : 10];
    _realHouseLabel.textColor = [UIColor themeGray3];
    _realHouseLabel.textAlignment = NSTextAlignmentLeft;
    [_segementContentView addSubview:_realHouseLabel];
    
    [_realHouseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.segementContentView).offset(0);
        make.centerY.equalTo(self.segementContentView);
        make.height.equalTo(self.segementContentView);
    }];
    
    _realHouseNumLabel = [[UILabel alloc] init];
    _realHouseNumLabel.font = [UIFont themeFontDINAlternateBold:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 12];
    _realHouseNumLabel.textColor = [UIColor themeRed3];
    _realHouseNumLabel.textAlignment = NSTextAlignmentLeft;
    [_segementContentView addSubview:_realHouseNumLabel];
    
    [_realHouseNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_realHouseLabel.mas_right).offset(0);
        make.centerY.equalTo(self.segementContentView);
        make.height.equalTo(self.segementContentView);
    }];
    
    _realHouseUnitLabel= [[UILabel alloc] init];
    _realHouseUnitLabel.font = [UIFont themeFontRegular:10];
    _realHouseUnitLabel.textColor = [UIColor themeRed3];
    _realHouseUnitLabel.text = @"套";
    _realHouseUnitLabel.textAlignment = NSTextAlignmentLeft;
    [_segementContentView addSubview:_realHouseUnitLabel];
    
    
    [_realHouseUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.realHouseNumLabel.mas_right).offset(2);
        make.centerY.equalTo(self.segementContentView);
        make.height.equalTo(self.segementContentView);
    }];
    
    _segementLine = [UIView new];
    [_segementLine setBackgroundColor:[UIColor themeGray6]];
    [_segementContentView addSubview:_segementLine];
    [_segementLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.realHouseUnitLabel.mas_right).offset(8);
        make.centerY.equalTo(self.segementContentView);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(12);
    }];
    
    
    _falseHouseLabel = [[UILabel alloc] init];
    _falseHouseLabel.font = [UIFont themeFontRegular:[TTDeviceHelper isScreenWidthLarge320] ? 12 : 10];
    _falseHouseLabel.textColor = [UIColor themeGray3];
    _falseHouseLabel.textAlignment = NSTextAlignmentLeft;
    [_segementContentView addSubview:_falseHouseLabel];
    [_falseHouseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_segementLine).offset(8);
        make.centerY.equalTo(self.segementContentView);
    }];
    
    _falseHouseNumLabel = [[UILabel alloc] init];
    _falseHouseNumLabel.font = [UIFont themeFontDINAlternateBold:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 12];
    _falseHouseNumLabel.textColor = [UIColor themeRed3];
    _falseHouseNumLabel.textAlignment = NSTextAlignmentLeft;
    [_segementContentView addSubview:_falseHouseNumLabel];
    
    [_falseHouseNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_falseHouseLabel.mas_right).offset(0);
        make.centerY.equalTo(self.segementContentView);
        make.height.equalTo(self.segementContentView);
    }];
    
    
    _falseHouseUnitLabel = [[UILabel alloc] init];
    _falseHouseUnitLabel.font = [UIFont themeFontRegular:10];
    _falseHouseUnitLabel.textColor = [UIColor themeRed3];
    _falseHouseUnitLabel.text = @"套";
    _falseHouseUnitLabel.textAlignment = NSTextAlignmentLeft;
    [_segementContentView addSubview:_falseHouseUnitLabel];
    
    [_falseHouseUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.falseHouseNumLabel.mas_right).offset(2);
        make.centerY.equalTo(self.segementContentView);
        make.height.equalTo(self.segementContentView);
    }];
    
    
    _allWebHouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _allWebHouseBtn.titleLabel.font = [UIFont themeFontRegular:12];
    UIImage *img = ICON_FONT_IMG(16, @"\U0000e6ad", RGB(0x66, 0x66, 0x66));
    [_allWebHouseBtn setImage:img forState:UIControlStateNormal];
    [_allWebHouseBtn addTarget:self action:@selector(allWebHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_allWebHouseBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    [self.contentView addSubview:_allWebHouseBtn];
    

    [_allWebHouseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(10);
        make.centerY.equalTo(self.titleLabel);
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(14);
    }];
    
    
    _allFalseHouseBtn = [FHExtendHotAreaButton buttonWithType:UIButtonTypeCustom];
    _allFalseHouseBtn.isExtend = YES;
                            //\U0000
    img = ICON_FONT_IMG(16, @"\U0000e670", RGB(0x66, 0x66, 0x66));//
    [_allFalseHouseBtn setImage:img forState:UIControlStateNormal];
    [_allFalseHouseBtn addTarget:self action:@selector(allFalseHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_allFalseHouseBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    [_segementContentView addSubview:_allFalseHouseBtn];
    
    [_allFalseHouseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.falseHouseUnitLabel.mas_right).offset(3);
        make.centerY.equalTo(_falseHouseLabel);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(12);
    }];
    
    _maskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_maskBtn setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_maskBtn];
    [_maskBtn addTarget:self action:@selector(allFalseHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_maskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.falseHouseNumLabel).offset(-3);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width * 0.65);
    }];
    
    
    _maskWebBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_maskWebBtn setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_maskWebBtn];
    [_maskWebBtn addTarget:self action:@selector(allWebHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_maskWebBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.allWebHouseBtn).offset(-8);
        make.right.equalTo(self.allWebHouseBtn).offset(5);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(40);
    }];
    
    self.backgroundColor = [UIColor themeGray7];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setupUITypeBottom
{
    UIView *backColorView = [UIView new];
    [backColorView setBackgroundColor:[UIColor themeGray7]];
    [self.contentView addSubview:backColorView];
    [backColorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView).offset(10);
        make.height.mas_equalTo(30);
    }];
    
    _falseHouseLabel = [[UILabel alloc] init];
    _falseHouseLabel.font = [UIFont themeFontRegular:[TTDeviceHelper isScreenWidthLarge320] ? 12 : 10];
    _falseHouseLabel.textColor = [UIColor themeGray3];
    _falseHouseLabel.textAlignment = NSTextAlignmentLeft;
    [backColorView addSubview:_falseHouseLabel];
    [_falseHouseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backColorView).offset(-15);
        make.centerY.equalTo(backColorView);
        make.height.mas_equalTo(30);
    }];

    _allFalseHouseBtn = [FHExtendHotAreaButton buttonWithType:UIButtonTypeCustom];
    _allFalseHouseBtn.isExtend = YES;
    UIImage *img = ICON_FONT_IMG(([TTDeviceHelper isScreenWidthLarge320] ? 12 : 10), @"\U0000e670", [UIColor themeGray3]);
    [_allFalseHouseBtn setImage:img forState:UIControlStateNormal];
    [_allFalseHouseBtn addTarget:self action:@selector(allFalseHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_allFalseHouseBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    [backColorView addSubview:_allFalseHouseBtn];
    
    
    [_allFalseHouseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.falseHouseLabel.mas_right).offset(5);
        make.centerY.equalTo(_falseHouseLabel);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(12);
    }];
    
    _maskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_maskBtn setBackgroundColor:[UIColor clearColor]];
    [backColorView addSubview:_maskBtn];
    [_maskBtn addTarget:self action:@selector(allFalseHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_maskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.falseHouseNumLabel).offset(-3);
        make.right.equalTo(backColorView);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width * 0.65);
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
    if ([model isKindOfClass:[FHSugListRealHouseTopInfoModel class]] &&[model.openUrl isKindOfClass:[NSString class]]) {
        
        NSString *urlStr = nil;
        if ([self.tracerDict isKindOfClass:[NSDictionary class]] && model.openUrl) {
            NSMutableDictionary *reprotParams = [NSMutableDictionary new];
            if ([self.tracerDict isKindOfClass:[NSMutableDictionary class]]) {
                [reprotParams addEntriesFromDictionary:self.tracerDict];
            }
            [reprotParams setValue:self.tracerDict[@"category_name"] forKey:@"enter_from"];
            if ([model.openUrl containsString:@"?"]) {
                urlStr = [NSString stringWithFormat:@"%@&report_params=%@",model.openUrl,[FHUtils getJsonStrFrom:reprotParams]];
            }else
            {
                urlStr = [NSString stringWithFormat:@"%@?report_params=%@",model.openUrl,[FHUtils getJsonStrFrom:reprotParams]];
            }
        }else
        {
            urlStr = model.openUrl;
        }
        
        if ([urlStr isKindOfClass:[NSString class]]) {
            NSDictionary *info = @{@"url":urlStr,@"fhJSParams":@{},@"title":@" "};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://webview"] userInfo:userInfo];
        }
    }
}

- (void)allFalseHouseBtnClick:(UIButton *)button
{
    FHSugListRealHouseTopInfoModel *model = (FHSugListRealHouseTopInfoModel *)self.currentModel;

    if (model.searchId && [model.fakeHouseTotal integerValue] > 0) {
        NSMutableDictionary *info = [NSMutableDictionary new];
        [info setValue:model.searchId forKey:@"searchId"];
        [info setValue:self.searchQuery forKey:@"searchQuery"];
        [info setValue:self.tracerDict forKey:@"tracer"];
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:@"sslocal://house_fake_list"] userInfo:userInfo];
    }
}

#pragma mark -
- (void)subscribeStatusChanged:(NSNotification *)notification {

}

- (void)enabelSubscribBtn
{
    _allWebHouseBtn.userInteractionEnabled = YES;
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) {
        [self refreshUI:data];
    }
}

+ (CGFloat)heightForData:(id)data
{
    return 50;
}

- (void)refreshUI:(JSONModel *)data
{
    if ([data isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) {
        FHSugListRealHouseTopInfoModel *model = (FHSugListRealHouseTopInfoModel *)data;
        self.currentModel = model;
        self.searchQuery = model.searchQuery;
        self.tracerDict = model.tracerDict;
        [_falseHouseLabel setBackgroundColor:[UIColor clearColor]];
        if ([model.fakeText isKindOfClass:[NSString class]]) {
            _falseHouseLabel.text = model.fakeText;
        }
        
        if([model.fakeHouseTotal integerValue] == 0)
        {
            _allFalseHouseBtn.hidden = YES;
        }else
        {
            _allFalseHouseBtn.hidden = NO;
        }
        
        [self layoutIfNeeded];
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


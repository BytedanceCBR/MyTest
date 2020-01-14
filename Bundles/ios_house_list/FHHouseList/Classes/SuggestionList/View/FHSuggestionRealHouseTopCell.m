//
//  FHSuggestionRealHouseTopCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/29.
//

#import "FHSuggestionRealHouseTopCell.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "Masonry.h"
#import "FHSugSubscribeModel.h"
#import <FHEnvContext.h>
#import "ToastManager.h"
#import "NSDictionary+TTAdditions.h"
#import "TTRoute.h"
#import "FHExtendHotAreaButton.h"
#import "TTDeviceHelper.h"
#import "FHUtils.h"
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

- (void)setupUITypeBottom
{
    UIView *backColorView = [UIView new];
    [backColorView setBackgroundColor:[UIColor colorWithHexString:@"#fafbfa"]];
    [self.contentView addSubview:backColorView];
    [backColorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(46);
    }];
    
    _falseHouseLabel = [[UILabel alloc] init];
    _falseHouseLabel.font = [UIFont themeFontRegular:[TTDeviceHelper isScreenWidthLarge320] ? 14 : 12];
    _falseHouseLabel.textColor = [UIColor themeGray3];
    _falseHouseLabel.textAlignment = NSTextAlignmentLeft;
    [backColorView addSubview:_falseHouseLabel];
    [_falseHouseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backColorView).offset(-10);
        make.centerY.equalTo(backColorView);
        make.height.mas_equalTo(30);
    }];

    _allFalseHouseBtn = [FHExtendHotAreaButton buttonWithType:UIButtonTypeCustom];
    _allFalseHouseBtn.isExtend = YES;
    UIImage *img = ICON_FONT_IMG(([TTDeviceHelper isScreenWidthLarge320] ? 14 : 12), @"\U0000e670", [UIColor colorWithHexString:@"#aeadad"]);
    [_allFalseHouseBtn setImage:img forState:UIControlStateNormal];
    [_allFalseHouseBtn addTarget:self action:@selector(allFalseHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_allFalseHouseBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
    [backColorView addSubview:_allFalseHouseBtn];
    
    
    [_allFalseHouseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.falseHouseLabel.mas_right).offset(4);
        make.centerY.equalTo(_falseHouseLabel);
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(16);
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
    return 66;
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


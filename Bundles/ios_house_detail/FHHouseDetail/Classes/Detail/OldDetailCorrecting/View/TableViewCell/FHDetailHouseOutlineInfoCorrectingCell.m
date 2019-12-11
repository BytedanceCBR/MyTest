//
//  FHDetailHouseOutlineInfoCorrectingCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailHouseOutlineInfoCorrectingCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "UILabel+House.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import <TTSandBoxHelper.h>
#import "FHDetailFoldViewButton.h"

#define foldHeight 150 //当文本高度+标题高度（36）+headerView高度（52+18）>367折叠

@interface FHDetailHouseOutlineInfoCorrectingCell ()

@property (nonatomic, weak) FHDetailHeaderView *headerView;
@property (nonatomic, weak) FHDetailFoldViewButton *foldButton;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) UIButton *infoButton;
@property (nonatomic, assign) CGFloat contentHeight;
@property(nonatomic, weak) UIView *bottomGradientView;
@property (nonatomic, strong) NSMutableArray *itemsArr;

@end

@implementation FHDetailHouseOutlineInfoCorrectingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    _itemsArr = [[NSMutableArray alloc]init];
    if (self.currentData == data || ![data isKindOfClass:[FHDetailHouseOutlineInfoCorrectingModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailHouseOutlineInfoCorrectingModel *model = (FHDetailHouseOutlineInfoCorrectingModel *)data;
    self.shadowImage.image = model.shadowImage;
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    _infoButton.hidden = model.hideReport;
    _contentHeight = 70; //header高度
    __block UIView *lastView = self.containerView;
    if (model.houseOverreview.list.count > 0) {
        [model.houseOverreview.list enumerateObjectsUsingBlock:^(FHDetailOldDataHouseOverreviewListModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHDetailHouseOutlineInfoCorrectingView *outlineView = [[FHDetailHouseOutlineInfoCorrectingView alloc] init];
            outlineView.keyLabel.text = obj.title;
            outlineView.valueLabel.text = obj.content;
            CGSize titleSize = [obj.content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-62, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont themeFontRegular:14]} context:nil].size;
            self.contentHeight = self.contentHeight + 34 + titleSize.height;
            [outlineView.valueLabel sizeToFit];
            [outlineView showIconAndTitle:obj.title.length > 0];
            [self.containerView addSubview:outlineView];
            [self.itemsArr addObject:outlineView];
        }];
    }
    if (_contentHeight > foldHeight) {
        [self.containerView mas_updateConstraints :^(MASConstraintMaker *make) {
            make.height.mas_equalTo(foldHeight);
        }];
        model.isFold = YES;
        self.foldButton.hidden = NO;
        self.bottomGradientView.hidden = NO;
        [self.itemsArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *outlineView = obj;
            [outlineView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (idx == 0) {
                    make.top.mas_equalTo(0);
                } else {
                    make.top.mas_equalTo(lastView.mas_bottom);
                }
                make.left.right.mas_equalTo(self.containerView);
            }];
            lastView = outlineView;
        }];
    }else {
        [self.itemsArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *outlineView = obj;
            [outlineView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (idx == 0) {
                    make.top.mas_equalTo(0);
                } else {
                    make.top.mas_equalTo(lastView.mas_bottom);
                }
                make.left.right.mas_equalTo(self.containerView);
                if (idx ==self.itemsArr.count - 1) {
                    make.bottom.mas_equalTo(self.containerView);
                }
            }];
            lastView = outlineView;
        }];
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIView *)containerView {
    if (!_containerView) {
         UIView *containerView = [[UIView alloc] init];
        containerView.clipsToBounds = YES;
        [self.contentView addSubview:containerView];
        _containerView = containerView;
    }
    return _containerView;
}

- (FHDetailHeaderView *)headerView {
    if (!_headerView) {
        FHDetailHeaderView *headerView = [[FHDetailHeaderView alloc] init];
        headerView.label.text = @"房源概况";
        [self.contentView addSubview:headerView];
        _headerView = headerView;
    }
    return _headerView;
}

- (UIButton *)infoButton {
    if (!_infoButton) {
        UIButton *infoButton = [[UIButton alloc] init];
        [infoButton setImage:[UIImage imageNamed:@"reportimage"] forState:UIControlStateNormal];
        [infoButton setTitle:@"举报" forState:UIControlStateNormal];
        NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:@"举报" attributes:@{
                                                                                                     NSFontAttributeName:[UIFont themeFontRegular:12],
                                                                                                     NSForegroundColorAttributeName:[UIColor themeGray3]
                                                                                                     }];
        [infoButton setAttributedTitle:attriStr forState:UIControlStateNormal];
         [infoButton addTarget:self action:@selector(feedBackButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        infoButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [self.headerView addSubview:infoButton];
        _infoButton = infoButton;
    }
    return _infoButton;
}

-(UIView *)bottomGradientView {
    if(!_bottomGradientView){
        CGFloat width = SCREEN_WIDTH -30;
        CGFloat height = 53;
        CGRect frame = CGRectMake(0, 0, width, height);
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = frame;
        gradientLayer.colors = @[
                                 (__bridge id)[UIColor colorWithWhite:1 alpha:0].CGColor,
                                 (__bridge id)[UIColor colorWithWhite:1 alpha:1].CGColor
                                 ];
        gradientLayer.startPoint = CGPointMake(0.5, 0);
        gradientLayer.endPoint = CGPointMake(0.5, 0.9);
        UIView *bottomGradientView = [[UIView alloc]initWithFrame:frame];
        [bottomGradientView.layer addSublayer:gradientLayer];
        [self.contentView addSubview:bottomGradientView];
        bottomGradientView.hidden  = YES;
        _bottomGradientView = bottomGradientView;
    }
    return _bottomGradientView;
}

- (FHDetailFoldViewButton *)foldButton {
    if (!_foldButton) {
        FHDetailFoldViewButton *foldButton = [[FHDetailFoldViewButton alloc] initWithDownText:@"查看全部信息" upText:@"收起" isFold:YES];
        foldButton.keyLabel.font = [UIFont themeFontRegular:14];
        foldButton.openImage = [UIImage imageNamed:@"message_more_arrow"];
        foldButton.foldImage = [UIImage imageNamed:@"message_flod_arrow"];
        foldButton.keyLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
        foldButton.backgroundColor = [UIColor whiteColor];
          [foldButton addTarget:self action:@selector(foldButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        foldButton.hidden = YES;
        [self.contentView addSubview:foldButton];
        
        _foldButton = foldButton;
    }
    return _foldButton;
}
- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(0);
        make.right.mas_equalTo(self.contentView).offset(0);
        make.top.mas_equalTo(self.contentView).offset(-12);
        make.bottom.mas_equalTo(self.contentView).offset(12);
    }];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(11);
        make.right.mas_equalTo(self.contentView).offset(-11);
        make.top.mas_equalTo(self.shadowImage).offset(30);
        make.height.mas_equalTo(52);// 46 + 6
    }];
    
    [self.infoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headerView.label);
        make.right.mas_equalTo(self.headerView).offset(-25);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(6);
        make.left.mas_equalTo(self.contentView).offset(11);
        make.right.mas_equalTo(self.contentView).offset(-11);
        make.bottom.mas_equalTo(self.shadowImage).offset(-48);
    }];
    [self.bottomGradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-50);
        make.height.mas_equalTo(53);
    }];
    [self.foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-30);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
    }];

}

- (void)feedBackButtonClick:(UIButton *)button {
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
    [FHUserTracker writeEvent:@"click_feedback" params:tracerDic];
//    if ([TTAccountManager isLogin]) {
        [self gotoReportVC];
//    } else {
//        [self gotoLogin];
//    }
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"old_feedback" forKey:@"enter_from"];
    [params setObject:@"feedback" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(NO) forKey:@"need_pop_vc"];
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                [wSelf gotoReportVC];
            }
            // 移除登录页面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wSelf delayRemoveLoginVC];
            });
        }
    }];
}

- (void)foldButtonClick:(UIButton *)btn {
    FHDetailHouseOutlineInfoCorrectingModel *model = (FHDetailHouseOutlineInfoCorrectingModel *)self.currentData;
    model.isFold = !model.isFold;
    self.foldButton.isFold = model.isFold;
    [model.tableView beginUpdates];
    [self.containerView mas_updateConstraints :^(MASConstraintMaker *make) {
        make.height.mas_equalTo( model.isFold ?foldHeight:self.contentHeight-70+50);//减去header 高度再加上展开时展开s按钮的高度
    }];
    self.bottomGradientView.hidden =!model.isFold ;
    [model.tableView endUpdates];
}

- (void)delayRemoveLoginVC {
    UINavigationController *navVC = self.baseViewModel.detailController.navigationController;
    NSInteger count = navVC.viewControllers.count;
    if (navVC && count >= 2) {
        NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:navVC.viewControllers];
        if (vcs.count == count) {
            [vcs removeObjectAtIndex:count - 2];
            [self.baseViewModel.detailController.navigationController setViewControllers:vcs];
        }
    }
}

// 二手房-房源问题反馈
- (void)gotoReportVC {
    FHDetailHouseOutlineInfoCorrectingModel *model = (FHDetailHouseOutlineInfoCorrectingModel *)self.currentData;
    FHDetailOldDataModel *ershouData = [(FHDetailOldModel *)model.baseViewModel.detailData data];
    NSDictionary *jsonDic = [ershouData toDictionary];
    if (model && model.houseOverreview.reportUrl.length > 0 && jsonDic) {
        
        NSString *openUrl = @"sslocal://webview";
        NSDictionary *pageData = @{@"data":jsonDic};
        NSDictionary *commonParams = [[FHEnvContext sharedInstance] getRequestCommonParams];
        if (commonParams == nil) {
            commonParams = @{};
        }
        NSDictionary *commonParamsData = @{@"data":commonParams};
        NSDictionary *jsParams = @{@"requestPageData":pageData,
                                   @"getNetCommonParams":commonParamsData
                                   };
        NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
        if ([TTSandBoxHelper isInHouseApp] && [[NSUserDefaults standardUserDefaults]boolForKey:@"BOE_OPEN_KEY"]) {
            host = @"http://i.haoduofangs.com.boe-gateway.byted.org";
        }
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",host,model.houseOverreview.reportUrl];
        NSDictionary *info = @{@"url":urlStr,@"fhJSParams":jsParams,@"title":@"房源问题反馈"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:userInfo];
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"house_info";
}

@end

// FHDetailHouseOutlineInfoCorrectingView
@interface FHDetailHouseOutlineInfoCorrectingView ()

@end

@implementation FHDetailHouseOutlineInfoCorrectingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _iconImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rectangle-100"]];
    [self addSubview:_iconImg];
    _keyLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _keyLabel.font = [UIFont themeFontMedium:15];
    _keyLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
    [self addSubview:_keyLabel];
    _valueLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _valueLabel.textColor = [UIColor themeGray3];
    _valueLabel.numberOfLines = 0;
    _valueLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_valueLabel];
    
    [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(12);
        make.centerY.mas_equalTo(self.keyLabel);
    }];
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImg.mas_right).offset(2);
        make.top.mas_equalTo(4);
        make.height.mas_equalTo(26);
        make.right.mas_equalTo(self).offset(-20);
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImg);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.keyLabel.mas_bottom).offset(8);
        make.bottom.mas_equalTo(self).offset(-10);
    }];
}

- (void)showIconAndTitle:(BOOL)showen {
    self.iconImg.hidden = !showen;
    self.keyLabel.hidden = !showen;
    if (showen) {
        [self.valueLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).offset(32);
        }];
    } else {
        [self.valueLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).offset(4);
        }];
    }
}

@end

// FHDetailHouseOutlineInfoCorrectingModel
@implementation FHDetailHouseOutlineInfoCorrectingModel


@end

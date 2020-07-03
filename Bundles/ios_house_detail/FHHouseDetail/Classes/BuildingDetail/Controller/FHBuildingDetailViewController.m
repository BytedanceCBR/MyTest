//
//  FHBuildingDetailViewController.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "FHBuildingDetailViewController.h"
#import "FHHouseDetailAPI.h"
#import "FHBuildingDetailViewModel.h"
#import "FHBuildingDetailCollectionViewFlowLayout.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import "UIViewController+Track.h"
#import "FHLoadingButton.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHBuildingDetailFloorCollectionViewCell.h"
#import "FHBuildingDetailHeaderCollectionViewCell.h"
#import "FHBuildingDetailInfoCollectionViewCell.h"
#import "FHDetailBaseModel.h"
#import "FHHouseDetailContactViewModel.h"

@interface FHBuildingDetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) NSString *houseId;

@property (nonatomic, strong) FHBuildingDetailViewModel *viewModel;

@property (nonatomic, weak) FHBaseCollectionView *collectionView;
@property (nonatomic, strong)   UIButton       *onlineBtn;
@property (nonatomic, strong)   FHLoadingButton       *contactBtn;

@property(nonatomic, strong) UIView *bottomBar;

@property (nonatomic, strong) FHHouseDetailContactViewModel *contactViewModel;

@property (nonatomic, copy) NSString *elementFrom;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;
@end

@implementation FHBuildingDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if (self = [super initWithRouteParamObj:paramObj]) {
        self.ttTrackStayEnable = YES;
        if (paramObj.allParams[@"house_id"]) {
            self.houseId = paramObj.allParams[@"house_id"];
        }
    }
    return self;
}

- (UIButton *)onlineBtn {
    if (!_onlineBtn) {
        _onlineBtn = [[UIButton alloc] init];
        _onlineBtn.layer.cornerRadius = 20;
        _onlineBtn.layer.masksToBounds = YES;
        _onlineBtn.titleLabel.font = [UIFont themeFontRegular:16];
        _onlineBtn.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
        [_onlineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_onlineBtn setTitle:@"在线联系" forState:UIControlStateNormal];
        [_onlineBtn setTitle:@"在线联系" forState:UIControlStateHighlighted];
        [_onlineBtn addTarget:self action:@selector(onlineButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _onlineBtn.layer.shadowColor = [UIColor colorWithRed:255/255.0 green:143/255.0 blue:0 alpha:0.3].CGColor;
        _onlineBtn.layer.shadowOffset = CGSizeMake(4, 10);
    }
    return _onlineBtn;
}

- (FHLoadingButton *)contactBtn {
    if (!_contactBtn) {
        _contactBtn = [[FHLoadingButton alloc]init];
        _contactBtn.layer.cornerRadius = 20;
        _contactBtn.layer.masksToBounds = YES;
        _contactBtn.titleLabel.font = [UIFont themeFontRegular:16];
        _contactBtn.backgroundColor = [UIColor colorWithHexStr:@"#fe5500"];
        [_contactBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateNormal];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateHighlighted];
        [_contactBtn addTarget:self action:@selector(contactButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _contactBtn.layer.shadowColor = [UIColor colorWithRed:254/255.0 green:85/255.0 blue:0 alpha:0.3].CGColor;
        _contactBtn.layer.shadowOffset = CGSizeMake(4, 10);
    }
    return _contactBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavbar];
    [self setupUI];
    [FHHouseDetailAPI requestBuildingDetail:self.houseId completion:^(FHBuildingDetailModel * _Nullable model, NSError * _Nullable error) {
        
    }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    if (self.bottomBar) {
        [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(64 + bottomInset);
        }];
        contentInset.bottom = 20 + bottomInset + 64;
    } else {
        contentInset.bottom = 20 + bottomInset;
    }
    self.collectionView.contentInset = contentInset;
}

- (void)setupNavbar {
    [self setupDefaultNavBar:NO];
    [self.customNavBarView setNaviBarTransparent:YES];
    self.customNavBarView.title.text = @"楼栋信息";
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]) forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]) forState:UIControlStateHighlighted];
}

- (void)setupUI {
    FHBuildingDetailCollectionViewFlowLayout *layout = [[FHBuildingDetailCollectionViewFlowLayout alloc] init];
    FHBaseCollectionView *collectionView = [[FHBaseCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.customNavBarView.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.collectionView registerClass:[FHBuildingDetailHeaderCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([FHBuildingDetailHeaderCollectionViewCell class])];
    [self.collectionView registerClass:[FHBuildingDetailInfoCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([FHBuildingDetailInfoCollectionViewCell class])];
    [self.collectionView registerClass:[FHBuildingDetailFloorCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([FHBuildingDetailFloorCollectionViewCell class])];
    [self.collectionView registerClass:[FHDetailSectionTitleCollectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FHDetailSectionTitleCollectionView class])];
    
    if (self.contactViewModel) {
        // lead_show 埋点
        [self addLeadShowLog:self.contactViewModel.contactPhone baseParams:[self.contactViewModel baseParams]];
        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 64, CGRectGetWidth(self.view.bounds), 64)];
        self.bottomBar.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.bottomBar];
        [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(64);
            make.bottom.mas_equalTo(0);
        }];
        
        BOOL showenOnline = self.contactViewModel.showenOnline;
        CGFloat itemWidth = CGRectGetWidth(self.view.bounds) - 30;
        if (showenOnline) {
            itemWidth = (itemWidth - 13) / 2.0;
            // 在线联系
            NSString *title = @"在线联系";
            if (self.contactViewModel.onLineName.length > 0) {
                title = self.contactViewModel.onLineName;
            }
            NSMutableAttributedString *buttonTitle = [[NSMutableAttributedString alloc] initWithString:title?:@"" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:16], NSForegroundColorAttributeName : [UIColor whiteColor]}];
//            [buttonTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n线上联系更方便" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:10], NSForegroundColorAttributeName : [UIColor whiteColor]}]];
            self.onlineBtn.titleLabel.numberOfLines = 0;
            [self.onlineBtn setAttributedTitle:buttonTitle.copy forState:UIControlStateNormal];

            [self.bottomBar addSubview:self.onlineBtn];
            [self.onlineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(15);
                make.top.mas_equalTo(12);
                make.width.mas_equalTo(itemWidth);
                make.height.mas_equalTo(40);
            }];
            
            // 电话咨询
            NSString *photoTitle = @"电话咨询";
            if (self.contactViewModel.phoneCallName.length > 0) {
                photoTitle = self.contactViewModel.phoneCallName;
            }
            NSMutableAttributedString *buttonPhoneTitle = [[NSMutableAttributedString alloc] initWithString:photoTitle?:@"" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:16], NSForegroundColorAttributeName : [UIColor whiteColor]}];
//            [buttonPhoneTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n隐私保护更安全" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:10], NSForegroundColorAttributeName : [UIColor whiteColor]}]];
            self.contactBtn.titleLabel.numberOfLines = 0;
            [self.contactBtn setAttributedTitle:buttonPhoneTitle.copy forState:UIControlStateNormal];
            [self.bottomBar addSubview:self.contactBtn];
            [self.contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-16);
                make.top.mas_equalTo(self.onlineBtn.mas_top);
                make.width.mas_equalTo(self.onlineBtn.mas_width);
                make.height.mas_equalTo(self.onlineBtn.mas_height);
            }];
        } else {
            // 电话咨询
            NSString *photoTitle = @"电话咨询";
            if (self.contactViewModel.phoneCallName.length > 0) {
                photoTitle = self.contactViewModel.phoneCallName;
            }
            NSMutableAttributedString *buttonPhoneTitle = [[NSMutableAttributedString alloc] initWithString:photoTitle?:@"" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:16], NSForegroundColorAttributeName : [UIColor whiteColor]}];
//            [buttonPhoneTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n隐私保护更安全" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:10], NSForegroundColorAttributeName : [UIColor whiteColor]}]];
            self.contactBtn.titleLabel.numberOfLines = 0;
            [self.contactBtn setAttributedTitle:buttonPhoneTitle.copy forState:UIControlStateNormal];
            self.contactBtn.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
            [self.bottomBar addSubview:self.contactBtn];
            [self.contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(15);
                make.top.mas_equalTo(12);
                make.width.mas_equalTo(itemWidth);
                make.height.mas_equalTo(40);
            }];
        }
    }
}

#pragma mark - Action
// 电话咨询点击
- (void)contactButtonClick:(UIButton *)btn {
    if (self.contactViewModel) {

        NSMutableDictionary *extraDic = @{
            @"realtor_position":@"phone_button",
            @"position":@"report_button",
            @"element_from":self.elementFrom?:@"be_null"
        }.mutableCopy;
        
//        extraDic[@"from"] = @"app_newhouse_property_picture";
//        if (cluePage) {
//            extraDic[kFHCluePage] = cluePage;
//        }
        NSDictionary *associateInfoDict = nil;
        FHDetailContactModel *contactPhone = self.contactViewModel.contactPhone;
        if (contactPhone.phone.length > 0) {
            associateInfoDict = self.associateInfo.phoneInfo;
        }else {
            associateInfoDict = self.associateInfo.reportFormInfo;
        }
        extraDic[kFHAssociateInfo] = associateInfoDict;
        [self.contactViewModel contactActionWithExtraDict:extraDic];
    }
}

// 在线联系点击
- (void)onlineButtonClick:(UIButton *)btn {
    if (self.contactViewModel) {
        NSMutableDictionary *extraDic = @{}.mutableCopy;
        extraDic[@"realtor_position"] = @"online";
        extraDic[@"position"] = @"online";
        extraDic[@"element_from"] = self.elementFrom?:@"be_null";
        extraDic[@"from"] = @"app_newhouse_property_picture";
        // 头图im入口线索透传
        if(self.associateInfo) {
            extraDic[kFHAssociateInfo] = self.associateInfo;
        }
        [self.contactViewModel onlineActionWithExtraDict:extraDic];
    }
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)addLeadShowLog:(FHDetailContactModel *)contactPhone baseParams:(NSDictionary *)dic
{
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tracerDic = dic.mutableCopy;
        tracerDic[@"is_im"] = contactPhone.imOpenUrl.length ? @"1" : @"0";
        tracerDic[@"is_call"] = contactPhone.phone.length < 1 ? @"0" : @"1";
        tracerDic[@"is_report"] = contactPhone.phone.length < 1 ? @"1" : @"0";
        tracerDic[@"is_online"] = contactPhone.unregistered ? @"1" : @"0";
        tracerDic[@"element_from"] = [self elementFrom];
        TRACK_EVENT(@"lead_show", tracerDic);
    }
}
@end

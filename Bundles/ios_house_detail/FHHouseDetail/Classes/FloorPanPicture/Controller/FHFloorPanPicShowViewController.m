//
//  FHFloorPanPicShowViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/12.
//

#import "FHFloorPanPicShowViewController.h"
#import "FHFloorPanPicCollectionCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTDeviceHelper.h"
#import "UIViewController+Track.h"
#import <FHHouseBase/TTDeviceHelper+FHHouse.h>
#import <FHHouseBase/FHBaseCollectionView.h>
#import "FHDetailSectionTitleCollectionView.h"
#import "FHDetailPictureTitleView.h"
#import "FHLoadingButton.h"
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHFloorPanPicShowViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic , strong) UICollectionView *collectionView;

@property (nonatomic, strong) FHDetailPictureTitleView *segmentTitleView;
@property (nonatomic, copy)   NSArray       *pictureTitles;
@property (nonatomic, copy)   NSArray       *pictureNumbers;

@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@property(nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong)   UIButton       *onlineBtn;
@property (nonatomic, strong)   FHLoadingButton       *contactBtn;

@property (nonatomic, assign) UIStatusBarStyle lastStatusBarStyle;

@property (nonatomic, assign) BOOL segmentViewChangedFlag;
@end

@implementation FHFloorPanPicShowViewController

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleDefault;;
//}

- (void)setTopImages:(NSArray<FHDetailNewTopImage *> *)topImages {
    _topImages = topImages;
    [self processImagesList];
}

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (void)dealloc {
    [[UIApplication sharedApplication] setStatusBarStyle:_lastStatusBarStyle];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ttTrackStayEnable = YES;
        _lastStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    }
    return self;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if (self = [super initWithRouteParamObj:paramObj]) {
        self.ttTrackStayEnable = YES;
        _lastStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavbar];
    [self setupUserInterface];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self setNeedsStatusBarAppearanceUpdate];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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

- (void)setupUserInterface {
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.topImages && self.pictureTitles.count > 1) {
        self.segmentTitleView = [[FHDetailPictureTitleView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.customNavBarView.frame), CGRectGetWidth(self.view.bounds), 42)];
        self.segmentTitleView.backgroundColor = [UIColor clearColor];
        self.segmentTitleView.usedInPictureList = YES;
        self.segmentTitleView.seperatorLine.hidden = NO;
        self.segmentTitleView.titleNames = self.pictureTitles;
        self.segmentTitleView.titleNums = self.pictureNumbers;
        __weak typeof(self) weakSelf = self;
        [self.segmentTitleView setCurrentIndexBlock:^(NSInteger currentIndex) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.topImageClickTabBlock) {
                strongSelf.topImageClickTabBlock(currentIndex);
            }
            [strongSelf scrollToCurrentIndex:currentIndex];
        }];
        [self.view addSubview:self.segmentTitleView];
        [self.segmentTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(42);
            make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        }];
        [self.segmentTitleView reloadData];
        self.segmentTitleView.selectIndex = 0;
    }
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    //    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //设置headerView的尺寸大小
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 40);
    //该方法也可以设置itemSize
//    layout.itemSize =CGSizeMake(110, 150);
    
    //2.初始化collectionView
    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor clearColor];
    
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [_collectionView registerClass:[FHFloorPanPicCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHFloorPanPicCollectionCell class])];
    
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    [_collectionView registerClass:[FHDetailSectionTitleCollectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FHDetailSectionTitleCollectionView class])];
    //设置代理
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
  
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (self.segmentTitleView) {
            make.top.equalTo(self.segmentTitleView.mas_bottom);
        } else {
            make.top.equalTo(self.customNavBarView.mas_bottom);
        }
        make.bottom.mas_equalTo(0);
    }];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    
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


- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    [self setNavBar:NO];
    [self.customNavBarView setNaviBarTransparent:YES];
    self.customNavBarView.title.text = @"楼盘相册";
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]) forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]) forState:UIControlStateHighlighted];
}

- (void)setNavBar:(BOOL)error {
//    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
//    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
    [self.customNavBarView setNaviBarTransparent:NO];
    
}

- (void)scrollToCurrentIndex:(NSInteger )toIndex {
    //segmentview 的index 和 collectionview的index 不一一对应
    //需要通过计算得出，
    NSInteger count = 0;
    NSInteger titleIndex = 0;
    
    for (int i = 0; i < self.pictsArray.count; i++) {
        FHHouseDetailImageGroupModel *smallImageGroupModel = self.pictsArray[i];
        NSInteger tempCount = smallImageGroupModel.images.count;
        count += tempCount;
        if (toIndex < count) {
            titleIndex = i;
            break;
        }
    }
    self.lastIndexPath = [NSIndexPath indexPathForItem:0 inSection:titleIndex];
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:self.lastIndexPath];
    CGRect frame = attributes.frame;
    frame.origin.y -= 65;
    //section header frame
    //需要滚到到顶部，如果滚动的距离超过contengsize，则滚动到底部
    CGPoint contentOffset = self.collectionView.contentOffset;
    contentOffset.y = frame.origin.y;
    if (contentOffset.y + CGRectGetHeight(self.collectionView.frame) > (self.collectionView.contentSize.height + self.collectionView.contentInset.bottom)) {
        contentOffset.y = self.collectionView.contentSize.height - CGRectGetHeight(self.collectionView.frame) + self.collectionView.contentInset.bottom;
    }
    //防止向上滑动
    if (contentOffset.y < 0) {
        contentOffset.y = 0;
    }
    self.segmentViewChangedFlag = YES;
    [UIView animateWithDuration:0.2 animations:^{
        [self.collectionView setContentOffset:contentOffset];
    } completion:^(BOOL finished) {
        self.segmentViewChangedFlag = NO;
    }];
    
//    [self.mainCollectionView scrollRectToVisible:frame animated:YES];
//    [self.mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:titleIndex] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}

- (void)processImagesList {
    NSMutableArray *smallImageGroup = [NSMutableArray array];

    NSMutableArray *titles = [NSMutableArray array];
    NSMutableArray *numbers = [NSMutableArray array];
    
    for (FHDetailNewTopImage *topImage in self.topImages) {
        FHHouseDetailImageGroupModel *smallImageGroupModel = [[FHHouseDetailImageGroupModel alloc] init];
        smallImageGroupModel.type = [@(topImage.type) stringValue];
        smallImageGroupModel.name = topImage.name;
        
        NSInteger tempCount = 0;
        
        NSMutableArray *smallImageList = [NSMutableArray array];
        for (FHHouseDetailImageGroupModel * groupModel in topImage.smallImageGroup) {
            for (NSInteger j = 0; j < groupModel.images.count; j++) {
                [smallImageList addObject:groupModel.images[j]];
                tempCount += 1;
            }
            
            if (topImage.type == FHDetailHouseImageTypeApartment) {
                smallImageGroupModel.name = groupModel.name;
                smallImageGroupModel.images = smallImageList.copy;
                [smallImageGroup addObject:smallImageGroupModel.copy];
                [smallImageList removeAllObjects];
                continue;
            }
        }
        
        if (smallImageList.count) {
            smallImageGroupModel.images = smallImageList.copy;
            [smallImageGroup addObject:smallImageGroupModel];
        }
        [titles addObject:[NSString stringWithFormat:@"%@（%ld）",topImage.name?:@"",tempCount]];
        [numbers addObject:@(tempCount)];
    }
    self.pictsArray = smallImageGroup.copy;
    
    self.pictureTitles = titles.copy;
    self.pictureNumbers = numbers.copy;
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
        FHDetailContactModel *contactPhone = self.contactViewModel.contactPhone;
        NSDictionary *associateInfoDict = contactPhone.enablePhone ? self.associateInfo.phoneInfo : self.associateInfo.reportFormInfo;
        extraDic[kFHAssociateInfo] = associateInfoDict?:@{};
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


#pragma mark - collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.pictsArray.count;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section < self.pictsArray.count) {
        FHHouseDetailImageGroupModel *groupModel = self.pictsArray[section];
        if ([groupModel isKindOfClass:[FHHouseDetailImageGroupModel class]]) {
            return groupModel.images.count;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHFloorPanPicCollectionCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHFloorPanPicCollectionCell class]) forIndexPath:indexPath];
    if (indexPath.section < self.pictsArray.count) {
        FHHouseDetailImageGroupModel *groupModel = self.pictsArray[indexPath.section];
        if ([groupModel isKindOfClass:[FHHouseDetailImageGroupModel class]] && groupModel.images.count > indexPath.row) {
            cell.dataModel = groupModel.images[indexPath.row];
        }
    }
 
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

//设置每个item的尺寸 81 * 61
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat itemWidth = floor((CGRectGetWidth(collectionView.frame) - 15 * 2 - 6 * 3) / 4.0);
    CGFloat itemHeight = floor(itemWidth / 81.0 * 61.0);
    return CGSizeMake(itemWidth, itemHeight);
}

//header的size
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(CGRectGetWidth(collectionView.frame) , 30 + 15 + 20);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 6;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}

//通过设置SupplementaryViewOfKind 来设置头部或者底部的view，其中 ReuseIdentifier 的值必须和 注册是填写的一致，本例都为 “reusableView”
#pragma mark -- 返回头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        FHDetailSectionTitleCollectionView *titleView = (FHDetailSectionTitleCollectionView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FHDetailSectionTitleCollectionView class]) forIndexPath:indexPath];
        if (self.pictsArray.count > indexPath.section) {

           FHHouseDetailImageGroupModel *groupModel = self.pictsArray[indexPath.section];
            if([groupModel.name length] > 0) {
                if ([groupModel.type isEqualToString:@"2"]) {
                    //户型图后面不带计数
                    titleView.titleLabel.text = [NSString stringWithFormat:@"%@",groupModel.name];
                } else {
                    titleView.titleLabel.text = [NSString stringWithFormat:@"%@ (%ld)",groupModel.name,groupModel.images.count];
                }
            } else {
                titleView.titleLabel.text = [NSString stringWithFormat:@"(%ld)",groupModel.images.count];
            }
        }
        reusableView = titleView;
    }
    //如果是头视图
    return reusableView;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.topImages) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    if (self.albumImageBtnClickBlock && self.pictsArray.count > indexPath.section) {
        NSInteger total = 0;
      
        for (NSInteger i = 0; i <= indexPath.section; i++) {
            if (i < indexPath.section) {
                FHHouseDetailImageGroupModel *groupModel = self.pictsArray[i];
                total += groupModel.images.count;
            }else
            {
                total += indexPath.row; 
            }
        }
        self.albumImageBtnClickBlock(total);
    }
    
//    if (self.albumImageStayBlock) {
//        self.albumImageStayBlock(0,self.ttTrackStartTime);
//    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (self.segmentViewChangedFlag) {
        return;
    }
    //locate the scrollview which is in the centre
    CGPoint centerPoint = CGPointMake(20, scrollView.contentOffset.y + 55);
//    NSIndexPath *indexPathOfCentralCell = [self.mainCollectionView indexPathForItemAtPoint:centerPoint];
    
//    CGPoint centerPoint = [self.view convertPoint:CGPointMake(20, 55) toView:self.mainCollectionView];
    //1 6 2
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:centerPoint];
    NSLog(@"centerPoint :%@ section:%d,row:%d",NSStringFromCGPoint(centerPoint),indexPath.section,indexPath.item);
    if (indexPath && self.lastIndexPath.section != indexPath.section) {
        self.lastIndexPath = indexPath;
        if (indexPath.section < self.pictsArray.count) {
            NSInteger currentIndex = 0;
            for (int i = 0; i < indexPath.section; i++) {
                FHHouseDetailImageGroupModel *smallImageGroupModel = self.pictsArray[i];
                currentIndex += smallImageGroupModel.images.count;
            }
            if (self.segmentTitleView) {
                self.segmentTitleView.selectIndex = currentIndex;
            }
        }
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


//- (void)goBack
//{
//    if (self.albumImageStayBlock) {
//        self.albumImageStayBlock(0,self.ttTrackStartTime);
//    }
//}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.albumImageStayBlock) {
        self.albumImageStayBlock(0,self.ttTrackStayTime);
    }
}

- (void)addLeadShowLog:(FHDetailContactModel *)contactPhone baseParams:(NSDictionary *)dic
{
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tracerDic = dic.mutableCopy;
        tracerDic[@"is_im"] = contactPhone.imOpenUrl.length ? @"1" : @"0";
        tracerDic[@"is_call"] = contactPhone.enablePhone ? @"1" : @"0";
        tracerDic[@"is_report"] = contactPhone.enablePhone ? @"0" : @"1";
        tracerDic[@"is_online"] = contactPhone.unregistered ? @"1" : @"0";
        tracerDic[@"element_from"] = [self elementFrom];
        TRACK_EVENT(@"lead_show", tracerDic);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

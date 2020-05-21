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


#define FH_FLOOR_PIC_HEADER_HEIGHT 30

@interface FHFloorPanPicShowViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic , strong) UITableView* tableView;
@property (nonatomic , strong) UICollectionView *mainCollectionView;


@end

@implementation FHFloorPanPicShowViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    }
    return UIStatusBarStyleDefault;
}

- (void)setTopImages:(NSArray<FHDetailNewTopImage *> *)topImages {
    _topImages = topImages;
    [self processImagesList];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavbar];
    [self setUpPictureTable];
    
    // Do any additional setup after loading the view.
}

- (void)setUpPictureTable
{
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    //    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //设置headerView的尺寸大小
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 40);
    //该方法也可以设置itemSize
    layout.itemSize =CGSizeMake(110, 150);
    
    //2.初始化collectionView
    _mainCollectionView = [[FHBaseCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:_mainCollectionView];
    _mainCollectionView.backgroundColor = [UIColor clearColor];
    
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [_mainCollectionView registerClass:[FHFloorPanPicCollectionCell class] forCellWithReuseIdentifier:@"cellId"];
    
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    [_mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
    //设置代理
    _mainCollectionView.delegate = self;
    _mainCollectionView.dataSource = self;
  
    
    [self.view addSubview:self.mainCollectionView];
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.customNavBarView.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
    _mainCollectionView.showsVerticalScrollIndicator = NO;
    _mainCollectionView.showsHorizontalScrollIndicator = NO;
    [_mainCollectionView setBackgroundColor:[UIColor whiteColor]];
}


- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    [self setNavBar:NO];
    [self.customNavBarView setNaviBarTransparent:YES];
    self.customNavBarView.title.text = @"楼盘相册";
}

- (void)setNavBar:(BOOL)error {
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
    [self.customNavBarView setNaviBarTransparent:NO];
}

- (void)processImagesList {
    NSMutableArray *smallImageGroup = [NSMutableArray array];
    for (FHDetailNewTopImage *topImage in self.topImages) {
        FHDetailNewDataSmallImageGroupModel *smallImageGroupModel = [[FHDetailNewDataSmallImageGroupModel alloc] init];
        smallImageGroupModel.type = [@(topImage.type) stringValue];
        smallImageGroupModel.name = topImage.name;

        NSMutableArray *smallImageList = [NSMutableArray array];
        for (FHDetailNewDataImageGroupModel * groupModel in topImage.smallImageGroup) {
            for (NSInteger j = 0; j < groupModel.images.count; j++) {
                [smallImageList addObject:groupModel.images[j]];
            }
            if (topImage.type == FHDetailHouseImageTypeApartment) {
                smallImageGroupModel.name = groupModel.name;
                smallImageGroupModel.images = smallImageList.copy;
                [smallImageGroup addObject:smallImageGroupModel];
                [smallImageList removeAllObjects];
                continue;
            }
        }
        
        if (smallImageList.count) {
            smallImageGroupModel.images = smallImageList.copy;
            [smallImageGroup addObject:smallImageGroupModel];
        }
    }
    self.pictsArray = smallImageGroup.copy;
}


#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.pictsArray.count;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section < self.pictsArray.count) {
        FHDetailNewDataSmallImageGroupModel *groupModel = self.pictsArray[section];
        if ([groupModel isKindOfClass:[FHDetailNewDataSmallImageGroupModel class]]) {
            return groupModel.images.count;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHFloorPanPicCollectionCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    if (indexPath.section < self.pictsArray.count) {
        FHDetailNewDataSmallImageGroupModel *groupModel = self.pictsArray[indexPath.section];
        if ([groupModel isKindOfClass:[FHDetailNewDataSmallImageGroupModel class]] && groupModel.images.count > indexPath.row) {
            cell.dataModel = groupModel.images[indexPath.row];
        }
    }
 
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(78 * [TTDeviceHelper scaleToScreen375], 78* [TTDeviceHelper scaleToScreen375]);
}

//header的size
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, FH_FLOOR_PIC_HEADER_HEIGHT);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
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
//        [_mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[NSString stringWithFormat:@"reusableView%ld",indexPath.section]];
        
        UICollectionReusableView *view = (UICollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView" forIndexPath:indexPath];
        view.backgroundColor = [UIColor whiteColor];
        UIView *titleView = [view viewWithTag:10010];
        if (self.pictsArray.count > indexPath.section) {

           FHDetailNewDataSmallImageGroupModel *groupModel = self.pictsArray[indexPath.section];

            if ([titleView isKindOfClass:[UILabel class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([groupModel.name length] > 0)
                    {
                       ((UILabel *)titleView).text = [NSString stringWithFormat:@"%@(%ld)",groupModel.name,groupModel.images.count];
                    }else
                    {
                        ((UILabel *)titleView).text = [NSString stringWithFormat:@"(%ld)",groupModel.images.count];
                    }
                });
            }else
            {
                UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 100, FH_FLOOR_PIC_HEADER_HEIGHT)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([groupModel.name length] > 0)
                    {
                        labelTitle.text = [NSString stringWithFormat:@"%@(%ld)",groupModel.name,groupModel.images.count];
                    }else
                    {
                        labelTitle.text = [NSString stringWithFormat:@"(%ld)",groupModel.images.count];
                    }
                });
                labelTitle.tag = 10010;
                labelTitle.font = [UIFont themeFontRegular:14];
                [labelTitle setTextColor:[UIColor themeGray1]];
                [view addSubview:labelTitle];
            }
            
        }

        reusableView = view;
    }
    //如果是头视图
    return reusableView;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if (self.albumImageBtnClickBlock && self.pictsArray.count > indexPath.section) {
        NSInteger total = 0;
      
        for (NSInteger i = 0; i <= indexPath.section; i++) {
            if (i < indexPath.section) {
                FHDetailNewDataSmallImageGroupModel *groupModel = self.pictsArray[i];
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

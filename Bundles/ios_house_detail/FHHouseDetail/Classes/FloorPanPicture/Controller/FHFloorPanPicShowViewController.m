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
#import "FHPictureListTitleCollectionView.h"
#import "FHDetailPictureTitleView.h"

@interface FHFloorPanPicShowViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic , strong) UITableView* tableView;
@property (nonatomic , strong) UICollectionView *mainCollectionView;

@property (nonatomic, strong) FHDetailPictureTitleView *segmentTitleView;
@property (nonatomic, copy)   NSArray       *pictureTitles;
@property (nonatomic, copy)   NSArray       *pictureNumbers;

@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@property(nonatomic, strong) UIView *bottomBar;

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
    if (self.topImages && self.pictureTitles.count > 1) {
        self.segmentTitleView = [[FHDetailPictureTitleView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.customNavBarView.frame), CGRectGetWidth(self.view.bounds), 42)];
        self.segmentTitleView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.segmentTitleView];
        [self.segmentTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(42);
            make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        }];
        self.segmentTitleView.seperatorLine.hidden = NO;
        self.segmentTitleView.titleNames = self.pictureTitles;
        self.segmentTitleView.titleNums = self.pictureNumbers;
        __weak typeof(self) weakSelf = self;
        [self.segmentTitleView setCurrentIndexBlock:^(NSInteger currentIndex) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf scrollToCurrentIndex:currentIndex];
        }];
    }
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
    [_mainCollectionView registerClass:[FHFloorPanPicCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHFloorPanPicCollectionCell class])];
    
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    [_mainCollectionView registerClass:[FHPictureListTitleCollectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FHPictureListTitleCollectionView class])];
    //设置代理
    _mainCollectionView.delegate = self;
    _mainCollectionView.dataSource = self;
  
    
    [self.view addSubview:self.mainCollectionView];
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (self.segmentTitleView) {
            make.top.equalTo(self.segmentTitleView.mas_bottom);
        } else {
            make.top.equalTo(self.customNavBarView.mas_bottom);
        }
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

- (void)scrollToCurrentIndex:(NSInteger )toIndex {
    //segmentview 的index 和 collectionview的index 不一一对应
    //需要通过计算得出，
    NSInteger count = 0;
    NSInteger titleIndex = 0;
    
    for (int i = 0; i < self.pictsArray.count; i++) {
        FHDetailNewDataSmallImageGroupModel *smallImageGroupModel = self.pictsArray[i];
        NSInteger tempCount = smallImageGroupModel.images.count;
        count += tempCount;
        if (toIndex <= count) {
            titleIndex = i;
            break;
        }
    }
    UICollectionViewLayoutAttributes *attributes = [self.mainCollectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:titleIndex]];
    CGRect frame = attributes.frame;
    frame.origin.y -= 65;
    //section header frame
    //需要滚到到顶部，如果滚动的距离超过contengsize，则滚动到底部
    CGPoint contentOffset = self.mainCollectionView.contentOffset;
    contentOffset.y = frame.origin.y;
    if (contentOffset.y + CGRectGetHeight(self.mainCollectionView.frame) > self.mainCollectionView.contentSize.height) {
        contentOffset.y = self.mainCollectionView.contentSize.height - CGRectGetHeight(self.mainCollectionView.frame);
    }
    [self.mainCollectionView setContentOffset:contentOffset animated:YES];
    
//    [self.mainCollectionView scrollRectToVisible:frame animated:YES];
//    [self.mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:titleIndex] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}

- (void)scrollToSegmentView {
    NSIndexPath *indexPath = [self.mainCollectionView indexPathForItemAtPoint:self.mainCollectionView.contentOffset];
    
    if (self.lastIndexPath.section != indexPath.section) {
        self.lastIndexPath = indexPath;
        if (indexPath.section < self.pictsArray.count) {
            NSInteger currentIndex = 0;
            for (int i = 0; i < indexPath.section; i++) {
                FHDetailNewDataSmallImageGroupModel *smallImageGroupModel = self.pictsArray[i];
                currentIndex += smallImageGroupModel.images.count;
            }
            self.segmentTitleView.selectIndex = currentIndex;
        }
    }
}

- (void)processImagesList {
    NSMutableArray *smallImageGroup = [NSMutableArray array];

    NSMutableArray *titles = [NSMutableArray array];
    NSMutableArray *numbers = [NSMutableArray array];
    
    for (FHDetailNewTopImage *topImage in self.topImages) {
        FHDetailNewDataSmallImageGroupModel *smallImageGroupModel = [[FHDetailNewDataSmallImageGroupModel alloc] init];
        smallImageGroupModel.type = [@(topImage.type) stringValue];
        smallImageGroupModel.name = topImage.name;
        
        NSInteger tempCount = 0;
        
        NSMutableArray *smallImageList = [NSMutableArray array];
        for (FHDetailNewDataImageGroupModel * groupModel in topImage.smallImageGroup) {
            for (NSInteger j = 0; j < groupModel.images.count; j++) {
                [smallImageList addObject:groupModel.images[j]];
            }
            
            tempCount += smallImageList.count;
            
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
    
    if (titles.count > 1) {
        self.pictureTitles = titles.copy;
        self.pictureNumbers = numbers.copy;
    }
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHFloorPanPicCollectionCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHFloorPanPicCollectionCell class]) forIndexPath:indexPath];
    if (indexPath.section < self.pictsArray.count) {
        FHDetailNewDataSmallImageGroupModel *groupModel = self.pictsArray[indexPath.section];
        if ([groupModel isKindOfClass:[FHDetailNewDataSmallImageGroupModel class]] && groupModel.images.count > indexPath.row) {
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
        FHPictureListTitleCollectionView *titleView = (FHPictureListTitleCollectionView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FHPictureListTitleCollectionView class]) forIndexPath:indexPath];
        if (self.pictsArray.count > indexPath.section) {

           FHDetailNewDataSmallImageGroupModel *groupModel = self.pictsArray[indexPath.section];
            if([groupModel.name length] > 0) {
                titleView.titleLabel.text = [NSString stringWithFormat:@"%@ (%ld)",groupModel.name,groupModel.images.count];
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

//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    //计算总index，传segmentview
//    [self scrollToSegmentView];
//}
//
//- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self scrollToSegmentView];
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    //locate the scrollview which is in the centre
    CGPoint centerPoint = CGPointMake(20, scrollView.contentOffset.y + 55);
//    NSIndexPath *indexPathOfCentralCell = [self.mainCollectionView indexPathForItemAtPoint:centerPoint];
    
//    CGPoint centerPoint = [self.view convertPoint:CGPointMake(20, 55) toView:self.mainCollectionView];
    NSIndexPath *indexPath = [self.mainCollectionView indexPathForItemAtPoint:centerPoint];
    NSLog(@"centerPoint :%@ section:%d,row:%d",NSStringFromCGPoint(centerPoint),indexPath.section,indexPath.item);
    if (indexPath && self.lastIndexPath.section != indexPath.section) {
        self.lastIndexPath = indexPath;
        if (indexPath.section < self.pictsArray.count) {
            NSInteger currentIndex = 0;
            for (int i = 0; i <= indexPath.section; i++) {
                FHDetailNewDataSmallImageGroupModel *smallImageGroupModel = self.pictsArray[i];
                currentIndex += smallImageGroupModel.images.count;
            }
            self.segmentTitleView.selectIndex = currentIndex;
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

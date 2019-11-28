//
//  FHHomeMainViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import "FHHomeMainViewController.h"
#import "FHHomeMainViewModel.h"
#import "FHHomeMainTopView.h"
#import <TTDeviceHelper.h>
@interface FHHomeMainViewController ()
@property (nonatomic,strong)FHHomeMainViewModel *viewModel;
@property (nonatomic,strong)FHHomeMainTopView *topView;
@end

@implementation FHHomeMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView]; //初始化视图
    [self initConstraints]; //更新约束
    [self initViewModel]; //创建viewModel
    [self initNotifications];//订阅通知
    // Do any additional setup after loading the view.
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topView = [[FHHomeMainTopView alloc] init];
    _topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topView];

    self.containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    //2.初始化collectionView
    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.allowsSelection = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    _collectionView.scrollEnabled = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor themeGray7];
    [self.containerView addSubview:_collectionView];
}

- (void)initConstraints {
    
    CGFloat bottom = 49;
    if (@available(iOS 11.0, *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    CGFloat top = 0;
    CGFloat safeTop = 0;
    if (@available(iOS 11.0, *)) {
        safeTop = [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].top;
    }
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(0);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44 + safeTop);
    }];
    [self.topView setBackgroundColor:[UIColor redColor]];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
    [self.containerView setBackgroundColor:[UIColor blueColor]];
    
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
}

- (void)initViewModel{
    self.viewModel = [[FHHomeMainViewModel alloc] initWithCollectionView:self.collectionView controller:self];
}

- (void)initNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainCollectionScrollBegin) name:@"FHHomeMainDidScrollBegin" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainCollectionScrollEnd) name:@"FHHomeMainDidScrollEnd" object:nil];
}

#pragma mark notifications

- (void)mainCollectionScrollBegin{
    self.collectionView.scrollEnabled = NO;
}

- (void)mainCollectionScrollEnd{
    self.collectionView.scrollEnabled = YES;
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

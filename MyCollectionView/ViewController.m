//
//  ViewController.m
//  MyCollectionView
//
//  Created by bytedance on 2021/2/7.
//

#import "ViewController.h"
#import "MyLayout.h"
#import "MyCollectionViewCell.h"
@interface ViewController () <WaterFlowLayoutDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) MyLayout *layout;
@end

@implementation ViewController
- (void) initView
{
    [self.view addSubview:self.collectionView];
    
}
- (UICollectionView *)collectionView
{
    if(!_collectionView)
    {
        _layout = [[MyLayout alloc] init];
        _layout.delegate = self;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MyCollectionViewCell class])];
    }
    return _collectionView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 30;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MyCollectionViewCell class]) forIndexPath:indexPath];
    return cell;
}
- (CGFloat)waterflowLayout:(MyLayout *)waterflowLayout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth
{
    return (index % 3 + 1) * 100;
}
@end

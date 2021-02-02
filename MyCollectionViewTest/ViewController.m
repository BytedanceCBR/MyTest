//
//  ViewController.m
//  MyCollectionViewTest
//
//  Created by bytedance on 2021/2/1.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "MyCollectionViewCell.h"
#import "MyLayout.h"
#define itemPadding 10
@interface ViewController () 
@property(nonatomic,strong) UICollectionView *collectionView;
@end

@implementation ViewController
- (void)initView
{
    MyLayout *layout = [[MyLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor grayColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MyCollectionViewCell class])];
    
}
- (void) initConstraint
{
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(130);
        make.left.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(150);
    }];
    
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initConstraint];
    // Do any additional setup after loading the view.
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100000;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MyCollectionViewCell class]) forIndexPath:indexPath];
    [cell update];
    
    return cell;
}

@end

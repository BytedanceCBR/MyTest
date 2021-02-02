//
//  ViewController.m
//  MyCollectionViewTest
//
//  Created by bytedance on 2021/2/1.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "CircleLayout.h"
#import "MyCollectionViewCell.h"
#import "SecondView.h"
#define itemPadding 10
@interface ViewController () 
@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) UIButton *btn;
@end

@implementation ViewController
- (void)moveToSecondView
{
    SecondView *secondView = [[SecondView alloc] init];
    [self.navigationController pushViewController:secondView animated:YES];
}
- (void)initView
{
    CircleLayout *layout = [[CircleLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor grayColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MyCollectionViewCell class])];
    self.btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.btn.backgroundColor = [UIColor blueColor];
    [self.btn addTarget:self action:@selector(moveToSecondView) forControlEvents:UIControlEventTouchUpInside];
    [self.btn setTitle:@"跳转" forState:UIControlStateNormal];
    [self.btn setTitle:@"确认" forState:UIControlStateHighlighted];
    
}
- (void) initConstraint
{
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.btn];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(130);
        make.left.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(500);
    
    }];
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.collectionView);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
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
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 9;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MyCollectionViewCell class]) forIndexPath:indexPath];
    [cell update];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

@end

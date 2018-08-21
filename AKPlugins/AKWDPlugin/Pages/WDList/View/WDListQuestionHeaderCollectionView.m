//
//  WDListQuestionHeaderCollectionView.m
//  Article
//
//  Created by 延晋 张 on 16/8/23.
//
//

#import "WDListQuestionHeaderCollectionView.h"
#import "WDListViewModel.h"
#import "WDQuestionEntity.h"
#import "WDQuestionTagEntity.h"
#import "WDListQuestionHeaderCollectionTagCell.h"

#import "TTLeftCollectionViewFlowLayout.h"
#import "WDUIHelper.h"
#import "NSObject+FBKVOController.h"
#import "TTRoute.h"

@interface WDListQuestionHeaderCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) WDListViewModel *viewModel;

@end

@implementation WDListQuestionHeaderCollectionView

- (instancetype)initWithViewModel:(WDListViewModel *)viewModel
                            frame:(CGRect)frame
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = WDPadding(5.0f);
    flowLayout.minimumInteritemSpacing = WDPadding(5.0f);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    if (self = [super initWithFrame:frame collectionViewLayout:flowLayout]) {
        
        _viewModel = viewModel;
        
        self.allowsSelection = YES;
        self.showsHorizontalScrollIndicator = NO;
        
        [self registerClass:[WDListQuestionHeaderCollectionTagCell class] forCellWithReuseIdentifier:@"QuestionHeaderCollectionTagCellIdentifier"];
        
        self.dataSource = self;
        self.delegate = self;
        
        self.height = [self viewHeight];
        
    }
    return self;
}

- (CGFloat)viewHeight
{
    if ([TTDeviceHelper isPadDevice]) {
        return 0;
    } else if ([self.tagEntities count] > 0) {
        return 20;
    } else {
        return 0.0f;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.tagEntities count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WDListQuestionHeaderCollectionTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QuestionHeaderCollectionTagCellIdentifier" forIndexPath:indexPath];
    cell.viewModel = self.viewModel;
    [cell refreshCellWithTagEntity:[self tagEntities][indexPath.row]];
    return cell!=nil ? cell : [[UICollectionViewCell alloc] init];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WDQuestionTagEntity *entity = [self tagEntities][indexPath.row];
    return CGSizeMake([WDListQuestionHeaderCollectionTagCell collectionCellWidthWithName:entity.name], SSHeight(self));
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    WDQuestionTagEntity *entity = [self tagEntities][indexPath.row];
    if ([NSURL URLWithString:entity.schema]) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:entity.schema] userInfo:nil];
    }
    
    [WDListViewModel trackEvent:kWDWendaListViewControllerUMEventName label:@"click_tag_word" gdExtJson:self.viewModel.gdExtJson];
}

#pragma mark - getter

- (NSArray *)tagEntities
{
    return [self.viewModel questionEntity].tagEntities;
}

@end

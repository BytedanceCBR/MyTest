//
//  TTPersonalHomeMultiplePlatformFollowersInfoView.m
//  Article
//
//  Created by 邱鑫玥 on 2018/1/9.
//

#import "TTPersonalHomeMultiplePlatformFollowersInfoView.h"
#import "TTPersonalHomeMultiplePlatformFollowersInfoViewModel.h"
#import "TTPersonalHomeSinglePlatformFollowersInfoCell.h"
#import "TTPersonalHomeSinglePlatformFollowersInfoViewModel.h"
#import <ReactiveObjC.h>
#import <UIView+CustomTimingFunction.h>
#import <TTRoute.h>
#import "TTThemedAlertController.h"
#import "SSActionManager.h"

#define kHorizontalPadding [TTDeviceUIUtils tt_newPadding:15]
#define kMinimumLineSpacing [TTDeviceUIUtils tt_newPadding:8]

@interface TTPersonalHomeMultiplePlatformFollowersInfoView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation TTPersonalHomeMultiplePlatformFollowersInfoView

+ (CGFloat)heightForViewModel:(TTPersonalHomeMultiplePlatformFollowersInfoViewModel *)viewModel
{
    if (viewModel.uiStyle == TTPersonalHomePlatformFollowersInfoViewStyle1) {
        return [TTDeviceUIUtils tt_newPadding:40];
    } else {
        return [TTDeviceUIUtils tt_newPadding:70];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.headerReferenceSize = CGSizeMake(kHorizontalPadding, 0);
            layout.footerReferenceSize = CGSizeMake(kHorizontalPadding, 0);
            layout.minimumLineSpacing = kMinimumLineSpacing;
            
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.showsHorizontalScrollIndicator = NO;
            collectionView.backgroundColor = [UIColor clearColor];
            
            [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
            [collectionView registerClass:[TTPersonalHomeSinglePlatformFollowersInfoCell class] forCellWithReuseIdentifier:NSStringFromClass([TTPersonalHomeSinglePlatformFollowersInfoCell class])];
            
            collectionView;
        });
        [self addSubview:self.collectionView];
        
        [self bindRAC];
    }
    
    return self;
}

- (void)bindRAC
{
    @weakify(self);
    [RACObserve(self, viewModel.itemViewModels) subscribeNext:^(id x) {
        @strongify(self);
        
        [self.collectionView reloadData];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize lastCollectionViewSize = self.collectionView.size;
    
    self.collectionView.frame = self.bounds;
    
    if (!CGSizeEqualToSize(lastCollectionViewSize, self.collectionView.size)) {
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewModel.itemViewModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    
    if (indexPath.item < self.viewModel.itemViewModels.count) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TTPersonalHomeSinglePlatformFollowersInfoCell class]) forIndexPath:indexPath];
        ((TTPersonalHomeSinglePlatformFollowersInfoCell *)cell).viewModel = self.viewModel.itemViewModels[indexPath.item];
    }
    
    return cell ?: [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = 0;
    
    if (self.viewModel.itemViewModels.count <= 4) {
        width = (collectionView.width - 2 * kHorizontalPadding - (self.viewModel.itemViewModels.count - 1) * kMinimumLineSpacing) / self.viewModel.itemViewModels.count;
    } else {
        width = [TTDeviceUIUtils tt_newPadding:80];
    }
    
    NSAssert(width >= 0, @"width必须不小于0");
    
    return CGSizeMake(MAX(0, width), collectionView.height);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < self.viewModel.itemViewModels.count) {
        TTPersonalHomeSinglePlatformFollowersInfoViewModel *itemViewModel = self.viewModel.itemViewModels[indexPath.item];
        NSURL *openURL = itemViewModel.openURL;
        
        if (!openURL) {
            return;
        }
        
        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:openURL];
            [itemViewModel trackClickEventWithAction:@"list_show"];
        } else {
            if ([[UIApplication sharedApplication] canOpenURL:openURL]) {
                if ([itemViewModel shouldShowLaunchAppAlert]) {
                    [itemViewModel markHasShownLaunchAppAlert];
                    
                    TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:[NSString stringWithFormat:@"即将前往%@ APP 查看", itemViewModel.displayName]
                                                                                                      message:nil
                                                                                                preferredType:TTThemedAlertControllerTypeAlert];
                    [alertController addActionWithTitle:@"取消"
                                             actionType:TTThemedAlertActionTypeCancel
                                            actionBlock:nil];
                    [alertController addActionWithTitle:@"立刻前往"
                                             actionType:TTThemedAlertActionTypeNormal
                                            actionBlock:^{
                                                [itemViewModel trackClickEventWithAction:@"app_launch"];
                                                [[UIApplication sharedApplication] openURL:openURL];
                                            }];
                    [alertController showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
                } else {
                    [itemViewModel trackClickEventWithAction:@"app_launch"];
                    [[UIApplication sharedApplication] openURL:openURL];
                }
            } else {
                TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:[NSString stringWithFormat:@"即将前往App Store，下载%@APP 查看", itemViewModel.displayName]
                                                                                                  message:nil
                                                                                            preferredType:TTThemedAlertControllerTypeAlert];
                [alertController addActionWithTitle:@"取消"
                                         actionType:TTThemedAlertActionTypeCancel
                                        actionBlock:nil];
                [alertController addActionWithTitle:@"立刻前往"
                                         actionType:TTThemedAlertActionTypeNormal
                                        actionBlock:^{
                                            [itemViewModel trackDownloadApp];
                                            [itemViewModel trackClickEventWithAction:@"app_download"];
                                            [[SSActionManager sharedManager] openDownloadURL:nil appleID:itemViewModel.appleID];
                                        }];
                [alertController showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
            }
        }
    }
}

@end

 //
//  TTImagePickerController.m
//  TestPhotos
//
//  Created by tyh on 2017/4/7.
//  Copyright © 2017年 tyh. All rights reserved.
//

#import "TTImagePickerController.h"
#import "TTImagePickerCell.h"
#import "TTImageAlbumSelectView.h"
#import "TTImagePickerBottomView.h"
#import "TTImagePreviewViewController.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTTakePhotoViewController.h"
#import "TTIndicatorView.h"
#import "TTImagePicker.h"
#import "TTThemedAlertController.h"
#import "TTImagePickerBackGestureView.h"
#import "TTImagePickerNav.h"
#import "TTImagePickerTrackManager.h"
#import "TTImagePickerAlert.h"
#import "UIViewAdditions.h"

@interface TTImagePickerController ()<UICollectionViewDelegate,UICollectionViewDataSource,TTImagePickerNavDelegate,TTImageAlbumSelectViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,TTImagePreviewViewControllerDelegate,UIGestureRecognizerDelegate,TTImagePickerBackGestureViewDelegate>
{
    TTImagePickerBackGestureCollectionView *_collectionView;
    TTImagePickerBackGestureView *backView;
    TTImagePickerBottomView *_bottomView;
    
    UIView *maskBg;
    UILabel *emptyTips;
    UIView *_collectionViewBack;
    
}

@property (nonatomic,assign)BOOL isAllowPhoto;
@property (nonatomic,assign)BOOL isAllowVideo;


@property (nonatomic,weak)id<TTImagePickerControllerDelegate> delegate;
@property (nonatomic,strong)TTAlbumModel *currentAlbumModel;
@property (nonatomic,strong)NSMutableArray<TTAssetModel *> *seletedModels;
@property (nonatomic,strong)NSMutableArray<UIImage *> *selectedImages;
@property (nonatomic,strong)UIViewController *retainSelf;

//UI
@property (nonatomic,strong) TTImageAlbumSelectView * albumSelectView;
@property (nonatomic,strong) TTTakePhotoViewController *imagePickerVc;

@property (nonatomic,strong) UIView *currentPreviewMaskView; //蒙在当前预览view上的

@property (nonatomic,assign) UIStatusBarStyle lastStyle;
@property (nonatomic,assign) BOOL lastHidden;

@end


@implementation TTImagePickerController

#pragma mark - Life Cycle


- (instancetype)initWithDelegate:(id<TTImagePickerControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.maxImagesCount = 9;
        self.columnNumber = 4;
        self.imagePickerMode = TTImagePickerModePhoto;
        self.seletedModels = [NSMutableArray array];
        self.selectedImages = [NSMutableArray array];
        self.allowTakePicture = YES;
        self.allowAutoSavePicture = YES;
        self.isRequestPhotosBack = YES;
        _selectedCount = 0;
        
        self.isAllowPhoto = YES;
        self.isAllowVideo = NO;
       
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.lastStyle = [UIApplication sharedApplication].statusBarStyle;
    self.lastHidden = [[UIApplication sharedApplication] isStatusBarHidden];

    if (self.imagePickerMode != TTImagePickerModeVideo) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
 
    [TTImagePickerManager manager].sortAscendingByModificationDate = NO;
    [self _initViews];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self _getCurrentImages];
        [self _getAllAlbums];
    });
}


- (void)presentOn:(UIViewController *)parentViewController;
{
    WeakSelf;
    [[TTImagePickerManager manager] startAuthAlbumWithSuccess:^{
        StrongSelf;
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [parentViewController addChildViewController:self];
        self.view.top = KScreenHeight;
        
        //底部遮罩
        maskBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        maskBg.backgroundColor = [UIColor blackColor];
        maskBg.alpha = 0;
        [parentViewController.view addSubview:maskBg];
        
        [parentViewController.view addSubview:self.view];
        
        [UIView animateWithDuration:.35 delay:0 usingSpringWithDamping:.84 initialSpringVelocity:1 options:UIViewAnimationOptionLayoutSubviews animations:^{
            self.view.top = 0;
            maskBg.alpha = 0.4;
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
        
    } fail:^{
        StrongSelf;
        self.retainSelf = self;
        
        UIAlertView * authAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"无访问权限", nil)
                                                             message:NSLocalizedString(@"请在手机的「设置-隐私-照片」选项中，允许爱看访问你的相册", nil)
                                                            delegate:self
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil];
        if (&UIApplicationOpenSettingsURLString != NULL) {
            [authAlert addButtonWithTitle:NSLocalizedString(@"去设置", nil)];
        }
        [authAlert show];
    }];
}

//复写dismiss方法
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if (flag) {
        [UIView animateWithDuration:.35 delay:0 usingSpringWithDamping:.84 initialSpringVelocity:1 options:UIViewAnimationOptionLayoutSubviews animations:^{
            self.view.top = KScreenHeight;
            maskBg.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                [maskBg removeFromSuperview];
                if (completion) {
                    completion();
                }
            }
        }];
    }else{
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [maskBg removeFromSuperview];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:self.lastStyle animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:self.lastHidden];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[UIApplication sharedApplication] setStatusBarStyle:self.lastStyle animated:NO];
//        [[UIApplication sharedApplication] setStatusBarHidden:self.lastHidden];
//    });

}

- (void)showPromptViewAtBottomViewTop:(UIView *)promptView {
    if (!promptView) return;
    promptView.bottom = _bottomView.top;
    [backView addSubview:promptView];
    [backView bringSubviewToFront:_bottomView];
}

#pragma mark - UI
- (void)_initViews
{
    if (self.imagePickerMode == TTImagePickerModeVideo) {
        TTImagePickerTrack(TTImagePickerTrackKeyVideoDidEnter, nil);
    }else if (self.imagePickerMode == TTImagePickerModeAll){
        TTImagePickerTrack(TTImagePickerTrackKeyPhotoVideoDidEnter, nil);
    }
   
    
    //侧滑下拉返回动画的view
    backView = [[TTImagePickerBackGestureView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    backView.delegate = self;
    backView.imagePickerMode = self.imagePickerMode;
    backView.disableDirection = BackGestureDirectionDisabledRight;
    [self.view addSubview:backView];
    
    //导航栏
    if (!self.customAlmumNav) {
        TTImagePickerNav *customAlmumNav = [[TTImagePickerNav alloc] init];
        customAlmumNav.imagePickerMode = self.imagePickerMode;
      
        self.customAlmumNav = customAlmumNav;
    
    }
    
    self.customAlmumNav.delegate = self;
    [backView addSubview:self.customAlmumNav];
    
    
    _bottomView = [[TTImagePickerBottomView alloc] initWithFrame:CGRectMake(0, backView.height - 45, self.view.width, 45)];
    
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _bottomView.frame = CGRectMake(0, backView.height - 45 - TTSafeAreaInsetsBottom, self.view.width, 45 + TTSafeAreaInsetsBottom);
    }
    
    
    WeakSelf;
    _bottomView.previewAction = ^{
        StrongSelf;
        if (self.imagePickerMode == TTImagePickerModePhoto) {
            TTImagePickerTrack(TTImagePickerTrackKeyPreview, nil);
        }else if (self.imagePickerMode == TTImagePickerModeAll)
        {
            TTImagePickerTrack(TTImagePickerTrackKeyPhotoVideoPreview, nil);
        }
        [self previewAction:self.seletedModels select:self.seletedModels index:0 tapView:nil];

    };
    
    [backView addSubview:_bottomView];
    
    UIView *bottomViewMask = [[UIView alloc] initWithFrame:_bottomView.frame];
    bottomViewMask.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [backView insertSubview:bottomViewMask belowSubview:_bottomView];
    

    //图片区域
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 1;
    CGFloat itemWH = (self.view.width - (self.columnNumber - 1) * margin) / self.columnNumber;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    
    _collectionViewBack = [[UIView alloc]initWithFrame:CGRectMake(0, self.customAlmumNav.bottom, self.view.width, backView.height - self.customAlmumNav.bottom - _bottomView.height)];
    _collectionViewBack.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [backView addSubview:_collectionViewBack];
    
    _collectionView = [[TTImagePickerBackGestureCollectionView alloc] initWithFrame:_collectionViewBack.frame collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceHorizontal = NO;
    _collectionView.alpha = 0;
    
    
    //用来监听collectionView偏移量
    backView.collectionView = _collectionView;
    _collectionView.bounces = NO;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, margin, 0);
    
    [_collectionView registerClass:[TTImagePickerCell class] forCellWithReuseIdentifier:@"TTImagePickerCell"];
    [_collectionView registerClass:[TTImagePickerCameraCell class] forCellWithReuseIdentifier:@"TTImagePickerCameraCell"];
    [backView addSubview:_collectionView];
  

    
    
    //视频形式
    if (self.imagePickerMode == TTImagePickerModeVideo) {
        _bottomView.hidden = YES;
        _collectionView.height = _collectionView.height + _bottomView.height;
    }
    
    
}
#pragma mark - Action
- (void)completeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.imagePickerMode == TTImagePickerModeVideo ) {
        
        if (!SSIsEmptyArray(self.seletedModels) && self.delegate && [self.delegate respondsToSelector:@selector(ttimagePickerController:didFinishPickingVideo:sourceAsset:)]) {
            
            TTAssetModel *model = [self.seletedModels firstObject];
            NSString *assetID = [[TTImagePickerManager manager] getAssetIdentifier:model.asset];
            UIImage *coverImage = [[TTImagePickerManager manager].cacheManager getImageWithAssetID:assetID];
            [self.delegate ttimagePickerController:self didFinishPickingVideo:coverImage sourceAsset:model];
        }
    }else if (self.imagePickerMode == TTImagePickerModeAll){
        if (!SSIsEmptyArray(self.seletedModels) && self.delegate && [self.delegate respondsToSelector:@selector(ttimagePickerController:didFinishPickerPhotosAndVideoWithSourceAssets:)]) {
            [self.delegate ttimagePickerController:self didFinishPickerPhotosAndVideoWithSourceAssets:[self.seletedModels copy]];
        }
        
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(ttimagePickerController:didFinishPickingPhotos:sourceAssets:)]) {
            if (self.isRequestPhotosBack) {
                TTImagePickerManager *manager =[TTImagePickerManager manager];
                [manager getPhotosWithAssets:_seletedModels completion:^(NSArray<UIImage *> *photos) {
                    [self.delegate ttimagePickerController:self didFinishPickingPhotos:photos sourceAssets:_seletedModels];
                }];
            }else{
                [self.delegate ttimagePickerController:self didFinishPickingPhotos:nil sourceAssets:_seletedModels];
            }
        }

    }
    
}


#pragma mark - Get & Set
- (void)_getCurrentImages
{
    __weak typeof(self) weakSelf = self;
    
    [[TTImagePickerManager manager] getCameraRollAlbum:self.isAllowVideo allowPickingImage:self.isAllowPhoto completion:^(TTAlbumModel *model) {
        weakSelf.currentAlbumModel = model;
        if (self.imagePickerMode == TTImagePickerModePhoto) {
            if (model.count > 0) {
                TTImagePickerTrack(TTImagePickerTrackKeyDidEnter, nil);
            }else{
                TTImagePickerTrack(TTImagePickerTrackKeyDidEnterNone, nil);
            }
        }
        
        if (model.count == 0) {
            
            _customAlmumNav.enableSelcect = NO;
            
            if (!emptyTips) {
                emptyTips = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
                emptyTips.center = self.view.center;
                emptyTips.text = @"你的相机胶卷是空的";
                emptyTips.textAlignment = NSTextAlignmentCenter;
                emptyTips.font = [UIFont systemFontOfSize:16];
                emptyTips.textColor  = [UIColor tt_themedColorForKey:kColorText3];
                [backView addSubview:emptyTips];
            }

        }else{
            _customAlmumNav.enableSelcect = YES;
        }
        [UIView animateWithDuration:.2 animations:^{
            _collectionView.alpha = 1;
            
        }completion:^(BOOL finished) {
            [_collectionViewBack removeFromSuperview];
        }];
    }];
    

}
- (void)_getAllAlbums
{
    //相册选择视图
    [[TTImagePickerManager manager] getAllAlbums:self.isAllowVideo allowPickingImage:self.isAllowPhoto completion:^(NSArray<TTAlbumModel *> *models) {
    
        
        if (_customAlmumNav && [_customAlmumNav respondsToSelector:@selector(didCompletedTheRequestWithAlbums:)]) {
            [_customAlmumNav didCompletedTheRequestWithAlbums:models];
        }
    }];
    
}
- (void)setCurrentAlbumModel:(TTAlbumModel *)currentAlbumModel
{
    if (_currentAlbumModel != currentAlbumModel) {
        _currentAlbumModel = currentAlbumModel;
        
        [_collectionView reloadData];

    }
    
}

- (TTTakePhotoViewController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[TTTakePhotoViewController alloc] init];
        _imagePickerVc.delegate = self;
    }
    return _imagePickerVc;
}

- (void)setImagePickerMode:(TTImagePickerMode)imagePickerMode{
    _imagePickerMode = imagePickerMode;
    switch (_imagePickerMode) {
        case TTImagePickerModePhoto:
            self.isAllowPhoto = YES;
            self.isAllowVideo = NO;
            break;
        case TTImagePickerModeVideo:
            self.isAllowPhoto = NO;
            self.isAllowVideo = YES;
            break;
        default:
            self.isAllowPhoto = YES;
            self.isAllowVideo = YES;
            break;
    }
}


#pragma mark - Handle Seleted Model
- (void)didSelectModel:(TTAssetModel *)model
{
    [_seletedModels addObject:model];
    _selectedCount = _seletedModels.count;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTImagePickerSelctedCountDidChange object:[NSNumber numberWithInteger:_selectedCount]];
}
- (void)didDeselectModel:(TTAssetModel *)model
{
    
    [_seletedModels removeObject:model];
    _selectedCount = _seletedModels.count;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTImagePickerSelctedCountDidChange object:[NSNumber numberWithInteger:_selectedCount]];
}


#pragma mark - Take Photo
- (void)takePhoto {

    if (self.maxImagesCount <= _seletedModels.count) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[NSString stringWithFormat:@"最多可选%ld张图片", (long)self.maxImagesCount] indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) && iOS7Later) {
        // 无权限
        
        UIAlertView * authAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"无访问权限", nil)
                                                             message:NSLocalizedString(@"请在手机的「设置-隐私-照片」选项中，允许爱看访问你的相机", nil)
                                                            delegate:self
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil];
        if (&UIApplicationOpenSettingsURLString != NULL) {
            [authAlert addButtonWithTitle:NSLocalizedString(@"去设置", nil)];
        }
        [authAlert show];

        
    } else {
        if (self.imagePickerMode == TTImagePickerModePhoto) {
            TTImagePickerTrack(TTImagePickerTrackKeyShoot, nil);
        }
        dispatch_main_async_safe_ttImagePicker(^{
            // 调用相机
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                self.imagePickerVc.sourceType = sourceType;
                if(iOS8Later) {
                    _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                }
                [self.parentViewController presentViewController:_imagePickerVc animated:YES completion:nil];
            } else {
                //            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
            }
        
        });
        
        
       
    }
}



#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   

    return  self.allowTakePicture? _currentAlbumModel.models.count + 1 : _currentAlbumModel.models.count ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isSortAscendingByModificationDate = [TTImagePickerManager manager].sortAscendingByModificationDate;
    //去拍照的cell
    if (((isSortAscendingByModificationDate && indexPath.row >= _currentAlbumModel.models.count)|| (!isSortAscendingByModificationDate && indexPath.row == 0)) && self.allowTakePicture) {
        TTImagePickerCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTImagePickerCameraCell" forIndexPath:indexPath];

        return cell;
    }
    
    //展示照片或视频的cell
    TTImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTImagePickerCell" forIndexPath:indexPath];
    cell.isAllMode = self.imagePickerMode == TTImagePickerModeAll ? YES : NO;
    
    if (isSortAscendingByModificationDate || !self.allowTakePicture) {
        cell.model = _currentAlbumModel.models[indexPath.row];
    } else {
        cell.model = _currentAlbumModel.models[indexPath.row -1];
    }
    
    cell.isCellRefresh = YES;
    if ([_seletedModels containsObject:cell.model] ) {
        cell.isSelected = YES;
    }else{
        cell.isSelected = NO;
    }
    cell.isCellRefresh = NO;
    
    if (self.imagePickerMode != TTImagePickerModeVideo) {
        if (self.maxImagesCount <= _seletedModels.count) {
            cell.isMask = YES;
        }else{
            cell.isMask = NO;
        }
    }
    return cell;
}

//so trick
- (void)didSelectItemWithCell:(UICollectionViewCell *)cell
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    if (_allowTakePicture && indexPath.row == 0) {
        
        [self takePhoto];
    } else {
        
        if (self.imagePickerMode == TTImagePickerModePhoto) {
            TTImagePickerTrack(TTImagePickerTrackKeyPreviewPhoto, nil);
        }else if (self.imagePickerMode == TTImagePickerModeVideo)
        {
            TTImagePickerTrack(TTImagePickerTrackKeyVideoPreview, nil);
        }else{
            
            TTAssetModel *model = self.currentAlbumModel.models[indexPath.row];
            if (model.type == TTAssetModelMediaTypeVideo) {
                TTImagePickerTrack(TTImagePickerTrackKeyPhotoVideoPreviewVideo, nil);
            }else{
                TTImagePickerTrack(TTImagePickerTrackKeyPhotoVideoPreviewPhoto, nil);
            }
        }
        
        TTImagePickerCell *cell = (TTImagePickerCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        
        [self previewAction:self.currentAlbumModel.models select:self.seletedModels index:_allowTakePicture? indexPath.row-1: indexPath.row tapView:cell.img];
    }
    
}
//有一个点击无法响应的bug，废弃
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}



- (void)previewAction:(NSArray *)totalModels select:(NSMutableArray *)selectedModels index:(NSInteger)index tapView:(UIImageView *)tapView;
{
    
    TTImagePreviewViewController *peviewViewController = nil;
    if (self.imagePickerMode == TTImagePickerModeVideo) {
        peviewViewController = [TTImagePreviewViewController selectPreviewViewControllerWithVideo:totalModels[index] delegate:self];
    }else{
        peviewViewController = [TTImagePreviewViewController
                                     selectPreviewViewControllerWithModes:totalModels
                                     selects:selectedModels
                                     index:index
                                     delegate:self];
    }
    peviewViewController.tapView = tapView;
    peviewViewController.maxLimit = _maxImagesCount;
    peviewViewController.lastHidden = self.lastHidden;
    peviewViewController.statusBarAutoHidden = NO;
    [peviewViewController presentOn:self];
}

#pragma mark  -- TTImagePickerNavDelegate

//导航栏关闭
- (void)ttImagePickerNavDidClose
{
    if (self.imagePickerMode == TTImagePickerModeVideo) {
        TTImagePickerTrack(TTImagePickerTrackKeyVideoClickClose, nil);
    }
    
    if ([self.delegate respondsToSelector:@selector(ttImagePickerControllerDidCancel:)]) {
        [self.delegate ttImagePickerControllerDidCancel:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
//选择哪个相册
- (void)ttImagePickerNavDidSelect:(TTAlbumModel *)model;
{
    self.currentAlbumModel = model;
}
- (void)ttImagePickerNavDidFinish
{
    if (self.imagePickerMode == TTImagePickerModePhoto) {
        TTImagePickerTrack(TTImagePickerTrackKeyListFinished, nil);
    }
    [self completeAction];
}



#pragma mark  -- TTImagePreviewViewControllerDelegate
- (void)ttImagePreviewViewControllerDidDismiss:(TTImagePreviewViewController *)controller
{
    BOOL showAnimating = NO;
    if (controller.animatedImageView && _currentPreviewMaskView && _currentPreviewMaskView.superview) {
        showAnimating = YES;
        
        CGRect frame = [_currentPreviewMaskView convertRect:_currentPreviewMaskView.bounds toView:self.view];

       
        [UIView animateWithDuration:0.2 animations:^{
            controller.animatedImageView.frame = frame;
            controller.animatedImageView.contentMode = UIViewContentModeScaleAspectFill;
            controller.animatedImageView.clipsToBounds = YES;
        } completion:^(BOOL finished) {
             [_currentPreviewMaskView removeFromSuperview];
        }];
    }
    
    if (!showAnimating) {
        if (_currentPreviewMaskView) {
            [_currentPreviewMaskView removeFromSuperview];
        }
    }

}

- (void)ttImagePreviewViewControllerScrollChange:(TTImagePreviewViewController *)controller index:(NSInteger)index {
    if (_currentPreviewMaskView) {
        [_currentPreviewMaskView removeFromSuperview];
    }
    
    TTAssetModel* model = [controller.allModels objectAtIndex:index];
    if ([_currentAlbumModel.models containsObject:model]) {
        NSUInteger index = [_currentAlbumModel.models indexOfObject:model];
        if (_allowTakePicture) index++;
        
        TTImagePickerCell *cell = (TTImagePickerCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        if (cell && [cell isKindOfClass:[TTImagePickerCell class]] && [_collectionView.visibleCells containsObject:cell]) {
            if (!_currentPreviewMaskView) {
                _currentPreviewMaskView = [[UIView alloc] init];
                _currentPreviewMaskView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            }
            _currentPreviewMaskView.frame = [cell convertRect:cell.bounds toView:_collectionView];
            [_collectionView addSubview:_currentPreviewMaskView];
        }
    }
}

- (void)ttImagePreviewViewControllerSelectDidFinish:(TTImagePreviewViewController *)controller
{
    self.seletedModels = controller.selectModels;

    [self completeAction];
    [controller dismiss:YES isGestureAnimate:YES];

}

- (void)ttImagePreviewViewControllerSelectChange:(TTImagePreviewViewController *)controller index:(NSInteger)index;
{
    self.seletedModels = controller.selectModels;
    
    _selectedCount = self.seletedModels.count;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTImagePickerSelctedCountDidChange object:[NSNumber numberWithInteger:_selectedCount]];
    [_collectionView reloadData];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (self.imagePickerMode == TTImagePickerModePhoto) {
        TTImagePickerTrack(TTImagePickerTrackKeyConfirmShoot, nil);
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:self.lastStyle animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:self.lastHidden];
        //适配iOS7的两个dismiss
        if (!iOS8Later) {
            [self _didFinishPickingMediaWithInfo:info];
        }

    }];
    if (iOS8Later) {
        [self _didFinishPickingMediaWithInfo:info];
    }
    
}

- (void)_didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if (![type isEqualToString:@"public.image"]) {
        return;
    }
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        if (self.allowAutoSavePicture) {
            [[TTImagePickerManager manager] savePhotoWithImage:image completion:nil];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(ttimagePickerController:didFinishTakePhoto:selectedAssets:withInfo:)]) {
            if (SSIsEmptyArray(self.seletedModels)) {
                [self.delegate ttimagePickerController:self didFinishTakePhoto:image selectedAssets:nil withInfo:info];
            }else{
                [self.delegate ttimagePickerController:self didFinishTakePhoto:image selectedAssets:self.seletedModels withInfo:info];
            }
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    if (self.imagePickerMode == TTImagePickerModePhoto) {
        TTImagePickerTrack(TTImagePickerTrackKeyCancelShoot, nil);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TTImagePickerBackGestureViewDelegate

- (void)ttImagePickerBackGestureViewdidScrollScale:(float)scale
{
    float needScale = 1 - scale;
    maskBg.alpha = needScale *0.4;
}
- (void)ttImagePickerBackGestureViewdidFinnish
{
    [UIView animateWithDuration:.2 animations:^{
        maskBg.alpha = 0;
    }];
}
- (void)ttImagePickerBackGestureViewdidCancel
{
    [UIView animateWithDuration:.2 animations:^{
        maskBg.alpha = 0.4;
    }];
}

#pragma mark -- Rotate
//每次改变方向调用，（必须是window的rootvc关系链里的）
- (BOOL)shouldAutorotate
{
    return NO;
}

//出现的时候调用，初始化方向，之后每次shouldAutorotate为YES的时候才会调用
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([TTDeviceHelper OSVersionNumber] >= 10.0) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    self.retainSelf = nil;
}




@end

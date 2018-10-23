//
//  TTAssetCell.m
//  TestPhotos
//
//  Created by tyh on 2017/4/7.
//  Copyright © 2017年 tyh. All rights reserved.
//

#import "TTImagePickerCell.h"
#import "TTImagePickerManager.h"
#import "UIView+TTImagePickerViewController.h"
#import "TTImagePickerController.h"
#import "UIColor+TTThemeExtension.h"
#import "TTIndicatorView.h"
#import "UIViewAdditions.h"
#import "SSThemed.h"

@interface TTImagePickerCell()
{
    UIView *selectView;
    UIImageView *typeBg;
}

@property (nonatomic,strong)UIImageView *selectImg;
@property (nonatomic,strong)UIView *mask;
@property (nonatomic,strong)UILabel *typeLabel;


@property (nonatomic, copy) NSString *representedAssetIdentifier;
//请求图片的ID
@property (nonatomic, assign) PHImageRequestID imageRequestID;



@end

@implementation TTImagePickerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initViews];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedCountDidChange:) name:TTImagePickerSelctedCountDidChange object:nil];

    }
    return self;
}


#pragma mark - UI

- (void)_initViews
{
    _img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _img.contentMode = UIViewContentModeScaleAspectFill;
    _img.clipsToBounds = YES;
    
    [self.contentView addSubview:_img];
    
    _selectImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 2 - 24, 2, 24, 24)];
    _selectImg.image = [UIImage themedImageNamed:@"ImgPic_select_album"];
    [self.contentView addSubview:self.selectImg];
    
    selectView = [[UIView alloc]initWithFrame:CGRectMake(self.width - 44, 0, 44, 44)];
    selectView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self.contentView addSubview:selectView];
    
    UITapGestureRecognizer *selectTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectAction)];
    [selectView addGestureRecognizer:selectTap];
    
    
    _typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.width - 44 -2, self.height - 20 -2, 44, 20)];
    _typeLabel.layer.cornerRadius = 10;
    _typeLabel.font = [UIFont systemFontOfSize:10];
    _typeLabel.textColor = [UIColor tt_themedColorForKey:kColorText12];
    _typeLabel.hidden = YES;
    _typeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview: _typeLabel];
    
    
    UIImage * image = [UIImage themedImageNamed:@"message_background_view"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2, image.size.width / 2, image.size.height / 2 - 1, image.size.width / 2 - 1) resizingMode:UIImageResizingModeTile];
    
    
    typeBg = [[UIImageView alloc]initWithFrame:_typeLabel.frame];
    typeBg.hidden = YES;
    typeBg.image = image;
    [self.contentView insertSubview:typeBg belowSubview:_typeLabel];
    
    
    _mask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _mask.backgroundColor = [UIColor blackColor];
    _mask.alpha = 0.5;
    _mask.hidden = YES;
    [self.contentView addSubview:_mask];
    
    UITapGestureRecognizer *interceptTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(interceptTapAction)];
    [_mask addGestureRecognizer:interceptTap];
    
    UITapGestureRecognizer *contentViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageAction)];
    [self.contentView addGestureRecognizer:contentViewTap];
    
}


#pragma mark - Set Function

- (void)setModel:(TTAssetModel *)model
{
    _model = model;
    
    switch (_model.type) {
        case TTAssetModelMediaTypeVideo:
            _typeLabel.text = [TTAssetModel getNewTimeFromDurationSecond:[_model.timeLength integerValue]];
            _typeLabel.hidden = NO;
            typeBg.hidden = NO;
            
            if (!self.isAllMode) {
                selectView.hidden  = YES;
                _selectImg.hidden = YES;
                if ([_model.timeLength integerValue] <3 || [_model.timeLength integerValue] > 60 *15) {
                    _mask.hidden = NO;
                }else{
                    _mask.hidden = YES;
                }
            }
            break;
        case TTAssetModelMediaTypePhotoGif:
            _typeLabel.text = @"GIF";
            _typeLabel.hidden = NO;
            typeBg.hidden = NO;

            selectView.hidden  = NO;
            _selectImg.hidden = NO;
            break;
        default:
            _typeLabel.hidden = YES;
            typeBg.hidden = YES;

            selectView.hidden  = NO;
            _selectImg.hidden = NO;
            break;
    }
    
    if (iOS8Later) {
        self.representedAssetIdentifier = [[TTImagePickerManager manager] getAssetIdentifier:model.asset];
    }
    
    PHImageRequestID imageRequestID = [[TTImagePickerManager manager] getPhotoWithAsset:model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
    
        if (!photo) {
            return ;
        }
        
        if (!iOS8Later) {
            self.img.image = photo; return;
        }
        if ([self.representedAssetIdentifier isEqualToString:[[TTImagePickerManager manager] getAssetIdentifier:model.asset]]) {
            self.img.image = photo;
            model.thumbImage = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        //是否是高质量图，高质量图清空id
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
        
    } progressHandler:nil isIcloudEabled:NO isSingleTask:NO];
    
    //不是同一个ID，则取消之前的图片请求
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;

    
}


- (void)setIsSelected:(BOOL)isSelected
{
    TTImagePickerController *vc = (TTImagePickerController *)self.ttImagePickerViewController;
    if (vc && vc.selectedCount >= vc.maxImagesCount && !_isSelected && !_isCellRefresh)
    {
        return;
    }
    
    _isSelected = isSelected;
    if (_isSelected) {
        
        if (_isCellRefresh) {
            _selectImg.image = [UIImage themedImageNamed:@"ImgPic_select_ok_album"];
            return;
        }
        
        UIImageView *rotateImg = [[UIImageView alloc] initWithFrame:_selectImg.bounds];
        rotateImg.image = [UIImage themedImageNamed:@"ImgPic_select_ok_album"];
        rotateImg.transform = CGAffineTransformMakeScale(0.2, 0.2);
        rotateImg.transform = CGAffineTransformRotate(rotateImg.transform, -M_PI/4);
        [_selectImg addSubview:rotateImg];
        
        [UIView animateWithDuration:0.1 animations:^{
            rotateImg.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [rotateImg removeFromSuperview];
            _selectImg.image = [UIImage themedImageNamed:@"ImgPic_select_ok_album"];
        }];
        
        //缓存一下大图
        [[TTImagePickerManager manager] getPhotoWithAsset:self.model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            
        }];
        
    }else{
        _selectImg.image = [UIImage themedImageNamed:@"ImgPic_select_album"];
    }

}

- (void)setIsMask:(BOOL)isMask
{
    _isMask = isMask;
    if (_isMask && !_isSelected) {
        _mask.hidden = NO;
    }else{
        _mask.hidden = YES;
    }
}


#pragma mark - Action

- (void)selectAction
{
    self.isSelected = !self.isSelected;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (_isSelected) {
        [self.ttImagePickerViewController performSelector:NSSelectorFromString(@"didSelectModel:") withObject:self.model];
    }else{
        [self.ttImagePickerViewController performSelector:NSSelectorFromString(@"didDeselectModel:") withObject:self.model];
    }
#pragma clang diagnostic pop

}

/// 用来拦截ColectionView点击代理
- (void)interceptTapAction{
    
    NSString *tips;
    TTImagePickerController *vc = (TTImagePickerController *)self.ttImagePickerViewController;
    if (self.model.type == TTAssetModelMediaTypeVideo) {
        if ([self.model.timeLength intValue] < 3 ) {
            tips = @"不支持上传短于3秒的视频";
        }
        if ([self.model.timeLength intValue] > 60 *15 ) {
            tips = @"不支持上传15分钟以上的视频";
        }
    }else{
        tips = [NSString stringWithFormat:@"最多只能选%ld张图片",vc.maxImagesCount];
    }
    
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                              indicatorText:tips
                             indicatorImage:nil
                                autoDismiss:YES
                             dismissHandler:nil];
}

- (void)imageAction
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.ttImagePickerViewController performSelector:NSSelectorFromString(@"didSelectItemWithCell:") withObject:self];
#pragma clang diagnostic pop
}




#pragma mark - Notify
- (void)selectedCountDidChange:(NSNotification *)notify
{
    
    TTImagePickerController *vc = (TTImagePickerController *)self.ttImagePickerViewController;
   
    if ([notify.object intValue] >= vc.maxImagesCount && !self.isSelected) {
        _mask.hidden = NO;
    }else{
        _mask.hidden = YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end

@interface TTImagePickerCameraCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic,strong)UIView *mask;

@end

@implementation TTImagePickerCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - 40)/2.0,( self.height - 40 -10)/2.0, 40, 40)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.image = [UIImage imageNamed:@"ImgPic_Camera_Icon"];
        [self addSubview:_imageView];
        self.clipsToBounds = YES;
        
        UILabel *tips = [[UILabel alloc]initWithFrame:CGRectMake((self.width - 50)/2.0, _imageView.bottom ,  50, 10)];
        tips.text = @"拍摄照片";
        tips.textColor = [UIColor tt_themedColorForKey:kColorText3];
        tips.font = [UIFont systemFontOfSize:10];
        tips.textAlignment = NSTextAlignmentCenter;
        [self addSubview:tips];
        
        
        _mask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = 0.5;
        _mask.hidden = YES;
        [self.contentView addSubview:_mask];
        
        UITapGestureRecognizer *interceptTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(interceptTapAction)];
        [_mask addGestureRecognizer:interceptTap];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedCountDidChange:) name:TTImagePickerSelctedCountDidChange object:nil];
        
        UITapGestureRecognizer *contentViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageAction)];
        [self.contentView addGestureRecognizer:contentViewTap];
    }
    return self;
}

/// 用来拦截ColectionView点击代理
- (void)interceptTapAction{
    TTImagePickerController *vc = (TTImagePickerController *)self.ttImagePickerViewController;
    
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                              indicatorText:[NSString stringWithFormat:@"最多只能选%ld张图片",vc.maxImagesCount]
                             indicatorImage:nil
                                autoDismiss:YES
                             dismissHandler:nil];
    
}

- (void)imageAction
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.ttImagePickerViewController performSelector:NSSelectorFromString(@"didSelectItemWithCell:") withObject:self];
#pragma clang diagnostic pop
}


#pragma mark - Notify
- (void)selectedCountDidChange:(NSNotification *)notify
{
    
    TTImagePickerController *vc = (TTImagePickerController *)self.ttImagePickerViewController;
    if ([notify.object intValue] >= vc.maxImagesCount ) {
        _mask.hidden = NO;
    }else{
        _mask.hidden = YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end

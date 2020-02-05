//
//  FRPostAssetViewColumn.m
//  Article
//
//  Created by SongChai on 09/06/2017.
//
//

#import "FRPostAssetViewColumn.h"
#import <TTThemed/SSThemed.h>
#import <TTImagePicker/TTImagePickerManager.h>
#import <TTImagePicker/TTImagePickerLoadingView.h>
#import <TTBaseLib/UIViewAdditions.h>

@interface FRPostAssetViewColumn ()<UIGestureRecognizerDelegate> {
    UILabel *_gifLabel;
    
    CGRect _startFrame;
    CGPoint _startPoint;
}

@property (nonatomic, strong) TTAssetModel *assetModel;
@property (nonatomic, strong) TTImagePickerLoadingView *loadingView;
@property (nonatomic, strong) UIView *mask;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;
@property (nonatomic, strong) UIImageView * deleteImageView;
@end


@implementation FRPostAssetViewColumn

@synthesize column = _column;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapAction:)];
        _tapGesture.delegate = self;
        [self addGestureRecognizer:_tapGesture];
        
        _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(userDidLongPressAction:)];
        _longGesture.minimumPressDuration = 0.3;
        _longGesture.delegate = self;
        [self addGestureRecognizer:_longGesture];
        
        // Add the photo thumbnail.
        _assetImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _assetImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_assetImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        _assetImageView.clipsToBounds = YES;
        
        [self addSubview:_assetImageView];
        
        _mask = [[UIView alloc]initWithFrame:self.bounds];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = 0.3;
        _mask.hidden = YES;
        [_mask setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:_mask];
        
        UIImageView * deleteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fh_ugc_del_normal"]];
        deleteImageView.width = 22;
        deleteImageView.height = 22;
        deleteImageView.origin = CGPointMake(self.width - 22, 0);
        [self addSubview:deleteImageView];
        _deleteImageView = deleteImageView;
        
        float width = self.width/3;
        UIButton *selectButton = [[UIButton alloc] initWithFrame: CGRectMake(self.width - width , 0, width, width)];
        [selectButton setBackgroundColor:[UIColor clearColor]];
        [selectButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self addSubview:selectButton];
        [selectButton addTarget:self action:@selector(onClickDelete) forControlEvents:UIControlEventTouchUpInside];
        
        _gifLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.width - 44 -2, self.height - 20 -2, 44, 20)];
        _gifLabel.layer.cornerRadius = 10;
        _gifLabel.layer.masksToBounds = YES;
        _gifLabel.font = [UIFont systemFontOfSize:10];
        _gifLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _gifLabel.textColor = [UIColor tt_themedColorForKey:kColorText12];
        _gifLabel.text = @"GIF";
        _gifLabel.textAlignment = NSTextAlignmentCenter;
        [_gifLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
        [self addSubview:_gifLabel];
        
        [self reloadThemeUI];
  
        _loadingView = [[TTImagePickerLoadingView alloc]initWithFrame:CGRectMake((self.width - 32)/2.0, (self.height - 32)/2.0, 32, 32)];
        _loadingView.hidden = YES;
        [_loadingView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
        _loadingView.inset = 2.5;
        
        WeakSelf;
        _loadingView.retry = ^{
            StrongSelf;
            //重新开始加载
            [self reloadTask];
        };
        [self addSubview:_loadingView];
        
        self.dragEnable = YES;
        self.showPickerLoadingView = YES;
    }
    return self;
}

- (void)loadWithImage:(UIImage *)image {
    if (image.images && image.images.count > 0) {
        _gifLabel.hidden = NO;
        _assetImageView.image = [image.images firstObject];
    } else {
        _gifLabel.hidden = YES;
        _assetImageView.image = image;
    }
}


- (void)loadWithAsset:(TTAssetModel *)asset {
    
    if (!asset) {
        return;
    }
    self.assetModel = asset;
    
    _gifLabel.hidden = asset.type != TTAssetModelMediaTypePhotoGif;
    
    if (!self.assetImageView.image) {
        self.assetImageView.image = asset.thumbImage;
    }
    if (!self.assetImageView.image) {
        self.assetImageView.image = asset.cacheImage;
    }
    
    if (!self.assetImageView.image) {
        __block UIImage *image = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:asset.imageURL]];
            if (image){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.assetImageView.image = image;
                });
            }
        });
    }
    
    [[TTImagePickerManager manager] getPhotoWithAsset:asset.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (!photo) {
            return;
        }
        //太恶心了，这个黑色闪烁问题卡了一天...
        NSData *data = UIImageJPEGRepresentation(photo, 0.9);
        UIImage *finalImg = [UIImage imageWithData:data];
        if (finalImg) {
            self.assetImageView.image = finalImg;
        }
    } progressHandler:nil isIcloudEabled:YES isSingleTask:NO];
    

    
}

- (void)setTask:(TTUGCImageCompressTask *)task {
    _task = task;

    if ([[TTImagePickerManager manager] isNeedIcloudSync:self.assetModel.asset] && _task.status != FHiCloudSyncStatusSuccess) {
        _loadingView.progress = 0;
        _mask.hidden = NO;
        
        WeakSelf;
        [task iCloud_addCompleteBlock:^(BOOL success) {
            if (success) {
                wself.loadingView.progress = 1;
                wself.mask.hidden = YES;
                
            } else {
                wself.loadingView.isFailed = YES;
            }
        }];
        [task iCloud_addProgressBlock:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            wself.loadingView.progress = progress;
            if (progress == 1) {
                wself.mask.hidden = YES;
            }
        }];
    }
   
}
- (void)reloadTask {
    if (!_task) {
        return;
    }
    [[TTUGCImageCompressManager sharedInstance] queryFilePathWithTask:_task complete:nil];
}

- (void)reset {
    self.panEnable = NO;
    self.alpha = 1.0;
    self.layer.zPosition = 0.0;
    self.transform = CGAffineTransformMakeScale(1.0, 1.0);
}

- (void)setDragTargetFrame:(CGRect)targetFrame {
    if (self.panEnable) {
        _startFrame = targetFrame;
    } else {
        _startFrame = CGRectZero;
        self.frame = targetFrame;
        _startPoint = CGPointZero;
    }
}
#pragma mark - Actions
- (void)userDidTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapAssetViewColumn:)]) {
            [self.delegate didTapAssetViewColumn:self];
        }
    }
}

- (void)userDidLongPressAction:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(assetViewColumnDidBeginDragging:)]) {
            [self.delegate assetViewColumnDidBeginDragging:self];
        }
        _startFrame = self.frame;
        _startPoint = [sender locationInView:sender.view];
        [CATransaction begin];
        CAMediaTimingFunction *funtion = [CAMediaTimingFunction functionWithControlPoints:0.14 :1 :0.34 :1];
        [CATransaction setAnimationTimingFunction:funtion];
        self.layer.zPosition = 1.0;
        self.panEnable = YES;
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformMakeScale(1.2, 1.2);
            self.alpha = 0.9;
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(onDragingAssetViewColumn:atPoint:)]) { // 主要目的是收起键盘
                [self.delegate onDragingAssetViewColumn:self atPoint:[sender locationInView:sender.view.superview]];
            }
        }];
        [CATransaction commit];
    } else if (sender.state == UIGestureRecognizerStateChanged){
        if (self.panEnable) {
            CGPoint newPoint = [sender locationInView:sender.view];
            CGFloat deltaX = newPoint.x - _startPoint.x;
            CGFloat deltaY = newPoint.y - _startPoint.y;
            
            UIView *view = sender.view;
            view.center = CGPointMake(view.centerX + deltaX, view.centerY + deltaY);
            if ([self.delegate respondsToSelector:@selector(onDragingAssetViewColumn:atPoint:)]) {
                [self.delegate onDragingAssetViewColumn:self atPoint:[sender locationInView:sender.view.superview]];
            }
        }
    } else {
        self.panEnable = NO;
        [CATransaction begin];
        CAMediaTimingFunction *funtion = [CAMediaTimingFunction functionWithControlPoints:0.14 :1 :0.34 :1];
        [CATransaction setAnimationTimingFunction:funtion];
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.center = CGPointMake(self->_startFrame.origin.x + self->_startFrame.size.width/2, self->_startFrame.origin.y + self->_startFrame.size.height/2);
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.alpha = 1;
        } completion:^(BOOL finished) {
            [self reset];
            
            if ([self.delegate respondsToSelector:@selector(assetViewColumnDidFinishDragging:)]) {
                [self.delegate assetViewColumnDidFinishDragging:self];
            }
        }];
        [CATransaction commit];
    }
}

- (void)onClickDelete {
    if (self.panEnable) return; // 拖拽中不能点击删除
    [[TTImagePickerManager manager].icloudDownloader cancelDownloadIcloudPhotoWithAsset:_assetModel.asset];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDeleteAssetViewColumn:)]) {
        [self.delegate didDeleteAssetViewColumn:self];
    }
}

- (void)setDragEnable:(BOOL)dragEnable {
    _dragEnable = dragEnable;
    
    self.longGesture.enabled = dragEnable;
}

- (void)setShowPickerLoadingView:(BOOL)showPickerLoadingView {
    _showPickerLoadingView = showPickerLoadingView;
    
    if (_showPickerLoadingView) {
        [self addSubview:self.loadingView];
    } else {
        [self.loadingView removeFromSuperview];
    }
}

@end

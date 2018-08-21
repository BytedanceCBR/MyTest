//
//  FRPostAssetViewColumn.m
//  Article
//
//  Created by SongChai on 09/06/2017.
//
//

#import "FRPostAssetViewColumn.h"
#import "SSThemed.h"
#import "TTImagePickerManager.h"
#import "TTImagePickerLoadingView.h"
#import "UIViewAdditions.h"

@interface FRPostAssetViewColumn ()
{
    UILabel *_gifLabel;
}
@property (nonatomic,strong)TTAssetModel *assetModel;
@property (nonatomic,strong)TTImagePickerLoadingView *loadingView;
@property (nonatomic,strong)UIView *mask;

@end


@implementation FRPostAssetViewColumn

@synthesize column = _column;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        // Add the photo thumbnail.
        _assetImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _assetImageView.contentMode = UIViewContentModeScaleAspectFill;
        _assetImageView.clipsToBounds = YES;
        
        [self addSubview:_assetImageView];
        
        _mask = [[UIView alloc]initWithFrame:self.bounds];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = 0.3;
        _mask.hidden = YES;
        [self addSubview:_mask];
        
        UIImageView * deleteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ImgPic_delete_image"]];
        deleteImageView.width = self.width;
        deleteImageView.height = 80/222.0 * self.width;
        [self addSubview:deleteImageView];
        
        float width = self.width/3;
        UIButton *selectButton = [[UIButton alloc] initWithFrame: CGRectMake(self.width - width , 0, width, width)];
        [selectButton setBackgroundColor:[UIColor clearColor]];
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
        [self addSubview:_gifLabel];
        
        [self reloadThemeUI];
  
        _loadingView = [[TTImagePickerLoadingView alloc]initWithFrame:CGRectMake((self.width - 32)/2.0, (self.height - 32)/2.0, 32, 32)];
        _loadingView.hidden = YES;
        _loadingView.inset = 2.5;
        
        WeakSelf;
        _loadingView.retry = ^{
            StrongSelf;
            //重新开始加载
            [self reloadTask];
        };
        [self addSubview:_loadingView];
    }
    return self;
}

- (void)loadWithImage:(UIImage *)image {
    if (image.images && image.images.count > 0) {
        _gifLabel.hidden = NO;
        _assetImageView.image = [image.images firstObject];
    }else{
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

    
    [[TTImagePickerManager manager] getPhotoWithAsset:asset.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (!photo) {
            return;
        }
        //太恶心了，这个黑色闪烁问题卡了一天...
        NSData *data = UIImagePNGRepresentation(photo);
        UIImage *finalImg = [UIImage imageWithData:data];
        if (finalImg) {
            self.assetImageView.image = finalImg;
        }
    } progressHandler:nil isIcloudEabled:YES isSingleTask:NO];
    

    
}

- (void)setTask:(TTForumPostImageCacheTask *)task
{
    _task = task;

    if ([[TTImagePickerManager manager] isNeedIcloudSync:self.assetModel.asset] && _task.status != IcloudSyncComplete) {
        _loadingView.progress = 0;
        _mask.hidden = NO;
        
        NSMutableArray *icloudCompletes = [task.icloudCompletes mutableCopy];
        if (!icloudCompletes) {
            icloudCompletes = [NSMutableArray array];
        }
        WeakSelf;
        PostIcloudCompletion icloudBlock = ^(BOOL success) {
            if (success) {
                wself.loadingView.progress = 1;
                wself.mask.hidden = YES;
                
            }else{
                wself.loadingView.isFailed = YES;
            }
        };
        [icloudCompletes addObject:[icloudBlock copy]];
        
        task.icloudCompletes = icloudCompletes;
        
        NSMutableArray *icloudProgresses = [task.icloudProgresses mutableCopy];
        if (!icloudProgresses) {
            icloudProgresses = [NSMutableArray array];
        }
        PostIcloudProgressHandler progressBlock = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            wself.loadingView.progress = progress;
            if (progress == 1) {
                wself.mask.hidden = YES;
            }
        };
        [icloudProgresses addObject:[progressBlock copy]];
        task.icloudProgresses = icloudProgresses;
    }
   
}
- (void)reloadTask
{
    if (!_task) {
        return;
    }
    [[TTForumPostImageCache sharedInstance] queryFilePathWithSource:_task complete:nil];
}

#pragma mark - Actions
- (void)userDidTapAction:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapAssetViewColumn:)]) {
            [self.delegate didTapAssetViewColumn:self];
        }
    }
}

- (void)onClickDelete {
    [[TTImagePickerManager manager].icloudDownloader cancelDownloadIcloudPhotoWithAsset:_assetModel.asset];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDeleteAssetViewColumn:)]) {
        [self.delegate didDeleteAssetViewColumn:self];
    }
}
@end

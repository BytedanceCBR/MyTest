//
//  FHDetailPhotoHeaderCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/11.
//

#import "FHDetailPhotoHeaderCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import <TTShareManager.h>
#import <TTPhotoScrollViewController.h>
#import "FHUserTracker.h"

#define K_PhotoHeader_HEIGHT 300
#define K_CELLID @"cell_id"

@interface FHPhotoHeaderCell : UICollectionViewCell

@property(nonatomic , strong) UIImageView *imageView;

@end

@interface FHDetailPhotoHeaderCell ()<UICollectionViewDelegate,UICollectionViewDataSource, TTPhotoScrollViewControllerDelegate>
@property(nonatomic , strong) UICollectionView *colletionView;
@property(nonatomic , strong) NSArray<FHDetailPhotoHeaderModelProtocol> *images;
@property(nonatomic , strong) UILabel *infoLabel;
@property(nonatomic , strong) UIImage *placeHolder;
@property(nonatomic , strong) UIImageView *noDataImageView;
@property(nonatomic, strong) NSMutableDictionary *pictureShowDict;
@property(nonatomic, assign) BOOL isLarge;
@property(nonatomic, assign) NSInteger currentIndex;
@property(nonatomic, assign) NSTimeInterval enterTimestamp;
@end

@implementation FHDetailPhotoHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailPhotoHeaderModel class]]) {
        return;
    }
    self.currentData = data;
    id images = ((FHDetailPhotoHeaderModel *)data).houseImage;
    [self updateWithImages:images];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _pictureShowDict = [NSMutableDictionary dictionary];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //        layout.estimatedItemSize = CGSizeMake(SCREEN_WIDTH, HEIGHT);
        layout.itemSize = CGSizeMake(SCREEN_WIDTH, K_PhotoHeader_HEIGHT);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _colletionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, K_PhotoHeader_HEIGHT) collectionViewLayout:layout];
        _colletionView.backgroundColor = [UIColor whiteColor];
        _colletionView.pagingEnabled = YES;
        _colletionView.showsHorizontalScrollIndicator = NO;
        
        [_colletionView registerClass:[FHPhotoHeaderCell class] forCellWithReuseIdentifier:K_CELLID];
        
        _colletionView.delegate = self;
        _colletionView.dataSource = self;
        
        [self.contentView addSubview:_colletionView];
        
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.font = [UIFont themeFontRegular:12];
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.layer.cornerRadius = 10;
        _infoLabel.layer.masksToBounds = YES;
        
        [self.contentView addSubview:_infoLabel];
        
        _noDataImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_noDataImageView];
        _noDataImageView.hidden = YES;
        
        [_colletionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.mas_equalTo(self.colletionView.superview);
            make.height.mas_equalTo(K_PhotoHeader_HEIGHT);
        }];
        
        [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(20);
            make.right.mas_equalTo(self.infoLabel.superview).offset(-20);
            make.bottom.mas_equalTo(self.infoLabel.superview).offset(-10);
        }];
        [_noDataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.mas_equalTo(self.colletionView.superview);
            make.height.mas_equalTo(K_PhotoHeader_HEIGHT);
        }];
        
        
    }
    return self;
}

-(UIImage *)placeHolder
{
    if (!_placeHolder) {
        _placeHolder = [UIImage imageNamed:@"default_image"];
    }
    return _placeHolder;
}

// 模型要实现FHDetailPhotoHeaderCellProtocol
-(void)updateWithImages:(NSArray<FHDetailPhotoHeaderModelProtocol>*)images
{
    self.images = images;
    [self.colletionView reloadData];
    if (images.count > 0) {
        self.infoLabel.text = [NSString stringWithFormat:@"%d/%ld",1,images.count];
        self.infoLabel.hidden = NO;
        self.colletionView.hidden = NO;
        self.noDataImageView.hidden = YES;
        if (images.count > 1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    }else{
        self.infoLabel.hidden = YES;
        self.colletionView.hidden = YES;
        self.noDataImageView.hidden = NO;
        if (!_noDataImageView.image) {
            _noDataImageView.image = [UIImage imageNamed:@"default_image"];
        }
    }
}

//埋点
- (void)trackPictureShowWithIndex:(NSInteger)index {
    id<FHDetailPhotoHeaderModelProtocol> img = _images[index];
    NSString *showType = self.isLarge ? @"large" : @"small";
    NSString *row = [NSString stringWithFormat:@"%@_%i",showType,index];
    self.isLarge = NO;
    if (_pictureShowDict[row]) {
        return;
    }
    
    _pictureShowDict[row] = row;
    
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
    if(!dict){
        dict = [NSMutableDictionary dictionary];
    }
    [dict removeObjectsForKeys:@[@"card_type",@"rank"]];
    dict[@"picture_id"] = img.url;
    dict[@"show_type"] = showType;
    TRACK_EVENT(@"picture_show", dict);
}

//埋点
- (void)trackPictureLargeStayWithIndex:(NSInteger)index {
    id<FHDetailPhotoHeaderModelProtocol> img = _images[index];
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
    if(!dict){
        dict = [NSMutableDictionary dictionary];
    }
    [dict removeObjectsForKeys:@[@"card_type",@"rank"]];
    dict[@"picture_id"] = img.url;
    dict[@"show_type"] = @"large";
    
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _enterTimestamp;
    if (duration <= 0) {
        return;
    }
    
    dict[@"stay_time"] = [NSString stringWithFormat:@"%.0f",(duration*1000)];
    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
    TRACK_EVENT(@"picture_large_stay", dict);
}

//埋点
- (void)trackSavePictureWithIndex:(NSInteger)index {
    id<FHDetailPhotoHeaderModelProtocol> img = _images[index];
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
    if(!dict){
        dict = [NSMutableDictionary dictionary];
    }
    [dict removeObjectsForKeys:@[@"card_type",@"rank"]];
    dict[@"picture_id"] = img.url;
    dict[@"show_type"] = @"large";
    
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _enterTimestamp;
    if (duration <= 0) {
        return;
    }
    
    dict[@"stay_time"] = [NSString stringWithFormat:@"%.0f",(duration*1000)];
    TRACK_EVENT(@"picture_save", dict);
}


-(NSInteger)indexForIndexPath:(NSIndexPath *)indexPath
{
    if (_images.count <= 1) {
        return indexPath.item;
    }
    NSInteger index = indexPath.item - 1;
    if (index < 0) {
        //the last one
        index = _images.count - 1;
    }else if (index >= _images.count){
        //the first one
        index = 0;
    }
    return index;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_images.count <= 1) {
        return _images.count;
    }
    return [_images count]+2;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self indexForIndexPath:indexPath];
    [self trackPictureShowWithIndex:index];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHPhotoHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:K_CELLID forIndexPath:indexPath];
    
    NSInteger index = [self indexForIndexPath:indexPath];
    
    id<FHDetailPhotoHeaderModelProtocol> img = _images[index];

    NSURL *url = [NSURL URLWithString:img.url];
    [cell.imageView bd_setImageWithURL:url placeholder:self.placeHolder];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [self indexForIndexPath:indexPath];
    [self showImages:self.images currentIndex:index];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger curPage = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (_images.count > 1) {
        if (curPage == 0) {
            curPage = _images.count;
        }else if (curPage == _images.count + 1){
            curPage = 0;
        }
    }
    if (curPage == 0 ){
        curPage = 1;
    }
    self.infoLabel.text = [NSString stringWithFormat:@"%ld/%ld",curPage,self.images.count];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_images.count > 1) {
        int curPage = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
        NSIndexPath *indexPath = nil;
        if (curPage == 0) {
            //show last page
            indexPath = [NSIndexPath indexPathForItem:_images.count inSection:0];
        }else if (curPage == _images.count + 1) {
            //show first page
            indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        }
        if (indexPath) {
            [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    }
}

-(void)showImages:(NSArray<FHDetailPhotoHeaderModelProtocol>*)images currentIndex:(NSInteger)index
{
    if (images.count == 0) {
        return;
    }
    
    TTPhotoScrollViewController *vc = [[TTPhotoScrollViewController alloc] init];
    vc.dragToCloseDisabled = YES;
    vc.mode = PhotosScrollViewSupportBrowse;
    vc.startWithIndex = index;
    
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:images.count];
    for(id<FHDetailPhotoHeaderModelProtocol> imgModel in images)
    {
        NSMutableDictionary *dict = [[imgModel toDictionary] mutableCopy];
        //change url_list from string array to dict array
        NSMutableArray *dictUrlList = [[NSMutableArray alloc] initWithCapacity:imgModel.urlList.count];
        for (NSString * url in imgModel.urlList) {
            if ([url isKindOfClass:[NSString class]]) {
                [dictUrlList addObject:@{@"url":url}];
            }else{
                [dictUrlList addObject:url];
            }
        }
        // 兼容租房逻辑
        if (dictUrlList.count == 0) {
            NSString *url = dict[@"url"];
            if (url.length > 0) {
                [dictUrlList addObject:@{@"url":url}];
            }
        }
        dict[@"url_list"] = dictUrlList;
        
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        model.imageType = TTImageTypeLarge;
        if (model) {
            [models addObject:model];
        }
    }
    vc.imageInfosModels = models;
    
    UIImage *placeholder = [UIImage imageNamed:@"default_image"];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect frame = [self convertRect:self.bounds toView:window];
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:index+1];
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (NSInteger i = 0 ; i < index ; i++) {
        [frames addObject:[NSNull null]];
    }
    for (NSInteger i = 0 ; i < images.count; i++) {
        [placeholders addObject:placeholder];
    }
    
    NSValue *frameValue = [NSValue valueWithCGRect:frame];
    [frames addObject:frameValue];
    vc.placeholderSourceViewFrames = frames;
    vc.placeholders = placeholders;
    __weak typeof(self) weakSelf = self;
    vc.indexUpdatedBlock = ^(NSInteger lastIndex, NSInteger currentIndex) {
        if (currentIndex >= 0 && currentIndex < weakSelf.images.count) {
            weakSelf.currentIndex = currentIndex;
            weakSelf.isLarge = YES;
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:currentIndex + 1 inSection:0];
            [weakSelf.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    };
    
    [vc presentPhotoScrollViewWithDismissBlock:^{
        weakSelf.isLarge = NO;
        [weakSelf trackPictureShowWithIndex:weakSelf.currentIndex];
        [weakSelf trackPictureLargeStayWithIndex:weakSelf.currentIndex];
    }];
    
    vc.saveImageBlock = ^(NSInteger currentIndex) {
        [weakSelf trackSavePictureWithIndex:currentIndex];
    };
    
    self.isLarge = YES;
    [self trackPictureShowWithIndex:index];
    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
}

@end


@implementation FHPhotoHeaderCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:_imageView];
        
        self.contentView.clipsToBounds = YES;
    }
    return self;
}

@end


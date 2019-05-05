//
//  ExploreAirDownloadManager.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-19.
//
//

#import "ExploreAirDownloadManager.h"
#import "CategoryModel.h"
#import "ExploreFetchListManager.h"
#import "ExploreFetchListDefines.h"
#import "SSWebImagePrefetcher.h"
#import "NewsFetchArticleDetailManager.h"
#import "EssayData.h"
#import "ArticleCategoryManager.h"

//下载进度为近似值, 顺序为先下载列表，再下载列表内容，最后下载图片
#define kFetchedOrderedProgress 0.03                //下载完列表Model占总进度的3%
#define kFetchedOrderedDataCotentProgress   0.3     //下载列表内容占总进度的30%
#define kFetchedImagesProgress  0.67                //下载图片占总进度的67%


#pragma mark - CategoryModel + AirDownload
@implementation CategoryModel (AirDownload)

- (BOOL)isAirDownloadRequired {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:[self keyForAirDownloadNotRequired]];
}

- (void)setAirDownloadRequired:(BOOL)required {
    [[NSUserDefaults standardUserDefaults] setBool:!required forKey:[self keyForAirDownloadNotRequired]];
}

- (NSString *)keyForAirDownloadNotRequired {
    return [NSString stringWithFormat:@"Category_%@_AirDownloadNotRequired", self.categoryID];
}

@end

@interface ExploreAirDownloadManager()<NewsFetchArticleDetailManagerDelegate>
{
    BOOL _isFinish;
    
    NSUInteger _currentNeedDownloadArticleCount;        //当前下载文章的总数，改值和orderedDatas不一定相等
    NSUInteger _currentDownloadedArticleCount;          //当前已经下载的文章的数量
    
    NSUInteger _currentNeedDownloadImageCount;          //当前需要下载的图片的总数
    NSUInteger _currentDownloadedImageCount;            //当前已经下载的图片的总数
    
    
    NSUInteger _finishCategoryCount;            //已经下载完的频道的数量
    NSUInteger _currentCategoryFinishCount;     //当前正在下载的频道完成数量
}
@property(nonatomic, retain)CategoryModel * currentCategory;
@property(nonatomic, retain)NSArray * categorys;    //所有需要下载的频道
@property(nonatomic, retain)NSArray * orderedDatas; //当前正在下载的频道的OrderedData列表<有段子，有文章>
@property(nonatomic, copy)  ExploreAirDownloadProgressBlock progressBlock;
@property(nonatomic, retain)ExploreFetchListManager * fetchListManager;
@property(nonatomic, retain)SSWebImagePrefetcher * imagePrefetcher;
@property(nonatomic, retain)NewsFetchArticleDetailManager * fetchDetailManager;
@end

static ExploreAirDownloadManager * shareManager;
@implementation ExploreAirDownloadManager

+ (ExploreAirDownloadManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[ExploreAirDownloadManager alloc] init];
    });
    return shareManager;
}

- (void)dealloc
{
    [self cancel];
}

- (void)startAirDownloadForCategorys:(NSArray *)array finishBlock:(ExploreAirDownloadProgressBlock)progressBlock
{
    [self cancel];
    NSMutableArray * availableCategorys = [NSMutableArray arrayWithCapacity:10];
    for (CategoryModel * model in array) {
        BOOL available = !isEmptyString(model.categoryID);
        if ([model.categoryID isEqualToString:kNewsLocalCategoryID] && [model.name isEqualToString:KNewsLocalCategoryNoCityName]) {
            available = NO;
        }
        if (available) {
            [availableCategorys addObject:model];
        }
    }
    if ([availableCategorys count] == 0) {
        NSLog(@"air download at least have one category");
        [self notifyFinish];
        return ;
    }

    self.progressBlock = progressBlock;
    
    self.categorys = [NSArray arrayWithArray:availableCategorys];
    
    [self fetchCategoryAtIndex:0];
}

- (void)cancel
{
    [_fetchDetailManager cancelAllRequests];
    self.fetchDetailManager = nil;
    [_imagePrefetcher cancelPrefetching];
    self.imagePrefetcher = nil;
    [_fetchListManager cancelAllOperations];
    self.fetchListManager = nil;
    self.categorys = nil;
    self.orderedDatas = nil;
    self.currentCategory = nil;
    self.progressBlock = nil;
    _isFinish = NO;
    _finishCategoryCount = 0;
    _currentCategoryFinishCount = 0;
    _currentNeedDownloadArticleCount = 0;
    _currentDownloadedArticleCount = 0;
    _currentNeedDownloadImageCount = 0;
    _currentDownloadedImageCount = 0;
}

- (void)fetchCategoryAtIndex:(NSUInteger)index
{
    [_imagePrefetcher cancelPrefetching];
    if (index >= [_categorys count]) {
        [self notifyFinish];
    }
    else {
        self.currentCategory = [_categorys objectAtIndex:index];
        [self fetchListDataForCategory:_currentCategory];
    }
}

- (void)notifyFinish
{
    if (_progressBlock) {
        _progressBlock(YES, nil, 0, 0, 0, 0, 1, 1);
    }
}

- (void)notifyProgressFinish:(BOOL)finish currentPercent:(CGFloat)currentPercent
{
    if (_progressBlock) {
        CGFloat total = 0;
        if ([_categorys count] > 0) {
            total = (CGFloat)_currentCategoryFinishCount / [_categorys count];
        }
        _progressBlock(finish, _currentCategory, _currentDownloadedImageCount, _currentNeedDownloadImageCount, _currentDownloadedArticleCount, _currentNeedDownloadArticleCount, currentPercent, total);
    }
}

#pragma mark -- fetch list data

- (void)fetchListDataForCategory:(CategoryModel *)category
{
    if (!_fetchListManager) {
        self.fetchListManager = [[ExploreFetchListManager alloc] init];
    }
    [self notifyProgressFinish:NO currentPercent:0];
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:category.categoryID forKey:kExploreFetchListConditionListUnitIDKey];
    [condition setValue:@(ListDataOperationReloadFromTypeAirdownload) forKey:kExploreFetchListConditionReloadFromTypeKey];
    [_fetchListManager reuserAllOperations];
    [_fetchListManager startExecuteWithCondition:condition fromLocal:NO fromRemote:YES getMore:NO isDisplyView:NO listType:ExploreOrderedDataListTypeCategory finishBlock:^(NSArray *increaseItems, id operationContext, NSError *error) {
        
        if (error && [error.domain isEqualToString:kExploreFetchListErrorDomainKey] &&
            error.code == kExploreFetchListCategoryIDChangedCode) {
            return ;
        }
        NSMutableArray * orderedDatas = [NSMutableArray arrayWithCapacity:20];
        for (id obj in increaseItems) {
            if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[Article class]] ||
                    [((ExploreOrderedData *)obj).originalData isKindOfClass:[EssayData class]]) {
                    [orderedDatas addObject:obj];
                }
            }
        }
        if ([orderedDatas count] == 0) {
            [self notifyProgressFinish:NO currentPercent:1];
            self.orderedDatas = orderedDatas;
            _currentCategoryFinishCount ++;
            [self fetchCategoryAtIndex:_currentCategoryFinishCount];
        }
        else {
            [self notifyProgressFinish:NO currentPercent:kFetchedOrderedProgress];
            self.orderedDatas = orderedDatas;
            [self fetchNewsConentForOrderedDatas:_orderedDatas];
        }
    }];
}

#pragma mark -- fetch image

- (void)startFetchCurrentCategoryImage
{
    NSArray * imgModels = [self imageModelForOrderedDatas:_orderedDatas];
    _currentNeedDownloadImageCount = [imgModels count];
    _currentDownloadedImageCount = 0;
    if (imgModels.count > 0) {
         [self downloadImage:imgModels];
    } else {
        
        _currentDownloadedImageCount = 0;
        _currentCategoryFinishCount ++;
        [self fetchCategoryAtIndex:_currentCategoryFinishCount];
    }
}

- (void)downloadImage:(NSArray *)imageModels
{
    if (!_imagePrefetcher) {
        self.imagePrefetcher = [[SSWebImagePrefetcher alloc] init];
        _imagePrefetcher.maxConcurrentDownloads = 3;
        _imagePrefetcher.options = SDWebImageDownloaderLowPriority;
    }

    [_imagePrefetcher prefetchImageInfoModels:imageModels progressBlock:^(CGFloat totalPercent, BOOL isFinish, BOOL success, UIImage * image) {
        
        CGFloat percent = totalPercent * kFetchedImagesProgress + kFetchedOrderedDataCotentProgress + kFetchedOrderedProgress;
        _currentDownloadedImageCount ++;
        [self notifyProgressFinish:NO currentPercent:percent];
        if (isFinish) {
            _currentDownloadedImageCount = 0;
            _currentCategoryFinishCount ++;
            [self fetchCategoryAtIndex:_currentCategoryFinishCount];
        }
    }];
}

- (NSArray *)imageModelForOrderedDatas:(NSArray *)orderedDatas
{
    NSMutableArray * mutableImages = [NSMutableArray arrayWithCapacity:50];
    for (id obj in orderedDatas) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            ExploreOrderedData * orderedData = (ExploreOrderedData *)obj;
            if ([orderedData article]) {
                Article * article = [orderedData article];
                SSImageInfosModel * model =[article listLargeImageModel];
                if (model) {
                    [mutableImages addObject:model];
                }
                
                model = [article listMiddleImageModel];
                if (model) {
                    [mutableImages addObject:model];
                }
                NSArray * models = [article listGroupImgModels];
                if ([models count] > 0) {
                    [mutableImages addObjectsFromArray:models];
                }
                models = [article detailLargeImageModels];
                if ([models count] > 0) {
                    [mutableImages addObjectsFromArray:models];
                }
                models = [article detailThumbImageModels];
                if ([models count] > 0) {
                    [mutableImages addObjectsFromArray:models];
                }
            }
            else if ([orderedData essayData]) {
                EssayData * essayData = [orderedData essayData];
                SSImageInfosModel * model = [essayData largeImageModel];
                if (model) {
                    [mutableImages addObject:model];
                }
                model = [essayData middleImageModel];
                if (model) {
                    [mutableImages addObject:model];
                }
            }
        }
    }
    return mutableImages;
}

#pragma mark -- fetch news content

- (void)fetchNewsConentForOrderedDatas:(NSArray *)ordereds
{
    if (!_fetchDetailManager) {
        self.fetchDetailManager = [[NewsFetchArticleDetailManager alloc] init];
        _fetchDetailManager.threadPriority = 0.4f;
        _fetchDetailManager.delegate = self;
    }
    NSMutableArray * articles = [NSMutableArray arrayWithCapacity:20];
    for (id obj in ordereds) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[Article class]]) {
                if (![((Article *)((ExploreOrderedData *)obj).originalData) isContentFetched]) {
                    [articles addObject:((ExploreOrderedData *)obj).originalData];
                }
            }
        }
    }
    _currentNeedDownloadArticleCount = [articles count];
    _currentDownloadedArticleCount = 0;
    [self notifyProgressFinish:NO currentPercent:0];
    for (Article * article in articles) {
        [_fetchDetailManager fetchDetailForArticle:article withOperationPriority:NSOperationQueuePriorityLow notifyError:YES];
    }
    if ([articles count] == 0) {
        [self startFetchCurrentCategoryImage];
    }
}

#pragma mark -- NewsFetchArticleDetailManagerDelegate

- (void)fetchDetailManager:(NewsFetchArticleDetailManager *)manager finishWithResult:(NSDictionary *)result
{
    if (manager == _fetchDetailManager) {
        _currentDownloadedArticleCount ++;
        
        CGFloat percent = kFetchedOrderedProgress;
        if (_currentNeedDownloadArticleCount > 0) {
            CGFloat contentPercent = (CGFloat)_currentDownloadedArticleCount / (CGFloat)_currentNeedDownloadArticleCount;
            contentPercent = MIN(contentPercent, 1);
            contentPercent = contentPercent * kFetchedOrderedDataCotentProgress;
            percent = kFetchedOrderedProgress + contentPercent;
        }
        [self notifyProgressFinish:NO currentPercent:percent];
        
        if (_currentDownloadedArticleCount >= _currentNeedDownloadArticleCount) {//内容下载完成
            [self startFetchCurrentCategoryImage];
        }
    }
}


#pragma mark -- category select

- (NSArray *)allSubScribedCategories {
    NSArray *allCategories = [[ArticleCategoryManager sharedManager] subScribedCategories];
    __block NSMutableArray * result = [NSMutableArray arrayWithCapacity:allCategories.count];
    [allCategories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([self supportAirDownload:obj]) {
            [result addObject:obj];
        }
    }];
    return result;
}

- (NSArray *)airDownloadSubScribedCategories {
    __block NSMutableArray * result = [NSMutableArray array];
    NSArray * allSubScribedCategories = [self allSubScribedCategories];
    [allSubScribedCategories enumerateObjectsUsingBlock:^(CategoryModel *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isAirDownloadRequired] && [self supportAirDownload:obj]) {
            [result addObject:obj];
        }
    }];
    return result;
}

- (BOOL)supportAirDownload:(CategoryModel *)category {
    NSInteger type = category.listDataType.intValue;
    return ((type == ListDataTypeArticle) || (type == ListDataTypeEssay) || (type == ListDataTypeImage)) && ![category.categoryID isEqualToString:@"video"];
}

+ (NSString *) downloadFormatStringWithCategory:(CategoryModel *) category
                           downloadedImageCount:(NSUInteger)downloadedImgCount
                                totalImageCount:(NSUInteger) totalImageCount
                            downloadedItemCount:(NSUInteger) downloadedItemCount
                                 totalItemCount:(NSUInteger) totalItemCount {
    if (downloadedItemCount >= totalItemCount && totalItemCount > 0) {
        return [NSString stringWithFormat:@"下载图片 %lld/%lld",(long long)downloadedImgCount, (long long)totalImageCount];
    }
    return [NSString stringWithFormat:@"正在下载 %@ %lld/%lld",category.name, (long long)downloadedItemCount, (long long)totalItemCount];
}


@end

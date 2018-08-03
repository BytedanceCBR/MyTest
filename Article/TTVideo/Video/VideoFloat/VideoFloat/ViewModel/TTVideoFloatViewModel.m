
#import "TTVideoFloatViewModel.h"
#import "TTVideoFloatParameter.h"
#import "TTVideoFloatCellEntity.h"
#import "ExploreDetailManager.h"
#import "Article+TTADComputedProperties.h"

typedef void(^Finished)();

@interface TTVideoFloatViewModel()<ArticleInfoManagerDelegate>
@property (nonatomic, copy) Finished finishedBlock;
@end
@implementation TTVideoFloatViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _infoManager = [[ArticleInfoManager alloc] init];
        _infoManager.delegate = self;
    }
    return self;
}

- (void)loadTableWithData:(Article *)object completeBlock:(void (^)())complete
{
    if ([object isKindOfClass:[Article class]]) {
        [self addMainVideoEntityWithArticle:object];
        complete();
    }
}

- (void)loadDataWithParameters:(TTVideoFloatParameter *)parameter completeBlock:(void (^)())complete
{
    self.finishedBlock = complete;
    //调用info接口获取相关视频等
    [self.infoManager cancelAllRequest];
    
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    if (parameter.groupModel) {
        [condition setValue:parameter.groupModel forKey:kArticleInfoManagerConditionGroupModelKey];
    }
    if (parameter.comment_id) {
        [condition setValue:parameter.comment_id forKey:kArticleInfoManagerConditionTopCommentIDKey];
    }
    if (parameter.comment_id) {
        [condition setValue:parameter.videoSubjectID forKey:kArticleInfoRelatedVideoSubjectIDKey];
    }
    if (parameter.zzids) {
        [condition setValue:parameter.zzids forKey:@"zzids"];
    }
    if (parameter.cateoryID) {
        [condition setValue:parameter.cateoryID forKey:@"kArticleInfoManagerConditionCategoryIDKey"];
    }
    if (parameter.from) {
        [condition setValue:parameter.from forKey:@"from"];
    }
    if (parameter.flags) {
        [condition setValue:parameter.flags forKey:@"flags"];
    }
    if (parameter.article_page) {
        [condition setValue:parameter.article_page forKey:@"article_page"];
    }
    if (parameter.ad_id) {
        [condition setValue:parameter.ad_id forKey:@"article_page"];
    }
    [condition setValue:@"video_floating" forKey:@"video_scene"];
    
    WeakSelf;
    [self.infoManager startFetchArticleInfo:condition finishBlock:^(ArticleInfoManager *infoManager, NSError *error) {
        StrongSelf;
        self.error = error;
        [self.dataArr removeAllObjects];
        if (error) {
            self.netStatus = TTVideoFloatNetStatus_Failed;
            if (infoManager) {
                self.netData = infoManager;
                Article *article = self.detailModel.article;
                [self addMainVideoEntityWithArticle:article];
            }
        }
        else
        {
            if (infoManager) {
                self.netData = infoManager;
                Article *article = self.detailModel.article;
                [self addMainVideoEntityWithArticle:article];
                
                for (NSDictionary *dic in infoManager.relateVideoArticles) {
                    Article *article = [dic valueForKey:@"article"];
                    [self addRelatedVideoEntityWithArticle:article];
                }
            }
            self.netStatus = TTVideoFloatNetStatus_Success;
        }
        if (!isNull(self.finishedBlock)) {
            self.finishedBlock();
        }
    }];
}

- (void)addMainVideoEntityWithArticle:(Article *)article
{
    TTVideoFloatCellEntity *entity = [[TTVideoFloatCellEntity alloc] init];
    entity.article = article;
    entity.detailModel = self.detailModel;
    [self.dataArr addObject:entity];
}

- (void)addRelatedVideoEntityWithArticle:(Article *)article
{
    if (!article.isDeleted && ![article hasVideoSubjectID] && ![article hasVideoBookID] && [article hasVideoID] && article.adIDStr.length <= 0) {
        ArticleRelatedVideoType type = [[article.relatedVideoExtraInfo valueForKey:kArticleInfoRelatedVideoCardTypeKey] unsignedIntegerValue];
        if (type == ArticleRelatedVideoTypeArticle) {
            TTVideoFloatCellEntity *entity = [[TTVideoFloatCellEntity alloc] init];
            entity.article = article;
            entity.detailModel = [[TTDetailModel alloc] init];
            [self.dataArr addObject:entity];
        }
    }
}


- (void)articleInfoManager:(ArticleInfoManager *)manager getStatus:(NSDictionary *)dict
{
    [[self.detailModel sharedDetailManager] updateArticleByData:dict];
}

@end

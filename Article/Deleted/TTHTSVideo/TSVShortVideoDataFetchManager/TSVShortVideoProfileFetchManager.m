//
//  TSVShortVideoProfileFetchManager.m
//  Article
//
//  Created by 王双华 on 2017/8/30.
//
//

#import "TSVShortVideoProfileFetchManager.h"
#import "ArticleURLSetting.h"
#import "TTNetworkManager/TTNetworkManager.h"
#import "HTSVideoPlayJSONResponseSerializer.h"
#import "TSVMonitorManager.h"

@interface TSVShortVideoProfileFetchManager ()

@property (nonatomic, copy, readwrite) NSString *userID;
@property (nonatomic, copy, readwrite) NSArray<TTShortVideoModel *> *shortVideoArray;

@end

@implementation TSVShortVideoProfileFetchManager

@synthesize dataDidChangeBlock;

- (instancetype)initWithUserID:(NSString *)userID;
{
    self = [super init];
    if (self){
        _userID = userID;
        self.hasMoreToLoad = YES;
        self.shouldShowNoMoreVideoToast = YES;
    }
    return self;
}

- (NSUInteger)numberOfShortVideoItems
{
    return [self.shortVideoArray count] - self.offsetIndex;
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index
{
    return [self itemAtIndex:index replaced:YES];
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index replaced:(BOOL)replaced
{
    NSParameterAssert(index < [self.shortVideoArray count]);
    
    if (replaced && self.replacedModel && index == self.replacedIndex) {
        return self.replacedModel;
    } else if (index + self.offsetIndex < [self.shortVideoArray count]) {
        TTShortVideoModel *model = [self.shortVideoArray objectAtIndex:index + self.offsetIndex];
        return model;
    }
    return nil;
}

- (void)requestDataAutomatically:(BOOL)isAutomatically
                     finishBlock:(TTFetchListFinishBlock)finishBlock
{
    if ([self numberOfShortVideoItems] == 0 && !isEmptyString(self.userID)) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:self.userID forKey:@"user_id"];
        [self requestDataWithParams:params finishBlock:finishBlock];
    } else if ([self numberOfShortVideoItems] > 0) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        TTShortVideoModel *model = [self.shortVideoArray lastObject];
        [params setValue:model.groupID forKey:@"group_id"];
        [params setValue:@(model.createTime) forKey:@"start_cursor"];
        [params setValue:model.author.userID forKey:@"user_id"];
        [self requestDataWithParams:params finishBlock:finishBlock];
    } else {
        self.hasMoreToLoad = NO;
        self.isLoadingRequest = NO;
        if (finishBlock) {
            finishBlock(0, nil);
        }
    }
}

- (void)requestDataWithParams:(NSDictionary *)params finishBlock:(TTFetchListFinishBlock)finishBlock
{
    self.isLoadingRequest = YES;
    NSString *urlStr = [ArticleURLSetting shortVideoLoadMoreURL];
    
    NSString *monitorIdentifier = [[TSVMonitorManager sharedManager] startMonitorNetworkService:TSVMonitorNetworkServiceProfile key:nil];
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlStr
                                                     params:params
                                                     method:@"POST"
                                           needCommonParams:YES
                                          requestSerializer:nil
                                         responseSerializer:[HTSVideoPlayJSONResponseSerializer class]
                                                 autoResume:YES
                                                   callback:^(NSError *error, id jsonObj) {
                                                       StrongSelf;
                                                       
                                                       [[TSVMonitorManager sharedManager] endMonitorNetworkService:TSVMonitorNetworkServiceProfile identifier:monitorIdentifier error:error];
                                                       
                                                       if (!self) {
                                                           finishBlock(0, error);
                                                           return;
                                                       }
                                                       self.isLoadingRequest = NO;
                                                       if (error || jsonObj == nil || jsonObj[@"data"] == nil) {
                                                           if (finishBlock) {
                                                               finishBlock(0, error);
                                                           }
                                                           return;
                                                       }
                                                       self.hasMoreToLoad = [jsonObj tt_boolValueForKey:@"has_more"];
                                                       NSArray *data = [jsonObj tt_arrayValueForKey:@"data"];
                                                       NSError *mappingError = nil;
                                                       NSArray *models = [TTShortVideoModel arrayOfModelsFromDictionaries:data error:&mappingError];
                                                       if ([models count] > 0) {
                                                           for (TTShortVideoModel *model in models) {
                                                               model.enterFrom = @"click_pgc";
                                                               model.categoryName = @"profile";
                                                               model.listEntrance = @"draw_profile";
                                                           }
                                                           NSMutableArray *mutItems = [NSMutableArray arrayWithArray:self.shortVideoArray];
                                                           [mutItems addObjectsFromArray:models];
                                                           self.shortVideoArray = mutItems;
                                                       }
                                                       if (finishBlock) {
                                                           finishBlock(models.count, error);
                                                       }
                                                   }];
}

@end


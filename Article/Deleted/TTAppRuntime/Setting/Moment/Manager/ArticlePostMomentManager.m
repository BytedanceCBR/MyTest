//
//  ArticlePostMomentManager.m
//  Article
//
//  Created by Huaqing Luo on 13/1/15.
//
//

#import "ArticlePostMomentManager.h"
#import "TTFeedbackUploadImageManager.h"
#import "ArticleMomentModel.h"
#import "TTNetworkManager.h"
#import "ALAssetsLibrary+TTImagePicker.h"

@interface ArticlePostMomentManager () <TTFeedbackUploadImageManagerDelegate>
{
    BOOL _isPosting;
    BOOL _hasCancelled;
}

@property(nonatomic, copy) NSString * content;
@property(nonatomic, assign) long long forumID;
@property(nonatomic, assign) PostMomentSourceType fromSource;
@property(nonatomic, assign) NSInteger needForward;
@property(nonatomic, strong) NSMutableArray * imageUris;

@property(nonatomic, strong) NSMutableArray * imageKeys;
@property(nonatomic, strong) NSMutableDictionary * keysImageUris;

@property(nonatomic, strong) TTFeedbackUploadImageManager * uploadImageManager;
@property(nonatomic, strong) TTHttpTask *httpTask;
@end

@implementation ArticlePostMomentManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _isPosting = NO;
        _hasCancelled = NO;
        self.imageKeys = [NSMutableArray arrayWithCapacity:DefaultImagesSelectionLimit];
        self.keysImageUris = [NSMutableDictionary dictionary];
        self.imageUris = [NSMutableArray arrayWithCapacity:DefaultImagesSelectionLimit];
        self.uploadImageManager = [[TTFeedbackUploadImageManager alloc] init];
        _uploadImageManager.delegate = self;
    }
    return self;
}

- (BOOL)isPosting
{
    return _isPosting;
}

- (void)PostMoment
{
    NSMutableString * strImageUris = [[NSMutableString alloc] init];
    for (id imageUri in _imageUris)
    {
        if ([imageUri isKindOfClass:[NSString class]])
        {
            [strImageUris appendString:(NSString *)imageUri];
            [strImageUris appendString:@","];
        }
    }
    if ([strImageUris length] > 0) {
        [strImageUris deleteCharactersInRange:NSMakeRange([strImageUris length] - 1, 1)];
    }
    
    NSDictionary * postParameter = @{@"content" : _content,
                                     @"forum_id" : @(_forumID),
                                     @"image_uris" : strImageUris,
                                     @"source" : @(_fromSource),
                                     @"forward" : @(_needForward)};
    
    WeakSelf;
    self.httpTask = [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting postMomentURLString] params:postParameter method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        [self result:jsonObj error:error userInfo:nil];
    }];
}

- (void)PostMomentWithContent:(NSString *)content ForumID:(long long)forumID AssetsImages:(NSArray *)assetsImages FromSource:(PostMomentSourceType)fromSource NeedForward:(NSInteger)needForward
{
    if (_isPosting) {
        return;
    }
    
    _isPosting = YES;
    _hasCancelled = NO;
    self.content = content;
    _forumID = forumID;
    _fromSource = fromSource;
    _needForward = needForward;
    
    [_imageKeys removeAllObjects];
    [_imageUris removeAllObjects];
    NSMutableArray * needUploadImages = [NSMutableArray arrayWithCapacity:DefaultImagesSelectionLimit];
    NSMutableArray * needUploadImageKeys = [NSMutableArray arrayWithCapacity:DefaultImagesSelectionLimit];
    NSMutableDictionary * needUploadImageKeysImages = [NSMutableDictionary dictionaryWithCapacity:DefaultImagesSelectionLimit];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (id assetImage in assetsImages)
        {
            UIImage * image = nil;
            if ([assetImage isKindOfClass:[UIImage class]]) {
                image = assetImage;
            } else if ([assetImage isKindOfClass:[ALAsset class]]) {
                image = [ALAssetsLibrary tt_getBigImageFromAsset:assetImage];
            }
            
            if (image)
            {
                NSString * imageKey = [TTFeedbackUploadImageManager imageUniqueKey:image];
                [_imageKeys addObject:imageKey];
                
                NSString * imageUri = [_keysImageUris objectForKey:imageKey];
                if (!isEmptyString(imageUri))
                {
                    [_imageUris addObject:imageUri];
                }
                else
                {
                    [needUploadImageKeysImages setObject:image forKey:imageKey];
                }
            }
        }
        
        for (NSString * imageKey in [needUploadImageKeysImages allKeys])
        {
            [needUploadImageKeys addObject:imageKey];
            [needUploadImages addObject:[needUploadImageKeysImages objectForKey:imageKey]];
        }
        
        if (needUploadImages.count == 0)
        {
            [self PostMoment];
        }
        else
        {
            if (_uploadImageManager.delegate == nil) {
                _uploadImageManager.delegate = self;
            }
            
            [_uploadImageManager uploadImages:needUploadImages uniqueKey:needUploadImageKeys withMaxAspectSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) withMaxDataSize:(1 * 1024.f)];
        }
    });
}

- (void)cancelAllOperations
{
    _hasCancelled = YES;
    _isPosting = NO;
    [_uploadImageManager cancelAllOperation];
    _uploadImageManager.delegate = nil;
    [_httpTask cancel];
}

- (void)result:(NSDictionary *)result error:(NSError*)tError userInfo:(id)userInfo
{
    if (_hasCancelled) {
        return;
    }
    
    if (!tError)
    {
        id momentItemDict = result;
        if ([momentItemDict isKindOfClass:[NSDictionary class]])
        {
            NSDictionary * momentItemData = [(NSDictionary *)momentItemDict objectForKey:@"data"];
            ArticleMomentModel * momentItem = [[ArticleMomentModel alloc] initWithDictionary:momentItemData];
            
            NSMutableDictionary * notificationUerInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            [notificationUerInfo setValue:momentItem forKey:@"item"];
            if (_fromSource == PostMomentSourceFromForum)
            {
                // Post notificaiton to insert the result to the forum list
                [notificationUerInfo setValue:@(_forumID) forKey:@"forum_id"];
                NSNotification * notification = [[NSNotification alloc] initWithName:kPostForumItemDoneNotification object:nil userInfo:notificationUerInfo];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
            
            if (_fromSource == PostMomentSourceFromMoment || (_fromSource == PostMomentSourceFromForum && _needForward == 1))
            {
                // Post notificaiton to insert the result to the moment list
                NSNotification * notification = [[NSNotification alloc] initWithName:kPostMomentItemDoneNotification object:nil userInfo:notificationUerInfo];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        }
    }
    
    _isPosting = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(postMomentManager:postFinishWithError:)])
    {
        [self.delegate postMomentManager:self postFinishWithError:tError];
    }
}

#pragma mark -- TTFeedbackUploadImageManagerDelegate

- (void)uploadImageManager:(TTFeedbackUploadImageManager *)manager uploadFinishForUniqueKeys:(NSArray *)finishKeyStrs results:(NSArray*)dicts  error:(NSError *)error
{
    if (_hasCancelled) {
        return;
    }
  
    if (!error) {
        
        for (NSUInteger index = 0; index < finishKeyStrs.count; ++index)
        {
            NSString * keyStr = [finishKeyStrs objectAtIndex:index];
            NSDictionary * dict = [dicts objectAtIndex:index];
            id result = [dict objectForKey:@"data"];
            if (!isEmptyString(keyStr) && [result isKindOfClass:[NSDictionary class]])
            {
            
                id imageUri = [(NSDictionary *)result objectForKey:@"web_uri"];
                if ([imageUri isKindOfClass:[NSString class]])
                {
                    [self.keysImageUris setValue:imageUri forKey:keyStr];
                }
                
            }
        }
        [_imageUris removeAllObjects];
        for (NSString * keyStr in _imageKeys)
        {
            NSString * uri = [_keysImageUris objectForKey:keyStr];
            if (uri) {
                [_imageUris addObject:uri];
            }
        }
        
        [self PostMoment];
    }
    else
    {
        _isPosting = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(postMomentManager:postFinishWithError:)])
        {
            [_delegate postMomentManager:self postFinishWithError:error];
        }
    }

}

- (void)uploadImageManager:(TTFeedbackUploadImageManager *)manager uploadImagesProgress:(NSNumber *)progress
{
    if (_delegate && [_delegate respondsToSelector:@selector(postMomentManager:uploadImagesProgress:)])
    {
        [_delegate postMomentManager:self uploadImagesProgress:progress];
    }
}

@end

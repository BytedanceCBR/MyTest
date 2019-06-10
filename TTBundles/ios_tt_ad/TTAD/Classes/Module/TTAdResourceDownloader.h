//
//  TTAdResourceDownloader.h
//  Article
//
//  Created by carl on 2017/5/28.
//
//

#import <Foundation/Foundation.h>
#import "TTAdResourceModel.h"
#import "TTAdResourceDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTAdResourceDownloader : NSObject
+ (nonnull instancetype)sharedManager;
- (void)preloadResource:(NSArray<TTAdResourceModel *> *_Nullable)models;
- (void)preloadResource:(NSArray<TTAdResourceModel *> *_Nullable)models timeout:(NSTimeInterval)timeout;
@end


@interface TTAdResourceOperation : NSOperation
- (nonnull instancetype)initWith:(TTAdResourceModel *_Nonnull)model;
@property (nonatomic, copy) TTAdDownloadCompletedBlock _Nullable completedBlock;
@end

@interface TTAdResourceImageOperation : TTAdResourceOperation
@end

@interface TTAdResourceVideoOperation : TTAdResourceOperation
@end

@interface TTAdResourceFileOperation : TTAdResourceOperation
@end

@interface TTAdResourceOperation (TTAdResourcrOperationFactory)
+ (instancetype _Nullable )opertationWithModel:(TTAdResourceModel *_Nullable)model;
@end

NS_ASSUME_NONNULL_END

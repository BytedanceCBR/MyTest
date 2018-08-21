//
//  TTForumVideoUploaderManager.h
//  Article
//
//  Created by ranny_90 on 2017/7/21.
//
//

#import <Foundation/Foundation.h>
#import "TTVideoUploadClient.h"

@interface TTForumVideoUploaderSDKManager : NSObject

+ (instancetype)sharedUploader;

- (void)uploadVideoWithTaskID:(NSString *)taskID
                   videoFilePath:(NSString *)videoFilePath
         coverImageTimestamp:(NSTimeInterval)coverImageTimestamp
        clientDelegate:(id<TTVideoUploadClientProtocol>)delegate;

- (TTVideoUploadClient *)fetchTaskWithTaskID:(NSString *)taskID;

- (void)cacheClient:(TTVideoUploadClient *)client withTaskID:(NSString *)taskID;

- (void)cancelVideoUploadWithTaskID:(NSString *)taskID;

- (void)cancelAndRemoveUploadWithTaskID:(NSString *)taskID;

- (void)removeClientWithTaskId:(NSString *)taskID;


@end

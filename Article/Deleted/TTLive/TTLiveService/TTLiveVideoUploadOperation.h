//
//  TTLiveVideoUploadOperation.h
//  Article
//
//  Created by matrixzk on 9/22/16.
//
//

#import <Foundation/Foundation.h>

typedef void(^TTLiveVideoUploadProgressBlock)(CGFloat progress);
typedef void(^TTLiveVideoUploadCompletedBlock)(NSString *videoId, NSError *error);

@interface TTLiveVideoUploadOperation : NSOperation

- (instancetype)initWithVideoPath:(NSString *)path
                         progress:(TTLiveVideoUploadProgressBlock)progress
                        completed:(TTLiveVideoUploadCompletedBlock)completed;

@end

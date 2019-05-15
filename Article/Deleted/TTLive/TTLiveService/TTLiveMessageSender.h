//
//  TTLiveMessageSender.h
//  Article
//
//  Created by matrixzk on 9/22/16.
//
//

#import <Foundation/Foundation.h>

@class TTLiveMessage;


@interface TTLiveMessageSender : NSObject

@property (nonatomic, copy) NSDictionary *eventTrackParams;

- (void)sendMessage:(TTLiveMessage *)message;
- (void)cancelVideoUpload;

@end

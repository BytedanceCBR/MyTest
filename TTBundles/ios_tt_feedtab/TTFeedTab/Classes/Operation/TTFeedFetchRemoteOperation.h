//
//  TTFeedFetchRemoteOperation.h
//  Article
//
//  Created by fengyadong on 16/11/14.
//
//

#import "TTFeedGeneralOperation.h"

@interface TTFeedFetchRemoteOperation : TTFeedGeneralOperation

@property (nonatomic, strong, readonly) NSNumber *rankKey;
@property (nonatomic, strong, readonly) NSDictionary *remoteDict;
@property (nonatomic, strong, readonly) NSArray *flattenList;
@property (nonatomic, strong, readonly) NSError *error;

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel;

@end

//
//  TTFeedInsertDataOperation.h
//  Article
//
//  Created by fengyadong on 16/11/14.
//
//

#import "TTFeedGeneralOperation.h"

@interface TTFeedInsertDataOperation : TTFeedGeneralOperation

@property (nonatomic, copy, readonly)   NSArray *ignoreIDs;
@property (nonatomic, copy, readonly)   NSArray *increaseItems;
@property (nonatomic, assign, readonly) NSUInteger newNumber;

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel;

@end

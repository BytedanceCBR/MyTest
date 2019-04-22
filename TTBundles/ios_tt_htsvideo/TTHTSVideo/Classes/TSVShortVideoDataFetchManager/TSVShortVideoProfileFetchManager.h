//
//  TSVShortVideoProfileFetchManager.h
//  Article
//
//  Created by 王双华 on 2017/8/30.
//
//

#import <Foundation/Foundation.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"
#import "TSVDataFetchManager.h"

@class TTShortVideoModel;

@interface TSVShortVideoProfileFetchManager : TSVDataFetchManager<TSVShortVideoDataFetchManagerProtocol>

@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSArray<TTShortVideoModel *> *shortVideoArray;
@property (nonatomic, assign) NSInteger offsetIndex;

- (instancetype)initWithUserID:(NSString *)userID;

@end

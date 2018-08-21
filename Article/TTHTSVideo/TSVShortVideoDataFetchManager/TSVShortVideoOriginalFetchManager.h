//
//  TSVShortVideoOriginalFetchManager.h
//  Article
//
//  Created by 王双华 on 2017/6/20.
//
//

#import <Foundation/Foundation.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"
#import "TSVDataFetchManager.h"

@interface TSVShortVideoOriginalFetchManager : TSVDataFetchManager<TSVShortVideoDataFetchManagerProtocol>

- (instancetype)initWithShortVideoOriginalData:(TSVShortVideoOriginalData *)shortVideoOriginalData logPb:(NSDictionary *)logPb;

@end

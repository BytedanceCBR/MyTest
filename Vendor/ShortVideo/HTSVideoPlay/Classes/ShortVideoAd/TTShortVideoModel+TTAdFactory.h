//
//  TTShortVideoModel+TTAdFactory.h
//  HTSVideoPlay
//
//  Created by carl on 2017/12/8.
//

#import "TTAdShortVideoModel.h"
#import "TTShortVideoModel.h"


@interface TTShortVideoModel (TTAdFactory)

- (BOOL)isAd;

@property (nonatomic, strong) TTAdShortVideoModel *rawAd;

@end

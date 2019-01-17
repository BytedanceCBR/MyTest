//
//  FHClientModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/26.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHClientModel : JSONModel

@end

@interface FHClientHomeParamsModel : JSONModel

@property (nonatomic, strong , nullable) NSString *originFrom;
@property (nonatomic, strong , nullable) NSString *originSearchId;

@end

@interface FHClientTraceModel : JSONModel

@property (nonatomic, strong , nullable) NSString *originFrom;
@property (nonatomic, strong , nullable) NSString *originSearchId;

@end

NS_ASSUME_NONNULL_END

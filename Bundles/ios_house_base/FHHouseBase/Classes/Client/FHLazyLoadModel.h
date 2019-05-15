//
//  FHLazyLoadModel.h
//  AKCommentPlugin
//
//  Created by leo on 2019/4/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHLazyLoadModel : NSObject
@property (nonatomic, strong) id ref;
@property (nonatomic, copy) NSString* className;
@property (nonatomic, strong) NSArray* data;
+(instancetype)proxyWithObj:(id)object;

+ (instancetype)proxyWithClass:(NSString*)className withData:(NSDictionary*)data;
@end

NS_ASSUME_NONNULL_END

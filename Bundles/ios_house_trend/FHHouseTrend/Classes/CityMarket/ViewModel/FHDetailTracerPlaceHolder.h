//
//  FHDetailTracerPlaceHolder.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailTracerPlaceHolder : NSObject
@property (nonatomic, strong) NSSet<NSIndexPath*>* traceCache;
@property (nonatomic, assign) NSUInteger sectionOffset;
-(NSUInteger)sectionWithOffset:(NSIndexPath*)indexPath;
-(NSIndexPath*)indexPathWithOffset:(NSIndexPath*)indexPath;
@end

NS_ASSUME_NONNULL_END

//
//
//  Created by 01 on 9/1/16.
//
//

#import <Foundation/Foundation.h>

@interface AWEReportViewController : NSObject

@property(nonatomic, copy, nonnull) NSString *reportType;

- (void)performWithReportOptions:(nullable NSArray<NSDictionary *> *)reportOptions completion:(nullable void (^)(NSDictionary *_Nonnull parameters))completion;

@end

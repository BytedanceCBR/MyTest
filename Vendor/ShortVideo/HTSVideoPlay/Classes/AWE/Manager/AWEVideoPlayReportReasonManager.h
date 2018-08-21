//
//  AWEVideoPlayReportReasonManager.h
//  Pods
//
//  Created by 01 on 17/5/7.
//
//
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ReportType)
{
    ReportTypeVideo = 1,
    ReportTypeComment,
    ReportTypeProfile,
    ReportTypeLive
};


typedef void(^AWEReportReasonManagerCompletionBlock)(NSArray<NSDictionary *> *reportArray,NSError *error);

@interface AWEVideoPlayReportReasonManager : NSObject

- (void)requestReportReasonWithReportTypeString:(NSString *)typeString withComplection:(AWEReportReasonManagerCompletionBlock)block;

- (void)requestReportWithReportParams:(NSDictionary *)reportParams completion:(void (^)(NSError *error, id jsonObj))completion;

@end

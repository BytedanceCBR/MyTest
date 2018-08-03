//
//  TSVLogoAction.h
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 13/12/2017.
//

#import <Foundation/Foundation.h>

@class TTShortVideoModel, TSVVideoDetailPromptManager;

@interface TSVLogoAction : NSObject

+ (instancetype)sharedInstance;
- (void)clickLogoWithModel:(TTShortVideoModel *)model
   commonTrackingParameter:(NSDictionary *)commonTrackingParameter
       detailPromptManager:(TSVVideoDetailPromptManager *)detailPromptManager
                  position:(NSString *)position;

@end

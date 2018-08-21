//
//  TTVReportAction.h
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVMoreAction.h"

@interface TTVReportActionEntity : TTVMoreActionEntity
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *videoSource;
@property (nonatomic, strong) NSNumber *adID;
@end

@interface TTVReportAction : TTVMoreAction
@property (nonatomic ,strong)TTVReportActionEntity *entity;
@property (nonatomic, copy) void (^didTrackReportSubmiteActionBlock)(NSDictionary *reportReason);
- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity;
- (void)execute:(TTActivityType)type;
@end

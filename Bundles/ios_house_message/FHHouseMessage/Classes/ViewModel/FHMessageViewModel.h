//
//  FHMessageViewModel.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import <Foundation/Foundation.h>
#import "FHMessageBridgeProtocol.h"
#import "FHMessageTopView.h"

NS_ASSUME_NONNULL_BEGIN

@class FHMessageViewController;
@class IMConversation;
@interface FHMessageViewModel : NSObject

@property(nonatomic, strong) NSMutableArray *dataList;

- (instancetype)initWithTableView:(UITableView *)tableView topView:(FHMessageTopView *)topView controller:(FHMessageViewController *)viewController;

- (void)requestData;

- (void)addStayCategoryLog:(NSTimeInterval)stayTime;

- (id<FHMessageBridgeProtocol>)messageBridgeInstance;

-(void)deleteConversation:(IMConversation*)conv;

- (void)setPageType:(NSString *)pageType;

- (void)setEnterFrom:(NSString *)enterFrom;

- (void)refreshConversationList;

- (void)refreshDataWithType:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END

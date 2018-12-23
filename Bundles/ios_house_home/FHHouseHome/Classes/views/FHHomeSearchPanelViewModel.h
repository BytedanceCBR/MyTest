//
//  FHHomeSearchPanelViewModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import <Foundation/Foundation.h>
#import "FHHomeSearchPanelView.h"
#import "FHHomeRollModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeSearchPanelViewModel : NSObject

- (instancetype)initWithSearchPanel:(FHHomeSearchPanelView *)panel;

-(void)requestPanelRollScreen:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeRollModel *model, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END

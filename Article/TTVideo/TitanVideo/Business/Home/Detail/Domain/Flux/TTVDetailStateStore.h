//
//  TTVDetailStateStore.h
//  Article
//
//  Created by panxiang on 2017/7/7.
//
//

#import "TTVFluxStore.h"
#import "TTVDetailStateModel.h"
#import "TTVFluxAction.h"
#import "TTVDetailControllerState.h"

@interface TTVDetailStateAction : TTVFluxAction

@end

@interface TTVDetailStateStore : TTVFluxStore
@property (nonatomic, strong) TTVDetailStateModel *state;
- (void)sendAction:(TTVDetailEventType)event payload:(id)payload;
@end

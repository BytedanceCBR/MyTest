//
//  TTVDetailContext.h
//  Article
//
//  Created by panxiang on 2017/7/7.
//
//
#import "TTVDetailStateStore.h"
#import "TTVDetailStateModel.h"

@protocol TTVDetailContext <NSObject>
@property (nonatomic, strong) TTVDetailStateStore *detailStateStore;
@optional
- (void)actionChangeCallbackWithAction:(TTVDetailStateAction *)action state:(TTVDetailStateModel *)state;
@end

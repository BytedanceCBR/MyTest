//
//  TTVideoFloatViewController+Action.h
//  Article
//
//  Created by panxiang on 16/7/14.
//
//

#import "TTVideoFloatViewController.h"
#import "TTBaseCellAction.h"
#import "ExploreItemActionManager.h"

@interface TTVideoFloatViewController (Action)

@property (nonatomic, copy, nullable) NSDictionary        *contentInfo;
@property (nonatomic, strong, nullable) ExploreItemActionManager *itemActionManager;

- (void)doAction:(TTVideoFloatCellAction)action withCellEntity:(TTVideoFloatCellEntity * _Nullable)cellEntity callbackBlock:(TTCellActionCallback _Nullable)callbackBlock;
- (void)actionInit;
@end

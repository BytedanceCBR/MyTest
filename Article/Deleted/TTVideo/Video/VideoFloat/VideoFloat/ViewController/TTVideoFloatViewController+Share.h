//
//  TTVideoFloatViewController+Share.h
//  Article
//
//  Created by panxiang on 16/7/14.
//
//

#import "TTVideoFloatViewController.h"
#import "TTVideoFloatCellEntity.h"
#import "TTActivityShareManager.h"
#import "SSActivityView.h"

@interface TTVideoFloatViewController (Share)<SSActivityViewDelegate>
- (void)shareActionWithCellEntity:(TTVideoFloatCellEntity *)cellEntity;
@end

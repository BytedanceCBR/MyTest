//
//  ConditionSelectPanelDelegate.h
//  FHHouseBase
//
//  Created by leo on 2018/11/17.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ConditionSelectPanelDelegate <NSObject>

-(void)viewWillDisplay;

-(void)viewDidDisplay;

-(void)viewWillDismiss;

-(void)viewDidDismiss;

@end

NS_ASSUME_NONNULL_END

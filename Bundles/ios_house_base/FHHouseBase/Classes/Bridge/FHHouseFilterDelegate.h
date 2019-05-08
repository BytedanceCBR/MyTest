//
//  FHHouseFilterDelegate.h
//  Pods
//
//  Created by 谷春晖 on 2018/11/18.
//

#ifndef FHHouseFilterDelegate_h
#define FHHouseFilterDelegate_h

@protocol FHHouseFilterDelegate <NSObject>

@required

-(void)onConditionChanged:(NSString *)condition;

@optional

-(void)onConditionPanelWillDisplay;

-(void)onConditionPanelWillDisappear;

@end

#endif /* FHHouseFilterDelegate_h */

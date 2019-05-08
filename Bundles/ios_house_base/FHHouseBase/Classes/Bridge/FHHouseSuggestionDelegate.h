//
//  FHHouseSuggestionDelegate.h
//  Pods
//
//  Created by 谷春晖 on 2018/11/25.
//

#ifndef FHHouseSuggestionDelegate_h
#define FHHouseSuggestionDelegate_h


@protocol FHHouseSuggestionDelegate <NSObject>

@required

-(void)resetCondition;

-(void)backAction:(UIViewController *)controller;

@optional
-(void)suggestionSelected:(TTRouteObject *)routeObject;

@end

#endif /* FHHouseSuggestionDelegate_h */

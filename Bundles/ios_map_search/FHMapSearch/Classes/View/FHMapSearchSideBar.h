//
//  FHMapSearchSideBar.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/9.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , FHMapSearchSideBarItemType) {
    FHMapSearchSideBarItemTypeSubway = 0 , //地铁
    FHMapSearchSideBarItemTypeCircle ,     //画圈
    FHMapSearchSideBarItemTypeFilter ,     //筛选
    FHMapSearchSideBarItemTypeList,        //列表
};

NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchSideBar : UIView

@property(nonatomic , copy) void (^chooseTypeBlock)(FHMapSearchSideBarItemType type);

-(void)showWithTypes:(NSArray *)types;

@end

NS_ASSUME_NONNULL_END

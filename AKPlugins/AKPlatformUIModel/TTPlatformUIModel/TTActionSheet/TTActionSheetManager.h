//
//  TTActionSheetManager.h
//  Article
//
//  Created by zhaoqin on 8/29/16.
//
//

#import <Foundation/Foundation.h>

@class TTActionSheetModel;

@interface TTActionSheetManager : NSObject
@property (nonatomic, strong) TTActionSheetModel * _Nullable dislikeModel;
@property (nonatomic, strong) TTActionSheetModel * _Nullable reportModel;
@property (nonatomic, strong) NSString * _Nullable criticismInput;
@property (nonatomic, strong) NSString * _Nullable source; //埋点统计
@property (nonatomic, strong) NSNumber * _Nullable adID;

- (void)addActionSheetMode:(nonnull TTActionSheetModel *)model;

- (void)resetManager;

@end

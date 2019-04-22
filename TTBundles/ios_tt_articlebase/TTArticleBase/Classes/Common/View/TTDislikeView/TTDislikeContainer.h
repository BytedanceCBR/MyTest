//
//  TTDislikeContainer.h
//  Article
//
//  Created by zhaoqin on 01/03/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTDislikeConst.h"

@class TTDetailModel;

@interface TTDislikeContainer : NSObject

@property (nonatomic, assign) TTDislikeType type;
@property (nonatomic, strong) TTDetailModel * _Nonnull detailModel;

- (void)insertDislikeOptions:(NSArray * _Nullable)dislikeOptions reportOptions:(NSArray * _Nullable)reportOptions;

- (void)showDislikeViewAfterComplete:(void (^ _Nullable)(NSArray * _Nullable dislikeOptions, NSArray * _Nullable reportOptions, NSDictionary * _Nullable extraDict))complete;

@end

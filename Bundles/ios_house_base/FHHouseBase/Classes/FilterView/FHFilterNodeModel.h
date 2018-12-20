//
//  FHFilterNodeModel.h
//  FHHouseBase
//
//  Created by leo on 2018/11/17.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFilterNodeModel : NSObject
@property (nonatomic, copy) NSString* label;
@property (nonatomic, copy) NSString* externalConfig;
@property (nonatomic, copy) NSString* value;
@property (nonatomic, assign) BOOL isSupportMulti;
@property (nonatomic, copy) NSString* key;
@property (nonatomic, assign) NSInteger isEmpty;
@property (nonatomic, assign) NSInteger isNoLimit;
@property (nonatomic, copy) NSString* parentLabel;
@property (nonatomic, assign) NSInteger rate;
@property (nonatomic, copy) NSString* rankType;
@property (nonatomic, strong) NSArray<FHFilterNodeModel*>* children;
@end

@interface FHFilterNodeModelConverter : NSObject
+(FHFilterNodeModel*)convertDictToModel:(NSDictionary*)dict;
@end

NS_ASSUME_NONNULL_END

//
//  TSVRecUserCardModel.h
//  Article
//
//  Created by 王双华 on 2017/9/27.
//

#import <JSONModel/JSONModel.h>
#import "TSVUserModel.h"

@class TSVRecUserCardOriginalData;

@protocol TSVRecUserSinglePersonModel
@end

@interface TSVRecUserCardModel : JSONModel

@property (nonatomic, weak) TSVRecUserCardOriginalData<Ignore> *tsvRecUserCardOriginalData;

@property (nonatomic, copy) NSString<Ignore> *listEntrance;
@property (nonatomic, copy) NSString<Ignore> *categoryName;
@property (nonatomic, copy) NSString<Ignore> *enterFrom;

@property (nonatomic, copy) NSDictionary<Optional> *logPb;
@property (nonatomic, copy) NSString<Optional> *cardID;
@property (nonatomic, copy) NSString<Optional> *title;
@property (nonatomic, copy) NSArray<TSVRecUserSinglePersonModel, Optional> *userList;

- (void)save;

@end

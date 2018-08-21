//
//  TTCountInfoResponseModel.h
//  Article
//
//  Created by fengyadong on 16/12/21.
//
//

#import <JSONModel/JSONModel.h>
@class TTCountInfoResponseDataModel;
@class TTCountInfoItemModel;

@interface TTCountInfoResponseModel : JSONModel

@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) TTCountInfoResponseDataModel *data;

@end

@interface TTCountInfoResponseDataModel : JSONModel

@property (nonatomic, copy)   NSString<Optional> *showInfo;
@property (nonatomic, strong) TTCountInfoItemModel<Optional> *momentItem;
@property (nonatomic, strong) TTCountInfoItemModel *followingsItem;
@property (nonatomic, strong) TTCountInfoItemModel *followerItem;
@property (nonatomic, strong) TTCountInfoItemModel<Optional> *multiplatformFollowerItem;
@property (nonatomic, strong) TTCountInfoItemModel *visitorItem;

@property (nonatomic, strong) NSMutableArray<Optional> *followerDetail;

@end

@interface TTCountInfoItemModel : JSONModel

@property (nonatomic, copy)   NSString *name;
@property (nonatomic, strong) NSNumber *value;

@end

@interface TTFollowerDetailModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *appID;
@property (nonatomic, copy) NSString<Optional> *downloadURL;
@property (nonatomic, copy) NSString<Optional> *fansCount;
@property (nonatomic, copy) NSString<Optional> *iconURL;
@property (nonatomic, copy) NSString<Optional> *appName;
@property (nonatomic, copy) NSString<Optional> *trackName;
@property (nonatomic, copy) NSString<Optional> *openURL;
@property (nonatomic, copy) NSString<Optional> *packageName;

@end

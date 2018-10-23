//
//  TTUserFollowJSONModels.h
//  Article
//
//  Created by 徐霜晴 on 16/12/15.
//
//

#import "JSONModel.h"
#import "TTResponseModelProtocol.h"
#import "TTRequestModel.h"

//api wiki:https://wiki.bytedance.net/pages/viewpage.action?pageId=19465762

@interface TTBlockStructModel : JSONModel

@property (nonatomic, strong) NSNumber<Optional> * blockUserID;
@property (nonatomic, copy) NSString<Optional> * desc;
@property (nonatomic, strong) NSNumber<Optional>* errorCode;

@end

@interface TTBlockResponseModel : JSONModel<TTResponseModelProtocol>

@property (nonatomic, copy) NSString<Optional> *message;
@property (nonatomic, strong) TTBlockStructModel<Optional> *data;

@end

@interface TTBlockRequestModel : TTRequestModel
@property(nonatomic, copy) NSString* block_user_id;
@end

@interface TTUnBlockRequestModel : TTRequestModel
@property(nonatomic, copy) NSString* block_user_id;
@end

@interface TTBlockUserListRequestModel : TTRequestModel

@property(nonatomic, assign) NSUInteger offset;
@property(nonatomic, assign) NSUInteger count;
@end

@interface TTBlockUserListResponseModel : JSONModel<TTResponseModelProtocol>

@property (nonatomic, copy) NSString<Optional> *message;
@property (nonatomic, strong) NSDictionary<Optional> *data;

@end

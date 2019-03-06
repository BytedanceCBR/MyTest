//
//  FHHomeRollModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHomeRollDataDataModel<NSObject>
@end

@protocol FHHomeRollDataDataDetailModel<NSObject>
@end

@interface FHHomeRollDataDataDetailModel : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *guessSearchId;
@property (nonatomic, copy , nullable) NSString *houseType;
@end

@interface FHHomeRollDataDataModel : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) NSArray<FHHomeRollDataDataDetailModel> *detail;
@end

@interface FHHomeRollDataModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHHomeRollDataDataModel> *data;
@end

@interface FHHomeRollModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHomeRollDataModel *data ;
@end

NS_ASSUME_NONNULL_END

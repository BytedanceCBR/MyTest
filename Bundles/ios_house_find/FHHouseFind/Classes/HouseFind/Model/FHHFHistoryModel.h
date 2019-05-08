//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import <FHHouseBase/FHBaseModelProtocol.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FHHFHistoryDataDataModel<NSObject>
@end

@interface FHHFHistoryDataDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *listText;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *historyId;
@property (nonatomic, copy , nullable) NSString *extinfo;
@end

@interface FHHFHistoryDataModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray<FHHFHistoryDataDataModel> *data;
@end

@interface FHHFHistoryModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHFHistoryDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER

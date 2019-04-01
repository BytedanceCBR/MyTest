//
//  FHHouseFindRecommendModel.h
//  FHHouseFind
//
//  Created by 张静 on 2019/4/1.
//

#import <JSONModel.h>
#import <FHHouseBase/FHBaseModelProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindRecommendDataModel : JSONModel

@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *priceTitle;
@property (nonatomic, copy , nullable) NSString *districtTitle;
@property (nonatomic, copy , nullable) NSString *roomNumTitle;
@property (nonatomic, copy , nullable) NSString *bottomOpenUrl;
@property (nonatomic, assign) NSInteger findHouseNumber;
@property (nonatomic, assign) BOOL used;
@property (nonatomic, assign) BOOL status;

@end

@interface FHHouseFindRecommendModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseFindRecommendDataModel *data ;
@end


NS_ASSUME_NONNULL_END

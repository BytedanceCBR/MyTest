//
//  FHSuggestionListModel.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FHBaseModelProtocol.h"
#import "FHImageModel.h"

NS_ASSUME_NONNULL_BEGIN

// FHSuggestionClearHistoryResponseModel
@interface  FHSuggestionClearHistoryResponseModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, copy , nullable) NSString *data;

@end

// FHSuggestionResponseModel
@protocol FHSuggestionResponseItemModel<NSObject>

@end


@interface  FHSuggestionResponseDataInfoModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *recallId;

@property (nonatomic, copy , nullable) NSString *areaId;
@property (nonatomic, copy , nullable) NSString *neighborhoodName;
@property (nonatomic, copy , nullable) NSString *wordid;
@property (nonatomic, copy , nullable) NSString *fea;
@property (nonatomic, copy , nullable) NSString *cityId;
@property (nonatomic, copy , nullable) NSString *recallType;
@property (nonatomic, copy , nullable) NSString *areaName;
@property (nonatomic, copy , nullable) NSString *isCut;
@property (nonatomic, copy , nullable) NSString *userOriginEnter;
@property (nonatomic, copy , nullable) NSString *districtId;
@property (nonatomic, copy , nullable) NSString *adreess;
@property (nonatomic, copy , nullable) NSString *oldName;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *districtName;
@property (nonatomic, copy , nullable) NSString *neigbordId;

@end


@interface  FHSuggestionResponseItemModel  : JSONModel

@property (nonatomic, strong , nullable) FHSuggestionResponseDataInfoModel *info ;
@property (nonatomic, copy , nullable) NSString *count;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *oldName;
@property (nonatomic, copy , nullable) NSString *tag;
@property (nonatomic, copy , nullable) NSString *tag2;
@property (nonatomic, copy , nullable) NSString *recallType;
@property (nonatomic, copy , nullable) NSString *tips2;
@property (nonatomic, copy , nullable) NSString *text2;
@property (nonatomic, copy , nullable) NSString *score;
@property (nonatomic, copy , nullable) NSString *query;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *countDisplay;
@property (nonatomic, copy , nullable) NSString *tips;
@property (nonatomic, copy , nullable) NSDictionary *newtip;
@property (nonatomic, copy , nullable) NSString *id;

//XXX: 为了支持1.0.1版本帮我找房卡片临时加入几个字段，之后需要支持混排
@property (nonatomic, assign) NSInteger cardType;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *buttonText;
@property (nonatomic, assign) BOOL setHistory;

@end

@interface  FHSuggestionResponseDataModel  : JSONModel

@property (nonatomic, strong , nullable) NSArray <FHSuggestionResponseItemModel> *items;
@property (nonatomic, strong , nullable) NSArray <FHSuggestionResponseItemModel> *otherItems;
@property (nonatomic, assign) NSInteger jumpHouseType;

@end

@interface  FHSuggestionResponseModel  : JSONModel  <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSuggestionResponseDataModel *data;

@end


// FHSuggestionSearchHistoryResponseModel
@protocol FHSuggestionSearchHistoryResponseDataDataModel<NSObject>

@end


@interface  FHSuggestionSearchHistoryResponseDataDataModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *listText;
@property (nonatomic, copy , nullable) NSString *description;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *historyId;
@property (nonatomic, copy , nullable) NSString *userOriginEnter;
@property (nonatomic, copy , nullable) NSString *extinfo;
@property (nonatomic, assign) BOOL setHistory;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;

@end


@interface  FHSuggestionSearchHistoryResponseDataModel  : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHSuggestionSearchHistoryResponseDataDataModel> *data;

@end


@interface  FHSuggestionSearchHistoryResponseModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSuggestionSearchHistoryResponseDataModel *data ;

@end


// FHGuessYouWantResponseModel
@protocol FHGuessYouWantResponseDataDataModel<NSObject>
@end

@interface FHGuessYouWantResponseDataDataRecommendTypeModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@interface FHGuessYouWantResponseDataDataRecommendReasonModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@interface FHGuessYouWantResponseDataDataModel : JSONModel

@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) FHGuessYouWantResponseDataDataRecommendTypeModel *recommendType ;
@property (nonatomic, copy , nullable) NSString *imageUrl;
@property (nonatomic, copy , nullable) NSString *guessSearchId;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, copy , nullable) NSString *guessSearchType;
@property (nonatomic, strong , nullable) FHGuessYouWantResponseDataDataRecommendReasonModel *recommendReason ;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, assign ) NSInteger type;
@property (nonatomic, assign ) NSInteger rank;
@property (nonatomic, copy , nullable) NSString *extinfo;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, assign) BOOL setHistory;
@end

@interface FHGuessYouWantExtraInfoModel : JSONModel

@property (nonatomic, strong, nullable) FHImageModel *icon;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *backgroundColor;
@property (nonatomic, copy, nullable) NSString *textColor;
@property (nonatomic, copy, nullable) NSString *openUrl;

@end

@interface FHGuessYouWantResponseDataModel : JSONModel

@property (nonatomic, strong , nullable) FHGuessYouWantExtraInfoModel *extraInfo;
@property (nonatomic, strong , nullable) NSArray<FHGuessYouWantResponseDataDataModel> *data;
@end

@interface FHGuessYouWantResponseModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHGuessYouWantResponseDataModel *data ;
@end

NS_ASSUME_NONNULL_END

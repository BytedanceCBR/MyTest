//
//  TTSearchSugModel.h
//  Article
//
//  Created by 王双华 on 16/12/21.
//
//

#import <JSONModel/JSONModel.h>

@class TTSearchSugData;

@protocol TTSearchSugItem;


@interface TTSearchSugModel : JSONModel

@property (nonatomic, strong) TTSearchSugData* result;

@end

@interface TTSearchSugData : JSONModel

@property (nonatomic, strong) NSArray<TTSearchSugItem, Optional>* data;

@end

@protocol TTSearchSugItem <NSObject>

@end

@interface TTSearchSugItem: JSONModel

@property (nonatomic, strong) NSString <Optional> *keyword;

@end


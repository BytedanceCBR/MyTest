//
//  ExploreCollectionBookCellModel.h
//  Article
//
//  Created by 王双华 on 16/9/23.
//
//

#import <Foundation/Foundation.h>
#import "TTImageInfosModel.h"

@interface ExploreCollectionBookCellModel : NSObject
@property (nonatomic, retain, nullable) NSNumber *bookID;
@property (nonatomic, retain, nullable) TTImageInfosModel *imageModel;
@property (nonatomic, retain, nullable) NSString *title;
@property (nonatomic, retain, nullable) NSString *desc;
@property (nonatomic, retain, nullable) NSString *schemaUrl;
@property (nonatomic, retain, nullable) TTImageInfosModel *nightImageModel;

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;
@end


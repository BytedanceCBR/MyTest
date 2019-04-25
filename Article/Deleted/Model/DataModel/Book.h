//
//  Book+CoreDataClass.h
//  Article
//
//  Created by 王双华 on 16/9/19.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOriginalData.h"
#import "TTImageInfosModel.h"

@class NSObject;
@class ExploreCollectionBookCellModel;

typedef NS_ENUM(NSUInteger, SerialStyle) {
    SerialStyleHasMoreCell = 1,//有更多的那个cell
    SerialStyleNoMoreCell  = 2,//无更多的那个cell
};

@interface Book : ExploreOriginalData

@property (nullable, nonatomic, retain) NSArray *bookList;
@property (nullable, nonatomic, copy) NSNumber *serialStyle;
@property (nullable, nonatomic, retain) NSDictionary *moreInfo;

/**
 *  返回多本小说数组, 使用bookList转换
 *
 *  @return
 */
- (nullable NSArray *)bookListModels;

/**
 *  返回更多小说的字典, 使用moreInfo转换
 *
 *  @return
 */
- (nullable ExploreCollectionBookCellModel *)moreInfoModel;

@end



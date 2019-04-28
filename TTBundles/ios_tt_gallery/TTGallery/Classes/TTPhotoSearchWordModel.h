//
//  TTPhotoSearchWordModel.h
//  Article
//
//  Created by 邱鑫玥 on 2017/4/1.
//
//

#import <Foundation/Foundation.h>

@interface TTPhotoSearchWordModel : NSObject
/**
 * 单搜索词
 */
@property (nonatomic, copy, readonly) NSString *title;
/**
 * 多搜索词
 */
@property (nonatomic, copy ,readonly) NSString *label;
/**
 * 搜索词对应schema
 */
@property (nonatomic, copy, readonly) NSString *link;
/**
 * 单搜索词对应的图片列表
 */
@property (nonatomic, copy, readonly) NSArray *imageList;
/**
 * 单搜索词对应的search_num
 */
@property (nonatomic, assign, readonly) NSInteger searchNum;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (BOOL)isValidSingleSearchWord;

- (BOOL)isValidMultiSearchWord;

@end

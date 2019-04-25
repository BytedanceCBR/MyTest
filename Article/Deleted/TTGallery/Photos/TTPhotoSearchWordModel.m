//
//  TTPhotoSearchWordModel.m
//  Article
//
//  Created by 邱鑫玥 on 2017/4/1.
//
//

#import "TTPhotoSearchWordModel.h"

@interface TTPhotoSearchWordModel ()
/**
 * 单搜索词
 */
@property (nonatomic, copy, readwrite) NSString *title;
/**
 * 多搜索词
 */
@property (nonatomic, copy ,readwrite) NSString *label;
/**
 * 搜索词对应schema
 */
@property (nonatomic, copy, readwrite) NSString *link;
/**
 * 单搜索词对应的图片列表
 */
@property (nonatomic, copy, readwrite) NSArray *imageList;
/**
 * 单搜索词对应的search_num
 */
@property (nonatomic, assign, readwrite) NSInteger searchNum;

@end

@implementation TTPhotoSearchWordModel

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    if(self = [super init]){
        _title = [dict tt_stringValueForKey:@"title"];
        _label = [dict tt_stringValueForKey:@"label"];
        _link = [dict tt_stringValueForKey:@"link"];
        _imageList = [dict tt_arrayValueForKey:@"image_list"];
        _searchNum = [dict tt_integerValueForKey:@"search_num"];
    }
    return self;
}

- (BOOL)isValidSingleSearchWord{
    if(!isEmptyString(_title) && [_imageList count] >= 3 && !isEmptyString(_link)){
        return YES;
    }
    return NO;
}

- (BOOL)isValidMultiSearchWord{
    if(!isEmptyString(_label) && !isEmptyString(_link)){
        return YES;
    }
    return NO;
}

@end

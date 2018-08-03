//
//  TTPushAlertModel.h
//  Article
//
//  Created by liuzuopeng on 06/07/2017.
//
//

#import <Foundation/Foundation.h>



@interface TTPushAlertModel : NSObject

/** 记录点击操作将要打开的Scheme */
@property (nonatomic,   copy) NSString *schemaString;

@property (nonatomic,   copy) NSString *ridString;

@property (nonatomic,   copy) NSNumber *gidString;

@property (nonatomic,   copy) NSString *titleString;

@property (nonatomic,   copy) NSString *detailString;

@property (nonatomic, strong) NSArray<id /*NSString, NSURL, UIImage */> *images;

+ (instancetype)modelWithTitle:(NSString *)titleString
                        detail:(NSString *)detailString
                        images:(NSArray *)imageArray;

/** 返回images中第一个对象 */
- (id)firstImageObject;

@end

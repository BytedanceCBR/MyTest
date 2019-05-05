//
//  SSBaseModel.h
//  Article
//
//  Created by Dianwei on 14-5-23.
//
//

#import <Foundation/Foundation.h>

/**
 有ID作为object的唯一识别的类可继承此类
 */
@interface SSBaseModel : NSObject
@property(nonatomic, copy) NSString *ID; // 该属性对外部只读
@end

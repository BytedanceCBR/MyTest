//
//  TTSFShareModel.h
//  Article
//
//  Created by 冯靖君 on 2017/12/6.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface TTSFShareModel : JSONModel

@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *shareDescription;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *targetURL;

@end

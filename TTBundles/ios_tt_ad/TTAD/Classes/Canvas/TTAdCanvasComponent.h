//
//  TTAdCanvasComponent.h
//  Article
//
//  Created by carl on 2017/11/13.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@class TTImageInfosModel;

@interface TTAdCanvasComponent : JSONModel

@property (nonatomic, copy, readonly) NSString *componentName;
@property (nonatomic, copy, readonly) NSString *componentType;

@property (nonatomic, copy) NSDictionary *styles;
@property (nonatomic, copy) NSDictionary *data;

- (NSDictionary *)exportComponent;

@end

@interface TTAdCanvasComponentPicture : TTAdCanvasComponent
- (instancetype)initWithImageModel:(TTImageInfosModel *)imageModel;
@end

@interface TTAdCanvasComponentVideo : TTAdCanvasComponent
- (instancetype)initWithImageModel:(TTImageInfosModel *)imageModel  videoID:(NSString *)videoID;
- (instancetype)initWithDictionary:(NSDictionary *)videoInfo error:(NSError *__autoreleasing *)err;
@end

@interface TTAdCanvasComponent (TTAd_Factory)
@end


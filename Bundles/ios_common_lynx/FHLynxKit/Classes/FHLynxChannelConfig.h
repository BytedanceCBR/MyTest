//
//  FHLynxChannelConfig.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/22.
//

#import <Foundation/Foundation.h>


#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN


@interface FHLynxTemplateConfig : JSONModel

@property (nonatomic, copy) NSString *templateKey;
@property (nonatomic, copy) NSString *templateName;

@property (nonatomic, copy) NSString<Ignore> *channel;

@end

@interface FHLynxChannelIOSConfig : JSONModel

@property (nonatomic, copy) NSArray<NSDictionary *> *templateList;

- (NSArray<FHLynxTemplateConfig *> *)templateConfigList;

@end

@interface FHLynxChannelConfig : JSONModel

@property (nonatomic, assign) NSUInteger version;
@property (nonatomic, strong) FHLynxChannelIOSConfig *iOS;

@property (nonatomic, assign) BOOL invalid;

@end

@protocol FHLynxFontConfig <NSObject>
@end
@interface FHLynxFontConfig : JSONModel

@property (nonatomic, copy) NSString *name; //font name
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, copy) NSString *path;

@end

@interface FHLynxServerConfig : JSONModel

@property (nonatomic, copy) NSString *templateChannel;
@property (nonatomic, copy) NSString *templateKey;
@property (nonatomic, assign) NSInteger impressionType;
@property (nonatomic, copy) NSString *impressionId;
@property (nonatomic, copy) NSDictionary *impressionExtra;
@property (nonatomic, assign) BOOL hideNativeDivider;
@property (nonatomic, copy) NSArray<FHLynxFontConfig> *dynamicFonts;

// lynx二期需求新增
@property (nonatomic, copy) NSString *lynxTemplateName;
@end

NS_ASSUME_NONNULL_END

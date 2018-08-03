//
//  ArticleAddressManager.m
//  Article
//
//  Created by Dianwei on 14-7-20.
//
//

#import "ArticleAddressManager.h"
#import "SSAddressBook.h"
#import "SSABPerson.h"
#import "ArticleURLSetting.h"
#import "TTNetworkManager.h"
#import "NSStringAdditions.h"

static NSString *const kUploadIntervalStorageKey    = @"kUploadIntervalStorageKey";
static NSString *const kReplaceRegexStorageKey      = @"";
static int const kDefaultUploadInterval             = 7 * 24 * 3600;

NSString * const kAddressBookHasGotNotification     = @"kAddressBookHasGotNotification";

@interface ArticleAddressManager() {
}

@property(nonatomic, strong)NSTimer *uploadTimer;

@end
@implementation ArticleAddressManager

static NSMutableDictionary * _privateAddressbookPersons;

static ArticleAddressManager *s_manager;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[ArticleAddressManager alloc] init];
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        _privateAddressbookPersons = [[NSMutableDictionary alloc] initWithCapacity:2];
        if ([userDefaults valueForKey:ArticleAddressPersonCacheKey]) {
            NSDictionary * dictionary = [userDefaults valueForKey:ArticleAddressPersonCacheKey];
            [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    SSABPerson * person = [[SSABPerson alloc] initWithDictionary:obj];
                    [_privateAddressbookPersons setValue:person forKey:key];
                }
            }];
        }
    });
    
    return s_manager;
}

+ (void)setUploadInterval:(NSTimeInterval)uploadInterval
{
    [[NSUserDefaults standardUserDefaults] setDouble:uploadInterval forKey:kUploadIntervalStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)uploadInterval
{
    
    if([[NSUserDefaults standardUserDefaults] doubleForKey:kUploadIntervalStorageKey] > 0)
    {
        return MAX([[NSUserDefaults standardUserDefaults] doubleForKey:kUploadIntervalStorageKey], 60.f);
    }
    
    return kDefaultUploadInterval;
}

- (void)dealloc
{
    [_uploadTimer invalidate];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)upload:(NSTimer*)timer {
    [self startUploadAddressBookWithFinishBlock:^(NSError *error) {
        
    }];
}

- (void)startUploadAddressBookWithFinishBlock:(void(^)(NSError *error))finishBlock {
    [self startUploadAddressBookWithPermissionBlock:NULL uploadFinishBlock:finishBlock];
}

- (void)startUploadAddressBookWithPermissionBlock:(void(^)(NSError * error)) permissionBlock uploadFinishBlock:(void(^)(NSError *error))finishBlock {
    [ArticleAddressManager sharedManager];
    SSAddressBook *book = [[SSAddressBook alloc] init];
    [book startGetAllContactsWithFinishBlock:^(NSArray *persons, NSError *error) {
        if (permissionBlock) {
            permissionBlock(error);
        }
        if(!error && persons.count >= 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAddressBookHasGotNotification object:nil];
            
            [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting uploadAddressBookURLString] params:[self postDataFromPersons:persons] method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
                if(finishBlock) {
                    finishBlock(error);
                }
            }];
        }
        else
        {
            if(finishBlock)
            {
                finishBlock(error);
            }
        }
    }];
}

- (id)postDataFromPersons:(NSArray*)persons {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:persons.count];
    [_privateAddressbookPersons removeAllObjects];
    for(SSABPerson *person in persons)
    {
        if(person.phoneNumbers) {
            [contacts addObject:@{@"mobiles": [self processPhoneNumbers:person.phoneNumbers inPerson:person]}];
        }
    }
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity:5];
    [_privateAddressbookPersons enumerateKeysAndObjectsUsingBlock:^(id key, SSABPerson * obj, BOOL *stop) {
        if ([obj isKindOfClass:[SSABPerson class]]) {
            [dictionary setValue:[obj toDictionary] forKey:key];
        }
    }];
    [userDefaults setValue:dictionary forKey:ArticleAddressPersonCacheKey];
    [userDefaults synchronize];
    result[@"contacts"] = contacts;
    return result;
}


- (NSArray*)processPhoneNumbers:(NSArray*)phoneNumabers inPerson:(SSABPerson *) person{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:phoneNumabers.count];
    for(NSString *phoneNumber in phoneNumabers)
    {
        NSString *processedString = [self processPhoneNumber:phoneNumber];
        if(!isEmptyString(processedString))
        {
            [result addObject:processedString];
            [_privateAddressbookPersons setValue:person forKey:[processedString lowercaseString]];
        }
    }
    
    return result;
}

- (NSDictionary *) addressBookPersons {
    return [_privateAddressbookPersons copy];
}


- (NSString*)processPhoneNumber:(NSString*)phoneNumberString
{
    NSMutableString *strippedString = [NSMutableString stringWithCapacity:13];
    for(int idx = 0; idx < [phoneNumberString length]; idx ++)
    {
        if(isdigit([phoneNumberString characterAtIndex:idx]))
        {
            [strippedString appendFormat:@"%c", [phoneNumberString characterAtIndex:idx]];
        }
    }
    
    NSArray *regexs = [ArticleAddressManager replaceRegluarExpress];
    NSString *modifiedString = nil;
    for(NSArray *regex in regexs)
    {
        if ([regex isKindOfClass:[NSArray class]] && regex.count == 2)
        {
            NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regex[0] options:NSRegularExpressionCaseInsensitive error:nil];
            modifiedString = [expression stringByReplacingMatchesInString:strippedString options:0 range:NSMakeRange(0, strippedString.length) withTemplate:regex[1]];
            if(!isEmptyString(modifiedString))
            {
                break;
            }
        }
    }
    
    if(!isEmptyString(modifiedString))
    {
        NSString *result = [modifiedString SHA256String];
        return result;
    }
    else
    {
        return nil;
    }
}

+ (NSArray*)replaceRegluarExpress
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:kReplaceRegexStorageKey];
}

+ (void)setReplaceRegularExpress:(NSArray*)regex
{
    
    [[NSUserDefaults standardUserDefaults] setValue:regex forKey:kReplaceRegexStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const ArticleAddressPersonCacheKey = @"ArticleAddressPersonCacheKey";

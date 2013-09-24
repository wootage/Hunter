#import <Foundation/Foundation.h>

@interface ApiCalls : NSObject

+ (ApiCalls *)sharedClient;
- (void)getGameVersion;
- (void)login :(NSString *)username :(NSString *)password :(NSString *)gameVersion;
- (void)hunt :(NSString *)gameVersion;

@end

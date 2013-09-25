#import <Foundation/Foundation.h>

@interface ApiCalls : NSObject

+ (ApiCalls *)sharedClient;
- (void)getGameVersion;
- (void)login :(NSString *)username :(NSString *)password;
- (void)hunt;

@end

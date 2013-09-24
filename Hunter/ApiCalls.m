#import "ApiCalls.h"

@implementation ApiCalls

+ (ApiCalls *)sharedClient {
    
    static ApiCalls *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ApiCalls alloc] init];
    });
    
    return _sharedClient;
}


@end

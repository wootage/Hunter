#import "SharedClient.h"
#import "AFJSONRequestOperation.h"

@implementation SharedClient

static NSString * const kAFAppDotNetAPIBaseURLString = @"https://www.mousehuntgame.com/api/"; //"http://httpbin.org/post"


+ (SharedClient *)sharedClient {
    static SharedClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SharedClient alloc] initWithBaseURL:[NSURL URLWithString:kAFAppDotNetAPIBaseURLString]];
    });
    
    return _sharedClient;
}

@end

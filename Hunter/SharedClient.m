#import "SharedClient.h"
#import "AFJSONRequestOperation.h"

@implementation SharedClient

static NSString * const kAFAppDotNetAPIBaseURLString = @"http://8tracks.com/";


+ (SharedClient *)sharedClient {
    static SharedClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SharedClient alloc] initWithBaseURL:[NSURL URLWithString:kAFAppDotNetAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end

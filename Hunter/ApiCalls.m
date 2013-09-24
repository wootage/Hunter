#import "ApiCalls.h"
#import "SharedClient.h"

@implementation ApiCalls

+ (ApiCalls *)sharedClient {
    
    static ApiCalls *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ApiCalls alloc] init];
    });
    
    return _sharedClient;
}

- (void)getGameVersion {
    
    NSString *stringPath = [NSString stringWithFormat:@"info"];
    
    [[SharedClient sharedClient] postPath:stringPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *list =[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"getGameVersionSuccess" object: nil userInfo:list];
    }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      //TODO
                                  }];
}

- (void)login :(NSString *)username :(NSString *)password :(NSString *)gameVersion {
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    NSDictionary *cookie = [NSHTTPCookie requestHeaderFieldsWithCookies: [cookieStorage cookies]];

    NSHTTPCookie *coo = [NSHTTPCookie cookieWithProperties:cookie];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:coo];

    
    [[SharedClient sharedClient]setDefaultHeader:@"User-Agent" value:@"Mozilla/5.0 (Linux; U; Android 2.3.3; en-en; HTC Desire Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"];
    [[SharedClient sharedClient]setDefaultHeader:@"Accept" value:@"application/json, text/javascript, */*; q=0.01"];
    [[SharedClient sharedClient]setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [[SharedClient sharedClient]setDefaultHeader:@"X-Requested-With" value:@"com.hitgrab.android.mousehunt"];
    [[SharedClient sharedClient]setDefaultHeader:@"Accept-Encoding" value:@"gzip,deflate"];
    [[SharedClient sharedClient]setDefaultHeader:@"Accept-Language" value:@"en-US"];
    [[SharedClient sharedClient]setDefaultHeader:@"Accept-Charset" value:@"utf-8, iso-8859-1, utf-16, *;q=0.7"];
    
    NSString *stringPath = [NSString stringWithFormat:@"login"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"2",@"v",
                            @"Cordova%%3AAndroid",@"client_id",
                            @"0.12.4",@"client_version",
                            gameVersion,@"game_version",
                            username,@"account_name",
                            password,@"password",
                            @"1",@"login_token",
                            nil];
    
    [[SharedClient sharedClient] postPath:stringPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
         NSDictionary *list =[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"loginSuccess" object: nil userInfo:list];        
    }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSDictionary *errors = [error valueForKey:@"userInfo"];
                                      [[NSNotificationCenter defaultCenter] postNotificationName: @"loginFail" object: nil userInfo:errors];
                                  }];
}

- (void)hunt :(NSString *)gameVersion{
    
    NSString *stringPath = [NSString stringWithFormat:@"action/turn/me"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"2",@"v",
                            @"Cordova%%3AAndroid",@"client_id",
                            @"0.12.4",@"client_version",
                            gameVersion,@"game_version",
                            @"eebb14b4a5c18e19dacdf2b84ef8df5e|100006700177710",@"login_token",
                            nil];
    
    [[SharedClient sharedClient] postPath:stringPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *list =[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"huntSuccess" object: nil userInfo:list];
    }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      NSDictionary *errors = [error valueForKey:@"userInfo"];
                                      [[NSNotificationCenter defaultCenter] postNotificationName: @"huntFail" object: nil userInfo:errors];
                                  }];

}

@end

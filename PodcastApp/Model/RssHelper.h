//
//  RssHelper.h
//  PodcastApp
//
//  Created by Astrid on 2022/2/11.
//

#import <Foundation/Foundation.h>
#import "RssItem.h"


//NS_ASSUME_NONNULL_BEGIN

@protocol RssHelperDelegate <NSObject>
@required
- (void)suceededFetchRss:(NSArray*)rssItems infoTitle:(NSString*)infoTitle infoImage:(NSString*)infoImage;
- (void)failedFetchRss;
@end

@interface RssHelper : NSObject <NSXMLParserDelegate> {
    NSXMLParser *xmlParser;
}

@property (nonatomic) bool infoTitleFound;
@property (nonatomic) bool infoImageFound;
@property (nonatomic, strong) NSMutableArray *rssItems;
@property (nonatomic, strong) NSString *rssInfoImage;
@property (nonatomic, strong) NSString *rssInfoTitle;

@property (nonatomic, strong) NSString *audioUrl;
@property (nonatomic, strong) NSString *currentElement;
@property (nonatomic, strong) NSMutableString *currentTitle;
@property (nonatomic, strong) NSMutableString *currentDescription;
@property (nonatomic, strong) NSMutableString *currentPubDate;
@property (nonatomic, strong) NSString *currentInfoImageUrl;
@property (nonatomic, strong) NSString *currentAudioUrl;

@property (nonatomic, weak) id<RssHelperDelegate> delegate;

- (void)parsefeedWithUrlString:(NSString*) urlString ;
- (instancetype)init;

@end

//NS_ASSUME_NONNULL_END

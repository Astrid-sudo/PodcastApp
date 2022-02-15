//
//  RssHelper.h
//  PodcastApp
//
//  Created by Astrid on 2022/2/11.
//

#import <Foundation/Foundation.h>
#import "RssItem.h"



@protocol RssHelperDelegate <NSObject>
@required

/*!
 * @discussion Pass data to delegate.
 * @param rssItems The rss items fetched from url.
 * @param infoTitle The infoTitle fetched from url.
 * @param infoImage The infoImageUrl fetched from url
 */
- (void)suceededFetchRss:(NSArray*)rssItems infoTitle:(NSString*)infoTitle infoImage:(NSString*)infoImage;
- (void)failedFetchRss: (NSError*)error;
@end

@interface RssHelper : NSObject <NSXMLParserDelegate> {
    NSXMLParser *xmlParser;
}

/*!
 * @discussion Whether info title found.
 */
@property (nonatomic) bool infoTitleFound;

/*!
 * @discussion Whether info image found.
 */
@property (nonatomic) bool infoImageFound;

/*!
 * @discussion The array stored fetched rss items.
 */
@property (nonatomic, strong) NSMutableArray *rssItems;

/*!
 * @discussion Rss info image url string.
 */
@property (nonatomic, strong) NSString *rssInfoImage;

/*!
 * @discussion Rss info title.
 */
@property (nonatomic, strong) NSString *rssInfoTitle;

/*!
 * @discussion Audio url string.
 */
@property (nonatomic, strong) NSString *audioUrl;

/*!
 * @discussion The element XML parser currently on.
 */
@property (nonatomic, strong) NSString *currentElement;

/*!
 * @discussion The string temporarily collect title chracters.
 */
@property (nonatomic, strong) NSMutableString *currentTitle;

/*!
 * @discussion The string temporarily collect description chracters.
 */
@property (nonatomic, strong) NSMutableString *currentDescription;

/*!
 * @discussion The string temporarily collect pubDate chracters.
 */
@property (nonatomic, strong) NSMutableString *currentPubDate;

/*!
 * @discussion The string stored currentInfoImageUrl.
 */
@property (nonatomic, strong) NSString *currentInfoImageUrl;

/*!
 * @discussion The string stored currentAudioUrl.
 */
@property (nonatomic, strong) NSString *currentAudioUrl;

/*!
 * @discussion The delegate to recieve data after parsing.
 */
@property (nonatomic, weak) id<RssHelperDelegate> delegate;

/*!
 * @discussion Parse feed with url string.
 * @param urlString The rss feed url string.
 */
- (void)parsefeedWithUrlString:(NSString*) urlString ;
- (instancetype)init;

@end


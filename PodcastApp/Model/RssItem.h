//
//  RssItem.h
//  PodcastApp
//
//  Created by Astrid on 2022/2/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RssItem : NSObject

@property (nonatomic, strong) NSString* rssTitle;
@property (nonatomic, strong) NSString* rssDescription;
@property (nonatomic, strong) NSString* rssPubDate;
@property (nonatomic, strong) NSString* rssAudioUrl;
@property (nonatomic, strong) NSString* rssEpImageUrl;

- (instancetype)initWithRssTitle:(NSString*)rssTitle initWithRssDescription:(NSString*)rssDescription initWithRssPubDate:(NSString*)rssPubDate initWithAudioUrl:(NSString*)rssAudioUrl initWithEpImageUrl:(NSString*)rssEpImageUrl;

- (NSString*) description;

@end

NS_ASSUME_NONNULL_END

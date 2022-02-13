//
//  RssItem.m
//  PodcastApp
//
//  Created by Astrid on 2022/2/12.
//

#import "RssItem.h"

@implementation RssItem

- (instancetype)initWithRssTitle:(NSString*)rssTitle initWithRssDescription:(NSString*)rssDescription initWithRssPubDate:(NSString*)rssPubDate initWithAudioUrl:(NSString*)rssAudioUrl initWithEpImageUrl:(NSString*)rssEpImageUrl {
    self = [super init];
    if (self != nil) {
        self.rssTitle = rssTitle;
        self.rssDescription = rssDescription;
        self.rssPubDate = rssPubDate;
        self.rssAudioUrl = rssAudioUrl;
        self.rssEpImageUrl = rssEpImageUrl;
    }
    return self;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@", self.rssTitle, self.rssDescription, self.rssPubDate, self.rssAudioUrl, self.rssEpImageUrl];
}

@end

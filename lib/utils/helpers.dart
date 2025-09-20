import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

bool _zhTwLocaleLoaded = false;

String formatRelativeTime(Timestamp? timestamp) {
  if (!_zhTwLocaleLoaded) {
    timeago.setLocaleMessages('en', timeago.ZhMessages());
    _zhTwLocaleLoaded = true;
  }

  if (timestamp == null) {
    return '尚未複習';
  }
  
  return timeago.format(timestamp.toDate());
}
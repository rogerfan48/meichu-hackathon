import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsService {
  CloudFunctionsService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<void> runSessionPipeline({required String userId, required String sessionId}) async {
    final callable = _functions.httpsCallable('runSessionPipeline');
    await callable.call({'userId': userId, 'sessionId': sessionId});
  }
}

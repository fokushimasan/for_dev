import 'package:get/get.dart';

mixin SessionMixin on GetxController {
  final _isSessionExpired = RxBool();
  Stream<bool> get isSessionExpiredStream => _isSessionExpired.stream;
  set isSessionExpired(bool value) => _isSessionExpired.value = value;
}

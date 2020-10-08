import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:localstorage/localstorage.dart';
import 'package:meta/meta.dart';

class LocalStorageAdapter {
  final LocalStorage localStorage;

  LocalStorageAdapter({@required this.localStorage});

  Future<void> save({@required String key, @required dynamic value}) async {
    await localStorage.deleteItem(key);
    await localStorage.setItem(key, value);
  }
}

class LocalStorageSpy extends Mock implements LocalStorage {}

void main() {
  LocalStorageAdapter sut;
  LocalStorageSpy localStorage;
  String key;
  dynamic value;

  void mockDeleteItemError() =>
      when(localStorage.deleteItem(any)).thenThrow(Exception());

  void mockSetItemError() =>
      when(localStorage.setItem(any, any)).thenThrow(Exception());

  setUp(() {
    localStorage = LocalStorageSpy();
    sut = LocalStorageAdapter(localStorage: localStorage);
    key = faker.randomGenerator.string(5, min: 5);
    value = faker.randomGenerator.string(50, min: 50);
  });

  test('should call localStorage with correct values', () async {
    // act
    await sut.save(key: key, value: value);
    // assert
    verify(localStorage.deleteItem(key)).called(1);
    verify(localStorage.setItem(key, value)).called(1);
  });

  test('should throw if deleteItem throws', () async {
    // arrange
    mockDeleteItemError();
    // act
    final future = sut.save(key: key, value: value);
    // assert
    expect(future, throwsA(TypeMatcher<Exception>()));
  });

  test('should throw if deleteItem throws', () async {
    // arrange
    mockSetItemError();
    // act
    final future = sut.save(key: key, value: value);
    // assert
    expect(future, throwsA(TypeMatcher<Exception>()));
  });
}

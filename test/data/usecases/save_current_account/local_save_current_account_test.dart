import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';

import 'package:for_dev/domain/entities/entities.dart';
import 'package:for_dev/domain/helpers/helpers.dart';
import 'package:for_dev/domain/usecases/usecases.dart';

abstract class ISaveSecureCacheStorage {
  Future<void> saveSecure({
    @required String key,
    @required String value,
  });
}

class SaveSecureCacheStorageSpy extends Mock
    implements ISaveSecureCacheStorage {}

class LocalSaveCurrentAccount implements ISaveCurrentAccount {
  final ISaveSecureCacheStorage saveSecureCacheStorage;

  LocalSaveCurrentAccount({@required this.saveSecureCacheStorage});

  @override
  Future<void> save(AccountEntity account) async {
    try {
      await saveSecureCacheStorage.saveSecure(
        key: 'token',
        value: account.token,
      );
    } catch (_) {
      throw DomainError.unexpected;
    }
  }
}

void main() {
  SaveSecureCacheStorageSpy saveSecureCacheStorage;
  LocalSaveCurrentAccount sut;
  AccountEntity account;

  setUp(() {
    saveSecureCacheStorage = SaveSecureCacheStorageSpy();
    sut =
        LocalSaveCurrentAccount(saveSecureCacheStorage: saveSecureCacheStorage);
    account = AccountEntity(token: faker.guid.guid());
  });

  test('should call SaveSecureCacheStorage with correct values', () async {
    // act
    await sut.save(account);

    // assert
    verify(
        saveSecureCacheStorage.saveSecure(key: 'token', value: account.token));
  });

  test(
    'should throw UnexpectedError if SaveSecureCacheStorage throws',
    () async {
      // arrange
      when(saveSecureCacheStorage.saveSecure(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenThrow(Exception());

      // act
      final future = sut.save(account);

      // assert
      expect(future, throwsA(DomainError.unexpected));
    },
  );
}
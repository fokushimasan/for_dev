import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:for_dev/domain/entities/entities.dart';
import 'package:for_dev/domain/usecases/usecases.dart';
import 'package:for_dev/domain/helpers/helpers.dart';
import 'package:for_dev/presentation/presenters/presenters.dart';
import 'package:for_dev/ui/helpers/errors/errors.dart';
import 'package:for_dev/ui/pages/pages.dart';

import '../../mocks/mocks.dart';

class LoadSurveysSpy extends Mock implements ILoadSurveys {}

void main() {
  GetxSurveysPresenter sut;
  LoadSurveysSpy loadSurveys;

  PostExpectation mockLoadSurveysCall() => when(loadSurveys.load());

  void mockLoadSurveys(List<SurveyEntity> data) {
    mockLoadSurveysCall().thenAnswer((_) async => data);
  }

  void mockLoadSurveysError() =>
      mockLoadSurveysCall().thenThrow(DomainError.unexpected);
  void mockAccessDeniedError() =>
      mockLoadSurveysCall().thenThrow(DomainError.accessDenied);

  setUp(() {
    loadSurveys = LoadSurveysSpy();
    sut = GetxSurveysPresenter(loadSurveys: loadSurveys);
    mockLoadSurveys(FakeSurveysMock.makeEntities());
  });

  test('should call LoadSurveys on loadData', () async {
    // arrange

    // act
    await sut.loadData();
    // assert
    verify(loadSurveys.load()).called(1);
  });

  test('should emit correct events on success', () async {
    // assert
    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    sut.surveysStream.listen(expectAsync1((surveys) => expect(surveys, [
          SurveyViewModel(
            id: surveys[0].id,
            question: surveys[0].question,
            date: DateFormat('dd MMM yyyy').format(DateTime(1969, 07, 20)),
            didAnswer: surveys[0].didAnswer,
          ),
          SurveyViewModel(
            id: surveys[1].id,
            question: surveys[1].question,
            date: DateFormat('dd MMM yyyy').format(DateTime(1970, 05, 12)),
            didAnswer: surveys[1].didAnswer,
          ),
        ])));
    // act
    await sut.loadData();
  });

  test('should emit correct events on failure', () async {
    // arrange
    mockLoadSurveysError();

    // assert
    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    sut.surveysStream.listen(
      null,
      onError: expectAsync1(
        (error) => expect(error, UIError.unexpected.description),
      ),
    );
    // act
    await sut.loadData();
  });

  test('should emit correct events on access denied', () async {
    // arrange
    mockAccessDeniedError();

    // assert
    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    expectLater(sut.isSessionExpiredStream, emits(true));
    // act
    await sut.loadData();
  });

  test('should go to SurveyResultPage on survey click', () async {
    expectLater(
      sut.navigateToStream,
      emitsInOrder([
        '/survey_result/any_router',
        '/survey_result/other_router',
      ]),
    );

    // act
    sut.goToSurveyResult('any_router');
    sut.goToSurveyResult('other_router');
  });
}

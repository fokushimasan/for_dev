import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:for_dev/data/usecases/usecases.dart';
import 'package:for_dev/data/http/http.dart';
import 'package:for_dev/domain/entities/entities.dart';
import 'package:for_dev/domain/helpers/helpers.dart';

import '../../../mocks/mocks.dart';

class HttpClientSpy extends Mock implements IHttpClient {}

void main() {
  RemoteSaveSurveyResult sut;
  HttpClientSpy httpClient;
  String url;
  String answer;
  Map surveyResult;

  PostExpectation mockRequest() => when(httpClient.request(
        url: anyNamed('url'),
        method: anyNamed('method'),
        body: anyNamed('body'),
      ));

  void mockRequestData(Map data) {
    surveyResult = data;
    mockRequest().thenAnswer((_) async => surveyResult);
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  setUp(() {
    answer = faker.lorem.sentence();
    url = faker.internet.httpUrl();
    httpClient = HttpClientSpy();
    sut = RemoteSaveSurveyResult(url: url, httpClient: httpClient);
    mockRequestData(FakeSurveyResultMock.makeApiJson());
  });

  test('should call HttpClient with correct values', () async {
    // act
    await sut.save(answer: answer);
    // assert
    verify(httpClient.request(
      url: url,
      method: 'PUT',
      body: {'answer': answer},
    ));
  });

  test('should return surveyResult on 200', () async {
    // act
    final survey = await sut.save(answer: answer);
    // assert
    expect(
      survey,
      SurveyResultEntity(
        surveyId: surveyResult['surveyId'],
        question: surveyResult['question'],
        answers: [
          SurveyAnswerEntity(
            image: surveyResult['answers'][0]['image'],
            answer: surveyResult['answers'][0]['answer'],
            isCurrentAnswer: surveyResult['answers'][0]
                ['isCurrentAccountAnswer'],
            percent: surveyResult['answers'][0]['percent'],
          ),
          SurveyAnswerEntity(
            image: surveyResult['answers'][1]['image'],
            answer: surveyResult['answers'][1]['answer'],
            isCurrentAnswer: surveyResult['answers'][1]
                ['isCurrentAccountAnswer'],
            percent: surveyResult['answers'][1]['percent'],
          ),
        ],
      ),
    );
  });

  test(
      'should throws UnexpectedError if HttpClient returns 200 with invalid data',
      () async {
    // arrange
    mockRequestData(FakeSurveyResultMock.makeInvalidJson());
    // act
    final future = sut.save(answer: answer);
    // assert
    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if HttpClient returns 404', () async {
    // arrange
    mockHttpError(HttpError.notFound);

    // act
    final future = sut.save(answer: answer);

    // assert
    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw AccessDeniedError if HttpClient returns 403', () async {
    // arrange
    mockHttpError(HttpError.forbidden);

    // act
    final future = sut.save(answer: answer);

    // assert
    expect(future, throwsA(DomainError.accessDenied));
  });

  test('should throw UnexpectedError if HttpClient returns 500', () async {
    // arrange
    mockHttpError(HttpError.serverError);

    // act
    final future = sut.save(answer: answer);

    // assert
    expect(future, throwsA(DomainError.unexpected));
  });
}

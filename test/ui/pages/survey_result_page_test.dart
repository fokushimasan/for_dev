import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_test_utils/image_test_utils.dart';

import 'package:for_dev/ui/pages/pages.dart';
import 'package:for_dev/ui/helpers/helpers.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mocks.dart';
import '../helpers/helpers.dart';

class SurveyResultPresenterSpy extends Mock implements ISurveyResultPresenter {}

void main() {
  SurveyResultPresenterSpy presenter;
  StreamController<bool> isLoadingController;
  StreamController<bool> isSessionExpiredController;
  StreamController<SurveyResultViewModel> surveyResultController;

  void initStreams() {
    isLoadingController = StreamController<bool>();
    isSessionExpiredController = StreamController<bool>();
    surveyResultController = StreamController<SurveyResultViewModel>();
  }

  void mockStreams() {
    when(presenter.isLoadingStream)
        .thenAnswer((_) => isLoadingController.stream);
    when(presenter.isSessionExpiredStream)
        .thenAnswer((_) => isSessionExpiredController.stream);
    when(presenter.surveyResultStream)
        .thenAnswer((_) => surveyResultController.stream);
  }

  void closeStreams() {
    isLoadingController.close();
    isSessionExpiredController.close();
    surveyResultController.close();
  }

  Future<void> loadPage(WidgetTester tester) async {
    presenter = SurveyResultPresenterSpy();
    initStreams();
    mockStreams();

    await provideMockedNetworkImages(() async {
      await tester.pumpWidget(makePage(
        path: '/survey_result/:survey_id',
        page: () => SurveyResultPage(presenter: presenter),
      ));
    });
  }

  tearDown(() {
    closeStreams();
  });

  testWidgets('should call LoadSurveyResult on page load',
      (WidgetTester tester) async {
    await loadPage(tester);

    verify(presenter.loadData()).called(1);
  });

  testWidgets('should handle loading correctly', (WidgetTester tester) async {
    await loadPage(tester);

    isLoadingController.add(true);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    isLoadingController.add(false);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    isLoadingController.add(true);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    isLoadingController.add(null);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('should present error if loadSurveyResultStream fails',
      (WidgetTester tester) async {
    await loadPage(tester);

    surveyResultController.addError(UIError.unexpected.description);
    await tester.pump();
    expect(
      find.text('Algo de errado aconteceu. Tente novamente em breve.'),
      findsOneWidget,
    );
    expect(find.text('Recarregar'), findsOneWidget);
    expect(find.text('Question'), findsNothing);
  });

  testWidgets('should call LoadSurveyResult on reload button click',
      (WidgetTester tester) async {
    await loadPage(tester);

    surveyResultController.addError(UIError.unexpected.description);
    await tester.pump();
    await tester.tap(find.text('Recarregar'));

    verify(presenter.loadData()).called(2);
  });

  testWidgets(
    'should logout',
    (WidgetTester tester) async {
      await loadPage(tester);

      isSessionExpiredController.add(true);
      await tester.pumpAndSettle();

      expect(currentRoute, '/login');
      expect(find.text('fake login'), findsOneWidget);
    },
  );

  testWidgets(
    'should not logout',
    (WidgetTester tester) async {
      await loadPage(tester);

      isSessionExpiredController.add(false);
      await tester.pumpAndSettle();
      expect(currentRoute, '/survey_result/:survey_id');

      isSessionExpiredController.add(null);
      await tester.pumpAndSettle();
      expect(currentRoute, '/survey_result/:survey_id');
    },
  );

  testWidgets('should call save on list item click',
      (WidgetTester tester) async {
    await loadPage(tester);

    surveyResultController.add(FakeSurveyResultMock.makeViewModel());
    await provideMockedNetworkImages(() async {
      await tester.pump();
    });
    await tester.tap(find.text('Answer 1'));

    verify(presenter.save(answer: 'Answer 1')).called(1);
  });

  testWidgets('should not call save on current answer item click',
      (WidgetTester tester) async {
    await loadPage(tester);

    surveyResultController.add(FakeSurveyResultMock.makeViewModel());
    await provideMockedNetworkImages(() async {
      await tester.pump();
    });
    await tester.tap(find.text('Answer 0'));

    verifyNever(presenter.save(answer: 'Answer 0'));
  });
}

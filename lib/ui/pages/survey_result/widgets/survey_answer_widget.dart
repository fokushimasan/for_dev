import 'package:flutter/material.dart';

import '../viewmodels/viewmodels.dart';
import 'widgets.dart';

class SurveyAnswerWidget extends StatelessWidget {
  final SurveyAnswerViewModel viewModel;

  const SurveyAnswerWidget({@required this.viewModel});

  @override
  Widget build(BuildContext context) {
    List<Widget> _buildItems() {
      List<Widget> children = [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              viewModel.answer,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
        Text(
          viewModel.percent,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        viewModel.isCurrentAnswer ? ActiveIconWidget() : DisabledIconWidget()
      ];

      if (viewModel.image != null) {
        children.insert(0, Image.network(viewModel.image, width: 40));
      }

      return children;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildItems(),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

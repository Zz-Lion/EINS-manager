import 'package:eins_manager/widgets/add_filter_button_widget.dart';
import 'package:eins_manager/widgets/filter_list_widget.dart';
import 'package:flutter/material.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Container(
        width: mediaSize.width,
        height: mediaSize.height -
            (Scaffold.of(context).appBarMaxHeight ?? 0) -
            MediaQuery.of(context).padding.bottom,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            AddFilterButton(),
            const SizedBox(height: 20),
            Expanded(
              child: FilterList(),
            ),
          ],
        ),
      ),
    );
  }
}

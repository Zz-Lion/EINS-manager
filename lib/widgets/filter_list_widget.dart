import 'dart:io';

import 'package:eins_manager/constants/color_constant.dart';
import 'package:eins_manager/models/filter_model.dart';
import 'package:eins_manager/models/product_model.dart';
import 'package:eins_manager/providers/filter_provider.dart';
import 'package:eins_manager/providers/product_provider.dart';
import 'package:eins_manager/widgets/error_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FilterList extends StatefulWidget {
  const FilterList({Key? key}) : super(key: key);

  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        if (context.read<FilterProvider>().hasNextDocs) {
          context.read<FilterProvider>().getFilters(10);
        }
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {
        await context.read<FilterProvider>().getFilters(10);
      } catch (e) {
        errorDialog(context, e);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  Future<DateTime?> _showDatePicker(BuildContext context) async {
    if (Platform.isIOS) {
      DateTime? selectedDate;

      return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text("날짜를 선택해주세요."),
            actions: <Widget>[
              CupertinoDatePicker(
                minimumYear: DateTime.now().year - 5,
                maximumYear: DateTime.now().year + 5,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (DateTime value) {
                  selectedDate = value;
                },
                mode: CupertinoDatePickerMode.date,
              ),
              CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop(selectedDate);
                },
                child: Text("확인"),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text("취소"),
            ),
          );
        },
      );
    } else {
      return showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        helpText: "날짜를 선택해주세요.",
        cancelText: "취소",
        confirmText: "확인",
      );
    }
  }

  Future<void> _editFilter(BuildContext context, FilterModel filter) async {
    final Size mediaSize = MediaQuery.of(context).size;
    final ProductProvider productProv = context.read<ProductProvider>();
    final FilterProvider filterProv = context.read<FilterProvider>();

    try {
      int selectedProduct = productProv.getProductIndex(filter.productName);
      DateTime? selectedStartDate = filter.startDate;
      DateTime? selectedReplaceDate = filter.replaceDate;
      bool? result;

      result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                width: mediaSize.width - 80,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      filter.id,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: kPrimaryColor),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "필터 모델",
                          style: TextStyle(fontSize: 18, color: kPrimaryColor),
                        ),
                        StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return DropdownButton(
                            value: selectedProduct,
                            items: productProv.productList
                                .map((ProductModel e) => DropdownMenuItem(
                                      child: Text(e.productName),
                                      value: productProv
                                          .getProductIndex(e.productName),
                                    ))
                                .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null &&
                                  selectedProduct != newValue) {
                                setState(() {
                                  selectedProduct = newValue;
                                });
                              }
                            },
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "시작일",
                          style: TextStyle(fontSize: 18, color: kPrimaryColor),
                        ),
                        StatefulBuilder(
                          builder: (context, StateSetter setState) {
                            return Row(
                              children: <Widget>[
                                Text(
                                  "${selectedStartDate ?? "등록 필요"}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: kTextColor.withOpacity(0.7)),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    var temp = await _showDatePicker(context);

                                    setState(() {
                                      selectedStartDate = temp;
                                    });
                                  },
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: kPrimaryColor,
                                    size: 24,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "교체일",
                          style: TextStyle(fontSize: 18, color: kPrimaryColor),
                        ),
                        StatefulBuilder(
                          builder: (context, StateSetter setState) {
                            return Row(
                              children: <Widget>[
                                Text(
                                  "${selectedReplaceDate ?? "등록 필요"}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: kTextColor.withOpacity(0.7)),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    var temp = await _showDatePicker(context);

                                    setState(() {
                                      selectedReplaceDate = temp;
                                    });
                                  },
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: kPrimaryColor,
                                    size: 24,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.all(20),
                      width: mediaSize.width - 160,
                      height: 48,
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Center(
                          child: Text(
                            "저장",
                            style: const TextStyle(
                                color: kBackgroundColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(20),
                      width: mediaSize.width - 160,
                      height: 48,
                      decoration: BoxDecoration(
                          color: kBackgroundColor,
                          border: Border.all(color: kPrimaryColor, width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Center(
                          child: Text(
                            "취소",
                            style: const TextStyle(
                                color: kPrimaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });

      if (result == true) {
        await filterProv.updateFilter(filter.id, filter);
      }
    } catch (e) {
      errorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final FilterListState filterList = context.watch<FilterProvider>().state;

    if (filterList.loading && filterList.filters.length == 0) {
      return Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    if (filterList.filters.length == 0) {
      return Center(
        child: Text(
          "등록된 필터가 없습니다.",
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      children: <Widget>[
        ...filterList.filters.map((FilterModel e) => ListTile(
              onTap: () {
                _editFilter(context, e);
              },
              leading: Text(
                e.productName,
                style: TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
              title: Text(e.id),
              subtitle: Row(
                children: <Widget>[
                  Text(
                    "${e.startDate != null ? DateFormat("yyyy.MM.dd").format(e.startDate!) : "미등록"}",
                    style: TextStyle(color: kPrimaryColor.withOpacity(0.6)),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "${e.replaceDate != null ? DateFormat("yyyy.MM.dd").format(e.replaceDate!) : "미등록"}",
                    style: TextStyle(color: kPrimaryColor.withOpacity(0.6)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

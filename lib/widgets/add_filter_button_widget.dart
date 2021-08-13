import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:eins_manager/constants/color_constant.dart';
import 'package:eins_manager/models/product_model.dart';
import 'package:eins_manager/providers/filter_provider.dart';
import 'package:eins_manager/providers/product_provider.dart';
import 'package:eins_manager/widgets/error_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

class AddFilterButton extends StatelessWidget {
  const AddFilterButton({Key? key}) : super(key: key);

  String _handleTag(NfcTag tag) {
    try {
      final List<int> tempIntList =
          List<int>.from(Ndef.from(tag)?.additionalData["identifier"]);
      String id = "";

      tempIntList.forEach((element) {
        id = id + element.toRadixString(16);
      });

      return id;
    } catch (e) {
      throw "NFC 데이터를 가져올 수 없습니다.";
    }
  }

  Future<void> _enrollFilter(BuildContext context) async {
    final Size mediaSize = MediaQuery.of(context).size;
    final ProductProvider productProv = context.read<ProductProvider>();
    final FilterProvider filterProv = context.read<FilterProvider>();

    try {
      final int productIndex;
      String? id;

      try {
        productIndex = await showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "필터를 선택하여주세요.",
                      style: TextStyle(fontSize: 24, color: kPrimaryColor),
                    ),
                    ...productProv.productList
                        .asMap()
                        .entries
                        .map((MapEntry<int, ProductModel> entry) {
                      int index = entry.key;
                      ProductModel product = entry.value;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        width: mediaSize.width - 40,
                        height: 48,
                        decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(index),
                          child: Center(
                            child: Text(
                              product.productName,
                              style: TextStyle(
                                fontSize: 20,
                                color: kBackgroundColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            });
      } catch (e) {
        throw "필터를 선택하여주세요.";
      }

      if (!(await NfcManager.instance.isAvailable())) {
        if (Platform.isAndroid) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("오류"),
              content: Text(
                "NFC를 지원하지 않는 기기이거나 일시적으로 비활성화 되어 있습니다.",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    AppSettings.openNFCSettings();
                  },
                  child: Text("설정", style: TextStyle(color: kPrimaryColor)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("확인", style: TextStyle(color: kPrimaryColor)),
                ),
              ],
            ),
          );

          return;
        }

        throw "NFC를 지원하지 않는 기기이거나 일시적으로 비활성화 되어 있습니다.";
      }

      try {
        if (Platform.isIOS) {
          await NfcManager.instance.startSession(
            alertMessage: "기기를 필터 가까이에 가져다주세요.",
            onDiscovered: (NfcTag tag) async {
              try {
                id = _handleTag(tag);

                var ndef = Ndef.from(tag);
                if (ndef == null || !ndef.isWritable) {
                  throw "쓰기가 불가능한 NFC 태그 입니다.";
                }

                NdefMessage message = NdefMessage(<NdefRecord>[
                  NdefRecord.createUri(
                      Uri.parse('https://eins.page.link/home')),
                ]);

                await ndef.write(message);
                await NfcManager.instance.stopSession(alertMessage: "완료되었습니다.");
              } catch (e) {
                id = null;

                throw "NFC태그 정보를 불러올 수 없습니다.";
              }
            },
          );
        }

        if (Platform.isAndroid) {
          id = await showDialog(
            context: context,
            builder: (context) =>
                _AndroidSessionDialog("기기를 필터 가까이에 가져다주세요.", _handleTag),
          );
        }
      } catch (e) {
        throw "NFC태그 정보를 불러올 수 없습니다.";
      }

      if (id != null) {
        bool result = true;

        if (await filterProv.isFilterEnrolled(id!)) {
          if (Platform.isIOS) {
            result = await showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text("경고"),
                  content: Text("이미 등록되어있는 필터입니다."),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("취소"),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    CupertinoDialogAction(
                      child: Text("계속"),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            );
          } else {
            result = await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("경고"),
                  content: Text(
                    "이미 등록되어있는 필터입니다.",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text("계속", style: TextStyle(color: kPrimaryColor)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("취소", style: TextStyle(color: kPrimaryColor)),
                    ),
                  ],
                );
              },
            );
          }
        }

        if (result) {
          await filterProv.enrollFilter(
              id!, productProv.productList[productIndex].productName);
        }
      } else {
        throw "NFC태그 id를 확인할 수 없습니다.";
      }
    } catch (e) {
      errorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        _enrollFilter(context);
      },
      child: Container(
        width: mediaSize.width - 40,
        height: 100,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "필터 등록하기",
              style: TextStyle(
                color: kBackgroundColor,
                fontSize: 20,
              ),
            ),
            Icon(
              Icons.add_circle,
              size: 36,
              color: kBackgroundColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _AndroidSessionDialog extends StatefulWidget {
  const _AndroidSessionDialog(this.alertMessage, this.handleTag);

  final String alertMessage;

  final String Function(NfcTag tag) handleTag;

  @override
  State<StatefulWidget> createState() => _AndroidSessionDialogState();
}

class _AndroidSessionDialogState extends State<_AndroidSessionDialog> {
  String? _alertMessage;
  String? _errorMessage;

  String? _result;

  @override
  void initState() {
    super.initState();

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          _result = widget.handleTag(tag);

          var ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            throw "쓰기가 불가능한 NFC 태그 입니다.";
          }

          NdefMessage message = NdefMessage(<NdefRecord>[
            NdefRecord.createUri(Uri.parse('https://eins.page.link/home')),
          ]);

          await ndef.write(message);
          await NfcManager.instance.stopSession();

          setState(() => _alertMessage = "NFC 태그를 인식하였습니다.");
        } catch (e) {
          await NfcManager.instance.stopSession();

          setState(() => _errorMessage = '$e');
        }
      },
    ).catchError((e) => setState(() => _errorMessage = '$e'));
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _errorMessage?.isNotEmpty == true
            ? "오류"
            : _alertMessage?.isNotEmpty == true
                ? "성공"
                : "준비",
      ),
      content: Text(
        _errorMessage?.isNotEmpty == true
            ? _errorMessage!
            : _alertMessage?.isNotEmpty == true
                ? _alertMessage!
                : widget.alertMessage,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
              _errorMessage?.isNotEmpty == true
                  ? "확인"
                  : _alertMessage?.isNotEmpty == true
                      ? "완료"
                      : "취소",
              style: TextStyle(color: kPrimaryColor)),
          onPressed: () => Navigator.of(context).pop(_result),
        ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_manager/constants/db_constants.dart';
import 'package:eins_manager/models/filter_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class FilterListState extends Equatable {
  final bool loading;
  final List<FilterModel> filters;

  FilterListState({
    required this.loading,
    required this.filters,
  });

  FilterListState copyWith({
    bool? loading,
    List<FilterModel>? filters,
  }) {
    return FilterListState(
      loading: loading ?? this.loading,
      filters: filters ?? this.filters,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [loading, filters];
}

class FilterProvider with ChangeNotifier {
  FilterListState state =
      FilterListState(loading: false, filters: <FilterModel>[]);
  bool _hasNextDocs = true;

  bool get hasNextDocs => _hasNextDocs;

  Future<void> getFilters(int limit) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      QuerySnapshot<Map<String, dynamic>> filtersSnapshot;
      DocumentSnapshot<Map<String, dynamic>>? startAfterDoc;

      if (state.filters.isNotEmpty) {
        FilterModel f = state.filters.last;

        startAfterDoc = await filterRef.doc(f.id).get();
      } else {
        startAfterDoc = null;
      }

      if (startAfterDoc == null) {
        filtersSnapshot = await filterRef.limit(limit).get();
      } else {
        filtersSnapshot = await filterRef
            .limit(limit)
            .startAfterDocument(startAfterDoc)
            .get();
      }

      List<FilterModel> filters =
          filtersSnapshot.docs.map((e) => FilterModel.fromDoc(e)).toList();

      if (filtersSnapshot.docs.length < limit) {
        _hasNextDocs = false;
      }

      state = state.copyWith(
          loading: false, filters: <FilterModel>[...state.filters, ...filters]);
      notifyListeners();
    } catch (e) {
      state = state.copyWith(loading: false);
      notifyListeners();

      throw "필터 정보를 불러오지 못 하였습니다.";
    }
  }

  Future<void> updateFilter(String id, FilterModel filter) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      await filtersRef.doc(id).set(filter.toDoc());

      state = state.copyWith(loading: false);
      notifyListeners();
    } catch (e) {
      state = state.copyWith(loading: true);
      notifyListeners();

      throw "필터정보를 업데이트하지 못 하였습니다.";
    }
  }

  Future<void> enrollFilter(String id, String productName) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      await filtersRef.doc(id).set(<String, dynamic>{
        "id": id,
        "product_name": productName,
      });

      state = state.copyWith(loading: false);
      notifyListeners();
    } catch (e) {
      state = state.copyWith(loading: true);
      notifyListeners();

      throw "필터정보를 등록하지 못 하였습니다.";
    }
  }

  Future<bool> isFilterEnrolled(String id) async {
    final DocumentSnapshot filterdoc = await filterRef.doc(id).get();

    return filterdoc.exists;
  }

  int? getFilterIndex(String id) {
    for (int i = 0; i < state.filters.length; i++) {
      if (id == state.filters[i].id) {
        return i;
      }
    }
  }
}

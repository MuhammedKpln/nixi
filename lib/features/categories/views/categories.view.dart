import 'package:auto_route/auto_route.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:nextcloudnotes/core/router/router.gr.dart';
import 'package:nextcloudnotes/core/shared/components/scaffold.component.dart';
import 'package:nextcloudnotes/features/home/controllers/home.controller.dart';
import 'package:nextcloudnotes/models/category.model.dart';

@RoutePage()
// ignore: public_member_api_docs
class CategoriesView extends StatefulWidget {
  // ignore: public_member_api_docs
  const CategoriesView({required this.categories, super.key});

  /// `final List<CategoryModel> categories;` is declaring a final variable named `categories` of type
  /// `List<CategoryModel>`. This variable is used to store a list of `CategoryModel` objects that will be
  /// passed as a parameter to the `CategoriesView` widget. The `CategoriesView` widget will then use this
  /// list to display a list of categories in a `ListView.builder` widget.
  final List<CategoryModel> categories;

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  void navigateToPosts(String label) {
    isViewingCategoryPosts.value = true;
    context.router.push(HomeRoute(byCategoryName: label));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          return ListTile(
            title: Text(category.label),
            leading: const Icon(EvaIcons.folderOutline),
            onTap: () => navigateToPosts(category.label),
          );
        },
        itemCount: widget.categories.length,
      ),
    );
  }
}

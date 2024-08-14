import 'package:album_image/src/controller/gallery_provider.dart';
import 'package:album_image/src/customization/album_picker_style.dart';
import 'package:album_image/src/widgets/app_bar_album.dart';
import 'package:album_image/src/widgets/gallery_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'enum/album_type.dart';

typedef SelectionWidgetBuilder = Widget Function(
    BuildContext context, bool selected, int index);

class AlbumImagePicker extends StatefulWidget {
  /// album picker style
  final AlbumPickerStyle albumPickerStyle;

  /// maximum images allowed (default 1)
  final int maxSelection;

  /// return all selected images
  final Function(List<AssetEntity>)? onSelected;

  /// preSelected images
  final List<AssetEntity>? selected;

  /// The album type when requesting paths.
  ///
  ///  * [all] - Request paths that return images and videos.
  ///  * [image] - Request paths that only return images.
  ///  * [video] - Request paths that only return videos.
  final AlbumPickerType type;

  /// image quality thumbnail
  final int thumbnailQuality;

  /// On reach max
  final VoidCallback? onSelectedMax;

  /// thumbnail box fit
  final BoxFit thumbnailBoxFix;

  /// gridview crossAxisCount
  final int crossAxisCount;

  /// gallery gridview aspect ratio
  final double childAspectRatio;

  /// gridView Padding
  final EdgeInsets gridPadding;

  /// gridView physics
  final ScrollPhysics? scrollPhysics;

  /// gridView controller
  final ScrollController? scrollController;

  ///Icon widget builder
  ///index = -1, not selected yet
  final SelectionWidgetBuilder? selectionBuilder;

  ///Close widget
  final Widget? closeWidget;

  ///appBar actions widgets
  final List<Widget>? appBarActionWidgets;

  final ValueChanged<List<AssetEntity>> onDone;

  final bool centerTitle;

  final Widget? emptyAlbumThumbnail;

  final String? trailingText;

  const AlbumImagePicker(
      {Key? key,
      this.albumPickerStyle = const AlbumPickerStyle(),
      this.maxSelection = 1,
      this.onSelected,
      this.selected,
      this.type = AlbumPickerType.all,
      this.thumbnailBoxFix = BoxFit.cover,
      this.crossAxisCount = 3,
      this.childAspectRatio = 1.0,
      this.thumbnailQuality = 200,
      this.gridPadding = EdgeInsets.zero,
      this.centerTitle = true,
      this.appBarActionWidgets,
      this.closeWidget,
      this.selectionBuilder,
      this.scrollPhysics,
      this.scrollController,
      this.onSelectedMax,
      required this.onDone,
      this.emptyAlbumThumbnail,
      this.trailingText = "Done"})
      : super(key: key);

  @override
  _AlbumImagePickerState createState() => _AlbumImagePickerState();
}

class _AlbumImagePickerState extends State<AlbumImagePicker>
    with AutomaticKeepAliveClientMixin {
  /// create object of PickerDataProvider
  late PickerDataProvider provider;

  @override
  void initState() {
    _initProvider();
    _getPermission();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AlbumImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.maxSelection != widget.maxSelection) {
      provider.max = widget.maxSelection;
    }
    if (oldWidget.type != widget.type) {
      _refreshPathList();
    }
  }

  void _initProvider() {
    provider = PickerDataProvider(
        picked: widget.selected ?? [], maxSelectionCount: widget.maxSelection);
    provider.onPickMax.addListener(onPickMax);
  }

  void _getPermission() async {
    var result = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
            iosAccessLevel: IosAccessLevel.readWrite));
    if (result == PermissionState.authorized ||
        result == PermissionState.limited) {
      PhotoManager.startChangeNotify();
      PhotoManager.addChangeCallback((value) {
        _refreshPathList();
      });

      if (provider.pathList.isEmpty) {
        _refreshPathList();
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  void _refreshPathList() {
    late RequestType type;
    switch (widget.type) {
      case AlbumPickerType.all:
        type = RequestType.common;
        break;
      case AlbumPickerType.image:
        type = RequestType.image;
        break;
      case AlbumPickerType.video:
        type = RequestType.video;
        break;
    }
    PhotoManager.getAssetPathList(type: type).then((pathList) {
      /// don't delete setState
      setState(() {
        provider.resetPathList(pathList);
      });
    });
  }

  void onPickMax() {
    widget.onSelectedMax?.call();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        /// album drop down
        AppBarAlbum(
          provider: provider,
          albumDividerColor: widget.albumPickerStyle.albumDividerColor,
          albumBackGroundColor: widget.albumPickerStyle.albumBackGroundColor,
          appBarColor: widget.albumPickerStyle.appBarColor,
          albumTextStyle: widget.albumPickerStyle.albumTextStyle,
          albumHeaderTextStyle: widget.albumPickerStyle.albumHeaderTextStyle,
          albumSubTextStyle: widget.albumPickerStyle.albumSubTextStyle,
          height: widget.albumPickerStyle.appBarHeight,
          appBarLeadingWidget: widget.closeWidget,
          appBarActionWidgets: widget.appBarActionWidgets,
          onDone: widget.onDone,
          centerTitle: widget.centerTitle,
          emptyAlbumThumbnail: widget.emptyAlbumThumbnail,
          trailingText: widget.trailingText,
          trailingTextStyle: widget.albumPickerStyle.trailingTextStyle,
          albumPickerDropdownStyle:
              widget.albumPickerStyle.albumPickerDropdownStyle,
          isSingle: widget.maxSelection == 1,
        ),

        /// grid image view
        Expanded(
          child: ValueListenableBuilder<AssetPathEntity?>(
            valueListenable: provider.currentPathNotifier,
            builder: (context, currentPath, child) => currentPath != null
                ? GalleryGridView(
                    path: currentPath,
                    thumbnailQuality: widget.thumbnailQuality,
                    provider: provider,
                    padding: widget.gridPadding,
                    childAspectRatio: widget.childAspectRatio,
                    crossAxisCount: widget.crossAxisCount,
                    gridViewBackgroundColor:
                        widget.albumPickerStyle.listBackgroundColor,
                    gridViewController: widget.scrollController,
                    gridViewPhysics: widget.scrollPhysics,
                    imageBackgroundColor:
                        widget.albumPickerStyle.itemBackgroundColor,
                    selectedBackgroundColor:
                        widget.albumPickerStyle.selectedItemBackgroundColor,
                    selectionBuilder: widget.selectionBuilder,
                    thumbnailBoxFix: widget.thumbnailBoxFix,
                    selectedCheckBackgroundColor:
                        widget.albumPickerStyle.selectedItemBackgroundColor,
                    onAssetItemClick: (ctx, asset, index) async {
                      provider.pickEntity(asset);
                      // widget.onSelected(provider.picked);
                    },
                  )
                : Container(),
          ),
        )
      ],
    );
  }

  Widget _defaultCloseWidget() {
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Text('Cancel'));
  }

  @override
  bool get wantKeepAlive => true;
}

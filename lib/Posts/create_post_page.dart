import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';

import 'package:social_media_template/colors.dart';

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: colorBackground,
        body: CreatePostSection(),
      ),
    );
  }
}

class CreatePostSection extends StatefulWidget {
  CreatePostSection({Key? key}) : super(key: key);

  @override
  State<CreatePostSection> createState() => _CreatePostSectionState();
}

class _CreatePostSectionState extends State<CreatePostSection> {
  List<Album>? _albums;
  bool loading = false;
  List<DropdownMenuItem<Album>> dropDownItems = [];
  Album? currentAlbum;

  @override
  void initState() {
    super.initState();
    loading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    if (await _promptPermission()) {
      List<Album> albums =
          await PhotoGallery.listAlbums(mediumType: MediumType.image);

      setState(() {
        _albums = albums;
        currentAlbum = albums[0];
        for (Album album in albums) {
          dropDownItems.add(DropdownMenuItem(
            child: Text(album.name.toString()),
            value: album,
          ));
        }
        loading = false;
      });
    }
    setState(() {
      loading = false;
    });
  }

  Future<bool> _promptPermission() async {
    if (Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<List<Medium>> getMediaPage(Album album) async {
    MediaPage imagepage = await album.listMedia();
    return imagepage.items.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? CircularProgressIndicator()
        : Column(
            children: [
              Expanded(
                child: DropdownButton(
                  
                    style: TextStyle(fontSize: 2),
                    value: currentAlbum,
                    items: dropDownItems,
                    onChanged: (Album? value) {
                      setState(() {
                        currentAlbum = value;
                      });
                    }),
              ),
              FutureBuilder(
                future: getMediaPage(currentAlbum!),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error"),
                      );
                    } else if (snapshot.hasData) {
                      return MediaGrid(
                          mediumList: snapshot.data as List<Medium>);
                    }
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }),
              ),
            ],
          );
  }
}

class MediaGrid extends StatefulWidget {
  MediaGrid({Key? key, required this.mediumList}) : super(key: key);
  List<Medium> mediumList;

  @override
  State<MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        shrinkWrap: false,
        crossAxisCount: 4,
        children: List.generate(widget.mediumList.length, (index) {
          return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ThumbnailProvider(
                          highQuality: true,
                          mediumId: widget.mediumList[index].id),
                      fit: BoxFit.cover)));
        }),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:sqflite_upload_file/sqlite_db.dart';

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite_upload_file/model/foto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Upload File',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: 'Galeri'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController judulController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();

  List<Map<String, dynamic>> catatan = [];

  void refreshData() async {
    final data = await DatabaseHelper.getFoto(); //database Foto

    setState(() {
      catatan = data;
    });
  }

  @override
  void initState() {
    refreshData();
    super.initState();
  }

  String? photoprofile;
  Future<String> getFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'png',
        'webm',
      ],
    );
    
    if (result != null) {
      PlatformFile sourceFile = result.files.first;
      final destination = await getExternalStorageDirectory();
      File? destinationFile =
          File('${destination!.path}/${sourceFile.name.hashCode}');
      final newFile =
         File(sourceFile.path!).copy(destinationFile.path.toString());
      setState(() {
        photoprofile = destinationFile.path;
      });
      File(sourceFile.path!.toString()).delete();
      return destinationFile.path;
    } else {
      return "Dokumen belum diupload";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: catatan.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: catatan[index]['judul'] != ''
                ? Image.file(File(catatan[index]['photo']),
                    width: 40, height: 40)
                : FlutterLogo(),
            title: Text(catatan[index]['judul']),
            subtitle: Text(catatan[index]['deskripsi']),
            trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Form(catatan[index]['id']);
                        },
                        icon: const Icon(Icons.edit)),
                    IconButton(
                        onPressed: () {
                          hapusFoto(catatan[index]['id']);
                        },
                        icon: const Icon(Icons.delete)),
                    ],
                  )),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Form(null);
        },
        tooltip: 'Tambah Data',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void Form(id) async {
    if (id != null) {
      final dataupdate = catatan.firstWhere((element) => element['id'] == id);
      judulController.text = dataupdate['judul'];
      deskripsiController.text = dataupdate['deskripsi'];
    }
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            height: 800,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: judulController,
                    decoration: const InputDecoration(hintText: "Judul"),
                  ),
                  TextField(
                    controller: deskripsiController,
                    decoration: const InputDecoration(hintText: "Deskripsi"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        getFilePicker();
                      },
                      child: Row(
                        children: const [
                          Text("Pilih Gambar"),
                          Icon(Icons.camera)
                        ],
                      )),
                  ElevatedButton(
                      onPressed: () async {
                        if (id != null) {
                          String? photo = photoprofile;
                          final data = Foto(
                              id: id,
                              judul: judulController.text,
                              deskripsi: deskripsiController.text,
                              photo: photo.toString());
                          updateFoto(data);
                          judulController.text = '';
                          deskripsiController.text = '';
                          Navigator.pop(context);
                        } else {
                          String? photo = photoprofile;
                          final data = Foto(
                              judul: judulController.text,
                              deskripsi: deskripsiController.text,
                              photo: photo.toString());
                          tambahFoto(data);
                          judulController.text = '';
                          deskripsiController.text = '';
                          Navigator.pop(context);
                        }
                      },
                      child: Text(id == null ? "Tambah" : 'update'))
                ],
              ),
            ),
          );
        });
  }

  Future<void> tambahFoto(Foto foto) async {
    await DatabaseHelper.tambahFoto(foto);
    return refreshData();
  }

  Future<void> updateFoto(Foto foto) async {
    await DatabaseHelper.updateFoto(foto);
    return refreshData();
  }

  Future<void> hapusFoto(int id) async {
    await DatabaseHelper.deleteFoto(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Berhasil Dihapus")));
    return refreshData();
  }
}

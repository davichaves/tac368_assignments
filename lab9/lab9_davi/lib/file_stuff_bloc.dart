// file_stuff_bloc.dart
// Barrett Koster
// This demos some basic file io in flutter.
// Uses BlocProvider for state.

import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart"; // flutter pub add flutter_bloc
import "package:path_provider/path_provider.dart"; // flutter pub add path_provider
// cd to the project directory
// > flutter pub add path_provider

class BufState
{ String text;
  bool loaded;

  BufState( this.text, this.loaded );
}

class BufCubit extends Cubit<BufState>
{
  BufCubit() : super( BufState("nothing,still nothing", false) );

  void update(String s) { emit( BufState(s,true) ); }

  void add(String s ) { emit( BufState("${state.text},$s",true) ); }
}

void main() 
{ runApp( FileStuff () );
}

class FileStuff extends StatelessWidget
{
  FileStuff({super.key});

  Widget build( BuildContext context )
  { return MaterialApp
    ( title: "file stuff - barrett",
      home: BlocProvider<BufCubit>
      ( create: (context) => BufCubit(),
        child: BlocBuilder<BufCubit,BufState>
        ( builder: (context,state) => FileStuff2(),
        ),
      ),
    );
  }
}

class FileStuff2 extends StatelessWidget
{
  FileStuff2({super.key});

  @override
  Widget build( BuildContext context ) 
  { BufCubit bc = BlocProvider.of<BufCubit>(context);
    BufState bs = bc.state;

    TextEditingController tec = TextEditingController();
    // tec.text = bs.loaded ? bs.text : "not loaded yet";

    // Future<String> contents = readFile();
    // writeFile("hi there");
    return Scaffold
    ( appBar: AppBar( title: Text("file stuff - barrett") ),
      body: Column
      ( children:
        [ // box to show contents of the BufState
          makeListView(bs.text),

          // place to type stuff
          Row
          ( children:
            [ Text("type here: "),
              Container
              ( height: 50, width: 500,
                decoration: BoxDecoration( border: Border.all(width:2) ),
                child: TextField
                (controller:tec, style: TextStyle(fontSize:20) ),
              ),
            ],
          ),

          // row of buttons
          Row
          ( children:
            [
              // shows where is the current directory
              FloatingActionButton
              ( onPressed: (){ whereAmI().then( (String c) { bc.add(c); }); },
                child: Text("where", style:TextStyle(fontSize:20)),
              ),

              // add the typed text to the list
              FloatingActionButton
              ( onPressed: (){ bc.add(tec.text); },
                child: Text("add", style:TextStyle(fontSize:20)),
              ),

              // clear the list
              FloatingActionButton
              ( onPressed: (){ bc.update(""); },
                child: Text("clr", style:TextStyle(fontSize:20)),
              ),

              // loads from the file
              FloatingActionButton 
              ( onPressed: () async
                { String contents = await readFile(); 
                  bc.update(contents);
                },
                child: Text("load", style:TextStyle(fontSize:20)),
              ),
            
              // saves to the file
              FloatingActionButton
              ( onPressed: (){ writeFile(bs.text); },
                child: Text("write", style:TextStyle(fontSize:20)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // splits the string by commas to make a list of kids (Text objects), 
  // shows the kids in a vertical ListView widget in a Container with a 
  // border.
  Widget makeListView( String theString )
  { List<String> items =  theString.split(",");
    List<Widget> kids = [];
    for ( String s in items )
    { kids.add(Text(s)); }
    return Container
    ( height:300, width:700,
      decoration: BoxDecoration( border:Border.all(width:1)),
      child: ListView 
      ( scrollDirection: Axis.vertical,
        itemExtent: 30,
        children: kids,
      ),
    );
  }

  // 
  Future<String> whereAmI() async
  {
    Directory mainDir = await getApplicationDocumentsDirectory();
    String mainDirPath = mainDir.path;
    // String mainDirPath = "/Users/bkoster/Documents/courses/USC/368/shared";
    print("mainDirPath is $mainDirPath");
    return mainDirPath;
  }
  
  Future<String> readFile() async
  { await Future.delayed( const Duration(seconds:2) ); // adds drama
    String myStuff = await whereAmI();
    String filePath = "$myStuff/stuff.txt";
    File fodder = File(filePath);
    String contents = fodder.readAsStringSync();
    print("-------------in readFile ...");
    print(contents);
    return contents;
  }

  Future<void> writeFile( String writeMe) async
  { String myStuff = await whereAmI();
    String filePath = "$myStuff/stuff.txt";
    print("about to write to $filePath");
    File fodder = File(filePath);
    fodder.writeAsStringSync( writeMe );
  }
}
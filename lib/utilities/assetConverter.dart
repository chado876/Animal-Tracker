//   Card(
//                       margin: EdgeInsets.all(8.0),
//             clipBehavior: Clip.antiAlias,
//             child: SingleChildScrollView( child: Column(
//               children: [
//                 ListTile(
//                   leading: Icon(Icons.arrow_drop_down_circle),
//                   title: Text(livestock[index]['tagId']),
//                   subtitle: livestock[index]['isMissing']
//                             ? Text(
//                                 "Missing",
//                                 style: TextStyle(
//                                   color: Colors.red,
//                                   fontSize: 20,
//                                 ),
//                               )
//                             : Text(
//                                 "Safe",
//                                 style: TextStyle(
//                                   color: Colors.green,
//                                   fontSize: 20,
//                                 ),
//                               ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'Greyhound divisively hello coldly wonderfully marginally far upon excluding.',
//                     style: TextStyle(color: Colors.black.withOpacity(0.6)),
//                   ),
//                 ),
//                 ButtonBar(
//                   alignment: MainAxisAlignment.start,
//                   children: [
//                     FlatButton(
//                       textColor: const Color(0xFF6200EE),
//                       onPressed: () {
//                         // Perform some action
//                       },
//                       child: const Text('ACTION 1'),
//                     ),
//                     FlatButton(
//                       textColor: const Color(0xFF6200EE),
//                       onPressed: () {
//                         // Perform some action
//                       },
//                       child: const Text('ACTION 2'),
//                     ),
//                   ],
//                 ),
// Image.network(
//                               livestock[index]['image_urls']
//                                   [0], //this needs to be fixed (null checking)
//                               height: 300,
//                               width: 300),              ],
//             ),),

//           ),

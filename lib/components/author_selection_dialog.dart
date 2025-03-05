// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:dharmic/services/isar_service.dart';
// import 'package:dharmic/models/author.dart';

// class AuthorSelectionDialog extends StatefulWidget {
//   const AuthorSelectionDialog({Key? key}) : super(key: key);

//   @override
//   State<AuthorSelectionDialog> createState() => _AuthorSelectionDialogState();
// }

// class _AuthorSelectionDialogState extends State<AuthorSelectionDialog> {
//   Map<String, bool> tempSelections = {};
//   List<Author>? authorsList;

//   @override
//   void initState() {
//     super.initState();
//     _loadAuthors();
//   }

//   Future<void> _loadAuthors() async {
//     final isarService = Provider.of<IsarService>(context, listen: false);
//     final authors = await isarService.fetchAllAuthors();
//     setState(() {
//       authorsList = authors;
//       tempSelections = {
//         for (var author in authors) author.name: author.isSelected
//       };
//     });
//   }

//   Future<void> _saveChanges() async {
//     final isarService = Provider.of<IsarService>(context, listen: false);
//     await isarService.updateAuthorsSelection(tempSelections);
//     if (mounted) Navigator.pop(context, true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       backgroundColor: const Color(0xFF202020),
//       child: authorsList == null
//           ? SizedBox(
//               height: 200,
//               child: Center(child: CircularProgressIndicator()),
//             )
//           : Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Select Authors',
//                         style: GoogleFonts.roboto(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Choose the authors whose quotes you want to see',
//                         style: GoogleFonts.roboto(
//                           fontSize: 14,
//                           color: Colors.grey[400],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Author List
//                 Container(
//                   constraints: BoxConstraints(
//                     maxHeight: MediaQuery.of(context).size.height * 0.5,
//                   ),
//                   margin: const EdgeInsets.symmetric(vertical: 16),
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: authorsList!.length,
//                     itemBuilder: (context, index) {
//                       final author = authorsList![index];
//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage: AssetImage(author.image),
//                         ),
//                         title: Text(
//                           author.name,
//                           style: GoogleFonts.roboto(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                         subtitle: Text(
//                           author.title,
//                           style: GoogleFonts.roboto(
//                             color: Colors.grey[500],
//                             fontSize: 12,
//                           ),
//                         ),
//                         trailing: Checkbox(
//                           value: tempSelections[author.name] ?? true,
//                           onChanged: (bool? value) {
//                             if (value != null) {
//                               setState(() {
//                                 tempSelections[author.name] = value;
//                               });
//                             }
//                           },
//                           activeColor: const Color(0xFFfa5620),
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 // Action Buttons
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context, false),
//                         child: Text(
//                           'Cancel',
//                           style: GoogleFonts.roboto(
//                             color: Colors.grey[400],
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       ElevatedButton(
//                         onPressed: _saveChanges,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFfa5620),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text(
//                           'Save',
//                           style: GoogleFonts.roboto(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
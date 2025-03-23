import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class RoomListPage extends StatefulWidget {
  final int actId;
  final Client client;

  const RoomListPage({Key? key, required this.actId, required this.client})
    : super(key: key);

  @override
  _RoomListPageState createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  late Databases databases;
  List<dynamic> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    databases = Databases(widget.client);
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentList result = await databases.listDocuments(
        databaseId: '67d260270026140252d0',
        collectionId: '67d260970028e350b3c7',
      );

      setState(() {
        rooms = result.documents;
        isLoading = false;
      });
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching rooms: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _createRoom(
    String roomId,
    String roomName,
    String description,
  ) async {
    if (roomId.trim().isEmpty ||
        roomName.trim().isEmpty ||
        description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room ID, Name, and Description cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await databases.createDocument(
        databaseId: '67d260270026140252d0',
        collectionId: '67d260970028e350b3c7',
        documentId: 'unique()', // Use Appwrite's unique() for document ID.
        data: {
          'RoomID': roomId.trim(), // Use the entered room ID as an attribute.
          'RoomName': roomName.trim(),
          'desc': description.trim(),
          'ActID': widget.actId,
        },
      );

      _fetchRooms(); // Refresh the room list after creation.
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating room: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCreateRoomDialog() {
    final TextEditingController roomIdController =
        TextEditingController(); // Input for Room ID.
    final TextEditingController roomNameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create a Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomIdController,
                decoration: const InputDecoration(
                  labelText: 'Room ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roomNameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // Allow multi-line input for description.
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog.
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final roomId = roomIdController.text;
                final roomName = roomNameController.text;
                final description = descriptionController.text;

                _createRoom(roomId, roomName, description);
                Navigator.of(context).pop(); // Close the dialog after creation.
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rooms for ${widget.actId}")),
      body: Column(
        children: [
          // Button to open the dialog for creating a new room.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _showCreateRoomDialog,
                  child: const Text('Create Room'),
                ),
              ],
            ),
          ),
          // Room list or empty message.
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : rooms.isEmpty
                    ? const Center(
                      child: Text(
                        'No rooms available. Create a room to get started!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];

                        // Safely access the fields with null-checks and provide default values.
                        final roomId = room.data['RoomID'] ?? 'Unknown ID';
                        final roomName =
                            room.data['RoomName'] ?? 'Unnamed Room';
                        final description =
                            room.data['desc'] ?? 'No Description';

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(roomName),
                            subtitle: Text('ID: $roomId - $description'),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Joining $roomName")),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

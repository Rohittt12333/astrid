import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'room_list_page.dart';

class ActivitiesAndGamesPage extends StatefulWidget {
  final Client client;

  const ActivitiesAndGamesPage({Key? key, required this.client})
    : super(key: key);

  @override
  _ActivitiesAndGamesPageState createState() => _ActivitiesAndGamesPageState();
}

class _ActivitiesAndGamesPageState extends State<ActivitiesAndGamesPage>
    with SingleTickerProviderStateMixin {
  late Databases databases;
  late TabController _tabController;
  List<dynamic> activities = []; // ActType 1: Activities
  List<dynamic> games = []; // ActType 2: Games
  bool isLoadingActivities = true;
  bool isLoadingGames = true;

  @override
  void initState() {
    super.initState();
    databases = Databases(widget.client);
    _tabController = TabController(length: 2, vsync: this);
    _fetchItems(); // Fetch activities and games
  }

  Future<void> _fetchItems() async {
    try {
      // Fetch activities (ActType = 1)
      final activitiesResult = await databases.listDocuments(
        databaseId: '67d260270026140252d0', // Replace with your database ID
        collectionId: '67d26553002432036396', // Replace with your collection ID
        queries: [Query.equal('ActType', 1)],
      );

      // Fetch games (ActType = 2)
      final gamesResult = await databases.listDocuments(
        databaseId: '67d260270026140252d0', // Replace with your database ID
        collectionId: '67d26553002432036396', // Replace with your collection ID
        queries: [Query.equal('ActType', 2)],
      );

      setState(() {
        activities = activitiesResult.documents;
        games = gamesResult.documents;
        isLoadingActivities = false;
        isLoadingGames = false;
      });
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching items: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoadingActivities = false;
        isLoadingGames = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities and Games'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Activities'), Tab(text: 'Games')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Activities Tab
          isLoadingActivities
              ? const Center(child: CircularProgressIndicator())
              : activities.isEmpty
              ? const Center(
                child: Text(
                  'No activities available.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  final activityName =
                      activity.data['ActName'] ?? 'Unknown Activity';
                  final activityId = activity.data['ActID'] ?? 'N/A';

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(activityName),
                      subtitle: Text('ID: $activityId'),
                      onTap: () {
                        // Navigate to RoomListPage for the selected activity
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RoomListPage(
                                  actId: activityId,
                                  client: widget.client,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          // Games Tab
          isLoadingGames
              ? const Center(child: CircularProgressIndicator())
              : games.isEmpty
              ? const Center(
                child: Text(
                  'No games available.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  final gameName = game.data['ActName'] ?? 'Unknown Activity';
                  final gameId = game.data['ActID'] ?? 'N/A';
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(gameName),
                      subtitle: Text('ID: $gameId'),
                      onTap: () {
                        // Navigate to RoomListPage for the selected game
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RoomListPage(
                                  actId: gameId,
                                  client: widget.client,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
}

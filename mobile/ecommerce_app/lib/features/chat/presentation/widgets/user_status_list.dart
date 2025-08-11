import 'package:flutter/material.dart';

class UserStatusList extends StatelessWidget {
  const UserStatusList({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      {'name': 'My status', 'image': 'user7.png'},
      {'name': 'Adil', 'image': 'user8.png'},
      {'name': 'Marina', 'image': 'user9.png'},
      {'name': 'Dean', 'image': 'user7.png'},
      {'name': 'Max', 'image': 'user8.png'},
      {'name': 'Hana', 'image': 'user9.png'},
    ];

    return Container(
      // ↑↑ Important: make header tall enough so chips don’t overflow
      height: 120,
      child: SafeArea(
        bottom: false,
        child: ListView.separated(
          clipBehavior: Clip.none, // allow dots to spill safely
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final isMe = users[i]['name'] == 'My status';
            return _StoryChip(
              label: users[i]['name'] as String,
              image: users[i]['image'] as String,
              isMe: isMe,
            );
          },
        ),
      ),
    );
  }
}

class _StoryChip extends StatelessWidget {
  final String label;
  final String image;
  final bool isMe;
  const _StoryChip({
    required this.label,
    required this.image,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // don’t force full height
      children: [
        // Avatar with a soft ring
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: isMe
                ? const LinearGradient(colors: [Colors.white, Colors.white])
                : const LinearGradient(
                    colors: [Color(0xFF7DD3FC), Color(0xFF4F46E5)]),
            shape: BoxShape.circle,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/$image',
                  width: 56, // avatar size
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: isMe
                    ? Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4E5BF1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.add,
                            size: 12, color: Colors.white),
                      )
                    : Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 72,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

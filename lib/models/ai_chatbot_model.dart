import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Message {
  final bool isUser;
  final String message;
  final DateTime date;
  final String? profileImageUrl;

  Message({
    required this.isUser,
    required this.message,
    required this.date,
    this.profileImageUrl,
  });
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final DateTime date;
  final String? profileImageUrl;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('hh:mm a').format(date);

    TextSpan parseMessage(String text) {
      final List<InlineSpan> spans = [];
      final RegExp boldRegex = RegExp(r'\*(.*?)\*');
      int startIndex = 0;

      for (final match in boldRegex.allMatches(text)) {
        if (match.start > startIndex) {
          spans.add(
            TextSpan(
              text: text.substring(startIndex, match.start),
              style: TextStyle(
                fontSize: 16,
                color: isUser ? Colors.white : Colors.black,
              ),
            ),
          );
        }

        spans.add(
          TextSpan(
            text: match.group(1),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isUser ? Colors.white : Colors.black,
            ),
          ),
        );

        startIndex = match.end;
      }

      if (startIndex < text.length) {
        spans.add(
          TextSpan(
            text: text.substring(startIndex),
            style: TextStyle(
              fontSize: 16,
              color: isUser ? Colors.white : Colors.black,
            ),
          ),
        );
      }

      return TextSpan(children: spans);
    }

    final messageBubble = Container(
      constraints: BoxConstraints(
        maxWidth: isUser
            ? MediaQuery.of(context).size.width * 0.7
            : double.infinity,
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 8),

      decoration: BoxDecoration(
        color: isUser ? null : Colors.white,
        gradient: isUser
            ? LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: message));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Copied to clipboard"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: SelectableText.rich(parseMessage(message)),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              formattedTime,
              style: TextStyle(
                fontSize: 10,
                color: isUser ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );

    if (isUser && profileImageUrl != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CircleAvatar(
                radius: 24,
                backgroundImage:
                    (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                    ? NetworkImage(profileImageUrl!)
                    : const AssetImage('assets/images/default_profile.png')
                          as ImageProvider,
              ),
            ),

            const SizedBox(width: 7),
            messageBubble,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(alignment: Alignment.centerLeft, child: messageBubble),
    );
  }
}

class LoadingIndicator extends StatefulWidget {
  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedDot(Colors.deepPurple.shade500, 0),
              SizedBox(width: 0.5),
              _buildAnimatedDot(Colors.blue.shade500, 1),
              SizedBox(width: 0.5),
              _buildAnimatedDot(Colors.deepPurple.shade500, 2),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedDot(Color color, int index) {
    return Transform.translate(
      offset: Offset(
        0,
        -10 * (_animation.value - 0.5).abs() * 2,
      ), // Moves dots up and down
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: Color.lerp(
            color,
            Colors.white,
            _animation.value,
          ), 
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

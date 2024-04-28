import 'package:flutter/material.dart';
import 'package:instagram_app/utils/colors.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final snap;

  const CommentCard({
    super.key,
    required this.snap
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              widget.snap['profImage']
            ),
          ),
          const SizedBox(
            width: 10
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${widget.snap['username']}  ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      TextSpan(
                        text: '${widget.snap['comment']}',
                      ),
                    ]
                  )
                ),
              ),
              Text(
                DateFormat.yMMMd().format(
                  widget.snap['date'].toDate()
                ),
                style: const TextStyle(
                  color: secondaryColor,
                ),
              ),
            ]
          ),
          Flexible(child: Container()),
          const SizedBox(
            width: 10
          ),
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.favorite_border, size: 20,),
          )
        ],
      ),
    );
  }
}
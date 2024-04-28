import 'package:flutter/material.dart';

class LikeAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;
  final bool isSmallLike;

  const LikeAnimation({
    super.key, 
    required this.isAnimating, 
    required this.child, 
    this.duration = const Duration(milliseconds: 150), 
    this.onEnd, 
    this.isSmallLike = false,
  });

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this, 
      duration: Duration(
        milliseconds: widget.duration.inMilliseconds ~/ 2 // This syntax will divide millisec by 2 
                                                          // and converts to int
      )
    );
    scale = Tween<double>(begin: 1.0, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget){
    super.didUpdateWidget(oldWidget);

    if(widget.isAnimating != oldWidget.isAnimating){
      startAnimation();
    }
  }

  startAnimation() async{
    if(widget.isAnimating || widget.isSmallLike){
      await controller.forward();
      await controller.reverse();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if(widget.onEnd != null){
      widget.onEnd!();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }
}
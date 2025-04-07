import 'package:flutter/material.dart';

extension ShakeAnimation on Widget {
  Widget withShakeAnimation(AnimationController animationController) {
    Animation<double> shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1), 
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1), 
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1), 
      TweenSequenceItem(
          tween: Tween(begin: -10, end: 0), weight: 1), 
    ]).animate(animationController);

    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(shakeAnimation.value, 0), 
          child: this,
        );
      },
    );
  }
}

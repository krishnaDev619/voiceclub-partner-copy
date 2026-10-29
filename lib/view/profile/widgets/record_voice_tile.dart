import 'package:flutter/material.dart';

class RecordVoiceTile extends StatelessWidget {
  final String title;
  final Widget subtitle;
  final IconData icon;
  final void Function()? onTap;
  const RecordVoiceTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48.0,
        height: 48.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color(0xFFECECEC),
        ),
        child: Icon(icon, color: Colors.black),
      ),
      dense: true,
      title: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Text(
          title,
          textAlign: TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      subtitle: subtitle,
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 20.0,
        color: Colors.black,
      ),
    );
  }
}

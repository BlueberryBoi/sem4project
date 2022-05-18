import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const SearchBar({
    required this.autoFocus,
    required this.showIcon,
    required this.onIconPressed,
    required this.onTap,
    required this.onChanged,
    required this.icon,
  });

  final bool autoFocus;
  final bool showIcon;
  final Function() onIconPressed;
  final Function() onTap;
  final Function(String) onChanged;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          flex: 4,
          child: TextField(
            keyboardType: TextInputType.name,
            autofocus: autoFocus,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.grey.shade200,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            onChanged: onChanged,
            onTap: onTap,
          ),
        ),
        if (showIcon)
          Flexible(
            child: Container(
              width: 60.0,
              height: 55.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.grey.shade200,
              ),
              child: icon == null
                  ? IconButton(
                      splashColor: Colors.grey.shade200,
                      color: Colors.grey.shade500,
                      icon: const Icon(Icons.person_add_alt),
                      onPressed: onIconPressed,
                    )
                  : icon,
            ),
          ),
      ],
    );
  }
}

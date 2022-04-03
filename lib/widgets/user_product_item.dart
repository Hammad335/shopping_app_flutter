import 'package:flutter/material.dart';
import 'package:shopping_app/providers/products.dart';
import 'package:shopping_app/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem(
      {required this.id, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(title),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
            ),
            DeleteIconWidget(id: id),
          ],
        ),
      ),
    );
  }
}

class DeleteIconWidget extends StatefulWidget {
  const DeleteIconWidget({
    Key? key,
    required this.id,
  }) : super(key: key);

  final String id;

  @override
  State<DeleteIconWidget> createState() => _DeleteIconWidgetState();
}

class _DeleteIconWidgetState extends State<DeleteIconWidget> {
  var _shouldDelete = false;
  var _deletingProductId = '';
  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return IconButton(
      icon: _shouldDelete && _deletingProductId == widget.id
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            )
          : const Icon(Icons.delete),
      color: Theme.of(context).errorColor,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content:
                const Text('Do you want to remove the product from the list? '),
            actions: <Widget>[
              TextButton(
                child: const Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text('YES'),
                onPressed: () async {
                  Navigator.of(context).pop(false);
                  setState(() {
                    _deletingProductId = widget.id;
                    _shouldDelete = true;
                  });
                  try {
                    await Provider.of<Products>(context, listen: false)
                        .deleteProduct(widget.id);
                  } catch (exception) {
                    setState(() {
                      _shouldDelete = false;
                    });
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(exception.toString()),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shopping_app/providers/product.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'edit_product_screen';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String;
      if (productId.isNotEmpty) {
        _editedProduct =
            Provider.of<Products>(context).getProductById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: value!,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            isFavorite: _editedProduct.isFavorite);
                      },
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Please provide a title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_descFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(value!),
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Please provide a price';
                        }
                        if (value != null &&
                            (double.tryParse(value) == null ||
                                double.parse(value) <= 0)) {
                          return 'Please enter valid price';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descFocusNode,
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: value!,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Please provide a description';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value!,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter image url';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter valid image url';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, left: 30),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Image URL')
                              : FittedBox(
                                  fit: BoxFit.fill,
                                  child: Image.network(
                                    _imageUrlController.text,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }
    // it triggers the validator method of each textField
    _form.currentState?.save();

    setState(() {
      _isLoading = true;
    });
    try {
      if (!_editedProduct.id.isEmpty) {
        // product already exists
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } else {
        // adding new product
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      }
    } catch (exception) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('An Error Occurred'),
            content: Text(exception.toString()),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Okay')),
            ],
          );
        },
      );
    }
    Navigator.of(context).pop();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }
}

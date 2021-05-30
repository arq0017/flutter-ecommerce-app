import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/EditProductScreen';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  FocusNode _descriptionFocusNode;
  // adding this focus Node to focus on image preview the moment we input the URL
  final FocusNode _imageFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  // global key for saving the form
  final _formKey = GlobalKey<FormState>();

  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
  );
  var _initValues = {
    'title ': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isInit = true;
  var _isLoading = false;
  void changeProgress(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImageUrl);
    _descriptionFocusNode = FocusNode();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        // updated _editedProduct with updated id
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
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

  // function for focus node listeners
  void _updateImageUrl() {
    if (!_imageFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty) return;
    }
    setState(() {});
  }

  // method to save the item
  Future<void> _saveForm() async {
    var isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState.save();

    changeProgress(true);
    if (_editedProduct.id == null) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occured !'),
            content:
                Text('Something went wrong - Check your internet connection .'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Okay'),
              )
            ],
          ),
        );
      }
    } else {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct, _editedProduct.id);
    }
    Navigator.of(context).pop();

    changeProgress(false);
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImageUrl);
    _descriptionFocusNode.dispose();
    _imageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              strokeWidth: 3,
            ))
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                autovalidateMode: AutovalidateMode.always,
                key: _formKey,
                child: SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _initValues['title'],
                          decoration: InputDecoration(labelText: 'Title '),
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                          onSaved: (value) {
                            _editedProduct =
                                _editedProduct.copyWith(title: value);
                          },
                          validator: (value) {
                            if (value.isEmpty) return 'Please provide a title';
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          decoration: const InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          onSaved: (value) {
                            _editedProduct = _editedProduct.copyWith(
                                price: double.parse(value));
                          },
                          validator: (value) {
                            if (value.isEmpty) return 'Please enter a price';
                            if (double.tryParse(value) == null)
                              return 'Please enter a valid number';
                            if (double.parse(value) <= 0)
                              return 'Please enter price greater than 0';
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.next,
                          focusNode: _descriptionFocusNode,
                          onFieldSubmitted: (_) =>
                              _descriptionFocusNode.requestFocus(),
                          onSaved: (value) {
                            _editedProduct =
                                _editedProduct.copyWith(description: value);
                          },
                          validator: (value) {
                            if (value.isEmpty) return 'Enter description';
                            if (value.length < 10)
                              return 'Should be atleast 10 characters';
                            return null;
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // COntainer for showing preview of image
                            Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(
                                top: 8,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: _imageUrlController.text.isEmpty
                                  ? Padding(
                                      padding: EdgeInsets.all(7),
                                      child: Text('Enter a URL'))
                                  : FittedBox(
                                      child: Image.network(
                                          _imageUrlController.text),
                                      fit: BoxFit.cover),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Image Url'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                focusNode: _imageFocusNode,
                                onSaved: (value) {
                                  _editedProduct =
                                      _editedProduct.copyWith(imageUrl: value);
                                },
                                onFieldSubmitted: (_) => _saveForm(),
                                controller: _imageUrlController,
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Provide enter an image URL.';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            ),
    );
  }
}

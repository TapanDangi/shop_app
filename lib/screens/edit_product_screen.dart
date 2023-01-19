import 'package:flutter/material.dart';

import '../provider/product.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  static const routeName = 'edit-product-screen';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  //FocusNode is a widget built in flutter that can be assigned to a Text Input widget.
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  //this is used to set up a GlobalKey of type FormState.
  //it is needed when you need to interact with a widget from inside your code.
  //here, we need it to access Form() widget from the _saveForm() function.
  var _editedProduct = Product(
    id: '',
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
  );

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    //we added a new listener to this FocusNode and point to a function that
    //should be executed whenever listener detects a change in the focus.
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }
  //FocusNode needs to be cleared when the object is removed, otherwise it leads
  //to memory leaks. Therefore, always use the dispose() function to clear the FocusNode.

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
    //this forces flutter to update the screen whenever the focus of imageUrl field changes.
  }
  //this function is executed whenever the focus in the imageUrl field changes.

  void _saveForm() {
    final isValid = _form.currentState!.validate();
    //validate() method is provided by flutter to trigger all the validators in the
    //TextFormField. It can be used if autovalidate is set to false.
    //the value of isValid will return true if all validators return null.
    if (!isValid) {
      return;
    }
    //if isValid returns false, the function will stop execution.
    _form.currentState!.save();
    //save() method is provided by flutter to save the form.
    //It will be accessed if isValid returns true.
  }
  //this function triggers a method on every TextFormField which allows us to take
  //the values entered in the field and do whatever you want with it.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          //key argument establishes the connection to the _saveForm() function
          //using the GlobalKey.
          //Now, we can use the _form property to interact with the state managed
          //by Form() widget.
          //It means that the contents of Form() widget can be accessed from outside
          //using the _form GlobalKey.
          child: ListView(
            children: [
              TextFormField(
                //TextFormField automatically connects to the Form widget to get input.
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  //onFieldSubmitted() tells flutter what to do when the bottom
                  //right button in the keyboard is pressed.
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                  //this tells flutter that when the submit button is clicked,
                  //we want to focus on the element with this FocusNode specified.
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please provide a value';
                    //if a string is returned, it is automatically treated as an error message.
                  }
                  return null;
                  //returning a null is treated as having no problems in the input.
                },
                //the value we get is the value currently entered in the TextFormField.
                //it is executed when we call a specific validate method.
                onSaved: (value) {
                  _editedProduct = Product(
                    id: '',
                    title: value as String,
                    description: _editedProduct.description,
                    imageUrl: _editedProduct.imageUrl,
                    price: _editedProduct.price,
                  );
                  //Here, we have to create a new product every time because the
                  //fields of the Product() are final(immutable).
                },
                //this executed when _saveForm() is executed. Here, our plan is
                //to update the _editedProduct() whenever _saveForm() is called.
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                //this defines the name of the FocusNode for this TextField.
                //It can be accessed by other TextFields to transfer input control
                //to this field.
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: '',
                    title: _editedProduct.title,
                    description: _editedProduct.description,
                    imageUrl: _editedProduct.imageUrl,
                    price: double.parse(value as String),
                  );
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                onSaved: (value) {
                  _editedProduct = Product(
                    id: '',
                    title: _editedProduct.title,
                    description: value as String,
                    imageUrl: _editedProduct.imageUrl,
                    price: _editedProduct.price,
                  );
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(
                      top: 8,
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? const Text(
                            'Enter a URL',
                            textAlign: TextAlign.center,
                          )
                        : FittedBox(
                            alignment: Alignment.center,
                            fit: BoxFit.fill,
                            child: Image.network(_imageUrlController.text),
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      //here, controller is used because we have to get the image
                      //before the form is submitted.
                      //If we have to get the value after the form is submitted,
                      //we don't need to use controller.
                      focusNode: _imageUrlFocusNode,
                      //it keeps track of wwhether this field is focused or not.
                      //So, we only need to listen to the changes in focus.
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: '',
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          imageUrl: value as String,
                          price: _editedProduct.price,
                        );
                      },
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
}

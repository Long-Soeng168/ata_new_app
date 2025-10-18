// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/models/body_type.dart';
import 'package:ata_new_app/models/brand.dart';
import 'package:ata_new_app/models/brand_model.dart';
import 'package:ata_new_app/models/category.dart';
import 'package:ata_new_app/models/shop.dart';
import 'package:ata_new_app/services/body_type_service.dart';
import 'package:ata_new_app/services/brand_model_service.dart';
import 'package:ata_new_app/services/brand_service.dart';
import 'package:ata_new_app/services/category_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ata_new_app/services/product_service.dart';

class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key, required this.shop});
  final Shop shop;

  @override
  _ProductCreatePageState createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  List<Category> categories = [];
  bool isLoadingCategories = true;
  bool isLoadingCategoriesError = false;
  int? categoryId;

  List<BodyType> bodyTypes = [];
  bool isLoadingBodyTypes = true;
  bool isLoadingBodyTypesError = false;
  int? bodyTypeId;

  List<Brand> brands = [];
  bool isLoadingBrands = true;
  bool isLoadingBrandsError = false;
  int? brandId;

  List<BrandModel> brandModels = [];
  List<BrandModel> filteredBrandModels = [];
  bool isLoadingBrandModels = true;
  bool isLoadingBrandModelsError = false;
  int? brandModelId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategories();
    getBodyTypes();
    getBrands();
    getBrandModels();
  }

  Future<void> getCategories() async {
    try {
      // Fetch products outside of setState
      final fetchedCategories = await CategoryService.fetchCategories();
      // Update the state
      setState(() {
        categories = fetchedCategories;
        isLoadingCategories = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingCategories = false;
        isLoadingCategoriesError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Catogries: $error');
    }
  }

  Future<void> getBodyTypes() async {
    try {
      // Fetch products outside of setState
      final fetchedBodyTypes = await BodyTypeService.fetchBodyTypes();
      // Update the state
      setState(() {
        bodyTypes = fetchedBodyTypes;
        isLoadingBodyTypes = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingBodyTypes = false;
        isLoadingBodyTypesError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Body Types: $error');
    }
  }

  Future<void> getBrands() async {
    try {
      // Fetch products outside of setState
      final fetchedBrands = await BrandService.fetchBrands();
      // Update the state
      setState(() {
        brands = fetchedBrands;
        isLoadingBrands = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingBrands = false;
        isLoadingBrandsError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Brands: $error');
    }
  }

  Future<void> getBrandModels() async {
    try {
      // Fetch products outside of setState
      final fetchedBrandModels = await BrandModelService.fetchBrandModels();
      // Update the state
      setState(() {
        brandModels = fetchedBrandModels;
        isLoadingBrandModels = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingBrandModels = false;
        isLoadingBrandModelsError = true;
      });
      // You can also show an error message to the user
      print('Failed to load BrandModels: $error');
    }
  }

  final _productService = ProductService();
  final _productFormKey = GlobalKey<FormState>();

  // Controllers for product fields
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productDescriptionController = TextEditingController();

  // Variable for product image
  List<XFile> _productImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // Function to pick image for the product
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    final List<XFile> validImages = [];
    for (var file in pickedFiles) {
      final fileSize = await file.length(); // in bytes
      if (fileSize <= 2 * 1024 * 1024) {
        validImages.add(file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${file.name} is too large. Max 2 MB.",
            ),
          ),
        );
      }
    }

    if (validImages.isNotEmpty) {
      setState(() {
        _productImages.addAll(validImages); // append to existing images
      });
    }
  }

  // Function to handle product creation
  Future<void> _createProduct() async {
    if (_productFormKey.currentState!.validate() && _productImages != null) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Call the product creation service
      final response = await _productService.createProduct(
        context: context,
        shop: widget.shop,
        name: _productNameController.text,
        price: _productPriceController.text,
        categoryId: categoryId ?? -1,
        brandId: brandId ?? -1,
        brandModelId: brandModelId ?? -1,
        bodyTypeId: bodyTypeId ?? -1,
        description: _productDescriptionController.text,
        images: _productImages, // <- pass list now
      );

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Product created successfully".tr())));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Please complete all fields and upload an image".tr())));
    }
  }

  Widget _buildImageCard(
      {required Widget child,
      VoidCallback? onDelete,
      bool isDeleting = false}) {
    return Stack(
      children: [
        AspectRatio(aspectRatio: 1, child: child),
        if (isDeleting)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
          )
        else if (onDelete != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Product".tr()),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _productFormKey,
          child: ListView(
            children: [
              // Product name input
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: "Name".tr(),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Border color when enabled
                    ),
                  ),
                  hintText: 'Product Name'.tr(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter product name".tr() : null,
              ),
              SizedBox(
                height: 12,
              ),

              // Product price input
              TextFormField(
                controller: _productPriceController,
                decoration: InputDecoration(
                  labelText: "Price \$",
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Border color when enabled
                    ),
                  ),
                  hintText: "Price \$",
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Enter product price".tr() : null,
              ),

              SizedBox(
                height: 12,
              ),

              if (isLoadingCategories ||
                  isLoadingBodyTypes ||
                  isLoadingBrands ||
                  isLoadingBrandModels)
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (!isLoadingCategories)
                DropdownButtonFormField<int>(
                  value: categoryId,
                  decoration: InputDecoration(
                    labelText: "Select Category".tr(),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Colors.grey.shade400, // Border color when enabled
                      ),
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    ...categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40, // Adjust the width as needed
                              height: 40, // Adjust the height as needed
                              child: Image.network(
                                category.imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 10), // Space between image and text
                            Text(category.name),
                          ],
                        ),
                      );
                    }),
                    DropdownMenuItem<int>(
                      value: -1, // Unique value for "Other"
                      child: Row(
                        children: [
                          Icon(Icons.add), // Icon for "Other" option
                          SizedBox(width: 10),
                          Text("Other".tr()),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      categoryId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Select Category".tr() : null,
                ),
              SizedBox(height: 12),

              if (!isLoadingBodyTypes)
                DropdownButtonFormField<int>(
                  value: bodyTypeId,
                  decoration: InputDecoration(
                    labelText: "Select Body-Type".tr(),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Colors.grey.shade400, // Border color when enabled
                      ),
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    ...bodyTypes.map((bodyType) {
                      return DropdownMenuItem<int>(
                        value: bodyType.id,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40, // Adjust the width as needed
                              height: 40, // Adjust the height as needed
                              child: Image.network(
                                bodyType.imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 10), // Space between image and text
                            Text(bodyType.name),
                          ],
                        ),
                      );
                    }),
                    DropdownMenuItem<int>(
                      value: -1, // Unique value for "Other"
                      child: Row(
                        children: [
                          Icon(Icons.add), // Icon for "Other" option
                          SizedBox(width: 10),
                          Text("Other".tr()),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      bodyTypeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Select Body-Type".tr(); // Include validation for "Other"
                    }
                    return null;
                  },
                ),

              SizedBox(height: 12),

              if (!isLoadingBrands)
                DropdownButtonFormField<int>(
                  value: brandId,
                  decoration: InputDecoration(
                    labelText: "Select Brand".tr(),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Colors.grey.shade400, // Border color when enabled
                      ),
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    ...brands.map((brand) {
                      return DropdownMenuItem<int>(
                        value: brand.id,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40, // Adjust the width as needed
                              height: 40, // Adjust the height as needed
                              child: Image.network(
                                brand.imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 10), // Space between image and text
                            Text(brand.name),
                          ],
                        ),
                      );
                    }),
                    DropdownMenuItem<int>(
                      value: -1, // Unique value for "Other"
                      child: Row(
                        children: [
                          Icon(Icons.add), // Icon for "Other" option
                          SizedBox(width: 10),
                          Text("Other".tr()),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      brandId = value;
                      brandModelId = null;
                      filteredBrandModels = brandModels
                          .where((brandModel) =>
                              brandModel.brandId == value.toString())
                          .toList();
                    });
                  },
                  validator: (value) => value == null ? "Select Brand".tr() : null,
                ),
              SizedBox(height: 12),

              if (!isLoadingBrandModels)
                DropdownButtonFormField<int>(
                  value: brandModelId,
                  decoration: InputDecoration(
                    labelText: "Select Model".tr(),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Colors.grey.shade400, // Border color when enabled
                      ),
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    ...filteredBrandModels.map((brandModel) {
                      return DropdownMenuItem<int>(
                        value: brandModel.id,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40, // Adjust the width as needed
                              height: 40, // Adjust the height as needed
                              child: Image.network(
                                brandModel.imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 10), // Space between image and text
                            Text(brandModel.name),
                          ],
                        ),
                      );
                    }),
                    DropdownMenuItem<int>(
                      value: -1, // Unique value for "Other"
                      child: Row(
                        children: [
                          Icon(Icons.add), // Icon for "Other" option
                          SizedBox(width: 10),
                          Text("Other".tr()),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      brandModelId = value;
                    });
                  },
                  validator: (value) => value == null ? "Select Model".tr() : null,
                ),
              SizedBox(height: 12),

              TextFormField(
                controller: _productDescriptionController,
                decoration: InputDecoration(
                  labelText: "Description".tr(),
                  hintText: 'Product Description'.tr(),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Border color when enabled
                    ),
                  ),
                ),
                maxLines:
                    4, // Set maxLines to allow multiple lines, adjust as needed
                validator: (value) =>
                    value!.isEmpty ? "Enter product description".tr() : null,
              ),

              SizedBox(height: 12),

              // Product image picker with preview
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Product Images".tr(),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImages,
                      child: _productImages.isEmpty
                          ? Container(
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image,
                                          color: Colors.grey.shade400,
                                          size: 50),
                                      Text('Tap to pick images'.tr()),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _productImages.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (_, index) => _buildImageCard(
                                  child: Image.file(
                                      File(_productImages[index].path),
                                      fit: BoxFit.cover),
                                  onDelete: () => setState(
                                      () => _productImages.removeAt(index)),
                                ),
                              ),
                            ),
                    ),
                    TextButton(
                      onPressed: _pickImages,
                      child: Text(_productImages.isEmpty
                          ? "Upload Images".tr()
                          : "Add More".tr()),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Submit button with loading indicator
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : MyElevatedButton(
                      onPressed: _createProduct, title: 'Create Product'.tr())
            ],
          ),
        ),
      ),
    );
  }
}

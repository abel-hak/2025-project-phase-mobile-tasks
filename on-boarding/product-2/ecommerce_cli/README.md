# Dart eCommerce CLI Application

A simple command-line eCommerce application built with Dart that allows users to manage products through basic CRUD operations.

## Features

- Add new products with name, description, and price
- View all products in the system
- View a single product by name
- Edit existing products
- Delete products

## Project Structure

- `lib/product.dart`: Contains the Product class with proper encapsulation
- `lib/product_manager.dart`: Implements the ProductManager class for CRUD operations
- `bin/ecommerce_cli.dart`: Main CLI interface for user interaction

## Running the Application

To run the application, use the following command in the project directory:

```bash
dart run
```

## Usage

The application provides a simple menu-driven interface with the following options:

1. Add Product - Add a new product with name, description, and price
2. View All Products - Display all products in the system
3. View Single Product - Search and display a product by name
4. Edit Product - Modify an existing product's details
5. Delete Product - Remove a product from the system
6. Exit - Close the application

## Implementation Details

- Uses proper OOP principles including encapsulation and abstraction
- Implements error handling for invalid inputs and edge cases
- Follows Dart coding conventions and best practices

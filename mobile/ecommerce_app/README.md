# eCommerce Mobile App

A Flutter-based mobile application for managing products, built using Clean Architecture principles and Test-Driven Development (TDD).

## Architecture Overview

The application follows Clean Architecture principles with the following layers:

### Domain Layer

#### Entities
- `Product`: Core business entity with properties:
  - id (String)
  - name (String)
  - description (String)
  - price (double)
  - imageUrl (String)
  - category (String)
  - rating (double)

#### Use Cases
CRUD operations for products:
- `InsertProductUseCase`: Add new products
- `UpdateProductUseCase`: Modify existing products
- `DeleteProductUseCase`: Remove products
- `GetProductUseCase`: Retrieve product details

#### Repository Interfaces
- `ProductRepository`: Defines contract for product data operations
  - insertProduct
  - updateProduct
  - deleteProduct
  - getProduct

### Data Layer

#### Models
- `ProductModel`: Data representation of Product entity
  - Extends Product entity
  - Implements JSON serialization/deserialization
  - Handles data type conversion

## Project Structure

```
lib/
├── core/            # Core functionality and shared components
├── features/
│   └── product/     # Product feature module
│       └── data/
│           └── models/
│               └── product_model.dart
├── domain/
│   ├── entities/
│   │   └── product.dart
│   ├── usecases/
│   │   └── product_usecases.dart
│   └── repositories/
│       └── product_repository.dart
├── config/
│   ├── page_transitions.dart
│   └── routes.dart
├── screens/
│   ├── add_update_page.dart
│   ├── details_page.dart
│   ├── home_page.dart
│   └── search_page.dart
└── main.dart
```

## Data Flow

1. UI Layer (Screens)
   - Displays data to users
   - Captures user input
   - Communicates with Use Cases

2. Domain Layer
   - Contains business logic
   - Defines entity structures
   - Provides use case interfaces

3. Data Layer
   - Implements data models
   - Handles data conversion
   - Manages data persistence

## Features

- Create, Read, Update, and Delete products
- Search products by name
- Detailed product view
- Modern and responsive UI
- Clean Architecture design
- Test-Driven Development approach

## Getting Started

1. Ensure you have Flutter installed
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Architecture Overview

The application follows Clean Architecture principles:

1. **Domain Layer**
   - Contains business logic
   - No dependencies on external packages
   - Pure Dart code
   - Includes entities, use cases, and repository interfaces

2. **Use Cases**
   - Single responsibility principle
   - Each use case represents one specific business action
   - Independent of external implementations

3. **Repository Pattern**
   - Abstract definition in domain layer
   - Separates business logic from data sources
   - Enables easy testing and modification of data sources

## Dependencies

- Flutter SDK
- Material Design components

## Contributing

Feel free to submit issues and enhancement requests.

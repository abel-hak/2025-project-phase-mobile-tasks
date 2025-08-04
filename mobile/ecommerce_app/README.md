# eCommerce Mobile App

A Flutter-based mobile application for managing products, built using Clean Architecture principles and Test-Driven Development (TDD).

## Implementation Details

Detailed breakdown of the implementation:

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

#### Repository Layer

The repository layer implements the domain layer contracts and coordinates data operations:

1. **Network-Aware Repository**
   - Uses NetworkInfo to check connectivity
   - Remote data source when online
   - Local data source when offline
   - Automatic caching of remote data

2. **Error Handling**
   - Handles ServerException for remote operations
   - Handles CacheException for local operations
   - Falls back to cached data when remote fails

3. **Data Sources**
   - **Remote Data Source**:
     - Implements ProductRemoteDataSource contract
     - Mock API implementation (ready for real API integration)
     - Proper error handling with ServerException
     - Simulated network delays for testing
     - Comprehensive test coverage for all operations
   - **Local Data Source**:
     - Uses SharedPreferences for caching
     - JSON serialization/deserialization
     - Proper error handling with CacheException

4. **Testing**
   - Comprehensive unit tests
   - Mock-based testing using Mockito
   - Tests for online/offline scenarios
   - Tests for success and error cases

### Architecture Overview

#### 1. Presentation Layer
- **BLoC Pattern**
  - Separates business logic from UI
  - Events: LoadAllProduct, GetSingleProduct, UpdateProduct, DeleteProduct, CreateProduct
  - States: Initial, Loading, LoadedAllProduct, LoadedSingleProduct, Error
  - Comprehensive unit tests for all events and states

#### 2. Domain Layer
- **Entities**
  - `Product`: Core business entity
  - Properties: id, name, description, price, imageUrl, category, rating

- **Use Cases**
  - CreateProductUseCase
  - UpdateProductUseCase
  - DeleteProductUseCase
  - GetProductUseCase
  - GetAllProductsUseCase

- **Repository Contracts**
  - ProductRepository interface defining data operations

#### 3. Data Layer
- **Models**
  - `ProductModel`: Data representation of Product entity
  - JSON serialization/deserialization
  - Type conversion and equality implementations

- **Repository Implementation**
  - Network-aware with automatic offline fallback
  - Coordinated remote/local data source usage
  - Error handling with Either type from dartz

- **Remote Data Source**
  - Mock API implementation (HTTP-based)
  - Proper error handling with ServerException
  - Ready for real API integration

- **Local Data Source**
  - SharedPreferences-based caching
  - JSON serialization for storage
  - Proper error handling with CacheException

#### 4. Core Layer
- **Network**
  - NetworkInfo interface
  - InternetConnectionChecker implementation
  - Reliable connectivity detection

- **Error Handling**
  - Custom exceptions (ServerException, CacheException)
  - Failure classes for domain layer
  - Either type for functional error handling

## Project Structure

```
lib/
├── core/                    # Core functionality and shared components
│   ├── error/              # Error handling (exceptions, failures)
│   └── network/            # Network connectivity handling
└── features/
    └── product/            # Product feature module
        ├── data/           # Data layer
        │   ├── datasources/  # Remote and local data sources
        │   ├── models/      # Data models
        │   └── repositories/ # Repository implementations
        ├── domain/         # Domain layer
        │   ├── entities/    # Business entities
        │   ├── repositories/ # Repository contracts
        │   └── usecases/    # Business use cases
        └── presentation/    # Presentation layer
            ├── bloc/        # BLoC pattern implementation
            ├── pages/       # Screen implementations
            └── widgets/     # Reusable UI components
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

The application follows Clean Architecture principles with three main layers:

1. **Domain Layer**
   - Contains business logic and entities
   - No dependencies on external packages
   - Pure Dart code
   - Includes:
     - Entities (e.g., Product)
     - Use Cases (CRUD operations)
     - Repository Interfaces

2. **Data Layer**
   - Implements data access and storage
   - Includes:
     - Models (JSON serialization)
     - Data Source Contracts
       - Remote Data Source (API)
       - Local Data Source (Cache)
     - Repository Implementation
   - Handles data conversion and caching

3. **Presentation Layer**
   - User interface and interaction
   - Implements screens and widgets
   - Uses Material Design components
   - Handles user input and display

## Dependencies

- Flutter SDK
- Material Design components
- internet_connection_checker: Network connectivity detection

## Network Handling

1. **NetworkInfo Implementation**
   - Uses InternetConnectionChecker for reliable connectivity detection
   - Abstract NetworkInfo interface for dependency inversion
   - NetworkInfoImpl concrete implementation
   - Unit tested with mock-based testing

2. **Network-Aware Features**
   - Automatic online/offline mode switching
   - Local data caching for offline access
   - Graceful error handling for network failures

## Contributing

Feel free to submit issues and enhancement requests.

Family Guard
Tree Project
```    
lib/
├── core/
│   ├── constants/            # App constants (color, text, key, ...)
│   ├── theme/                # Theme, color scheme, text style
│   ├── utils/                # Helpers, extensions, formatters
│   ├── network/              # Dio client, interceptors, API config
│   ├── error/                # Exception & failure handling
│   └── widgets/              # Global reusable widgets
│
├── features/
│   ├── login/
│   │   ├── data/
│   │   │   ├── datasources/        # Remote & local data sources
│   │   │   ├── models/             # DTO models (JSON)
│   │   │   └── repositories_impl/  # Repository implementation
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/           # Core business entities
│   │   │   ├── repositories/       # Abstract repositories
│   │   │   └── usecases/           # Login use cases
│   │   │
│   │   └── presentation/
│   │       ├── screens/            # Login screens
│   │       ├── cubit/              # State management (Cubit/Bloc)
│   │       └── widgets/            # Feature-specific widgets
│   │
│   ├── home/
│   ├── sos/
│   ├── tracking/
│   └── settings/
│
└── main.dart                      # Entry point
```

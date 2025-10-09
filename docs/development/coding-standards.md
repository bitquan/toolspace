# Coding Standards

Comprehensive coding standards and style guide for Toolspace development.

## General Principles

- **Consistency**: Follow established patterns within the codebase
- **Readability**: Code should be self-documenting and easy to understand
- **Maintainability**: Write code that's easy to modify and extend
- **Performance**: Consider performance implications of code changes
- **Security**: Always validate inputs and follow security best practices

## Dart/Flutter Standards

### Code Formatting

```bash
# Format all Dart code
dart format .

# Check formatting without changes
dart format . --set-exit-if-changed
```

**Rules:**

- Use `dart format` with default settings (no custom configuration)
- Line length: 80 characters (dart format default)
- Use trailing commas for better version control diffs

### Naming Conventions

```dart
// Classes: PascalCase
class BillingService {}
class PaywallGuard extends StatelessWidget {}

// Variables and functions: camelCase
String userName = 'john';
void calculateTotal() {}

// Constants: camelCase with const
const Duration animationDuration = Duration(milliseconds: 300);

// Private members: leading underscore
String _privateField;
void _privateMethod() {}

// Files: snake_case
// billing_service.dart
// upgrade_sheet.dart
```

### Code Organization

```dart
/// Doc comment for public APIs
///
/// Explains what the class/function does and how to use it.
class BillingService {
  // Static fields first
  static const String baseUrl = 'https://api.stripe.com';

  // Instance fields
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Constructor
  BillingService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  // Public methods
  Future<BillingProfile> getBillingProfile() async {
    // Implementation
  }

  // Private methods
  void _validateUser() {
    // Implementation
  }
}
```

### Widget Structure

```dart
class UpgradeSheet extends StatefulWidget {
  // Required parameters first
  final BillingService billingService;
  final PlanId currentPlan;

  // Optional parameters with defaults
  final String? successUrl;
  final String? cancelUrl;

  const UpgradeSheet({
    super.key,
    required this.billingService,
    required this.currentPlan,
    this.successUrl,
    this.cancelUrl,
  });

  @override
  State<UpgradeSheet> createState() => _UpgradeSheetState();
}

class _UpgradeSheetState extends State<UpgradeSheet> {
  // State variables
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Widget tree
    );
  }

  // Helper methods
  Future<void> _loadData() async {
    // Implementation
  }
}
```

### Error Handling

```dart
// Use try-catch for async operations
Future<void> createCheckoutSession() async {
  try {
    final session = await _stripe.createSession(planId);
    await _launchUrl(session.url);
  } on StripeException catch (e) {
    _showError('Payment error: ${e.message}');
  } catch (e) {
    _showError('An unexpected error occurred');
    logger.error('Checkout error', error: e);
  }
}

// Use Result pattern for complex operations
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}
```

## TypeScript Standards

### TypeScript Code Formatting

```bash
# Format and lint
npm run lint

# Auto-fix issues
npm run lint -- --fix
```

**Configuration:**

- ESLint with Google config
- Prettier integration
- Strict TypeScript mode enabled

### TypeScript Naming Conventions

```typescript
// Interfaces: PascalCase with 'I' prefix (optional)
interface BillingProfile {
  planId: string;
  status: SubscriptionStatus;
}

// Types: PascalCase
type PlanId = "free" | "pro" | "pro_plus";

// Functions: camelCase
function createCheckoutSession(): Promise<string> {}

// Constants: SCREAMING_SNAKE_CASE
const MAX_RETRY_ATTEMPTS = 3;

// Enums: PascalCase
enum SubscriptionStatus {
  Active = "active",
  Cancelled = "cancelled",
}
```

### Function Structure

```typescript
/**
 * Creates a Stripe checkout session for the specified plan.
 *
 * @param userId - The authenticated user's ID
 * @param planId - The target subscription plan
 * @param returnUrl - URL to redirect after completion
 * @returns Promise resolving to checkout session URL
 * @throws {Error} When user is not found or plan is invalid
 */
export async function createCheckoutSession(
  userId: string,
  planId: PlanId,
  returnUrl: string
): Promise<string> {
  // Validate inputs
  if (!userId) {
    throw new Error("User ID is required");
  }

  // Implementation
  const customer = await getOrCreateCustomer(userId);
  const session = await stripe.checkout.sessions.create({
    customer: customer.id,
    mode: "subscription",
    line_items: [
      {
        price: getPriceId(planId),
        quantity: 1,
      },
    ],
    success_url: returnUrl,
  });

  return session.url!;
}
```

### TypeScript Error Handling

```typescript
// Custom error classes
export class BillingError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 400
  ) {
    super(message);
    this.name = "BillingError";
  }
}

// Error handling in functions
export const createCheckoutSession = functions.https.onCall(
  async (data, context) => {
    try {
      // Validate authentication
      if (!context.auth) {
        throw new BillingError("Unauthenticated", "UNAUTHENTICATED", 401);
      }

      // Implementation
      const sessionUrl = await processCheckout(data);

      return { success: true, data: { url: sessionUrl } };
    } catch (error) {
      logger.error("Checkout error", { error, userId: context.auth?.uid });

      if (error instanceof BillingError) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          error.message,
          { code: error.code }
        );
      }

      throw new functions.https.HttpsError(
        "internal",
        "An unexpected error occurred"
      );
    }
  }
);
```

## Project Structure

### Folder Organization

```text
lib/
├── auth/                 # Authentication features
│   ├── services/        # Auth business logic
│   ├── widgets/         # Reusable auth widgets
│   └── screens/         # Auth-specific screens
├── billing/             # Billing/subscription features
│   ├── types.dart       # Billing data models
│   ├── service.dart     # Billing business logic
│   └── widgets/         # Billing UI components
├── core/                # Core app functionality
│   ├── routes.dart      # App routing configuration
│   ├── theme.dart       # App theme definition
│   └── constants.dart   # App-wide constants
├── shared/              # Shared utilities
│   ├── widgets/         # Reusable UI components
│   ├── services/        # Common services
│   └── utils/           # Helper functions
└── tools/               # Individual tool implementations
    ├── text_tools/      # Tool-specific code
    └── file_merger/
```

### File Naming

- **Dart files**: `snake_case.dart`
- **Test files**: `feature_test.dart`
- **Widget files**: Match class name in snake_case
- **Service files**: End with `_service.dart`

## Testing Standards

### Test Organization

```dart
void main() {
  group('BillingService', () {
    late BillingService service;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      service = BillingService(auth: mockAuth);
    });

    group('getBillingProfile', () {
      test('returns profile for authenticated user', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);

        // Act
        final profile = await service.getBillingProfile();

        // Assert
        expect(profile.planId, equals(PlanId.free));
      });

      test('throws when user not authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => service.getBillingProfile(),
          throwsA(isA<AuthException>()),
        );
      });
    });
  });
}
```

### Test Naming

- **Test files**: `*_test.dart`
- **Test descriptions**: Use present tense ("returns user profile")
- **Test groups**: Match class/feature names
- **Test structure**: Arrange/Act/Assert pattern

## Documentation Standards

### Code Documentation

````dart
/// Service for managing user billing and subscriptions.
///
/// Provides methods for:
/// - Retrieving billing profiles
/// - Creating checkout sessions
/// - Managing subscription status
///
/// Example usage:
/// ```dart
/// final service = BillingService();
/// final profile = await service.getBillingProfile();
/// if (profile.planId == PlanId.free) {
///   // Show upgrade options
/// }
/// ```
class BillingService {
  /// Creates a Stripe checkout session for the specified plan.
  ///
  /// Throws [AuthException] if user is not authenticated.
  /// Throws [BillingException] if plan is invalid or Stripe fails.
  Future<String> createCheckoutSession(PlanId planId) async {
    // Implementation
  }
}
````

### README Standards

Each major feature should have a README:

```markdown
# Feature Name

Brief description of what this feature does.

## Usage

Basic usage examples with code snippets.

## Architecture

High-level overview of how the feature works.

## Testing

How to run tests for this feature.

## Configuration

Any configuration options or environment variables.
```

## Git Standards

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Format
type(scope): description

# Examples
feat(billing): add Pro+ subscription tier
fix(auth): resolve email verification bug
docs(setup): update Firebase configuration guide
refactor(ui): extract reusable button component
test(billing): add checkout session tests
```

### Branch Naming

```bash
# Features
feat/add-pro-plus-tier
feat/batch-qr-generator

# Bug fixes
fix/email-verification-bug
fix/checkout-timeout-issue

# Documentation
docs/update-setup-guide
docs/add-api-documentation

# Operations
ops/add-production-deployment
ops/update-ci-pipeline
```

## Performance Guidelines

### Flutter Performance

```dart
// Use const constructors
const Text('Hello World')

// Prefer const collections
const ['item1', 'item2', 'item3']

// Use builders for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// Avoid expensive operations in build methods
class MyWidget extends StatelessWidget {
  final String _processedText = _expensiveOperation(); // ❌ Wrong

  @override
  Widget build(BuildContext context) {
    final processedText = _expensiveOperation(); // ❌ Wrong - called every build

    return Text(processedText);
  }
}

// Better approach
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late String _processedText;

  @override
  void initState() {
    super.initState();
    _processedText = _expensiveOperation(); // ✅ Correct
  }

  @override
  Widget build(BuildContext context) {
    return Text(_processedText);
  }
}
```

### Cloud Functions Performance

```typescript
// Keep functions warm (if needed)
export const keepWarm = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async () => {
    console.log("Keeping functions warm");
  });

// Use appropriate memory allocation
export const heavyFunction = functions
  .runWith({ memory: "1GB", timeoutSeconds: 540 })
  .https.onRequest(handler);

// Cache expensive operations
const priceCache = new Map<string, number>();

async function getPrice(priceId: string): Promise<number> {
  if (priceCache.has(priceId)) {
    return priceCache.get(priceId)!;
  }

  const price = await stripe.prices.retrieve(priceId);
  priceCache.set(priceId, price.unit_amount!);
  return price.unit_amount!;
}
```

## Security Guidelines

### Input Validation

```dart
// Validate all user inputs
void validateEmail(String email) {
  if (email.isEmpty) {
    throw ValidationException('Email is required');
  }

  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
    throw ValidationException('Invalid email format');
  }
}

// Sanitize file names
String sanitizeFileName(String fileName) {
  return fileName
    .replaceAll(RegExp(r'[^\w\-_\.]'), '_')
    .replaceAll(RegExp(r'_{2,}'), '_');
}
```

### TypeScript Security

```typescript
// Validate function inputs
export const updateProfile = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Login required");
  }

  // Validate input structure
  const { name, email } = data;
  if (typeof name !== "string" || typeof email !== "string") {
    throw new functions.https.HttpsError("invalid-argument", "Invalid input");
  }

  // Check ownership
  if (data.userId !== context.auth.uid) {
    throw new functions.https.HttpsError("permission-denied", "Access denied");
  }

  // Implementation
});
```

---

These standards should be followed consistently across the entire codebase. When in doubt, refer to existing code for patterns and consistency.

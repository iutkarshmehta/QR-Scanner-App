# QR Scanner — Product Verification App

An iOS app that scans QR codes and barcodes to instantly verify product authenticity using the [Open Food Facts](https://world.openfoodfacts.org) API. Scan results are stored locally for offline reference.

> iOS take-home assignment for Acviss Technologies.

---

## Features

- **QR & Barcode Scanning** — supports QR, EAN-8, EAN-13, UPC-E, Code 128, Code 39, and Code 93
- **Product Verification** — fetches product data from Open Food Facts and marks products as Genuine or Unverified
- **Scan History** — all scans persisted locally via SwiftData with full-text search and status filter
- **Dark / Light Mode** — fully adaptive UI with semantic colours
- **Offline-first** — history is available without a network connection

---

## Architecture

The project follows **MVVM** with strict layer separation. Views are dumb — all computation lives in ViewModels.

```
┌─────────────────────────────────────────────┐
│                   Views                     │
│  HomeView  ScannerView  HistoryView  etc.   │
└────────────────────┬────────────────────────┘
                     │ reads / binds
┌────────────────────▼────────────────────────┐
│                 ViewModels                  │
│  ScannerViewModel  HistoryViewModel  etc.   │
└────────────────────┬────────────────────────┘
                     │ calls
┌────────────────────▼────────────────────────┐
│             Services / Repository           │
│  ProductRepository  CameraSession           │
└────────────────────┬────────────────────────┘
                     │ uses
┌────────────────────▼────────────────────────┐
│              Networking Layer               │
│  APIEndpoint  APIClient  URLSessionAPIClient│
└─────────────────────────────────────────────┘
```

### Scan flow

```
CameraPreviewView (AVFoundation)
  └── AVCaptureMetadataOutput delegate → ScannerViewModel.handleDetected()
        └── ProductRepository.fetchProduct(barcode:)     ← async/await, nonisolated
              └── ProductDetails built from API response
                    ├── saved to SwiftData (ScanRecord)
                    └── state = .result → ProductDetailView sheet
```

---

## Project Structure

```
QR-Scanner-App/
├── Models/
│   ├── ScanRecord.swift              SwiftData @Model + VerificationStatus enum
│   └── ProductDetails.swift          API response DTOs + domain presentation model
│
├── Services/
│   ├── CameraSession.swift           AVFoundation session on dedicated serial queue
│   ├── Networking/
│   │   ├── HTTPMethod.swift          GET / POST / PUT / PATCH / DELETE
│   │   ├── APIEndpoint.swift         Protocol — scheme/host/path/method/urlRequest()
│   │   ├── APIClient.swift           Protocol — send<T: Decodable>(_:) async throws
│   │   ├── APIError.swift            Typed network errors
│   │   └── URLSessionAPIClient.swift Concrete URLSession implementation
│   └── OpenFoodFacts/
│       ├── OpenFoodFactsEndpoint.swift  .product(barcode:) endpoint definition
│       └── ProductRepository.swift      Protocol + OpenFoodFacts implementation
│
├── ViewModels/
│   ├── ScannerViewModel.swift        Camera + network + persistence orchestration
│   ├── HistoryViewModel.swift        Search / filter / delete logic
│   ├── ScanRecordViewModel.swift     View-ready wrapper over ScanRecord
│   └── ProductDetailViewModel.swift  View-ready wrapper over ProductDetails
│
└── Views/
    ├── Shared/
    │   └── Theme.swift               AppTheme colours + .appCard() modifier
    ├── Tabbar/
    │   └── TabbarView.swift          Root TabView (Home + History)
    ├── Home/
    │   └── HomeView.swift            Landing screen with scan CTA
    ├── Scanner/
    │   ├── ScannerView.swift         Full-screen camera view, no tab bar
    │   ├── ScanOverlayView.swift     Canvas-based cutout + animated reticle
    │   └── CameraPreviewView.swift   UIViewRepresentable for AVCaptureVideoPreviewLayer
    ├── History/
    │   ├── HistoryView.swift         Searchable, filterable scan list
    │   ├── HistoryRowView.swift      Single row cell
    │   └── HistoryDetailView.swift   Expanded record detail
    └── ProductDetail/
        └── ProductDetailView.swift   Verification result sheet
```

---

## Tech Stack

| Area | Technology |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData |
| Camera | AVFoundation |
| Networking | URLSession + async/await |
| Concurrency | Swift structured concurrency — `@MainActor`, `nonisolated` |
| API | Open Food Facts REST — free, no key required |
| Minimum Target | iOS 17 |
| Swift | 6.2 (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`) |
| Dependencies | None — Apple frameworks only |

---

## Network Layer

Protocol-driven and fully testable. Swapping the real repository for a mock requires zero changes to ViewModels.

```
APIEndpoint          scheme / host / path / method / urlRequest()
  └── OpenFoodFactsEndpoint    .product(barcode:)

APIClient            send<T: Decodable>(_ endpoint:) async throws -> T
  └── URLSessionAPIClient      URLSession-backed, nonisolated I/O

ProductRepository    fetchProduct(barcode:) async throws -> ProductDetails
  └── OpenFoodFactsRepository  maps DTO → domain model
```

**Injecting a mock for tests:**

```swift
struct MockRepository: ProductRepository {
    func fetchProduct(barcode: String) async throws -> ProductDetails { ... }
}

let vm = ScannerViewModel(repository: MockRepository())
```

---

## Concurrency Model

| Component | Isolation | Reason |
|---|---|---|
| `ScannerViewModel` | `@MainActor` | Owns all UI-facing state |
| `CameraSession` | `@unchecked Sendable` + serial `DispatchQueue` | AVFoundation must not run on main thread |
| `URLSessionAPIClient.send` | `nonisolated` | I/O + JSON decode on cooperative thread pool |
| `ProductRepository.fetchProduct` | `nonisolated` | Inherits from client; never touches UI |
| Callbacks into ViewModel | `Task { @MainActor [weak self] in }` | Hop back to main actor; weak to avoid extending lifetime |

---

## API

**Open Food Facts** — `https://world.openfoodfacts.org/api/v0/product/{barcode}.json`

- Free, no API key required
- `status: 1` → product found → **Genuine**
- `status: 0` → not found → **Unverified**
- Supports EAN-8, EAN-13, UPC-E and most consumer product barcodes

---

## Sample Barcodes for Testing

| Barcode | Product | Expected Result |
|---|---|---|
| `3017620422003` | Nutella | Genuine |
| `5449000000996` | Coca-Cola | Genuine |
| `4006381333931` | Faber-Castell pencils | Genuine |
| `0000000000000` | — | Unverified |

---

## Getting Started

1. Clone the repository
2. Open `QR-Scanner-App.xcodeproj` in Xcode 16 or later
3. Select a physical device or simulator running iOS 17+
4. Build and run — no API key or additional configuration required

> Camera scanning requires a physical device. The History tab, search, and filter work in the Simulator.

---

## Known Limitations

- **Simulator** — camera is unavailable; use a real device for the full scan flow
- **Non-product QR codes** — a URL or plain-text QR code is sent to the API, receives `status: 0`, and is stored as Unverified — correct by design
- **No pagination** — `@Query` loads all scan records; a large history would benefit from a paginated fetch
- **Image caching** — `AsyncImage` does not persist images across launches; a disk cache would improve repeat product visits

---

## What I Would Improve With More Time

1. **Scanning region** — restrict `AVCaptureMetadataOutput.rectOfInterest` to the overlay frame so off-frame codes are ignored
2. **Haptic + audio feedback** — `UINotificationFeedbackGenerator` on successful scan
3. **Torch toggle** — flashlight button for low-light environments
4. **Unit tests** — `ScannerViewModel` and repository layer are injectable and fully testable with a mock repository and an in-memory `ModelContext`
5. **Image disk cache** — wrap `AsyncImage` in an `NSCache`-backed loader
6. **Accessibility** — dedicated VoiceOver traversal pass and dynamic type scaling

---

## Author

Mehta, Utkarsh

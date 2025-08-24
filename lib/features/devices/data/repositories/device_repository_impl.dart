// Devices feature - Data layer repository implementation entrypoint
// This file aligns the existing Firestore implementation with the
// Clean Architecture feature-first folder structure without moving files.
//
// Presentation/domain layers can import this file to access the concrete
// repository implementation.

export 'package:cence_app/repositories/firestore_device_repository_v2.dart'
    show FirestoreDeviceRepositoryV2;
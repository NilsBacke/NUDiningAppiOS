/*
 * Copyright 2018 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: firestore/local/maybe_document.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

@class FSTPBNoDocument;
@class GCFSDocument;
@class GPBTimestamp;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FSTPBMaybeDocumentRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface FSTPBMaybeDocumentRoot : GPBRootObject
@end

#pragma mark - FSTPBNoDocument

typedef GPB_ENUM(FSTPBNoDocument_FieldNumber) {
  FSTPBNoDocument_FieldNumber_Name = 1,
  FSTPBNoDocument_FieldNumber_ReadTime = 2,
};

/**
 * A message indicating that the document is known to not exist.
 **/
@interface FSTPBNoDocument : GPBMessage

/**
 * The name of the document that does not exist, in the standard format:
 * `projects/{project_id}/databases/{database_id}/documents/{document_path}`
 **/
@property(nonatomic, readwrite, copy, null_resettable) NSString *name;

/** The time at which we observed that it does not exist. */
@property(nonatomic, readwrite, strong, null_resettable) GPBTimestamp *readTime;
/** Test to see if @c readTime has been set. */
@property(nonatomic, readwrite) BOOL hasReadTime;

@end

#pragma mark - FSTPBMaybeDocument

typedef GPB_ENUM(FSTPBMaybeDocument_FieldNumber) {
  FSTPBMaybeDocument_FieldNumber_NoDocument = 1,
  FSTPBMaybeDocument_FieldNumber_Document = 2,
};

typedef GPB_ENUM(FSTPBMaybeDocument_DocumentType_OneOfCase) {
  FSTPBMaybeDocument_DocumentType_OneOfCase_GPBUnsetOneOfCase = 0,
  FSTPBMaybeDocument_DocumentType_OneOfCase_NoDocument = 1,
  FSTPBMaybeDocument_DocumentType_OneOfCase_Document = 2,
};

/**
 * Represents either an existing document or the explicitly known absence of a
 * document.
 **/
@interface FSTPBMaybeDocument : GPBMessage

@property(nonatomic, readonly) FSTPBMaybeDocument_DocumentType_OneOfCase documentTypeOneOfCase;

/** Used if the document is known to not exist. */
@property(nonatomic, readwrite, strong, null_resettable) FSTPBNoDocument *noDocument;

/** The document (if it exists). */
@property(nonatomic, readwrite, strong, null_resettable) GCFSDocument *document;

@end

/**
 * Clears whatever value was set for the oneof 'documentType'.
 **/
void FSTPBMaybeDocument_ClearDocumentTypeOneOfCase(FSTPBMaybeDocument *message);

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)

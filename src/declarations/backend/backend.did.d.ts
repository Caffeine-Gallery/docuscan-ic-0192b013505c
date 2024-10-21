import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface ExtractedData {
  'placeOfBirth' : [] | [string],
  'dateOfExpiry' : [] | [string],
  'placeOfIssue' : [] | [string],
  'documentType' : [] | [string],
  'country' : [] | [string],
  'dateOfBirth' : [] | [string],
  'dateOfIssue' : [] | [string],
  'surname' : [] | [string],
  'givenName' : [] | [string],
  'filename' : string,
  'gender' : [] | [string],
  'passportNumber' : [] | [string],
}
export interface _SERVICE {
  'generateCSV' : ActorMethod<[], string>,
  'getAllExtractedData' : ActorMethod<[], Array<ExtractedData>>,
  'getExtractedData' : ActorMethod<[bigint], [] | [ExtractedData]>,
  'uploadImage' : ActorMethod<[string, Uint8Array | number[]], bigint>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];

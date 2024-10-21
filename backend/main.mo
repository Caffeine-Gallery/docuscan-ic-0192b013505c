import Hash "mo:base/Hash";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor {
  // Types
  type ImageData = {
    filename: Text;
    data: Blob;
  };

  type ExtractedData = {
    filename: Text;
    documentType: ?Text;
    country: ?Text;
    passportNumber: ?Text;
    surname: ?Text;
    givenName: ?Text;
    dateOfBirth: ?Text;
    gender: ?Text;
    placeOfBirth: ?Text;
    placeOfIssue: ?Text;
    dateOfIssue: ?Text;
    dateOfExpiry: ?Text;
  };

  // Stable storage
  stable var nextImageId: Nat = 0;
  stable var imageEntries: [(Nat, ImageData)] = [];
  stable var extractedDataEntries: [(Nat, ExtractedData)] = [];

  let images = HashMap.fromIter<Nat, ImageData>(imageEntries.vals(), 10, Nat.equal, func (x) = Nat32.fromNat(x));
  let extractedData = HashMap.fromIter<Nat, ExtractedData>(extractedDataEntries.vals(), 10, Nat.equal, func (x) = Nat32.fromNat(x));

  // Helper functions
  func mockExtractDataFromImage(image: ImageData) : ExtractedData {
    {
      filename = image.filename;
      documentType = ?"Passport";
      country = ?"United States";
      passportNumber = ?"123456789";
      surname = ?"Doe";
      givenName = ?"John";
      dateOfBirth = ?"01/01/1990";
      gender = ?"M";
      placeOfBirth = ?"New York";
      placeOfIssue = ?"Washington D.C.";
      dateOfIssue = ?"01/01/2020";
      dateOfExpiry = ?"01/01/2030";
    }
  };

  // Public functions
  public func uploadImage(filename: Text, data: Blob) : async Nat {
    let id = nextImageId;
    nextImageId += 1;
    
    let imageData: ImageData = {
      filename = filename;
      data = data;
    };
    
    images.put(id, imageData);
    
    let extracted = mockExtractDataFromImage(imageData);
    extractedData.put(id, extracted);
    
    id
  };

  public query func getExtractedData(id: Nat) : async ?ExtractedData {
    extractedData.get(id)
  };

  public query func getAllExtractedData() : async [ExtractedData] {
    Iter.toArray(extractedData.vals())
  };

  public query func generateCSV() : async Text {
    let headers = "filename,documentType,country,passportNumber,surname,givenName,dateOfBirth,gender,placeOfBirth,placeOfIssue,dateOfIssue,dateOfExpiry\n";
    let rows = Buffer.Buffer<Text>(0);
    
    for (data in extractedData.vals()) {
      let row = Text.join(",", [
        data.filename,
        Option.get(data.documentType, ""),
        Option.get(data.country, ""),
        Option.get(data.passportNumber, ""),
        Option.get(data.surname, ""),
        Option.get(data.givenName, ""),
        Option.get(data.dateOfBirth, ""),
        Option.get(data.gender, ""),
        Option.get(data.placeOfBirth, ""),
        Option.get(data.placeOfIssue, ""),
        Option.get(data.dateOfIssue, ""),
        Option.get(data.dateOfExpiry, "")
      ].vals());
      rows.add(row);
    };
    
    headers # Text.join("\n", rows.vals())
  };

  // System functions
  system func preupgrade() {
    imageEntries := Iter.toArray(images.entries());
    extractedDataEntries := Iter.toArray(extractedData.entries());
  };

  system func postupgrade() {
    imageEntries := [];
    extractedDataEntries := [];
  };
}

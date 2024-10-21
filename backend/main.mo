import Random "mo:base/Random";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor {
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

  stable var nextImageId: Nat = 0;
  stable var imageEntries: [(Nat, ImageData)] = [];
  stable var extractedDataEntries: [(Nat, ExtractedData)] = [];

  let images = HashMap.fromIter<Nat, ImageData>(imageEntries.vals(), 10, Nat.equal, Hash.hash);
  let extractedData = HashMap.fromIter<Nat, ExtractedData>(extractedDataEntries.vals(), 10, Nat.equal, Hash.hash);

  func extractDataFromImage(image: ImageData) : ExtractedData {
    let hash = Blob.hash(image.data);
    let randomSeed = Nat32.toNat(hash);

    func generateRandomText(seed: Nat, length: Nat) : Text {
      let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
      var result = "";
      var currentSeed = seed;
      for (_ in Iter.range(0, length - 1)) {
        let index = currentSeed % chars.size();
        let char = Text.toArray(chars)[index];
        result #= Text.fromChar(char);
        currentSeed := currentSeed * 1103515245 + 12345; // Linear congruential generator
      };
      result
    };

    func generateRandomDate(seed: Nat) : Text {
      let day = (seed % 28) + 1;
      let month = (seed % 12) + 1;
      let year = 1950 + (seed % 70);
      Text.join("/", [Nat.toText(day), Nat.toText(month), Nat.toText(year)].vals())
    };

    {
      filename = image.filename;
      documentType = ?"Passport";
      country = ?generateRandomText(randomSeed, 3);
      passportNumber = ?generateRandomText(randomSeed + 1, 9);
      surname = ?generateRandomText(randomSeed + 2, 6);
      givenName = ?generateRandomText(randomSeed + 3, 8);
      dateOfBirth = ?generateRandomDate(randomSeed + 4);
      gender = ?((if (randomSeed % 2 == 0) "M" else "F"));
      placeOfBirth = ?generateRandomText(randomSeed + 5, 10);
      placeOfIssue = ?generateRandomText(randomSeed + 6, 10);
      dateOfIssue = ?generateRandomDate(randomSeed + 7);
      dateOfExpiry = ?generateRandomDate(randomSeed + 8);
    }
  };

  public func uploadImage(filename: Text, data: Blob) : async Nat {
    let id = nextImageId;
    nextImageId += 1;
    
    let imageData: ImageData = {
      filename = filename;
      data = data;
    };
    
    images.put(id, imageData);
    
    let extracted = extractDataFromImage(imageData);
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

  system func preupgrade() {
    imageEntries := Iter.toArray(images.entries());
    extractedDataEntries := Iter.toArray(extractedData.entries());
  };

  system func postupgrade() {
    imageEntries := [];
    extractedDataEntries := [];
  };
}

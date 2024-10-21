export const idlFactory = ({ IDL }) => {
  const ExtractedData = IDL.Record({
    'placeOfBirth' : IDL.Opt(IDL.Text),
    'dateOfExpiry' : IDL.Opt(IDL.Text),
    'placeOfIssue' : IDL.Opt(IDL.Text),
    'documentType' : IDL.Opt(IDL.Text),
    'country' : IDL.Opt(IDL.Text),
    'dateOfBirth' : IDL.Opt(IDL.Text),
    'dateOfIssue' : IDL.Opt(IDL.Text),
    'surname' : IDL.Opt(IDL.Text),
    'givenName' : IDL.Opt(IDL.Text),
    'filename' : IDL.Text,
    'gender' : IDL.Opt(IDL.Text),
    'passportNumber' : IDL.Opt(IDL.Text),
  });
  return IDL.Service({
    'generateCSV' : IDL.Func([], [IDL.Text], ['query']),
    'getAllExtractedData' : IDL.Func([], [IDL.Vec(ExtractedData)], ['query']),
    'getExtractedData' : IDL.Func(
        [IDL.Nat],
        [IDL.Opt(ExtractedData)],
        ['query'],
      ),
    'uploadImage' : IDL.Func([IDL.Text, IDL.Vec(IDL.Nat8)], [IDL.Nat], []),
  });
};
export const init = ({ IDL }) => { return []; };

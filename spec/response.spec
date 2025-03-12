# BIMI Validator

## BIMI Validator Request

The BIMI Validator expects a posted request with a JSON payload containing 2 fields. In the default setup this request is made to the /checkdomain URI.

- **domain**: `String`
  The domain being validated
- **selector**: `String`
  The optional selector to validate, defaults to 'default'

A JSON object will be returned as defined below.

## BIMI Validator Response

A failed BIMI Validator request will return a JSON object as defined below

- **error**: `String`
  A text representation of the error encountered

A successful BIMI Validator request will return a JSON object as defined below

- **request**: `RequestObject`
  A request object representing the request made
- **response**: `ResponseObject|null`
  A response object representing the resulting BIMI record
- **result**: `ResultObject|null`
  A result object representing the Authentication-Results generated from this BIMI record

A **RequestObject** object has the following properties:

- **domain**: `String`
  The domain requested
- **selector**: `String`
  The selector requested

A **ResponseObject** object has the following properties:

- **record**: `RecordObject`

A **RecordObject** object has the following properties:

- **authority**: `AuthorityObject|null`
  Details of the authority for this record
- **errors**: `ErrorsObject[]`
  A list of errors encountered
- **is_valid**: `Boolean`
  True if this BIMI record was validated
- **location**: `LocationObject|null`
  Details of the location for this record
- **retrieved_domain**: `String`
  The domain the record was retrieved from, this may be the org domain
- **retrieved_record**: `String`
  The record as retrieved
- **retrieved_selector**: `String`
  The selector used to retrieve the record
- **version**: `String`
  The BIMI version from the record, currently BIMI1
- **warnings**: `String[]`
  A list of warnings generated

A **LocationObject** object has the following properties:

- **errors**: `ErrorsObject[]`
  A list of errors encountered
- **indicator**: `IndicatorObject|null`
  The indicator from this VMC
- **is_valid**: `Boolean`
  True if this location record is valid for BIMI
- **uri**: `String`
  The URI this location was retrieved from

A **AuthorityObject object has the following properties:

- **errors**: `ErrorsObject[]`
  A list of errors encountered
- **is_valid**: `Boolean`
  True if this record is valid for BIMI
- **uri**: `String`
  The URI this VMC was retrieved from
- **vmc**: `VMCObject|null`
  The VMC object for this authority

A **VMCObject** object has the following properties:

- **chain**: `ChainObject|null`
  The certificate chain for this VMC
- **errors**: `ErrorsObject[]`
  A list of errors encountered
- **has_valid_usage**: `Boolean`
  True if this VMC had a valid usage flag for BIMI
- **indicator**: `IndicatorObject|null`
  The indicator from this VMC
- **is_allowed_mark_type**: `Boolean`
  True if this mark type was allowed in our config
- **is_cert_valid**: `Boolean`
  True if this VMC cert was validated
- **is_expired**: `Boolean`
  True if this VMC is expired
- **is_valid**: `Boolean`
  True if this VMC was validated
- **is_valid_alt_name**: `Boolean`
  True if the alt name was valid for the given domain
- **issuer**: `String|null`
  Text issuer field from the certificate
- **mark_type**: `String`
  Text mark type
- **not_after**: `DateString|null`
  The Not After date for this VMC
- **not_before**: `DateString|null`
  The Not Before date for this VMC
- **subject**: `String|null`
  The text subject from this VMC
- **uri**: `String`
  The URI this VMC was retrieved from

A **ChainObject** object...

- **certs**: `CertObject[]`
  An array of cert object for this chain
- **is_valid**: `Boolean`
  True if this certificate chain was validated

A **CertObject** object has the following properties:

- **alt_name**: `String|null`
  The alt name presented in the certificate
- **errors**: `ErrorsObject[]`
  A list of errors encountered
- **has_logotype_extn**: `Boolean`
  True if this cert has the logotype extension
- **has_valid_usage**: `Boolean`
  True of this cert had a valid usage flag for BIMI
- **index**: `Number`
  Numeric index for this cert in the chain
- **is_experimental**: `Boolean`
  True if the experimental flag was set on the cert
- **is_expired**: `Boolean`
  True if this cert was expired
- **is_valid**: `Boolean`
  True if this cert passed validation
- **is_valid_to_root**: `Boolean`
  True if this cert was validated via a trusted root certificate
- **issuer**: `String|null`
  The issuer field from this cert
- **not_after**: `DateString|null`
  The Not After date from this cert
- **not_before**: `DateString|null`
  The Not Before date from this cert
- **subject**: `String|null`
  The text subject from this cert
- **valid_to_root_via**: `Number|null`
  The certificate index of the cert which linked this cert to a trusted root cert. 0 if this is directly trusted.


A **IndicatorObject** object has the following properties:

- **errors**: `ErrorsObject[]`
  A list of errors encountered
- **is_valid**: `Boolean`
  True if the indicator was validated
- **size_header**: `Number`
  The size of the BIMI-Indicator header field generated by this indicator
- **size_raw**: `Number`
  The Raw size of the indicator as retrieved
- **size_uncompressed**: `Number`
  The size of the indicator without gzip compression
- **uri**: `String`
  The URI the indicator was retrieved from

A **ResultObject** object has the following properties:

- **authentication_results**: `String`
  A text representation of the authentication-results header generated
- **header**: `HeaderObject`
  A Header object conatining the generated headers for this result
- **result**: `String`
  A text representation of the Authentication result, pass/fail/etc

A **HeaderObject** object has the following optional properties:

- **BIMI-Indicator**: `String`
  The BIMI-Indicator header generated
- **BIMI-Location**: `String`
  The BIMI-Location header generated

This objects properties are keyed on the headers which may be added, these may be missing of no header of that name is to be added, and there may be extra entries if additional headers are to be added.

A **ErrorsObject** object has the following properties:

- **code**: `String`
  The error code
- **description**: `String`
  A text description of the error
- **detail**: `String`
  A detailed text description of the error

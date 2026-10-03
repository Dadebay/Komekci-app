/// Base URL of the KÖMEKÇI backend. Endpoints are appended to this.
const apiBaseUrl = 'https://komekchi.brandsforlesstm.com/api';

/// How long a single request may take before the app falls back to defaults.
const apiTimeout = Duration(seconds: 8);

/// Photo and banner uploads are far slower than JSON calls.
const apiUploadTimeout = Duration(seconds: 60);
